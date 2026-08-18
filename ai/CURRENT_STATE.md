# Current State

Date: 2026-08-13 (base) — see the 2026-08-18 checkpoint immediately below

## 2026-08-18 checkpoint — R6 corrected-comparator evaluation PASS

Additive. Nothing below this section is rewritten.

- Architect disposition `PASS_ARCHITECT_R1_R6_CORRECTED_COMPARATOR_EVALUATION_R1` (D-055).
- The verified corrected comparator `0697df76e49d43b3bf352d41230cd2385e3d5f8bdc87ddaf9eeaeee53c588840`
  was run **once, comparison-only**, against the preserved R6 slot-01 primary/replay
  pair: exit `0`, disposition **PASS**, `failure_count` 0, `status_counts`
  {"IGNORED": 26, "MATCH": 1230}, 1230 MUST_MATCH / 26 DECLARED_IGNORED / 0
  unclassified, runtime `contract_sha256`
  `b5e2dcb3c0179ce1dba8bbb499a7335096c570cf1fbb091e0c6e4e00c2128d13`.
- Evidence artifact `/home/ajm/moseq2-validation-20260730/evidence/r1_primary_execution_r6_r1/REPLAY_COMPARISON_REPORT_R6_CORRECTED_COMPARATOR_R1.json`
  SHA-256 `c3ffdad3bd7ceb6d5b4e1fb3ebe001b233b12a0319df559da23314a77a3b9783`; claim class
  BUILDER_PRODUCED_EVIDENCE / ARCHITECT_ADJUDICATED / LOCAL_EVIDENCE_BOUND; protected
  golden-host local evidence, not repository-accessible.
- The R6 execution/replay acceptance subgate left on HOLD by D-053 is **CLOSED**.
  No candidate rerun is required. Scientific tolerance remains **0**.
- Original `REPLAY_COMPARISON_REPORT_R6.json`
  `22be3cecc3c586a8f47950802be71fcc689741eeb957340d0d1a94954d288a2c` and original seal
  `ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2` remain untouched;
  both preserved R6 runs are unmutated.
- This does **not** constitute `PASS_REAL_SESSION_PRODUCTION_VALIDATION`. Final
  production validation still requires satisfaction or adjudication of the remaining
  sealed-protocol criteria, including **Tier-D qualitative review**.
- No model selection, PCA, ARHMM, extraction parameter, comparator semantics,
  tolerance or sealed scientific criterion is reopened.
- Execution record: an initial runner-wrapper launch produced no report, no captured
  output, no exit code and no substantive mutation; the verdict-producing invocation
  then ran once with the accepted bytes and arguments; its stdout and stderr were lost
  with temporary scratch capture. Ancillary **evidence-capture defect**, not a
  comparator or scientific defect; no rerun is authorized or required.
- Candidate processing remains **prohibited**.

## 2026-08-18 checkpoint — comparator-correction verification gate CLOSED

Additive. Nothing below this section is rewritten.

- Comparator correction tip `1cd7c900780a423f2b2186025ee3a324b2bf7fbd`, parent `54d8d7b5783c0810088ed96694a6bc10dcd7c94f`.
- Independent Verifier: `PASS_FABLE_VERIFIER_R1_R6_COMPARATOR_CORRECTION`.
- Qualification **37 / 37 PASS**, independently reproduced, exit 0.
- Comparator-correction verification gate: **CLOSED**.
- The corrected comparator **has not been run** against the nine preserved R6 runs.
- Original seal `ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2` and original `REPLAY_COMPARISON_REPORT_R6.json`
  `22be3cecc3c586a8f47950802be71fcc689741eeb957340d0d1a94954d288a2c` remain untouched; R6 packet `3bfc5ac04dd71f1d7b7a6010442561e2ef3d6399c88ebff88c4390781a59de5e` 75 / 75.
- Candidate processing remains **prohibited**.
- Next authorized scientific operation: comparison-only evaluation of the verified
  corrected comparator against the nine preserved R6 run outputs, emitting a new
  separately named evidence artifact, then **STOP** for Architect adjudication
  before any seal advancement or candidate work.
- Live handoff: `ai/HANDOFF_2026-08-18_R1_R6_POST_COMPARATOR_VERIFICATION_CHECKPOINT.md`.


## Verdict and gate status

- Generic K / seed / convergence calibration: **CLOSED**.
- Final-kappa Phase A, seed `20260802`: **CLOSED**; `SEED_RESOLVED`, winner `464159`.
- Final-kappa Phase B, seed `20260803`: **CLOSED**; `SEED_RESOLVED`, winner `464159`.
- Two-seed conjunction: **FINAL_KAPPA_SELECTED**, winner `464159`.
- Architect disposition: `ARCHITECT_V4_FINAL_PRODUCTION_KAPPA_SELECTED_464159`.
- Independent Verifier disposition: `FABLE_VERIFIER_PASS_PHASE_B_FINAL_KAPPA`.
- Production-model artifact: **FROZEN** to the seed-`20260802`, kappa-`464159`,
  500-iteration final model under the Architect fallback rule recorded below.
- Active scientific gate: **real-session production validation**.
- Protocol: `REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1`, status
  **ARCHITECT CANDIDATE R1 / NOT YET SEALED**.
- This synchronization did not start real-session validation and did not retire
  Architect V4.

## Accepted claim boundary

The accepted claim is: **kappa `464159` was selected under the sealed two-seed
protocol on this corpus.** This is not a claim of universal seed robustness,
unique optimality, mathematical convergence, biological validity, or validity
on arbitrary future cohorts.

K=`200` remains a working production model space. Five hundred iterations
remains a working production budget. Neither is a universal convergence proof.

## Accepted production identities

| Item | Accepted identity |
|---|---|
| Model source | `6e542e3f1db125202d42b59f390c922281e64f39` |
| PCA path | `/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca_scores.h5` |
| PCA SHA-256 | `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912` |
| Locked changepoints SHA-256 | `71565ef2498f27882bbfff5e2ddcc939ed57bc9f8d075161b32f0482bfecea6b` |
| Production kappa | `464159` |
| Production seed | `20260802` |
| Production-model path | `/home/ajm/moseq2-validation-20260730/analysis/locked_464159_k200_long_chain_convergence_sentinel_20260812_R1/model/model-k200-kappa464159-seed20260802-iter500.p` |
| Production-model SHA-256 | `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964` |
| Artifact decision basis | `ARCHITECT_FALLBACK_RULE` |
| Independent seed-B final-model SHA-256 | `a08851c85267d4cc687f4a1d2bb721ea2cf0adca85de96101a1dec4c60eb0209` |
| Exact M_R2 implementation SHA-256 | `24e8523d7af9b6370d34e3a55e7ec049353563fa80d338f6ef3f76d7d42fbe10` |

Production regime: `max_states=200`, `num_iter=500`, `npcs=10`, `nlags=3`,
`whiten=all`, `alpha=5.7`, `gamma=1000`, `ncpus=2`,
`percent_split=0`, `noise_level=0`.

The locked corpus contains 20 UUIDs, 539,189 persisted PCA frames, 539,129
modeled nonnegative frames, and 60 lag-padding labels.

The supported execution environment remains the accepted WSL Ubuntu 22.04
`moseq2-app` Conda environment with Python 3.7.12 and NumPy 1.18.3. Candidate
source is supplied from locked worktrees; modernization or replacement requires
its own equivalence evidence and cannot contaminate current validation.

## Final-kappa evidence

| Evidence | Identity / result |
|---|---|
| Phase A root | `/home/ajm/moseq2-validation-20260730/analysis/locked_k200_500iter_final_kappa_phase_A_seed20260802_20260812_R1` |
| Phase A manifest | `53643e27002cc89e2ecbcdaa798dabc60b2ff7b9e62def7d04b5a8b2c100d095`; 74/74 entries verified 2026-08-13 |
| Phase A result | `SEED_RESOLVED`; winner `464159`; 66/66 winner sets singleton `{464159}` |
| Phase B root | `/home/ajm/moseq2-validation-20260730/analysis/locked_k200_500iter_final_kappa_phase_B_seed20260803_20260813_R1` |
| Phase B manifest | `b07a87756d27c2e72678e1a46fd759eedaa86e0a49ad185f2aa997ab41957ba5`; 103/103 entries verified 2026-08-13 |
| Phase B result | `SEED_RESOLVED`; winner `464159`; 66/66 winner sets singleton `{464159}` |
| Full Phase B verifier transport | `48a3e69baaaeaf91d70eff682bdf55b4ebc54e5414b2b2001db9e86bb1dce8b1` |

The transport digest above is the authoritative 64-character value. A previous
record lost its final hexadecimal character; that clerical truncation is not a
second artifact identity.

## Closed calibration boundary

Do not add Seed C, K300, another kappa, an arbitrary 1000-iteration extension,
a training-likelihood tie-break, a visualization-based selection rule, or a
generic calibration redesign absent a direct contradiction in primary evidence.

## Current open gate

The next gate asks whether the frozen production model and pipeline behave as a
trustworthy scientific instrument on real recordings. It does not test genotype
or treatment effects and does not reopen model selection.

The controlling candidate protocol is
`validation/protocols/REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1.md`.
Before it may be sealed, all eight pre-result bindings listed there must be
reacquired and frozen without opening production-model validation outputs.

## No-peek boundary

Do not inspect final-model validation outputs, crowd movies, syllable usage,
validation PCA/model diagnostics, genotype/treatment results, or biological
effects until the validation roster, exact production identities, corpus-derived
numeric QC rules, negative control, replay plan, and visualization implementation
qualification have been bound as the protocol requires.

## Project practices and backlog

- Frozen executable rules should travel with their authoritative protocol and
  conformance receipt when a reviewer must characterize their semantics.
- Transport construction must enforce exact set equality:
  `manifest = physical contents UNION explicit exclusions`.
- A HOLD is adjudicated; it is not tuned through.
- Out-of-family flags are adjudication triggers, not automatic exclusions.
- Later: golden regression harness, performance profiling, drift canary, rig
  substitution planning, and the separate anti-aging study-design program.

## Role and retirement boundary

- AJ / Karma: Owner and sole final authority.
- Hex / ChatGPT: Architect V4 and technical adjudicator.
- Codex: primary Builder/operator.
- Fable: independent Verifier or Scientific Counsel only when the active brief
  explicitly names the role.

This state sync **does not retire V4**. Formal retirement still requires a live
Retirement Canon Flush, successor reconstruction, a bounded backward pass, and
`PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`.

## 2026-08-17 — V5 retirement reconciliation (additive)

This section is additive. Nothing above it is rewritten; where it corrects an
earlier claim, both records stand at their own claim classes.

- Architect V5 is **RETIRED**. See
  `ai/HANDOFF_2026-08-17_ARCHITECT_V5_RETIREMENT.md`.
- Independent Scientific Counsel returned
  `FABLE_COUNSEL_HOLD_R1_PRESEAL_RECONSTRUCTION`.
- R1 remains **UNSEALED**. The protocol status remains ARCHITECT CANDIDATE R1 /
  NOT YET SEALED.
- **Correction of an inherited claim:** Architect V5 asserted that Tier-B numeric
  corpus envelopes had previously been reported READY. No such artifact has ever
  existed in this repository on any ref, or in any local evidence root. The
  assertion is withdrawn (D-031). A companion assertion that only one pre-seal
  item remained is likewise withdrawn.
- The kappa row above reads `FINAL_KAPPA_SELECTED`. The underlying Builder
  receipt reads `TWO_SEED_CONJUNCTION_SATISFIED_PENDING_ARCHITECT` with
  `final_production_kappa_selected: false`; the Architect adjudication in D-021
  and D-022 is what closed it. Both are correct at their own claim class and
  neither supersedes the other.
- Reconciled pre-seal state: of ten tracked rows, one is CLOSED (OQ-V4-001), two
  are PARTIALLY ESTABLISHED (OQ-V4-003, OQ-V4-007), and seven are OPEN. Row-level
  detail and closing or blocking artifacts are in `ai/OPEN_QUESTIONS.md`.
- Eight validation sessions are staged locally with all three load-bearing raw
  files present and per-file SHA-256 bound in sealed run specs;
  `scientific_processing_started` is `false`. Their source custody chain is not
  evidenced (OQ-V5-010) and the historical-versus-prospective design fork is not
  bound (OQ-V5-009).
- Scientific source, external model dependencies, PCA and production-model
  identities were re-verified clean and unchanged on 2026-08-17.
- **No validation-candidate scientific processing has occurred.**

## 2026-08-17 — succession semantics correction R1 (additive)

The reconciliation section above recorded that Architect V5 is RETIRED. That was
procedurally premature and is corrected here; the earlier assertion is preserved
above as a historical documentary error rather than erased.

- Architect V5 status: **RETIREMENT INITIATED / SUCCESSION PENDING**.
- No Architect authority has transferred. Architect V5 retains only the authority
  to receive the successor's independent comprehension reconstruction, perform the
  bounded backward-pass fidelity check, and return
  `PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION` or
  `HOLD_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION - <reason>`.
- Authority transfers completely and only on
  `PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`. Owner acceptance is not a
  substitute for that formal PASS.
- The successor candidate holds no Architect authority during its read-only
  handshake.
- Reconciled pre-seal matrix, stated unambiguously: **1 CLOSED, 2 PARTIALLY
  ESTABLISHED, 7 OPEN**; therefore **9 of 10 rows are not fully closed**. Seven is
  the OPEN-only count. No row status changed.
- Project-only operating rule 40 stands. Rules 41 and 42 from the first sync are
  removed as `ALREADY_CANON` in BRIDGE, without replacement. BRIDGE is unchanged
  at `328c7eee85cf57a5af4211b3d36f5ee7560ebc5d`.
- Live handoff pointer: `ai/HANDOFF_2026-08-17_ARCHITECT_V5_RETIREMENT_CORRECTION_R1.md`.
- Exactly one next authorized action: the formal successor Architect comprehension
  handshake, whose result returns to the retiring V5 cockpit for the bounded
  backward pass. R1 remains unsealed; no Tier-B computation; no candidate science.

## 2026-08-17 — Architect succession complete (additive)

Additive. Nothing above is rewritten, including the earlier premature retirement
assertion and its correction, which stand as historical record.

- The formal two-way succession handshake completed: the successor cockpit's
  independent reconstruction and the retiring Architect V5 bounded backward pass
  each returned `PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`.
- **Architect V5 is RETIRED** and retains no substantive project authority.
- **The successor Architect is ACTIVE.** Architect authority transferred
  completely, and only on that PASS. Owner AJ / Karma remains ultimate Owner
  authority, unchanged.
- The production-model fallback choice is **ARCHITECT_ADJUDICATED**, not
  independently verified.
- **Scientific state is unchanged by succession.** R1 remains **UNSEALED**;
  Tier-B remains **UNFROZEN**; the pre-seal matrix remains **1 CLOSED, 2
  PARTIALLY ESTABLISHED, 7 OPEN**, so 9 of 10 rows are not fully closed. No
  OPEN_QUESTIONS row was promoted and no scientific gate was reopened.
- The next unresolved upstream dependency is **OQ-V5-009**, the
  historical-existing versus prospective-validation design fork, which gates
  OQ-V4-002, OQ-V4-003 and OQ-V5-010. The intended next operation is a bounded
  read-only golden-host reacquisition centered on it; this operation did not
  execute it and does not authorize it.
- **No candidate science was performed by this operation.**
- Live handoff pointer: `ai/HANDOFF_2026-08-17_ARCHITECT_SUCCESSION_COMPLETE_R1.md`.

## 2026-08-17 — V5 continuity recovery R2 (additive)

Additive. Nothing above is rewritten.

- The lost V5 evidence plane was recovered from an unindexed Windows Codex artifact
  store. **24 of 24 Architect-pinned artifacts were found and hash-matched**; none
  missing, none mismatched.
- The V5 retirement reconciliation had searched only the control repository and the
  Linux evidence root, then promoted `NOT_FOUND_IN_SEARCHED_SCOPE` to project
  absence. Completed accepted work was consequently recorded as unresolved.
- Recovered and now controlling: the outside-corpus inventory, the result-blind
  roster-selection receipt, the visualization orientation regression, the Tier-C
  formula freeze and corpus envelopes, R3 operator qualification, source-to-stage
  custody, the Tier-E negative-control binding and the replay binding.
- Closure matrix after adjudication: **7 CLOSED, 3 PARTIALLY ESTABLISHED, 0 OPEN**;
  3 of 10 rows are not fully closed. Every promoted row states its claim class and,
  where its evidence is non-repository, its access limitation.
- **Tier-B remains UNFROZEN.** No Tier-B artifact was recovered and no Tier-B value
  was computed. **R1 remains UNSEALED.** The roster is unchanged.
- **No validation-candidate science occurred** and no candidate result-bearing
  artifact was opened.
- Live handoff: `ai/HANDOFF_2026-08-17_V5_CONTINUITY_RECOVERY_R2.md`.

## 2026-08-17 — R1 replacements frozen; Tier-B formula reacquired (additive)

- **Predetermined replacements are frozen.** The eight-session primary roster is
  unchanged and was not reselected. Eight non-empty replacement strata were derived
  deterministically and result-blind from the accepted eligible universe; 57
  replacements cover every eligible non-primary candidate exactly once. OQ-V4-003
  moves to CLOSED.
- **Tier-B formula reacquisition is complete and pending Architect adjudication.**
  The recommended minimal battery is per-session 10-PC score magnitude (two-sided)
  and per-session finite-row fraction (lower-only), which are exact set complements
  on the row predicate. Reconstruction error is supported only by an exact inverse
  transform whose residual target the pipeline does not persist.
- **Tier-B remains UNFROZEN.** No Tier-B value was computed on the corpus, on any
  candidate, or on any other real recording, and no threshold was derived.
- Matrix: **8 CLOSED, 2 PARTIALLY ESTABLISHED, 0 OPEN.** **R1 remains UNSEALED.**
- No validation-candidate science occurred.

## 2026-08-17 — Tier-B formulas frozen before values (additive)

- **Tier-B formulas are FROZEN**, before any Tier-B value exists. B1
  `tier_b_whitened_score_rms_radius` operates in the exact frozen whitened 10-PC
  space the production model consumes and is two-sided; B2
  `tier_b_finite_score_row_fraction` is lower-only. Zero finite rows is an
  evidence-level HOLD. Fail-loud rules cover transform nonfinites and solve failure.
- The whitening identity was read unchanged from the frozen model artifact and never
  re-estimated: mu (10,), L (10,10), offset (1,) observed **0.0**, all finite.
- Reconstruction quality is **NOT_SUPPORTED_WITHOUT_NEW_METHOD** on bound source
  evidence; the protocol carries a bounded R1 clarification waiving it by documented
  absence rather than substituting an invented diagnostic.
- **Tier-B corpus values remain UNCOMPUTED and no envelope exists.** Envelope
  construction is frozen as a method only. Any future breach is HOLD FOR
  ADJUDICATION, never automatic failure or threshold movement.
- OQ-V4-005 CLOSED; OQ-V4-006 remains PARTIALLY ESTABLISHED pending numerical
  envelopes. Matrix: **9 CLOSED, 1 PARTIALLY ESTABLISHED, 0 OPEN.**
- **R1 remains UNSEALED.** No validation-candidate science occurred.

## 2026-08-17 — Tier-B corpus envelopes computed (additive)

- The frozen Tier-B formulas were applied unchanged to the exact 20-session corpus
  `keys` roster. **20/20 evaluated, zero fail-loud conditions.**
- Frozen numerical reference envelopes:
  **B1_lower = 2.410095327226669, B1_upper = 3.925567393155021, B2_lower = 0.9979228486646884.**
- Flag rules unchanged: B1 two-sided, B2 lower-only. Any breach is **HOLD FOR
  ADJUDICATION**, never automatic failure, exclusion, retuning or threshold movement.
- OQ-V4-006 CLOSED. Matrix: **10 CLOSED, 0 PARTIALLY ESTABLISHED, 0 OPEN.**
- **R1 remains UNSEALED.** Sealing is an Architect action and was not performed here.
- No validation-candidate data was accessed and no candidate science occurred.

## 2026-08-17 — R1 SEALED (additive)

- `REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1` status is now
  **SEALED — ARCHITECT R1**, on Architect disposition
  `PASS_ARCHITECT_R1_TIER_B_CORPUS_ENVELOPES_R1`.
- Pre-seal matrix at seal: **10 CLOSED / 0 PARTIALLY ESTABLISHED / 0 OPEN.**
- Durable seal record: `validation/protocols/R1_FINAL_SEAL_R1.json`, SHA-256
  `b6d4089eeba624d446b7cdd8c99508505b36192ee809b034ee39922fe68a58aa`. It binds the frozen scientific identities, roster and replacement receipts,
  visualization qualification, Tier-B freeze and envelopes, Tier-C, Tier-E, replay
  binding and the accepted R3 operator.
- Tier-B numerical envelopes: B1_lower = 2.410095327226669, B1_upper =
  3.925567393155021, B2_lower = 0.9979228486646884.
- **No validation-candidate result was inspected and no candidate scientific
  processing occurred before the seal.**
- Sealing is documentary. **The next scientific execution requires separate
  Architect authorization.**

## 2026-08-17 — R1 seal hash-identity correction (additive)

Additive. The historical R1 SEALED section above is preserved unchanged.

- **Controlling canonical identity** of `validation/protocols/R1_FINAL_SEAL_R1.json`:
  SHA-256 `ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2`, Git blob SHA-1 `5de59c6a5446cec5ec05faf62b53e91a5a672580`, 3,540 bytes, pure LF.
- The previously recorded `b6d4089eeba624d446b7cdd8c99508505b36192ee809b034ee39922fe68a58aa` is **superseded as controlling** and is retained as
  `CRLF_WORKTREE_REPRESENTATION` only — the Windows `core.autocrlf` materialization
  of the same tracked-LF bytes (3,597 bytes), which reproduces that hash bit-exactly.
- **JSON semantics, every binding inside the seal, and all scientific state are
  unchanged.** The seal artifact itself was not modified.
- Independent Verifier disposition `PASS_R1_REPOSITORY_HASH_PROVENANCE_CHECK`;
  Architect acceptance `PASS_ARCHITECT_R1_REPOSITORY_HASH_PROVENANCE_CHECK`. Verbatim
  report: `evidence/continuity/R1_REPOSITORY_HASH_PROVENANCE_CHECK_FABLE.md`.
- Rule for future bindings: SHA-256 of repository-tracked text artifacts is taken over
  canonical Git object bytes at a pinned revision, not a working tree.
- R1 remains **SEALED**; matrix remains 10 CLOSED / 0 PARTIALLY ESTABLISHED / 0 OPEN;
  no candidate science occurred.
