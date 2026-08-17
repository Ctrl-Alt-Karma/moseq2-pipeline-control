# Handoff — R1 seal hash remediation (2026-08-17)

Live handoff. Additive; predecessors immutable.

## State

- **R1 is SEALED.** Protocol status `Status: **SEALED — ARCHITECT R1**`.
- Matrix: **10 CLOSED / 0 PARTIALLY ESTABLISHED / 0 OPEN**.
- Canonical seal artifact SHA-256: **`ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2`**
  (Git blob SHA-1 `5de59c6a5446cec5ec05faf62b53e91a5a672580`, 3,540 bytes, pure LF).
- **`b6d4089eeba624d446b7cdd8c99508505b36192ee809b034ee39922fe68a58aa` = CRLF_WORKTREE_REPRESENTATION only.** It is preserved in historical records
  and is not the controlling identity.
- **No scientific state changed.** The seal artifact bytes were never modified; JSON
  semantics are identical; model, PCA, corpus, Tier-B, Tier-C, Tier-E, replay and
  operator identities are untouched.
- **No candidate science has occurred**; `scientific_processing_started` remains false.

## Standing rule adopted

SHA-256 bindings of repository-tracked text artifacts are taken over canonical Git
object bytes at a pinned revision, never a working tree. A worktree-derived hash may
be recorded only when explicitly labelled with its representation and line-ending
provenance.

## Next authorized action

Separate Architect authorization for R1 execution. Nothing here permits extraction,
PCA or model application to candidates, diagnostics, visualization, Tier-E execution
or replay.
