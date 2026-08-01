# Phase 2 Fixture Qualification Closeout - 2026-08-01

This is an additive architect adjudication over immutable R1, R2, R3, and
script-03 R2 evidence. It does not relabel or repair any formal run.

## Verdict

**SUBSTANTIVE FIXTURE-BACKED CANDIDATE QUALIFICATION COMPLETE.**

The accepted evidence establishes the fixture-backed behavior of the locked
candidate source in the frozen legacy environment. It does not authorize a
merge, script 04, real-data execution, or the next scientific phase.

## Immutable formal results

| Run | Formal result | Exact reason |
|---|---|---|
| R1 | **FAIL CLOSED** | Both authoritative fixture ZIPs contained a member named exactly `/`. The original safety rule classified that zero-byte root directory marker as an absolute and empty-normalized member. No extraction, mirror creation, collection, or test began. Architect adjudication later allowed only this exact root-directory marker under the narrow archive rule; R1 remains unchanged. |
| R2 | **FAIL CLOSED** | Fixture preparation passed, but the submitted nine viz selectors omitted the `TestScalarUtils` class component. Pytest could not resolve them; collection exited `4`, no test ran, and no retry occurred. |
| R3 | **FAIL CLOSED** | The candidate full suites passed 128/128, then seven cross-repository contract tests failed solely because the replacement runner omitted `MOSEQ2_EXTRACT_REPO`, `MOSEQ2_VIZ_REPO`, and `MOSEQ2_APP_REPO`. R3 also modified ignored `moseq2-app/.coverage`, so protected plain-filesystem state was not unchanged. |

## Frozen identities

| Repository | Locked candidate SHA |
|---|---|
| `moseq2-extract` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-pca` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| `moseq2-model` | `6e542e3f1db125202d42b59f390c922281e64f39` |
| `moseq2-viz` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | `e0b85201226d03e15944473a734f71417698c31e` |

The accepted fixture archives are:

| Fixture archive | SHA-256 |
|---|---|
| `moseq2-viz-test-data.zip` | `de6c4d30a67c800888fc27ec395ff8e3821b2903248235c972a63b0e72b27728` |
| `moseq2-extract-test-data.zip` | `21f9dd7a55a44eae329c76ba48686c36cc26dc2da4264d199c7ccd3b7eb370f9` |

## Substantive qualification evidence

- R3 targeted confirmation passed **10/10 non-vacuously**: nine viz tests and
  extract `test_get_roi`, whose fixture loop executed five real TIFF inputs.
- R3 correctly contextualized candidate full suites passed **128/128**:
  provenance chain 1/1, app 40/40, extract 11/11, and viz 76/76.
- The earlier immutable script-03 R2 run passed the same locked
  cross-repository contract suite **7/7**.
- Candidate SHAs, packet test bytes, golden environment, fixture identities,
  and relevant source identities were unchanged across the accepted evidence.
- R3's seven contract failures establish an operator runner-context defect, not
  a contradictory candidate-code, fixture, harness, dependency, or scientific
  failure.

These facts support the architect adjudication. They do not rewrite the formal
R1, R2, or R3 results.

## Protected-worktree restoration

R3 created or modified this ignored pytest-cov artifact:

`/home/ajm/moseq2-validation-20260730/worktrees/moseq2-app/.coverage`

Its SHA-256 was
`41053d1a048a8cc08f707f4ae941e929282bcef228eccd1424810db9c6929c40`.
The closeout operation copied and verified the exact bytes outside all
protected worktrees, recorded the before-state, then removed only that file.
Post-removal comparison proved that tracked files and every other ignored file
were byte-identical. The worktree was touched during R3 and then exactly
restored; it was not "never touched."

Preserved artifact and records:

`/home/ajm/moseq2-validation-20260730/evidence/fixture_qualification_closeout_20260801/coverage/`

## Boundary and next phase

No merge is authorized. Script 04 and real-data execution remain unauthorized.
The next major phase is preparation for one bounded real-recording pilot, but
only after a new architect chat passes the read-only comprehension check in
`ai/HANDOFF_CURRENT.md` and AJ separately authorizes pilot design or execution.
