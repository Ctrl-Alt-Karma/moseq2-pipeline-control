#!/usr/bin/env python
"""Synthetic qualification suite for the R1 deterministic replay comparator.

Uses only synthetic fixtures. No candidate recording, extraction, PCA score,
model output or roster identity is read. Emits a hash-bound receipt.
"""

from __future__ import print_function

import hashlib
import json
import os
import pickle
import shutil
import subprocess
import sys
import tempfile

import numpy as np
import h5py

HERE = os.path.dirname(os.path.abspath(__file__))
COMPARATOR = os.path.join(os.path.dirname(HERE), "compare_r1_replay.py")
CONTRACT = os.path.join(os.path.dirname(HERE), "REPLAY_COMPARISON_CONTRACT_R1.json")
PYTHON = sys.executable

UNRELATED_UUID = "99999999-9999-4999-8999-999999999999"


def write_tiff(path, pixels, stamp):
    """Same pixels, different container bytes (description tag varies)."""
    from skimage.external import tifffile
    d = os.path.dirname(path)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    tifffile.imsave(path, pixels, description="written-at-%s" % stamp)


SENTINEL_STR = "SENTINEL_SCIENTIFIC_VALUE_DO_NOT_EMIT"
SENTINEL_NUM = 1234.56789


def w(path, text):
    d = os.path.dirname(path)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    with open(path, "w") as handle:
        handle.write(text)


def wb(path, blob):
    d = os.path.dirname(path)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    with open(path, "wb") as handle:
        handle.write(blob)


def wj(path, obj):
    d = os.path.dirname(path)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    with open(path, "w") as handle:
        json.dump(obj, handle, indent=2, sort_keys=True)
        handle.write("\n")


def angle_array(nan_index):
    arr = np.arange(12, dtype="float32") * 1.5
    arr[nan_index] = np.nan
    return arr


def build_root(root, stamp, nan_index=3, reverse_order=False,
               gen_uuid="11111111-1111-4111-8111-111111111111",
               roi_pixels=None, label_bump=0, unrelated_uuid=UNRELATED_UUID,
               acquisition_stamp="2025-12-11T08:46:51Z",
               extract_commit="2c9cd865", pca_commit="efb6fcfa",
               roi_policy="lstsq-inlier-refit-deterministic-rng0",
               include_model_object=True, model_param=1, param_bump=0):
    """Build a synthetic governed output root matching the operator schema."""
    if roi_pixels is None:
        roi_pixels = np.arange(64, dtype="uint16").reshape(8, 8)
    steps = []

    steps.append(lambda: w(os.path.join(root, "R1_FULL_SESSION_RECEIPT.txt"),
        "status=PASS\ncompleted_utc=%s\nrecording_reference=/staged/raw/SESSION/depth.dat\n"
        "full_session=true\nproduction_model_sha256_before=5e10803a\n"
        "production_model_sha256_after=5e10803a\nmodel_fit_started=false\n" % stamp))

    steps.append(lambda: w(os.path.join(root, "process_environment.txt"),
        "captured_utc=%s\npwd=/tmp/cwd-%s\nPYTHONHASHSEED=0\nOMP_NUM_THREADS=1\n"
        "MKL_NUM_THREADS=1\nDASK_NUM_WORKERS=1\nTZ=UTC\n" % (stamp, stamp)))

    steps.append(lambda: wj(os.path.join(root, "inputs", "R1_FULL_SESSION_RUN_SPEC.json"),
        {"candidate_identity_id": "CID-SYNTHETIC", "raw_inputs": {"depth": {"sha256": "aa" * 32}}}))
    steps.append(lambda: w(os.path.join(root, "inputs", "config.original.yaml"), "crop_size: [80, 80]\n"))
    steps.append(lambda: w(os.path.join(root, "inputs", "config.working.yaml"), "crop_size: [80, 80]\n"))
    steps.append(lambda: wb(os.path.join(root, "inputs", "flip_classifier.pkl"), b"\x01synthetic-classifier"))
    steps.append(lambda: wb(os.path.join(root, "inputs", "pca_components.h5"), b"\x02synthetic-pca-input"))
    steps.append(lambda: wj(os.path.join(root, "inputs", "provenance_preflight.json"),
        {"checked_utc": stamp, "status": "PASS",
         "raw_inputs": {"depth": {"observed_sha256": "bb" * 32, "checks": {"sha256_matches_run_spec": True}}}}))
    steps.append(lambda: wj(os.path.join(root, "inputs", "runtime_identity.json"),
        {"checked_utc": stamp, "status": "PASS", "python": "3.7.12", "numpy": "1.18.3",
         "moseq_sources": {"moseq2_extract": {"observed_commit": "e7f58510", "clean": True}}}))
    steps.append(lambda: wj(os.path.join(root, "inputs", "raw_frame_accounting.json"),
        {"schema": "moseq-r1-raw-frame-accounting-v1", "status": "PASS", "timestamp_rows": 12}))
    steps.append(lambda: wj(os.path.join(root, "inputs", "extraction_frame_accounting.json"),
        {"schema": "moseq-r1-extraction-frame-accounting-v1", "status": "PASS",
         "extracted_frames": 12, "tolerance": 0}))

    steps.append(lambda: w(os.path.join(root, "logs", "02_extract_full_session.command.txt"),
        "moseq2-extract extract --output-dir %s/stages/02_extract\n" % root))
    steps.append(lambda: w(os.path.join(root, "logs", "02_extract_full_session.exit_code.txt"), "0\n"))
    steps.append(lambda: w(os.path.join(root, "logs", "02_extract_full_session.stdout.txt"),
        "progress 100%% in %s seconds %s\n" % (stamp, SENTINEL_STR)))
    steps.append(lambda: w(os.path.join(root, "logs", "02_extract_full_session.stderr.txt"),
        "warning emitted at %s\n" % stamp))

    steps.append(lambda: write_tiff(os.path.join(root, "stages", "01_roi", "bground.tiff"),
                                    roi_pixels + 1, stamp))
    steps.append(lambda: wb(os.path.join(root, "stages", "02_extract", "results_00.mp4"),
        b"\x04encoder-" + stamp.encode("utf-8")))
    steps.append(lambda: w(os.path.join(root, "stages", "02_extract", "results_00.yaml"),
        "complete: true\nuuid: %s\nstart_time: %s\nend_time: %s\nduration: 41\n"
        "parameters:\n  crop_size: 80\n" % (gen_uuid, stamp, stamp)))
    # TIFFs: identical pixels, deliberately different container bytes per side
    steps.append(lambda: write_tiff(os.path.join(root, "stages", "01_roi", "roi_00.tiff"),
                                    roi_pixels, stamp))
    steps.append(lambda: write_tiff(os.path.join(root, "stages", "02_extract", "roi_00.tiff"),
                                    roi_pixels, stamp))
    # diagnostic-only render: content differs by construction, presence enforced
    steps.append(lambda: wb(os.path.join(root, "stages", "01_roi", "depth_range_diagnostic.png"),
                            b"\x89PNG-diagnostic-" + stamp.encode("utf-8")))

    def make_extract_h5():
        path = os.path.join(root, "stages", "02_extract", "results_00.h5")
        if not os.path.isdir(os.path.dirname(path)):
            os.makedirs(os.path.dirname(path))
        with h5py.File(path, "w") as f:
            f.create_dataset("frames", data=np.arange(24, dtype="uint8").reshape(2, 3, 4))
            f.create_dataset("frames_mask", data=np.ones((2, 3, 4), dtype="bool"))
            f.create_dataset("timestamps", data=np.arange(12, dtype="float64"))
            f.create_dataset("scalars/angle", data=angle_array(nan_index))
            f.create_dataset("scalars/velocity_2d_mm", data=np.full(12, SENTINEL_NUM, dtype="float32"))
            f.create_dataset("metadata/uuid", data=np.string_(gen_uuid))
            f.create_dataset("metadata/acquisition/StartTime",
                             data=np.string_(acquisition_stamp))
            f.create_dataset("metadata/extraction/pipeline", data=np.string_(
                json.dumps({"written": stamp, "git_commit": extract_commit,
                            "policy": {"roi_plane_fit": roi_policy}}, sort_keys=True)))
            # fixed-width S dtype whose capacity tracks the run-root length
            f.create_dataset("metadata/extraction/parameters/config_file",
                             data=np.string_(os.path.join(root, "inputs", "config.working.yaml")))
            f["frames"].attrs["description"] = np.string_("depth frames")
            f.attrs["flip_classifier_applied"] = True
    steps.append(make_extract_h5)

    def make_pca_h5():
        path = os.path.join(root, "stages", "03_pca", "pca_scores.h5")
        if not os.path.isdir(os.path.dirname(path)):
            os.makedirs(os.path.dirname(path))
        with h5py.File(path, "w") as f:
            f.create_dataset("scores/" + gen_uuid, data=np.linspace(0, 1, 20).reshape(10, 2))
            f.create_dataset("scores_idx/" + gen_uuid, data=np.arange(10, dtype="int64"))
            f.create_dataset("metadata/pipeline", data=np.string_(
                json.dumps({"written": stamp, "git_commit": pca_commit,
                            "npcs": 10}, sort_keys=True)))
    steps.append(make_pca_h5)

    def make_model_joblib():
        import joblib
        path = os.path.join(root, "stages", "04_model", "model-applied-heldout.p")
        if not os.path.isdir(os.path.dirname(path)):
            os.makedirs(os.path.dirname(path))
        payload = {"labels": {gen_uuid: np.array([1, 2, 3, 4 + label_bump], dtype="int32")},
                   "metadata": {"uuid": gen_uuid, "source": unrelated_uuid},
                   "run_parameters": {"npcs": 10},
                   "whitening_parameters": {"whiten": "all"},
                   "model_fit_started": False}
        if include_model_object:
            # stand-in for the embedded ARHMM: picklable, and its repr carries a
            # heap address that differs on every load, exactly like the real object
            payload["model"] = object()
        payload["model_parameters"] = {"kappa": 464159 + param_bump}
        joblib.dump(payload, path, compress=("zlib", 4))
    steps.append(make_model_joblib)

    steps.append(lambda: wj(os.path.join(root, "summaries", "extraction_summary.json"),
        {"path": os.path.join(root, "stages", "02_extract", "results_00.h5"),
         "datasets": {"frames": {"dataset_sha256": "cc" * 32, "mean": SENTINEL_NUM, "shape": [2, 3, 4]}},
         "provenance": {"written": stamp, "note": "extract run in %s" % root}}))
    steps.append(lambda: wj(os.path.join(root, "summaries", "pca_summary.json"),
        {"path": os.path.join(root, "stages", "03_pca", "pca_scores.h5"),
         "provenance": {"written": stamp, "note": "pca apply"},
         "score_summaries": {gen_uuid: {"dataset_sha256": "dd" * 32}}}))
    steps.append(lambda: wj(os.path.join(root, "summaries", "model_input_handoff.json"),
        {"input_sessions": [gen_uuid], "unrelated_reference": unrelated_uuid,
         "model_fit_started": False}))

    if reverse_order:
        steps = list(reversed(steps))
    for step in steps:
        step()


def run_comparator(primary, replay, report):
    proc = subprocess.Popen(
        [PYTHON, COMPARATOR, "--primary", primary, "--replay", replay,
         "--contract", CONTRACT, "--report", report],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate()
    return proc.returncode, out.decode("utf-8", "replace"), err.decode("utf-8", "replace")


# --------------------------------------------------------------------------
# mutations (applied to the replay root only)
# --------------------------------------------------------------------------
def m_none(root, primary=None):
    pass


def m_hdf5_dataset_bit(root, primary=None):
    path = os.path.join(root, "stages", "02_extract", "results_00.h5")
    with h5py.File(path, "a") as f:
        data = f["frames"][()]
        data[0, 0, 0] = data[0, 0, 0] + 1
        f["frames"][...] = data


def m_hdf5_attr(root, primary=None):
    with h5py.File(os.path.join(root, "stages", "02_extract", "results_00.h5"), "a") as f:
        f.attrs["flip_classifier_applied"] = False


def m_hdf5_extra_dataset(root, primary=None):
    with h5py.File(os.path.join(root, "stages", "02_extract", "results_00.h5"), "a") as f:
        f.create_dataset("scalars/undeclared_new", data=np.zeros(3, dtype="float32"))


def m_hdf5_missing_dataset(root, primary=None):
    with h5py.File(os.path.join(root, "stages", "02_extract", "results_00.h5"), "a") as f:
        del f["scalars/angle"]


def m_nan_placement(root, primary=None):
    path = os.path.join(root, "stages", "02_extract", "results_00.h5")
    with h5py.File(path, "a") as f:
        f["scalars/angle"][...] = angle_array(5)


def m_json_leaf(root, primary=None):
    path = os.path.join(root, "inputs", "extraction_frame_accounting.json")
    doc = json.load(open(path))
    doc["extracted_frames"] = 11
    wj(path, doc)


def m_json_extra_key(root, primary=None):
    path = os.path.join(root, "inputs", "raw_frame_accounting.json")
    doc = json.load(open(path))
    doc["undeclared_new_key"] = "x"
    wj(path, doc)


def m_keyval_field(root, primary=None):
    path = os.path.join(root, "R1_FULL_SESSION_RECEIPT.txt")
    text = open(path).read().replace("model_fit_started=false", "model_fit_started=true")
    w(path, text)


def m_bytes_input(root, primary=None):
    w(os.path.join(root, "inputs", "config.working.yaml"), "crop_size: [80, 81]\n")


def m_pickle_label(root, primary=None):
    path = os.path.join(root, "stages", "04_model", "model-applied-heldout.p")
    import joblib
    data = joblib.load(path)
    key = sorted(data["labels"])[0]
    data["labels"][key][2] = 99
    joblib.dump(data, path, compress=("zlib", 4))


def m_yaml_field(root, primary=None):
    path = os.path.join(root, "stages", "02_extract", "results_00.yaml")
    w(path, open(path).read().replace("crop_size: 80", "crop_size: 79"))


def m_exit_code(root, primary=None):
    w(os.path.join(root, "logs", "02_extract_full_session.exit_code.txt"), "1\n")


def m_missing_file(root, primary=None):
    os.remove(os.path.join(root, "summaries", "pca_summary.json"))


def m_foreign_root_contamination(root, primary):
    """Replay emits the PRIMARY run root literal in a MUST_MATCH field.

    The primary side canonicalises its own root to <RUN_ROOT>; the replay
    side must NOT canonicalise the foreign primary root, so the literal
    survives and the comparison must fail.
    """
    path = os.path.join(root, "summaries", "extraction_summary.json")
    doc = json.load(open(path))
    doc["provenance"] = "extract run in %s" % primary
    wj(path, doc)


def m_numeric_dtype_widened(root, primary=None):
    """Same numeric values, wider dtype: must FAIL (numeric dtype stays mandatory)."""
    path = os.path.join(root, "stages", "02_extract", "results_00.h5")
    with h5py.File(path, "a") as f:
        data = f["timestamps"][()].astype("float32")
        del f["timestamps"]
        f.create_dataset("timestamps", data=data)


def m_different_canonical_path_text(root, primary=None):
    """Canonicalised path TEXT differs (not just S-width): must FAIL."""
    path = os.path.join(root, "stages", "02_extract", "results_00.h5")
    with h5py.File(path, "a") as f:
        del f["metadata/extraction/parameters/config_file"]
        f.create_dataset("metadata/extraction/parameters/config_file",
                         data=np.string_(os.path.join(root, "inputs", "config.OTHER.yaml")))


def m_extra_file(root, primary=None):
    w(os.path.join(root, "summaries", "undeclared_extra.json"), "{}\n")


CASES = [
    ("Q01_identical_plus_declared_ignored_only", m_none, "PASS"),
    ("Q02_hdf5_dataset_single_bit", m_hdf5_dataset_bit, "FAIL"),
    ("Q03_hdf5_attribute_value", m_hdf5_attr, "FAIL"),
    ("Q04_json_scientific_leaf", m_json_leaf, "FAIL"),
    ("Q05_keyval_receipt_field", m_keyval_field, "FAIL"),
    ("Q06_frozen_input_copy_bytes", m_bytes_input, "FAIL"),
    ("Q07_pickle_label_array_value", m_pickle_label, "FAIL"),
    ("Q08_yaml_scientific_field", m_yaml_field, "FAIL"),
    ("Q09_stage_exit_code", m_exit_code, "FAIL"),
    ("Q10_nan_placement_moved_same_count", m_nan_placement, "FAIL"),
    ("Q11_missing_must_match_hdf5_dataset", m_hdf5_missing_dataset, "FAIL"),
    ("Q12_missing_must_match_file", m_missing_file, "FAIL"),
    ("Q13_undeclared_extra_file", m_extra_file, "FAIL"),
    ("Q14_undeclared_extra_hdf5_dataset", m_hdf5_extra_dataset, "FAIL"),
    ("Q15_undeclared_extra_json_key", m_json_extra_key, "FAIL"),
    ("Q19_foreign_cross_run_root_contamination", m_foreign_root_contamination, "FAIL"),
    ("Q36_numeric_dtype_mismatch_fails", m_numeric_dtype_widened, "FAIL"),
    ("Q37_different_canonical_path_text_fails", m_different_canonical_path_text, "FAIL"),
]

UUID_A = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
UUID_B = "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb"


def main():
    workdir = tempfile.mkdtemp(prefix="r1-replay-qual-")
    results = []
    try:
        for name, mutate, expected in CASES:
            case_dir = os.path.join(workdir, name)
            primary = os.path.join(case_dir, "primary")
            replay = os.path.join(case_dir, "replay")
            build_root(primary, "2026-08-17T10:00:00Z")
            build_root(replay, "2026-08-17T20:30:00Z")
            mutate(replay, primary)
            report = os.path.join(case_dir, "report.json")
            code, out, err = run_comparator(primary, replay, report)
            doc = json.load(open(report)) if os.path.exists(report) else {}
            observed = doc.get("disposition", "ERROR")
            exit_ok = (code == 0) if expected == "PASS" else (code != 0)
            results.append({
                "case": name, "expected": expected, "observed": observed,
                "exit_code": code, "exit_code_correct": exit_ok,
                "failure_count": doc.get("failure_count"),
                "result": "PASS" if (observed == expected and exit_ok) else "FAIL",
                "stderr": err.strip()[:200],
            })

        # --- R6 semantic cases: differing generated extraction UUID per side ---
        def scenario(name, akw, bkw, expected):
            cdir = os.path.join(workdir, name)
            p, r = os.path.join(cdir, "primary"), os.path.join(cdir, "replay")
            build_root(p, "2026-08-17T10:00:00Z", **akw)
            build_root(r, "2026-08-17T20:30:00Z", **bkw)
            rep = os.path.join(cdir, "report.json")
            code, _, err = run_comparator(p, r, rep)
            doc = json.load(open(rep)) if os.path.exists(rep) else {}
            obs = doc.get("disposition", "ERROR")
            exit_ok = (code == 0) if expected == "PASS" else (code != 0)
            results.append({"case": name, "expected": expected, "observed": obs,
                            "exit_code": code, "exit_code_correct": exit_ok,
                            "failure_count": doc.get("failure_count"),
                            "result": "PASS" if (obs == expected and exit_ok) else "FAIL",
                            "stderr": err.strip()[:160]})

        base_a = {"gen_uuid": UUID_A}
        base_b = {"gen_uuid": UUID_B}
        # Q20: differing generated UUIDs alone must PASS after canonicalisation
        scenario("Q20_generated_extraction_uuid_canonicalized", base_a, base_b, "PASS")
        # Q21: an unrelated UUID that differs must NOT be canonicalised -> FAIL
        scenario("Q21_unrelated_uuid_not_canonicalized",
                 dict(base_a), dict(base_b, unrelated_uuid="12345678-1234-4123-8123-123456789abc"),
                 "FAIL")
        # Q22: joblib model output, identical labels -> PASS (proves joblib load path)
        scenario("Q22_joblib_model_output_pass", base_a, base_b, "PASS")
        # Q23: one-bit label perturbation -> FAIL
        scenario("Q23_joblib_label_perturbation_fails",
                 dict(base_a), dict(base_b, label_bump=1), "FAIL")
        # Q24: TIFF container bytes differ, decoded pixels identical -> PASS
        scenario("Q24_tiff_container_differs_pixels_identical", base_a, base_b, "PASS")
        # Q25: TIFF pixel perturbation -> FAIL
        px = np.arange(64, dtype="uint16").reshape(8, 8).copy()
        px[3, 3] += 1
        scenario("Q25_tiff_pixel_perturbation_fails",
                 dict(base_a), dict(base_b, roi_pixels=px), "FAIL")

        # Q26: diagnostic/duplicate presence still enforced by inventory
        cdir = os.path.join(workdir, "Q26_diagnostic_presence_enforced")
        p, r = os.path.join(cdir, "primary"), os.path.join(cdir, "replay")
        build_root(p, "2026-08-17T10:00:00Z", **base_a)
        build_root(r, "2026-08-17T20:30:00Z", **base_b)
        os.remove(os.path.join(r, "stages", "01_roi", "depth_range_diagnostic.png"))
        rep = os.path.join(cdir, "report.json")
        code, _, _ = run_comparator(p, r, rep)
        doc = json.load(open(rep)) if os.path.exists(rep) else {}
        results.append({"case": "Q26_diagnostic_presence_enforced_by_inventory",
                        "expected": "FAIL", "observed": doc.get("disposition"),
                        "exit_code": code,
                        "result": "PASS" if (doc.get("disposition") == "FAIL" and code != 0)
                                  else "FAIL"})

        # --- R7 negative controls -----------------------------------------
        A0, B0 = {"gen_uuid": UUID_A}, {"gen_uuid": UUID_B}
        # provenance wall-clock only -> PASS (stamps already differ per side)
        scenario("Q27_provenance_written_only_differs", A0, B0, "PASS")
        # any OTHER extraction provenance field -> FAIL
        scenario("Q28_other_extraction_provenance_field_fails",
                 dict(A0), dict(B0, extract_commit="deadbeef"), "FAIL")
        scenario("Q29_extraction_policy_field_fails",
                 dict(A0), dict(B0, roi_policy="lstsq-inlier-refit"), "FAIL")
        # any OTHER pca provenance field -> FAIL
        scenario("Q30_other_pca_provenance_field_fails",
                 dict(A0), dict(B0, pca_commit="cafebabe"), "FAIL")
        # acquisition timestamp remains MUST_MATCH -> FAIL
        scenario("Q31_acquisition_timestamp_differs_fails",
                 dict(A0), dict(B0, acquisition_stamp="2025-12-11T09:00:00Z"), "FAIL")
        # embedded model object: equal content, different repr address -> PASS
        scenario("Q32_embedded_model_repr_address_differs", A0, B0, "PASS")
        # missing embedded model key -> FAIL
        scenario("Q33_missing_embedded_model_key_fails",
                 dict(A0), dict(B0, include_model_object=False), "FAIL")
        # model/run/whitening parameter perturbation -> FAIL
        scenario("Q34_model_parameter_perturbation_fails",
                 dict(A0), dict(B0, param_bump=1), "FAIL")
        # fixed-width S dtype differing only by run-root length -> PASS
        # (build_root writes config_file under its own root; roots differ in length)
        scenario("Q35_fixed_width_string_dtype_differs_pixels_same", A0, B0, "PASS")

        # Q16 determinism: identical inputs, two runs, byte-identical reports
        case_dir = os.path.join(workdir, "Q16_determinism")
        primary = os.path.join(case_dir, "primary")
        replay = os.path.join(case_dir, "replay")
        build_root(primary, "2026-08-17T10:00:00Z", gen_uuid=UUID_A)
        build_root(replay, "2026-08-17T20:30:00Z", gen_uuid=UUID_B)
        r1 = os.path.join(case_dir, "r1.json")
        r2 = os.path.join(case_dir, "r2.json")
        run_comparator(primary, replay, r1)
        run_comparator(primary, replay, r2)
        d1 = hashlib.sha256(open(r1, "rb").read()).hexdigest()
        d2 = hashlib.sha256(open(r2, "rb").read()).hexdigest()
        results.append({"case": "Q16_report_determinism", "expected": "IDENTICAL",
                        "observed": "IDENTICAL" if d1 == d2 else "DIFFERENT",
                        "result": "PASS" if d1 == d2 else "FAIL", "digest": d1})

        # Q17 directory-order invariance: replay built in reverse creation order
        case_dir = os.path.join(workdir, "Q17_order")
        primary = os.path.join(case_dir, "primary")
        replay = os.path.join(case_dir, "replay")
        build_root(primary, "2026-08-17T10:00:00Z", gen_uuid=UUID_A)
        build_root(replay, "2026-08-17T20:30:00Z", gen_uuid=UUID_B, reverse_order=True)
        r3 = os.path.join(case_dir, "r3.json")
        code, _, _ = run_comparator(primary, replay, r3)
        doc3 = json.load(open(r3))
        same_as_q16 = hashlib.sha256(
            json.dumps(doc3["findings"], sort_keys=True).encode()).hexdigest() == hashlib.sha256(
            json.dumps(json.load(open(r1))["findings"], sort_keys=True).encode()).hexdigest()
        results.append({"case": "Q17_directory_order_invariance", "expected": "PASS+INVARIANT",
                        "observed": "%s/%s" % (doc3["disposition"], "INVARIANT" if same_as_q16 else "VARIANT"),
                        "exit_code": code,
                        "result": "PASS" if (doc3["disposition"] == "PASS" and same_as_q16 and code == 0) else "FAIL"})

        # Q18 blindness: no scientific value may appear anywhere in a report
        blob = open(r1).read()
        leaked = [s for s in (SENTINEL_STR, repr(SENTINEL_NUM), "1234.56789") if s in blob]
        results.append({"case": "Q18_report_blindness", "expected": "NO_VALUES",
                        "observed": "LEAKED:%s" % leaked if leaked else "NO_VALUES",
                        "result": "PASS" if not leaked else "FAIL"})

        overall = "PASS" if all(r["result"] == "PASS" for r in results) else "FAIL"
        receipt = {
            "schema": "moseq-r1-replay-comparator-qualification-v3",
            "status": overall,
            "synthetic_fixture_only": True,
            "candidate_data_read": False,
            "case_count": len(results),
            "cases": results,
            "comparator_sha256": hashlib.sha256(open(COMPARATOR, "rb").read()).hexdigest(),
            "contract_sha256": hashlib.sha256(open(CONTRACT, "rb").read()).hexdigest(),
        }
        out_path = os.path.join(HERE, "REPLAY_COMPARATOR_QUALIFICATION_RECEIPT.json")
        wj(out_path, receipt)
        for row in results:
            print("%-42s %s" % (row["case"], row["result"]))
        print("OVERALL:", overall)
        return 0 if overall == "PASS" else 2
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
