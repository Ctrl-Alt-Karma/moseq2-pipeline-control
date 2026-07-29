# Review Log

## Schema

Each finding must contain:

- **finding ID**
- **repository**
- **severity**
- **status**
- **raised by**
- **independently verified by**
- **candidate commit**
- **exact evidence**
- **required falsifying test**
- **implementation commit**
- **remaining limitation**

Allowed adjudication statuses are `OPEN`, `FIXED`, `REJECTED`, and `NEEDS REAL DATA`.

`PENDING INDEPENDENT VERIFICATION` is a verification marker, not an adjudication status. Seeded claims remain `OPEN`; none is `FIXED` until an independent verifier checks current source and the required falsifying regression.

## Seeded findings

### EXTRACT-001 — mixed-unit velocity scalar

- **repository:** `Ctrl-Alt-Karma/moseq2-extract`
- **severity:** critical
- **status:** OPEN
- **raised by:** prior repair review; replacement PR #6 claim
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `f028801e9a6b54ffa63e22d9e10179ea7419ccc4`
- **exact evidence:** Candidate changes `moseq2_extract/extract/proc.py` and `moseq2_extract/util.py`; it claims `velocity_3d_px` mixed pixel/frame x-y components with a millimetre/frame z component and is now omitted with policy `invalid-mixed-units-omitted`.
- **required falsifying test:** On the buggy base, a nonzero x/y motion plus height change must emit the invalid key; on the candidate, `tests/unit_tests/test_extract_proc.py::TestExtractProc::test_compute_scalars_nonzero_velocity_components` must independently calculate the retained velocities and prove the invalid key is absent.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** Nominal FOV-derived intrinsics remain in use; calibrated camera intrinsics are not wired through extraction.

### EXTRACT-002 — scalar regression must not be vacuous

- **repository:** `Ctrl-Alt-Karma/moseq2-extract`
- **severity:** high
- **status:** OPEN
- **raised by:** prior repair review; replacement commit `f028801e...`
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `f028801e9a6b54ffa63e22d9e10179ea7419ccc4`
- **exact evidence:** Candidate adds a nonzero regression in `tests/unit_tests/test_extract_proc.py`; the test must not merely mirror the production formula or use all-zero components.
- **required falsifying test:** Mutate or restore the mixed-unit calculation at the base and show the nonzero regression fails; restore the candidate and show it passes with fixed independently derived expected values.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** Synthetic coverage does not establish real-camera calibration accuracy.

### VIZ-001 — pinhole conversion must agree with extract

- **repository:** `Ctrl-Alt-Karma/moseq2-viz`
- **severity:** critical
- **status:** OPEN
- **raised by:** prior repair review; replacement PR #5 claim
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`
- **exact evidence:** Candidate changes `moseq2_viz/scalars/util.py` from a small-angle approximation to `tan(deg2rad(fov / 2))`; `tests/unit_tests/test_scalar_utils.py::TestPinholeProjection` claims fixed-value and cross-package checks.
- **required falsifying test:** Replace `tan(deg2rad(...))` with `deg2rad(...)`; fixed focal-length, one-pixel displacement, and extract-equality tests must fail.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** Agreement between two nominal-FOV implementations does not equal calibrated-intrinsics validation.

### VIZ-002 — deprecated scalar must fail closed at public entry points

- **repository:** `Ctrl-Alt-Karma/moseq2-viz`
- **severity:** critical
- **status:** OPEN
- **raised by:** prior repair review; replacement PR #5 claim
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`
- **exact evidence:** Candidate changes `moseq2_viz/scalars/util.py`; it claims legacy `velocity_3d_px` is dropped on load and rejected when manually supplied to public scalar-name APIs, including `compute_mean_syll_scalar`.
- **required falsifying test:** Supply a manually assembled dataframe containing `velocity_3d_px` to every public scalar selector and prove the candidate rejects it while valid scalar names still pass.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** Unknown third-party consumers may bypass these public entry points.

### VIZ-003 — deprecated-scalar filtering must preserve mappings

- **repository:** `Ctrl-Alt-Karma/moseq2-viz`
- **severity:** high
- **status:** OPEN
- **raised by:** prior repair review; replacement PR #5 claim
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`
- **exact evidence:** Candidate claims `drop_deprecated_scalars()` previously converted a mapping to a list, causing a dict-to-list crash through `get_scalar_map()`.
- **required falsifying test:** Pass legacy numeric mappings directly and through `get_scalar_map()`; assert the return type and surviving key/value associations remain mappings after the deprecated key is removed.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** Mapping subclasses and external dataframe adapters are not yet inventoried.

### VIZ-004 — provenance must enforce real compatibility and expose parse errors

- **repository:** `Ctrl-Alt-Karma/moseq2-viz`
- **severity:** critical
- **status:** OPEN
- **raised by:** prior repair review; replacement PR #5 claim
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`
- **exact evidence:** Candidate changes `moseq2_viz/util.py`; it claims extraction policies are compared only within a package, cross-package no-op comparisons are refused, model provenance parse errors propagate, and unstamped inputs are described as unknown.
- **required falsifying test:** Cover conflicting same-package policies, stamped/unstamped mixes, all-unstamped inputs, disjoint package maps, malformed model provenance, required-but-undeclared policies, and explicit override warnings.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** Legacy unstamped and mixed-policy handling still needs an AJ-approved operating policy.

### APP-001 — interruption must not permit silent reprocessing

- **repository:** `Ctrl-Alt-Karma/moseq2-app`
- **severity:** critical
- **status:** OPEN
- **raised by:** prior repair review; replacement PR #5 claim
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `192921f1aff3ea58d3b1f268d71731ed222011d2`
- **exact evidence:** Candidate changes `moseq2_app/flip/widget.py`; it claims `in_progress`, `failed`, and `complete` all keep the legacy Boolean latch true and partial sessions hard-fail on rerun.
- **required falsifying test:** Inject a crash after frames are touched, rerun, and byte-compare frames/angles to prove the rerun refuses rather than double-flipping any processed prefix.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** Detection is not rollback; damaged partial outputs require restoration or re-extraction.

### APP-002 — processing-record updates must fail closed at every stage

- **repository:** `Ctrl-Alt-Karma/moseq2-app`
- **severity:** critical
- **status:** OPEN
- **raised by:** prior repair review; replacement PR #5 claim
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `192921f1aff3ea58d3b1f268d71731ed222011d2`
- **exact evidence:** Candidate adds a durable update sentinel and two-slot journal at `metadata/processing/flip_classifier` and its journal path.
- **required falsifying test:** Fault-inject before and after every record-update stage; every recoverable state must read as latched or failed, never pristine.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** HDF5 and filesystem durability still depend on the host storage stack honoring flush semantics.

### APP-003 — preview completion must reflect the subprocess result

- **repository:** `Ctrl-Alt-Karma/moseq2-app`
- **severity:** high
- **status:** OPEN
- **raised by:** prior repair review; replacement PR #5 claim
- **independently verified by:** PENDING INDEPENDENT VERIFICATION
- **candidate commit:** `192921f1aff3ea58d3b1f268d71731ed222011d2`
- **exact evidence:** Candidate claims the optional preview subprocess is awaited with `communicate()`, its return code is inspected, and the true preview result is recorded before completion.
- **required falsifying test:** Exercise success, nonzero exit, and preview-only failure; completion must never be committed before the preview result is known, while frame correction may still complete when preview generation fails.
- **implementation commit:** not accepted; candidate head only
- **remaining limitation:** Platform-specific ffmpeg behavior remains broader-suite work.
