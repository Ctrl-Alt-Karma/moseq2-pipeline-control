# Reacquired Repositories

Operation: `MOSEQ_V4_FULL_STATE_SYNC_AND_PRODUCTION_MODEL_FREEZE_R1`

Date: 2026-08-13

## MoSeq project control

- repository: `Ctrl-Alt-Karma/moseq2-pipeline-control`;
- remote: `https://github.com/Ctrl-Alt-Karma/moseq2-pipeline-control.git`;
- remote default branch: `main`;
- pre-write remote `main`: `2834a8378095131b2743bd7a6e38925e0c1cc097`;
- active project-control / PR branch:
  `agent/bootstrap-pipeline-control`;
- pre-write active branch HEAD:
  `034b94e46ada97650c714f7882596e3f4f2fb48b`;
- existing PR ref: `refs/pull/1/head` at the same SHA;
- existing PR URL:
  `https://github.com/Ctrl-Alt-Karma/moseq2-pipeline-control/pull/1`;
- pre-write PR merge ref:
  `fbe68d706880b069af249c16dc319ce86bb3a34b`;
- current authoritative state files: `ai/CURRENT_STATE.md`,
  `ai/DECISIONS.md`, `ai/REVIEW_LOG.md`, `ai/HANDOFF_CURRENT.md`,
  `ai/TASK_SPEC.md`, `ai/OPEN_QUESTIONS.md`, `ai/OPERATING_RULES.md`, and
  `validation/ACCEPTANCE_CRITERIA.md`.

The local checkout was not clean. Its only pre-existing status entries were:

```text
?? LOCKED_464159_K200_LONG_CHAIN_CONVERGENCE_SENTINEL_R1_FABLE_REVIEW.zip
?? bridge-retirement-canon-flush-v3-r1/
```

Neither was modified, deleted, staged, or included. All project edits were made
in an isolated clean worktree from `origin/agent/bootstrap-pipeline-control` on
local branch `agent/v4-full-state-sync-production-freeze`.

Post-write commits, pushed refs, PR state, and final remote HEAD are recorded in
the operation's `PROJECT_STATE_SYNC_RECEIPT.md`, Git history, and final operator
report after publication.

## BRIDGE

- repository: `Ctrl-Alt-Karma/bridge`;
- remote: `https://github.com/Ctrl-Alt-Karma/bridge.git`;
- live remote branch: `main`;
- previously known V4 base:
  `328c7eee85cf57a5af4211b3d36f5ee7560ebc5d`;
- reacquired live `origin/main`:
  `328c7eee85cf57a5af4211b3d36f5ee7560ebc5d`;
- inspected current files: `core/GOVERNANCE.md`,
  `core/OPERATING_RULES.md`, `core/ROLE_AND_POSTURE.md`,
  `core/EVIDENCE_AND_ADJUDICATION.md`,
  `templates/TASK_SPEC_TEMPLATE.md`, `templates/HANDOFF_TEMPLATE.md`, and
  `docs/REFERENCE_CAST.md`.

The nested local BRIDGE worktree was clean and on
`agent/retirement-canon-flush-v3-r1` at
`7ffd5f74664dadfaf42b688390e8f4d92b0adfc4`; it was used read-only. No BRIDGE
file, branch, commit, PR, or remote ref changed.
