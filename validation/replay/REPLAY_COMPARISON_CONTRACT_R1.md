# R1 deterministic replay comparison contract

Governs: **OQ-V6-011**
Classification: **PRE_EXECUTION_CLARIFICATION**
Machine-readable partition: `REPLAY_COMPARISON_CONTRACT_R1.json`
(SHA-256 `f5095def25fdedfa73754bc3ed401f2d482178ec10f692e8fc49f778c3ba7dd1`)
Comparator: `compare_r1_replay.py`
(SHA-256 `6e9c0e575648d096dad3980428fd0452c4497d3cf91bfdfe5fc45f00274cbf46`)
Qualification receipt: `tests/REPLAY_COMPARATOR_QUALIFICATION_RECEIPT.json`
(SHA-256 `a08bb51b4d9464cbb287d28bffecca5ba53bcf3ce312f0694cb2af1fe306e24a`)

Operator binding: R4 packet revision, operator commit
`485a2dcf08726cd208cf4f5e7cc342c5a35594a6`, packet manifest
`8b5b5424204bf5a8d0ac5df3a88d2100b45bfd75b2dbe4dd1aab58706c4dd983`.
Rebound from the R3 operator commit after a pre-science raw-frame-accounting
compatibility remediation. The comparison partition below is unchanged.

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
