> **Superseded 2026-08-17.** The live handoff is
> `ai/HANDOFF_2026-08-17_R1_TIER_B_CORPUS_ENVELOPES_R1.md`; earlier handoffs remain
> immutable history. Tier-B formulas are frozen **and** the numerical corpus
> envelopes are computed. Matrix is 10 CLOSED / 0 PARTIALLY ESTABLISHED / 0 OPEN.
> **R1 remains UNSEALED** — sealing is an Architect action.
> `ai/OPEN_QUESTIONS.md` is authoritative for row-level state. The text below is
> preserved as written and is not rewritten.

# V4 Current Handoff — Final Kappa Closed, Validation R1 Pending Seal

## Handoff ID

`HANDOFF-2026-08-13-V4-STATE-SYNC-TO-V5-READINESS`

This is the live project-state pointer. It is a compact phase delta; immutable
earlier handoffs and scientific evidence remain unchanged.

## Mission

Move the accepted, frozen MoSeq pipeline toward trustworthy routine use on real
recordings without reopening completed calibration or inspecting downstream
biology before the validation design is sealed.

## Last closed gates

- generic K / seed / convergence calibration: **CLOSED**;
- final-kappa Phase A, seed `20260802`: `SEED_RESOLVED`, winner `464159`;
- final-kappa Phase B, seed `20260803`: `SEED_RESOLVED`, winner `464159`;
- frozen two-seed conjunction: `FINAL_KAPPA_SELECTED`, winner `464159`;
- Architect: `ARCHITECT_V4_FINAL_PRODUCTION_KAPPA_SELECTED_464159`;
- independent Verifier: `FABLE_VERIFIER_PASS_PHASE_B_FINAL_KAPPA`.

Phase A and Phase B manifests were mechanically reverified 74/74 and 103/103,
respectively, during the 2026-08-13 state synchronization.

## Active gate

Real-session production validation. Protocol
`REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1` is **ARCHITECT CANDIDATE R1
/ NOT YET SEALED**.

The gate asks whether the frozen model/pipeline is a trustworthy scientific
instrument on real recordings. It is not a biological-effect test and does not
reopen model selection.

## Roles

- AJ / Karma: Owner and sole final authority.
- Hex / ChatGPT: Architect V4 and technical adjudicator.
- Codex: primary Builder/operator.
- Fable: independent Verifier or Scientific Counsel when explicitly assigned.

## Accepted production identities

- source: `6e542e3f1db125202d42b59f390c922281e64f39`;
- PCA path: `/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca_scores.h5`;
- PCA SHA-256: `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912`;
- kappa: `464159`;
- production model: `/home/ajm/moseq2-validation-20260730/analysis/locked_464159_k200_long_chain_convergence_sentinel_20260812_R1/model/model-k200-kappa464159-seed20260802-iter500.p`;
- production model SHA-256: `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964`;
- production artifact decision: `ARCHITECT_FALLBACK_RULE`;
- regime: K=`200`, iterations=`500`, `npcs=10`, `nlags=3`, `whiten=all`,
  `alpha=5.7`, `gamma=1000`, `ncpus=2`, `percent_split=0`, `noise_level=0`;
- environment: accepted WSL Ubuntu 22.04 `moseq2-app` Conda environment,
  Python 3.7.12 and NumPy 1.18.3.

Seed `20260803` model
`a08851c85267d4cc687f4a1d2bb721ea2cf0adca85de96101a1dec4c60eb0209`
remains the independent conjunction lineage; it is not the production artifact.

## Authoritative evidence

- `ai/CURRENT_STATE.md`;
- `validation/protocols/REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1.md`;
- `evidence/synchronization/MOSEQ_V4_FULL_STATE_SYNC_AND_PRODUCTION_MODEL_FREEZE_R1/`;
- Phase A root:
  `/home/ajm/moseq2-validation-20260730/analysis/locked_k200_500iter_final_kappa_phase_A_seed20260802_20260812_R1`;
- Phase A manifest SHA-256:
  `53643e27002cc89e2ecbcdaa798dabc60b2ff7b9e62def7d04b5a8b2c100d095`;
- Phase B root:
  `/home/ajm/moseq2-validation-20260730/analysis/locked_k200_500iter_final_kappa_phase_B_seed20260803_20260813_R1`;
- Phase B manifest SHA-256:
  `b07a87756d27c2e72678e1a46fd759eedaa86e0a49ad185f2aa997ab41957ba5`;
- complete Phase B verifier transport SHA-256:
  `48a3e69baaaeaf91d70eff682bdf55b4ebc54e5414b2b2001db9e86bb1dce8b1`.

The 64-character transport identity above supersedes only the clerically
truncated textual record. No scientific artifact changed.

## Settled decisions

Do not reopen generic K selection, generic convergence, fitting length, kappa
grid, seed count, target construction, the R3 amendment, Phase A, or Phase B
without a direct contradiction in primary evidence. No Seed C, K300, extra
kappa, arbitrary 1000-iteration extension, likelihood tie-break, or
visualization-based model selection.

The production model was selected strictly by the predeclared Architect
fallback: seed `20260802` is the first-seed/primary lineage; seed `20260803` is
the replication/conjunction lineage. No downstream visualization or biology was
used.

## Validation R1 pre-seal requirements

Before any validation-model result is opened, bind:

1. the exact 20-session fitting-corpus UUID roster;
2. metadata-only outside-corpus inventory with QC and exposure history;
3. exact validation roster, predetermined replacements, disclosed exceptions,
   and expected-flag dimensions for deliberate challenges;
4. repaired visualization identity and 180-degree orientation regression;
5. supported PCA/model global QC statistics;
6. corpus-only Tier-B/Tier-C envelopes and numeric mechanical flag rules;
7. the exact Tier-E negative-control condition;
8. the deterministic replay plan and any materially distinct paths.

## Only next authorized scientific operation

One bounded **read-only reacquisition and pre-result freeze** operation covering
the eight requirements above. After Architect review and sealing, a separate
authorization is required to execute real-session production validation.

## Prohibitions

Do not fit, resume, extend, add a seed/kappa/K, refit PCA, modernize the
environment, inspect production crowd movies or validation-model diagnostics,
inspect genotype/treatment results, perform biological interpretation, optimize
performance, or tune through a validation HOLD.

## Project-only lessons and backlog

- Ship executable rule, protocol, and conformance receipt together when a
  verifier must characterize frozen semantics.
- Require `manifest = transport contents UNION exclusions` with exact equality.
- Use numeric predeclared QC rules; do not fake precision with post-hoc
  “materially outside” language.
- OOD flags trigger adjudication, not automatic exclusion.
- Later: golden regression harness, performance profiling, drift canary, rig
  substitution planning, and separate anti-aging study design.

## BRIDGE reconciliation

Live BRIDGE canon at `328c7eee85cf57a5af4211b3d36f5ee7560ebc5d`
already covers Builder autonomy, independent reviewer reasoning, evidence-first
adjudication, Owner challenge, proportional governance, prompt proportionality,
and retirement flush.

- autonomy/prompt candidate: `ALREADY_CANON`;
- domain-specific “scientifically load-bearing” wording: `PROJECT_ONLY`;
- proposed Owner-to-Architect reasoning restriction: `AMBIGUOUS`, held;
- core result: `NO_CANON_EDIT_REQUIRED`.

## Succession and retirement status

This synchronization **does not retire V4**. Formal retirement later requires a
then-live Retirement Canon Flush, successor reconstruction, the retiring
Architect's bounded backward pass, and
`PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`. Until then, Hex remains
Architect V4.

## Claim boundaries

Kappa `464159` is selected under this sealed two-seed protocol on this corpus.
K=`200` and 500 iterations are working production choices, not universal
convergence results. No biological or arbitrary-future-cohort validation has
been claimed.

## Stop boundary

Stop after the read-only pre-result bindings are frozen. Do not execute the
validation protocol or inspect its result-bearing outputs in the same operation.
