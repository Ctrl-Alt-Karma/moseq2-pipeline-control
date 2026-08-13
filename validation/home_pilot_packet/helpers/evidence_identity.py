#!/usr/bin/env python
"""Deterministic installed-source, sitecustomize, and custody evidence."""

from __future__ import print_function

import hashlib
import importlib.machinery
import json
import os
import re


IDENTITY_STATUSES = (
    "VANILLA_MATCH",
    "FORK_RELEASE_MATCH",
    "CANDIDATE_MATCH",
    "MULTIPLE_IDENTICAL_MATCHES",
    "NEITHER",
    "UNRESOLVED",
)
REFERENCE_LABELS = ("VANILLA", "FORK_RELEASE", "CANDIDATE")
IGNORED_DIRECTORIES = {".git", "__pycache__"}
IGNORED_SUFFIXES = (".pyc", ".pyo")
CONFIG_SUFFIXES = (".yaml", ".yml", ".json", ".toml")
CLASSIFIER_SUFFIXES = (".p", ".pkl", ".pickle", ".joblib")
CLASSIFIER_REFERENCE = re.compile(
    r"""(?ix)
    (?:flip[\s_-]*classifier|classifier[\s_-]*path)
    \s*[:=]\s*
    ["']?([^"'#\s]+)
    """
)


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _manifest_digest(records):
    payload = "".join(
        "{}  {}\n".format(item["sha256"], item["relative_path"])
        for item in records
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def source_tree_identity(root):
    """Hash a package tree deterministically without executing its contents."""
    root = os.path.abspath(root)
    record = {
        "root": root,
        "selection": "all regular files and symlinks except .git, __pycache__, .pyc, .pyo",
        "status": "UNRESOLVED",
        "files": [],
        "errors": [],
    }
    if not os.path.isdir(root):
        record["errors"].append("source tree is not a directory")
        return record
    for current, directories, files in os.walk(root, followlinks=False):
        directories[:] = sorted(
            name for name in directories if name not in IGNORED_DIRECTORIES
        )
        for filename in sorted(files):
            if filename.endswith(IGNORED_SUFFIXES):
                continue
            path = os.path.join(current, filename)
            relative = os.path.relpath(path, root).replace(os.sep, "/")
            try:
                if os.path.islink(path):
                    target = os.readlink(path)
                    payload = target.encode("utf-8")
                    digest = hashlib.sha256(payload).hexdigest()
                    size = len(payload)
                    file_type = "symlink-target"
                elif os.path.isfile(path):
                    digest = sha256_file(path)
                    size = os.path.getsize(path)
                    file_type = "regular"
                else:
                    record["errors"].append(
                        "unsupported source entry: {}".format(relative)
                    )
                    continue
                record["files"].append(
                    {
                        "relative_path": relative,
                        "path": os.path.abspath(path),
                        "sha256": digest,
                        "bytes": size,
                        "type": file_type,
                    }
                )
            except Exception as error:
                record["errors"].append(
                    "{}: {}: {}".format(
                        relative,
                        type(error).__name__,
                        error,
                    )
                )
    record["files"].sort(key=lambda item: item["relative_path"])
    if record["files"] and not record["errors"]:
        record["status"] = "HASHED"
        record["aggregate_sha256"] = _manifest_digest(record["files"])
        record["file_count"] = len(record["files"])
        record["total_bytes"] = sum(item["bytes"] for item in record["files"])
    else:
        record["aggregate_sha256"] = "UNRESOLVED"
        record["file_count"] = len(record["files"])
        record["total_bytes"] = sum(item["bytes"] for item in record["files"])
    return record


def find_reference_package(reference_root, module_name):
    reference_root = os.path.abspath(reference_root)
    candidates = []
    for candidate in (
        os.path.join(reference_root, module_name),
        os.path.join(reference_root, "src", module_name),
    ):
        if os.path.isdir(candidate):
            candidates.append(os.path.abspath(candidate))
    for current, directories, unused_files in os.walk(reference_root):
        relative = os.path.relpath(current, reference_root)
        depth = 0 if relative == "." else len(relative.split(os.sep))
        if depth >= 3:
            directories[:] = []
            continue
        directories[:] = sorted(
            name for name in directories if name not in IGNORED_DIRECTORIES
        )
        for name in directories:
            if name == module_name:
                candidates.append(os.path.abspath(os.path.join(current, name)))
    candidates = sorted(set(candidates))
    if len(candidates) != 1:
        return {
            "status": "UNRESOLVED",
            "reference_root": reference_root,
            "candidates": candidates,
            "error": "expected exactly one {} package directory".format(module_name),
        }
    identity = source_tree_identity(candidates[0])
    identity["reference_root"] = reference_root
    return identity


def assign_source_identity_status(installed, references):
    if installed.get("status") != "HASHED":
        return "UNRESOLVED", []
    if set(references) != set(REFERENCE_LABELS):
        return "UNRESOLVED", []
    if any(item.get("status") != "HASHED" for item in references.values()):
        return "UNRESOLVED", []
    installed_hash = installed["aggregate_sha256"]
    matches = sorted(
        label
        for label, item in references.items()
        if item["aggregate_sha256"] == installed_hash
    )
    if len(matches) > 1:
        return "MULTIPLE_IDENTICAL_MATCHES", matches
    if matches == ["VANILLA"]:
        return "VANILLA_MATCH", matches
    if matches == ["FORK_RELEASE"]:
        return "FORK_RELEASE_MATCH", matches
    if matches == ["CANDIDATE"]:
        return "CANDIDATE_MATCH", matches
    return "NEITHER", []


def installed_source_record(
    distribution_name,
    module_name,
    package_root,
    version,
    metadata,
    reference_roots,
):
    installed = source_tree_identity(package_root)
    references = {}
    for label in REFERENCE_LABELS:
        root = reference_roots.get(label)
        if not root:
            references[label] = {
                "status": "UNRESOLVED",
                "error": "{} reference root was not supplied".format(label),
            }
        else:
            references[label] = find_reference_package(root, module_name)
    status, matches = assign_source_identity_status(installed, references)
    if status not in IDENTITY_STATUSES:
        raise AssertionError("invalid source identity status: " + status)
    return {
        "distribution": distribution_name,
        "module": module_name,
        "package_path": os.path.abspath(package_root),
        "version": version,
        "metadata": metadata,
        "installed_tree": installed,
        "references": references,
        "matching_reference_classes": matches,
        "status": status,
    }


def inspect_sitecustomize(
    interpreter,
    search_path,
    path_finder=None,
):
    search_path = list(search_path)
    candidates = []
    for entry in search_path:
        resolved = os.path.abspath(entry or os.getcwd())
        if os.path.isdir(resolved):
            candidates.extend(
                [
                    {
                        "path": os.path.join(resolved, "sitecustomize.py"),
                        "exists": os.path.isfile(
                            os.path.join(resolved, "sitecustomize.py")
                        ),
                    },
                    {
                        "path": os.path.join(
                            resolved,
                            "sitecustomize",
                            "__init__.py",
                        ),
                        "exists": os.path.isfile(
                            os.path.join(
                                resolved,
                                "sitecustomize",
                                "__init__.py",
                            )
                        ),
                    },
                ]
            )
        else:
            candidates.append(
                {
                    "path": resolved + "!/sitecustomize",
                    "exists": os.path.exists(resolved),
                    "search_entry_type": "non-directory import path entry",
                }
            )
    record = {
        "status": "UNRESOLVED",
        "interpreter": os.path.abspath(interpreter),
        "sys_path": search_path,
        "candidate_locations": candidates,
        "search_method": (
            "importlib.machinery.PathFinder.find_spec('sitecustomize', sys.path); "
            "hash spec.origin when it is a regular file"
        ),
    }
    finder = path_finder or importlib.machinery.PathFinder.find_spec
    try:
        spec = finder("sitecustomize", search_path)
    except Exception as error:
        record["error"] = "{}: {}".format(type(error).__name__, error)
        return record
    if spec is None:
        record["status"] = "VERIFIED_ABSENT"
        record["path"] = "ABSENT"
        record["sha256"] = "ABSENT"
        record["bytes"] = 0
        return record
    origin = getattr(spec, "origin", None)
    if not origin or not os.path.isfile(origin):
        record["error"] = "sitecustomize spec origin is not a regular file: {!r}".format(
            origin
        )
        return record
    try:
        record.update(
            {
                "status": "PRESENT_AND_HASHED",
                "path": os.path.abspath(origin),
                "sha256": sha256_file(origin),
                "bytes": os.path.getsize(origin),
            }
        )
    except Exception as error:
        record["error"] = "{}: {}".format(type(error).__name__, error)
    return record


def _bounded_walk(search_root, max_depth):
    search_root = os.path.abspath(search_root)
    if not os.path.isdir(search_root):
        return
    for current, directories, files in os.walk(search_root):
        relative = os.path.relpath(current, search_root)
        depth = 0 if relative == "." else len(relative.split(os.sep))
        if depth >= max_depth:
            directories[:] = []
        else:
            directories[:] = sorted(
                name for name in directories if name not in IGNORED_DIRECTORIES
            )
        yield current, sorted(files)


def inspect_classifier(search_roots, explicit_paths=None, max_depth=7):
    roots = []
    candidates_by_path = {}
    explicit_paths = list(explicit_paths or [])

    def add_candidate(path, discovery):
        absolute = os.path.abspath(path)
        if not os.path.isfile(absolute):
            return
        record = candidates_by_path.get(absolute)
        if record is None:
            record = {
                "path": absolute,
                "sha256": sha256_file(absolute),
                "bytes": os.path.getsize(absolute),
                "discovery": [],
            }
            candidates_by_path[absolute] = record
        if discovery not in record["discovery"]:
            record["discovery"].append(discovery)

    for path in explicit_paths:
        add_candidate(path, "explicit classifier path")

    for search_root in search_roots:
        absolute = os.path.abspath(search_root)
        roots.append(
            {
                "path": absolute,
                "exists": os.path.isdir(absolute),
                "readable": os.access(absolute, os.R_OK) if os.path.exists(absolute) else False,
            }
        )
        for current, files in _bounded_walk(absolute, max_depth) or ():
            for filename in files:
                lower = filename.lower()
                if (
                    "flip" in lower
                    and "classifier" in lower
                    and lower.endswith(CLASSIFIER_SUFFIXES)
                ):
                    path = os.path.join(current, filename)
                    add_candidate(path, "bounded filename search")
    candidates = sorted(candidates_by_path.values(), key=lambda item: item["path"])
    for item in candidates:
        item["discovery"].sort()
    record = {
        "status": "UNRESOLVED",
        "search_method": "bounded filename search, max depth {}".format(max_depth),
        "searched_locations": roots,
        "explicit_paths": [os.path.abspath(path) for path in explicit_paths],
        "candidates": candidates,
    }
    if len(candidates) == 1:
        record.update(candidates[0])
        record["status"] = "FOUND_AND_HASHED"
    elif not candidates:
        record["reason"] = "no classifier candidate found in bounded search locations"
        if explicit_paths:
            record["reason"] += " or explicit classifier paths"
    else:
        record["reason"] = "multiple classifier candidates require explicit adjudication"
    return record


def inspect_configurations(search_roots, explicit_paths=None, max_depth=6):
    roots = []
    files_by_path = {}
    references = []
    explicit_paths = list(explicit_paths or [])
    explicit_records = []

    def add_configuration(path, discovery):
        absolute = os.path.abspath(path)
        if not os.path.isfile(absolute):
            references.append(
                {
                    "configuration": absolute,
                    "status": "UNRESOLVED_REFERENCE",
                    "error": "configuration file is missing or not regular",
                }
            )
            return
        record = files_by_path.get(absolute)
        is_new = record is None
        if record is None:
            record = {
                "path": absolute,
                "sha256": sha256_file(absolute),
                "bytes": os.path.getsize(absolute),
                "discovery": [],
            }
            files_by_path[absolute] = record
        if discovery not in record["discovery"]:
            record["discovery"].append(discovery)
        if not is_new:
            return
        try:
            with open(
                absolute,
                "r",
                encoding="utf-8",
                errors="replace",
            ) as stream:
                for line_number, line in enumerate(stream, 1):
                    for match in CLASSIFIER_REFERENCE.finditer(line):
                        value = match.group(1)
                        referenced = (
                            value
                            if os.path.isabs(value)
                            else os.path.abspath(
                                os.path.join(os.path.dirname(absolute), value)
                            )
                        )
                        reference = {
                            "configuration": absolute,
                            "line": line_number,
                            "reference": referenced,
                            "status": "UNRESOLVED_REFERENCE",
                        }
                        if os.path.isfile(referenced):
                            reference.update(
                                {
                                    "status": "REFERENCED_FILE_HASHED",
                                    "sha256": sha256_file(referenced),
                                    "bytes": os.path.getsize(referenced),
                                }
                            )
                        references.append(reference)
        except Exception as error:
            references.append(
                {
                    "configuration": absolute,
                    "status": "UNRESOLVED_REFERENCE",
                    "error": "{}: {}".format(type(error).__name__, error),
                }
            )

    for path in explicit_paths:
        absolute = os.path.abspath(path)
        explicit_records.append(absolute)
        add_configuration(absolute, "explicit load-bearing configuration")

    for search_root in search_roots:
        absolute = os.path.abspath(search_root)
        roots.append(
            {
                "path": absolute,
                "exists": os.path.isdir(absolute),
                "readable": os.access(absolute, os.R_OK) if os.path.exists(absolute) else False,
            }
        )
        for current, filenames in _bounded_walk(absolute, max_depth) or ():
            for filename in filenames:
                if not filename.lower().endswith(CONFIG_SUFFIXES):
                    continue
                path = os.path.join(current, filename)
                add_configuration(path, "bounded configuration extension search")
    files = sorted(files_by_path.values(), key=lambda item: item["path"])
    for item in files:
        item["discovery"].sort()
    references.sort(
        key=lambda item: (
            item.get("configuration", ""),
            item.get("line", 0),
            item.get("reference", ""),
        )
    )
    unresolved = [
        item for item in references if item["status"] == "UNRESOLVED_REFERENCE"
    ]
    status = "BOUNDED_HASHED"
    reason = ""
    if not explicit_records:
        status = "UNRESOLVED"
        reason = "no explicit load-bearing configuration files were supplied"
    elif not files:
        status = "UNRESOLVED"
        reason = "no configuration files found in bounded search locations"
    elif unresolved:
        status = "UNRESOLVED"
        reason = "one or more configuration references are unresolved"
    return {
        "status": status,
        "reason": reason,
        "comprehensive_custody_claimed": False,
        "scope": "only explicitly supplied and documented bounded search roots",
        "search_method": "bounded extension search, max depth {}".format(max_depth),
        "searched_locations": roots,
        "explicit_load_bearing_paths": explicit_records,
        "files": files,
        "references": references,
        "unresolved_references": unresolved,
    }


def write_json(path, value):
    with open(path, "w") as stream:
        json.dump(value, stream, indent=2, sort_keys=True)
        stream.write("\n")
