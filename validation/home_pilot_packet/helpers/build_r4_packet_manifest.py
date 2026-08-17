#!/usr/bin/env python3
"""Build the canonical, sorted R4 packet manifest."""

from __future__ import print_function

import hashlib
import os


PACKET_ROOT = os.path.realpath(os.path.join(os.path.dirname(__file__), ".."))
OUTPUT_NAME = "SHA256SUMS_R4.txt"


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def governed_members():
    members = []
    for directory, dirnames, filenames in os.walk(PACKET_ROOT):
        dirnames[:] = sorted(name for name in dirnames if name not in (".git", "__pycache__"))
        for filename in sorted(filenames):
            path = os.path.join(directory, filename)
            relative = os.path.relpath(path, PACKET_ROOT).replace(os.sep, "/")
            if relative == OUTPUT_NAME or filename.endswith((".pyc", ".pyo")):
                continue
            if os.path.isfile(path) and not os.path.islink(path):
                members.append(relative)
    return sorted(members)


def main():
    output = os.path.join(PACKET_ROOT, OUTPUT_NAME)
    lines = ["{}  {}".format(sha256_file(os.path.join(PACKET_ROOT, name)), name) for name in governed_members()]
    temporary = output + ".tmp"
    with open(temporary, "w", newline="\n") as stream:
        stream.write("\n".join(lines) + "\n")
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, output)
    print("manifest={}".format(output))
    print("entries={}".format(len(lines)))
    print("sha256={}".format(sha256_file(output)))


if __name__ == "__main__":
    main()
