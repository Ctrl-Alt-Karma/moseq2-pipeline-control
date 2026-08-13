#!/usr/bin/env python
"""Canonicalize and compare the versioned synthetic production-path result."""

from __future__ import print_function

import argparse
import hashlib
import json
import os
import sys

import h5py
import numpy as np


FIXTURE_CONTRACT = "moseq-known-answer-v1"
REQUIRED_RECEIPTS = {
    "extract_writer": "REAL",
    "viz_reader_and_gate": "REAL",
    "app_flip_path": "REAL",
    "scalar_production": "REAL",
    "pca_application_and_writer": "REAL",
    "model_input_loader": "REAL",
    "model_fit_started": "false",
}


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def canonical_array(value):
    array = np.asarray(value)
    contiguous = np.ascontiguousarray(array)
    digest = hashlib.sha256(contiguous.tobytes(order="C")).hexdigest()
    return {
        "shape": list(array.shape),
        "dtype": str(array.dtype),
        "sha256": digest,
    }


def selected_datasets(path, prefixes):
    result = {}
    with h5py.File(path, "r") as h5_file:
        def visit(name, value):
            if not isinstance(value, h5py.Dataset):
                return
            if any(name == prefix or name.startswith(prefix + "/") for prefix in prefixes):
                result[name] = canonical_array(value[()])
        h5_file.visititems(visit)
    return result


def read_json(path):
    with open(path, "r") as stream:
        return json.load(stream)


def read_receipt(path):
    result = {}
    with open(path, "r") as stream:
        for line in stream:
            if "=" in line:
                key, value = line.rstrip("\n").split("=", 1)
                result[key] = value
    return result


def stable_flip_record(record):
    excluded_fragments = (
        "time",
        "date",
        "path",
        "started",
        "finished",
        "updated",
        "created",
        "written",
    )
    result = {}
    for key, value in sorted(record.items()):
        lowered = key.lower()
        if any(fragment in lowered for fragment in excluded_fragments):
            continue
        if isinstance(value, (str, int, float, bool)) or value is None:
            result[key] = value
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=("establish", "verify"), required=True)
    parser.add_argument("--smoke-dir", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--expected")
    parser.add_argument("--preflight")
    parser.add_argument("--deployment-lock")
    args = parser.parse_args()

    smoke = os.path.abspath(args.smoke_dir)
    output = os.path.abspath(args.output)
    required = {
        "receipt": os.path.join(smoke, "SYNTHETIC_RECEIPT.txt"),
        "extract_h5": os.path.join(smoke, "stages", "synthetic_extraction.h5"),
        "pca_h5": os.path.join(smoke, "stages", "synthetic_pca_scores.h5"),
        "extract_provenance": os.path.join(smoke, "extract_provenance.json"),
        "pca_provenance": os.path.join(smoke, "pca_provenance.json"),
        "flip_record": os.path.join(smoke, "flip_record.json"),
        "scalar_summary": os.path.join(smoke, "scalar_summary.json"),
        "model_summary": os.path.join(smoke, "model_input_summary.json"),
    }
    absent = [name for name, path in required.items() if not os.path.isfile(path)]
    if absent:
        raise SystemExit("known-answer outputs missing: {}".format(", ".join(absent)))

    receipt = read_receipt(required["receipt"])
    for key, expected in REQUIRED_RECEIPTS.items():
        if receipt.get(key) != expected:
            raise SystemExit(
                "production-path receipt mismatch for {}: {!r}".format(
                    key, receipt.get(key)
                )
            )

    extract_provenance = read_json(required["extract_provenance"])
    pca_provenance = read_json(required["pca_provenance"])
    flip_record = read_json(required["flip_record"])
    scalar_summary = read_json(required["scalar_summary"])
    model_summary = read_json(required["model_summary"])

    inputs = model_summary.get("inputs", {})
    results = {
        "fixture_contract": FIXTURE_CONTRACT,
        "production_paths": REQUIRED_RECEIPTS,
        "extraction_datasets": selected_datasets(
            required["extract_h5"], ("frames", "timestamps", "scalars")
        ),
        "pca_datasets": selected_datasets(required["pca_h5"], ("scores",)),
        "extract_provenance": {
            "package": extract_provenance.get("package"),
            "package_version": extract_provenance.get("package_version"),
            "output_policies": extract_provenance.get("output_policies"),
        },
        "pca_provenance": {
            "package": pca_provenance.get("package"),
            "package_version": pca_provenance.get("package_version"),
            "output_policies": pca_provenance.get("output_policies"),
        },
        "flip_record": stable_flip_record(flip_record),
        "scalar_names": sorted(scalar_summary),
        "scalar_units_policy": {
            key: extract_provenance.get("output_policies", {}).get(key)
            for key in (
                "scalar_px_to_mm",
                "area_units",
                "velocity_3d_px",
                "flip_correction",
            )
        },
        "model_input_sessions": sorted(inputs),
        "model_input_shapes": {
            name: record.get("shape") for name, record in sorted(inputs.items())
        },
        "model_fit_started": model_summary.get("model_fit_started"),
    }
    if results["model_input_sessions"] != ["synthetic-session"]:
        raise SystemExit("synthetic session alignment failed")
    if results["model_fit_started"] is not False:
        raise SystemExit("known-answer test unexpectedly started a model fit")

    preflight_record = None
    if args.preflight:
        preflight_record = read_json(args.preflight)
        if preflight_record.get("status") != "VERIFIED":
            raise SystemExit("known-answer verification requires VERIFIED preflight")

    lock_sha = (
        sha256_file(args.deployment_lock)
        if args.deployment_lock and os.path.isfile(args.deployment_lock)
        else "UNRESOLVED"
    )
    if args.mode == "establish":
        record = {
            "schema_version": 1,
            "status": "GOLDEN_ESTABLISHED",
            "fixture_contract": FIXTURE_CONTRACT,
            "results": results,
            "deployment_lock_sha256": lock_sha,
        }
        exit_code = 0
    else:
        if not args.expected or not os.path.isfile(args.expected):
            raise SystemExit("--expected golden-known-answer.json is required")
        expected_record = read_json(args.expected)
        if expected_record.get("status") != "GOLDEN_ESTABLISHED":
            raise SystemExit("expected known-answer record is not golden")
        expected_results = expected_record.get("results")
        matched = expected_results == results
        record = {
            "schema_version": 1,
            "status": "VERIFIED" if matched else "MISMATCH",
            "fixture_contract": FIXTURE_CONTRACT,
            "results": results,
            "expected_sha256": sha256_file(args.expected),
            "preflight_sha256": sha256_file(args.preflight),
            "fingerprint_sha256": preflight_record.get("fingerprint_sha256"),
            "deployment_lock_sha256": lock_sha,
        }
        exit_code = 0 if matched else 2

    with open(output, "w") as stream:
        json.dump(record, stream, indent=2, sort_keys=True)
        stream.write("\n")
    print("{} {}".format(record["status"], output))
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
