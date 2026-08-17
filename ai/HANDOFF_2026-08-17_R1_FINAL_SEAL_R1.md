# Handoff — R1 final seal (2026-08-17)

Live handoff. Additive; predecessors immutable.

## Sealed

`REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1` is **SEALED — ARCHITECT R1** on
`PASS_ARCHITECT_R1_TIER_B_CORPUS_ENVELOPES_R1`, from canonical pre-seal parent
`a97e20c444de5312fa2f23b48c76816137f2df44`, with the pre-seal matrix at
**10 CLOSED / 0 PARTIALLY ESTABLISHED / 0 OPEN**.

Durable seal record: `validation/protocols/R1_FINAL_SEAL_R1.json`, SHA-256
`b6d4089eeba624d446b7cdd8c99508505b36192ee809b034ee39922fe68a58aa`.

## Tier-B envelopes

    B1_lower = 2.410095327226669
    B1_upper = 3.925567393155021
    B2_lower = 0.9979228486646884

B1 two-sided, B2 lower-only, every breach HOLD FOR ADJUDICATION.

## What the seal does and does not do

It records that every pre-result binding was frozen **before any
validation-candidate result existed** — the property that makes the coming run
confirmatory rather than exploratory. It does **not** authorize execution. No
candidate has been accessed or processed; `scientific_processing_started` remains
false.

## Next authorized action

Separate Architect authorization for the R1 execution operation. Nothing in this
handoff permits extraction, PCA or model application to candidates, diagnostics,
visualization, Tier-E execution or replay.


---

## ADDITIVE CORRECTION 2026-08-17 — seal artifact hash identity

The original wording above is preserved as written and is not rewritten.

The controlling canonical identity of `validation/protocols/R1_FINAL_SEAL_R1.json`
is SHA-256 `ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2` over canonical Git object bytes (Git blob SHA-1 `5de59c6a5446cec5ec05faf62b53e91a5a672580`, 3,540 bytes,
pure LF).

The value `b6d4089eeba624d446b7cdd8c99508505b36192ee809b034ee39922fe68a58aa` stated above is **historical CRLF worktree representation only** — the
Windows `core.autocrlf` materialization of the same tracked-LF bytes. It is not the
controlling canonical identity.

The seal artifact bytes were never modified, the JSON semantics are identical, and no
scientific state changed. Verbatim verifier report: `evidence/continuity/R1_REPOSITORY_HASH_PROVENANCE_CHECK_FABLE.md`.
