# Corrected Packet Static Validation

Date: 2026-07-29

These checks were run against the corrected control-repository packet. No WSL
backup, environment freeze, machine bootstrap, scientific candidate test,
real-data processing, or production-repository command was run.

## Required correction checks

- Shell syntax/static validation: `bash -n` passed for all 13 shell files,
  including the executable credential-leak regression test.
- Complete environment-capture scan: passed. No packet script uses an
  unrestricted process `env`, `printenv`, `dict(os.environ)`,
  `os.environ.copy()`, or PowerShell environment-provider dump.
- PowerShell static validation: the Windows PowerShell AST parser accepted
  both packet `.ps1` files; command-AST and invocation scans found no
  `Remove-Item`, `Stop-Process`, `Stop-Computer`, WSL `--terminate`,
  `--shutdown`, or `--unregister` action.
- Python 3.7 grammar validation: all 12 packet Python files parsed with Python
  3.7 grammar.
- `deployment/validate_deployment_static.py`: passed the allowlist, stopped-WSL
  state, new-validation-root, deployment contract, and destructive/floating
  reference assertions.
- Fabricated preflight mismatch: passed. An impossible deployment lock
  returned nonzero, produced `MISMATCH`, and was not downgraded to a warning or
  `VERIFIED`.
- Credential-leak regression: passed after injecting four dummy
  credential-shaped variables. It scanned three generated
  process-environment records, the complete collected-evidence staging tree,
  and every filename and payload in the final evidence ZIP. No injected name
  or value was present.
- Internal SHA-256 manifest: regenerated for every corrected packet file other
  than `SHA256SUMS.txt` itself and verified independently.
- Locked candidate SHAs: all five hard-coded values remain byte-for-byte
  unchanged in `02_prepare_locked_worktrees.sh` and both lock-file copies.
- `git diff --check`: passed.

## Controls confirmed statically

- `write_process_environment` records only the explicit 16-variable safe
  allowlist and writes `<UNSET>` for every missing allowlisted variable.
- `00_export_wsl_backup.ps1` accepts export only when the exact requested
  distribution reports `Stopped`. It fails clearly for `Running`, never stops
  or unregisters WSL, preserves the no-overwrite/free-space checks, and retains
  any partial archive.
- `02_prepare_locked_worktrees.sh` requires an explicit new root below
  `/home/ajm`, rejects every existing root and receipt path, and retains exact
  detached-SHA verification.
- The first three PowerShell commands explicitly create and resolve
  `C:\Users\AJM\Documents\MoSeq2-WSL-Backups`, display it, reject a OneDrive
  component, and pass the explicit destination and `Ubuntu-22.04` to the
  backup script.

The independently observed golden-machine values are recorded in
`evidence/GOLDEN_MACHINE_PREFLIGHT_2026-07-29.md`. WSL state and free space are
point-in-time values; the backup script must recheck them when AJ later runs
the export after verifier approval.
