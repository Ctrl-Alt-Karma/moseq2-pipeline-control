#!/usr/bin/env python
"""Collect bounded text evidence, hash it, and create one verifier ZIP."""

from __future__ import print_function

import argparse
import hashlib
import os
import shutil
import zipfile


TEXT_EXTENSIONS = {
    ".command",
    ".csv",
    ".env",
    ".json",
    ".log",
    ".md",
    ".ps1",
    ".py",
    ".sh",
    ".stderr",
    ".stdout",
    ".toml",
    ".tsv",
    ".txt",
    ".xml",
    ".yaml",
    ".yml",
}
BINARY_EXTENSIONS = {".h5", ".hdf5", ".joblib", ".p", ".pickle", ".pkl"}
RAW_EXTENSIONS = {".avi", ".bin", ".dat", ".mkv", ".mp4", ".tar"}


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def copy_tree(source, destination, include_binary):
    copied = []
    if not os.path.isdir(source):
        return copied
    for current, directories, files in os.walk(source):
        directories.sort()
        files.sort()
        for filename in files:
            source_path = os.path.join(current, filename)
            extension = os.path.splitext(filename)[1].lower()
            if extension in RAW_EXTENSIONS:
                continue
            if extension in BINARY_EXTENSIONS and not include_binary:
                continue
            if extension not in TEXT_EXTENSIONS and extension not in BINARY_EXTENSIONS:
                continue
            relative = os.path.relpath(source_path, source)
            target = os.path.join(destination, relative)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy2(source_path, target)
            copied.append(target)
    return copied


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--validation-root", required=True)
    parser.add_argument("--packet-root", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--include-binary-outputs", action="store_true")
    parser.add_argument("--include-raw-recording")
    args = parser.parse_args()

    validation_root = os.path.abspath(args.validation_root)
    packet_root = os.path.abspath(args.packet_root)
    output_dir = os.path.abspath(args.output_dir)
    staging = os.path.join(output_dir, "staging")
    os.makedirs(staging)

    copied = []
    copied.extend(
        copy_tree(
            packet_root,
            os.path.join(staging, "home_pilot_packet"),
            include_binary=False,
        )
    )
    for name in ("evidence", "real_pilot"):
        copied.extend(
            copy_tree(
                os.path.join(validation_root, name),
                os.path.join(staging, name),
                include_binary=args.include_binary_outputs,
            )
        )
    for filename in (
        ".moseq2-home-pilot-root",
        "PHASE0_FREEZE_RECEIPT.txt",
        "PHASE0_SHA256SUMS.txt",
        "locked_source.env",
        "locked_worktrees.tsv",
        "LOCKED_WORKTREE_RECEIPT.txt",
    ):
        source = os.path.join(validation_root, filename)
        if os.path.isfile(source):
            target = os.path.join(staging, filename)
            shutil.copy2(source, target)
            copied.append(target)

    if args.include_raw_recording:
        source = os.path.abspath(args.include_raw_recording)
        if not os.path.isfile(source):
            raise SystemExit("raw recording is not a file: {}".format(source))
        target = os.path.join(staging, "explicit_raw_recording", os.path.basename(source))
        os.makedirs(os.path.dirname(target))
        shutil.copy2(source, target)
        copied.append(target)

    manifest = os.path.join(staging, "SHA256SUMS.txt")
    entries = []
    for path in sorted(copied):
        relative = os.path.relpath(path, staging).replace(os.sep, "/")
        entries.append("{}  {}".format(sha256(path), relative))
    with open(manifest, "w") as stream:
        stream.write("\n".join(entries) + "\n")

    zip_path = os.path.join(output_dir, "MOSEQ_FABLE_HOME_PILOT_EVIDENCE.zip")
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for current, directories, files in os.walk(staging):
            directories.sort()
            files.sort()
            for filename in files:
                path = os.path.join(current, filename)
                relative = os.path.relpath(path, staging).replace(os.sep, "/")
                archive.write(path, relative)

    with open(zip_path + ".sha256.txt", "w") as stream:
        stream.write("{}  {}\n".format(sha256(zip_path), os.path.basename(zip_path)))
        stream.write("{}  bytes\n".format(os.path.getsize(zip_path)))
        stream.write("payload_files={}\n".format(len(entries)))
        stream.write("raw_recording_included={}\n".format(bool(args.include_raw_recording)))


if __name__ == "__main__":
    main()
