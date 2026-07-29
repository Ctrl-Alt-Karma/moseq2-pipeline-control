# Legacy Production Risk Register

Date: 2026-07-29

The production target is frozen at Katya's existing Python 3.7 / NumPy 1.18.3
environment. This register preserves risks inside that boundary. It is not a
modernization backlog.

| ID | Risk | State | Control |
|---|---|---|---|
| R-001 | `pyhsmm`, `pybasicbayes`, and `autoregressive` were installed from floating Git `master` references; exact installed commits are not yet known. | OPEN | `01_freeze_legacy_environment.sh` inspects package metadata, `direct_url.json`, editable trees, Conda records, and bounded Git ancestry. It records `UNRESOLVED` rather than guessing. |
| R-002 | Pinned-Dask `svd_compressed` is called without an explicit seed; PCA may vary within the production environment. | OPEN | Preserve the actual Dask signature and runtime controls. Use `07_repeatability_plan.md` only after separate approval; never auto-run repeated fits. |
| R-003 | The active sklearn flip-classifier file is primary study custody and has not yet been identified by exact bytes. | OPEN | Resolve through bounded config/package references; record path, SHA-256, byte count, and file type before pilot approval. |
| R-004 | An active `sitecustomize.py` may be required for the working environment but its bytes are not yet in custody. | OPEN | Import the active module, record its source path and `sys.path`, archive exact bytes, and hash them. |
| R-005 | Nine viz tests are blocked by absent repository fixture/data files, leaving legacy metadata behavior insufficiently exercised. | OPEN | Preserve exact collection and failure output in the home qualification run. Recover fixtures only from an authoritative source and hash them. |
| R-006 | The legacy extract provenance writer is incompatible with NumPy 2 because it calls `np.string_`. | ACCEPTED / OUT OF SCOPE | Katya's supported NumPy is 1.18.3. Do not patch production code or plan modernization under this study. |
| R-007 | The WSL image is a single point of failure until exported and stored separately. | OPEN | Run the explicit Windows backup script first; record archive bytes and SHA-256. The backup is never part of an automatic run-all command. |

All unresolved custody items must remain explicit in the Fable evidence packet.
