# MoSeq2 upstream handoff and Owner closeout — 2026-10-26

## Final project state

**R1 SCIENTIFIC VALIDATION CLOSED BY OWNER BEFORE FINAL HUMAN QUALITATIVE GATE**

AJ / Karma terminated the remaining R1 scientific-validation effort. The blinded
domain-scientist Tier-A / Tier-D qualitative review was not completed.
`PASS_REAL_SESSION_PRODUCTION_VALIDATION` was NOT issued. This is neither a
scientific validation PASS nor a scientific validation FAIL, and establishes
neither biological validity nor biological invalidity.

Machine-side/software evidence remains at its existing accepted claim classes.
No further scientific processing, validation, retuning, model selection or
biological inference is planned under R1. There is no pending request to Katya,
AI substitute reviewer, or automatic continuation. Reopening requires a new
explicit Owner decision.

Authority for this closeout: AJ's 2026-10-26 final-operation directive. Codex acted
as Builder/operator, not independent Verifier, Scientific Counsel or scientific
adjudicator. Decisions D-057 through D-059 record the additive control-plane delta.

## Reconstructing the software handoff

- [Complete human-readable finding crosswalk](../evidence/upstream-closeout-2026-10-26/FINDING_CROSSWALK.md).
- [Machine-readable crosswalk](../evidence/upstream-closeout-2026-10-26/FINDING_CROSSWALK.json).
- [Every historical repair commit and changed symbol](../evidence/upstream-closeout-2026-10-26/HISTORICAL_SYMBOL_COVERAGE.json).
- [Contribution branches, commits and PR URLs](../evidence/upstream-closeout-2026-10-26/CONTRIBUTIONS.json).
- [Confirmed issue reports and reproductions](../evidence/upstream-closeout-2026-10-26/CONFIRMED_ISSUES.json).
- [Twenty strict-xfail cases](../evidence/upstream-closeout-2026-10-26/APP_STRICT_XFAIL_INVENTORY.json).
- [Remote publication verification](../evidence/upstream-closeout-2026-10-26/REMOTE_PUBLICATION_RECEIPT.json).
- [Source/wheel/test continuity](../evidence/upstream-closeout-2026-10-26/QUALIFIED_SOURCE_CONTINUITY.json).
- [Rules/protection checks before writes](../evidence/upstream-closeout-2026-10-26/RULE13_WRITE_AUDIT.json).

The crosswalk has 91 topic rows: 51 PR_READY, 6 ISSUE_ONLY_CONFIRMED,
4 ALREADY_UPSTREAM, 9 UNCONFIRMED_HANDOFF, 5 OBSOLETE_OR_SUPERSEDED,
15 PROJECT_CONTROL_ONLY, and 1 REJECTED. Legacy finding IDs are aliases, not
duplicate rows. All 40 nonmerge historical repair commits are accounted for,
including tests-only commits. PR_READY means submitted for review, not merged,
independently verified or production-accepted by upstream.

The original implementation reports, OPUS/Fable reviews and review-log claims
remain unchanged. In particular, a historical OPEN/pending-independent-verification
claim is not retroactively marked FIXED merely because this sweep produced a PR.
Original authorship is carried in commit trailers, source-history references and
PR bodies. The old proposals/branches are preserved.

## Current upstream identities inspected and rechecked

| Repository | Ref | SHA |
|---|---|---|
| dattalab/moseq2-extract | release | `d1b0e75d0a696d071d4d158ab2b16787f52890df` |
| dattalab/moseq2-pca | release | `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c` |
| dattalab/moseq2-model | release | `ed1fb9bff59db377eb3b45d996b3195ff0f93637` |
| dattalab/moseq2-viz | release | `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8` |
| dattalab/moseq2-app | release | `eefa3d5c15e21adef6e9ede343f2705f37d3e47b` |
| dattalab/moseq2-test | main | `9e696dbbc3e36169366ec309656b87183524ff3d` |

All five Ctrl-Alt-Karma fork defaults and their old repair refs were reacquired;
the exact initial refs are in REACQUIRED_REPOSITORIES.json. New contributions
start at the current upstream bases above, not at frozen fork release heads.
Each correction is a separate `codex/final-*` branch. No default fork branch was
rewritten, no force push occurred, and no upstream merge was performed.

BRIDGE live main was reacquired at
`a919e0ad170134fcce5ef56de14c1cf352130165`. Rules 13, 23 and 24 were applied to
write checks and durable continuity. No reusable canon gap was established and
no BRIDGE canon was changed. This project closeout does not fabricate an
Architect successor-reconstruction PASS or transfer of scientific authority.

## Testing architecture and actual verification

[App PR #291](https://github.com/dattalab/moseq2-app/pull/291) merged on
2026-10-26 at `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`. Its release description
reports Python 3.10+, a pip/PyPI suite install, versioned sibling dependencies,
modern notebook/UI APIs and 306 tests. Those are upstream release claims, not a
claim that this operation executed the complete notebook suite.

AST inspection found 20 expanded strict-xfail cases: 3 MATCHES_OUR_FINDING,
2 RELATED_BUT_DISTINCT, and 15 NO_PROJECT_OVERLAP. The matches are coverage count,
QC percentage display and index-column leakage. The two related cases are MP4
faststart, not our subprocess-finalization defect. The remaining 17 cases were
not adopted as project tasks. Existing matching app xfails were promoted to hard
regressions where the affected app implementation was repaired; the coverage
case depends on the separately submitted viz fix/release.

The current moseq2-test repository is an installed-wheel/cross-pipeline framework
for the **legacy** stack: Python 3.12 controller, Python 3.7 worker. Its documented
profiles contain 47 install checks, 264 historical outcomes and 28 pipeline-smoke
steps; full pipeline-end-to-end is deliberately unavailable. Package-owned unit
tests belong in their package repositories. Central locks, fixtures, comparators
and cross-package profiles belong to moseq2-test. This is not automatically a
modern 1.4 cross-package certification environment.

[Model PR #100](https://github.com/dattalab/moseq2-model/pull/100) and
[extract PR #176](https://github.com/dattalab/moseq2-extract/pull/176) remained open
informational CI-integration pilots at reacquisition. Their heads were
`2ab129463a123ac53fb7cba362d25712ad2d227d` and
`20c80cc49e8468a0c2e717b5855817df03f0b2c8`, respectively. Neither was treated as
an already-merged modern-suite contract.

The sweep qualified 51 focused changes against genuinely installed wheels in a
separate disposable Python 3.12 software-test environment. The same generated
tests gave 65 baseline failures across 67 cases and 67/67 candidate passes,
with zero errors/skips. Each contribution had at least one red baseline test.
Additional diagnostic and native-node checks are recorded separately. Tests used
generated arrays, synthetic HDF5 fixtures and mocked process/trainer interfaces;
none used a recording or fitted scientific artifact. Full notebook suites,
real-data profiles, platform matrices and combined-stack equivalence were NOT run.

Each PR is based independently on current release. Overlapping hunks—especially
flip lifecycle/indices/overlap/preview and the two geometry changes—need normal
maintainer integration. Independent green branches do not establish that an
unreviewed combination is green. The exact output changes and excluded neighbors
are stated per PR. No scientific retuning or dependency modernization was bundled.

## Previously accepted upstream contribution

[Extract PR #180](https://github.com/dattalab/moseq2-extract/pull/180), area_mm area
conversion, merged as `81c49e6e7dac99afd64df8312accea8680555fc8`; our head was
`bd5ed2232a91dbf92c421e00a6e8276a94afc0ac`.
[Issue #179](https://github.com/dattalab/moseq2-extract/issues/179) is closed completed.
The current-source depth-scaling regression passes. It was not resubmitted.

[JRJacoby's workflow acceptance](https://github.com/dattalab/moseq2-extract/issues/179#issuecomment-5415717874)
permits focused corrections with unit tests, with maintainer local execution and
approval while CI modernization proceeds. This is contribution-process acceptance,
not blanket acceptance of every subsequent patch. No duplicate D-057 existed in
the reacquired control history, so that event is now recorded additively.

## Frozen historical instrument — not replaced by upstream 1.4

| Package | Frozen R1 source |
|---|---|
| extract R6 | `2c9cd86571bcc23ad6870e4da344e0f558f3f54c` |
| PCA | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| model | `6e542e3f1db125202d42b59f390c922281e64f39` |
| viz | `b80192dc20353bf77c36610f315543b57afa908c` |
| app | `e0b85201226d03e15944473a734f71417698c31e` |

Final kappa selection remains closed at 464159 under the sealed two-seed protocol
on the fitting corpus. The seed-20260802 model artifact remains bound under the
predeclared ARCHITECT_FALLBACK_RULE; the independent two-seed agreement supports
the hyperparameter, not a biological preference between fitted byte artifacts.
See the unchanged [production artifact decision](../evidence/synchronization/MOSEQ_V4_FULL_STATE_SYNC_AND_PRODUCTION_MODEL_FREEZE_R1/PRODUCTION_MODEL_ARTIFACT_DECISION.md).

Model SHA-256:
`5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964`.
PCA SHA-256:
`26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912`.
This operation did not load or regenerate either artifact.

The R1 final seal, seal addendum and protocol are unchanged. Their canonical Git
byte identities are in PRESERVED_SCIENTIFIC_SEALS.json. The new upstream branches
are a separate software-contribution track and are not asserted equivalent to R1.

## Continuation-critical accepted results and access boundaries

[Accepted result index](../evidence/upstream-closeout-2026-10-26/ACCEPTED_CONTINUITY_RESULTS.json).

1. `R1_TRANSPORT_BYTE_PROOF_R2.tar.xz`: SHA-256
   `ae1a709a36204495e7fe5a75e4e00d9f4339c2b2558c3522c09af270aca1c3ca`,
   237,460,672 bytes. The Builder rechecked that exact archive hash and size on the
   golden host without unpacking it. The accepted verifier conclusion—direct byte
   equality of preserved labels and PCA scores_idx, closing prior receipt-only
   derivation limits—is carried as OWNER_SUPPLIED_ACCEPTED_VERIFIER_RESULT,
   not independently reexecuted by this Builder. The standalone verifier report
   was not reacquired from the public repository.
2. `PASS_FABLE_KATYA_R1_REVIEW_COMPANION_R2`:
   `Katya_R1_Qualitative_Review_Companion_v2.zip`, SHA-256
   `d8bd607d089917eb8357d5eebd256bf626bec193bf5133e2c9d026474dfdc169`,
   162,656,837 bytes. This is an Owner-supplied accepted verifier result. The
   archive/report were not located in the bounded lookup and were not reverified
   here. The claim is suitability of the review tool, not completion of review.

Neither result constitutes final production validation. Protected golden-host
evidence remains local, and this public software handoff does not contain labels,
scores, mouse recordings, movies, animal identities or group-effect results.

## Limits and final custody

Frozen rule artifacts/protocol/conformance should travel together. Transport
payload members must equal manifested members plus explicitly ledgered omissions,
with no artifact-type exemption. No tuning through HOLD, no fake numeric
thresholds, and no automatic biological exclusion from OOD flags are authorized.

Remaining uncertain method choices, project-only provenance machinery, obsolete
legacy repairs and rejected over-strict orientation reasoning are preserved in the
crosswalk, not silently discarded and not advertised as proven upstream defects.
The software sweep used no new fit, model application, extraction, PCA pipeline,
candidate inspection, biological analysis or synthetic human judgment.

This document and the final handoff are the terminal control-plane record.
There is no next planned MoSeq task. Upstream review is maintainer-owned.

## Submitted PR and issue index

The complete URL/commit list is in CONTRIBUTIONS.json and CONFIRMED_ISSUES.json;
the generated index below is part of this same closeout record.

### moseq2-extract

- [Preserve fractional millimetres for integer pixel coordinates](https://github.com/dattalab/moseq2-extract/pull/182) — `b00699aad6320d29dc7a5bbb44668f035378d920`.
- [Use the pinhole relation for nominal field of view](https://github.com/dattalab/moseq2-extract/pull/183) — `f9987793dc033196b9376ffd3fa3f79c55b99e0c`.
- [Stop emitting the dimensionally invalid velocity_3d_px scalar](https://github.com/dattalab/moseq2-extract/pull/184) — `9674e130f0b27a17bd8d0280c6cd2d38e2e831d4`.
- [Make centroid Hampel filtering translation invariant](https://github.com/dattalab/moseq2-extract/pull/185) — `6212b47b32fec47de4c63cb808b287a042d80144`.
- [Allow angle-only Hampel filtering and use the MAD threshold](https://github.com/dattalab/moseq2-extract/pull/186) — `69fae4f7e333227af3f688ccee4fc1678ea176a0`.
- [Give plane RANSAC a local reproducible random generator](https://github.com/dattalab/moseq2-extract/pull/187) — `89e778a7a8f63c5f7ec243d8a5d521dc2e826333`.
- [Raise an actionable error when RANSAC cannot find a plane](https://github.com/dattalab/moseq2-extract/pull/188) — `050f5bcb6a806717cc93ea90392090100a5bb8e1`.
- [Honor the declared raw depth pixel byte order](https://github.com/dattalab/moseq2-extract/pull/189) — `4ac319b7772b4e62e3a8800525aaf9c3c8987311`.
- [Use unsigned 16-bit depth in the raw-reader CLI default](https://github.com/dattalab/moseq2-extract/pull/190) — `2bbebcda4556d0c665ba80483cc2f2f006be84b2`.

### moseq2-pca

- [Center the Gaussian smoothing kernel on its impulse](https://github.com/dattalab/moseq2-pca/pull/133) — `d8f975fdadf8e58eea2cb3b86a7f26fcbcdd06af`.
- [Pass the requested changepoint sigma to the Gaussian sigma argument](https://github.com/dattalab/moseq2-pca/pull/134) — `c1622a232020686671061d3f4f69cdee8d834970`.
- [Do not mask every changepoint when smoothing is disabled](https://github.com/dattalab/moseq2-pca/pull/135) — `62b50277d3d1d9d9b350eff274c732ff0184d7ce`.
- [Use each session length for missing-timestamp fallback](https://github.com/dattalab/moseq2-pca/pull/136) — `24eb72e75d022340f6cf96f6d820d72f7547d502`.

### moseq2-model

- [Split validation data from the requested training boundary](https://github.com/dattalab/moseq2-model/pull/102) — `c098468bb83dc0e796eff9b298bda3bc4af90d61`.
- [Forward declared scientific options to scan-models commands](https://github.com/dattalab/moseq2-model/pull/103) — `48833663688c5a56743e751239581ca296a65bb3`.
- [Bind exported label keys to the actual backend session order](https://github.com/dattalab/moseq2-model/pull/105) — `6b7357cb522712d8e3fd8c4e0e0d41a6a48a35d2`.

### moseq2-viz

- [Preserve fractional millimetres for integer pixel coordinates](https://github.com/dattalab/moseq2-viz/pull/190) — `31021b517a0e857343c6d37d18a45ea8696c4cca`.
- [Use the nominal pinhole field-of-view conversion](https://github.com/dattalab/moseq2-viz/pull/191) — `d588667ed06008faf622a3e0398d273e84ff09e2`.
- [Include raw states above 99 when ranking labels by usage](https://github.com/dattalab/moseq2-viz/pull/192) — `bbc70097f5a2c650dc6ccaeb070e2c6c8d3db79a`.
- [Include the threshold-crossing syllable in the coverage count](https://github.com/dattalab/moseq2-viz/pull/193) — `2361167d74c65589ab91c9f7ef2a6ac0103c33d9`.
- [Count the first observed state transition](https://github.com/dattalab/moseq2-viz/pull/194) — `ac381ddc2aacebf951c9f2df7e5f50fdea938b9d`.
- [Restrict Mann-Whitney comparisons to the requested groups](https://github.com/dattalab/moseq2-viz/pull/195) — `37cf1671cc57c0776124426d800bdaaa1c5ba10a`.
- [Correct Dunn p-values across syllables within each comparison](https://github.com/dattalab/moseq2-viz/pull/196) — `6b48bbe33895e08610c69e0c7496cfad658dd57a`.
- [Handle equal and unequal zero-variance z-test inputs](https://github.com/dattalab/moseq2-viz/pull/197) — `7308cbf71eb011ae2905b92dcaba17b8bc7151ac`.
- [Keep zero-total usage normalization finite](https://github.com/dattalab/moseq2-viz/pull/198) — `0b20df4c1a5e6e04d9902c3bc245209d52e4de63`.
- [Use the supported rows normalization in entropy_rate by default](https://github.com/dattalab/moseq2-viz/pull/199) — `1251cfe2474cfe21b461525dcb12f074b0855787`.
- [Preserve the requested metadata column order](https://github.com/dattalab/moseq2-viz/pull/200) — `448f18b34f7b3c57d92a85d0f3544ca52062b1ff`.
- [Match transition difference legend colors to the plotted signs](https://github.com/dattalab/moseq2-viz/pull/201) — `e156173cc3ca3c1b787f06948d5f57fd83a7857a`.
- [Keep state labels aligned with AR parameters when merging models](https://github.com/dattalab/moseq2-viz/pull/202) — `767c6869d80c66b6f2464b1b4b758482a8456a73`.
- [Preserve distinct median and mean fit summaries](https://github.com/dattalab/moseq2-viz/pull/203) — `c813d9c1b18b711a4ec5a71fd4521f9a2e5940c3`.
- [Apply an area conversion to legacy area scalars](https://github.com/dattalab/moseq2-viz/pull/204) — `d611143a12ccd955706ea476fe7d482abde25394`.
- [Index difference-graph usage by node identity after thresholding](https://github.com/dattalab/moseq2-viz/pull/205) — `05f5e58c47e91e1ada2a340550b5e1584ae0ea98`.
- [Read legacy scalar mappings without eager array defaults](https://github.com/dattalab/moseq2-viz/pull/206) — `2aadf69c3753315b58e900150f04d482b5ece0a2`.

### moseq2-app

- [Update flip-corrected angles at absolute frame indices](https://github.com/dattalab/moseq2-app/pull/292) — `c3d4a083de1c8a9b219b0607ef868c32176cc98e`.
- [Include the final frame in app flip correction](https://github.com/dattalab/moseq2-app/pull/293) — `2ae035bd51e2736aa7e2ca82ef74fff1477b78a5`.
- [Commit each overlapping flip-classifier frame only once](https://github.com/dattalab/moseq2-app/pull/294) — `40ed4a22c405e0e6eb37a6526846339b981a389b`.
- [Refuse reprocessing of interrupted or completed flip corrections](https://github.com/dattalab/moseq2-app/pull/295) — `6a01d1caaa11e0f2705b2af46117a8a2a55b16e5`.
- [Finalize preview subprocesses when flip processing raises](https://github.com/dattalab/moseq2-app/pull/296) — `76de73e268bd1684fee75cdc2f5ac8d31eb1b363`.
- [Print QC percentages before the generic truthy-value branch](https://github.com/dattalab/moseq2-app/pull/297) — `5bdbcf3d637124734b1afdd7bb260fac801cd3c7`.
- [Do not serialize the display-only filename column into the index](https://github.com/dattalab/moseq2-app/pull/298) — `b8f048344686193b7623308c67742d72fca74849`.
- [Select the newest model path in progress discovery](https://github.com/dattalab/moseq2-app/pull/299) — `616c6d193b730f862347e5877cbab5e335fa2baa`.
- [Keep stationary-frame counts nonnegative](https://github.com/dattalab/moseq2-app/pull/300) — `4bfe8d656145dc0000171372e6c475b6683c2b0b`.
- [Rescale integer timestamps without an in-place casting error](https://github.com/dattalab/moseq2-app/pull/301) — `993a697ef8034b98443e7d4d18476c9579963f61`.
- [Use mean minus two standard deviations for small-area QC](https://github.com/dattalab/moseq2-app/pull/302) — `dfefd76c8354cabbd5ef7d5eaf5f38f0f8f77da1`.
- [Replace only the movie extension when finding sidecar files](https://github.com/dattalab/moseq2-app/pull/303) — `b5ca7d0cded025d33fddc4ae5f073c758fac4335`.
- [Fit flip-classifier PCA within each cross-validation fold](https://github.com/dattalab/moseq2-app/pull/304) — `3691c8b3861835ad5149726c31dee1aac7c9d92f`.
- [Keep transition legend scale and signed differences consistent](https://github.com/dattalab/moseq2-app/pull/305) — `820b3fad0ca364d9c4749d5ea4c53ebd5dbeee59`.
- [Ignore unrelated movie filenames in the crowd-movie index](https://github.com/dattalab/moseq2-app/pull/306) — `8b151a00c664badab09eaedaac883a19646c7f32`.
- [Exclude unobserved values before bootstrapping confidence limits](https://github.com/dattalab/moseq2-app/pull/307) — `3eed4290850909b355fb8a29082bd1e8faa06daa`.
- [Report the actual training-frame array byte size](https://github.com/dattalab/moseq2-app/pull/308) — `9593b6d6e4e5e60abc0865386c22283f9ccb1103`.
- [Report failed preview-writer completion as an error](https://github.com/dattalab/moseq2-app/pull/310) — `b15995f14f449432e7c5e4bacca1504320bbcd87`.

### Issue-only confirmed

- [Background estimation treats missing zero depths as real floor observations](https://github.com/dattalab/moseq2-extract/issues/191).
- [Automatic floor range can be centered on a missing-depth pixel](https://github.com/dattalab/moseq2-extract/issues/192).
- [Missing physical scalar observations are filled with measured zeros](https://github.com/dattalab/moseq2-viz/issues/207).
- [Held-out sessions affect the training whitening transform](https://github.com/dattalab/moseq2-model/issues/104).
- [Define a migration/rejection policy for the mixed-unit velocity_3d_px scalar](https://github.com/dattalab/moseq2-viz/issues/208).
- [Missing heatmaps are replaced by plausible all-zero images](https://github.com/dattalab/moseq2-app/issues/309).
