# Fable Scientific Counsel — R1 pre-seal reconstruction (2026-08-17)

## Disposition

`FABLE_COUNSEL_HOLD_R1_PRESEAL_RECONSTRUCTION`

## Local artifact identity

- Path: `/home/ajm/moseq2-validation-20260730/evidence/v5_retirement_state_sync_20260817_R1/FABLE_COUNSEL_R1_PRESEAL_RECONSTRUCTION.md`
- SHA-256: `2a23377600d06f09dfd52a3a6f097084880bb8683de0606a6c4414ecaa7d2db6`
- Bytes: 19861
- Preserved: 2026-08-17T11:58:45Z

The report is preserved verbatim at that path. It is not reproduced here because
this repository is public and the pointer is sufficient for control purposes.

## Scope reviewed

The full repository tree at `59b15ce796bdda2b1d534fc34cded3e877360cac` (134
files), including the R3 operator script, run-spec schema, gate tests, summary
helper, packet integrity documents, decisions register, review log, and the V4
synchronization evidence folder.

## Access limitation

Counsel did **not** have access to the local evidence roots under `/home/ajm` on
the golden host, and the GitHub commits API returned 403 in that environment, so
commit-by-commit history walking was unavailable. Counsel substituted a live-ref
byte comparison of `ai/OPEN_QUESTIONS.md` and `ai/CURRENT_STATE.md` against the
pinned commit and found them identical.

Consequently Counsel's matrix records absence-in-repository, which is not the
same as absence-in-project. Rows resting on local evidence were reconciled
separately on 2026-08-17 and are recorded in `ai/OPEN_QUESTIONS.md`. Two rows
moved on that reconciliation (OQ-V4-001 to CLOSED, OQ-V4-003 to partially
established); the remainder stood, and two new rows were added.

## Central findings accepted

1. The durable control state contradicted any "Tier-B READY" narrative. No
   Tier-B formula, envelope, flag rule, receipt, or computation code has ever
   existed in this repository, on any ref, in any commit. The claim was
   inherited narrative, not state.
2. The durable control repository was stale relative to later local project
   activity, and narrative must not substitute for primary evidence.
3. A design fork between historical-existing and prospectively acquired
   validation sessions is bound nowhere in primary evidence while the operator's
   path layout presumes one answer. Recorded as OQ-V5-009.

## Adjudication boundary

This pointer and any Architect adjudication are **additive**. They do not
rewrite, replace, or summarize away the preserved counsel report, which remains
authoritative for its own content. Where reconciliation against local evidence
changed a row's status, both the counsel finding and the reconciled status are
preserved, with the closing artifact cited.

Counsel's Tier-B design review is a review of a **proposal**. No Tier-B
definition is frozen, and none is adopted by this pointer.
