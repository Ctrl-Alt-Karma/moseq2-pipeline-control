#!/usr/bin/env python
"""Create an exact per-test/status manifest from pytest collection and JUnit."""

from __future__ import print_function

import argparse
import glob
import os
import re
import xml.etree.ElementTree as ET


def read_text(path):
    with open(path, "r") as stream:
        return stream.read()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-dir", required=True)
    args = parser.parse_args()
    run_dir = os.path.abspath(args.run_dir)
    suites_dir = os.path.join(run_dir, "suites")

    rows = [
        "suite\tcollected_node\toutcome\tclassification\tmessage"
    ]
    summary = []
    for suite_path in sorted(glob.glob(os.path.join(suites_dir, "*"))):
        if not os.path.isdir(suite_path):
            continue
        suite = os.path.basename(suite_path)
        collect_stdout = os.path.join(suite_path, "collect.stdout.txt")
        collect_stderr = os.path.join(suite_path, "collect.stderr.txt")
        test_stdout = os.path.join(suite_path, "test.stdout.txt")
        junit_path = os.path.join(suite_path, "junit.xml")
        nodes = []
        if os.path.isfile(collect_stdout):
            for line in read_text(collect_stdout).splitlines():
                value = line.strip()
                if "::" in value and not value.startswith(("ERROR", "=")):
                    nodes.append(value)

        outcomes = {}
        if os.path.isfile(junit_path):
            root = ET.parse(junit_path).getroot()
            for case in root.iter("testcase"):
                classname = case.attrib.get("classname", "")
                name = case.attrib.get("name", "")
                node = "{}::{}".format(classname.replace(".", "/"), name)
                status = "PASSED"
                classification = "EXECUTED"
                message = ""
                for tag, mapped in (
                    ("failure", "FAILED"),
                    ("error", "BLOCKED"),
                    ("skipped", "SKIPPED"),
                ):
                    child = case.find(tag)
                    if child is not None:
                        status = mapped
                        classification = (
                            "COLLECTION_OR_EXECUTION_ERROR"
                            if mapped == "BLOCKED"
                            else "EXECUTED"
                        )
                        message = child.attrib.get("message", "") or (child.text or "")
                        break
                outcomes[(classname, name)] = (status, classification, message)

        matched = set()
        counts = {
            "COLLECTED": len(nodes),
            "PASSED": 0,
            "FAILED": 0,
            "SKIPPED": 0,
            "DESELECTED": 0,
            "BLOCKED": 0,
        }
        for node in nodes:
            leaf = node.split("::")[-1]
            candidates = [
                value for key, value in outcomes.items() if key[1] == leaf
            ]
            if len(candidates) == 1:
                status, classification, message = candidates[0]
                matched.add(leaf)
            else:
                status = "BLOCKED"
                classification = "NO_JUNIT_RESULT"
                message = "No unique JUnit result for collected node"
            counts[status] = counts.get(status, 0) + 1
            rows.append(
                "{}\t{}\t{}\t{}\t{}".format(
                    suite,
                    node,
                    status,
                    classification,
                    " ".join(message.split())[:1000],
                )
            )

        combined = ""
        for path in (collect_stdout, collect_stderr, test_stdout):
            if os.path.isfile(path):
                combined += "\n" + read_text(path)
        deselected = re.findall(r"(\d+)\s+deselected", combined)
        counts["DESELECTED"] = sum(int(value) for value in deselected)

        if not nodes:
            counts["BLOCKED"] += 1
            rows.append(
                "{}\t<collection>\tBLOCKED\tCOLLECTION_FAILED\tNo test nodes collected".format(
                    suite
                )
            )
        summary.append(
            "{}\t{}".format(
                suite,
                "\t".join(
                    "{}={}".format(key, counts[key])
                    for key in (
                        "COLLECTED",
                        "PASSED",
                        "FAILED",
                        "SKIPPED",
                        "DESELECTED",
                        "BLOCKED",
                    )
                ),
            )
        )

    with open(os.path.join(run_dir, "TEST_OUTCOMES.tsv"), "w") as stream:
        stream.write("\n".join(rows) + "\n")
    with open(os.path.join(run_dir, "TEST_COUNTS.txt"), "w") as stream:
        stream.write("\n".join(summary) + "\n")


if __name__ == "__main__":
    main()
