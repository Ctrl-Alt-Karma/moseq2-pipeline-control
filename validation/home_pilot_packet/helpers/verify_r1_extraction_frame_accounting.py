#!/usr/bin/env python3
"""Fail if a full-session extraction silently truncates persisted frames."""

from __future__ import print_function

import argparse
import json
import sys

import h5py


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw-accounting", required=True)
    parser.add_argument("--extraction-h5", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    with open(args.raw_accounting, "r") as stream:
        raw = json.load(stream)
    expected = raw["timestamp_rows"]
    with h5py.File(args.extraction_h5, "r") as handle:
        frames = len(handle["frames"])
        timestamps = len(handle["timestamps"])
        frame_mask = len(handle["frames_mask"]) if "frames_mask" in handle else None
    checks = {
        "extracted_frames_equal_raw_timestamp_rows": frames == expected,
        "extracted_timestamps_equal_raw_timestamp_rows": timestamps == expected,
        "frame_mask_equal_raw_timestamp_rows_if_present": frame_mask is None or frame_mask == expected,
    }
    receipt = {
        "schema": "moseq-r1-extraction-frame-accounting-v1",
        "status": "PASS" if all(checks.values()) else "FAILED_HOLD",
        "expected_full_session_frames": expected,
        "extracted_frames": frames,
        "extracted_timestamps": timestamps,
        "extracted_frame_mask": frame_mask,
        "checks": checks,
        "tolerance": 0,
    }
    with open(args.output, "w", newline="\n") as stream:
        json.dump(receipt, stream, indent=2, sort_keys=True)
        stream.write("\n")
    if receipt["status"] != "PASS":
        return 42
    return 0


if __name__ == "__main__":
    sys.exit(main())
