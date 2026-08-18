# Post-R6 Comparator Correction — Independent Verification Summary

**1. Tip and parent.** `1cd7c900780a423f2b2186025ee3a324b2bf7fbd` is the exact tip of `claude/r1-r6-comparator-correction-r1`, a single commit whose parent is `54d8d7b5…`, which is canonical `main`'s current tip. Verified from fetched git objects; nothing rewritten.

**2. Six critical identities, independently recomputed over canonical bytes at the tip, all exact:** comparator `0697df76…` (matches receipt, OQ-V6-011, and contract MD), contract JSON `b5e2dcb3…` (receipt + MD), contract MD `9f0da41a…` (OQ), qualification script `06bb6c3d…` (OQ), qualification receipt `58ac1137…` (OQ + MD), and R6 packet manifest `3bfc5ac0…` unchanged at 75 members (previously file-level verified 75/75).

**3. Seal.** `R1_FINAL_SEAL_R1.json` at the tip hashes `ac0cde7d…` — byte-untouched, as at every commit since the original correction.

**4. Contract partition.** Exactly **25 MUST_MATCH / 19 DECLARED_IGNORED**. I16-I19 read verbatim: each names one fully-qualified field path ending `…/pipeline/written` or `…/provenance/written` under a specific file glob — the extract HDF5, PCA HDF5, and the two summary JSONs — each justified as the locked writer's `datetime.now().isoformat()` stamp. The `field_ignored` matcher requires the file glob **and** the exact field-tail match, so a sibling like `written_by` or any other name cannot match `*/written`.

**5. Exhaustive-by-field.** `_provenance_units` expands the provenance JSON blob into one comparison unit per leaf field; only units matching I16-I19 are excused, every other field (listed or future-unlisted) lands in MUST_MATCH comparison, and an unparseable record stays opaque and fails closed. Proven live, not just read: Q28 (other extraction-provenance field differs → FAIL), Q29 (policy field → FAIL), Q30 (other PCA-provenance field → FAIL).

**6. Acquisition timestamp still fails.** Contract M17 keeps `metadata/acquisition/*` MUST_MATCH, the addendum block records `acquisition_timestamps_remain_must_match: true`, and **Q31 executed live: acquisition-timestamp difference → FAIL.**

**7. Numeric strictness intact.** `array_digest` retains full `dtype.str` + shape + exact C-order bytes for every non-string dtype; the relaxation to `dtype.kind` applies only to `U`/`S`/`O` arrays, whose canonicalised leaf contents are still compared exactly. **8.** Fixed-width capacity is therefore the *only* thing normalized, and only post-canonicalization — Q35 live: `S<N>` widths differing solely from run-root length with identical content → PASS, while string *content* differences still fail through the leaf comparison.

**9. Qualification.** Executed the complete suite at the tip in an isolated synthetic environment (legacy-`tifffile` delegating shim, sealed code unmodified): **37/37 PASS, OVERALL PASS, exit 0**, matching the tracked receipt (`status PASS, case_count 37`, all case results PASS), including all of Q28-Q37.

**10. Q32, narrowly characterized.** Q32 establishes only that a heap-address-bearing `repr` of the embedded model object no longer false-fails a replay: the object is reduced to a deterministic presence marker per the pre-existing M20 rule. It is a run-instance-representation regression test, **not** evidence of model-semantic equivalence — and semantic model content remains fully bound, proven by its bracketing controls: Q33 (missing model key → FAIL) and Q34 (model/run/whitening parameter perturbation → FAIL). The contract prose makes no equivalence claim (zero matches for any such phrasing).

**11. No candidate data.** Receipt records `synthetic_fixture_only: true, candidate_data_read: false`; the correction block records `corrected_comparator_run_against_r6: false` and `r6_outputs_preserved_and_not_rerun: true`, so the verdict rests on synthetic fixtures, not preserved R6 outputs; and the only UUID-shaped strings in the entire delta are the two self-evidently synthetic fixtures (`11111111-…`, `aaaaaaaa-…`). The addendum's disclosure of two run-instance extraction UUIDs printed during the first R6 diagnostic pass concerns generated uuid4s, not candidate identities, and is consistent with the redaction policy.

No material discrepancies. One standing note carried forward unchanged: the suite still presumes the golden host's legacy `skimage.external.tifffile` import.

PASS_FABLE_VERIFIER_R1_R6_COMPARATOR_CORRECTION

STOP.
