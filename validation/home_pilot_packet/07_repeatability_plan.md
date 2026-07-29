# Bounded Within-Legacy Repeatability Plan

This is a later plan, not an automatic command. No repeated PCA or model fit is
started by this packet.

## Frozen boundary

All repeats stay inside Katya's existing Python 3.7 / NumPy 1.18.3 environment
and use the same locked source, recording bytes, config bytes, classifier
bytes, BLAS/LAPACK implementation, thread settings, Dask configuration, and
input ordering.

Modern environments and cross-environment equivalence are out of scope.

## Proposed bounded check

1. Select one approved representative recording from the read-only inventory.
2. Repeat deterministic extraction and scalar stages three times, requiring
   byte-identical frames, masks, flips, and integer outputs.
3. Run PCA three to five times without changing source. Record component
   hashes, explained variance, subspace angles, Dask chunks, worker count, and
   thread variables.
4. Only after AJ separately approves model fitting, run a small predeclared
   seed set. Record fit configuration, dependency custody, log-likelihood
   traces, state usage, and label agreement. Do not run a large fit.

## Unresolved controls

- `moseq2_pca.pca.util.compute_svd` calls
  `dask.array.linalg.svd_compressed` without an explicit seed. The positional
  `0` and the pinned Dask 2.30.0 signature must be recorded from the actual
  environment. PCA is stochastic until proven otherwise.
- `pyhsmm`, `pybasicbayes`, and `autoregressive` were installed from floating
  Git `master` references. Their exact installed commits must be recovered from
  Katya's environment or marked `UNRESOLVED` with all available evidence.
- A fixed model seed cannot compensate for a different dependency commit,
  BLAS reduction order, classifier file, PCA basis, or input ordering.

Within-environment variability is reported as evidence. It is not a pretext for
modernization work.
