# R1 predetermined replacements — sanitized pointer

Local root (not repository-accessible):
`/home/ajm/moseq2-validation-20260730/evidence/r1_predetermined_replacements_r1`

| Artifact | SHA-256 |
|---|---|
| `R1_PREDETERMINED_REPLACEMENT_RECEIPT.json` | `c6f1fd96af1d0e671dac8a681402d0d541288f2882b2a67ef34fcb27c3a25aee` |
| `R1_PREDETERMINED_REPLACEMENT_RECEIPT.md` | `7b269f4e726023e7914c7f5f8cb15ebc5c7e99ea46023f01b8ea6af8cb7ba39b` |
| `SHA256SUMS` | `bfa115f2b66341c2f19a685118ec6e2f35247b91cd970eeb77a28d30cbe1ed17` |

The frozen primary roster is **unchanged**. Replacements were derived deterministically
and result-blind from the accepted eligible universe by nearest rank distance to each
selected anchor, ties to the earlier anchor, then ordered by rank distance, acquisition
time and candidate id.

Reproduced exactly: eligible singleton universe Rig 1 36 / Rig 2 29, matching the
accepted roster receipt; anchors reproduce the frozen primaries. Proven: eight
non-empty strata; 57 replacements; every eligible non-primary candidate assigned
exactly once; no overlap between queues; no primary appearing in any queue.

A replacement may be used only when a primary is proven input-invalid **before** any
validation-model result is inspected, and never because of PCA or model output,
syllable content, visualization, genotype or treatment behaviour, or an inconvenient
scientific result.

Candidate identities are deliberately not published.
