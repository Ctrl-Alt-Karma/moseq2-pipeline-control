#!/usr/bin/env python3
"""Verify the exact frozen runtime after locked PYTHONPATH activation."""

from __future__ import print_function

import argparse
import datetime
import json
import os
import subprocess
import sys

import importlib_metadata
import numpy


EXPECTED_SOURCES = {
    "moseq2_extract": "2c9cd86571bcc23ad6870e4da344e0f558f3f54c",
    "moseq2_pca": "efb6fcfa5d5af5bb4274540c371d0ddf96440b78",
    "moseq2_model": "6e542e3f1db125202d42b59f390c922281e64f39",
    "moseq2_viz": "b80192dc20353bf77c36610f315543b57afa908c",
    "moseq2_app": "e0b85201226d03e15944473a734f71417698c31e",
}
EXPECTED_EXTERNAL = {
    "pyhsmm": ("0.1.6", "4e739166746f92bfc968d281f2c1d31e3471409f"),
    "pybasicbayes": ("0.2.4", "61f65ad6c781288605ec5f7347efcc5dbd73c4fc"),
    "autoregressive": ("0.1.2", "2a4c73c08dcda959b9bac2f03a2b976dabbc37af"),
}


def utc_now():
    return datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def command(*args):
    return subprocess.check_output(list(args), universal_newlines=True).strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--receipt", required=True)
    args = parser.parse_args()
    receipt = {
        "schema": "moseq-r1-runtime-identity-v1",
        "checked_utc": utc_now(),
        "status": "FAILED_HOLD",
        "python": ".".join(str(value) for value in sys.version_info[:3]),
        "numpy": numpy.__version__,
        "dask": importlib_metadata.version("dask"),
        "moseq_sources": {},
        "external_dependencies": {},
    }
    checks = [receipt["python"] == "3.7.12", receipt["numpy"] == "1.18.3", receipt["dask"] == "2.30.0"]
    try:
        for module_name, expected in sorted(EXPECTED_SOURCES.items()):
            module = __import__(module_name)
            module_file = os.path.realpath(module.__file__)
            repo = command("git", "-C", os.path.dirname(module_file), "rev-parse", "--show-toplevel")
            observed = command("git", "-C", repo, "rev-parse", "HEAD")
            dirty = command("git", "-C", repo, "status", "--porcelain")
            record = {"module_file": module_file, "worktree": repo, "expected_commit": expected, "observed_commit": observed, "clean": dirty == ""}
            record["pass"] = observed == expected and dirty == ""
            receipt["moseq_sources"][module_name] = record
            checks.append(record["pass"])
        for name, (expected_version, expected_commit) in sorted(EXPECTED_EXTERNAL.items()):
            distribution = importlib_metadata.distribution(name)
            direct = json.loads(distribution.read_text("direct_url.json"))
            observed_commit = (direct.get("vcs_info") or {}).get("commit_id")
            record = {
                "expected_version": expected_version,
                "observed_version": distribution.version,
                "expected_commit": expected_commit,
                "observed_commit": observed_commit,
            }
            record["pass"] = distribution.version == expected_version and observed_commit == expected_commit
            receipt["external_dependencies"][name] = record
            checks.append(record["pass"])
        if all(checks):
            receipt["status"] = "PASS"
    except Exception as error:
        receipt["error"] = "{}: {}".format(type(error).__name__, error)
    with open(args.receipt, "w", newline="\n") as stream:
        json.dump(receipt, stream, indent=2, sort_keys=True)
        stream.write("\n")
    if receipt["status"] != "PASS":
        print("frozen runtime identity FAILED/HOLD", file=sys.stderr)
        return 42
    print("frozen_runtime_identity=PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
