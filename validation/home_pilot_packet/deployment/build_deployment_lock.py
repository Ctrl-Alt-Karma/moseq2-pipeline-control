#!/usr/bin/env python
"""Build the canonical offline-deployment lock from golden-reference evidence."""

from __future__ import print_function

import argparse
import hashlib
import json
import os
import platform
import re
import subprocess
import sys


CONTRACT_ID = "moseq2-legacy-study-2026-07-29-v1"
LOCKED_REPOSITORIES = {
    "moseq2-extract": "e7f585104ba25b66e5326c88c77a47e33db95635",
    "moseq2-viz": "b80192dc20353bf77c36610f315543b57afa908c",
    "moseq2-app": "e0b85201226d03e15944473a734f71417698c31e",
    "moseq2-pca": "efb6fcfa5d5af5bb4274540c371d0ddf96440b78",
    "moseq2-model": "6e542e3f1db125202d42b59f390c922281e64f39",
}
GIT_DEPENDENCIES = ("pyhsmm", "pybasicbayes", "autoregressive")


def read_json(path):
    with open(path, "r") as stream:
        return json.load(stream)


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def file_record(root, path):
    relative = os.path.relpath(path, root).replace(os.sep, "/")
    return {
        "path": relative,
        "sha256": sha256(path),
        "bytes": os.path.getsize(path),
    }


def run(command):
    return subprocess.check_output(command, stderr=subprocess.STDOUT).decode(
        "utf-8", "replace"
    ).strip()


def canonical_conda_packages(records):
    result = []
    for record in records:
        result.append(
            {
                "name": str(record.get("name", "")),
                "version": str(record.get("version", "")),
                "build": str(record.get("build_string", record.get("build", ""))),
                "channel": str(record.get("channel", "")),
            }
        )
    return sorted(result, key=lambda item: item["name"].lower())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bundle-root", required=True)
    parser.add_argument("--sitecustomize-absent", action="store_true")
    args = parser.parse_args()

    root = os.path.abspath(args.bundle_root)
    records = os.path.join(root, "records")
    golden = os.path.join(root, "golden_environment")
    required = {
        "conda_explicit": os.path.join(records, "conda-explicit.txt"),
        "conda_environment": os.path.join(records, "environment.yml"),
        "pip_freeze": os.path.join(records, "pip-freeze.txt"),
        "pip_list": os.path.join(records, "pip-list.txt"),
        "conda_list_json": os.path.join(records, "conda-list.json"),
        "python_environment": os.path.join(golden, "python_environment.json"),
        "blas_lapack": os.path.join(golden, "numpy_blas_lapack.txt"),
        "dependency_custody": os.path.join(
            golden, "floating_dependency_custody.json"
        ),
        "sitecustomize": os.path.join(golden, "active_sitecustomize.json"),
        "classifier": os.path.join(records, "classifier.json"),
        "repository_bundles": os.path.join(records, "repository-bundles.json"),
        "artifact_report": os.path.join(records, "artifact-report.json"),
        "configurations": os.path.join(records, "configurations.json"),
        "ffmpeg": os.path.join(records, "ffmpeg-version.txt"),
        "os_release": os.path.join(records, "os-release.txt"),
        "known_answer": os.path.join(records, "golden-known-answer.json"),
    }
    missing_files = [
        label for label, path in required.items() if not os.path.isfile(path)
    ]
    if missing_files:
        raise SystemExit(
            "required golden records missing: {}".format(", ".join(missing_files))
        )

    python_environment = read_json(required["python_environment"])
    dependencies_raw = read_json(required["dependency_custody"])
    sitecustomize = read_json(required["sitecustomize"])
    classifier = read_json(required["classifier"])
    repository_bundles = read_json(required["repository_bundles"])
    artifacts = read_json(required["artifact_report"])
    configurations = read_json(required["configurations"])
    for item in configurations.get("files", []):
        try:
            item["bytes"] = int(item.get("bytes"))
        except (TypeError, ValueError):
            item["bytes"] = "UNRESOLVED"
    known_answer = read_json(required["known_answer"])
    conda_packages = canonical_conda_packages(read_json(required["conda_list_json"]))

    unresolved = []
    dependencies = {}
    for name in GIT_DEPENDENCIES:
        source = dependencies_raw.get(name, {})
        commit = str(source.get("exact_git_sha", "UNRESOLVED"))
        status = str(source.get("status", "UNRESOLVED"))
        if status != "RESOLVED" or not re.match(r"^[0-9a-fA-F]{40}$", commit):
            unresolved.append("git_dependency:{}".format(name))
            status = "UNRESOLVED"
            commit = "UNRESOLVED"
        dependencies[name] = {
            "status": status,
            "commit": commit.lower() if commit != "UNRESOLVED" else commit,
            "evidence": file_record(root, required["dependency_custody"]),
        }

    repositories = {}
    for name, expected in sorted(LOCKED_REPOSITORIES.items()):
        record = repository_bundles.get(name, {})
        observed = str(record.get("commit", "UNRESOLVED"))
        bundle_path = record.get("bundle_path")
        bundle_file = (
            os.path.join(root, bundle_path.replace("/", os.sep))
            if bundle_path
            else ""
        )
        status = "VERIFIED"
        if observed != expected or not bundle_file or not os.path.isfile(bundle_file):
            status = "MISMATCH"
            unresolved.append("repository_bundle:{}".format(name))
        repositories[name] = {
            "status": status,
            "commit": expected,
            "bundle": file_record(root, bundle_file)
            if os.path.isfile(bundle_file)
            else {
                "path": bundle_path or "UNRESOLVED",
                "sha256": "UNRESOLVED",
                "bytes": "UNRESOLVED",
            },
        }

    if classifier.get("status") != "RESOLVED":
        unresolved.append("classifier")

    if args.sitecustomize_absent:
        site_lock = {
            "status": "VERIFIED_ABSENT",
            "sha256": "ABSENT",
            "bytes": 0,
            "bundle_path": "ABSENT",
        }
    elif sitecustomize.get("status") == "RESOLVED":
        archived_site = os.path.join(root, "custody", "sitecustomize.py")
        if not os.path.isfile(archived_site):
            unresolved.append("sitecustomize_archive")
        site_lock = {
            "status": "RESOLVED",
            "sha256": sitecustomize.get("sha256", "UNRESOLVED"),
            "bytes": sitecustomize.get("bytes", "UNRESOLVED"),
            "bundle_path": "custody/sitecustomize.py",
        }
    else:
        site_lock = {
            "status": "UNRESOLVED",
            "sha256": "UNRESOLVED",
            "bytes": "UNRESOLVED",
            "bundle_path": "UNRESOLVED",
        }
        unresolved.append("sitecustomize")

    if artifacts.get("status") != "COMPLETE":
        unresolved.append("offline_artifacts")
    if known_answer.get("status") != "GOLDEN_ESTABLISHED":
        unresolved.append("known_answer")
    if configurations.get("status") != "RESOLVED":
        unresolved.append("configurations")

    ffmpeg_first = ""
    with open(required["ffmpeg"], "r") as stream:
        ffmpeg_first = stream.readline().strip()
    os_release = {}
    with open(required["os_release"], "r") as stream:
        for line in stream:
            if "=" in line:
                key, value = line.rstrip("\n").split("=", 1)
                os_release[key] = value.strip('"')

    expected_environment = {
        "python": python_environment.get("python", "UNRESOLVED"),
        "packages": python_environment.get("packages", {}),
        "linked_hdf5": python_environment.get("linked_hdf5", "UNRESOLVED"),
        "platform": python_environment.get("platform", "UNRESOLVED"),
        "kernel": python_environment.get("kernel", "UNRESOLVED"),
        "machine": python_environment.get("machine", "UNRESOLVED"),
        "thread_environment": python_environment.get("thread_environment", {}),
        "ffmpeg_first_line": ffmpeg_first or "UNRESOLVED",
        "os_id": os_release.get("ID", "UNRESOLVED"),
        "os_version_id": os_release.get("VERSION_ID", "UNRESOLVED"),
        "blas_lapack_text_sha256": sha256(required["blas_lapack"]),
    }
    for key, value in expected_environment.items():
        if value in ("UNRESOLVED", "", None):
            unresolved.append("environment:{}".format(key))

    lock = {
        "schema_version": 1,
        "contract_id": CONTRACT_ID,
        "status": "COMPLETE" if not unresolved else "INCOMPLETE",
        "golden_reference": {
            "host_role": "HOME_WSL_GOLDEN_REFERENCE",
            "environment_name": "moseq2-app",
            "conda_prefix": "/home/ajm/miniforge3/envs/moseq2-app",
            "generated_by_python": sys.version.replace("\n", " "),
            "generator_host": platform.platform(),
        },
        "expected_environment": expected_environment,
        "conda_packages": conda_packages,
        "records": {
            key: file_record(root, path)
            for key, path in required.items()
            if key not in ("dependency_custody", "sitecustomize")
        },
        "repositories": repositories,
        "git_dependencies": dependencies,
        "classifier": classifier,
        "sitecustomize": site_lock,
        "configurations": configurations,
        "artifacts": artifacts,
        "known_answer": known_answer,
        "unresolved": sorted(set(unresolved)),
    }

    lock_path = os.path.join(root, "deployment-lock.json")
    with open(lock_path, "w") as stream:
        json.dump(lock, stream, indent=2, sort_keys=True)
        stream.write("\n")
    print(lock_path)
    if lock["status"] != "COMPLETE":
        return 3
    return 0


if __name__ == "__main__":
    sys.exit(main())
