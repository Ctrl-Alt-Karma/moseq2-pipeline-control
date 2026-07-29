# Current State

Date: 2026-07-29

## Candidate draft PRs

| Repository | PR | URL | Base | Base SHA | Head branch | Head SHA | State |
|---|---:|---|---|---|---|---|---|
| `moseq2-extract` | #6 | https://github.com/Ctrl-Alt-Karma/moseq2-extract/pull/6 | `release` | `424d643affb685e1cad145e3c7051b814d11265c` | `agent/repair-velocity-scalars` | `e7f585104ba25b66e5326c88c77a47e33db95635` | Draft, open, unmerged |
| `moseq2-viz` | #5 | https://github.com/Ctrl-Alt-Karma/moseq2-viz/pull/5 | `release` | `68ca6a34055987ff22f8651b4dca2aa254380c87` | `agent/repair-pinhole-provenance` | `b80192dc20353bf77c36610f315543b57afa908c` | Draft, open, unmerged |
| `moseq2-app` | #5 | https://github.com/Ctrl-Alt-Karma/moseq2-app/pull/5 | `release` | `36d40e098a5c4629116b7a4e233573218345bd5d` | `agent/repair-flip-processing-journal` | `e0b85201226d03e15944473a734f71417698c31e` | Draft, open, unmerged |

GitHub's mergeability result is transient metadata, not review evidence.

## Other current release heads

- `moseq2-pca` `release`: `efb6fcfa5d5af5bb4274540c371d0ddf96440b78`
- `moseq2-model` `release`: `6e542e3f1db125202d42b59f390c922281e64f39`

These SHAs were resolved from the remote `refs/heads/release` on 2026-07-29.

## Targeted pinned-stack results

Fresh reruns on the candidate heads, using the existing Python 3.7 pinned environment with pytest cache and bytecode generation disabled:

- extract: **10 passed**
- viz: **43 passed**
- app: **29 passed**

Exact invocations are recorded in `ai/implementation_reports/CODEX_2026-07-29_REPLACEMENT_PRS.md`.

## Supplemental-audit repair results

The Fable packet was imported verbatim and its executable findings were
reproduced against the prior candidate heads before implementation.

Available Windows Python 3.12 validation at the new heads:

- extract: **3 passed**
- viz: **61 passed**
- app: **40 passed plus 4 process-death subtests**
- locked-head cross-repository contract: **7 passed**
- Python 3.7 grammar parse and `git diff --check`: passed

The pinned Python 3.7 runtime was not available during this continuation.
Independent Linux SIGKILL verification and real-recording validation remain
open. Exact dispositions and limitations are in `ai/REVIEW_LOG.md`.

The extract and viz counts above were deliberately focused selections, not
full-suite pass counts. The verification-only addendum records the exact
collection and selection:

- extract: 11 tests exist in the reported file; the focused command named 3
  nodes and all 3 passed. A later full-file run produced 10 passed and 1 failed
  before the product function call because the current OpenCV build rejected a
  NumPy integer scalar in test setup.
- viz: 76 tests exist across the two reported files; the focused command
  selected all 43 provenance tests plus 18 scalar tests, and all 61 passed. A
  later full run produced 65 passed and 11 failed: 9 were blocked by absent
  repository fixtures and 2 exposed current `cytoolz.get` behavior outside the
  legacy pinned dependency set.

The actual extract-writer-to-viz-reader provenance chain failed in the round-2
NumPy 2.5.1 environment because the legacy extract writer calls the removed
`np.string_` API. The unchanged chain passed in the required isolated
NumPy 1.26.4/h5py 3.11.0 environment. No production source was changed.

## Reported broader-suite limitations

Codex reported:

- missing committed fixtures or data files;
- ffmpeg and native Windows path/behavior differences;
- missing legacy optional dependencies, including `qgrid` and `dtaidistance`;
- Windows lacks the Unix `forkserver` multiprocessing start method used by some legacy tests.

These reports are classifications to verify, not blanket excuses. Every broader-suite failure still needs an exact cause and a determination of environmental blocker versus product defect.

## Current gate

Independent source review of the three candidate PRs and control contract is
required before any merge. All four PRs remain draft and unmerged. Real-recording
validation remains deferred until the structural candidate passes that review.
