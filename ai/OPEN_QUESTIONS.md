# Open Questions

Statuses: `OPEN`, `IN REVIEW`, `ANSWERED`, `DEFERRED`.

| ID | Question | Owner | Status | Evidence needed |
|---|---|---|---|---|
| OQ-001 | What is the independent verdict on extract PR #6, viz PR #5, and app PR #5 after the F-01–F-15 repair? | Fable | IN REVIEW | Source review at the new locked head SHAs; red-old/green-new tests; per-finding verdicts in `REVIEW_LOG.md`. |
| OQ-002 | Do PCA and model require another cross-repository audit after the three candidate PRs are adjudicated? | ChatGPT Classic | OPEN | Reconciled findings, dependency-contract trace, and gap analysis at locked SHAs. |
| OQ-003 | What is the exact cause of every broader-suite failure, and is each an environmental blocker or a product defect? | Codex | OPEN | Command, environment report, full traceback, missing input/dependency proof, and base-versus-candidate comparison. |
| OQ-004 | What should the later real-recording validation harness execute and retain? | ChatGPT Classic | DEFERRED | Approved structural candidate, representative recording inventory, data manifest, checksums, resource budget, and expected structural outputs. |
| OQ-005 | How should legacy unstamped files and mixed-policy datasets be handled operationally? | AJ | OPEN | Inventory, compatibility evidence, failure-mode tests, and proposed migration/quarantine rules. |
| OQ-006 | What belongs in the final vanilla-versus-patched documentation after code stabilizes? | ChatGPT Classic | DEFERRED | Final merged source, locked validation runs, recorded methods deltas, and AJ approval. |
| OQ-007 | Is power-loss durability required for the app flip journal, and if so what storage/filesystem matrix must it support? | AJ / Fable | OPEN | Explicit durability requirement, `fsync`/HDF5 design review, power-cut or VM-host-death tests, and network/FUSE policy. |
