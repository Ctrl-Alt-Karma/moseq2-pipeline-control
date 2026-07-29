# Packet Static Validation

Date: 2026-07-29

Checks run on the work computer:

- `bash -n`: passed for all twelve shell files, including the four deployment
  shell entry points;
- each user-facing shell script's `--help` path: passed;
- PowerShell AST parser: passed for `00_export_wsl_backup.ps1` and
  `deployment/import_golden_wsl.ps1`;
- Python 3.7 grammar parse: passed for all twelve packet Python files;
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
- all four deployment shell entry points refused empty invocations before
  creating output or changing state;
- `deployment/validate_deployment_static.py`: passed required-control and
  floating/destructive-command assertions;
- a fabricated impossible deployment lock produced a nonzero preflight result
  with `MISMATCH`; no mismatch was downgraded to a warning or `VERIFIED`;
- executable deployment scripts contain no WSL unregister, `Remove-Item`,
  Conda update/in-place install, pip upgrade, or floating main/master checkout
  command;
- the WSL import helper's PowerShell-to-Bash literal quoting passed paths with
  spaces and operator names containing an apostrophe;
- `git diff --check`: passed after deployment additions.

Optional analyzers `shellcheck` and PSScriptAnalyzer were not installed.

WSL is not installed on the work computer. The backup script was therefore
verified to stop at WSL inventory failure before creating its destination; an
actual `wsl --export` was not and could not be run here.

No production script was executed against Katya's environment or recordings.
Those runtime results remain home-machine evidence, not static claims.

The offline environment export, isolated-environment bootstrap, WSL import,
known-answer production-path run, and guarded pipeline launcher were not
executed on the work computer. Static success does not qualify this machine.
The exact package artifacts, Git dependency commits, classifier,
`sitecustomize.py`, configurations, and golden expected hashes can only be
collected later from Katya's home WSL environment.
