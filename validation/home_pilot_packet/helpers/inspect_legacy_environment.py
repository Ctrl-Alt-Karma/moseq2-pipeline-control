#!/usr/bin/env python
"""Inspection-only legacy environment and dependency custody recorder."""

from __future__ import print_function

import argparse
import contextlib
import hashlib
import json
import os
import platform
import re
import subprocess
import sys

try:
    import pkg_resources
except ImportError:
    pkg_resources = None


def safe_import_version(module_name, attribute="__version__"):
    try:
        module = __import__(module_name, fromlist=["*"])
        return {
            "version": str(getattr(module, attribute, "UNKNOWN")),
            "file": str(getattr(module, "__file__", "UNKNOWN")),
        }
    except Exception as error:
        return {
            "version": "UNAVAILABLE",
            "error": "{}: {}".format(type(error).__name__, error),
        }


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def run(command, cwd=None):
    try:
        output = subprocess.check_output(
            command, cwd=cwd, stderr=subprocess.STDOUT
        )
        return output.decode("utf-8", "replace").strip()
    except Exception as error:
        return "UNRESOLVED: {}: {}".format(type(error).__name__, error)


def find_git_commit(start):
    current = os.path.abspath(start)
    if os.path.isfile(current):
        current = os.path.dirname(current)
    visited = []
    for unused in range(8):
        visited.append(current)
        if os.path.isdir(os.path.join(current, ".git")):
            head = run(["git", "-C", current, "rev-parse", "HEAD"])
            remote = run(["git", "-C", current, "remote", "get-url", "origin"])
            return {
                "status": "RESOLVED" if len(head) == 40 else "UNRESOLVED",
                "sha": head,
                "repository": current,
                "origin": remote,
                "searched": visited,
            }
        parent = os.path.dirname(current)
        if parent == current:
            break
        current = parent
    return {
        "status": "UNRESOLVED",
        "sha": "UNRESOLVED",
        "repository": "UNRESOLVED",
        "searched": visited,
    }


def distribution_record(name):
    record = {"name": name, "status": "UNRESOLVED"}
    if pkg_resources is None:
        record["package_metadata_error"] = "pkg_resources is unavailable"
        record["pip_show"] = run(
            [sys.executable, "-m", "pip", "show", "--verbose", name]
        )
        module_name = name.replace("-", "_")
        try:
            module = __import__(module_name, fromlist=["*"])
            module_file = os.path.abspath(module.__file__)
            record["module_files"] = [module_file]
            git_record = find_git_commit(module_file)
            record["git_evidence"] = [git_record]
            if git_record["status"] == "RESOLVED":
                record["status"] = "RESOLVED"
                record["exact_git_sha"] = git_record["sha"]
            else:
                record["exact_git_sha"] = "UNRESOLVED"
        except Exception as error:
            record["module_import_error"] = "{}: {}".format(
                type(error).__name__, error
            )
            record["exact_git_sha"] = "UNRESOLVED"
        return record
    try:
        dist = pkg_resources.get_distribution(name)
    except Exception as error:
        record["error"] = "{}: {}".format(type(error).__name__, error)
        return record

    record.update(
        {
            "version": dist.version,
            "location": dist.location,
            "egg_info": dist.egg_info,
        }
    )
    metadata_files = []
    direct_url_record = None
    if os.path.isdir(dist.egg_info):
        for candidate in (
            "direct_url.json",
            "PKG-INFO",
            "METADATA",
            "SOURCES.txt",
            "top_level.txt",
            "installed-files.txt",
        ):
            path = os.path.join(dist.egg_info, candidate)
            if os.path.isfile(path):
                metadata_files.append(
                    {
                        "path": path,
                        "bytes": os.path.getsize(path),
                        "sha256": sha256(path),
                    }
                )
                if candidate == "direct_url.json":
                    try:
                        with open(path, "r") as stream:
                            direct_url_record = json.load(stream)
                    except Exception as error:
                        direct_url_record = {
                            "status": "UNRESOLVED",
                            "error": "{}: {}".format(type(error).__name__, error),
                        }
    record["metadata_files"] = metadata_files
    record["direct_url_json"] = direct_url_record or "ABSENT"

    top_levels = []
    top_level_path = os.path.join(dist.egg_info, "top_level.txt")
    if os.path.isfile(top_level_path):
        with open(top_level_path, "r") as stream:
            top_levels = [line.strip() for line in stream if line.strip()]
    record["top_levels"] = top_levels

    module_files = []
    for module_name in top_levels:
        try:
            module = __import__(module_name, fromlist=["*"])
            module_file = getattr(module, "__file__", None)
            if module_file:
                module_files.append(os.path.abspath(module_file))
        except Exception as error:
            module_files.append(
                "UNRESOLVED {}: {}: {}".format(
                    module_name, type(error).__name__, error
                )
            )
    record["module_files"] = module_files

    starts = [dist.location, dist.egg_info]
    starts.extend(path for path in module_files if os.path.isabs(path))
    commits = [find_git_commit(path) for path in starts]
    resolved = [item for item in commits if item["status"] == "RESOLVED"]
    record["git_evidence"] = commits
    direct_url_sha = None
    if isinstance(direct_url_record, dict):
        direct_url_sha = (
            direct_url_record.get("vcs_info", {}).get("commit_id")
            if isinstance(direct_url_record.get("vcs_info"), dict)
            else None
        )
    if direct_url_sha:
        record["direct_url_commit_id"] = direct_url_sha
        if not re.match(r"^[0-9a-fA-F]{40}$", str(direct_url_sha)):
            record["direct_url_commit_warning"] = "not an exact 40-character SHA"
            direct_url_sha = None
    resolved_shas = [item["sha"] for item in resolved]
    if direct_url_sha:
        resolved_shas.append(str(direct_url_sha))
    if resolved_shas:
        unique = sorted(set(resolved_shas))
        record["status"] = "RESOLVED" if len(unique) == 1 else "UNRESOLVED"
        record["exact_git_sha"] = unique[0] if len(unique) == 1 else "CONFLICT"
    else:
        record["exact_git_sha"] = "UNRESOLVED"
    return record


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()
    output_dir = os.path.abspath(args.output_dir)
    if not os.path.isdir(output_dir):
        raise SystemExit("output directory does not exist: {}".format(output_dir))

    versions = {
        "python": sys.version.replace("\n", " "),
        "executable": sys.executable,
        "prefix": sys.prefix,
        "platform": platform.platform(),
        "kernel": platform.release(),
        "machine": platform.machine(),
        "processor": platform.processor(),
    }
    modules = {
        "numpy": "numpy",
        "scipy": "scipy",
        "pandas": "pandas",
        "opencv": "cv2",
        "scikit_image": "skimage",
        "h5py": "h5py",
        "scikit_learn": "sklearn",
        "dask": "dask",
        "joblib": "joblib",
        "cython": "Cython",
    }
    versions["packages"] = {
        label: safe_import_version(module) for label, module in modules.items()
    }
    try:
        import h5py

        versions["linked_hdf5"] = h5py.version.hdf5_version
    except Exception as error:
        versions["linked_hdf5"] = "UNAVAILABLE: {}".format(error)

    moseq_distributions = {}
    for name, module_name in (
        ("moseq2-extract", "moseq2_extract"),
        ("moseq2-viz", "moseq2_viz"),
        ("moseq2-app", "moseq2_app"),
        ("moseq2-pca", "moseq2_pca"),
        ("moseq2-model", "moseq2_model"),
    ):
        if pkg_resources is not None:
            try:
                dist = pkg_resources.get_distribution(name)
                moseq_distributions[name] = {
                    "version": dist.version,
                    "location": dist.location,
                    "egg_info": dist.egg_info,
                }
                continue
            except Exception as error:
                package_error = "{}: {}".format(type(error).__name__, error)
        else:
            package_error = "pkg_resources is unavailable"
        module_record = safe_import_version(module_name)
        module_record["package_metadata_error"] = package_error
        module_record["pip_show"] = run(
            [sys.executable, "-m", "pip", "show", "--verbose", name]
        )
        moseq_distributions[name] = module_record
    versions["moseq_distributions"] = moseq_distributions

    thread_names = (
        "OMP_NUM_THREADS",
        "MKL_NUM_THREADS",
        "OPENBLAS_NUM_THREADS",
        "NUMEXPR_NUM_THREADS",
        "VECLIB_MAXIMUM_THREADS",
        "BLIS_NUM_THREADS",
        "PYTHONHASHSEED",
    )
    versions["thread_environment"] = {
        name: os.environ.get(name, "UNSET") for name in thread_names
    }

    with open(os.path.join(output_dir, "python_environment.json"), "w") as stream:
        json.dump(versions, stream, indent=2, sort_keys=True)
        stream.write("\n")

    try:
        import numpy

        with open(os.path.join(output_dir, "numpy_blas_lapack.txt"), "w") as stream:
            with contextlib.redirect_stdout(stream):
                numpy.__config__.show()
    except Exception as error:
        with open(os.path.join(output_dir, "numpy_blas_lapack.txt"), "w") as stream:
            stream.write("UNAVAILABLE: {}: {}\n".format(type(error).__name__, error))

    site_record = {
        "status": "UNRESOLVED",
        "path": "UNRESOLVED",
        "sys_path": list(sys.path),
    }
    try:
        import sitecustomize

        path = os.path.abspath(sitecustomize.__file__)
        site_record.update(
            {
                "status": "RESOLVED",
                "path": path,
                "bytes": os.path.getsize(path),
                "sha256": sha256(path),
            }
        )
    except Exception as error:
        site_record["error"] = "{}: {}".format(type(error).__name__, error)
    with open(os.path.join(output_dir, "active_sitecustomize.json"), "w") as stream:
        json.dump(site_record, stream, indent=2, sort_keys=True)
        stream.write("\n")

    dependencies = {
        name: distribution_record(name)
        for name in ("pyhsmm", "pybasicbayes", "autoregressive")
    }
    with open(
        os.path.join(output_dir, "floating_dependency_custody.json"), "w"
    ) as stream:
        json.dump(dependencies, stream, indent=2, sort_keys=True)
        stream.write("\n")


if __name__ == "__main__":
    main()
