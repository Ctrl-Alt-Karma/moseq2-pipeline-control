# Current-upstream finding crosswalk — 2026-10-26

This is a software handoff, not R1 scientific acceptance. Counts are topic rows; legacy IDs are aliases. PR_READY means submitted for upstream review, not merged or independently verified.

| Disposition | Count |
|---|---:|
| ALREADY_UPSTREAM | 4 |
| ISSUE_ONLY_CONFIRMED | 6 |
| OBSOLETE_OR_SUPERSEDED | 5 |
| PROJECT_CONTROL_ONLY | 15 |
| PR_READY | 51 |
| REJECTED | 1 |
| UNCONFIRMED_HANDOFF | 9 |

## Findings

### extract-integer-coordinates — PR_READY

Preserve fractional millimetres for integer pixel coordinates (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

Integer input coordinates currently truncate converted millimetres back to integers. Integer and floating representations of the same pixel locations must produce the same physical coordinates.

Historical IDs: F-14.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/182).

Historical implementations: `e7f585104ba25b66e5326c88c77a47e33db95635`.

### extract-pinhole-geometry — PR_READY

Use the pinhole relation for nominal field of view (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The focal-length calculation uses the half-angle in radians instead of its tangent. Consequently the image edge does not map to depth times tan(FOV/2). The correction uses the nominal pinhole relation, not a new camera calibration.

Historical IDs: VIZ-001.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/183).

Historical implementations: `c9faa1dc18e96c3ef59bf90aa640ff8c42eed6a9`.

### extract-mixed-unit-velocity — PR_READY

Stop emitting the dimensionally invalid velocity_3d_px scalar (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The scalar sums squared pixel displacements and squared millimetre height changes. It has neither pixel nor millimetre units. Omit this invalid field and its description; retain meaningful 2D-pixel and 3D-millimetre velocities.

Historical IDs: EXTRACT-001.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/184).

Historical implementations: `5cc858626592ea2682260eae9911827c7c0ba551`.

### extract-hampel-centroid — PR_READY

Make centroid Hampel filtering translation invariant (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The rejection threshold includes the absolute median position and the loop filters only one coordinate. Translating the same track changes which outliers are removed. Filter both coordinates with the MAD-based threshold.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/185).

Historical implementations: `93bf656c3fbdf4d976980a80f9dddaad99d8ffe1`.

### extract-hampel-angle — PR_READY

Allow angle-only Hampel filtering and use the MAD threshold (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The angle branch reuses padding initialized only by centroid filtering, and adds the median angle to the deviation threshold. Give the branch its own padding and compare deviations to scaled MAD.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/186).

Historical implementations: `93bf656c3fbdf4d976980a80f9dddaad99d8ffe1`.

### extract-ransac-seed — PR_READY

Give plane RANSAC a local reproducible random generator (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

Sampling consumes the global NumPy RNG, so unrelated draws alter an otherwise identical floor estimate. Add an explicit seed and use a local RandomState. The plane estimator, acceptance rule, and sample replacement policy are unchanged.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/187).

Historical implementations: `2c9cd86571bcc23ad6870e4da344e0f558f3f54c`.

### extract-ransac-failure — PR_READY

Raise an actionable error when RANSAC cannot find a plane (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

Too few masked points and no accepted hypotheses currently produce low-level sampling or unbound-local errors. Validate the point count and report that no plane met the existing acceptance rule.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/188).

Historical implementations: `11d2691ab56f9972930663e712c06cecb01f2eb1`, `c75272683c68cb5695be8e99d4e89ceb7adcf42b`.

### extract-depth-byte-order — PR_READY

Honor the declared raw depth pixel byte order (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The raw ffmpeg reader always interprets bytes using native uint16, including when the requested pixel format is big-endian. Decode using the explicitly declared endian order.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/189).

Historical implementations: `93bf656c3fbdf4d976980a80f9dddaad99d8ffe1`.

### extract-unsigned-raw-depth — PR_READY

Use unsigned 16-bit depth in the raw-reader CLI default (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The raw depth CLI defaults to signed int16 although depth is unsigned. Values above 32767 become negative. Use the unsigned little-endian default; explicit user dtypes remain available.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/190).

Historical implementations: `93bf656c3fbdf4d976980a80f9dddaad99d8ffe1`.

### pca-symmetric-kernel — PR_READY

Center the Gaussian smoothing kernel on its impulse (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

The generated support omits the positive endpoint and has even length. This shifts the center of an otherwise symmetric impulse response. Include both endpoints without retuning sigma.

Upstream: [link](https://github.com/dattalab/moseq2-pca/pull/133).

Historical implementations: `ff3531632aaecbc045a42570db024c429235a914`.

### pca-changepoint-sigma — PR_READY

Pass the requested changepoint sigma to the Gaussian sigma argument (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

The requested sigma is passed as the kernel window length positional argument, leaving sigma at its default. Forward it by its named sigma argument. Default changepoint parameters are not retuned.

Upstream: [link](https://github.com/dattalab/moseq2-pca/pull/134).

Historical implementations: `e9f573185e2d7ed86a2de15089903a8294635c3c`.

### pca-disabled-smoothing — PR_READY

Do not mask every changepoint when smoothing is disabled (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

With zero smoothing the edge count is zero and a [-0:] slice masks the whole signal. None also reaches unsupported arithmetic. Apply edge masking only when smoothing and its edge count are positive.

Upstream: [link](https://github.com/dattalab/moseq2-pca/pull/135).

Historical implementations: `f0d24d111bb359e6768462b6164bf579b323cbc8`.

### pca-session-timestamps — PR_READY

Use each session length for missing-timestamp fallback (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

The distributed result loop uses the frames variable left over from the last loaded session. A session without timestamps therefore receives another session's fallback time axis. Obtain fallback length from the currently open session in both distributed result loops.

Upstream: [link](https://github.com/dattalab/moseq2-pca/pull/136).

Historical implementations: `ff3531632aaecbc045a42570db024c429235a914`.

### viz-integer-coordinates — PR_READY

Preserve fractional millimetres for integer pixel coordinates (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Integer arrays truncate converted physical coordinates. Preserve floating output so integer and float representations of the same pixels agree.

Historical IDs: F-14.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/190).

Historical implementations: `b80192dc20353bf77c36610f315543b57afa908c`.

### viz-pinhole-geometry — PR_READY

Use the nominal pinhole field-of-view conversion (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The focal-length calculation uses radians instead of tan(half-FOV), violating the pinhole edge geometry. Correct the nominal conversion without claiming a calibrated camera model.

Historical IDs: VIZ-001.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/191).

Historical implementations: `3e02d2dbc8062fc6cc0e9d765030ba9b40f28d7d`.

### viz-high-state-ranks — PR_READY

Include raw states above 99 when ranking labels by usage (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Usage relabeling inherits the default 100-state statistics ceiling, so occupied raw states >=100 can be omitted or assigned incorrect ranks. Derive the needed ceiling from the supplied labels.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/192).

Historical implementations: `68ca6a34055987ff22f8651b4dca2aa254380c87`.

### viz-coverage-count — PR_READY

Include the threshold-crossing syllable in the coverage count (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The function returns the zero-based crossing position rather than the number of syllables. Even a single occupied state returns zero, so requested coverage is not retained.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/193).

Historical implementations: `68ca6a34055987ff22f8651b4dca2aa254380c87`.

### viz-first-transition — PR_READY

Count the first observed state transition (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The transition-matrix path drops the initial state before forming adjacent state pairs, omitting the first transition. Compress consecutive runs while retaining the initial state.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/194).

Historical implementations: `68ca6a34055987ff22f8651b4dca2aa254380c87`.

### viz-pairwise-groups — PR_READY

Restrict Mann-Whitney comparisons to the requested groups (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

An unrequested third group affects the pairwise computation. Select the two requested groups explicitly so adding unrelated observations cannot alter their comparison.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/195).

Historical implementations: `645415411f3119e62b59fe79e26df504d23bbb1c`.

### viz-dunn-correction — PR_READY

Correct Dunn p-values across syllables within each comparison (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The multiplicity correction runs across group-pair columns instead of syllables, the hypothesis family described by this API. Correct the axis and test it against an independently computed statsmodels correction.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/196).

Historical implementations: `645415411f3119e62b59fe79e26df504d23bbb1c`.

### viz-constant-ztest — PR_READY

Handle equal and unequal zero-variance z-test inputs (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Zero pooled spread produces NaN for equal constants. Return one for equal constants and zero for distinct constants while retaining the ordinary nonzero-spread calculation.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/197).

Historical implementations: `83e9cadebf1dbd0822c87750217c39ba1d59e3ac`, `68ca6a34055987ff22f8651b4dca2aa254380c87`.

### viz-empty-usages — PR_READY

Keep zero-total usage normalization finite (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Normalizing an empty-occupancy mapping divides by zero. Preserve its zero values when the total is zero.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/198).

Historical implementations: `83e9cadebf1dbd0822c87750217c39ba1d59e3ac`.

### viz-entropy-default — PR_READY

Use the supported rows normalization in entropy_rate by default (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The default passes row, while the transition-matrix implementation recognizes rows. The advertised default therefore differs from explicitly requested row normalization.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/199).

Historical implementations: `83e9cadebf1dbd0822c87750217c39ba1d59e3ac`.

### viz-metadata-order — PR_READY

Preserve the requested metadata column order (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Filtering metadata preserves each source mapping's insertion order, not include_keys order. Requested column order must not depend on how the input mapping was serialized.

Historical IDs: F-13.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/200).

Historical implementations: `b80192dc20353bf77c36610f315543b57afa908c`.

### viz-graph-legend — PR_READY

Match transition difference legend colors to the plotted signs (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Positive differences are drawn blue and negative differences red, while the legend assigns the opposite meanings. Correct the legend, not the underlying signed data.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/201).

Historical implementations: `8ef5b049eeaf78cecc9bad539529e3daf126ca27`.

### viz-merge-models — PR_READY

Keep state labels aligned with AR parameters when merging models (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The default cost-function alias is not implemented, the parameter key is misspelled, and the assignment direction disagrees with label remapping. Repair these mechanically coupled parts of the merge operation; a three-cycle permutation regression checks the correspondence.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/202).

Historical implementations: `68ca6a34055987ff22f8651b4dca2aa254380c87`.

### viz-best-fit-summary — PR_READY

Preserve distinct median and mean fit summaries (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Duplicate dictionary keys overwrite the median summary with the mean summary. Return distinct names so both already-computed quantities survive.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/203).

Historical implementations: `68ca6a34055987ff22f8651b4dca2aa254380c87`.

### viz-legacy-area — PR_READY

Apply an area conversion to legacy area scalars (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Legacy conversion multiplies pixel area by the mean linear scale. Use the product of x/y scales so doubling depth quadruples area while doubling linear dimensions. This is the legacy-viz counterpart of extract PR 180.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/204).

Historical implementations: `645415411f3119e62b59fe79e26df504d23bbb1c`.

### viz-sparse-nodes — PR_READY

Index difference-graph usage by node identity after thresholding (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Node display values are taken from the first N states, not the retained graph's actual nodes. Thresholded sparse graphs can display another state's size and sign. Look up each retained node explicitly.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/205).

Historical implementations: `68ca6a34055987ff22f8651b4dca2aa254380c87`.

### viz-legacy-keys — PR_READY

Read legacy scalar mappings without eager array defaults (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The cytoolz get call receives an array default and also eagerly evaluates a possibly absent legacy key. Ordinary multirow arrays fail before conversion. Use an explicit key-presence choice.

Upstream: [link](https://github.com/dattalab/moseq2-viz/pull/206).

Historical implementations: `645415411f3119e62b59fe79e26df504d23bbb1c`.

### app-flip-frame-index — PR_READY

Update flip-corrected angles at absolute frame indices (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Batch-relative indices are used against the whole-session angle dataset, corrupting earlier angles in later batches. Map decisions through each batch's absolute indices.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/292).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### app-flip-final-frame — PR_READY

Include the final frame in app flip correction (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

The batch generator receives len(frames)-1 and never classifies the last frame. Supply the complete frame count.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/293).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### app-flip-overlap — PR_READY

Commit each overlapping flip-classifier frame only once (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Overlapping batches can rotate the same frame twice. Keep classification context but defer trailing overlap and commit each frame once. The separate final-frame and absolute-angle-index defects are not folded into this change.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/294).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`, `36d40e098a5c4629116b7a4e233573218345bd5d`.

### app-flip-lifecycle — PR_READY

Refuse reprocessing of interrupted or completed flip corrections (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

App correction mutates frames in place without a lifecycle guard. Repeating it silently unflips frames; interruption leaves an unmarked partial mutation. Flush an in-progress marker before mutation, record completion/failure, skip completed sessions, and refuse ambiguous reruns. This is not a transactional rollback or power-loss guarantee.

Historical IDs: APP-001.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/295).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`, `bd103a987a0eaba50986b5cd2f992c2fb727809b`, `192921f1aff3ea58d3b1f268d71731ed222011d2`, `e0b85201226d03e15944473a734f71417698c31e`.

### app-preview-finalization — PR_READY

Finalize preview subprocesses when flip processing raises (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

An exception exits before communicate(), leaving the preview subprocess unreaped. Use a per-session try/finally for finalization. This does not add MP4 faststart or solve codec policy.

Historical IDs: APP-003, F-11.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/296).

Historical implementations: `e0b85201226d03e15944473a734f71417698c31e`.

### app-qc-percentages — PR_READY

Print QC percentages before the generic truthy-value branch (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

A nonzero float is consumed by a generic truthiness branch and its percentage is never shown. Handle percentage values first and promote the matching strict xfail to a hard regression.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/297).

Historical implementations: `313c9b5bf180fd2dbacbec071dba39b9c4472743`.

### app-index-columns — PR_READY

Do not serialize the display-only filename column into the index (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

DataFrame.drop is not assigned, so the display column leaks into saved YAML. Assign the dropped frame and promote the matching strict xfail to a hard regression.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/298).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### app-latest-model — PR_READY

Select the newest model path in progress discovery (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Ascending modification-time order chooses the oldest model despite the latest-model intent. Reverse the ordering.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/299).

Historical implementations: `61861c3382d993cbba7522985d970de5c0f92ef9`.

### app-qc-stationary — PR_READY

Keep stationary-frame counts nonnegative (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Subtracting the initial-frame correction can produce -1 when no zero velocities exist. Clamp the count to zero.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/300).

Historical implementations: `313c9b5bf180fd2dbacbec071dba39b9c4472743`.

### app-qc-integer-timestamps — PR_READY

Rescale integer timestamps without an in-place casting error (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

In-place division cannot store float seconds in an integer timestamp array. Use an out-of-place conversion and retain equivalent float-input behavior.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/301).

Historical implementations: `313c9b5bf180fd2dbacbec071dba39b9c4472743`.

### app-qc-small-area — PR_READY

Use mean minus two standard deviations for small-area QC (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

The threshold uses (mean-2)*std instead of mean-2*std, contradicting the documented rule and depending on arbitrary area scaling. Restore the documented rule; no empirical threshold is introduced.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/302).

Historical implementations: `313c9b5bf180fd2dbacbec071dba39b9c4472743`.

### app-sidecar-paths — PR_READY

Replace only the movie extension when finding sidecar files (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Global replacement of mp4 also rewrites parent directory names. Replace the trailing extension in extraction progress and scalar-sidecar discovery.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/303).

Historical implementations: `61861c3382d993cbba7522985d970de5c0f92ef9`, `313c9b5bf180fd2dbacbec071dba39b9c4472743`.

### app-cv-pca-leakage — PR_READY

Fit flip-classifier PCA within each cross-validation fold (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

PCA is fitted to all frames before cross-validation, leaking test-fold information into feature construction. Put flattening and PCA inside the classifier pipeline. The regression checks pipeline structure without training a classifier.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/304).

Historical implementations: `94b84918a3c6d4a228f1bc8a8b0e4808532dd841`.

### app-transition-legend — PR_READY

Keep transition legend scale and signed differences consistent (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Edges use factors 250/400 but legends divide by 200/350; difference widths are absolute, so selecting negative widths loses every negative difference. Share the scales and pass signed probabilities through the legend path.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/305).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### app-foreign-movies — PR_READY

Ignore unrelated movie filenames in the crowd-movie index (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

The filename parser assumes every MP4 matches and crashes on an unrelated file. Skip nonmatches and parse arbitrary-width state IDs. The fixture contains names only, not video content.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/306).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### app-bootstrap-nans — PR_READY

Exclude unobserved values before bootstrapping confidence limits (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

All-NaN bootstrap resamples can poison percentile bounds even when valid observations exist. Drop missing observations first and return explicit NaNs if none remain. The global RNG policy is intentionally unchanged.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/307).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### app-memory-display — PR_READY

Report the actual training-frame array byte size (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

nbytes already measures bytes; multiplying it by four overstates the displayed allocation. Remove the extra factor without changing data or classifier behavior.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/308).

Historical implementations: `94b84918a3c6d4a228f1bc8a8b0e4808532dd841`.

### model-training-split — PR_READY

Split validation data from the requested training boundary (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

The training slice uses split_fraction*N, but validation starts at (1-split_fraction)*N. Non-half fractions overlap or leave gaps. Use one boundary and reject fractions outside (0,1).

Upstream: [link](https://github.com/dattalab/moseq2-model/pull/102).

Historical implementations: `bf8ca260631a7c67b9e383aafefe83abd2d50a82`.

### model-scan-parameters — PR_READY

Forward declared scientific options to scan-models commands (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

Generated learn-model commands omit several already-supported CLI parameters, silently replacing requested settings with defaults. Forward the declared options, without adding removed legacy backend flags.

Upstream: [link](https://github.com/dattalab/moseq2-model/pull/103).

Historical implementations: `bf8ca260631a7c67b9e383aafefe83abd2d50a82`.

### model-export-identity — PR_READY

Bind exported label keys to the actual backend session order (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

The export lists all loaded input keys even when held-out or n/a sessions were not modeled. Labels belong to the backend session order, so zipping the exported keys with labels can misattribute them. Export the current backend's stored session order. The regression mocks training and exercises only export plumbing.

Upstream: [link](https://github.com/dattalab/moseq2-model/pull/105).

Historical implementations: `bf8ca260631a7c67b9e383aafefe83abd2d50a82`.

### app-preview-exit — PR_READY

Report failed preview-writer completion as an error (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

The preview writer is waited on but its nonzero exit status is ignored, so failed ffmpeg completion looks successful. Check the completed process status and raise an actionable error. Separate subprocess cleanup/lifecycle changes are not folded in; fake successful and failed processes exercise this contract without encoding video.

Historical IDs: APP-003.

Upstream: [link](https://github.com/dattalab/moseq2-app/pull/310).

Historical implementations: `36d40e098a5c4629116b7a4e233573218345bd5d`, `e0b85201226d03e15944473a734f71417698c31e`.

### extract-background-dropouts — ISSUE_ONLY_CONFIRMED

Background estimation treats missing zero depths as real floor observations (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

A generated 3-frame, 8x8 depth stack has valid depth 700 and zero dropout in two observations of an interior patch. With med_scale=1, get_bground_im_file returns zero for that patch. np.nanmedian does not ignore zero. The pre-temporal spatial blur also spreads invalid depths.

Upstream: [link](https://github.com/dattalab/moseq2-extract/issues/191).

Historical implementations: `c5e45345dea28873b1cc883e76498dd945680494`.

### extract-auto-floor-center — ISSUE_ONLY_CONFIRMED

Automatic floor range can be centered on a missing-depth pixel (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The current automatic-range branch reads bground_im[cY][cX] after get_bucket_center and uses that single value +/-50 mm. A zero/missing center in an otherwise valid synthetic 700 mm floor therefore produces [-50,50]. This is a static branch-level reproduction, not an end-to-end ROI acceptance claim.

Upstream: [link](https://github.com/dattalab/moseq2-extract/issues/192).

Historical implementations: `b4429f839637782312a7008e82977f5c4a0e2a14`.

### viz-missing-scalar-observations — ISSUE_ONLY_CONFIRMED

Missing physical scalar observations are filled with measured zeros (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

get_session_mean_df fills an unobserved syllable scalar with zero. In a two-session synthetic table where each session expresses only one state, the absent height is returned as 0 rather than missing. Zero usage/count can be meaningful; zero height/duration for an unobserved state is not a measurement. The app InteractiveSyllableStats path separately calls self.df.fillna(0).

Upstream: [link](https://github.com/dattalab/moseq2-viz/issues/207).

Historical implementations: `645415411f3119e62b59fe79e26df504d23bbb1c`, `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### model-heldout-whitening — ISSUE_ONLY_CONFIRMED

Held-out sessions affect the training whitening transform (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

prepare_model_metadata selects held-out keys, then calls whiten_all(data_dict) on the entire input dictionary. A generated two-session example with hold_out_seed=0 holds b out and trains on a. Changing only b shifts the transformed a. No sampler is invoked.

Upstream: [link](https://github.com/dattalab/moseq2-model/issues/104).

Historical implementations: `bf8ca260631a7c67b9e383aafefe83abd2d50a82`.

### viz-invalid-mixed-unit-scalar — ISSUE_ONLY_CONFIRMED

Define a migration/rejection policy for the mixed-unit velocity_3d_px scalar (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The legacy converter constructs velocity_3d_px by summing squared x/y pixel displacements and squared height_ave_mm differences. get_scalar_triggered_average also accepts this field at its public include_keys boundary without a unit warning or rejection. The attached generated-value test confirms current acceptance. The dimensional defect is not a statement that an arbitrary supplied array is corrupt.

Historical IDs: VIZ-002, F-01.

Upstream: [link](https://github.com/dattalab/moseq2-viz/issues/208).

Historical implementations: `62ec4d579dffe0712e2e5b7f8531a029b3a04f00`, `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`, `b80192dc20353bf77c36610f315543b57afa908c`.

### app-missing-heatmap — ISSUE_ONLY_CONFIRMED

Missing heatmaps are replaced by plausible all-zero images (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

CrowdMovieComparison.generate_crowd_movie_divs catches every Exception while fetching a group PDF, substitutes np.zeros((50,50)), and then passes it to get_pdf_plot whenever cm_path is nonempty. Thus missing data and even unexpected errors can become a normal-looking heatmap. This is confirmed by static inspection and an isolated exception-branch reconstruction, not by opening any movie or running a notebook.

Upstream: [link](https://github.com/dattalab/moseq2-app/issues/309).

Historical implementations: `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### extract-area-mm — ALREADY_UPSTREAM

Area conversion (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

Current compute_scalars uses an area conversion; independent depth-doubling regression passed. PR 180 merged at 81c49e6e7dac99afd64df8312accea8680555fc8 and issue 179 is closed completed.

Upstream: [link](https://github.com/dattalab/moseq2-extract/pull/180), [link](https://github.com/dattalab/moseq2-extract/issues/179).

Historical implementations: `93bf656c3fbdf4d976980a80f9dddaad99d8ffe1`.

### pca-short-chunk-overlap — ALREADY_UPSTREAM

Local temporal-filter overlap clamp (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

apply_pca_local already clamps overlap to min(smallest_chunk,20); current git blame identifies a8f66cf2 (2018). Do not transplant a duplicate repair.

Historical implementations: `ff3531632aaecbc045a42570db024c429235a914`.

### viz-numpy-object — ALREADY_UPSTREAM

Removed NumPy object alias (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Current relevant model utilities use builtin object rather than removed np.object. Modernization already covers the compatibility correction.

Historical implementations: `645415411f3119e62b59fe79e26df504d23bbb1c`.

### app-pandas-any-axis — ALREADY_UPSTREAM

Pandas row-null axis keyword (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

count_nan_rows already calls any(axis=1). The historical positional-axis compatibility patch is unnecessary.

Historical implementations: `313c9b5bf180fd2dbacbec071dba39b9c4472743`.

### extract-ransac-estimator-design — UNCONFIRMED_HANDOFF

RANSAC refit/ranking/sample policy (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

Current estimator still returns a three-point hypothesis and samples with replacement. The historical inlier-refit/ranking changes may improve synthetic RMS, but no generally mandatory scientific estimator contract was established. Do not label an algorithm preference a proven universal defect.

Historical implementations: `11d2691ab56f9972930663e712c06cecb01f2eb1`.

### extract-floor-helper-opencv — OBSOLETE_OR_SUPERSEDED

Old OpenCV binding fault in fork-only floor heuristic (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

estimate_depth_range and its connected-components heuristic are absent upstream. The old OpenCV-4 binding workaround was for that fork-added helper; it is not an applicable current-upstream patch.

Historical implementations: `b4429f839637782312a7008e82977f5c4a0e2a14`, `c75272683c68cb5695be8e99d4e89ceb7adcf42b`.

### extract-ellipse-centroid-calibration — UNCONFIRMED_HANDOFF

Ellipse axes, centroid and calibrated dimensions (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

No independent current-source counterexample establishes a separate width/length or centroid defect beyond the submitted coordinate/unit corrections. Rotated anisotropic-camera axis conversion and calibrated intrinsics remain limitations, not proof of incorrect biological dimensions.

Historical implementations: `93bf656c3fbdf4d976980a80f9dddaad99d8ffe1`, `c9faa1dc18e96c3ef59bf90aa640ff8c42eed6a9`.

### extract-provenance-contract — PROJECT_CONTROL_ONLY

Project extraction policy/provenance stamps (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The project added a provenance schema/output policy absent from upstream. Schema enforcement is project instrument custody; absence of our schema is not an upstream parse bug.

Historical implementations: `424d643affb685e1cad145e3c7051b814d11265c`, `5cc858626592ea2682260eae9911827c7c0ba551`.

### nonvacuous-scalar-regression — PROJECT_CONTROL_ONLY

Non-vacuous scalar tests (dattalab/moseq2-extract, `d1b0e75d0a696d071d4d158ab2b16787f52890df`).

The former zero-motion fixture could not establish nonzero velocity correctness. Current scalar PR has nonzero 3/4 pixel motion and 12 mm height change. Test adequacy is a project evidence correction, not another upstream scientific defect.

Historical IDs: EXTRACT-002.

Historical implementations: `ec418d7a2f134dcd3e62883ce7317bb68197a20b`, `f028801e9a6b54ffa63e22d9e10179ea7419ccc4`.

### pca-sigma-1p3-retune — PROJECT_CONTROL_ONLY

Historical sigma 1.3 cadence preservation (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

The project changed sigma to preserve a historical cadence after repairing the kernel. This does not justify retuning upstream defaults. No upstream threshold/default retune is submitted.

Historical implementations: `e1fa3f8d2befdd90e1c1c281313c79010fae9d4e`.

### pca-frame-rate-estimation — UNCONFIRMED_HANDOFF

Mean/median timestamp FPS inference (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

The fork used robust timestamp cadence and fallback handling. Current routines infer FPS using mean differences. The correct treatment of drift, gaps and fallback cadence needs a defined timing contract; no candidate data or new method was used to invent one here.

Historical implementations: `ff3531632aaecbc045a42570db024c429235a914`, `f0d24d111bb359e6768462b6164bf579b323cbc8`.

### pca-old-scipy-import — OBSOLETE_OR_SUPERSEDED

Old scipy.stats import dependency (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

A current-environment import probe resolves scipy.stats.zscore after scipy.signal without the extra historical import. This is not proof about every old SciPy build; the current probe does not reproduce the old failure.

Historical implementations: `e9f573185e2d7ed86a2de15089903a8294635c3c`.

### pca-randomized-svd — UNCONFIRMED_HANDOFF

Unseeded randomized PCA risk (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

The legacy risk register records randomized SVD without an explicit seed. No repeated PCA fit was authorized or performed. This remains a reproducibility risk observation, not a newly proven source defect or instruction to rerun R1.

### pca-provenance-stamps — PROJECT_CONTROL_ONLY

Project PCA/changepoint provenance (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

Project-specific artifact provenance stamps are not an upstream schema contract. Exact R1 PCA/changepoint custody is preserved, not regenerated.

Historical implementations: `efb6fcfa5d5af5bb4274540c371d0ddf96440b78`.

### pca-artifact-binding — PROJECT_CONTROL_ONLY

Project PCA role/binding mistakes (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

Wrong artifact roles, manifest binding, persisted-row accounting and protocol readiness belonged to our operator/control plane, not an upstream PCA algorithm defect.

### model-legacy-prior-stability — OBSOLETE_OR_SUPERSEDED

Legacy regularize_for_stability (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

The current JAX backend removed regularize_for_stability. It explicitly maintains covariance definiteness without writing the old data-dependent ridge into the prior. Do not port the pyhsmm repair into a removed path or claim backend equivalence.

Historical implementations: `bf8ca260631a7c67b9e383aafefe83abd2d50a82`.

### model-legacy-float64-layout — OBSOLETE_OR_SUPERSEDED

Old compiled sampler contiguous-float64 repair (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

The historical patch repaired a fork preprocessing regression and the pyhsmm input contract. Current backend stacking converts to float64 arrays under a different implementation. No legacy ABI workaround is proposed.

Historical implementations: `4215f63f422ff40237db77d7c0de9cf990e14302`.

### model-legacy-seed-cli — OBSOLETE_OR_SUPERSEDED

Legacy sampler CLI seed forwarding (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

Current ARHMM has a JAX seed contract, while the old pyhsmm CLI flag is absent. The submitted scan fix forwards only currently declared options, not a removed flag. Backend seeding is not claimed equivalent to R1.

Historical implementations: `bf8ca260631a7c67b9e383aafefe83abd2d50a82`.

### model-provenance-and-kappa-governance — PROJECT_CONTROL_ONLY

Model provenance, target/kappa governance and M_R2 qualification (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

These are project artifact/experiment custody decisions, not upstream model-source defects. Keep final-kappa closure, the qualified M_R2 extractor and artifact-selection chronology unchanged.

Historical implementations: `6e542e3f1db125202d42b59f390c922281e64f39`.

### viz-statistical-test-choice — UNCONFIRMED_HANDOFF

Student versus Welch default (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Changing equal-variance test assumptions is a scientific-method choice, not established as universally wrong by the historical patch. No test-family or biological inference is changed.

Historical implementations: `645415411f3119e62b59fe79e26df504d23bbb1c`.

### viz-bootstrap-rng-policy — UNCONFIRMED_HANDOFF

Bootstrap plot repeatability (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Unseeded bootstrap intervals can vary by design. The historical default-seeding proposal is preserved, but variation alone is not proof of an upstream defect. The separately submitted NaN fix does not change RNG policy.

Historical implementations: `645415411f3119e62b59fe79e26df504d23bbb1c`, `c85b9a224fb6ffec656e8c9231ba0af63d28dd2c`.

### viz-no-event-transition-entropy — UNCONFIRMED_HANDOFF

Entropy when no transitions are observed (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Current generated one-state example yields NaN through zero-column normalization. No observed transitions means the distribution is unidentified; forcing entropy to zero requires a convention. No unsupported finite-zero guarantee is imposed.

Historical implementations: `83e9cadebf1dbd0822c87750217c39ba1d59e3ac`.

### viz-fork-provenance-readers — PROJECT_CONTROL_ONLY

Corrupt/nonmapping provenance and pooling enforcement (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Fail-open readers, conflicting paths, nonmapping records and dormant helpers existed in our fork-added provenance system. Current upstream does not contain those reader APIs. Their project fixes are preserved without describing absent upstream functions as broken.

Historical IDs: VIZ-004, F-03, F-12, F-15.

Historical implementations: `b2ad7e71dbae0da5e2d5e8575d7e9476c95cd2da`, `62ec4d579dffe0712e2e5b7f8531a029b3a04f00`, `32fe617db2cfd160070c85bed1ae0dfc19d797d1`, `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`, `b80192dc20353bf77c36610f315543b57afa908c`.

### viz-mapping-preserving-deprecation — PROJECT_CONTROL_ONLY

Mapping-preserving deprecated-scalar filtering (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The broken filter was part of our fork-added deprecation API. Preserve the corrected mapping contract as design knowledge; upstream migration/rejection policy is separately reported in issue 208.

Historical IDs: VIZ-003.

Historical implementations: `62ec4d579dffe0712e2e5b7f8531a029b3a04f00`, `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`.

### viz-cross-package-contract-tests — PROJECT_CONTROL_ONLY

Cross-package policy copies and undeclared test dependency (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

The defective hardcoded-key comparison and missing extract test dependency were in our provenance tests. Current upstream test ownership is package-local for unit tests and central moseq2-test for cross-package profiles. No legacy cross-package fixture is transplanted.

Historical IDs: F-02, F-04.

Historical implementations: `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`, `b80192dc20353bf77c36610f315543b57afa908c`.

### viz-duplicated-conversion-design — PROJECT_CONTROL_ONLY

Duplicated conversion implementation (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

Code duplication alone does not establish numerical error. Equivalent independent pinhole/dtype regressions were submitted in both packages. Consolidating package ownership would be a separate maintainer design decision, not necessary for these bounded corrections.

Historical IDs: F-08.

Historical implementations: `3e02d2dbc8062fc6cc0e9d765030ba9b40f28d7d`, `b80192dc20353bf77c36610f315543b57afa908c`.

### app-journal-sentinel-custody — PROJECT_CONTROL_ONLY

Fork journal records, sentinels, canonical paths and fail-closed readers (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Our journal schema/readers are absent upstream. Malformed slots, authoritative sentinel semantics, interrupted diagnostics and canonical-path agreement were defects/requirements of that project extension. A minimal native lifecycle guard is separately submitted for the actual upstream reprocessing defect.

Historical IDs: APP-002, F-05, F-10, F-12.

Historical implementations: `bd103a987a0eaba50986b5cd2f992c2fb727809b`, `f7af95d75c3b289b8a438783fda93b79fdb031fb`, `192921f1aff3ea58d3b1f268d71731ed222011d2`, `e0b85201226d03e15944473a734f71417698c31e`.

### app-extraction-app-flip-policy — UNCONFIRMED_HANDOFF

Layered extraction and app correction / stale-flip rendering (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Our accepted instrument prohibited layering and qualified an effective flip policy. Current upstream has no equivalent journal reader. A current whole-path orientation defect was not dynamically established here; metadata-state compatibility needs an explicit policy, not blind transplantation of the project guard.

Historical IDs: F-09.

Historical implementations: `f7af95d75c3b289b8a438783fda93b79fdb031fb`, `e0b85201226d03e15944473a734f71417698c31e`.

### app-fault-model-evidence — PROJECT_CONTROL_ONLY

In-process exception versus SIGKILL / power-loss claims (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

An in-process exception invokes h5py close/flush and is not evidence of SIGKILL behavior. H5Fflush is not fsync/power-loss durability. New lifecycle tests claim exception/reprocessing behavior only; no stronger crash-atomicity guarantee is asserted.

Historical IDs: F-06, F-07.

Historical implementations: `192921f1aff3ea58d3b1f268d71731ed222011d2`, `e0b85201226d03e15944473a734f71417698c31e`.

### app-frame-drop-estimand — UNCONFIRMED_HANDOFF

Frame-rate error versus missing-gap fraction (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

Current timestamp QC reports relative average acquisition-rate deviation, while the historical fork substituted a gap-count statistic. The name/documentation is broader than the formula, but the correct estimand is a policy question. The integer-rescaling exception is independently fixed without retuning this metric.

Historical implementations: `36d40e098a5c4629116b7a4e233573218345bd5d`.

### orientation-byte-equality-inference — REJECTED

Byte inequality implies failed orientation (dattalab/moseq2-viz, `5b52b176fbfa4fb1a6a7a69f48e7c37ac2730ba8`).

A generated asymmetric 80x80 fixture is not byte-equal after discrete 180-degree rotation followed by OpenCV rotation about an even crop center, yet matches exactly under a one-pixel translation and cannot match the rotated negative reference. Reject only that over-strict inference; this is not a current full-path viz qualification PASS.

Historical IDs: F-09.

### project-transport-and-review-semantics — PROJECT_CONTROL_ONLY

Rule-artifact transport, pycache exclusions and reviewer semantics (dattalab/moseq2-app, `eefa3d5c15e21adef6e9ede343f2705f37d3e47b`).

The missing rule artifacts and incomplete omission ledger were project evidence-transport defects. Preserve rule/protocol/conformance together and exact contents-union-exclusions set equality. Neither is an app scientific-code defect.

### project-replay-comparator-custody — PROJECT_CONTROL_ONLY

R1 comparator and environment/artifact custody (dattalab/moseq2-model, `ed1fb9bff59db377eb3b45d996b3195ff0f93637`).

Comparator false negatives, operator source identity, environment freezing and replay receipt capture belonged to the project control plane. D-053 through D-056 remain historical accepted records. No comparator/scientific rerun occurs in closeout.

### pca-kernel-regression-fixture — PROJECT_CONTROL_ONLY

Historical kernel regression fixture (dattalab/moseq2-pca, `e2dcce0c318681fe7625fb3b91849ecffb2f3d9c`).

This tests-only repair updates the asymmetric-kernel expectation. The current upstream correction has an independent centered-impulse regression; a historical implementation-mirroring expectation is not separate proof of correctness.

Historical implementations: `d4e53b7784d37d5d12498d631aa4d1a29c715d5d`.

## Evidence limits

The machine-readable record carries original bases, current targets, reproduction receipts and historical verification limitations. HISTORICAL_SYMBOL_COVERAGE.json ties all 40 nonmerge repair commits and their changed symbols to reviewed topics. Tests-only historical commits are included. No historical proposal is promoted merely because code exists.
