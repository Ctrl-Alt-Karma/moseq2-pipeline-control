# Review Log

## 2026-08-13 — final-kappa closeout and project lessons

### Final-kappa disposition

- Phase A seed `20260802`: independently verified `SEED_RESOLVED`, winner
  `464159`, 66/66 singleton winner sets.
- Phase B seed `20260803`: independently verified `SEED_RESOLVED`, winner
  `464159`, 66/66 singleton winner sets.
- Independent disposition: `FABLE_VERIFIER_PASS_PHASE_B_FINAL_KAPPA`.
- Architect disposition: `ARCHITECT_V4_FINAL_PRODUCTION_KAPPA_SELECTED_464159`.
- Mechanically reverified manifests: Phase A 74/74; Phase B 103/103.
- Correct full Phase B verifier transport SHA-256:
  `48a3e69baaaeaf91d70eff682bdf55b4ebc54e5414b2b2001db9e86bb1dce8b1`.

### Lesson 1 — Phase A verifier semantics

When a reviewer must characterize frozen executable semantics, provide the
authoritative executable rule, protocol, and conformance receipt when practical.
Do not rely on prose reconstruction. Phase A's first review had sufficient
numeric evidence to reproduce the result but characterized the practical-winner
and absolute-adequacy semantics incorrectly; the authoritative artifacts enabled
the independent correction and direct scorer execution.

### Lesson 2 — transport manifest / exclusion set equality

Transport construction and verification should enforce:

`manifest members = physical transport members UNION explicit exclusion members`

with exact set equality. Every omitted manifested member belongs in the
exclusion ledger regardless of artifact type. Phase B's six unledgered pycache
omissions were independently classified as non-load-bearing package bookkeeping,
but harmlessness does not make the constructor rule correct.

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

Repair-round dispositions are separate from adjudication status:
`CONFIRMED`, `PARTIALLY CONFIRMED`, or `REJECTED`. A confirmed finding can be
implemented while its adjudication remains `OPEN` pending independent review.

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

## Supplemental Fable audit repair round — F-01 through F-15

Source packet:
`ai/reviews/OPUS_FABLE_2026-07-29/FABLE_AUDIT_EXPORT_2026-07-29.md`.
Every executable finding was run against the old candidate head before code was
changed. The defensive reproduction summary is in
`evidence/summaries/CODEX_2026-07-29_REPAIR_REPRODUCTIONS.md`.

All entries below remain **OPEN / PENDING INDEPENDENT VERIFICATION**. “Implemented”
means the builder supplied a repair and a red-at-old/green-at-new regression; it
does not pre-approve a merge.

Verification-only addendum status:

| ID | Builder status |
|---|---|
| F-02 | IMPLEMENTED, EXTERNAL VERIFICATION PENDING |
| F-04 | IMPLEMENTED, EXTERNAL VERIFICATION PENDING |
| F-08 | IMPLEMENTED, EXTERNAL VERIFICATION PENDING |

These three statuses remain pending until Fable verifies the exported bytes.
The status does not alter the original reproduction disposition below.

| ID | Disposition | Reproduction and judgment | Implementation commit(s) | Green regression / remaining limitation |
|---|---|---|---|---|
| F-01 | CONFIRMED | Public plotting selectors accepted the invalid scalar because they had no shared guard. | viz `b80192dc20353bf77c36610f315543b57afa908c` | Public plotting, statistics, and embedding guard tests pass. Unknown third-party entry points remain outside inventory. |
| F-02 | CONFIRMED | The old viz test compared against a third hardcoded policy copy, so it could not detect cross-repo drift. | control contract `43eb14a920c0c01d454e0067ca3ee440b34c2e21` | `test_extract_policy_keys_match_viz_pooling_contract` imports neither package and fails on missing/wrong sibling heads. |
| F-03 | CONFIRMED | Malformed and non-mapping JSON was treated as absent; an all-corrupt set reached the warning-only unstamped branch. | viz `b80192dc20353bf77c36610f315543b57afa908c` | Corrupt, one-corrupt/one-valid, and conflicting-dual-path tests now hard-fail. |
| F-04 | CONFIRMED | The old cross-package numerical test required undeclared `moseq2_extract`; a clean viz environment could not collect it. | viz `b80192dc20353bf77c36610f315543b57afa908c`; control `43eb14a920c0c01d454e0067ca3ee440b34c2e21` | Undeclared import removed; source-level cross-repo contract owns equality. |
| F-05 | CONFIRMED | Valid JSON scalars such as null/number/string raised uncaught attribute errors before the mutation try-block. | app `e0b85201226d03e15944473a734f71417698c31e` | Non-mapping record regressions return fail-closed corrupt state. |
| F-06 | PARTIALLY CONFIRMED | In-process exceptions were not process-death tests. Real abrupt termination confirmed fail-closed semantics, but Windows did not reproduce the verifier’s exact Linux slot persistence at `after_new_slot_create`. | app `e0b85201226d03e15944473a734f71417698c31e` | Five-checkpoint subprocess-death matrix passes on Windows; independent Linux SIGKILL rerun remains required. |
| F-07 | CONFIRMED | Source contains HDF5 flushes and no `fsync`; “durable” overstated the guarantee. | app `e0b85201226d03e15944473a734f71417698c31e`; control `20249e42eda3cd674f651c0011dbbd99e62cf774` | Wording now says HDF5/OS-flushed and explicitly excludes power loss, host/kernel failure, network/FUSE semantics, and HDF5 metadata atomicity. No power-loss durability is claimed. |
| F-08 | CONFIRMED | Extract and viz deliberately retain independent conversion functions, but the old equality check was not executable in viz’s declared environment. | extract `e7f585104ba25b66e5326c88c77a47e33db95635`; viz `b80192dc20353bf77c36610f315543b57afa908c`; control `43eb14a920c0c01d454e0067ca3ee440b34c2e21` | Cross-repo contract checks float and integer inputs at the locked heads. Duplication remains deliberate to avoid a runtime dependency. |
| F-09A | CONFIRMED | App correction changed angle semantics but viz ignored the processing record, allowing corrected/uncorrected or differently corrected sessions to pool. | viz `b80192dc20353bf77c36610f315543b57afa908c` | Effective `flip_correction` policy is derived from app journal state even for unstamped files; incompatible or ambiguous states refuse pooling. |
| F-09B | CONFIRMED | Layering app correction on a session with extraction-time flip metadata produced a pi orientation delta while leaving extraction metadata stale for direct consumers. | app `e0b85201226d03e15944473a734f71417698c31e`; control `43eb14a920c0c01d454e0067ca3ee440b34c2e21` | App refuses before mutation whenever `metadata/extraction/flips` exists. Existing already-layered files are detected, not repaired. |
| F-10 | PARTIALLY CONFIRMED | The old reader did skip slot inspection when the sentinel was set. The packet’s stronger claim that the complete slot was power-loss durable and safe to auto-trust conflicts with F-07 and is not established. | app `e0b85201226d03e15944473a734f71417698c31e` | Reader now inspects and returns slot diagnostics but keeps the authoritative sentinel fail-closed. Recovery still requires restoration/re-extraction; no unsafe auto-repair was added. |
| F-11 | CONFIRMED | Batch exceptions bypassed preview finalization and the pipe handle lived outside the per-session scope. | app `e0b85201226d03e15944473a734f71417698c31e` | Mid-batch cleanup regression proves the child is finalized while the original processing exception is preserved. |
| F-12 | CONFIRMED | App and viz preferred opposite provenance paths. | app `e0b85201226d03e15944473a734f71417698c31e`; viz `b80192dc20353bf77c36610f315543b57afa908c`; control `43eb14a920c0c01d454e0067ca3ee440b34c2e21` | Both readers and the cross-repo contract use canonical `metadata/extraction/pipeline` first and reject conflicting dual records. |
| F-13 | PARTIALLY CONFIRMED | The candidate expectation edit had no causal production change, as reported. A synthetic source-order change did reproduce unstable public column order. | viz `b80192dc20353bf77c36610f315543b57afa908c` | Metadata columns now follow the explicit `include_keys` API order. Absent historical fixture data still blocks the original fixture-backed test. |
| F-14 | CONFIRMED | `zeros_like` inherited integer dtype and truncated fractional millimetres; the old expectation accepted truncation. | extract `e7f585104ba25b66e5326c88c77a47e33db95635`; viz `b80192dc20353bf77c36610f315543b57afa908c`; control `43eb14a920c0c01d454e0067ca3ee440b34c2e21` | Both functions allocate float64; exact integer-input and cross-repo regressions pass. Production’s usual float input reduced impact but did not excuse the API defect. |
| F-15 | CONFIRMED | Both provenance helpers had only definitions, docs, and tests—no production caller. | viz `b80192dc20353bf77c36610f315543b57afa908c`; control `20249e42eda3cd674f651c0011dbbd99e62cf774` | Dead helpers/tests removed; the real HDF5 pooling boundary remains gated. Model-provenance gating is still not claimed. |

## 2026-08-17 — Fable Scientific Counsel, R1 pre-seal reconstruction

- Disposition: `FABLE_COUNSEL_HOLD_R1_PRESEAL_RECONSTRUCTION`.
- Sanitized pointer and access limitation:
  `ai/reviews/FABLE_COUNSEL_2026-08-17_R1_PRESEAL_RECONSTRUCTION.md`.
- Preserved verbatim report SHA-256:
  `2a23377600d06f09dfd52a3a6f097084880bb8683de0606a6c4414ecaa7d2db6`.
- Counsel reviewed the repository at `59b15ce7…` only, without access to
  `/home/ajm`. Its matrix therefore records absence-in-repository.
- Reconciliation against local primary evidence followed on the same date under
  `V5_R1_PRESEAL_EVIDENCE_RECONCILIATION_AND_ARCHITECT_RETIREMENT_SYNC_R1`.
  Two rows moved (OQ-V4-001 CLOSED, OQ-V4-003 partially established); the rest
  stood; OQ-V5-009 and OQ-V5-010 were added. Architect commentary is additive
  and does not rewrite the counsel report.

### Lesson 2 — status assertions drift faster than semantics

Protocol §8 specifies what must be frozen for Tier B. A compression chain
promoted that specification into a claim that the thing had been frozen. The
tense error survived retelling because each paraphrase dropped one hedge. The
control is structural, not stylistic: a status may not move without its closing
artifact in the same change (rule 40), and inherited statuses absent from the
closure matrix are UNVERIFIED by default.

## 2026-08-17 — Architect succession fidelity check

- Result: `PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`, returned by both the
  successor reconstruction and the retiring Architect V5 bounded backward pass.
- Classification: **formal succession fidelity check**, not scientific
  verification. It establishes that the successor's reconstruction of state,
  authority and next action is faithful. It verifies no scientific claim, seals
  nothing, and promotes no OPEN_QUESTIONS row.
- Backward pass found no material omission, contradiction, authority or scope
  error, accidental reopening of settled science, or incorrect interpretation of
  the next authorized action.
- Nonblocking wording correction adopted: the production-model fallback choice is
  **ARCHITECT_ADJUDICATED**, not independently verified.
- Documentary predecessor at the time of the check:
  `0a15f002bbe4ab10f347b1d4035a78486910e896`. BRIDGE unchanged at
  `328c7eee85cf57a5af4211b3d36f5ee7560ebc5d`.

## 2026-08-17 — PROJECT-STATE CONTINUITY / EVIDENCE-NAMESPACE FAILURE

Classification: **continuity and evidence-namespace failure**, not a new scientific
finding. No scientific result changed; no candidate was processed.

- The retiring cockpit produced load-bearing evidence in an artifact namespace that
  durable project state never indexed. Retirement reconciliation searched the
  repository and the Linux evidence root only.
- A scope-limited negative result was reported as global absence, so accepted
  completed work — inventory, roster selection, visualization qualification, Tier-C
  freeze, custody, Tier-E and replay bindings — was recorded as unresolved.
- Formal succession then propagated the defect, because the successor faithfully
  reconstructed a durable record that was itself wrong.
- Recovery: 24/24 pinned artifacts found and hash-matched; ledger
  `f7bb096929bcf3e267752e59e91ba85f1dd078de2fc0d3c999b280c12e1103bc`.
- Owner testimony on acquisition motive was serialized and explicitly confirmed by
  the actor during execution before any dependent row was closed.

### Lesson 3 — absence claims inherit their search scope

A negative existence claim is only as strong as the scope actually searched. Record
the scopes, name the evidence namespaces, and classify unsearched planes as
access-limited rather than absent.

## 2026-08-17 — R1 replacement freeze and Tier-B formula reacquisition

- Replacement freeze: mechanical. Eligible universe reproduced exactly against the
  accepted receipt; anchors reproduced the frozen primaries; coverage, non-overlap
  and non-emptiness proven. ARCHITECT_ADJUDICATED for the rule, MECHANICALLY_VERIFIED
  for the derived queues.
- Tier-B: formula and source semantics only, deliberately performed before any value
  was seen, so no formula could be chosen because its real-data values looked
  convenient. The recommendation is Builder-proposed and not controlling.
- Recorded honestly: reconstruction error is not emitted by the accepted pipeline and
  its residual target is not persisted. No substitute metric was invented to satisfy
  the protocol phrase.

## 2026-08-17 — Tier-B formula freeze

- Independent Scientific Counsel marker `PASS_FABLE_COUNSEL_R1_TIER_B_FORMULA_FREEZE_R1`;
  Architect disposition `PASS_ARCHITECT_COUNSEL_R1_TIER_B_FORMULA_FREEZE_R1`. The local
  counsel receipt is a durable pointer to that accepted result and explicitly does not
  claim the Builder reproduced the review.
- The freeze was performed with no Tier-B value in existence, which is the control
  that makes the metric choice honest rather than convenient.
- Reconstruction error was not substituted with an invented metric. The waiver rests
  on bound source evidence: an unimplemented TODO at `moseq2_pca/pca/util.py:246`.
- Builder note carried forward: corpus B1 values will be in-sample with respect to the
  whitening the corpus itself estimated, so a healthy new session may sit wider than
  corpus extrema. Predeclared as interpretation caution; it does not alter the rule.

## 2026-08-17 — Tier-B corpus envelope computation

- Formula-before-values discipline held end to end: the metric identity was frozen
  while no value existed, then the values were computed under that frozen identity
  without modification.
- 20/20 corpus sessions evaluated, zero fail-loud conditions. Corpus order was taken
  from the frozen model `keys` roster, never the HDF5 group listing, which is the
  trap recorded earlier as D-034.
- Extrema are empirical with no added tolerance. The in-sample caution recorded at
  freeze stands and does not alter the rule.
- All ten pre-seal rows are now closed. R1 sealing remains an Architect action and
  was not performed by the Builder.
