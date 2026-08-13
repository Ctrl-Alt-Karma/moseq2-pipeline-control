# Reusable-Root Corrected Packet Static Validation

Date: 2026-07-30

These checks were run on the Windows control-repository worktree. WSL was not
invoked. Scripts 01 and 02 were not run against the golden environment or any
real validation root. No package, scientific repository, or scientific data
was changed or inspected.

## Validation results

- Shell syntax: all 14 packet shell files passed `bash -n` using Git Bash,
  explicitly not the Windows WSL launcher.
- PowerShell static parse: both packet `.ps1` files passed the Windows
  PowerShell AST parser. Existing destructive-action scans remain clean.
- Python 3.7 grammar: all 14 packet Python files parsed with Python 3.7 grammar.
- Root-lifecycle regression: a synthetic Phase-0-initialized root was accepted;
  an arbitrary existing root, prior worktree state, and prior receipt state
  were rejected. The old “script 02 requires the root not to exist” behavior
  failed its negative control.
- Evidence-identity regression: deterministic source hashing and all six source
  identity statuses passed against synthetic trees.
- Sitecustomize regression: `PRESENT_AND_HASHED`, `VERIFIED_ABSENT`, and
  `UNRESOLVED` passed.
- Classifier regression: unresolved custody retained every bounded search
  location.
- Configuration regression: bounded discovery without an explicit
  load-bearing configuration remained `UNRESOLVED`; explicit custody was
  hashed without a comprehensive-custody claim.
- Credential-leak regression: four dummy credential-shaped variables were
  injected. None of their names or values appeared in three generated process
  environment records, the collected-evidence tree, or any filename or payload
  in the final evidence ZIP.
- Fabricated preflight mismatch: returned nonzero, emitted `MISMATCH`, and did
  not become `VERIFIED`.
- Internal packet SHA-256 manifest: regenerated and independently verified.
- `git diff --check`: passed.

## Controls confirmed

- Script 01 alone initializes a new versioned validation root.
- Script 02 accepts only the same root with the current packet-manifest marker,
  a structurally valid `COMPLETE` Phase 0 receipt, and a verified Phase 0
  manifest. It refuses unknown root state and any partial or repeated
  script-02 target.
- Later home-pilot phases require that explicit root, validate their prerequisite
  receipt, keep output beneath the root, and refuse overwrite.
- Installed `moseq2-*` package identity comes from per-file SHA-256 records and
  deterministic aggregate source-tree hashes, not versions.
- A conclusively absent `sitecustomize.py` is `VERIFIED_ABSENT` with the
  interpreter, `sys.path`, candidate locations, and search method retained.
- Classifier custody is exactly `FOUND_AND_HASHED` or `UNRESOLVED`.
- Configuration custody is explicitly bounded and fail-closed.
- The five locked candidate SHAs are unchanged.
