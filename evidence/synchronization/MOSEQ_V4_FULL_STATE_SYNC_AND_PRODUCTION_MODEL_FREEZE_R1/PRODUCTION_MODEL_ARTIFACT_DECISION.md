# Production Model Artifact Decision

Decision state: `ARCHITECT_FALLBACK_RULE`

## Frozen artifact

- absolute path:
  `/home/ajm/moseq2-validation-20260730/analysis/locked_464159_k200_long_chain_convergence_sentinel_20260812_R1/model/model-k200-kappa464159-seed20260802-iter500.p`;
- SHA-256:
  `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964`;
- seed: `20260802`;
- kappa: `464159`;
- max states: `200`;
- iterations: `500`;
- model source: `6e542e3f1db125202d42b59f390c922281e64f39`;
- PCA path:
  `/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca_scores.h5`;
- PCA SHA-256:
  `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912`.

## Decision basis

Pre-result design, run, Phase A, and Phase B provenance records were searched
for an unambiguous exact-artifact declaration such as primary model, canonical
production model, production candidate, or visualization incumbent. No such
artifact-level production binding was found.

Both phases use “incumbent” for the kappa-`464159` model inside that seed's own
candidate grid. That establishes reuse within each phase, not a cross-seed
production-artifact preference. It therefore does not override the frozen
fallback.

The Architect fallback selects seed `20260802` because it is the first-seed
incumbent / primary experimental lineage. Seed `20260803` was introduced as the
independent replication and conjunction lineage. The choice is based only on
role and chronology.

No crowd movie, syllable result, PCA/model validation diagnostic,
genotype/treatment result, likelihood aesthetic, or biological output was
inspected or used.

## Primary evidence

- seed-A run receipt:
  `/home/ajm/moseq2-validation-20260730/analysis/locked_464159_k200_long_chain_convergence_sentinel_20260812_R1/RUN_RECEIPT.json`;
- seed-A Phase A provenance:
  `/home/ajm/moseq2-validation-20260730/analysis/locked_k200_500iter_final_kappa_phase_A_seed20260802_20260812_R1/evidence/PROVENANCE_kappa464159.json`;
- seed-B Phase B provenance:
  `/home/ajm/moseq2-validation-20260730/analysis/locked_k200_500iter_final_kappa_phase_B_seed20260803_20260813_R1/evidence/PROVENANCE_kappa464159.json`;
- seed-B final-model SHA-256, retained as the replication lineage:
  `a08851c85267d4cc687f4a1d2bb721ea2cf0adca85de96101a1dec4c60eb0209`.

The selected model and PCA were re-hashed from primary bytes on 2026-08-13 and
matched the accepted identities exactly.
