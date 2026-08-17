#!/usr/bin/env python3
"""Synthetic qualification for R4 raw-frame-accounting resolution handling.

Synthetic fixtures only. No candidate recording, metadata or roster identity is
read. Proves the supported representations agree numerically and that every
unsupported representation fails closed through the accounting receipt rather
than raising.
"""

from __future__ import print_function

import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
HELPER = os.path.join(os.path.dirname(HERE), "helpers", "record_r1_raw_frame_accounting.py")
PYTHON = sys.executable

W, H, BPP = 512, 424, 2
FRAME = W * H * BPP          # 434176
FRAMES = 2
DEPTH_BYTES = FRAME * FRAMES


def build(work, resolution, dtype="UInt16[]", depth_bytes=DEPTH_BYTES, rows=FRAMES, declared=None):
    os.makedirs(work)
    depth = os.path.join(work, "depth.dat")
    with open(depth, "wb") as fh:
        fh.truncate(depth_bytes)
    md = {"DepthDataType": dtype, "SessionName": "synthetic", "SubjectName": "synthetic_nonbiological"}
    if resolution is not _OMIT:
        md["DepthResolution"] = resolution
    if declared is not None:
        md["DepthFrameCount"] = declared
    meta = os.path.join(work, "metadata.json")
    with open(meta, "w") as fh:
        json.dump(md, fh, sort_keys=True)
    ts = os.path.join(work, "depth_ts.txt")
    with open(ts, "w") as fh:
        fh.write("".join("%d\n" % i for i in range(rows)))
    return depth, meta, ts


class _Omit(object):
    pass


_OMIT = _Omit()


def run(work, **kw):
    depth, meta, ts = build(work, **kw)
    out = os.path.join(work, "receipt.json")
    proc = subprocess.Popen(
        [PYTHON, "-B", HELPER, "--depth", depth, "--metadata", meta,
         "--timestamps", ts, "--output", out],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    so, se = proc.communicate()
    receipt = json.load(open(out)) if os.path.exists(out) else None
    return proc.returncode, receipt, se.decode("utf-8", "replace")


CASES = [
    # label,                              kwargs,                                    expect
    ("string_512x424_uint16",             {"resolution": "512x424"},                 "PASS"),
    ("list_512_424_uint16",               {"resolution": [512, 424]},                "PASS"),
    ("list_len1",                         {"resolution": [512]},                     "FAILED_HOLD"),
    ("list_len0",                         {"resolution": []},                        "FAILED_HOLD"),
    ("list_len3",                         {"resolution": [512, 424, 1]},             "FAILED_HOLD"),
    ("list_string_element",               {"resolution": ["512", 424]},              "FAILED_HOLD"),
    ("list_zero_dimension",               {"resolution": [0, 424]},                  "FAILED_HOLD"),
    ("list_negative_dimension",           {"resolution": [-512, 424]},               "FAILED_HOLD"),
    ("list_boolean_element",              {"resolution": [True, 424]},               "FAILED_HOLD"),
    ("list_float_element",                {"resolution": [512.0, 424]},              "FAILED_HOLD"),
    ("null_resolution",                   {"resolution": None},                      "FAILED_HOLD"),
    ("absent_resolution",                 {"resolution": _OMIT},                     "FAILED_HOLD"),
    ("unsupported_resolution_string",     {"resolution": "512*424"},                 "FAILED_HOLD"),
    ("string_zero_dimension",             {"resolution": "0x424"},                   "FAILED_HOLD"),
    ("dict_resolution",                   {"resolution": {"w": 512, "h": 424}},      "FAILED_HOLD"),
    ("unsupported_dtype",                 {"resolution": [512, 424], "dtype": "Float32[]"}, "FAILED_HOLD"),
    ("non_whole_frame_bytes",             {"resolution": [512, 424], "depth_bytes": DEPTH_BYTES + 7}, "FAILED_HOLD"),
    ("timestamp_row_mismatch",            {"resolution": [512, 424], "rows": FRAMES + 1}, "FAILED_HOLD"),
    ("declared_frame_count_mismatch",     {"resolution": [512, 424], "declared": 99}, "FAILED_HOLD"),
    ("declared_frame_count_match",        {"resolution": [512, 424], "declared": FRAMES}, "PASS"),
]


def main():
    tmp = tempfile.mkdtemp(prefix="r4-rfa-qual-")
    results = []
    equivalence = {}
    try:
        for label, kw, expect in CASES:
            rc, receipt, stderr = run(os.path.join(tmp, label), **kw)
            status = receipt["status"] if receipt else "NO_RECEIPT"
            crashed = "Traceback" in stderr
            expected_rc = 0 if expect == "PASS" else 42
            ok = (status == expect) and (rc == expected_rc) and not crashed
            if label in ("string_512x424_uint16", "list_512_424_uint16"):
                equivalence[label] = {
                    "bytes_per_frame": receipt["raw_frame_derivation"]["bytes_per_frame"],
                    "frames": receipt["raw_frame_derivation"]["frames"],
                }
            results.append({
                "case": label, "expected": expect, "observed_status": status,
                "exit_code": rc, "expected_exit_code": expected_rc,
                "raised_exception": crashed,
                "resolution_representation_preserved": (
                    receipt["raw_frame_derivation"]["resolution"] == kw.get("resolution")
                    if receipt and kw.get("resolution") is not _OMIT else None),
                "result": "PASS" if ok else "FAIL",
            })

        same = (equivalence.get("string_512x424_uint16")
                == equivalence.get("list_512_424_uint16"))
        results.append({
            "case": "string_and_list_forms_numerically_identical",
            "expected": "IDENTICAL",
            "observed_status": "IDENTICAL" if same else "DIFFERENT",
            "detail": equivalence,
            "result": "PASS" if same else "FAIL",
        })

        overall = "PASS" if all(r["result"] == "PASS" for r in results) else "FAIL"
        receipt = {
            "schema": "moseq-r1-r4-raw-frame-accounting-qualification-v1",
            "status": overall,
            "synthetic_fixture_only": True,
            "candidate_data_read": False,
            "case_count": len(results),
            "cases": results,
            "helper_sha256": hashlib.sha256(open(HELPER, "rb").read()).hexdigest(),
        }
        out = os.path.join(HERE, "R4_RAW_FRAME_ACCOUNTING_QUALIFICATION_RECEIPT.json")
        with open(out, "w", newline="\n") as fh:
            json.dump(receipt, fh, indent=2, sort_keys=True)
            fh.write("\n")
        for row in results:
            print("%-42s %s" % (row["case"], row["result"]))
        print("OVERALL:", overall)
        return 0 if overall == "PASS" else 2
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
