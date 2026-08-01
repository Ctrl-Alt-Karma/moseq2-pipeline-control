# Phase 1 to Script 03 Authorization Handoff

## 1. Handoff ID

`HANDOFF-2026-08-01-PHASE1-TO-SCRIPT03-AUTHORIZATION`

This is the live control-state pointer. The immutable Phase-0-to-Phase-1
checkpoint remains `ai/HANDOFF_2026-07-31_PHASE0_TO_PHASE1.md`; it is not
superseded as audit history.

## 2. Mission

Preserve the independently verified Phase 0 and Phase 1 results, hold the
locked candidate source and golden environment unchanged, and obtain Hex
reconciliation before any bounded script-03 qualification run.

## 3. Gate state

| Gate | State | Independent disposition |
|---|---|---|
| Phase 0 golden-environment freeze | **CLOSED** | Fable `PASS` |
| Phase 1 locked candidate worktrees | **CLOSED** | Fable attachment-only `PASS`; recommends closure; `BLOCKS NEXT GATE: NONE` |
| Next packet gate | **PENDING ARCHITECT AUTHORIZATION** | Script 03 is **NOT YET AUTHORIZED** |

Phase 1 closure is recorded immutably in
`ai/PHASE1_CLOSEOUT_2026-08-01.md`. Script 02 ran once and exited `0`; it was
not rerun. The append-only evidence seal verified all five sealed entries
`OK`. Fable independently verified the four R3 attachment identities, exactly
14 ZIP members, all member hashes, both manifests, the original script-02
evidence, the post-run seal, and all 12 frozen script-02 acceptance criteria.

## 4. Roles and access model

- AJ is project owner and sole merge authority.
- The current Hex chat remains the active architect cockpit and reconciler.
- The current Codex chat remains the active builder/operator.
- Fable is an attachment-only independent verifier and cannot inspect the live
  workstation.
- Codex has local access only when AJ enables Full Access.
- Hex normally has no live workstation access.
- No new architect or Codex chat is opened before the next formal phase
  boundary.

## 5. Authoritative inputs

- Audited packet:
  `C:\deployment\MoSeq2-Pilot-Reusable-Root-Corrected-2026-07-30\Extracted-20260801T011401Z\MOSEQ_LEGACY_HOME_PILOT_REUSABLE_ROOT_CORRECTED_2026-07-30`
- Validation root: `/home/ajm/moseq2-validation-20260730`
- Phase 1 closeout: `ai/PHASE1_CLOSEOUT_2026-08-01.md`
- Phase 0 checkpoint: `ai/HANDOFF_2026-07-31_PHASE0_TO_PHASE1.md`
- Operating rules: `ai/OPERATING_RULES.md`

The authorized packet candidate source states are:

| Repository | Locked candidate SHA |
|---|---|
| `moseq2-extract` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-pca` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| `moseq2-model` | `6e542e3f1db125202d42b59f390c922281e64f39` |
| `moseq2-viz` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | `e0b85201226d03e15944473a734f71417698c31e` |

All five were rechecked read-only during the script-03 preflight: exact SHA,
detached HEAD, clean worktree, and expected `Ctrl-Alt-Karma` origin. Source is
exposed through `locked_source.env` and `PYTHONPATH_ONLY`; it is not installed.

## 6. Accepted findings

`IMPORTANT, NON-BLOCKING`:

- The immutable R3 receipt says `teen_staged_members_unchanged=PASS` instead of
  `fourteen_staged_members_unchanged=PASS`. Do not repair it.
- The attached evidence does not directly record why R2 failed: ZIP member
  names used backslashes.
- Live worktree cleanliness and environment state are builder-captured evidence
  reviewed by Fable, not independently reproduced live by Fable.
- Hostname formatting differs cosmetically among artifacts.
- Script 03 does not natively capture its console or create an integrity
  manifest, and its initial guard does not itself recheck every worktree's SHA,
  detached state, cleanliness, and origin. A future authorization should bind
  those checks and evidence-capture requirements explicitly.

`FUTURE / BACKLOG`:

- Make script 02 natively create and verify its integrity manifest.
- Normalize future transport ZIP permission metadata where practical.
- Preserve the Phase 0 and historical-configuration backlog already recorded.

## 7. Blockers

None for Hex authorization review. This is not authorization to execute script
03.

## 8. Next authorized action

Hex may reconcile the read-only script-03 preflight and decide whether to issue
one bounded execution authorization with frozen command, output, evidence, and
stop conditions. Codex may not execute script 03 without that new explicit
authorization.

## 9. Proposed script-03 acceptance criteria

Before execution authorization, Hex should freeze criteria requiring:

1. The exact audited packet and script SHA-256
   `3cf5b5d924c6b6d828b4e943e57e99d24eefe318390110139002452afccc51ce`.
2. Immediate pre-run verification of the Phase 0 manifest, the five-entry
   script-02 post-run seal, and all five worktrees at the exact SHAs, detached,
   clean, and at the expected origins.
3. One fresh output path below the validation root; no overwrite, resume,
   cleanup, or reuse of a partial path.
4. Activation of `/home/ajm/miniforge3/envs/moseq2-app` with Python 3.7 and
   NumPy 1.18.3, with candidate code supplied only by the sealed
   `locked_source.env` `PYTHONPATH`.
5. Successful collection and execution for all five named suites, with every
   collect and test exit code `0`.
6. Complete per-suite commands, stdout, stderr, exit codes, JUnit XML,
   `TEST_OUTCOMES.tsv`, and `TEST_COUNTS.txt`; no failed or blocked test and no
   unexplained skip or deselection.
7. Complete `process_environment.txt`, `python_runtime.txt`, and sitecustomize
   custody evidence.
8. `TEST_RUN_RECEIPT.txt` records `suite_commands_with_nonzero_exit=0`,
   `environment_modified=false`, and `source_modified=false`.
9. The full operator console and an integrity manifest over the final evidence
   are retained and verified under an explicitly authorized capture protocol.
10. No package, environment, scientific repository, or real study-data
    mutation; stop after script 03 and report without advancing to script 04.

Any missing artifact, nonzero collect/test code, failed or blocked test,
unexplained skip, source-state mismatch, partial output, environment/source
mutation, or evidence-integrity failure fails closed.

## 10. Prohibited actions

- Execute script 03 before explicit Hex authorization.
- Execute script 04 or any later packet script.
- Install, remove, upgrade, downgrade, or repair packages.
- Modify the golden environment or any scientific repository.
- Read or process real study data.
- Repair immutable R1, R2, or R3 transport artifacts.
- Merge or mark draft PR #1 ready.
- Open replacement architect or Codex chats before the next formal phase
  boundary.
