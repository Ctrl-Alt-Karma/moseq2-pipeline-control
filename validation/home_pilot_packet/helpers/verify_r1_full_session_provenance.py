#!/usr/bin/env python3
"""Fail-closed provenance gate for sealed R1 full-session validation."""

from __future__ import print_function

import argparse
import datetime
import hashlib
import json
import os
import re
import stat
import sys

import h5py
import numpy


SCHEMA = "moseq2-r1-real-session-run-spec-v2"
PCA_COMPONENTS_PATH = "components"
PCA_COMPONENTS_SHAPE = (25, 6400)
PCA_COMPONENTS_DTYPE = "float32"
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def pca_component_role(path):
    """Semantic role gate for the runtime PCA artifact.

    The runtime PCA input must be the component basis, not the training-score
    artifact. A score file hashes correctly but has no /components dataset, so a
    hash-only gate cannot tell the two apart. Fails closed before candidate
    science; never raises.
    """
    observed = {"readable_hdf5": False, "has_components": False,
                "shape": None, "dtype": None}
    try:
        with h5py.File(path, "r") as handle:
            observed["readable_hdf5"] = True
            if PCA_COMPONENTS_PATH in handle:
                dataset = handle[PCA_COMPONENTS_PATH]
                observed["has_components"] = True
                observed["shape"] = list(dataset.shape)
                observed["dtype"] = str(dataset.dtype)
    except Exception as error:
        observed["error"] = "{}: {}".format(type(error).__name__, error)
    checks = {
        "pca_runtime_artifact_readable_hdf5": observed["readable_hdf5"],
        "pca_runtime_artifact_has_components": observed["has_components"],
        "pca_components_shape_matches_frozen":
            observed["shape"] == list(PCA_COMPONENTS_SHAPE),
        "pca_components_dtype_matches_frozen":
            observed["dtype"] == PCA_COMPONENTS_DTYPE,
    }
    return observed, checks


def canonical(path):
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


def require_int(mapping, key, context):
    value = mapping.get(key)
    if not isinstance(value, int):
        raise ValueError("{}.{} must be an integer".format(context, key))
    return value


def require_sha(mapping, key, context):
    value = require_text(mapping, key, context).lower()
    if SHA256_RE.match(value) is None:
        raise ValueError("{}.{} must be a lowercase SHA-256".format(context, key))
    return value


def line_count(path):
    count = 0
    with open(path, "rb") as stream:
        for _line in stream:
            count += 1
    return count


def is_nonwritable(path):
    return stat.S_IMODE(os.stat(path).st_mode) & 0o222 == 0


def inspect_file(spec, supplied, context, required_sha=None, required_name=None, require_nonwritable=False):
    expected_path = canonical(require_text(spec, "path", context))
    observed_path = canonical(supplied)
    expected_sha = require_sha(spec, "sha256", context)
    expected_bytes = require_int(spec, "bytes", context)
    if not os.path.isfile(observed_path):
        raise ValueError("{} is not a regular file".format(context))
    if os.path.islink(os.path.abspath(supplied)):
        raise ValueError("{} may not be a symbolic link".format(context))
    if required_name is not None and os.path.basename(observed_path) != required_name:
        raise ValueError("{} must be named {}".format(context, required_name))
    observed_sha = sha256_file(observed_path)
    observed_bytes = os.path.getsize(observed_path)
    checks = {
        "path_matches_run_spec": observed_path == expected_path,
        "sha256_matches_run_spec": observed_sha == expected_sha,
        "bytes_match_run_spec": observed_bytes == expected_bytes,
    }
    if required_sha is not None:
        checks["run_spec_matches_frozen_identity"] = expected_sha == required_sha
    if require_nonwritable:
        checks["mode_has_no_write_bits"] = is_nonwritable(observed_path)
    return {
        "expected_path": expected_path,
        "observed_path": observed_path,
        "expected_sha256": expected_sha,
        "observed_sha256": observed_sha,
        "expected_bytes": expected_bytes,
        "observed_bytes": observed_bytes,
        "checks": checks,
    }


def write_receipt(path, receipt):
    parent = os.path.dirname(os.path.abspath(path))
    if parent and not os.path.isdir(parent):
        os.makedirs(parent)
    temporary = path + ".tmp"
    with open(temporary, "w", newline="\n") as stream:
        json.dump(receipt, stream, indent=2, sort_keys=True)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-spec", required=True)
    parser.add_argument("--staged-root", required=True)
    parser.add_argument("--depth", required=True)
    parser.add_argument("--metadata", required=True)
    parser.add_argument("--timestamps", required=True)
    parser.add_argument("--config", required=True)
    parser.add_argument("--classifier", required=True)
    parser.add_argument("--pca", required=True)
    parser.add_argument("--model", required=True)
    parser.add_argument("--required-config-sha256", required=True)
    parser.add_argument("--required-classifier-sha256", required=True)
    parser.add_argument("--required-pca-sha256", required=True)
    parser.add_argument("--required-model-sha256", required=True)
    parser.add_argument("--required-model-seed", required=True, type=int)
    parser.add_argument("--required-model-kappa", required=True, type=int)
    parser.add_argument("--receipt", required=True)
    return parser.parse_args()


def main():
    args = parse_args()
    receipt = {
        "schema": "moseq-r1-full-session-provenance-preflight-v2",
        "checked_utc": utc_now(),
        "status": "FAILED_HOLD",
        "scientific_processing_started": False,
        "source_inputs_mutated": False,
    }
    try:
        for name, value in (
            ("required_config_sha256", args.required_config_sha256),
            ("required_classifier_sha256", args.required_classifier_sha256),
            ("required_pca_sha256", args.required_pca_sha256),
            ("required_model_sha256", args.required_model_sha256),
        ):
            if SHA256_RE.match(value) is None:
                raise ValueError("{} must be a lowercase SHA-256".format(name))

        staged_root = canonical(args.staged_root)
        depth_real = canonical(args.depth)
        if not depth_real.startswith(staged_root + os.sep):
            raise ValueError("depth.dat resolves outside the approved staged root")

        with open(args.run_spec, "r") as stream:
            spec = json.load(stream)
        require_mapping(spec, "run spec")
        if spec.get("schema") != SCHEMA:
            raise ValueError("run spec schema must be {}".format(SCHEMA))

        candidate = require_text(spec, "candidate_identity_id", "run spec")
        session_dir = os.path.dirname(depth_real)
        if os.path.basename(session_dir) != candidate:
            raise ValueError("staged session directory must equal candidate_identity_id")

        raw = require_mapping(spec.get("raw_inputs"), "raw_inputs")
        scientific = require_mapping(spec.get("scientific_artifacts"), "scientific_artifacts")
        identity = require_mapping(spec.get("identity"), "identity")
        receipts = require_mapping(spec.get("environment_receipts"), "environment_receipts")

        receipt["candidate_identity_id"] = candidate
        receipt["identity"] = identity
        receipt["raw_inputs"] = {
            "depth": inspect_file(require_mapping(raw.get("depth"), "raw_inputs.depth"), args.depth, "raw_inputs.depth", required_name="depth.dat", require_nonwritable=True),
            "metadata": inspect_file(require_mapping(raw.get("metadata"), "raw_inputs.metadata"), args.metadata, "raw_inputs.metadata", required_name="metadata.json", require_nonwritable=True),
            "timestamps": inspect_file(require_mapping(raw.get("timestamps"), "raw_inputs.timestamps"), args.timestamps, "raw_inputs.timestamps", required_name="depth_ts.txt", require_nonwritable=True),
        }
        raw_parents = {os.path.dirname(item["observed_path"]) for item in receipt["raw_inputs"].values()}
        if raw_parents != {session_dir}:
            raise ValueError("all raw inputs must share the candidate staging directory")
        expected_rows = require_int(require_mapping(raw.get("timestamps"), "raw_inputs.timestamps"), "rows", "raw_inputs.timestamps")
        observed_rows = line_count(args.timestamps)
        receipt["raw_inputs"]["timestamps"]["expected_rows"] = expected_rows
        receipt["raw_inputs"]["timestamps"]["observed_rows"] = observed_rows
        receipt["raw_inputs"]["timestamps"]["checks"]["rows_match_run_spec"] = observed_rows == expected_rows

        with open(args.metadata, "r") as stream:
            metadata = json.load(stream)
        subject = require_text(identity, "subject_name", "identity")
        start = require_text(identity, "acquisition_start", "identity")
        session_name = require_text(identity, "session_name", "identity")
        rig = require_int(identity, "rig", "identity")
        parts = subject.split("_")
        metadata_checks = {
            "subject_name_matches": metadata.get("SubjectName") == subject,
            "start_time_matches": metadata.get("StartTime") == start,
            "session_name_matches": metadata.get("SessionName") == session_name,
            "rig_token_matches": len(parts) > 2 and parts[2] == str(rig),
        }
        receipt["metadata_identity"] = {
            "recorded": {"SubjectName": metadata.get("SubjectName"), "StartTime": metadata.get("StartTime"), "SessionName": metadata.get("SessionName")},
            "checks": metadata_checks,
        }

        receipt["scientific_artifacts"] = {
            "config": inspect_file(require_mapping(scientific.get("config"), "scientific_artifacts.config"), args.config, "scientific_artifacts.config", required_sha=args.required_config_sha256),
            "classifier": inspect_file(require_mapping(scientific.get("classifier"), "scientific_artifacts.classifier"), args.classifier, "scientific_artifacts.classifier", required_sha=args.required_classifier_sha256),
            "pca": inspect_file(require_mapping(scientific.get("pca"), "scientific_artifacts.pca"), args.pca, "scientific_artifacts.pca", required_sha=args.required_pca_sha256),
            "production_model": inspect_file(require_mapping(scientific.get("production_model"), "scientific_artifacts.production_model"), args.model, "scientific_artifacts.production_model", required_sha=args.required_model_sha256),
        }
        pca_observed, pca_role_checks = pca_component_role(args.pca)
        receipt["scientific_artifacts"]["pca"]["component_role"] = {
            "expected_dataset": PCA_COMPONENTS_PATH,
            "expected_shape": list(PCA_COMPONENTS_SHAPE),
            "expected_dtype": PCA_COMPONENTS_DTYPE,
            "observed": pca_observed,
        }
        receipt["scientific_artifacts"]["pca"]["checks"].update(pca_role_checks)

        model_spec = require_mapping(scientific.get("production_model"), "scientific_artifacts.production_model")
        receipt["scientific_artifacts"]["production_model"]["checks"]["seed_matches_frozen"] = model_spec.get("seed") == args.required_model_seed
        receipt["scientific_artifacts"]["production_model"]["checks"]["kappa_matches_frozen"] = model_spec.get("kappa") == args.required_model_kappa

        receipt["environment_receipts"] = {}
        for key in ("frozen_source_environment", "governed_external_dependencies"):
            receipt["environment_receipts"][key] = inspect_file(require_mapping(receipts.get(key), "environment_receipts.{}".format(key)), require_text(receipts[key], "path", "environment_receipts.{}".format(key)), "environment_receipts.{}".format(key))

        checks = []
        for item in receipt["raw_inputs"].values():
            checks.extend(item["checks"].values())
        checks.extend(metadata_checks.values())
        for item in receipt["scientific_artifacts"].values():
            checks.extend(item["checks"].values())
        for item in receipt["environment_receipts"].values():
            checks.extend(item["checks"].values())
        if not all(checks):
            raise ValueError("one or more R1 provenance checks failed")
        receipt["status"] = "PASS"
    except Exception as error:
        receipt["error"] = "{}: {}".format(type(error).__name__, error)

    write_receipt(args.receipt, receipt)
    if receipt["status"] != "PASS":
        print("R1 full-session provenance preflight FAILED/HOLD", file=sys.stderr)
        return 42
    print("r1_full_session_provenance_preflight=PASS")
    print("receipt={}".format(args.receipt))
    return 0


if __name__ == "__main__":
    sys.exit(main())
