#!/usr/bin/env python
"""Extract bounded provenance/scalar/flip/model-handoff evidence from a pilot."""

from __future__ import print_function

import argparse
import hashlib
import json
import os

import h5py
import numpy as np

from moseq2_model.util import load_pcs
from moseq2_viz.util import read_pipeline_provenance


def sha256_bytes(value):
    return hashlib.sha256(np.asarray(value).tobytes()).hexdigest()


def summary(value):
    array = np.asarray(value)
    finite = array[np.isfinite(array)] if np.issubdtype(array.dtype, np.number) else []
    return {
        "shape": list(array.shape),
        "dtype": str(array.dtype),
        "dataset_sha256": sha256_bytes(array),
        "min": float(finite.min()) if len(finite) else None,
        "max": float(finite.max()) if len(finite) else None,
        "mean": float(finite.mean()) if len(finite) else None,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--extraction-h5", required=True)
    parser.add_argument("--pca-scores", required=True)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()
    output = os.path.abspath(args.output_dir)

    extraction = {
        "path": os.path.abspath(args.extraction_h5),
        "provenance": read_pipeline_provenance(args.extraction_h5),
        "datasets": {},
        "flip_records": {},
    }
    with h5py.File(args.extraction_h5, "r") as h5_file:
        for path in (
            "frames",
            "frames_mask",
            "metadata/extraction/flips",
            "scalars/angle",
        ):
            if path in h5_file:
                extraction["datasets"][path] = summary(h5_file[path][()])
        if "scalars" in h5_file:
            extraction["scalar_summaries"] = {
                key: summary(value[()]) for key, value in h5_file["scalars"].items()
            }
        for path in (
            "metadata/processing/flip_classifier",
            "metadata/processing/flip_classifier_journal",
        ):
            if path in h5_file:
                raw = h5_file[path][()]
                if isinstance(raw, bytes):
                    raw = raw.decode("utf-8", "replace")
                extraction["flip_records"][path] = raw
        extraction["legacy_flip_classifier_applied"] = bool(
            h5_file.attrs.get("flip_classifier_applied", False)
        )

    pca = {
        "path": os.path.abspath(args.pca_scores),
        "provenance": read_pipeline_provenance(
            args.pca_scores, h5_path="metadata/pipeline"
        ),
    }
    model_inputs, model_metadata = load_pcs(
        args.pca_scores, var_name="scores", load_groups=False, npcs=10
    )
    pca["score_summaries"] = {
        key: summary(value) for key, value in model_inputs.items()
    }
    model_handoff = {
        "input_sessions": list(model_inputs),
        "metadata": model_metadata,
        "input_summaries": pca["score_summaries"],
        "model_fit_started": False,
    }

    for name, value in (
        ("extraction_summary.json", extraction),
        ("pca_summary.json", pca),
        ("model_input_handoff.json", model_handoff),
    ):
        with open(os.path.join(output, name), "w") as stream:
            json.dump(value, stream, indent=2, sort_keys=True)
            stream.write("\n")


if __name__ == "__main__":
    main()
