#!/usr/bin/env python
"""Fail-closed exact environment fingerprint and deployment-lock verifier."""

from __future__ import print_function

import argparse
import contextlib
import hashlib
import io
import json
import os
import platform
import subprocess
import sys


CONTRACT_ID = "moseq2-legacy-study-2026-07-29-v1"
MODULES = {
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
REPOSITORY_ENV = {
    "moseq2-extract": "MOSEQ2_EXTRACT_REPO",
    "moseq2-viz": "MOSEQ2_VIZ_REPO",
    "moseq2-app": "MOSEQ2_APP_REPO",
    "moseq2-pca": "MOSEQ2_PCA_REPO",
    "moseq2-model": "MOSEQ2_MODEL_REPO",
}
REPOSITORY_MODULE = {
    "moseq2-extract": "moseq2_extract",
    "moseq2-viz": "moseq2_viz",
    "moseq2-app": "moseq2_app",
    "moseq2-pca": "moseq2_pca",
    "moseq2-model": "moseq2_model",
}
DEPENDENCY_ENV = {
    "pyhsmm": "MOSEQ_PYHSMM_REPO",
    "pybasicbayes": "MOSEQ_PYBASICBAYES_REPO",
    "autoregressive": "MOSEQ_AUTOREGRESSIVE_REPO",
}


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def sha256_text(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def command(command):
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT)
        return {
            "status": "VERIFIED",
            "value": output.decode("utf-8", "replace").strip(),
        }
    except Exception as error:
        return {
            "status": "UNRESOLVED",
            "value": "UNRESOLVED",
            "error": "{}: {}".format(type(error).__name__, error),
        }


def import_version(module_name):
    try:
        module = __import__(module_name, fromlist=["*"])
        return str(getattr(module, "__version__", "UNRESOLVED"))
    except Exception:
        return "UNRESOLVED"


def add_check(checks, name, expected, observed):
    if expected in (None, "", "UNRESOLVED"):
        status = "UNRESOLVED"
    elif observed in (None, "", "UNRESOLVED"):
        status = "UNRESOLVED"
    elif expected == observed:
        status = "VERIFIED"
    else:
        status = "MISMATCH"
    checks.append(
        {
            "name": name,
            "status": status,
            "expected": expected,
            "observed": observed,
        }
    )
    return status


def canonical_conda(records):
    result = []
    for item in records:
        result.append(
            {
                "name": str(item.get("name", "")),
                "version": str(item.get("version", "")),
                "build": str(item.get("build_string", item.get("build", ""))),
                "channel": str(item.get("channel", "")),
            }
        )
    return sorted(result, key=lambda record: record["name"].lower())


def read_os_release():
    result = {}
    try:
        with open("/etc/os-release", "r") as stream:
            for line in stream:
                if "=" in line:
                    key, value = line.rstrip("\n").split("=", 1)
                    result[key] = value.strip('"')
    except Exception:
        pass
    return result


def git_head(path):
    if not path or not os.path.isdir(path):
        return "UNRESOLVED"
    result = command(["git", "-C", path, "rev-parse", "HEAD"])
    if result["status"] != "VERIFIED":
        return "UNRESOLVED"
    return result["value"]


def module_under_repository(module_name, repository):
    if not repository or not os.path.isdir(repository):
        return "UNRESOLVED"
    try:
        module = __import__(module_name, fromlist=["*"])
        module_file = os.path.realpath(str(module.__file__))
        repository_real = os.path.realpath(repository)
        if module_file == repository_real or module_file.startswith(
            repository_real + os.sep
        ):
            return "VERIFIED"
        return module_file
    except Exception:
        return "UNRESOLVED"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lock", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    lock_path = os.path.abspath(args.lock)
    output_path = os.path.abspath(args.output)
    if not os.path.isfile(lock_path):
        raise SystemExit("deployment lock is missing: {}".format(lock_path))
    output_parent = os.path.dirname(output_path)
    if not os.path.isdir(output_parent):
        raise SystemExit("output parent does not exist: {}".format(output_parent))
    if os.path.exists(output_path):
        raise SystemExit("refusing to overwrite fingerprint: {}".format(output_path))

    with open(lock_path, "r") as stream:
        lock = json.load(stream)
    checks = []
    add_check(checks, "contract_id", CONTRACT_ID, lock.get("contract_id"))
    add_check(checks, "lock_status", "COMPLETE", lock.get("status"))

    expected = lock.get("expected_environment", {})
    packages = {}
    for label, module_name in sorted(MODULES.items()):
        packages[label] = import_version(module_name)

    linked_hdf5 = "UNRESOLVED"
    try:
        import h5py

        linked_hdf5 = str(h5py.version.hdf5_version)
    except Exception:
        pass

    blas_text = "UNRESOLVED"
    try:
        import numpy

        buffer_value = io.StringIO()
        with contextlib.redirect_stdout(buffer_value):
            numpy.__config__.show()
        blas_text = buffer_value.getvalue().replace("\r\n", "\n")
    except Exception:
        pass

    conda_exe = os.environ.get("CONDA_EXE", "conda")
    conda_result = command([conda_exe, "list", "--json"])
    conda_packages = "UNRESOLVED"
    if conda_result["status"] == "VERIFIED":
        try:
            conda_packages = canonical_conda(json.loads(conda_result["value"]))
        except Exception:
            conda_packages = "UNRESOLVED"

    ffmpeg_result = command(["ffmpeg", "-version"])
    ffmpeg_first = "UNRESOLVED"
    if ffmpeg_result["status"] == "VERIFIED":
        ffmpeg_first = ffmpeg_result["value"].splitlines()[0]

    os_release = read_os_release()
    observed_environment = {
        "python": sys.version.replace("\n", " "),
        "packages": packages,
        "linked_hdf5": linked_hdf5,
        "platform": platform.platform(),
        "kernel": platform.release(),
        "machine": platform.machine(),
        "thread_environment": {
            name: os.environ.get(name, "UNSET")
            for name in sorted(expected.get("thread_environment", {}))
        },
        "ffmpeg_first_line": ffmpeg_first,
        "os_id": os_release.get("ID", "UNRESOLVED"),
        "os_version_id": os_release.get("VERSION_ID", "UNRESOLVED"),
        "blas_lapack_text_sha256": sha256_text(blas_text)
        if blas_text != "UNRESOLVED"
        else "UNRESOLVED",
        "conda_packages": conda_packages,
    }

    for key in (
        "python",
        "linked_hdf5",
        "platform",
        "kernel",
        "machine",
        "ffmpeg_first_line",
        "os_id",
        "os_version_id",
        "blas_lapack_text_sha256",
    ):
        add_check(
            checks,
            "environment.{}".format(key),
            expected.get(key, "UNRESOLVED"),
            observed_environment[key],
        )

    expected_package_records = expected.get("packages", {})
    for label in sorted(MODULES):
        expected_version = expected_package_records.get(label, {}).get(
            "version", "UNRESOLVED"
        )
        add_check(
            checks,
            "package.{}".format(label),
            expected_version,
            packages[label],
        )

    for name, value in sorted(expected.get("thread_environment", {}).items()):
        add_check(
            checks,
            "thread_environment.{}".format(name),
            value,
            observed_environment["thread_environment"].get(name, "UNRESOLVED"),
        )
    add_check(
        checks,
        "conda_packages_exact",
        lock.get("conda_packages", "UNRESOLVED"),
        conda_packages,
    )

    repository_observed = {}
    for name, env_name in sorted(REPOSITORY_ENV.items()):
        repository_path = os.environ.get(env_name)
        observed = git_head(repository_path)
        import_source = module_under_repository(
            REPOSITORY_MODULE[name], repository_path
        )
        repository_observed[name] = {
            "commit": observed,
            "import_source": import_source,
        }
        add_check(
            checks,
            "repository.{}".format(name),
            lock.get("repositories", {}).get(name, {}).get(
                "commit", "UNRESOLVED"
            ),
            observed,
        )
        add_check(
            checks,
            "repository.{}.import_source".format(name),
            "VERIFIED",
            import_source,
        )

    dependency_observed = {}
    for name, env_name in sorted(DEPENDENCY_ENV.items()):
        repository_path = os.environ.get(env_name)
        observed = git_head(repository_path)
        import_source = module_under_repository(name, repository_path)
        dependency_observed[name] = {
            "commit": observed,
            "import_source": import_source,
        }
        add_check(
            checks,
            "git_dependency.{}".format(name),
            lock.get("git_dependencies", {}).get(name, {}).get(
                "commit", "UNRESOLVED"
            ),
            observed,
        )
        add_check(
            checks,
            "git_dependency.{}.import_source".format(name),
            "VERIFIED",
            import_source,
        )

    classifier_path = os.environ.get("MOSEQ_CLASSIFIER_PATH", "")
    classifier_observed = {
        "path": classifier_path or "UNRESOLVED",
        "sha256": sha256_file(classifier_path)
        if os.path.isfile(classifier_path)
        else "UNRESOLVED",
        "bytes": os.path.getsize(classifier_path)
        if os.path.isfile(classifier_path)
        else "UNRESOLVED",
    }
    add_check(
        checks,
        "classifier.sha256",
        lock.get("classifier", {}).get("sha256", "UNRESOLVED"),
        classifier_observed["sha256"],
    )
    add_check(
        checks,
        "classifier.bytes",
        lock.get("classifier", {}).get("bytes", "UNRESOLVED"),
        classifier_observed["bytes"],
    )

    configuration_root = os.environ.get("MOSEQ_CONFIGURATION_ROOT", "")
    configuration_observed = {}
    for item in lock.get("configurations", {}).get("files", []):
        bundle_name = os.path.basename(str(item.get("bundle_path", "")))
        deployed = (
            os.path.join(configuration_root, bundle_name)
            if configuration_root and bundle_name
            else ""
        )
        observed_record = {
            "sha256": sha256_file(deployed)
            if os.path.isfile(deployed)
            else "UNRESOLVED",
            "bytes": os.path.getsize(deployed)
            if os.path.isfile(deployed)
            else "UNRESOLVED",
        }
        configuration_observed[bundle_name or "UNRESOLVED"] = observed_record
        add_check(
            checks,
            "configuration.{}.sha256".format(bundle_name),
            item.get("sha256", "UNRESOLVED"),
            observed_record["sha256"],
        )
        add_check(
            checks,
            "configuration.{}.bytes".format(bundle_name),
            item.get("bytes", "UNRESOLVED"),
            observed_record["bytes"],
        )

    site_expected = lock.get("sitecustomize", {})
    site_observed = {
        "status": "VERIFIED_ABSENT",
        "path": "ABSENT",
        "sha256": "ABSENT",
        "bytes": 0,
    }
    try:
        import sitecustomize

        site_path = os.path.abspath(sitecustomize.__file__)
        site_observed = {
            "status": "RESOLVED",
            "path": site_path,
            "sha256": sha256_file(site_path),
            "bytes": os.path.getsize(site_path),
        }
    except ImportError:
        pass
    except Exception:
        site_observed = {
            "status": "UNRESOLVED",
            "path": "UNRESOLVED",
            "sha256": "UNRESOLVED",
            "bytes": "UNRESOLVED",
        }
    add_check(
        checks,
        "sitecustomize.status",
        site_expected.get("status", "UNRESOLVED"),
        site_observed["status"],
    )
    add_check(
        checks,
        "sitecustomize.sha256",
        site_expected.get("sha256", "UNRESOLVED"),
        site_observed["sha256"],
    )
    add_check(
        checks,
        "sitecustomize.bytes",
        site_expected.get("bytes", "UNRESOLVED"),
        site_observed["bytes"],
    )

    observed = {
        "environment": observed_environment,
        "repositories": repository_observed,
        "git_dependencies": dependency_observed,
        "classifier": classifier_observed,
        "configurations": configuration_observed,
        "sitecustomize": site_observed,
    }
    canonical = json.dumps(
        observed, sort_keys=True, separators=(",", ":"), ensure_ascii=True
    )
    statuses = [item["status"] for item in checks]
    if all(status == "VERIFIED" for status in statuses):
        overall = "VERIFIED"
        exit_code = 0
    elif "MISMATCH" in statuses:
        overall = "MISMATCH"
        exit_code = 2
    else:
        overall = "UNRESOLVED"
        exit_code = 3

    report = {
        "schema_version": 1,
        "contract_id": CONTRACT_ID,
        "status": overall,
        "deployment_lock_sha256": sha256_file(lock_path),
        "fingerprint_sha256": sha256_text(canonical),
        "observed": observed,
        "checks": checks,
    }
    with open(output_path, "w") as stream:
        json.dump(report, stream, indent=2, sort_keys=True)
        stream.write("\n")
    print("{} {}".format(overall, output_path))
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
