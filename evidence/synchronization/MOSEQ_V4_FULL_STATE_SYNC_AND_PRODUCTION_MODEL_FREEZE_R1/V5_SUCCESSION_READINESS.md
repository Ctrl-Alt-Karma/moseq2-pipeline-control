# V5 Succession Readiness

Status: **STATE PRESERVED; V4 NOT RETIRED**

## Closed scientific gates

- generic K / seed / convergence calibration;
- final-kappa protocol;
- Phase A, seed `20260802`, winner `464159`;
- Phase B, seed `20260803`, winner `464159`;
- two-seed conjunction and Architect V4 production-kappa selection.

Do not reopen these with Seed C, K300, another kappa, a 1000-iteration
extension, a likelihood tie-break, or visualization-based selection absent a
direct contradiction in primary evidence.

## Accepted production identities

- model source: `6e542e3f1db125202d42b59f390c922281e64f39`;
- PCA SHA-256:
  `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912`;
- kappa: `464159`;
- production artifact: seed `20260802` final model;
- model SHA-256:
  `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964`;
- artifact basis: `ARCHITECT_FALLBACK_RULE`;
- accepted regime: K=`200`, iterations=`500`, `npcs=10`, `nlags=3`,
  `whiten=all`, `alpha=5.7`, `gamma=1000`, `ncpus=2`,
  `percent_split=0`, `noise_level=0`;
- accepted environment: WSL Ubuntu 22.04 `moseq2-app` Conda environment,
  Python 3.7.12 and NumPy 1.18.3.

## Evidence roots and identities

- Phase A root:
  `/home/ajm/moseq2-validation-20260730/analysis/locked_k200_500iter_final_kappa_phase_A_seed20260802_20260812_R1`;
- Phase A manifest:
  `53643e27002cc89e2ecbcdaa798dabc60b2ff7b9e62def7d04b5a8b2c100d095`;
- Phase B root:
  `/home/ajm/moseq2-validation-20260730/analysis/locked_k200_500iter_final_kappa_phase_B_seed20260803_20260813_R1`;
- Phase B manifest:
  `b07a87756d27c2e72678e1a46fd759eedaa86e0a49ad185f2aa997ab41957ba5`;
- full Phase B verifier transport:
  `48a3e69baaaeaf91d70eff682bdf55b4ebc54e5414b2b2001db9e86bb1dce8b1`.

## Current open gate

`REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1`, status **ARCHITECT
CANDIDATE R1 / NOT YET SEALED**.

The protocol decides whether the frozen instrument is trustworthy on real
recordings. It does not test biological efficacy, genotype effects, or arbitrary
future cohorts.

## Next authorized scientific operation

Bounded read-only reacquisition and freeze of the eight pre-result protocol
inputs: fitting-corpus roster, outside-corpus inventory, selected roster and
replacements, visualization fix/regression, supported QC statistics,
corpus-derived numeric rules, Tier-E negative control, and replay plan.

Do not inspect validation-model outputs or run validation until those are bound,
the Architect seals R1, and a separate execution operation is authorized.

## Nonblocking backlog

- transport set-equality constructor/verifier hardening;
- golden regression harness after validation PASS;
- later performance profiling and optimization behind equivalence;
- fixed-reference drift canary;
- rig substitution planning;
- separate anti-aging measurement and study design.

## Project-only lessons

- executable rule, authoritative protocol, and conformance receipt should travel
  together when reviewer semantics are load-bearing;
- `manifest = contents UNION exclusions` with exact equality;
- no tuning through HOLD;
- numeric rules must be real, not post-hoc prose;
- OOD flags trigger adjudication, not automatic exclusion.

## BRIDGE classifications

- autonomy/prompt candidate: `ALREADY_CANON`;
- domain-specific scientific wording: `PROJECT_ONLY`;
- proposed Owner-to-Architect prescription: `AMBIGUOUS`, held;
- live canon: `Ctrl-Alt-Karma/bridge` at
  `328c7eee85cf57a5af4211b3d36f5ee7560ebc5d`;
- reconciliation: `NO_CANON_EDIT_REQUIRED`.

## Role boundaries

- AJ / Karma: Owner;
- Hex / ChatGPT: Architect V4;
- Codex: primary Builder;
- Fable: independent Verifier or Counsel under an explicitly declared mode.

## Remaining retirement requirements

This synchronization does not retire V4. Formal retirement later requires:

1. reacquire then-live BRIDGE canon;
2. run the Retirement Canon Flush classifications;
3. implement only unambiguous `NEEDS_UPDATE` reusable changes;
4. record the final canon commit;
5. have V5 independently reconstruct the cockpit;
6. have V4 perform the bounded backward pass;
7. reach `PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION` before authority transfers.
