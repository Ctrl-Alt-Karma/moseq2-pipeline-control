#!/usr/bin/env python
"""Deterministic replay comparator for R1 (OQ-V6-011).

Compares two full-session operator output roots under
REPLAY_COMPARISON_CONTRACT_R1.json. Emits a blind report: logical names,
classes, match status and digests only. Never emits scientific values.

Exit 0 = PASS, 2 = FAIL, 3 = usage/contract error.
"""

from __future__ import print_function

import argparse
import fnmatch
import hashlib
import json
import os
import pickle
import struct
import sys

import numpy as np
import h5py

try:
    import yaml as _yaml
except ImportError:  # pragma: no cover - legacy env may expose ruamel only
    try:
        import ruamel.yaml as _yaml
    except ImportError:
        _yaml = None

PASS, FAIL, ERROR = 0, 2, 3
RUN_ROOT_TOKEN = "<RUN_ROOT>"


# --------------------------------------------------------------------------
# canonicalisation + digests
# --------------------------------------------------------------------------
def canon_text(text, own_roots):
    """Contract rule C1: neutralise ONLY this side's own run root.

    Each side is canonicalised against its own root alone. A foreign run
    root appearing in the other side's output therefore survives
    canonicalisation and forces a comparison failure. Supplying both roots
    to both sides would mask cross-run-root contamination.
    """
    for root in own_roots:
        text = text.replace(root, RUN_ROOT_TOKEN)
        text = text.replace(root.rstrip("/"), RUN_ROOT_TOKEN)
    return text


def leaf_bytes(value, roots):
    """Deterministic byte encoding of a scalar leaf.

    Floats are encoded as IEEE-754 little-endian bit patterns so that NaN
    payloads and -0.0 are distinguished exactly.
    """
    if value is None:
        return b"N"
    if isinstance(value, bool):
        return b"B1" if value else b"B0"
    if isinstance(value, float):
        return b"F" + struct.pack("<d", value)
    if isinstance(value, int):
        return b"I" + repr(value).encode("utf-8")
    if isinstance(value, bytes):
        return b"Y" + canon_text(value.decode("utf-8", "replace"), roots).encode("utf-8")
    return b"S" + canon_text(str(value), roots).encode("utf-8")


def digest(*chunks):
    h = hashlib.sha256()
    for chunk in chunks:
        h.update(chunk if isinstance(chunk, bytes) else str(chunk).encode("utf-8"))
        h.update(b"\x1f")
    return h.hexdigest()


def array_digest(array, roots):
    """dtype + shape + exact C-order bytes (NaN pattern included)."""
    arr = np.asarray(array)
    if arr.dtype == object or arr.dtype.kind in ("U", "S", "O"):
        parts = [repr(arr.dtype.str).encode("utf-8"), repr(arr.shape).encode("utf-8")]
        for item in arr.ravel().tolist() if arr.shape else [arr.tolist()]:
            parts.append(leaf_bytes(item, roots))
        return digest(*parts)
    return digest(
        arr.dtype.str,
        repr(arr.shape),
        np.ascontiguousarray(arr).tobytes(order="C"),
    )


# --------------------------------------------------------------------------
# unit extraction per handler
# --------------------------------------------------------------------------
def units_bytes(path, roots):
    with open(path, "rb") as handle:
        raw = handle.read()
    try:
        return {"": digest(canon_text(raw.decode("utf-8"), roots).encode("utf-8"))}
    except UnicodeDecodeError:
        return {"": digest(raw)}


def units_keyval(path, roots):
    units = {}
    with open(path, "rb") as handle:
        text = handle.read().decode("utf-8", "replace")
    for line in canon_text(text, roots).splitlines():
        if not line.strip():
            continue
        key, _, value = line.partition("=")
        units["::" + key.strip()] = digest(value)
    return units


def _walk_leaves(obj, prefix, out, roots):
    if isinstance(obj, dict):
        if not obj:
            out[prefix] = digest(b"EMPTYDICT")
        for key in sorted(obj.keys(), key=lambda k: str(k)):
            _walk_leaves(obj[key], prefix + "/" + str(key), out, roots)
    elif isinstance(obj, (list, tuple)):
        if not obj:
            out[prefix] = digest(b"EMPTYLIST")
        for index, item in enumerate(obj):
            _walk_leaves(item, prefix + "[%d]" % index, out, roots)
    elif isinstance(obj, np.ndarray):
        out[prefix] = array_digest(obj, roots)
    else:
        out[prefix] = digest(leaf_bytes(obj, roots))


def units_json(path, roots):
    with open(path, "rb") as handle:
        data = json.loads(handle.read().decode("utf-8"))
    out = {}
    _walk_leaves(data, "", out, roots)
    return {"::" + k.lstrip("/"): v for k, v in out.items()}


def units_yaml(path, roots):
    if _yaml is None:
        return units_bytes(path, roots)
    with open(path, "rb") as handle:
        text = handle.read().decode("utf-8", "replace")
    loader = getattr(_yaml, "safe_load", None)
    data = loader(text) if loader else _yaml.YAML(typ="safe").load(text)
    out = {}
    _walk_leaves(data, "", out, roots)
    return {"::" + k.lstrip("/"): v for k, v in out.items()}


def units_hdf5(path, roots):
    units = {}

    def attrs_of(name, obj):
        for key in sorted(obj.attrs.keys()):
            units["::" + name + "@" + str(key)] = array_digest(obj.attrs[key], roots)

    with h5py.File(path, "r") as handle:
        attrs_of("/", handle)
        names = []
        handle.visit(lambda n: names.append(n))
        for name in sorted(names):
            obj = handle[name]
            attrs_of("/" + name, obj)
            if isinstance(obj, h5py.Dataset):
                units["::/" + name] = array_digest(obj[()], roots)
    return units


def units_pickle(path, roots):
    with open(path, "rb") as handle:
        data = pickle.load(handle, encoding="latin1")
    out = {}
    _walk_leaves(data, "", out, roots)
    return {"::" + k.lstrip("/"): v for k, v in out.items()}


HANDLERS = {
    "bytes": units_bytes,
    "keyval": units_keyval,
    "json": units_json,
    "yaml": units_yaml,
    "hdf5": units_hdf5,
    "pickle": units_pickle,
}


# --------------------------------------------------------------------------
# contract
# --------------------------------------------------------------------------
class Contract(object):
    def __init__(self, doc):
        self.doc = doc
        self.file_rules = []
        for row in doc["MUST_MATCH"]:
            name = row["logical_name"]
            if name.startswith("<"):
                continue
            self.file_rules.append((name, row["handler"], row["id"]))
        self.ignored_files = []
        self.ignored_fields = []
        for row in doc["DECLARED_IGNORED"]:
            name = row["logical_name"]
            if name.startswith("<"):
                continue
            if "::" in name:
                fileglob, field = name.split("::", 1)
                self.ignored_fields.append((fileglob, field, row["id"]))
            else:
                self.ignored_files.append((name, row["id"]))

    def classify_file(self, rel):
        for glob, rule_id in self.ignored_files:
            if fnmatch.fnmatch(rel, glob):
                return "DECLARED_IGNORED", None, rule_id
        for glob, handler, rule_id in self.file_rules:
            if fnmatch.fnmatch(rel, glob):
                return "MUST_MATCH", handler, rule_id
        return "UNCLASSIFIED", None, None

    def field_ignored(self, rel, unit):
        field = unit[2:] if unit.startswith("::") else unit
        for fileglob, ignored, rule_id in self.ignored_fields:
            if not fnmatch.fnmatch(rel, fileglob):
                continue
            if fnmatch.fnmatch(field, ignored):
                return rule_id
        return None


def inventory(root):
    found = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for name in sorted(filenames):
            full = os.path.join(dirpath, name)
            found.append(os.path.relpath(full, root).replace(os.sep, "/"))
    return sorted(found)


# --------------------------------------------------------------------------
def compare(root_a, root_b, contract):
    root_a = os.path.abspath(root_a)
    root_b = os.path.abspath(root_b)
    own_a, own_b = [root_a], [root_b]  # C1: each side sees only its own root
    findings = []
    failures = 0

    inv_a, inv_b = inventory(root_a), inventory(root_b)
    only_a = sorted(set(inv_a) - set(inv_b))
    only_b = sorted(set(inv_b) - set(inv_a))
    inventory_ok = not only_a and not only_b
    if not inventory_ok:
        failures += len(only_a) + len(only_b)
    findings.append({
        "logical_name": "<inventory>",
        "class": "MUST_MATCH",
        "rule": "M01",
        "status": "MATCH" if inventory_ok else "DIFFER",
        "missing_in_replay": only_a,
        "extra_in_replay": only_b,
        "count_a": len(inv_a),
        "count_b": len(inv_b),
    })

    for rel in sorted(set(inv_a) & set(inv_b)):
        klass, handler, rule_id = contract.classify_file(rel)
        if klass == "UNCLASSIFIED":
            failures += 1
            findings.append({"logical_name": rel, "class": "UNCLASSIFIED",
                             "rule": None, "status": "FAIL_UNCLASSIFIED"})
            continue
        if klass == "DECLARED_IGNORED":
            findings.append({"logical_name": rel, "class": "DECLARED_IGNORED",
                             "rule": rule_id, "status": "IGNORED"})
            continue
        try:
            units_a = HANDLERS[handler](os.path.join(root_a, rel), own_a)
            units_b = HANDLERS[handler](os.path.join(root_b, rel), own_b)
        except Exception as error:  # unreadable governed content is a failure
            failures += 1
            findings.append({"logical_name": rel, "class": "MUST_MATCH",
                             "rule": rule_id, "status": "FAIL_UNREADABLE",
                             "detail": "%s: %s" % (type(error).__name__, error)})
            continue

        for unit in sorted(set(units_a) | set(units_b)):
            name = rel + unit
            ignored_by = contract.field_ignored(rel, unit)
            if ignored_by:
                findings.append({"logical_name": name, "class": "DECLARED_IGNORED",
                                 "rule": ignored_by, "status": "IGNORED"})
                continue
            in_a, in_b = unit in units_a, unit in units_b
            if not (in_a and in_b):
                failures += 1
                findings.append({
                    "logical_name": name, "class": "MUST_MATCH", "rule": rule_id,
                    "status": "FAIL_MISSING" if in_b else "FAIL_EXTRA",
                    "present_in_primary": in_a, "present_in_replay": in_b,
                })
                continue
            same = units_a[unit] == units_b[unit]
            if not same:
                failures += 1
            findings.append({
                "logical_name": name, "class": "MUST_MATCH", "rule": rule_id,
                "status": "MATCH" if same else "DIFFER",
                "digest_primary": units_a[unit], "digest_replay": units_b[unit],
            })

    findings.sort(key=lambda row: (row["logical_name"], row.get("rule") or ""))
    counted = {}
    for row in findings:
        counted[row["status"]] = counted.get(row["status"], 0) + 1
    report = {
        "schema": "moseq-r1-replay-comparison-report-v1",
        "contract_id": contract.doc["contract_id"],
        "contract_sha256": contract.sha256,
        "disposition": "PASS" if failures == 0 else "FAIL",
        "failure_count": failures,
        "status_counts": counted,
        "must_match_units": sum(1 for r in findings if r["class"] == "MUST_MATCH"),
        "declared_ignored_units": sum(1 for r in findings if r["class"] == "DECLARED_IGNORED"),
        "unclassified_units": sum(1 for r in findings if r["class"] == "UNCLASSIFIED"),
        "blindness": "logical names, classes, statuses and digests only; no scientific values",
        "findings": findings,
    }
    return report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--primary", required=True)
    parser.add_argument("--replay", required=True)
    parser.add_argument("--contract", required=True)
    parser.add_argument("--report", required=True)
    args = parser.parse_args()

    with open(args.contract, "rb") as handle:
        raw = handle.read()
    contract = Contract(json.loads(raw.decode("utf-8")))
    contract.sha256 = hashlib.sha256(raw).hexdigest()

    report = compare(args.primary, args.replay, contract)
    with open(args.report, "w") as handle:
        json.dump(report, handle, indent=2, sort_keys=True)
        handle.write("\n")
    print("disposition=%s failures=%d must_match_units=%d ignored=%d unclassified=%d"
          % (report["disposition"], report["failure_count"],
             report["must_match_units"], report["declared_ignored_units"],
             report["unclassified_units"]))
    return PASS if report["disposition"] == "PASS" else FAIL


if __name__ == "__main__":
    sys.exit(main())
