# Current State

Date: 2026-07-29

## Candidate draft PRs

| Repository | PR | URL | Base | Base SHA | Head branch | Head SHA | State |
|---|---:|---|---|---|---|---|---|
| `moseq2-extract` | #6 | https://github.com/Ctrl-Alt-Karma/moseq2-extract/pull/6 | `release` | `424d643affb685e1cad145e3c7051b814d11265c` | `agent/repair-velocity-scalars` | `f028801e9a6b54ffa63e22d9e10179ea7419ccc4` | Draft, unmerged, GitHub reports mergeable |
| `moseq2-viz` | #5 | https://github.com/Ctrl-Alt-Karma/moseq2-viz/pull/5 | `release` | `68ca6a34055987ff22f8651b4dca2aa254380c87` | `agent/repair-pinhole-provenance` | `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e` | Draft, unmerged, GitHub reports mergeable |
| `moseq2-app` | #5 | https://github.com/Ctrl-Alt-Karma/moseq2-app/pull/5 | `release` | `36d40e098a5c4629116b7a4e233573218345bd5d` | `agent/repair-flip-processing-journal` | `192921f1aff3ea58d3b1f268d71731ed222011d2` | Draft, unmerged, GitHub reports mergeable |

GitHub's current mergeability result is transient metadata, not review evidence.

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

## Reported broader-suite limitations

Codex reported:

- missing committed fixtures or data files;
- ffmpeg and native Windows path/behavior differences;
- missing legacy optional dependencies, including `qgrid` and `dtaidistance`;
- Windows lacks the Unix `forkserver` multiprocessing start method used by some legacy tests.

These reports are classifications to verify, not blanket excuses. Every broader-suite failure still needs an exact cause and a determination of environmental blocker versus product defect.

## Current gate

Independent source review of the three candidate PRs is required before any merge. Real-recording validation remains deferred until the structural candidate passes that review.
