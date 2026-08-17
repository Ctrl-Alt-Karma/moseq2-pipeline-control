#!/usr/bin/env python3
"""Record pre-science raw frame accounting for one staged R1 session."""

from __future__ import print_function

import argparse
import json
import os
import re
import sys


def line_count(path):
    with open(path, "rb") as stream:
        return sum(1 for _line in stream)


def metadata_frame_count(metadata):
    for key in ("DepthFrameCount", "FrameCount", "NumFrames", "NFrames", "depth_frame_count", "frame_count"):
        value = metadata.get(key)
        if isinstance(value, int):
            return {"key": key, "value": value}
    return {"key": None, "value": None}


def raw_frames_from_bytes(depth_bytes, metadata):
    resolution = metadata.get("DepthResolution")
    dtype = metadata.get("DepthDataType")
    match = re.match(r"^(\d+)x(\d+)$", resolution or "")
    bytes_per_pixel = {"UInt16[]": 2, "uint16": 2}.get(dtype)
    if match is None or bytes_per_pixel is None:
        return {"resolution": resolution, "data_type": dtype, "bytes_per_frame": None, "frames": None, "exact_division": False}
    bytes_per_frame = int(match.group(1)) * int(match.group(2)) * bytes_per_pixel
    return {
        "resolution": resolution,
        "data_type": dtype,
        "bytes_per_frame": bytes_per_frame,
        "frames": depth_bytes // bytes_per_frame,
        "exact_division": depth_bytes % bytes_per_frame == 0,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--depth", required=True)
    parser.add_argument("--metadata", required=True)
    parser.add_argument("--timestamps", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    with open(args.metadata, "r") as stream:
        metadata = json.load(stream)
    depth_bytes = os.path.getsize(args.depth)
    timestamp_rows = line_count(args.timestamps)
    from_bytes = raw_frames_from_bytes(depth_bytes, metadata)
    declared = metadata_frame_count(metadata)
    checks = {
        "raw_bytes_divide_into_whole_frames": from_bytes["exact_division"],
        "raw_frame_count_equals_timestamp_rows": from_bytes["frames"] == timestamp_rows,
        "metadata_declared_frame_count_matches_if_present": declared["value"] is None or declared["value"] == timestamp_rows,
    }
    receipt = {
        "schema": "moseq-r1-raw-frame-accounting-v1",
        "status": "PASS" if all(checks.values()) else "FAILED_HOLD",
        "depth_bytes": depth_bytes,
        "timestamp_rows": timestamp_rows,
        "metadata_declared_frame_count": declared,
        "raw_frame_derivation": from_bytes,
        "checks": checks,
    }
    with open(args.output, "w", newline="\n") as stream:
        json.dump(receipt, stream, indent=2, sort_keys=True)
        stream.write("\n")
    if receipt["status"] != "PASS":
        return 42
    return 0


if __name__ == "__main__":
    sys.exit(main())
