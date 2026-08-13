# Independent audit: Opus 5

Date: 2026-07-29  
Workflow marker supplied by reviewer: `MODE: FABLE / INDEPENDENT VERIFIER`  
Actual verifier model disclosed by reviewer: Claude Opus 5  
Verdict: **READY FOR ANOTHER CODEX FIX ROUND**

## Audited candidates

| Repository | PR | Base SHA | Candidate SHA |
|---|---:|---|---|
| `moseq2-extract` | 6 | `424d643affb685e1cad145e3c7051b814d11265c` | `f028801e9a6b54ffa63e22d9e10179ea7419ccc4` |
| `moseq2-viz` | 5 | `68ca6a34055987ff22f8651b4dca2aa254380c87` | `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e` |
| `moseq2-app` | 5 | `36d40e098a5c4629116b7a4e233573218345bd5d` | `192921f1aff3ea58d3b1f268d71731ed222011d2` |

The reviewer fetched all six trees at the exact SHAs, diffed the bytes, executed the app flip-record state machine with h5py 3.16 / numpy 2.4, and killed child processes at each journal checkpoint. This file records the claims to be reproduced by the builder; it is not builder acceptance of them.

## Positive results

- `velocity_3d_px` is absent from extract output paths.
- Retained velocity calculations are dimensionally consistent.
- FOV-derived focal lengths reproduce as `fx=361.6`, `fy=367.2`; the superseded small-angle values reproduce as `415.5` and `404.9`.
- The app journal remained fail-closed and HDF5-readable under process death at all five injected checkpoints.
- Extraction provenance was not overwritten by the app candidate.

## Findings

### F-01 / P1 / viz public scalar entry points

`scalar_plot(show_scalars=...)` and `position_plot(centroid_vars=...)` accept arbitrary scalar names without calling `check_scalar_is_usable`. The audit also requires inventorying `compute_behavioral_statistics`, `run_2d_scalar_embedding`, and other dataframe-wide consumers.

Falsifier: a manually assembled dataframe containing `velocity_3d_px` can reach a named plotter without `ValueError`.

### F-02 / P1 / cross-repository policy contract

`test_the_required_key_set_is_what_extract_declares` compares viz policy keys with a third hard-coded snapshot in the viz test. It does not import or otherwise inspect extract's `EXTRACT_OUTPUT_POLICIES`.

Falsifier: adding a key in extract does not fail the viz suite.

### F-03 / P1 / corrupt provenance fails open

`read_pipeline_provenance` catches `ValueError`, which includes `JSONDecodeError`, and returns the same value used for absence. If every pooled file is corrupt, the all-unstamped warning branch can proceed. Valid non-object JSON is also not validated as a mapping.

Falsifier: two files containing truncated provenance pool with a warning instead of raising `ProvenanceError`.

### F-04 / P1 / unrunnable numerical agreement test

Viz's only extract/viz pixel-to-mm agreement test imports `moseq2_extract`, but viz does not declare that package as a runtime or test dependency.

Falsifier: a clean viz-only environment cannot collect or run that test.

### F-05 / P1 / non-mapping app records

`read_flip_record` leaks `AttributeError` for JSON `null`, numbers, and strings because it calls mapping methods before validating the parsed value. Lists happen to fail through a caught `TypeError`.

Falsifier: a slot containing `null` aborts instead of returning an explicit fail-closed record.

### F-06 / P1 / fault harness does not model process death

The app test raises an in-process exception. The surrounding HDF5 context manager then closes cleanly and flushes state that is absent after a real abrupt process death.

At `after_new_slot_create`:

- in-process raise: both record slots remain;
- SIGKILL: only the original slot remains.

The design itself passed the verifier's real-death matrix; the test's claim is invalid.

### F-07 / P2 / process-crash scope overclaim

`f.flush()` is an HDF5/OS flush, not a power-loss barrier. No `fsync` exists in the implementation. The word `durable` overstates what the implementation and SIGKILL tests establish.

Required narrow fix: use accurate flushed/process-termination language and explicitly exclude power loss, kernel panic, and host death.

### F-08 / P2 / duplicated conversion contract

Extract and viz contain independent `convert_pxs_to_mm` implementations. They currently agree, but the only binding test is the unrunnable test in F-04.

Preferred disposition from the repair specification: retain the small duplicated runtime functions, keep package dependencies unchanged, and move exact-SHA compatibility checks into this control repository.

### F-09 / P1 / flip correction invisible to pooling

The app changes `scalars/angle` by `+pi` for selected frames and records the operation at `metadata/processing/flip_classifier`. Viz's pooling gate reads extraction pipeline provenance only, so corrected and uncorrected sessions can pool as compatible.

The angle trace found:

- raw ellipse orientation is axial/modulo pi;
- flip correction promotes it to a directed/modulo `2*pi` heading;
- diff consumers are invariant to a global `+pi` shift but not selective shifts;
- raw consumers see populations separated by pi;
- `make_crowd_matrix` reads HDF5 directly and subtracts extraction-time flips; an app pass that does not update `metadata/extraction/flips` can create a per-frame 180-degree render error.

The reviewer did not establish whether app correction is intended to run on an extraction already corrected at extraction time. That precondition must be resolved or enforced before treating the crowd-movie issue as fully classified.

### F-10 / P2 / sentinel diagnostics

When the update sentinel is set, `read_flip_record` reports failure without inspecting valid slots. A complete journal slot can therefore be condemned. Fail-closed behavior is appropriate; the current error message overstates that partial correction is known.

### F-11 / P2 / preview cleanup

Preview finalization is inside the normal `try` path after the batch loop. A loop exception skips `communicate()`, can orphan ffmpeg, and may leave a stale handle across sessions.

Falsifier: raise after preview creation and observe that `communicate()` is not called.

### F-12 / P2 / provenance path disagreement

Extract writes `metadata/extraction/pipeline`. App prefers that path, then `metadata/pipeline`; viz prefers the reverse. If both exist, readers can silently choose different records.

Required behavior: one documented order; both paths may coexist only when semantically identical.

### F-13 / P2 / unexplained test-order churn

Viz changed expected trailing metadata order from `SessionName, SubjectName, StartTime` to `SessionName, StartTime, SubjectName`, although the candidate diff contains no clear production change that should reorder those columns.

The reviewer could not execute the full viz fixture-dependent suite. The cause must be reproduced before deciding whether this is a defect or unrelated expectation churn.

### F-14 / P3 / integer truncation

Both pixel-to-mm implementations allocate with `np.zeros_like(coords)`. Integer input therefore returns integer output and truncates fractional millimetres. The revised viz test asserts those truncated integers.

Observed exact endpoints: approximately `[-476.581, -388.614]` and `[476.581, 388.614]`; stored endpoints: `[-476, -388]` and `[476, 388]`.

### F-15 / P3 / dead model provenance API

`provenance_from_model` and `assert_consistent_provenance` have no production caller. Tests imply a gate that production does not apply.

Required disposition: remove/internalize misleading dead API unless an actual cross-package lineage contract exists. Do not wire undefined compatibility semantics merely to make the functions look used.

## Evidence limitations

- Executable checks ran on Python 3.12.3, h5py 3.16.0, HDF5 2.0.0, numpy 2.4.4, Linux overlayfs—not the projects' pinned Python 3.7 stack.
- The verifier did not run repository test suites; viz tarballs lacked external data fixtures and target older dependencies.
- SIGKILL proves process-death behavior with the OS/page cache surviving. It does not prove power-loss durability.
- Supplied HDF5 fixtures were represented by hashes and observed states, not attached as binary files.

## Source

Imported from the two user-supplied audit/evidence attachments on 2026-07-29. The machine-readable ledger and executable harness are stored under `evidence/`.
