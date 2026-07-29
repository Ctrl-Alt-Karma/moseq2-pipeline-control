#!/usr/bin/env python
"""Read-only recording manifest and smallest representative candidate."""

from __future__ import print_function

import argparse
import datetime
import hashlib
import os


RAW_EXTENSIONS = {
    ".dat",
    ".mkv",
    ".avi",
    ".mp4",
    ".tar",
    ".gz",
    ".bin",
}
METADATA_EXTENSIONS = {".json", ".yaml", ".yml", ".csv", ".txt"}


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def iso_timestamp(value):
    return datetime.datetime.utcfromtimestamp(value).isoformat() + "Z"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-root", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--hash-max-bytes", type=int, default=2 * 1024 ** 3)
    args = parser.parse_args()
    data_root = os.path.abspath(args.data_root)
    output = os.path.abspath(args.output_dir)
    if not os.path.isdir(data_root):
        raise SystemExit("data root is not a directory: {}".format(data_root))
    if not os.path.isdir(output):
        raise SystemExit("output directory is not a directory: {}".format(output))

    records = []
    recording_dirs = {}
    for current, directories, files in os.walk(data_root):
        directories.sort()
        files.sort()
        for filename in files:
            path = os.path.join(current, filename)
            try:
                stat = os.stat(path, follow_symlinks=False)
            except OSError as error:
                records.append((path, "UNREADABLE", "", "", str(error)))
                continue
            digest = (
                sha256(path)
                if stat.st_size <= args.hash_max_bytes
                else "NOT_HASHED_SIZE_LIMIT"
            )
            records.append(
                (
                    path,
                    str(stat.st_size),
                    iso_timestamp(stat.st_mtime),
                    digest,
                    "",
                )
            )
            extension = os.path.splitext(filename)[1].lower()
            if extension in RAW_EXTENSIONS:
                entry = recording_dirs.setdefault(
                    current,
                    {
                        "raw_files": [],
                        "metadata_files": [],
                        "total_bytes": 0,
                    },
                )
                entry["raw_files"].append(path)
            if extension in METADATA_EXTENSIONS:
                entry = recording_dirs.setdefault(
                    current,
                    {
                        "raw_files": [],
                        "metadata_files": [],
                        "total_bytes": 0,
                    },
                )
                entry["metadata_files"].append(path)

    sizes_by_directory = {}
    for path, size, unused_time, unused_hash, unused_error in records:
        if size.isdigit():
            sizes_by_directory.setdefault(os.path.dirname(path), 0)
            sizes_by_directory[os.path.dirname(path)] += int(size)
    for directory, entry in recording_dirs.items():
        entry["total_bytes"] = sizes_by_directory.get(directory, 0)

    with open(os.path.join(output, "recording_manifest.tsv"), "w") as stream:
        stream.write("path\tbytes\tmodified_utc\tsha256\terror\n")
        for record in records:
            stream.write("\t".join(value.replace("\t", " ") for value in record) + "\n")

    representative = [
        (directory, entry)
        for directory, entry in recording_dirs.items()
        if entry["raw_files"] and entry["metadata_files"]
    ]
    representative.sort(key=lambda item: (item[1]["total_bytes"], item[0]))
    with open(os.path.join(output, "recording_recommendation.md"), "w") as stream:
        stream.write("# Smallest technically representative recording\n\n")
        stream.write(
            "Selection requires at least one raw depth/video file and one "
            "metadata/config file in the same bounded recording directory.\n\n"
        )
        if representative:
            directory, entry = representative[0]
            stream.write("- recommended directory: `{}`\n".format(directory))
            stream.write("- directory bytes: {}\n".format(entry["total_bytes"]))
            stream.write("- raw candidates:\n")
            for path in entry["raw_files"]:
                stream.write("  - `{}`\n".format(path))
            stream.write("- metadata/config candidates:\n")
            for path in entry["metadata_files"]:
                stream.write("  - `{}`\n".format(path))
            stream.write(
                "\nThis is a size/structure recommendation only. AJ must approve "
                "the scientific representativeness before processing.\n"
            )
        else:
            stream.write(
                "UNRESOLVED: no directory contained both a recognized raw "
                "recording file and metadata/config file.\n"
            )

    with open(os.path.join(output, "INVENTORY_RECEIPT.txt"), "w") as stream:
        stream.write("data_root={}\n".format(data_root))
        stream.write("files={}\n".format(len(records)))
        stream.write("hash_max_bytes={}\n".format(args.hash_max_bytes))
        stream.write("recordings_processed=false\n")
        stream.write("source_files_modified=false\n")


if __name__ == "__main__":
    main()
