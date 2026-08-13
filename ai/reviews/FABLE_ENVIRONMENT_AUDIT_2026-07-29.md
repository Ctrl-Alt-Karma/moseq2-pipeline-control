MODE: FABLE / INDEPENDENT SCIENTIFIC SOFTWARE VALIDATOR

Before answering I want the two repos I have never inspected, since PCA and model dominate the numerical-reproducibility question.One more check, since wheel availability materially changes the answer to F.MODE: FABLE / INDEPENDENT SCIENTIFIC SOFTWARE VALIDATOR

I read the actual source of all five repositories at the SHAs you listed before answering. Four things I found change the shape of this decision, and I want them visible before the section-by-section response.

**Finding 1: the legacy environment cannot currently be rebuilt from its own metadata.**

```
model_rel/setup.py:
    "pyhsmm @ git+https://github.com/mattjj/pyhsmm.git@master",
    "pybasicbayes @ git+https://github.com/mattjj/pybasicbayes.git@master",
    "autoregressive @ git+https://github.com/dattalab/pyhsmm-autoregressive.git@master",
```

Three unpinned `@master` Cython dependencies carry the entire ARHMM sampler. Katya's working environment contains whatever those repos happened to be on installation day. If that WSL2 image is lost, the legacy environment is unreproducible, and with it every result ever produced from it. This is a more urgent problem than the modern-stack question.

**Finding 2: PCA is already nondeterministic inside the legacy environment.**

```
pca_rel/moseq2_pca/pca/util.py:62
    _, s, v = lng.svd_compressed(dask_array - mean, rank, 0, compute=True)
```

`svd_compressed` is a randomized projection method. No seed is passed. Results also depend on dask chunk layout and worker count through floating-point reduction order. Your proposed control ("identical recordings, configurations, seeds") does not cover this stage, so as written step 4 cannot succeed at PCA regardless of environment.

Flagging uncertainty precisely: I am reading the call site, not dask 2.30.0's source. I believe position 3 binds `n_power_iter` and `seed` defaults to `None`, but that must be confirmed against the pinned dask version. That verification matters twice over, because a positional argument bound to a third-party signature that later gained parameters is itself a silent-change vector on upgrade.

**Finding 3: h5py 3.x silently changes metadata types, and the code does not defend against it.**

```
viz_r2/moseq2_viz/util.py  _load_h5_to_dict
            if isinstance(item, h5py.Dataset):
                ans[key] = item[()]        # no decode
```

Under h5py 2.10 variable-length string datasets read back as `str`; under h5py 3.x they read back as `bytes`. The provenance readers handle this explicitly (`if isinstance(raw, bytes): raw = raw.decode()`). The generic metadata reader does not. `SessionName`, `SubjectName`, `StartTime` and UUIDs flow through this path into index matching and group assignment. This is a silent-corruption vector, not a crash, and the nine viz tests that would have caught it are exactly the nine `BLOCKED BY ABSENT REPOSITORY FIXTURE/DATA`.

**Finding 4: the pinned stack and NumPy 1.26.4 have no Python version in common.**

```
opencv-python/4.1.2.30       requires_python=none    cp_wheels=cp35,cp36,cp37,cp38
h5py/2.10.0                  requires_python=none    cp_wheels=cp34,cp35,cp36,cp37,cp38
scipy/1.3.2                  requires_python=>=3.5   cp_wheels=cp35,cp36,cp37,cp38
numpy/1.18.3                 requires_python=>=3.5   cp_wheels=cp35,cp36,cp37,cp38
scikit-image/0.16.2          requires_python=>=3.6   cp_wheels=cp36,cp37,cp38
numpy/1.26.4                 requires_python=>=3.9   cp_wheels=cp39,cp310,cp311,cp312
```

The pinned set ends at cp38. NumPy 1.26.4 starts at cp39. Disjoint. This is decisive for question F and I will return to it there.

---

## A. Can the listed changes alter scientifically meaningful outputs?

Yes, and not marginally. Ranked by how much damage each can do here, with the specific mechanism in this codebase:

**scikit-learn (highest risk, and it is not on your list).** The flip classifier is an unpickled sklearn estimator:

```
extract_r2/moseq2_extract/extract/proc.py
    clf = joblib.load(flip_file)
    flip_class = np.where(clf.classes_ == 1)[0]
    probas = clf.predict_proba(...)
```

That pickle was produced under scikit-learn 0.20.3. scikit-learn does not guarantee cross-version pickle compatibility and says so. Loading it under a modern sklearn will either raise, or load with changed internals and produce different probabilities. The flip decision determines which frames get rotated 180 degrees and which get `angle += pi`. A single changed decision changes the frames themselves, and everything downstream inherits it. **Add scikit-learn to your controlled-variables list and treat the classifier pickle as primary research data, not as a dependency.**

**NumPy C-ABI and Cython.** pyhsmm, pybasicbayes and autoregressive are compiled extensions built against NumPy 1.x headers with `cython==0.29.14`. NumPy 2.0 changed the C ABI; those extensions require rebuilding and source-level compatibility work. Cython 0.29.x does not reliably build on Python 3.11+. This is a hard gate on any modern target.

**BLAS/LAPACK.** Conda NumPy typically links MKL; PyPI wheels link OpenBLAS. Different libraries, different threading, different reduction orders, different last bits in every matrix operation. In a Gibbs sampler those differences do not stay small: they change the accept/reject and sampling path, and trajectories diverge. Thread count alone changes results in OpenBLAS because it changes partition boundaries.

**h5py/HDF5.** Finding 3 above. Also compression filter availability and chunk layout, which affect file portability though not values.

**OpenCV.** Already observed empirically: `cv2.getRotationMatrix2D` in a modern build rejects a NumPy integer scalar that 4.1.2.30 accepted (that is your one extract test failure). The extract source also documents a `connectedComponentsWithStats` keyword-form segfault specific to the pinned 4.1.2 build. Interpolation defaults in `warpAffine` directly affect `crop_and_rotate` pixel values.

**scikit-image.** `skimage.external.tifffile` was removed; you have already hit this. Background and ROI images round-trip through TIFF.

**pandas.** groupby/apply semantics, dtype inference, sort stability and `observed=` defaults all changed between 1.0.5 and 2.x. The viz summary layer is groupby-heavy.

**SciPy.** `medfilt` edge handling and `linalg` backends. Lower risk than the above but non-zero.

**ffmpeg.** Lower risk than I expected, and this is a point in your favour: archival conversion uses `ffv1`, which is lossless. Decoder version should not change pixel values. It is not zero risk (pix_fmt handling, ffv1 level) but it is the least of these.

**Operating system.** Mostly a proxy for BLAS, glibc math (`libm` transcendentals can differ by an ULP across versions), and filesystem iteration order. Note that both round-2 validation environments were Windows and the target is WSL2 Ubuntu, so no validation to date has run on the production OS.

**Python itself.** Dict ordering is guaranteed since 3.7 so that is safe. The real interpreter-level risks are hash randomization affecting set iteration order where sets feed ordered computation, and changes to `math`/`float` repr. Modest compared to the library risks.

## B. Per-stage sensitivity

| Stage | Sensitivity | Dominant mechanism |
|---|---|---|
| Depth/video extraction | **High** | ffv1 decode, OpenCV morphology and `warpAffine` interpolation, `connectedComponentsWithStats` build quirks, `em_get_ll` float reductions |
| Filtering and morphology | **Medium-high** | OpenCV kernel implementations and SIMD paths; `medfilt` edge handling; results feed everything |
| Scalar computation | **Low-medium**, and the best-controlled stage | Pure NumPy arithmetic on deterministic inputs. The candidate PRs fixed the dtype-truncation and unit bugs here. Differences would come from BLAS-free elementwise ops, so near-bitwise is achievable **given identical input frames** |
| Flip correction | **Critical, and binary** | The sklearn pickle. Output is a boolean decision per frame. There is no tolerance band: a decision either matches or it does not, and a mismatch rotates real data |
| PCA | **Critical, and already stochastic** | Unseeded `svd_compressed`, chunk-dependent reductions, worker-count dependence, singular-vector sign convention |
| Model fitting | **Highest** | Gibbs sampling over ARHMM. Seeds control the stream, but BLAS bit differences and any change in the number or order of RNG draws inside three unpinned `@master` Cython packages will diverge trajectories |
| Visualization and summaries | **Medium** | pandas groupby/apply semantics; h5py string types corrupting group assignment before any statistics run |

The ordering matters strategically: sensitivity is roughly monotone increasing down the pipeline, and errors compound. Equivalence must be established stage by stage in pipeline order, and a stage may not be evaluated until its input has been proven equivalent.

## C. The four equivalence tiers

**Bitwise identity.** Byte-for-byte identical outputs. Achievable and *required* for: raw extracted frames, masks, `metadata/extraction/flips`, and the flip decision vector. These are integer or boolean data produced by deterministic operations. If frames are not bitwise identical, stop; nothing downstream is interpretable.

**Numerical equivalence.** Differences bounded by floating-point accumulation, not by algorithm change. Appropriate for scalars given identical frames. Test as relative difference against a stated tolerance, and require the *distribution* of differences to look like rounding (symmetric, near machine epsilon) rather than structured bias.

**Statistical equivalence.** Outputs are draws from the same distribution. This is the only meaningful tier for PCA and model fitting, because both are stochastic. It requires a two-sided equivalence test against a pre-registered margin, not a null-hypothesis test. "We failed to detect a difference" is not evidence of equivalence, and with small n it is mostly evidence of low power.

**Scientific/conclusion equivalence.** The analysis supports the same conclusion. Necessary but never sufficient on its own, because it is the easiest tier to pass for the wrong reason: an underpowered comparison will agree on "no significant difference between genotypes" in both environments while the underlying syllable structure has completely changed.

The failure mode I would guard hardest against is accepting conclusion equivalence as a substitute for the tiers above. All four must be evaluated, each at the stage where it is the appropriate tier.

## D. Are fixed seeds sufficient?

**No.** Seeds are necessary and roughly one third of what is required.

What the seed does buy you: `np.random.seed()` and `random.seed()` set the legacy MT19937 streams, and NumPy's documented policy is that the legacy `RandomState` stream is version-stable. So the same seed does give the same underlying stream on 1.18.3 and 1.26.4. That guarantee is real and useful.

What it does not buy you, all of which must be separately controlled:

1. **The sequence of draws.** The stream is only reproducible if the same code requests the same numbers in the same order. Three unpinned `@master` dependencies sit between your seed and the sampler. Pin them to explicit commit SHAs.
2. **PCA.** Not seeded at all (Finding 2). The PC basis feeding the model is a free variable today.
3. **BLAS library, version, and thread count.** Set `OMP_NUM_THREADS`, `MKL_NUM_THREADS` and `OPENBLAS_NUM_THREADS` to 1 for all equivalence runs. Single-threaded is slower and is the only way to make reduction order deterministic.
4. **Dask worker count and chunk size.** Use `--cluster-type nodask` where the code path allows it, or fix workers to 1 and chunk size explicitly.
5. **`PYTHONHASHSEED`.** Set it explicitly.
6. **Hold-out split.** Already tied to the seed in `wrappers.py`, which is good, but verify it in the captured config rather than assuming.
7. **Input file iteration order.** Anything driven by `glob` or `os.walk` inherits filesystem order. Sort explicitly.
8. **The classifier pickle.** Same file, verified by SHA-256, in both environments.

## E. Recommended order

**Legacy pilot first.** Your instinct is right, and I would go further: the legacy pilot is not the first action.

The correct sequence is:

**Step 0, before any pilot: freeze the legacy environment.** It is currently a single point of failure holding unreproducible research infrastructure (Finding 1). Export `conda env export --no-builds` and `pip freeze`; resolve and record the three `@master` dependencies to explicit commit SHAs; archive wheels/sdists of every package; image the WSL2 distribution; SHA-256 everything. Until this exists, a disk failure ends the project's reproducibility.

**Step 1: legacy pilot.** Establishes the scientific baseline and, equally important, exercises the repaired candidate code against real recordings for the first time. Note the pilot is testing two things at once (repaired code, real data) and the environment is the constant. That is the right variable to hold fixed first.

**Step 2: within-legacy repeatability.** Run the identical pilot three to five times in the same environment. This measures how much the pipeline varies against itself. Without this number you have nothing to compare a cross-environment difference to, and no principled basis for any tolerance. I expect extraction and scalars to be bitwise repeatable and PCA and model not to be. Whatever the answer, it is the denominator for everything in section G.

**Step 3: build the modern environment, run nothing scientific in it yet.** Qualify it mechanically: does the classifier pickle load, do the Cython extensions build, does `write_pipeline_provenance` run, do metadata strings come back as `str`.

**Step 4: staged differential comparison**, in pipeline order, gated per stage.

**Step 5: promotion** only on the criteria in G.

Modern-first is wrong here for a specific reason beyond the obvious: you would be changing the code and the environment in the same step, and when the numbers differ you would not know which caused it.

## F. Evaluating Python 3.11 + NumPy 1.26.4

**Reject it as the first modern candidate.** Not because it is wrong as a destination, but because it is not one step. It is the maximum-change option presented as a moderate one.

Per Finding 4, the pinned wheels stop at cp38 and NumPy 1.26.4 starts at cp39. There is no Python version where the current pins and 1.26.4 coexist. Moving to 3.11 therefore forces simultaneous replacement of NumPy, SciPy, OpenCV, scikit-image, h5py and pandas, plus recompilation of three unpinned Cython packages, plus resolution of the sklearn pickle question. Six or more coupled variables in a single differential comparison. When outputs differ you will not be able to attribute the difference, and you will have no reduced experiment available to isolate it.

Python 3.11 additionally breaks `cython==0.29.14`, so the three sampler dependencies must be rebuilt with a newer Cython, changing generated C for the most numerically sensitive stage in the pipeline.

**The better first modern candidate is Python 3.8, holding every current library pin unchanged.**

This is the only genuinely single-variable step available: identical NumPy 1.18.3, SciPy 1.3.2, OpenCV 4.1.2.30, scikit-image 0.16.2 and h5py 2.10.0 wheels exist for cp38, so only the interpreter changes. If outputs are bitwise identical there, you have proven the interpreter is not a factor and, just as valuable, you have proven your comparison harness can correctly report "no difference" when there is none. A harness that has never returned a negative result is not yet trustworthy.

Python 3.8 is end-of-life and is emphatically not a destination. It is a diagnostic step.

After that the cliff is unavoidable, so take it deliberately: **Python 3.11 + NumPy 1.26.x as the destination**, entered with the three git dependencies pinned to explicit SHAs, the h5py string-decoding defect fixed first, and the classifier question resolved first. I would choose 3.11 over 3.10 for the longer support runway and over 3.12 because 3.12 forces Cython 3.x on the sampler extensions, adding change where you can least afford it.

Two prerequisites are hard gates on any version above 3.8:

- **The h5py 3.x string decoding must be fixed before the first modern scientific run,** not after. You cannot reach any modern Python while keeping h5py 2.10, and h5py 3.x silently changes metadata types in a code path with no test coverage.
- **The flip classifier must be resolved explicitly.** Either verify byte-identical `predict_proba` output under the modern sklearn, or re-train and treat the new classifier as a deliberate scientific change requiring its own validation. Do not let an unpickling warning decide this.

Also worth noting: NumPy 2.x is not a near-term option at all. `np.string_` blocks the provenance writer and `np.asscalar` is already gone from `clean_dict` in both extract and viz. Those are pre-existing defects, not PR regressions, and they should be fixed on their own schedule rather than under upgrade pressure.

## G. Acceptance criteria and tolerances

The governing principle: **no cross-environment tolerance may be set before within-environment variability has been measured** (Step 2). Every threshold below that is expressed relative to that measurement, and the numeric placeholders I give are starting proposals to be replaced by the measured values, not recommendations to adopt as-is.

Gate each stage; do not evaluate a stage until its input has passed.

**Gate 1, extraction.** Extracted frames, masks and `metadata/extraction/flips` **bitwise identical**. No tolerance. Compare by SHA-256 of the datasets. Failure here stops the comparison.

**Gate 2, flip decisions.** The boolean decision vector **exactly equal**, and the classifier file SHA-256 identical in both environments. Zero disagreements permitted. If `predict_proba` differs at all, report it even when decisions happen to agree, since agreement may be luck near the 0.5 boundary.

**Gate 3, scalars.** Given Gate 1 passed, require max relative difference ≤ 1e-9 on all float scalars, and exact equality on integer-valued ones (`area_px`). Additionally require that the difference distribution is symmetric about zero with no structure against frame index or centroid position. Structured residuals mean an algorithm change, not rounding, even when the magnitude is small.

**Gate 4, PCA.** Because the stage is stochastic, compare distributions, not runs. With n ≥ 5 repeats per environment: explained-variance ratios per component agreeing within the within-legacy spread; principal angles between the two PC subspaces no larger than the within-legacy principal angles; sign and permutation canonicalized before comparison. Between-environment spread must not exceed within-environment spread. If PCA gets seeded first (which I recommend), this gate strengthens to numerical equivalence and becomes far cheaper to satisfy.

**Gate 5, model fitting.** With n ≥ 5 seeds per environment: log-likelihood traces overlapping within the within-legacy band; syllable-usage distributions equivalent under a two-sided test with a pre-registered margin; label agreement after optimal (Hungarian) matching at or above the within-legacy label agreement across seeds. State the margin before running. Do not compare a single legacy fit to a single modern fit.

**Gate 6, summaries and conclusions.** Group-level statistics agreeing within the within-legacy spread, and every reported conclusion identical in direction, significance and effect-size ordering. Explicitly confirm that metadata strings, group assignments and session counts match, since Finding 3 corrupts precisely these without touching any number.

**Standing requirements across all gates.** Same recordings by SHA-256; same configs by SHA-256; same classifier pickle by SHA-256; single-threaded BLAS; `PYTHONHASHSEED` fixed; dask workers and chunk size fixed; both environments fully captured and archived; every gate result recorded whether it passed or failed.

**Promotion criterion.** All six gates pass on a minimum of two independent recording sets, one of which must be a dataset whose scientific result is already known and published or reported internally. Passing on synthetic or convenient data only is not promotion evidence.

**Non-promotion criterion, stated in advance:** if any gate fails and the cause cannot be identified and eliminated, the modern stack does not get promoted. "The difference is small" is not a passing result if it is unexplained.

---

## Verdict

**AGREE WITH REQUIRED REVISIONS**

All seven of your points are sound and I would keep every one. Point 3 (separate environment rather than in-place upgrade) and point 6 (legacy as reference oracle) are the two that matter most, and point 7 is exactly the right instinct even though the specific candidate turns out to be wrong. The revisions below are additions and one substitution, not a redirection.

## Recommended policy

**0. Freeze and archive the legacy environment before anything else.** Export the full spec, resolve the three `@master` dependencies to explicit commit SHAs, archive all wheels and sdists, image the WSL2 distribution, SHA-256 everything, store off-machine. Treat the flip-classifier pickle as primary research data under the same custody. Nothing else in this policy proceeds until this is done.

**1. Preserve the exact legacy environment unchanged.** (Yours, unchanged.)

**2. Pin the three unpinned git dependencies to explicit commit SHAs in `setup.py`.** This is the single highest-value change available and it is independent of every version question.

**3. Run the first repaired real-data pilot in the legacy environment** to establish the scientific baseline. (Yours, unchanged.)

**4. Immediately follow with three to five within-legacy repeat runs** to measure the pipeline's variability against itself. This produces the denominator for every tolerance in section G. Without it, cross-environment tolerances are arbitrary.

**5. Seed `svd_compressed`, or formally classify PCA as a stochastic stage.** Preferably both. Verify which parameter the bare positional `0` binds in the pinned dask version, and convert it to a keyword argument.

**6. Build a separate modern environment; never upgrade in place.** (Yours, unchanged.)

**7. Take Python 3.8 with all current library pins as the first differential step,** not Python 3.11 + NumPy 1.26.4. It is the only single-variable comparison available and it validates your comparison harness on a case where the answer must be "no difference."

**8. Fix the h5py 3.x string decoding in `_load_h5_to_dict` before any Python ≥ 3.9 scientific run,** and add a real-fixture test for it. This defect is silent, sits on the metadata path, and is currently untested.

**9. Resolve the scikit-learn classifier pickle explicitly before the modern comparison.** Either demonstrate byte-identical `predict_proba` output, or re-train and validate the new classifier as a deliberate scientific change.

**10. Target Python 3.11 + NumPy 1.26.x as the destination,** entered after steps 7 through 9, with NumPy 2.x explicitly out of scope until `np.string_` and `np.asscalar` are removed from production code on their own schedule.

**11. Run identical recordings, configurations, seeds and stagewise comparisons in both environments,** with the full standing control set from section D: single-threaded BLAS, fixed `PYTHONHASHSEED`, fixed dask workers and chunk size, sorted input iteration, SHA-256-verified inputs.

**12. Gate promotion on all six criteria in section G,** evaluated in pipeline order, on at least two recording sets including one with a known prior result, with the non-promotion criterion stated in advance.

**13. Retain the legacy environment permanently as a reference oracle,** and re-run the gate suite against it whenever any dependency in the modern stack changes. An oracle used once is a snapshot; an oracle used continuously is a control.

**14. Record every gate outcome, including failures and abandoned attempts,** in the same evidence-packet form used for the round-2 addendum. The negative results are the part that makes the positive ones credible.

One item I would put on the risk register rather than the work plan: the round-2 validation environments were Windows and the production target is WSL2 Ubuntu. No validation of the repaired candidates has yet run on the operating system where the science will happen. The legacy pilot in step 3 will be the first, which is another reason to do it before anything modern.