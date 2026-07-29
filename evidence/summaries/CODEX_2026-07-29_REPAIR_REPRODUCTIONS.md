# Codex Supplemental-Audit Repair Reproductions

Date: 2026-07-29

## Evidence custody

- Supplemental packet SHA-256:
  `A25D6DA3259C8B523CEEF44267DE7243101FC7D2491CBD2F627D239F209281B7`
- Imported audit SHA-256:
  `574E31CA93A8A4E43C807F12730939B4ECF9A25CBCA93B19F55F8887B817542C`
- Imported findings ledger SHA-256:
  `93EF2EEDEAFEA5915C94BA9DC1488A91B72F222B637C71DFC2BB01D723BE123D`
- Imported `killtest.py` SHA-256:
  `E32B121299B06DFE6B1D55FEC9F03F657D016FD827F7D0764F81120A4543F933`
- Imported `child.py` SHA-256:
  `959A50EE157A0B9E6598A9238B0E58EC84465335AA45FB326120D329932B05B0`

The imported bytes are unchanged. Exact verifier commands and the reconstruction
recipe remain in `ai/reviews/OPUS_FABLE_2026-07-29/` and
`evidence/fixtures/flip-journal/`.

## Red-at-old-head reproduction

The old candidate heads were:

- extract `f028801e9a6b54ffa63e22d9e10179ea7419ccc4`
- viz `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`
- app `192921f1aff3ea58d3b1f268d71731ed222011d2`

A read-only old-head harness exercised corrupt provenance, non-mapping journal
records, public scalar boundaries, canonical path ordering, integer conversion,
metadata order, dead APIs, F-09 policy separation, and preview cleanup. Result:
**23 failed assertions and 1 passing control**, which establishes that the new
regressions are red on the audited heads.

The expanded F-09 reconstruction measured a pi orientation difference when app
correction was layered over extraction-time flip correction. The repair does not
attempt to rewrite possibly damaged sessions. It blocks that combination before
mutation and makes app correction part of viz pooling provenance.

## Process-death matrix

The verifier’s process-death harness was reconstructed and run at all five
journal checkpoints. On Windows, each pre-clear death returned fail-closed and
the post-clear death returned complete. HDF5 remained readable.

The exact Linux observation that only one slot persisted at
`after_new_slot_create` did not reproduce on Windows; both slots were visible.
This is why F-06 is only partially confirmed. The semantic safety assertion
did reproduce.

The matrix covers writer-process death with the operating system and page cache
surviving. It does not cover power loss, kernel or host death, network/FUSE
filesystems, or torn HDF5 metadata. No such durability claim remains in code.

## Green-at-new-head validation

New candidate heads:

- extract `e7f585104ba25b66e5326c88c77a47e33db95635`
- viz `b80192dc20353bf77c36610f315543b57afa908c`
- app `e0b85201226d03e15944473a734f71417698c31e`

Results in the available Windows Python 3.12 environment:

- extract focused regressions: **3 passed**
- viz self-contained provenance/scalar regressions: **61 passed**
- app flip-record suite: **40 passed plus 4 process-death subtests**
- cross-repository locked-head contract: **7 passed**
- Python 3.7 grammar parse of all modified Python files: passed
- `git diff --check`: passed in all four repositories

The pinned Python 3.7 environment was not available for this continuation.
Earlier pinned-head results remain separately recorded; they were not relabeled
as results from this run.

## Unresolved harness limits

- Eight broader viz tests require repository data fixtures absent from the
  checkout.
- Two legacy-conversion tests expose latest-`cytoolz` behavior outside the
  pinned dependency set.
- Independent Linux SIGKILL verification remains required for the exact
  slot-persistence matrix.
- Real-recording validation remains deferred by the existing acceptance gate.
