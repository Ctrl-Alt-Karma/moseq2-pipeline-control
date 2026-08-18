# R1 deterministic replay comparison contract

Governs: **OQ-V6-011**
Classification: **POST_R6_REPLAY_COMPARATOR_IMPLEMENTATION_CORRECTION** (the original freeze was PRE_EXECUTION_CLARIFICATION and that history stands)
Machine-readable partition: `REPLAY_COMPARISON_CONTRACT_R1.json`
(SHA-256 `b5e2dcb3c0179ce1dba8bbb499a7335096c570cf1fbb091e0c6e4e00c2128d13`)
Comparator: `compare_r1_replay.py`
(SHA-256 `0697df76e49d43b3bf352d41230cd2385e3d5f8bdc87ddaf9eeaeee53c588840`)
Qualification receipt: `tests/REPLAY_COMPARATOR_QUALIFICATION_RECEIPT.json`
(SHA-256 `58ac11375a4ed4b228123632d646214d20bd89abd27b513b74b8eb68e8766a70`)

Operator binding: **R6** packet revision, operator commit
`1f028869ad884fc0b506845ec717a226540d651b`, packet manifest
`3bfc5ac04dd71f1d7b7a6010442561e2ef3d6399c88ebff88c4390781a59de5e` (75 members).
Rebound from the R4 binding by the R5 PCA provenance-role correction, which moved
the runtime PCA input from the training-score artifact `pca_scores.h5` to the
component basis `pca.h5`, and then by the companion-dependency correction that binds
and verifies the consumed `pca.yaml` (`ba47df9b1229ab6dae884adf2fab49cfde4a07c5d44575e35547be12277af0d9`).
R6 then corrected the comparison itself: rule C2 canonicalises each side's own
generated extraction UUID, the applied model is read with joblib, TIFFs are
compared as decoded pixels, and the diagnostic render is presence-only. Scientific
equality, zero tolerance, the closed world and C1 are unchanged.

## Why this exists

`REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1` section 9 requires that
outputs expected to be deterministic match exactly, and that any component
requiring an equivalence criterion have that criterion frozen *before the replay
result is seen*. The sealed `deterministic_replay_binding` fixed the replay
target, count and result-blind selection. It did not enumerate the comparison
itself: both `DETERMINISTIC_REPLAY_PLAN.md` and `DETERMINISTIC_REPLAY_PLAN_R2.md`
deferred that step, R2 explicitly stating `INCOMPLETE` and conditioning its
exactness list on a comparison contract being frozen later.

This document is that freeze. It is authored before any primary candidate
execution exists, so no output could have influenced it.

## Derivation authority

The governed output schema is derived **only** from the accepted operator and
the locked pipeline source — `08_run_r1_full_session_validation.sh`,
`lib/common.sh`, the five packet helpers that write receipts, and the locked
`moseq2-extract` / `moseq2-pca` / `moseq2-model` worktrees at their frozen
commits. No candidate output was opened. The full source list is recorded in
`schema_derivation.sources` of the JSON.

## Comparison principles

- **Semantic, not whole-file.** Comparison is per dataset, per attribute, per
  JSON leaf, per receipt field. Whole-file byte equality is used only for frozen
  input copies and opaque image bytes, where the file *is* the unit.
- **Array exactness** means dtype **and** shape **and** exact C-order bytes.
  Because the raw bytes are compared, NaN representation and NaN *position* are
  compared bit-exactly; a relocated NaN fails even when the NaN count is equal.
- **Scalar floats** are compared as IEEE-754 little-endian bit patterns, so NaN
  and `-0.0` are distinguished.
- **Zero scientific tolerance.** There is no epsilon anywhere in this contract.
- **Closed world.** Any logical name inside governed scope that is in neither
  `MUST_MATCH` nor `DECLARED_IGNORED` is a failure, not a pass.
- **Inventory equality.** The relative-path inventories of the two run roots must
  be identical; any missing or extra entry fails.
- **Blind reporting.** Reports carry logical names, classes, statuses and
  digests. No scientific value is ever emitted.

## Canonicalisation (rule C1)

Each run root's own absolute path is replaced by the token `<RUN_ROOT>` in text,
JSON string and YAML string content before comparison. The two roots differ by
construction; canonicalising them lets embedded provenance stay `MUST_MATCH`
instead of being ignored. Absolute paths that are *not* run-root dependent —
locked worktree paths, staged input paths, module files — are left alone and
remain `MUST_MATCH`.

## MUST_MATCH

Twenty-four classes, `M01`–`M24`, enumerated in the JSON. In summary: the
inventory itself; the run receipt and any failure receipt; the frozen process
environment; the copied run spec, config (original and working), classifier and
PCA inputs; the provenance preflight, runtime identity, raw frame accounting and
extraction frame accounting receipts; every stage exit code and command line;
the ROI images; every dataset and attribute of the extraction HDF5 and the PCA
score HDF5; the extraction status YAML; the applied held-out model pickle
including its label arrays; and all three summary documents. `M24` is the
internal default: **every HDF5 dataset and attribute not explicitly ignored is
MUST_MATCH.**

Provenance, source, model, PCA, config and classifier identities are
load-bearing and are all `MUST_MATCH`. No metadata group is ignored wholesale.

## DECLARED_IGNORED

Fourteen classes, `I01`–`I14`, each with a one-line justification in the JSON.
They are only:

| Class | Ignored | Justification |
|---|---|---|
| I01–I04 | `completed_utc`, `checked_utc` (x2), `captured_utc` | wall-clock stamps |
| I05 | `process_environment.txt::pwd` | invocation cwd, runtime material |
| I06–I07 | stage `*.stdout.txt`, `*.stderr.txt` | human log text: progress counters, durations, worker ordering |
| I08 | `results_*.mp4` | non-load-bearing preview rendering derived entirely from MUST_MATCH frames; container embeds encoder identity and creation time |
| I09–I10 | `summaries/*.json::path` | absolute path inside the run root; identity already carried by MUST_MATCH digests |
| I11–I13 | `results_*.yaml` `start_time` / `end_time` / `duration` | wall-clock stamps and elapsed time |
| I14 | filesystem mtime, ownership, permission bits | host bookkeeping, not pipeline outputs |

Nothing else is ignored.

## Disposition

`PASS` requires every `MUST_MATCH` unit to match, identical inventories, and
nothing unclassified. Anything else is `FAIL`. Exit code 0 on PASS, 2 on FAIL.

A `FAIL` is a HOLD for Architect adjudication. The comparator does not decide
scientific meaning and must not be re-run with a relaxed contract.

## Qualification

`tests/qualify_r1_replay_comparator.py` builds synthetic fixtures only — no
candidate recording, extraction, score, model output or roster identity is read.
Nineteen cases, all `PASS`. The suite proves sensitivity across every handler class plus structural failure cases; it does not claim independent perturbation of all twenty-four MUST_MATCH rows:

- `Q01` scientific values identical with only declared-ignored differences → PASS
- `Q02`–`Q09` one-value or one-bit change in each **handler class** (HDF5 dataset,
  HDF5 attribute, JSON leaf, receipt field, frozen input bytes, pickle label
  array, YAML field, stage exit code) → FAIL
- `Q10` NaN relocated with count unchanged → FAIL
- `Q11`–`Q12` missing MUST_MATCH dataset and missing MUST_MATCH file → FAIL
- `Q13`–`Q15` undeclared extra file, extra HDF5 dataset, extra JSON key → FAIL
- `Q16` byte-identical report across repeated runs
- `Q17` directory-order invariance (replay built in reverse creation order)
- `Q18` blindness: sentinel scientific values never appear in any report
- `Q19` foreign cross-run-root contamination: the replay side emits the *primary*
  run root literal in a MUST_MATCH field. The primary canonicalises its own root
  to `<RUN_ROOT>`; the replay must not canonicalise a foreign root, so the literal
  survives → FAIL

## Usage

```bash
/home/ajm/miniforge3/envs/moseq2-app/bin/python validation/replay/compare_r1_replay.py \
  --primary  <runs>/r1_primary_slot_01 \
  --replay   <runs>/r1_replay_slot_01 \
  --contract validation/replay/REPLAY_COMPARISON_CONTRACT_R1.json \
  --report   <evidence>/REPLAY_COMPARISON_REPORT_R1.json
```

## Provenance of the R6 amendments

The original contract was frozen before any primary candidate execution existed.
The R6 amendments were made *after* the R5 replay failed, and were informed by a
protected, identity-redacted **structural** decomposition of the preserved R5
primary/replay pair together with confirmation in locked source. Only structure was
inspected: loader behaviour, container format, dataset and key names, and match or
differ status. No scientific value was inspected, no candidate identity or UUID value
was exposed, and no tolerance was introduced. Current locked moseq2-extract source is
`2c9cd86571bcc23ad6870e4da344e0f558f3f54c`.

## Post-R6 comparator implementation correction

The R6 replay established, by an identity-redacted and value-blind decomposition,
that **every scientific array and every applied label array is bit-exact**: frames,
frames_mask, timestamps, all scalars, ROI, true_depth, flips, acquisition metadata,
PCA score arrays, score indices, applied labels, and the model, run and whitening
parameters. Seven comparator units still differed, and all seven were representation
defects in the comparison itself, confirmed against locked source:

1. **Wall-clock provenance.** Both `moseq2-extract` and `moseq2-pca` write
   `"written": datetime.datetime.now().isoformat()` into their pipeline provenance.
   The two HDF5 provenance records are now expanded and compared **field by field**,
   so only the exact `written` field is declared ignored (I16-I19) and every other
   provenance field stays MUST_MATCH. Acquisition timestamps are untouched and remain
   MUST_MATCH.
2. **Embedded model object.** Contract M20 already stated that the embedded model
   object is not recursively compared. The implementation did compare it, digesting a
   `repr` that carries a heap address. The comparator now emits a deterministic
   presence marker for the `model` key; a missing key still fails.
3. **Fixed-length string dtype.** HDF5 stores paths as `S<N>`, and `N` tracks the
   *un-canonicalised* run-root length, so C1-identical text still differed. String and
   bytes arrays are now canonicalised before equality, comparing semantic type class,
   shape and exact canonicalised contents but not fixed capacity. **Numeric arrays are
   unchanged: dtype and shape and exact C-order bytes remain mandatory.**

Scientific tolerance remains **zero**. The R6 execution outputs are preserved and were
not rerun, and the corrected comparator has not been run against them.
