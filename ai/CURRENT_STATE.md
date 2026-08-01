# Current State

Date: 2026-08-01

## Verdict and phase status

- Phase 0, golden-environment freeze: **CLOSED**, independent Fable `PASS`.
- Phase 1, locked candidate worktrees: **CLOSED**, attachment-only independent
  Fable `PASS`.
- Phase 2, fixture-backed candidate qualification: **CLOSED BY ARCHITECT
  ADJUDICATION**. The formal R1, R2, and R3 results remain **FAIL CLOSED**.
- Architect adjudication: **SUBSTANTIVE FIXTURE-BACKED CANDIDATE QUALIFICATION
  COMPLETE.** See `ai/PHASE2_FIXTURE_QUALIFICATION_CLOSEOUT_2026-08-01.md`.
- Current boundary: a new architect chat must pass the read-only comprehension
  check in `ai/HANDOFF_CURRENT.md`. No pilot design or execution authority has
  been granted.

## Frozen production environment

Katya's existing WSL2 Ubuntu 22.04 `moseq2-app` Conda environment, Python 3.7
and NumPy 1.18.3, remains the sole supported production target for this study.
Candidate source is supplied by the locked `PYTHONPATH`; it is not installed
into the environment. Modernization, in-place package changes, and
multi-environment equivalence claims remain out of scope.

## Locked candidate source

| Repository | SHA |
|---|---|
| `moseq2-extract` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-pca` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| `moseq2-model` | `6e542e3f1db125202d42b59f390c922281e64f39` |
| `moseq2-viz` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | `e0b85201226d03e15944473a734f71417698c31e` |

The existing candidate PR record remains useful audit context:

| Repository | Draft PR | Head SHA | State |
|---|---|---|---|
| `moseq2-extract` | [#6](https://github.com/Ctrl-Alt-Karma/moseq2-extract/pull/6) | `e7f585104ba25b66e5326c88c77a47e33db95635` | Open, unmerged |
| `moseq2-viz` | [#5](https://github.com/Ctrl-Alt-Karma/moseq2-viz/pull/5) | `b80192dc20353bf77c36610f315543b57afa908c` | Open, unmerged |
| `moseq2-app` | [#5](https://github.com/Ctrl-Alt-Karma/moseq2-app/pull/5) | `e0b85201226d03e15944473a734f71417698c31e` | Open, unmerged |

AJ is the sole merge authority. GitHub mergeability metadata is not review
evidence.

## Governed fixture and harness identities

| Item | Identity |
|---|---|
| Viz fixture archive | `de6c4d30a67c800888fc27ec395ff8e3821b2903248235c972a63b0e72b27728` |
| Extract fixture archive | `21f9dd7a55a44eae329c76ba48686c36cc26dc2da4264d199c7ccd3b7eb370f9` |
| Accepted external harness | `/home/ajm/moseq2-test-harnesses/pytest541_cov251_20260801_R2` |
| Harness evidence | `/home/ajm/moseq2-validation-20260730/evidence/pytest_harness_20260801_R2` |

The isolated harness binds pytest 5.4.1 and pytest-cov 2.5.1 without changing
the golden Conda environment.

## Formal run record and adjudication

| Evidence | Formal result | Substantive record |
|---|---|---|
| Fixture R1 | **FAIL CLOSED** | Archive safety rejected the exact zero-byte root-only `/` directory marker before extraction or testing; later narrowly adjudicated safe without rewriting R1. |
| Fixture R2 | **FAIL CLOSED** | Nine viz selectors omitted `TestScalarUtils`; collection exited `4`, no test ran. |
| Fixture R3 | **FAIL CLOSED** | Targeted confirmation passed 10/10 non-vacuously; candidate suites passed 128/128; seven contract tests failed solely because three repository environment variables were omitted; ignored app `.coverage` also changed. |
| Script-03 R2 | **FAIL CLOSED** | Candidate suites included seven cross-repository contract passes; the immutable run's separate formal failures remain unchanged. |

The accepted combined evidence is: targeted viz 9/9; extract `test_get_roi`
1/1 over five real TIFF inputs; R3 provenance 1/1, app 40/40, extract 11/11,
and viz 76/76; prior script-03 R2 cross-repository contracts 7/7. This supports
the architect adjudication but does not convert any formal run to `PASS`.

R3's ignored app `.coverage` artifact was preserved, verified, and removed.
The protected app worktree was touched and then exactly restored. Closeout
evidence is at:

`/home/ajm/moseq2-validation-20260730/evidence/fixture_qualification_closeout_20260801`

## Unresolved scientific and custody risks

- Exact installed commits for floating `pyhsmm`, `pybasicbayes`, and
  `autoregressive` dependencies remain unresolved.
- Pinned-Dask `svd_compressed` PCA remains unseeded; within-environment
  variability is not yet characterized.
- The active study flip-classifier bytes still require exact custody.
- Real-recording structural behavior, legacy unstamped inputs, and mixed-policy
  dataset handling have not been validated by this fixture closeout.
- A future analysis machine remains unqualified until it reproduces the full
  locked environment and passes the separate known-answer and guarded-launch
  controls.

## Authorization status

No merge is authorized. Script 04, real study-data inspection, and any
real-recording pilot are unauthorized. The exact next phase is preparation for
one bounded real-recording pilot, beginning only after a read-only new-architect
comprehension check is reviewed and a later, explicit authorization is issued.
