# R1 R6 Post-Comparator-Verification Checkpoint

## Handoff ID

`HANDOFF-2026-08-18-R1-R6-POST-COMPARATOR-VERIFICATION-CHECKPOINT`

This is the live project-state pointer. It is a compact phase delta; immutable
earlier handoffs and scientific evidence remain unchanged. It records a
verification gate closing. It starts no scientific operation.

## Last closed gates

- R1 protocol: **SEALED — ARCHITECT R1**, canonical seal `ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2`, byte-untouched.
- Tier-E negative control: `PASS_R1_TIER_E_NEGATIVE_CONTROL_R1`.
- R6 determinism remediation: built, verified, canonicalized to `main` at `54d8d7b5783c0810088ed96694a6bc10dcd7c94f`.
- R6 execution: eight primaries and the slot-01 replay all exited 0; outputs preserved.
- R6 replay decomposition: identity-redacted and value-blind; established **every
  scientific array and every applied label array bit-exact**.
- **Comparator-correction verification gate: CLOSED.** Independent Verifier
  disposition `PASS_FABLE_VERIFIER_R1_R6_COMPARATOR_CORRECTION` on correction tip
  `1cd7c900780a423f2b2186025ee3a324b2bf7fbd` (parent `54d8d7b5783c0810088ed96694a6bc10dcd7c94f`), with 37 / 37 qualification independently
  reproduced at exit 0.

## Active gate

Comparison-only evaluation of the verified corrected comparator against the nine
already-preserved R6 run outputs. Not yet started, and not authorized by this
checkpoint.

## Verified comparator-correction identities

| Artifact | SHA-256 |
|---|---|
| Correction tip | `1cd7c900780a423f2b2186025ee3a324b2bf7fbd` |
| Parent (canonical main at branch creation) | `54d8d7b5783c0810088ed96694a6bc10dcd7c94f` |
| Contract JSON | `b5e2dcb3c0179ce1dba8bbb499a7335096c570cf1fbb091e0c6e4e00c2128d13` |
| Contract MD | `9f0da41a876b287729c8bc834f60a8e97d21395251d62ea68718ecd311555359` |
| Comparator | `0697df76e49d43b3bf352d41230cd2385e3d5f8bdc87ddaf9eeaeee53c588840` |
| Qualification suite | `06bb6c3dc2e3572c2d79a252cb127586454f7a2ad1279e3184238c4ec426dc9f` |
| Qualification receipt (37/37 PASS) | `58ac11375a4ed4b228123632d646214d20bd89abd27b513b74b8eb68e8766a70` |
| Seal addendum | `f199ca791ec6a7d232b8763b622b25b49cfd007b5d4cb1f4ab217d857b70fdb2` |

Partition **25 MUST_MATCH / 19 DECLARED_IGNORED**, scientific tolerance **0**.
I16-I19 each ignore exactly one fully-qualified writer-generated `.../written`
field; provenance blobs are expanded exhaustively field by field and fail closed;
acquisition timestamps remain MUST_MATCH; numeric arrays retain dtype + shape +
exact C-order byte equality; only fixed-width string storage capacity is
normalized after canonicalization.

`Q32` proves only suppression of unstable heap-address `repr()` noise on the
model-presence-marker path, not model-semantic equivalence. `Q33` still fails on a
missing model key and `Q34` still fails on parameter perturbation.

## Untouched state

- Original final seal `R1_FINAL_SEAL_R1.json`: `ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2`.
- R6 execution packet: `3bfc5ac04dd71f1d7b7a6010442561e2ef3d6399c88ebff88c4390781a59de5e`, 75 / 75.
- Original `REPLAY_COMPARISON_REPORT_R6.json`: `22be3cecc3c586a8f47950802be71fcc689741eeb957340d0d1a94954d288a2c`.
- All nine preserved R6 run directories, plus every R3/R4/R5 output and evidence
  directory.

## Only next authorized scientific operation

Run the **verified corrected comparator** in comparison-only mode against the
nine already-preserved R6 run outputs.

Constraints on that operation:

- it consumes preserved outputs only; it processes no recording and starts no
  extraction, PCA, fitting, decoding or visualization;
- it must emit a **new, separately named** evidence artifact;
- it must not overwrite or mutate `REPLAY_COMPARISON_REPORT_R6.json`, any preserved
  run directory, or the original seal;
- the comparator, contract and qualification must not be tuned against its result;
- on completion, **STOP for Architect adjudication** before any seal advancement or
  candidate work.

## Prohibitions

- No candidate processing of any kind.
- No model fitting, PCA fitting, extraction, decoding or visualization.
- No mutation of preserved R6 run directories or of the original R6 report.
- No modification of the original final seal; no seal advancement or replacement.
- No merge of the correction branch into canonical `main` without separate
  Architect authorization.

## Standing non-blocking note

The qualification suite still assumes the golden host's legacy
`skimage.external.tifffile` import behavior. Non-blocking; recorded so a successor
on a different host does not mistake it for a defect.
