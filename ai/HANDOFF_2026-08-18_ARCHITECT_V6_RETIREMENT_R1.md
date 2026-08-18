# Architect V6 Retirement Handoff — R1 R6

## 1. Handoff ID

`HANDOFF-2026-08-18-ARCHITECT-V6-TO-V7-R1`

Formal Architect retirement. Compact current delta, not project history.

## 2. Mission

Trustworthy routine MoSeq use on real recordings under the frozen production
instrument, with result-blind validation and deterministic replay.

## 3. Last closed gate

Scientific determinism of the R6 preserved primary/replay pair:
`PASS_ARCHITECT_R1_R6_SCIENTIFIC_DETERMINISM_ESTABLISHED_COMPARATOR_REPAIR_REQUIRED_R1`
(D-051).

**Overall R6 execution acceptance is NOT yet PASS.** It remains HOLD pending
comparator correction. Do not read the closed gate as an execution acceptance.

## 4. Active gate

`POST_R6_REPLAY_COMPARATOR_IMPLEMENTATION_CORRECTION`.

## 5. Role assignments

- Owner / final authority: AJ (Karma).
- Retiring Architect: ChatGPT Architect V6.
- Successor: fresh ChatGPT Architect V7, after formal handshake PASS.
- Builder: Claude Code, authorized stand-in while Codex is unavailable.
- Scientific Counsel: separate Fable counsel chat.
- Independent Verifier: separate Fable verifier chat.

Counsel and Verifier are distinct roles in distinct chats and must not be blurred.

## 6. Current authority

Authority has **not** transferred. Architect V6 is retiring; V7 holds no
operational authority until `PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`.

## 7. Accepted state and identities

Canonical project main: `54d8d7b5783c0810088ed96694a6bc10dcd7c94f`.

R6 moseq2-extract runtime source: `2c9cd86571bcc23ad6870e4da344e0f558f3f54c`.

| Frozen scientific artifact | SHA-256 |
|---|---|
| Production model | `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964` |
| PCA basis (runtime `/components`) | `6b587854412c1b0a0b69759f4262e4fac3583b1aa6144093fcd3d2bf1ff0b368` |
| PCA companion yaml | `ba47df9b1229ab6dae884adf2fab49cfde4a07c5d44575e35547be12277af0d9` |
| **TRAINING SCORES** (archival; **not** the runtime PCA basis) | `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912` |

Production kappa `464159`, production seed `20260802`.

R6 execution: **8/8 primaries PASS**, slot-01 replay PASS, production model
unchanged, no fit or adaptation, no replacement used, no visualization, no
scientific-value inspection.

Canonical comparator result on the preserved pair: **1209 / 1216 MATCH, 7 DIFFER**.

## 8. Authoritative evidence

- Residual-decomposition receipt: `/home/ajm/moseq2-validation-20260730/evidence/r1_primary_execution_r6_r1/R6_RESIDUAL_DECOMPOSITION_RECEIPT.json`
  SHA-256 `4b2d931b5ea1f44ed818cd5aaae6b3a354421cdd3be9c7d44b0f081e2a241675`.
- Source comparator report SHA-256 `22be3cecc3c586a8f47950802be71fcc689741eeb957340d0d1a94954d288a2c`.
- R6 execution evidence root: `/home/ajm/moseq2-validation-20260730/evidence/r1_primary_execution_r6_r1`.

Both are **protected golden-host local evidence** and are not repository-accessible.
Primary evidence is the receipt and the comparator report; this handoff is a summary.

## 9. Settled decisions

Do not reopen absent contradictory evidence: PCA role correction and component
lineage; the `pca.yaml` companion dependency; R4 `DepthResolution` compatibility;
frozen roster and replacement design; Tier-B formulas and envelopes; Tier-C;
kappa and model selection; the decision not to retrain PCA or the ARHMM for R6;
the scientific appropriateness of fixed-seed RANSAC; the R6 scientific determinism
finding; and the historical R3/R4/R5 failures and their preserved outputs.

## 10. Unresolved items

Comparator implementation correction only.

## 11. Access and capability limits

The decomposition receipt and R6 execution evidence are local to the golden host.
The Builder reaches them through WSL; Counsel and Verifier chats do not have that
access and must be given identities rather than asked to browse.

## 12. Retiring-chat condition

Context condition: **HEAVY**.

- This cockpit depended substantially on long and compressed history.
- The continuation-critical state has now been reacquired and persisted durably
  (D-051 and the bound receipt).
- Historical prose in this repository may contain stale identities.
- The successor must rely on canonical repository and evidence identities, not on
  chat memory.
- `ai/HANDOFF_CURRENT.md` before this checkpoint was **stale** and pointed at a V4-era
  body; it has been replaced with a live pointer.

## 13. Known limitations / claim boundaries

Established: scientific determinism of the preserved R6 pair (Architect-adjudicated
on a Builder-produced, mechanically re-verified receipt).

Not established: overall R6 execution acceptance; any biological or Tier-B/Tier-C
result; any claim that the corrected comparator will pass.

## 14. Only next authorized action

After succession PASS, the successor Architect may author exactly one bounded
Builder operation: **build and synthetically qualify the
`POST_R6_REPLAY_COMPARATOR_IMPLEMENTATION_CORRECTION`**, addressing the three
established defect classes:

1. exact pipeline-provenance `written` wall-clock fields;
2. M20 recursion into the embedded model `repr` despite the contract exclusion;
3. fixed-width HDF5 string capacity defeating C1 after canonicalized contents match.

That correction must preserve zero scientific tolerance, preserve closed-world
comparison, preserve all scientific MUST_MATCH content, rerun no candidate, alter no
preserved R6 output, and **stop before** running the corrected comparator against
preserved R6 or R5 outputs.

No Builder prompt is preloaded here. The successor authors it after authority
transfers.

## 15. Canon synchronization

Live BRIDGE main verified at `a919e0ad170134fcce5ef56de14c1cf352130165`.

| Candidate reusable change | Disposition |
|---|---|
| Formal two-way succession | `ALREADY_CANON` |
| Load-bearing acceptance persistence / retirement continuity | `ALREADY_CANON` |
| Proportional governance / avoiding objection theater | `ALREADY_CANON` |
| Project-specific comparator semantics | `PROJECT_ONLY` |
| Project-specific scientific decisions | `PROJECT_ONLY` |

No `AMBIGUOUS` candidate is held. No `NEEDS_UPDATE` was found, so **BRIDGE was not
edited**. No project-only rule was promoted to canon.

## 16. Stop boundary

The corrected comparator must not be run against preserved runs until the
correction is built and synthetically qualified, the Architect reviews it, and the
Independent Verifier reviews that exact correction. No seal advancement, no
replacement seal, no merge to canonical `main`, and no candidate work.

## 17. Communication posture

No project-specific deviation from `core/ROLE_AND_POSTURE.md`.

## 18. Succession status

`HOLD_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION` — the successor reconstruction has
not been performed. Authority transfers only on
`PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`.

## Continuity reconciliation

Load-bearing work since the last durable checkpoint, with disposition:

| Item | Disposition | Durable identity |
|---|---|---|
| R6 execution (8 primaries + replay) | `LOCAL_EVIDENCE_BOUND` | evidence root `/home/ajm/moseq2-validation-20260730/evidence/r1_primary_execution_r6_r1`; nine preserved run directories |
| Canonical comparator result on the preserved pair | `LOCAL_EVIDENCE_BOUND` | report SHA-256 `22be3cecc3c586a8f47950802be71fcc689741eeb957340d0d1a94954d288a2c` |
| R6 residual decomposition | `DURABLY_RECORDED` (as a bound identity) and `LOCAL_EVIDENCE_BOUND` (as content) | receipt `/home/ajm/moseq2-validation-20260730/evidence/r1_primary_execution_r6_r1/R6_RESIDUAL_DECOMPOSITION_RECEIPT.json` SHA-256 `4b2d931b5ea1f44ed818cd5aaae6b3a354421cdd3be9c7d44b0f081e2a241675` |
| D-051 acceptance | `DURABLY_RECORDED` | `ai/DECISIONS.md` on this branch |

Evidence namespaces used by the retiring cockpit: the project repository
(durably indexed); the golden-host validation root and R6 evidence root
(searched during retirement, local-only, not repository-accessible); the Windows
Codex artifact store (searched previously, local-only). No
`COMPLETED_WORK_EVIDENCE_LINK_MISSING` item is outstanding: each material item
above resolves to a stated identity. Downstream artifacts were checked before
calling anything unresolved — the comparator report and the preserved run
directories both exist and were re-read for this receipt.

This handoff does **not** claim that the local evidence was independently
repository-verified. It was Builder-produced on the golden host and bound by hash.
