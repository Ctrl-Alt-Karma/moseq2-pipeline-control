#!/usr/bin/env python
"""Synthetic regression tests for Phase 0 evidence state machines."""

from __future__ import print_function

import os
import shutil
import sys
import tempfile
import unittest


PACKET_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
sys.path.insert(0, os.path.join(PACKET_ROOT, "helpers"))

from evidence_identity import (  # noqa: E402
    assign_source_identity_status,
    inspect_classifier,
    inspect_configurations,
    inspect_sitecustomize,
    source_tree_identity,
)


class Spec(object):
    def __init__(self, origin):
        self.origin = origin


class EvidenceIdentityTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.mkdtemp(prefix="moseq-evidence-identity-")

    def tearDown(self):
        shutil.rmtree(self.temporary)

    def tree(self, name, payload):
        root = os.path.join(self.temporary, name)
        os.makedirs(os.path.join(root, "nested"))
        with open(os.path.join(root, "__init__.py"), "w") as stream:
            stream.write(payload)
        with open(os.path.join(root, "nested", "module.py"), "w") as stream:
            stream.write("value = {!r}\n".format(payload))
        return root

    def test_source_hashing_is_deterministic(self):
        first = self.tree("first", "same")
        second = self.tree("second", "same")
        first_identity = source_tree_identity(first)
        second_identity = source_tree_identity(second)
        self.assertEqual(first_identity["status"], "HASHED")
        self.assertEqual(
            first_identity["aggregate_sha256"],
            source_tree_identity(first)["aggregate_sha256"],
        )
        self.assertEqual(
            first_identity["aggregate_sha256"],
            second_identity["aggregate_sha256"],
        )
        self.assertEqual(
            [item["relative_path"] for item in first_identity["files"]],
            ["__init__.py", "nested/module.py"],
        )

    def test_all_source_identity_statuses(self):
        installed = source_tree_identity(self.tree("installed", "installed"))
        same = source_tree_identity(self.tree("same", "installed"))
        other_a = source_tree_identity(self.tree("other-a", "a"))
        other_b = source_tree_identity(self.tree("other-b", "b"))
        other_c = source_tree_identity(self.tree("other-c", "c"))

        cases = (
            (
                "VANILLA_MATCH",
                {"VANILLA": same, "FORK_RELEASE": other_a, "CANDIDATE": other_b},
            ),
            (
                "FORK_RELEASE_MATCH",
                {"VANILLA": other_a, "FORK_RELEASE": same, "CANDIDATE": other_b},
            ),
            (
                "CANDIDATE_MATCH",
                {"VANILLA": other_a, "FORK_RELEASE": other_b, "CANDIDATE": same},
            ),
            (
                "MULTIPLE_IDENTICAL_MATCHES",
                {"VANILLA": same, "FORK_RELEASE": same, "CANDIDATE": other_a},
            ),
            (
                "NEITHER",
                {
                    "VANILLA": other_a,
                    "FORK_RELEASE": other_b,
                    "CANDIDATE": other_c,
                },
            ),
            (
                "UNRESOLVED",
                {
                    "VANILLA": same,
                    "FORK_RELEASE": {"status": "UNRESOLVED"},
                    "CANDIDATE": other_a,
                },
            ),
        )
        for expected, references in cases:
            status, unused_matches = assign_source_identity_status(
                installed,
                references,
            )
            self.assertEqual(status, expected)

    def test_sitecustomize_present(self):
        path = os.path.join(self.temporary, "sitecustomize.py")
        with open(path, "w") as stream:
            stream.write("value = 1\n")
        record = inspect_sitecustomize(
            sys.executable,
            [self.temporary],
            path_finder=lambda unused_name, unused_path: Spec(path),
        )
        self.assertEqual(record["status"], "PRESENT_AND_HASHED")
        self.assertEqual(record["path"], os.path.abspath(path))
        self.assertEqual(len(record["sha256"]), 64)

    def test_sitecustomize_verified_absent(self):
        record = inspect_sitecustomize(
            sys.executable,
            [self.temporary],
            path_finder=lambda unused_name, unused_path: None,
        )
        self.assertEqual(record["status"], "VERIFIED_ABSENT")
        self.assertEqual(record["interpreter"], os.path.abspath(sys.executable))
        self.assertEqual(record["sys_path"], [self.temporary])
        self.assertTrue(record["candidate_locations"])
        self.assertIn("PathFinder.find_spec", record["search_method"])

    def test_sitecustomize_unresolved(self):
        def fail(unused_name, unused_path):
            raise OSError("synthetic search failure")

        record = inspect_sitecustomize(
            sys.executable,
            [self.temporary],
            path_finder=fail,
        )
        self.assertEqual(record["status"], "UNRESOLVED")
        self.assertIn("synthetic search failure", record["error"])

    def test_classifier_unresolved_records_search_locations(self):
        missing = os.path.join(self.temporary, "missing")
        record = inspect_classifier([self.temporary, missing])
        self.assertEqual(record["status"], "UNRESOLVED")
        self.assertEqual(
            [item["path"] for item in record["searched_locations"]],
            [os.path.abspath(self.temporary), os.path.abspath(missing)],
        )
        self.assertIn("bounded search locations", record["reason"])

    def test_classifier_explicit_path_is_hashed(self):
        classifier = os.path.join(self.temporary, "study-classifier.pkl")
        with open(classifier, "wb") as stream:
            stream.write(b"synthetic classifier")
        record = inspect_classifier(
            [self.temporary],
            explicit_paths=[classifier],
        )
        self.assertEqual(record["status"], "FOUND_AND_HASHED")
        self.assertEqual(record["path"], os.path.abspath(classifier))
        self.assertEqual(len(record["sha256"]), 64)

    def test_configuration_custody_requires_explicit_load_bearing_file(self):
        discovered = os.path.join(self.temporary, "discovered.json")
        with open(discovered, "w") as stream:
            stream.write("{}\n")
        unresolved = inspect_configurations([self.temporary])
        self.assertEqual(unresolved["status"], "UNRESOLVED")
        self.assertFalse(unresolved["comprehensive_custody_claimed"])
        self.assertIn("no explicit load-bearing", unresolved["reason"])

        resolved = inspect_configurations(
            [self.temporary],
            explicit_paths=[discovered],
        )
        self.assertEqual(resolved["status"], "BOUNDED_HASHED")
        self.assertEqual(
            resolved["explicit_load_bearing_paths"],
            [os.path.abspath(discovered)],
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
