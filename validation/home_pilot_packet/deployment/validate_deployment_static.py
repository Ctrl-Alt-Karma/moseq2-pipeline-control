#!/usr/bin/env python
"""Work-machine static checks; never provisions or qualifies a machine."""

from __future__ import print_function

import json
import os
import subprocess
import sys
import tempfile


ROOT = os.path.abspath(os.path.dirname(__file__))
REQUIRED = (
    "DEPLOYMENT_CONTRACT.md",
    "artifact_redistribution_allowlist.example.txt",
    "build_deployment_lock.py",
    "export_offline_environment_bundle.sh",
    "bootstrap_qualified_machine.sh",
    "preflight_environment.py",
    "known_answer_result.py",
    "run_known_answer_qualification.sh",
    "run_pipeline_guarded.sh",
    "import_golden_wsl.ps1",
)


def text(name):
    with open(os.path.join(ROOT, name), "r", encoding="utf-8") as stream:
        return stream.read()


def require(value, message):
    if not value:
        raise AssertionError(message)


def mismatch_preflight_test():
    expected_environment = {
        "python": "impossible-python",
        "packages": {
            name: {"version": "impossible"}
            for name in (
                "numpy",
                "scipy",
                "pandas",
                "opencv",
                "scikit_image",
                "h5py",
                "scikit_learn",
                "dask",
                "joblib",
                "cython",
            )
        },
        "linked_hdf5": "impossible",
        "platform": "impossible",
        "kernel": "impossible",
        "machine": "impossible",
        "thread_environment": {"OMP_NUM_THREADS": "impossible"},
        "ffmpeg_first_line": "impossible",
        "os_id": "impossible",
        "os_version_id": "impossible",
        "blas_lapack_text_sha256": "0" * 64,
    }
    repositories = {
        name: {"commit": "f" * 40}
        for name in (
            "moseq2-extract",
            "moseq2-viz",
            "moseq2-app",
            "moseq2-pca",
            "moseq2-model",
        )
    }
    dependencies = {
        name: {"commit": "e" * 40}
        for name in ("pyhsmm", "pybasicbayes", "autoregressive")
    }
    lock = {
        "contract_id": "moseq2-legacy-study-2026-07-29-v1",
        "status": "COMPLETE",
        "expected_environment": expected_environment,
        "conda_packages": [],
        "repositories": repositories,
        "git_dependencies": dependencies,
        "classifier": {"sha256": "d" * 64, "bytes": 1},
        "sitecustomize": {
            "status": "VERIFIED_ABSENT",
            "sha256": "ABSENT",
            "bytes": 0,
        },
    }
    with tempfile.TemporaryDirectory() as directory:
        lock_path = os.path.join(directory, "deployment-lock.json")
        output_path = os.path.join(directory, "fingerprint.json")
        with open(lock_path, "w", encoding="utf-8") as stream:
            json.dump(lock, stream)
        result = subprocess.run(
            [
                sys.executable,
                os.path.join(ROOT, "preflight_environment.py"),
                "--lock",
                lock_path,
                "--output",
                output_path,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )
        require(result.returncode != 0, "preflight accepted a mismatched lock")
        with open(output_path, "r", encoding="utf-8") as stream:
            report = json.load(stream)
        require(report["status"] != "VERIFIED", "mismatch became VERIFIED")
        require(
            any(item["status"] == "MISMATCH" for item in report["checks"]),
            "mismatch was downgraded to unresolved/warning",
        )


def main():
    for name in REQUIRED:
        require(os.path.isfile(os.path.join(ROOT, name)), "missing: " + name)

    contract = text("DEPLOYMENT_CONTRACT.md")
    for phrase in (
        "golden reference",
        "Approximate versions",
        "analysis unless",
        "`UNRESOLVED`",
        "`MISMATCH`",
        "`QUALIFIED`",
    ):
        require(phrase in contract, "contract phrase missing: " + phrase)

    export = text("export_offline_environment_bundle.sh")
    require("activate_legacy_environment" in export, "export lacks legacy guard")
    require("artifact-allowlist" in export, "export lacks legal artifact gate")
    require("bundle create" in export, "export lacks exact Git bundles")

    bootstrap = text("bootstrap_qualified_machine.sh")
    for phrase in ("--offline", "--no-index", "checkout --detach", "COMPLETE"):
        require(phrase in bootstrap, "bootstrap control missing: " + phrase)
    require("git checkout main" not in bootstrap, "floating main checkout found")
    require("git checkout master" not in bootstrap, "floating master checkout found")

    guarded = text("run_pipeline_guarded.sh")
    for phrase in (
        "environment-fingerprint.json",
        "QUALIFIED",
        "expected_known_answer_sha256",
        "MOSEQ_ANALYSIS_OUTPUT",
    ):
        require(phrase in guarded, "guarded entry control missing: " + phrase)

    import_script = text("import_golden_wsl.ps1").lower()
    require("--import" in import_script, "WSL import command missing")
    require("--unregister" not in import_script, "WSL unregister command found")
    require("remove-item" not in import_script, "destructive PowerShell found")

    mismatch_preflight_test()
    print("deployment_static_checks=PASS")
    print("future_bootstrap_executed=false")
    print("golden_export_executed=false")


if __name__ == "__main__":
    main()
