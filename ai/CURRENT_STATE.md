# Current State

Date: 2026-08-13

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
