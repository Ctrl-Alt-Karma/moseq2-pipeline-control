# Packet Static Validation

Date: 2026-07-29

Checks run on the work computer:

- `bash -n`: passed for all eight shell files, including `lib/common.sh`;
- each user-facing shell script's `--help` path: passed;
- PowerShell AST parser: passed for `00_export_wsl_backup.ps1`;
- Python 3.7 grammar parse: passed for all packet Python files;
- JSON parse: passed for the Fable custody manifest;
- YAML parse: passed for `repositories/repos.lock.yaml`;
- destructive/install command scan: passed;
- `git diff --check`: passed;
- verbatim Fable audit SHA-256 and byte count: passed;
- packet copies of the seven-contract source, real provenance-chain source, and
  lock file: byte-identical to the control source;
- `helpers/summarize_pytest.py`: live-checked against the seven contract tests
  and reported 7 collected, 7 passed, 0 failed/skipped/deselected/blocked;
- `helpers/inventory_recordings.py`: bounded dry run passed;
- `helpers/inspect_legacy_environment.py`: disposable-environment dry run
  passed, including the `pkg_resources`-absent fallback and explicit
  unresolved dependency records;
- `helpers/collect_evidence.py`: bounded dry run produced a readable ZIP;
- `06_run_approved_real_pilot.sh`: refused before output when confirmation was
  absent.

Optional analyzers `shellcheck` and PSScriptAnalyzer were not installed.

WSL is not installed on the work computer. The backup script was therefore
verified to stop at WSL inventory failure before creating its destination; an
actual `wsl --export` was not and could not be run here.

No production script was executed against Katya's environment or recordings.
Those runtime results remain home-machine evidence, not static claims.
