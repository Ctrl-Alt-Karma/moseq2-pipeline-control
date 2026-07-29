# Current Task Specification

Date: 2026-07-29

## Objective

1. Independently review:
   - `moseq2-extract` PR #6;
   - `moseq2-viz` PR #5;
   - `moseq2-app` PR #5.
2. Reconcile findings into `ai/REVIEW_LOG.md`.
3. Implement only confirmed findings.
4. Rerun the pinned tests and the red/green falsifying regressions.
5. Keep every PR draft until AJ gives explicit approval.
6. Defer real-data validation until the structural candidate passes independent review.

## Scope boundary

This task covers structural correctness, cross-repository contracts, testability, provenance enforcement, interruption safety, and validation controls. It does not cover experiment design, genotype hypotheses, biological effect expectations, sample-size planning, publication figures, or downstream interpretation.

Any scope expansion must be written here before implementation begins.
