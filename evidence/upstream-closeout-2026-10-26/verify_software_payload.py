"""Read-only software-evidence integrity check; never imports MoSeq packages."""
from collections import Counter
import hashlib
import json
from pathlib import Path, PurePosixPath
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent
evidence = root.parent
manifest = evidence / "UPSTREAM_CLOSEOUT_2026-10-26.sha256"
expected = {}
for line in manifest.read_text(encoding="utf-8").splitlines():
    digest, name = line.split("  ", 1)
    member = PurePosixPath(name)
    assert not member.is_absolute() and ".." not in member.parts
    assert name not in expected
    assert member.parts[0] == root.name
    expected[name] = digest
actual = {path.relative_to(evidence).as_posix() for path in root.rglob("*") if path.is_file()}
assert set(expected) == actual, (set(expected) - actual, actual - set(expected))
for name, digest in expected.items():
    path = evidence / name
    assert not path.is_symlink()
    assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, name
crosswalk = json.loads((root / "FINDING_CROSSWALK.json").read_text(encoding="utf-8"))
assert Counter(row["disposition"] for row in crosswalk["findings"]) == crosswalk["counts"]
assert len(crosswalk["findings"]) == 91
assert len(json.loads((root / "HISTORICAL_SYMBOL_COVERAGE.json").read_text(encoding="utf-8"))) == 40
inventory = json.loads((root / "APP_STRICT_XFAIL_INVENTORY.json").read_text(encoding="utf-8"))
assert len(inventory["rows"]) == 20
qualifications = json.loads((root / "SOFTWARE_QUALIFICATION.json").read_text(encoding="utf-8"))
assert len(qualifications) == 51
assert sum(row["candidate"]["tests"] for row in qualifications) == 67
for row in qualifications:
    assert row["baseline"]["failures"] > 0
    assert row["candidate"]["exit_code"] == 0 and row["candidate"]["skipped"] == 0
    cases = list(ET.parse(root / "regressions" / row["id"] / "candidate.xml").iter("testcase"))
    assert len(cases) == row["candidate"]["tests"]
    assert not any(case.find("failure") is not None or case.find("error") is not None for case in cases)
print(json.dumps({"status": "PASS_SOFTWARE_CLOSEOUT_PAYLOAD", "members": len(actual),
                  "topics": 91, "qualified_branches": 51, "candidate_cases": 67,
                  "scientific_validation_claim": False}))
