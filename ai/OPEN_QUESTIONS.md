# Open Questions

Statuses: `OPEN`, `IN REVIEW`, `ANSWERED`, `DEFERRED`.

| ID | Question | Owner | Status | Evidence needed |
|---|---|---|---|---|
| OQ-001 | Is round 2 structurally clear to proceed to a bounded real-data pilot in the supported legacy environment? | Fable | ANSWERED | Yes, subject to legacy preservation, environment custody, locked-source qualification, and explicit pilot approval. This is not merge approval. |
| OQ-002 | Do PCA and model require another cross-repository audit after the three candidate PRs are adjudicated? | ChatGPT Classic | OPEN | Reconciled findings, dependency-contract trace, and gap analysis at locked SHAs. |
| OQ-003 | What is the exact cause of every broader-suite failure, and is each an environmental blocker or a product defect? | Codex | OPEN | Command, environment report, full traceback, missing input/dependency proof, and base-versus-candidate comparison. |
| OQ-004 | What should the bounded real-recording validation harness execute and retain? | Codex | ANSWERED | `validation/home_pilot_packet/` freezes custody, tests locked source, inventories recordings, requires explicit pilot approval, captures stagewise outputs, and stops before model fitting. |
| OQ-005 | How should legacy unstamped files and mixed-policy datasets be handled operationally? | AJ | OPEN | Inventory, compatibility evidence, failure-mode tests, and proposed migration/quarantine rules. |
| OQ-006 | What belongs in the final vanilla-versus-patched documentation after code stabilizes? | ChatGPT Classic | DEFERRED | Final merged source, locked validation runs, recorded methods deltas, and AJ approval. |
| OQ-007 | Is power-loss durability required for the app flip journal, and if so what storage/filesystem matrix must it support? | AJ / Fable | OPEN | Explicit durability requirement, `fsync`/HDF5 design review, power-cut or VM-host-death tests, and network/FUSE policy. |
| OQ-008 | What exact commits of `pyhsmm`, `pybasicbayes`, and `autoregressive` are installed in Katya's environment? | Home pilot / Fable | OPEN | `direct_url.json`, package metadata, editable-source Git evidence, Conda records, and explicit `UNRESOLVED` disposition when no SHA can be recovered. |
| OQ-009 | What variability does the unseeded pinned-Dask `svd_compressed` PCA stage show within the legacy environment? | AJ / Fable | OPEN | Record the Dask 2.30.0 signature and positional binding, then run the separately approved bounded within-environment repeatability plan. |
| OQ-010 | What exact flip-classifier file is active for Katya's study? | Home pilot | OPEN | Config/package reference, absolute path, SHA-256, bytes, file type, and retained custody record. |
| OQ-011 | Is an active `sitecustomize.py` part of Katya's production runtime? | Home pilot | OPEN | Active import path, exact archived bytes, SHA-256, and `sys.path` evidence. |
| OQ-012 | Can the nine currently absent viz fixture/data tests be restored and run in Katya's environment? | Home pilot / Fable | OPEN | Exact fixture inventory, collection result, raw failures, and provenance of any recovered fixture bytes. |
| OQ-013 | What would be required for NumPy 2 compatibility? | None in this study | DEFERRED | Out-of-scope future work only. The legacy `np.string_` writer block is recorded; no modernization work is planned here. |
| OQ-014 | Can the golden WSL produce a `COMPLETE` offline deployment lock with every exact package artifact and a golden known-answer manifest? | Home pilot / Fable | OPEN | Exact Conda builds and cache artifacts, pip artifacts, three Git dependency commits and bundles, classifier/sitecustomize/config custody, golden fingerprint, and `moseq-known-answer-v1` expected results. Until then no future machine can qualify. |
