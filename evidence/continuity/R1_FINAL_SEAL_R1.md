# R1 final seal — pointer

Protocol `REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1` is **SEALED — ARCHITECT R1**.

- Architect disposition: `PASS_ARCHITECT_R1_TIER_B_CORPUS_ENVELOPES_R1`
- Canonical pre-seal parent: `a97e20c444de5312fa2f23b48c76816137f2df44`
- Pre-seal matrix: 10 CLOSED / 0 PARTIALLY ESTABLISHED / 0 OPEN
- Seal record: `validation/protocols/R1_FINAL_SEAL_R1.json`, SHA-256 `b6d4089eeba624d446b7cdd8c99508505b36192ee809b034ee39922fe68a58aa`

Tier-B numerical envelopes, in plain text:

    B1_lower = 2.410095327226669
    B1_upper = 3.925567393155021
    B2_lower = 0.9979228486646884

The seal binds the frozen production model `5e10803a...`, PCA `26e30500...`, corpus
order `cb1a7b46...`, the frozen roster and predetermined replacement receipts, the
visualization orientation qualification, the Tier-B formula freeze and corpus
envelopes, Tier-C, the Tier-E negative-control condition, the deterministic replay
binding, and the accepted R3 operator `59b15ce7...`.

No validation-candidate result was inspected and no candidate scientific processing
occurred before the seal. Sealing is documentary; the next scientific execution
requires separate Architect authorization. Protected candidate identities are not
published.


---

## ADDITIVE CORRECTION 2026-08-17 — seal artifact hash identity

Controlling canonical identity of `validation/protocols/R1_FINAL_SEAL_R1.json`:
SHA-256 `ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2`, Git blob SHA-1 `5de59c6a5446cec5ec05faf62b53e91a5a672580`, 3,540 bytes, pure LF.

The `b6d4089eeba624d446b7cdd8c99508505b36192ee809b034ee39922fe68a58aa` value stated above is **historical CRLF worktree representation only**
(`CRLF_WORKTREE_REPRESENTATION`), not the controlling identity. Seal bytes unchanged;
JSON semantics identical; no scientific state changed.

Verbatim verifier report: `evidence/continuity/R1_REPOSITORY_HASH_PROVENANCE_CHECK_FABLE.md`.
