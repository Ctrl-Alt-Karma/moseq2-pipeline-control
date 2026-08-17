# MoSeq2 Legacy Preservation and Home Pilot

Katya's existing WSL2 Ubuntu 22.04 environment is the golden reference:
Python 3.7 and NumPy 1.18.3 in `/home/ajm/miniforge3`, Conda environment
`moseq2-app`.

## Independently verified golden-machine preflight

The following values were confirmed by read-only inspection on 2026-07-29:

| Check | Verified value |
|---|---|
| Windows user | `AJM_LAPTOP\AJM` |
| WSL distribution | `Ubuntu-22.04` |
| WSL state during inspection | `Stopped` |
| WSL version | `2.7.11.0` |
| Ubuntu | `22.04.5 LTS` |
| Linux user | `ajm` |
| Linux home | `/home/ajm` |
| Miniforge | `/home/ajm/miniforge3` |
| Conda environment | `moseq2-app` |
| Conda prefix | `/home/ajm/miniforge3/envs/moseq2-app` |
| Python | `3.7.12` |
| NumPy | `1.18.3` |
| Confirmed local non-OneDrive backup root | `C:\Users\AJM\Documents` |
| Available C: space observed | `549915922432` bytes |

The WSL state and free-space values are observations, not permanent facts.
`00_export_wsl_backup.ps1` must recheck both immediately before export. The
full preflight record is in
`evidence/GOLDEN_MACHINE_PREFLIGHT_2026-07-29.md`.

The home computer is the preservation and pilot host; it is not assumed to be
the computer that will run the full analysis. A separate analysis machine is
supported only after exact offline deployment or verified WSL import and its
own fail-closed qualification.

The study's supported production target is frozen. Modernization, Python
migration, NumPy upgrades, and cross-environment equivalence work are out of
scope.

No script modifies an existing Conda environment or an existing source
directory. Home preservation and pilot scripts install nothing. The future
deployment bootstrap may install only into a new, explicitly named, isolated
environment from a complete exact offline lock; it refuses an existing name or
directory. Script 01 creates one explicit validation root below `/home/ajm`.
Every later home-pilot phase reuses that exact root only after validating its
packet marker, required prior-phase receipt, and internal manifest. Each phase
creates new child paths and refuses unknown, partial, repeated, or conflicting
state.

There is deliberately no automatic run-all command. The WSL export is always a
separate, explicit Windows PowerShell action.

This correction is delivered as
`MOSEQ_LEGACY_HOME_PILOT_REUSABLE_ROOT_CORRECTED_2026-07-30.zip`. It is a
distinct artifact and does not overwrite or replace either prior packet
archive.

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
  custody, deterministic installed MoSeq source identity, classifier and
  bounded configuration custody, and explicit `sitecustomize.py` state; it
  changes nothing in Conda or installed packages.
- `05_inventory_real_recordings.sh`: creates a read-only recording manifest and
  recommendation; it does not process recordings.

Qualification tests using only new validation outputs:

- `02_prepare_locked_worktrees.sh`: accepts only a complete
  Phase-0-initialized root, creates isolated clones at exact commit SHAs, and
  generates `locked_source.env`; it does not install them.
- `03_run_legacy_candidate_tests.sh`: runs the real provenance chain, targeted
  tests, and seven cross-repository checks.
- `04_run_synthetic_pipeline.sh`: runs the bounded synthetic pipeline through
  real production writers/loaders.

Real-data processing:

- `06_run_approved_real_pilot.sh`: the only real-data processing script. It
  requires a frozen run specification, explicit recording/PCA/model paths, and
  `--confirm RUN_APPROVED_REAL_PILOT`. It checks expected versus observed
  recording, PCA, and production-model SHA-256 values before scientific work,
  then applies the frozen model held-out. It never fits or adapts a model.

Packaging:

- `collect_evidence.sh`: packages evidence and hashes it. Raw recording bytes
  and HDF5/video payloads are excluded unless explicitly requested.

Golden-reference deployment export:

- `deployment/export_offline_environment_bundle.sh`: inspection/export only on
  the golden WSL. It copies exact records, approved cache artifacts, custody
  files, and Git bundles without altering the environment. Any unresolved
  requirement leaves the bundle `INCOMPLETE`.

Future-machine provisioning and qualification:

- `deployment/bootstrap_qualified_machine.sh`: installs only into a new
  isolated environment from a `COMPLETE` offline lock. Do not run it on the
  home machine merely to test it.
- `deployment/preflight_environment.py`: returns nonzero for every
  `UNRESOLVED` or `MISMATCH` exact-identity check.
- `deployment/run_known_answer_qualification.sh`: establishes the golden
  synthetic baseline or verifies a future machine through real production
  paths.
- `deployment/run_pipeline_guarded.sh`: the documented production entry point;
  it refuses an unqualified machine and embeds the fingerprint in analysis
  output.
- `deployment/import_golden_wsl.ps1`: imports a verified golden archive under a
  new distribution name and runs the same qualification. It never overwrites
  or unregisters another distribution.

The binding rules are in `deployment/DEPLOYMENT_CONTRACT.md`. Approximate
version matches are not accepted.

## Batch 1 — preserve the WSL distribution

1. Open Windows PowerShell, not a WSL shell.
2. Follow `FIRST_THREE_POWERSHELL_COMMANDS.md` exactly. Those commands expand
   the corrected packet, explicitly create
   `C:\Users\AJM\Documents\MoSeq2-WSL-Backups`, resolve and display the final
   path, reject any OneDrive component, and call `00_export_wsl_backup.ps1`
   with `Ubuntu-22.04`.
3. The export script must report that `Ubuntu-22.04` is `Stopped`; it never
   stops, terminates, shuts down, or unregisters a distribution.
4. Copy the resulting TAR and JSON receipt to a second storage device when
   practical.

Do not put this backup command into a batch file or run-all wrapper.

## Batch 2 — freeze the environment and source

1. Open Ubuntu 22.04 in WSL and `cd` to this packet.
2. Choose one explicit path that does not exist, then run script 01 with all
   bounded custody and source references:

   ```bash
   VALIDATION_ROOT=/home/ajm/moseq2-legacy-validation-YYYYMMDDTHHMMSSZ
   bash 01_freeze_legacy_environment.sh \
     --root "${VALIDATION_ROOT}" \
     --project-root /EXACT/BOUNDED/STUDY/PROJECT \
     --configuration-file /EXACT/LOAD_BEARING/config.yaml \
     --classifier-file /EXACT/LOAD_BEARING/flip-classifier.pkl \
     --vanilla-root /EXACT/PINNED/VANILLA/ROOT \
     --fork-release-root /EXACT/PINNED/FORK_RELEASE/ROOT \
     --candidate-root /EXACT/PINNED/CANDIDATE/ROOT
   ```

3. Review `PHASE0_FREEZE_RECEIPT.txt`; proceed only when `status=COMPLETE`.
4. Reuse the same shell variable:

   ```bash
   bash 02_prepare_locked_worktrees.sh --root "${VALIDATION_ROOT}"
   ```

Script 01 alone may initialize the root. Script 02 requires the versioned root
marker, a structurally valid complete Phase 0 receipt, and a verified Phase 0
manifest. It rejects arbitrary directories, unknown root entries, existing
worktrees or receipts, and every partial or repeated script-02 state. Keep the
exact `VALIDATION_ROOT`: every later home-pilot and golden-reference deployment
command must receive it through `--root`.

Phase 0 source identity is derived from deterministic file hashes, never
version labels. Each installed `moseq2-*` distribution receives exactly one of
`VANILLA_MATCH`, `FORK_RELEASE_MATCH`, `CANDIDATE_MATCH`,
`MULTIPLE_IDENTICAL_MATCHES`, `NEITHER`, or `UNRESOLVED`.
`sitecustomize.py` receives exactly one of `PRESENT_AND_HASHED`,
`VERIFIED_ABSENT`, or `UNRESOLVED`. Classifier custody is
`FOUND_AND_HASHED` or `UNRESOLVED`; unresolved classifier evidence lists every
bounded search location. Configuration evidence hashes only discovered,
referenced, or load-bearing files, records unresolved references, and never
claims comprehensive custody from a bounded search.

## Batch 3 — qualification

1. Run `bash 03_run_legacy_candidate_tests.sh --root "${VALIDATION_ROOT}"`.
2. Review every raw exit code and failure classification.
3. Only if no unexplained blocker remains, run
   `bash 04_run_synthetic_pipeline.sh --root "${VALIDATION_ROOT}"`.

Expected fixture failures remain visible. Nothing converts a failure to a pass.

## Batch 4 — real-data inventory

1. Run `bash 05_inventory_real_recordings.sh --root "${VALIDATION_ROOT}"`.
2. Review `recording_recommendation.md`.
3. Record the approved recording, extraction config, classifier, PCA
   components, and frozen production-model identity before continuing.
4. Create the session run specification from
   `real_session_run_spec.example.json`; bind the exact approved recording
   SHA-256 rather than inferring it at run time.

This batch reads OneDrive-mounted data through `/mnt/c`; it writes only the
manifest under the new validation root.

## Batch 5 — explicitly approved pilot

1. Read `06_run_approved_real_pilot.sh --help`.
2. Run it with `--root "${VALIDATION_ROOT}"`, the frozen run specification,
   approved recording path, config, classifier, PCA components, frozen
   production-model path, and the exact confirmation flag.
3. Inspect stage receipts before considering any repeatability work.

The script fails before scientific processing if the run-spec path or hash
bindings do not match. On success it performs extraction, PCA projection, and
held-out `moseq2-model apply-model` with stored production-model whitening/model
parameters. It never starts fitting, refitting, or adaptation.

## Sealed R1 full-session operator (R3)

`08_run_r1_full_session_validation.sh` is the distinct whole-session operator
for the selected R1 validation roster. It accepts only immutable staged raw
triplets beneath the fixed internal R1 raw root, verifies the run-spec-v2
bindings before science, and does not expose a frame-cap option. It must not be
run until Architect V5 seals R1 and explicitly authorizes execution.

The historical R2 `SHA256SUMS.txt` remains unchanged. R3 packet integrity is
defined by `SHA256SUMS_R3.txt` and `R3_PACKET_INTEGRITY.md`.

## Batch 6 — package evidence

1. Run `bash collect_evidence.sh --root "${VALIDATION_ROOT}"`.
2. Verify the generated ZIP SHA-256 receipt.
3. Send the verifier ZIP to Fable without adding raw recording data.

The packet manifest `SHA256SUMS.txt` authenticates every other packet file; the
manifest necessarily excludes itself. The delivered ZIP has a separate
SHA-256 receipt.

## Batch 7 — establish the golden deployment record

1. Finish the environment freeze, exact dependency/classifier/sitecustomize
   custody, and locked-source synthetic run on the home WSL.
2. Run `deployment/run_known_answer_qualification.sh --mode
   establish-golden --root "${VALIDATION_ROOT}"` with its other required
   arguments, and review the raw outputs.
3. Review package redistribution terms and create an explicit cache-artifact
   allowlist; the export script makes no legal guess.

This batch creates evidence only. It does not change the existing environment.

## Batch 8 — export the offline deployment bundle

1. Read `deployment/export_offline_environment_bundle.sh --help`.
2. Supply the exact classifier, study configurations, golden known-answer
   record, reviewed artifact allowlist, and `--root "${VALIDATION_ROOT}"`.
3. Accept the bundle only if its deployment lock says `COMPLETE` and every
   manifest hash verifies.

Artifact gaps, unresolved Git commits, or uncertain custody deliberately stop
the export from becoming deployable.

## Batch 9 — qualify a future analysis machine

1. Choose either the locked offline bootstrap or verified WSL import route.
2. Provision under a new environment/distribution name; never reuse or replace
   an existing MoSeq installation.
3. Run exact preflight and the known-answer fixture, then review the signed
   `QUALIFIED` report before any real data.

Do not execute this batch while preparing the packet. Every new machine
requires independent qualification even if its versions look right.

The preferred Windows route uses a golden WSL archive captured after the
complete deployment bundle and `records/golden_runtime.env` have been written
at their locked paths. The initial safety backup is still worth keeping, but it
does not automatically contain later qualification records.

## Batch 10 — guarded production entry

1. Confirm the machine's report is bound to the current contract and bundle.
2. Launch real analysis only through
   `deployment/run_pipeline_guarded.sh`.
3. Retain the fingerprint and qualification receipt written into each new
   analysis output.

Facts that can only be resolved on Katya's machine are listed in
`KNOWN_RUNTIME_DISCOVERIES.md`. The full Fable environment audit and custody
record are under `evidence/`.
