# Codex Audit Repair Round

Date: 2026-07-29

## Scope

This continued the existing repair round. It did not create replacement
branches or PRs, merge code, delete branches, or modify PCA/model.

Supplemental evidence was imported before implementation. Findings were
reproduced against the three previously locked heads and classified in
`ai/REVIEW_LOG.md`.

## Implemented heads

| Repository | Existing draft PR | Prior head | Repair head |
|---|---:|---|---|
| `moseq2-extract` | #6 | `f028801e9a6b54ffa63e22d9e10179ea7419ccc4` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-viz` | #5 | `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | #5 | `192921f1aff3ea58d3b1f268d71731ed222011d2` | `e0b85201226d03e15944473a734f71417698c31e` |

## Defensive changes

- Integer pixel arrays now produce fractional float64 millimetres in extract
  and viz.
- Viz uses one shared invalid-scalar guard at public plotting, analysis, and
  embedding boundaries.
- Corrupt or conflicting provenance is distinct from absent provenance and
  hard-fails.
- Viz derives an effective app flip-correction policy before pooling, including
  for otherwise unstamped files.
- App correction is refused when extraction-time flip metadata exists.
- App journal readers reject non-mapping JSON and preserve fail-closed
  diagnostics for interrupted updates.
- Preview subprocess cleanup happens on both success and processing failure.
- Provenance paths and cross-repository policy/conversion contracts are
  executable from the control repository.
- Storage wording now matches the evidence: process-death fail-closed after
  HDF5/OS flush, with no `fsync` or power-loss guarantee.

## Gate

All four PRs remain draft and unmerged. Findings remain open pending independent
verification; this report is builder evidence, not merge approval.
