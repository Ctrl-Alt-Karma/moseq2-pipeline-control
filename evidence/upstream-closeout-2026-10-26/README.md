# Software-only closeout evidence

This directory contains the 2026-10-26 contribution crosswalk, current source/ref
identities, historical symbol coverage, all submitted PR/issue identities,
synthetic regressions, expected-red baseline JUnit results, green candidate
results, patch exports, source/wheel continuity and governance write receipts.

Qualification: 51 branches; 67 candidate test cases pass, zero errors/skips;
65 baseline cases fail and two baseline positive controls pass. Six separate
diagnostic tests assert current defects/limitations rather than a fix. Two
synthetic/import semantic-audit tests and two amended native conversion nodes
also pass. These are not full notebook, real-data, platform or combined-stack
certification runs. No scientific artifacts or candidate outputs are included.

Read the exact per-topic evidence class. API-level synthetic reproductions are
not conflated with static exception-branch reconstructions. Historical evidence,
current Builder proof and independent/upstream acceptance are distinct claims.

The adjacent `../UPSTREAM_CLOSEOUT_2026-10-26.sha256` covers every regular file in
this directory, with exact set equality. The manifest is outside its own payload
so there is no self-hash exception or unledgered omitted payload member.
Scientific binaries were never members of this software payload.

Verify read-only, with the Python standard library only:

```sh
python -X utf8 evidence/upstream-closeout-2026-10-26/verify_software_payload.py
```

The payload and its adjacent manifest have narrowly scoped `-text` attributes
to preserve checksum bytes on Windows checkouts. No historical file's line
ending policy is changed.

For scientific status, use the final Owner closeout/handoff, not the presence of
green software test receipts. Final human qualitative review was never completed.
`PASS_REAL_SESSION_PRODUCTION_VALIDATION` was NOT issued.
