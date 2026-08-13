# Scientific Identity Verification

All checks were read-only and run against the live WSL Ubuntu 22.04 files on
2026-08-13. No scientific command, model fit, resume, PCA calculation, scorer,
visualization, or biological analysis was executed.

| Item | Observed SHA-256 / result |
|---|---|
| PCA | `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912` |
| Locked changepoints | `71565ef2498f27882bbfff5e2ddcc939ed57bc9f8d075161b32f0482bfecea6b` |
| Seed-A kappa-464159 final model | `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964` |
| Seed-B kappa-464159 final model | `a08851c85267d4cc687f4a1d2bb721ea2cf0adca85de96101a1dec4c60eb0209` |
| Exact M_R2 implementation | `24e8523d7af9b6370d34e3a55e7ec049353563fa80d338f6ef3f76d7d42fbe10` |
| Phase A manifest | `53643e27002cc89e2ecbcdaa798dabc60b2ff7b9e62def7d04b5a8b2c100d095`; 74/74 `OK` |
| Phase B manifest | `b07a87756d27c2e72678e1a46fd759eedaa86e0a49ad185f2aa997ab41957ba5`; 103/103 `OK` |
| Full Phase B verifier transport | `48a3e69baaaeaf91d70eff682bdf55b4ebc54e5414b2b2001db9e86bb1dce8b1` |

Sealed dispositions read from primary JSON:

- Phase A: `SEED_RESOLVED`, winner `464159`, 66 winner sets, all singleton;
- Phase B: `SEED_RESOLVED`, winner `464159`, 66 winner sets, all singleton;
- conjunction evidence: `TWO_SEED_CONJUNCTION_SATISFIED_PENDING_ARCHITECT`.

The later Architect and independent Verifier dispositions are recorded in
`ai/CURRENT_STATE.md`; they are adjudications, not claims manufactured by this
mechanical verification.
