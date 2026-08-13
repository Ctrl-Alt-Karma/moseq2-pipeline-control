#!/usr/bin/env python
"""Bounded synthetic smoke through real MoSeq production interfaces."""

from __future__ import print_function

import argparse
import hashlib
import json
import os
from pathlib import Path

import h5py
import joblib
import numpy as np

from moseq2_app.flip.widget import FlipClassifierWidget, read_flip_record
from moseq2_extract.extract.proc import compute_scalars
from moseq2_extract.util import write_pipeline_provenance
from moseq2_model.util import load_pcs
from moseq2_pca.pca.util import apply_pca_local
from moseq2_viz.util import (
    SCALAR_POOLING_POLICIES,
    enforce_consistent_provenance,
    read_pipeline_provenance,
)


class DeterministicSyntheticClassifier(object):
    """Minimal joblib classifier used only for bounded synthetic frames."""

    classes_ = np.asarray([0, 1])

    def predict_proba(self, values):
        flipped = (values.sum(axis=1) % 2).astype(float)
        return np.column_stack((1.0 - flipped, flipped))


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def array_summary(value):
    data = np.asarray(value)
    finite = data[np.isfinite(data)]
    return {
        "shape": list(data.shape),
        "dtype": str(data.dtype),
        "finite": int(finite.size),
        "min": float(finite.min()) if finite.size else None,
        "max": float(finite.max()) if finite.size else None,
        "mean": float(finite.mean()) if finite.size else None,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()
    output = os.path.abspath(args.output_dir)
    if not os.path.isdir(output):
        raise SystemExit("output directory does not exist: {}".format(output))

    stages = os.path.join(output, "stages")
    os.makedirs(stages)
    extraction_h5 = os.path.join(stages, "synthetic_extraction.h5")
    classifier_path = os.path.join(stages, "synthetic_classifier.joblib")
    session_yaml = os.path.join(stages, "synthetic_extraction.yaml")

    nframes = 12
    rows = 8
    columns = 8
    frames = np.zeros((nframes, rows, columns), dtype=np.uint16)
    for index in range(nframes):
        frames[index, 2:6, 2:6] = 20 + index
        if index % 2:
            frames[index, 2, 2] += 1

    track_features = {
        "centroid": np.column_stack(
            (
                np.linspace(3.0, 4.0, nframes),
                np.linspace(3.5, 4.5, nframes),
            )
        ),
        "axis_length": np.column_stack(
            (np.full(nframes, 3.0), np.full(nframes, 5.0))
        ),
        "orientation": np.linspace(0.0, 0.5, nframes),
    }
    scalars = compute_scalars(
        frames, track_features, min_height=10, max_height=100, true_depth=673.1
    )

    with h5py.File(extraction_h5, "w") as h5_file:
        h5_file.create_dataset("frames", data=frames, compression="gzip")
        h5_file.create_dataset(
            "timestamps",
            data=np.arange(nframes, dtype=float) * (1000.0 / 30.0),
        )
        acquisition = h5_file.require_group("metadata/acquisition")
        acquisition.create_dataset("SessionName", data="synthetic-session")
        acquisition.create_dataset("SubjectName", data="synthetic-subject")
        acquisition.create_dataset("StartTime", data="1970-01-01T00:00:00")
        scalar_group = h5_file.require_group("scalars")
        for name, values in scalars.items():
            scalar_group.create_dataset(name, data=values)
        # The real extract writer creates the provenance record.
        write_pipeline_provenance(h5_file)

    provenance_before = read_pipeline_provenance(extraction_h5)
    if provenance_before.get("package") != "moseq2-extract":
        raise AssertionError("viz did not read the real extract provenance")

    joblib.dump(DeterministicSyntheticClassifier(), classifier_path)
    widget = FlipClassifierWidget.__new__(FlipClassifierWidget)
    widget.sessions = {"synthetic-session": Path(extraction_h5)}
    widget.apply_flip_classifier(
        classifier_path,
        chunk_size=5,
        chunk_overlap=1,
        smoothing=0,
        frame_path="frames",
        write_movie=False,
        verbose=False,
    )

    with h5py.File(extraction_h5, "r") as h5_file:
        flip_record = read_flip_record(h5_file)
        if flip_record.get("state") != "complete":
            raise AssertionError("real app flip path did not complete")
        scalar_summary = {
            name: array_summary(values[()])
            for name, values in h5_file["scalars"].items()
        }
        frame_summary = array_summary(h5_file["frames"][()])

    if not enforce_consistent_provenance(
        [extraction_h5],
        required_policies=SCALAR_POOLING_POLICIES,
        context="bounded synthetic home-pilot smoke",
    ):
        raise AssertionError("viz provenance gate did not accept one valid record")

    with open(session_yaml, "w") as stream:
        stream.write("uuid: synthetic-session\n")

    components = np.eye(rows * columns, dtype=np.float32)[:3]
    score_base = os.path.join(stages, "synthetic_pca_scores")
    clean_params = {
        "medfilter_space": None,
        "gaussfilter_space": None,
        "medfilter_time": None,
        "gaussfilter_time": None,
        "detrend_time": None,
        "tailfilter": None,
        "tail_threshold": 5,
    }
    apply_pca_local(
        components,
        [extraction_h5],
        [session_yaml],
        False,
        clean_params,
        score_base,
        100,
        {
            "mask_threshold": -16,
            "mask_height_threshold": 5,
            "min_height": 10,
            "max_height": 100,
        },
        False,
        fps=30,
    )
    score_h5 = score_base + ".h5"

    score_provenance = read_pipeline_provenance(
        score_h5, h5_path="metadata/pipeline"
    )
    if score_provenance.get("package") != "moseq2-pca":
        raise AssertionError("PCA production writer did not stamp its output")

    model_inputs, model_metadata = load_pcs(
        score_h5, var_name="scores", load_groups=False, npcs=3
    )
    if list(model_inputs) != ["synthetic-session"]:
        raise AssertionError("model loader did not preserve the synthetic session key")
    model_input_summary = {
        key: array_summary(value) for key, value in model_inputs.items()
    }

    with open(os.path.join(output, "extract_provenance.json"), "w") as stream:
        json.dump(provenance_before, stream, indent=2, sort_keys=True)
        stream.write("\n")
    with open(os.path.join(output, "flip_record.json"), "w") as stream:
        json.dump(flip_record, stream, indent=2, sort_keys=True)
        stream.write("\n")
    with open(os.path.join(output, "scalar_summary.json"), "w") as stream:
        json.dump(scalar_summary, stream, indent=2, sort_keys=True)
        stream.write("\n")
    with open(os.path.join(output, "pca_provenance.json"), "w") as stream:
        json.dump(score_provenance, stream, indent=2, sort_keys=True)
        stream.write("\n")
    with open(os.path.join(output, "model_input_summary.json"), "w") as stream:
        json.dump(
            {
                "inputs": model_input_summary,
                "metadata": model_metadata,
                "model_fit_started": False,
            },
            stream,
            indent=2,
            sort_keys=True,
        )
        stream.write("\n")
    with open(os.path.join(output, "stage_files.tsv"), "w") as stream:
        stream.write("path\tsha256\tbytes\n")
        for path in (extraction_h5, classifier_path, session_yaml, score_h5):
            stream.write(
                "{}\t{}\t{}\n".format(path, sha256(path), os.path.getsize(path))
            )
    with open(os.path.join(output, "SYNTHETIC_RECEIPT.txt"), "w") as stream:
        stream.write("extract_writer=REAL\n")
        stream.write("viz_reader_and_gate=REAL\n")
        stream.write("app_flip_path=REAL\n")
        stream.write("scalar_production=REAL\n")
        stream.write("pca_application_and_writer=REAL\n")
        stream.write("model_input_loader=REAL\n")
        stream.write("model_fit_started=false\n")
        stream.write("frame_summary={}\n".format(json.dumps(frame_summary)))


if __name__ == "__main__":
    main()
