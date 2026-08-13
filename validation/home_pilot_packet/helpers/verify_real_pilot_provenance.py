#!/usr/bin/env python3
"""Fail-closed provenance gate for an approved real-session pilot.

This helper performs only path and SHA-256 checks. It never opens scientific
formats, alters inputs, or starts extraction, PCA, or model work.
"""

from __future__ import print_function

import argparse
import datetime
import hashlib
import json
import os
import re
import sys


SCHEMA = "moseq2-real-session-run-spec-v1"
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        while True:
            block = stream.read(1024 * 1024)
            if not block:
                break
            digest.update(block)
    return digest.hexdigest()


def canonical_path(path):
    return os.path.realpath(os.path.abspath(path))


def utc_now():
    return datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def require_mapping(value, name):
    if not isinstance(value, dict):
        raise ValueError("{} must be an object".format(name))
    return value


def require_text(mapping, key, context):
    value = mapping.get(key)
    if not isinstance(value, str) or not value:
        raise ValueError("{}.{} must be a nonempty string".format(context, key))
    return value


def require_sha256(mapping, key, context):
    value = require_text(mapping, key, context).lower()
    if SHA256_RE.match(value) is None:
        raise ValueError("{}.{} must be a lowercase SHA-256".format(context, key))
    return value


def inspect_artifact(spec_record, supplied_path, context, required_sha256=None):
    expected_path = canonical_path(require_text(spec_record, "path", context))
    expected_sha256 = require_sha256(spec_record, "sha256", context)
    observed_path = canonical_path(supplied_path)
    observed_sha256 = sha256_file(observed_path)
    checks = {
        "path_matches_run_spec": observed_path == expected_path,
        "sha256_matches_run_spec": observed_sha256 == expected_sha256,
    }
    if required_sha256 is not None:
        checks["run_spec_matches_required_identity"] = expected_sha256 == required_sha256
    return {
        "expected_path": expected_path,
        "observed_path": observed_path,
        "expected_sha256": expected_sha256,
        "observed_sha256": observed_sha256,
        "bytes": os.path.getsize(observed_path),
        "checks": checks,
    }


def write_receipt(path, receipt):
    parent = os.path.dirname(os.path.abspath(path))
    if parent and not os.path.isdir(parent):
        os.makedirs(parent)
    temporary = path + ".tmp"
    with open(temporary, "w") as stream:
        json.dump(receipt, stream, indent=2, sort_keys=True)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-spec", required=True)
    parser.add_argument("--recording", required=True)
    parser.add_argument("--pca-components", required=True)
    parser.add_argument("--production-model", required=True)
    parser.add_argument("--required-pca-sha256", required=True)
    parser.add_argument("--required-model-sha256", required=True)
    parser.add_argument("--required-model-seed", required=True, type=int)
    parser.add_argument("--required-model-kappa", required=True, type=int)
    parser.add_argument("--receipt", required=True)
    return parser.parse_args()


def main():
    args = parse_args()
    receipt = {
        "schema": "moseq2-real-pilot-provenance-preflight-v1",
        "checked_utc": utc_now(),
        "scientific_processing_started": False,
        "source_inputs_mutated": False,
        "status": "FAILED_HOLD",
    }
    try:
        for name, value in (
            ("required_pca_sha256", args.required_pca_sha256),
            ("required_model_sha256", args.required_model_sha256),
        ):
            if SHA256_RE.match(value) is None:
                raise ValueError("{} must be a lowercase SHA-256".format(name))

        with open(args.run_spec, "r") as stream:
            spec = json.load(stream)
        require_mapping(spec, "run spec")
        if spec.get("schema") != SCHEMA:
            raise ValueError("run spec schema must be {}".format(SCHEMA))

        recording_spec = require_mapping(spec.get("recording"), "recording")
        pca_spec = require_mapping(spec.get("pca_components"), "pca_components")
        model_spec = require_mapping(spec.get("production_model"), "production_model")

        receipt["run_spec"] = {
            "path": canonical_path(args.run_spec),
            "sha256": sha256_file(args.run_spec),
            "session_id": require_text(spec, "session_id", "run spec"),
        }
        receipt["recording"] = inspect_artifact(recording_spec, args.recording, "recording")
        receipt["pca_components"] = inspect_artifact(
            pca_spec,
            args.pca_components,
            "pca_components",
            required_sha256=args.required_pca_sha256,
        )
        receipt["production_model"] = inspect_artifact(
            model_spec,
            args.production_model,
            "production_model",
            required_sha256=args.required_model_sha256,
        )
        receipt["production_model"]["expected_seed"] = args.required_model_seed
        receipt["production_model"]["run_spec_seed"] = model_spec.get("seed")
        receipt["production_model"]["expected_kappa"] = args.required_model_kappa
        receipt["production_model"]["run_spec_kappa"] = model_spec.get("kappa")
        receipt["production_model"]["checks"]["seed_matches_required"] = (
            model_spec.get("seed") == args.required_model_seed
        )
        receipt["production_model"]["checks"]["kappa_matches_required"] = (
            model_spec.get("kappa") == args.required_model_kappa
        )

        all_checks = []
        for name in ("recording", "pca_components", "production_model"):
            all_checks.extend(receipt[name]["checks"].values())
        if not all(all_checks):
            raise ValueError("one or more run-spec provenance checks failed")
        receipt["status"] = "PASS"
    except Exception as error:
        receipt["error"] = "{}: {}".format(type(error).__name__, error)

    write_receipt(args.receipt, receipt)
    if receipt["status"] != "PASS":
        print("provenance preflight FAILED/HOLD; see {}".format(args.receipt), file=sys.stderr)
        return 42
    print("provenance_preflight=PASS")
    print("receipt={}".format(args.receipt))
    return 0


if __name__ == "__main__":
    sys.exit(main())
