# Phase 0 to Phase 1 Handoff

## 1. HANDOFF ID

`HANDOFF-2026-07-31-PHASE0-TO-PHASE1`

This is the live control-state pointer. The identical dated checkpoint is
`ai/HANDOFF_2026-07-31_PHASE0_TO_PHASE1.md`.

## 2. MISSION

Preserve the independently verified golden-environment freeze and prepare the
five locked candidate repositories as isolated detached worktrees without
installing them, altering the golden environment, processing scientific data,
or advancing beyond script 02.

## 3. LAST CLOSED GATE

Phase 0 golden-environment freeze: **independently verified PASS** by Fable.

- Phase 0 receipt status: `COMPLETE`.
- Authoritative unresolved list: empty (`[]`).
- `environment_changed=false`.
- `packages_installed=false`.
- Installed source identity: all five MoSeq packages are `VANILLA_MATCH`.
- No merges occurred.

## 4. ACTIVE GATE

Phase 1 locked candidate worktree preparation, beginning with
`02_prepare_locked_worktrees.sh` only.

`BLOCKS NEXT GATE`: script 03 remains unauthorized until every script-02
acceptance criterion in section 17 passes and its complete result is reviewed.

## 5. ROLE ASSIGNMENTS

| Role | Assignment |
|---|---|
| Project owner and sole merge authority | AJ; retains final approval authority and is the only person authorized to approve merges. |
| Architect, coordinator, and reconciler | Hex / GPT; maintains the frozen roadmap, classifies findings, reconciles builder and verifier evidence, makes gate recommendations, and must use formal change control for any proposed plan alteration. |
| Primary builder and operator | Codex; may perform only the explicitly authorized active-gate action and must stop at the stated boundary. |
| Independent adversarial verifier | Fable; independently audits completed gate evidence and labels findings as BLOCKS NEXT GATE, IMPORTANT NON-BLOCKING, or FUTURE / BACKLOG. |
| Bounded backup | Claude Code; used only when explicitly authorized for a defined builder, operator, or verification task. |
| Control repository | Ctrl-Alt-Karma/moseq2-pipeline-control, branch agent/bootstrap-pipeline-control, draft PR #1. |

- Nothing merges without AJ's explicit approval.
- Hex / GPT may authorize the next bounded operator action only after reconciling
  the frozen acceptance criteria and available verification evidence.
- Fable supplies independent evidence and blocker classifications; Fable does
  not silently redesign or reorder the roadmap.
- New evidence does not change the execution sequence unless formal change
  control establishes that the next gate would otherwise be unsafe, invalid,
  impossible, or incorrectly ordered.

## 6. AUTHORITATIVE SOURCES

| Source | Authority |
|---|---|
| `/home/ajm/moseq2-validation-20260730/PHASE0_FREEZE_RECEIPT.txt` | Live Phase 0 completion, environment-mutation flags, and evidence paths. |
| `/home/ajm/moseq2-validation-20260730/PHASE0_SHA256SUMS.txt` | Internal Phase 0 evidence integrity. |
| `/home/ajm/moseq2-validation-20260730/evidence/environment_freeze/` | Complete live Phase 0 evidence. |
| `/home/ajm/moseq2-governed-sources-20260731/comparison-source-materialization-receipt.json` | Exact comparison-source remotes, SHAs, detached state, cleanliness, and tree digests. |
| `/home/ajm/moseq2-governed-sources-20260731/comparison-source-manifest.sha256` | Comparison-source integrity manifest. |
| `evidence/summaries/CODEX_2026-07-31_PHASE0_INPUT_APPROVAL.md` | Architect-approved source, project, configuration, classifier, and historical-status decisions. |
| `environment/LEGACY_PRODUCTION_TARGET.md` | Frozen golden-machine and production-target contract. |
| `C:\deployment\MOSEQ_PHASE0_AUDIT_BUNDLE_2026-07-31.zip` | Fable audit-delivery bundle; SHA-256 `2609a5dea76b8d7ae43e6920eb99632b1f57764633ff4c6af8f05d2ac49f2968`. |
| Fable Phase 0 verdict communicated 2026-07-31 | Independent `VERDICT: PASS`; closes Phase 0. |

The audited packet for the next action is the deployed reusable-root corrected
packet under
`C:\deployment\MoSeq2-Pilot-Reusable-Root-Corrected-2026-07-30\Extracted-20260801T011401Z\MOSEQ_LEGACY_HOME_PILOT_REUSABLE_ROOT_CORRECTED_2026-07-30`.

## 7. FROZEN DECISIONS

- Validation root:
  `/home/ajm/moseq2-validation-20260730`.
- Governed source root:
  `/home/ajm/moseq2-governed-sources-20260731`.
- Study project root:
  `/home/ajm/moseq_work/5xfad_exploratory_20`.
- Explicit configuration 1:
  `/home/ajm/moseq_work/5xfad_exploratory_20/config.yaml`, SHA-256
  `ef42bf756eef975277d5dc62d0d7719daf75f374a2e58d96a6c3eb39ecd75269`.
- Explicit configuration 2:
  `/home/ajm/moseq_work/5xfad_exploratory_20/moseq2-index.yaml`, SHA-256
  `69788d31c5fcebd1e906cfff4cf1f4e921040d791880a93179a910cadacbd059`.
- `historical_smoke_test/config.yaml` is not explicit.
- `pca/pca.yaml` is not explicit; bounded discovery may capture it.
- Canonical classifier:
  `/home/ajm/moseq_work/5xfad_exploratory_20/flip/flip_classifier_k2_c57_10to13weeks.pkl`,
  SHA-256
  `4b06e1e56928bb1ac227329d0932d4637cdd541a3af49865ae127b57991c2c00`,
  `11981487` bytes.
- Historical-smoke classifier copy is a `VERIFIED_BYTE_IDENTICAL_ALIAS`.
- The current primary config is the golden Phase 0 artifact.
- Historical extraction-time config status is
  `UNRESOLVED_HISTORICAL_VERSION`; no reconstruction or remediation belongs in
  Phase 1.
- Locked candidate source is exposed through `PYTHONPATH` only. It is never
  installed into the Conda environment.
- Branch names are provenance, not code identities; only the 40-character SHAs
  in section 9 are authoritative.

## 8. CLAIM AND EVIDENCE LEDGER

| Operational label | Claim | Evidence and disposition |
|---|---|---|
| CLOSED | Phase 0 passed independently. | Fable `VERDICT: PASS`; live receipt `COMPLETE`; internal manifest verified; unresolved list empty. |
| CLOSED | The installed environment is upstream vanilla. | All five installed package trees are `VANILLA_MATCH` against immutable comparison roots. |
| CLOSED | Classifier and configuration custody are bounded and resolved for Phase 0. | Classifier `FOUND_AND_HASHED`; configuration `BOUNDED_HASHED`; two explicit configuration paths; 215 bounded configuration files; 21 classifier references; zero unresolved references. |
| `BLOCKS NEXT GATE` | Phase 1 may not advance to script 03 until script 02 passes. | Section 17 is the complete acceptance gate. A partial run, rerun, dirty checkout, wrong remote/SHA, missing receipt, or environment mutation fails closed. |
| `IMPORTANT, NON-BLOCKING` | Exact extraction-time config bytes are unavailable. | Status `UNRESOLVED_HISTORICAL_VERSION`; conflicting historical hashes are preserved. This lands in later historical comparison work and does not block script 02. |
| `IMPORTANT, NON-BLOCKING` | The audit ZIP omitted `.moseq2-home-pilot-root`. | Evidence-packaging omission only. The live marker remains at the validation root and script 02 must validate it before writing anything. |
| `IMPORTANT, NON-BLOCKING` | `moseq2-app` installation metadata points to `file:///home/ajm/moseq2-app` rather than an exact Git commit. | Deterministic installed-tree identity is an exact `VANILLA_MATCH`; Phase 0 remained complete. |
| `FUTURE / BACKLOG` | Katya's prior environment was confirmed upstream vanilla; consequences for prior scalar outputs require separate analysis. | Belongs in Phase 3 historical/scalar comparison work. It does not alter Phase 1 or authorize remediation now. |

## 9. LOCKED CODE STATES

| Repository | VANILLA | FORK_RELEASE | CANDIDATE |
|---|---|---|---|
| `moseq2-extract` | `39a6f0f88d28fc311c8be96619ee9e53b14d3a96` | `424d643affb685e1cad145e3c7051b814d11265c` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-pca` | `a7bdbe179084c5d366290cd04f4ab26ee8387aa0` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| `moseq2-model` | `c7c1e1f1ff22c8670bcf0d929d4ca3a12d53190d` | `6e542e3f1db125202d42b59f390c922281e64f39` | `6e542e3f1db125202d42b59f390c922281e64f39` |
| `moseq2-viz` | `f571e0ac84cc26cd7f04ea5cf7478657894b02d8` | `68ca6a34055987ff22f8651b4dca2aa254380c87` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | `7be1af1f96d7873ff44d6ea5ae45262881d76f9f` | `36d40e098a5c4629116b7a4e233573218345bd5d` | `e0b85201226d03e15944473a734f71417698c31e` |

Script 02 must create worktrees only for the five `CANDIDATE` SHAs.

## 10. GOLDEN ENVIRONMENT

- Windows user: `AJM_LAPTOP\AJM`.
- WSL distribution: `Ubuntu-22.04`.
- Ubuntu: `22.04.5 LTS`.
- Linux user/home: `ajm`, `/home/ajm`.
- Conda root: `/home/ajm/miniforge3`.
- Conda environment: `moseq2-app`.
- Conda prefix: `/home/ajm/miniforge3/envs/moseq2-app`.
- Python: `3.7.12`.
- NumPy: `1.18.3`.
- Dask: `2.30.0`.
- `sitecustomize.py`: `VERIFIED_ABSENT` using interpreter
  `/home/ajm/miniforge3/envs/moseq2-app/bin/python`.
- Installed identity: `moseq2-extract`, `moseq2-pca`, `moseq2-model`,
  `moseq2-viz`, and `moseq2-app` are all `VANILLA_MATCH`.
- Phase 0 mutation flags: `environment_changed=false`,
  `packages_installed=false`.

## 11. PHASE 0 ARTIFACTS AND HASHES

| Artifact | Path | SHA-256 |
|---|---|---|
| Phase 0 receipt | `/home/ajm/moseq2-validation-20260730/PHASE0_FREEZE_RECEIPT.txt` | `4cf65a412e6d2c3a4be3b38a83a4e980fd4ae740c53ebdc9fe31e4a2d2c69b18` |
| Internal manifest | `/home/ajm/moseq2-validation-20260730/PHASE0_SHA256SUMS.txt` | `afc19af0f72bf88c663f0145c0e47881f81c22039514eda884068a4eb6ccb7d1` |
| Installed source identity | `/home/ajm/moseq2-validation-20260730/evidence/environment_freeze/installed_moseq_source_identity.json` | `27ec7d5a1df835277f4a371c55f59ad1c21e8a009db672bbbf58c97c9fc9076c` |
| Sitecustomize evidence | `/home/ajm/moseq2-validation-20260730/evidence/environment_freeze/active_sitecustomize.json` | `dd4cac3f3cd55967996b38513828ed335e4c53a036ebabacf26e5568f2c708a3` |
| Classifier custody | `/home/ajm/moseq2-validation-20260730/evidence/environment_freeze/classifier_custody.json` | `6abe0f91735d71c08c42d7e4dc255830e230bb14e9f16c30ee75c66f72ed1f8b` |
| Configuration custody | `/home/ajm/moseq2-validation-20260730/evidence/environment_freeze/configuration_custody.json` | `fbd96e085e9ad3e1849d59e50a9dac53303fd9d4bab5839a0f139333895a0f70` |
| Comparison receipt | `/home/ajm/moseq2-governed-sources-20260731/comparison-source-materialization-receipt.json` | `6bb63f14b81734347aa6bfce627b0d3db26dfc20f3cbd3ac00067cb0ed9df226` |
| Comparison manifest | `/home/ajm/moseq2-governed-sources-20260731/comparison-source-manifest.sha256` | `092c2427b664e826955498b94de609327ad6d1a99d4c3775b2226b06ee21c29a` |
| Fable audit ZIP | `C:\deployment\MOSEQ_PHASE0_AUDIT_BUNDLE_2026-07-31.zip` | `2609a5dea76b8d7ae43e6920eb99632b1f57764633ff4c6af8f05d2ac49f2968` |
| Audit staging manifest | `C:\deployment\MoSeq2-Phase0-Audit-2026-07-31\AUDIT_BUNDLE_SHA256SUMS.txt` | `08346fc973efc38e4a24278fb935bbe14cc767c60e6aac024f0658f374184204` |

The live root marker is
`/home/ajm/moseq2-validation-20260730/.moseq2-home-pilot-root`. It was omitted
from the audit ZIP but remains part of the live script-02 validation contract.

## 12. GOVERNED DEPENDENCIES

| Dependency | Version | Exact commit |
|---|---|---|
| `pyhsmm` | `0.1.6` | `4e739166746f92bfc968d281f2c1d31e3471409f` |
| `pybasicbayes` | `0.2.4` | `61f65ad6c781288605ec5f7347efcc5dbd73c4fc` |
| `autoregressive` | `0.1.2` | `2a4c73c08dcda959b9bac2f03a2b976dabbc37af` |
| `dask` | `2.30.0` | Package version captured; no Git commit claim required by the Phase 0 gate. |

These are observed golden-environment identities, not installation requests.

## 13. OPEN RISKS AND LIMITATIONS

- `IMPORTANT, NON-BLOCKING`: extraction-time config bytes remain
  `UNRESOLVED_HISTORICAL_VERSION`. Preserve the conflicting historical records;
  defer comparison work.
- `IMPORTANT, NON-BLOCKING`: the Phase 0 audit ZIP omitted the root marker.
  Script 02 must validate the live marker, receipt, and manifest before any
  worktree path is created.
- `IMPORTANT, NON-BLOCKING`: installed `moseq2-app` Git metadata is local-path
  based; deterministic source hashing established `VANILLA_MATCH`.
- `FUTURE / BACKLOG`: assess consequences of upstream-vanilla scalar behavior
  for prior outputs in Phase 3. Do not reinterpret, repair, or regenerate those
  outputs in Phase 1.
- `FUTURE / BACKLOG`: modernization, Python/NumPy migration, and future-machine
  deployment qualification remain separate governed workstreams.

## 14. BLOCKERS

NONE.

## 15. NEXT AUTHORIZED ACTION

Run `02_prepare_locked_worktrees.sh` only from the audited deployed packet,
using the existing reusable validation root:

```bash
bash 02_prepare_locked_worktrees.sh --root /home/ajm/moseq2-validation-20260730
```

Stop after script 02 and report its complete result. Authorization does not
extend to script 03.

## 16. PROHIBITED ACTIONS

- Script 03 or any later packet script.
- Package installation, removal, upgrade, downgrade, repair, or other
  environment change.
- Scientific-data inspection or processing.
- Any merge.
- Modernization or migration work.
- Historical remediation or reconstruction.
- WSL trimming, scientific-data deletion, or recording movement.
- Alteration of the golden environment.
- Modification of the five scientific repositories outside script-02-managed
  detached worktrees.

## 17. ACCEPTANCE CRITERIA FOR SCRIPT 02

`BLOCKS NEXT GATE`: every item must pass before script 03 can be considered.

- The live root marker passes validation.
- The Phase 0 receipt and internal manifest pass structural and hash
  validation.
- Five locked `CANDIDATE` worktrees are created at the exact SHAs in section 9.
- Every worktree has detached HEAD.
- Every worktree is clean.
- Every origin matches the expected `Ctrl-Alt-Karma` repository URL.
- The control receipt records `source_mode=PYTHONPATH_ONLY`.
- No package installation occurs.
- No golden-environment modification occurs.
- The script-02 control receipt, `locked_worktrees.tsv`, `locked_source.env`,
  hashes, and complete console result are produced and retained.
- Script 02 exits successfully with no unresolved mismatch or conflicting prior
  state.
- Stop after script 02.

Any missing item, wrong SHA/remote, attached HEAD, dirty tree, receipt failure,
partial state, rerun state, package operation, or environment mutation fails
closed and blocks the next gate.

## 18. SUPERSEDED MATERIAL

- Prior statements that Phase 0 freeze is pending are superseded.
- Prior operational instructions that begin with WSL export or script 01 are
  historical records, not the active gate.
- `ai/HANDOFF_CURRENT.md` is the live pointer and may be replaced at a later
  approved transition. This dated checkpoint remains immutable audit history.
- No evidence file, prior packet, review, branch, or PR is deleted or rewritten
  by this handoff.
