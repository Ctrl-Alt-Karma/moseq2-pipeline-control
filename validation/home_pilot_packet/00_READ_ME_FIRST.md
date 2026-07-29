# MoSeq2 Legacy Preservation and Home Pilot

This packet is for Katya's existing WSL2 Ubuntu 22.04 environment only:
Python 3.7 and NumPy 1.18.3 in `/home/ajm/miniforge3`, Conda environment
`moseq2-app`.

The study's supported production target is frozen. Modernization, Python
migration, NumPy upgrades, and cross-environment equivalence work are out of
scope.

No script modifies an existing Conda environment or an existing source
directory. No script installs, upgrades, or removes a package. Locked source is
cloned into a new directory under `/home/ajm`. Every processing script writes
only to a new validation output directory and refuses overwrite.

There is deliberately no automatic run-all command. The WSL export is always a
separate, explicit Windows PowerShell action.

## Locked candidate source

| Repository | Exact detached commit |
|---|---|
| extract | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| viz | `b80192dc20353bf77c36610f315543b57afa908c` |
| app | `e0b85201226d03e15944473a734f71417698c31e` |
| pca | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| model | `6e542e3f1db125202d42b59f390c922281e64f39` |

## Script classes

Inspection-only:

- `00_export_wsl_backup.ps1`: inventories WSL and exports a distribution; it
  reads the distribution and creates a Windows-side archive but never alters,
  unregisters, replaces, or deletes a distribution.
- `01_freeze_legacy_environment.sh`: records the active environment, dependency
  custody, classifier custody, and active `sitecustomize.py`; it changes
  nothing in Conda or installed packages.
- `05_inventory_real_recordings.sh`: creates a read-only recording manifest and
  recommendation; it does not process recordings.

Qualification tests using only new validation outputs:

- `02_prepare_locked_worktrees.sh`: creates isolated clones at exact commit
  SHAs and generates `locked_source.env`; it does not install them.
- `03_run_legacy_candidate_tests.sh`: runs the real provenance chain, targeted
  tests, and seven cross-repository checks.
- `04_run_synthetic_pipeline.sh`: runs the bounded synthetic pipeline through
  real production writers/loaders.

Real-data processing:

- `06_run_approved_real_pilot.sh`: the only real-data processing script. It
  requires both an explicit recording path and
  `--confirm RUN_APPROVED_REAL_PILOT`.

Packaging:

- `collect_evidence.sh`: packages evidence and hashes it. Raw recording bytes
  and HDF5/video payloads are excluded unless explicitly requested.

## Batch 1 — preserve the WSL distribution

1. Open Windows PowerShell, not a WSL shell.
2. Run `00_export_wsl_backup.ps1` with an explicit destination that has at
   least 20 GiB free.
3. Copy the resulting TAR and JSON receipt to a second storage device when
   practical.

Do not put this backup command into a batch file or run-all wrapper.

## Batch 2 — freeze the environment and source

1. Open Ubuntu 22.04 in WSL and `cd` to this packet.
2. Run `bash 01_freeze_legacy_environment.sh`.
3. Run `bash 02_prepare_locked_worktrees.sh`.

The first command is inspection-only. The second writes isolated clones under
`/home/ajm/moseq2-legacy-validation/worktrees`.

## Batch 3 — qualification

1. Run `bash 03_run_legacy_candidate_tests.sh`.
2. Review every raw exit code and failure classification.
3. Only if no unexplained blocker remains, run
   `bash 04_run_synthetic_pipeline.sh`.

Expected fixture failures remain visible. Nothing converts a failure to a pass.

## Batch 4 — real-data inventory

1. Run `bash 05_inventory_real_recordings.sh`.
2. Review `recording_recommendation.md`.
3. Record the approved recording, extraction config, classifier, and PCA
   components before continuing.

This batch reads OneDrive-mounted data through `/mnt/c`; it writes only the
manifest under `/home/ajm/moseq2-legacy-validation`.

## Batch 5 — explicitly approved pilot

1. Read `06_run_approved_real_pilot.sh --help`.
2. Run it with the approved recording path, config, PCA components, and the
   exact confirmation flag.
3. Inspect stage receipts before considering any repeatability work.

The script never starts a model fit. It ends after producing and validating
model-input handoff data.

## Batch 6 — package evidence

1. Run `bash collect_evidence.sh`.
2. Verify the generated ZIP SHA-256 receipt.
3. Send the verifier ZIP to Fable without adding raw recording data.

The packet manifest `SHA256SUMS.txt` authenticates every other packet file; the
manifest necessarily excludes itself. The delivered ZIP has a separate
SHA-256 receipt.

Facts that can only be resolved on Katya's machine are listed in
`KNOWN_RUNTIME_DISCOVERIES.md`. The full Fable environment audit and custody
record are under `evidence/`.
