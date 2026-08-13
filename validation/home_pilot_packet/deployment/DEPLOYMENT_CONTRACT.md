# MoSeq2 Legacy Deployment Contract

Contract ID: `moseq2-legacy-study-2026-07-29-v1`

## Authority

Katya's exact `Ubuntu-22.04` WSL2 distribution on WSL `2.7.11.0`, running
Ubuntu `22.04.5 LTS` as Linux user `ajm` with home `/home/ajm`, is the golden
reference for this study. Its verified environment is Miniforge
`/home/ajm/miniforge3`, Conda environment `moseq2-app`, prefix
`/home/ajm/miniforge3/envs/moseq2-app`, Python `3.7.12`, and NumPy `1.18.3`.
The home computer is the preservation and pilot host; it is not assumed to be
the machine that will run the full analysis.

The environment is portable only by one of these routes:

1. import a SHA-256-verified archive of the golden WSL distribution under a
   new WSL distribution name; or
2. bootstrap a new isolated environment from the complete locked offline
   deployment bundle exported by the golden reference.

Approximate versions, compatible ranges, package names without Conda build
strings, floating Git branches, substituted classifiers, reconstructed
`sitecustomize.py` files, and best-effort dependency matches are not
equivalent to the golden reference.

## Qualification states

- `VERIFIED`: the observed value exactly matches the locked expected value.
- `UNRESOLVED`: the golden record lacks an exact expected value or the
  observation cannot be made. This is a failure state, not a warning.
- `MISMATCH`: an observed value differs from the locked expected value or a
  required object is absent. This is a failure state, not a warning.
- `QUALIFIED`: every preflight check is `VERIFIED`, the current versioned
  known-answer fixture passed through the production code paths, and the
  signed-off qualification report is bound by SHA-256 to the same deployment
  lock, fingerprint, fixture contract, and expected-results manifest.

No machine is `QUALIFIED` merely because installation completed. A machine
with any `UNRESOLVED` or `MISMATCH` result is unqualified.

## Mandatory locked identity

The offline deployment lock must contain exact values for:

- Python and every Conda package version, build string, channel URL, and
  explicit package artifact;
- pip records and every required pip artifact hash;
- the exact commits of `pyhsmm`, `pybasicbayes`, and `autoregressive`;
- the five source commits below;
- the active flip-classifier bytes;
- the active `sitecustomize.py` bytes, or an explicit verified-absent record;
- active study configuration bytes;
- ffmpeg, linked HDF5, BLAS/LAPACK, sklearn, dask, Cython, operating-system,
  architecture, and thread-environment identity;
- the versioned known-answer expected results.

Before locked worktrees or deployment artifacts may be created, Phase 0 must
complete inside the single packet-created validation root. The Phase 0 receipt
is valid only when its internal manifest verifies and the installed source,
sitecustomize, classifier, and bounded configuration evidence is present.
Installed MoSeq source identity is determined from deterministic per-file
SHA-256 records and an aggregate source-tree hash, never from package version
labels. `VERIFIED_ABSENT` is permitted for `sitecustomize.py` only when the
record includes the interpreter, `sys.path`, candidate locations, and the
import-system search method. Classifier or configuration uncertainty remains
`UNRESOLVED` and fails closed.

Locked source:

| Repository | Commit |
|---|---|
| `moseq2-extract` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-viz` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | `e0b85201226d03e15944473a734f71417698c31e` |
| `moseq2-pca` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| `moseq2-model` | `6e542e3f1db125202d42b59f390c922281e64f39` |

## Known-answer gate

Fixture contract `moseq-known-answer-v1` uses newly generated synthetic inputs
only. It must traverse the real candidate extract provenance writer, viz
reader and policy gate, app flip path, extract scalar producer, PCA application
and writer, and model-input loader. It verifies extraction structure,
provenance, flip state and behavior, scalar units and summaries, PCA/model
handoff shapes, session alignment, and hashes for deterministic datasets.

The golden reference establishes the expected-results manifest. Other
machines may only verify against those exact bytes. The fixture never processes
experimental recordings and never starts a model fit.

## Production gate

`deployment/run_pipeline_guarded.sh` is the documented production entry point.
It must refuse analysis unless:

1. current preflight returns only `VERIFIED`;
2. a qualification report says `QUALIFIED`;
3. that report matches the current contract, deployment lock, fingerprint,
   fixture contract, and expected-results hashes; and
4. the requested analysis output directory is new.

The wrapper records the verified fingerprint and qualification receipt inside
the new analysis output before launching the requested pipeline command.
Bypassing the wrapper is outside the supported study procedure.

Modernization remains out of scope.

## Preferred Windows/WSL2 transfer

For a Windows final-analysis computer, the preferred route is a copy imported
from a SHA-256-verified golden WSL archive under a new distribution name. The
archive used for this route must have been captured after the golden freeze,
locked worktrees, complete deployment bundle, and generated
`records/golden_runtime.env` exist at the paths recorded in the lock. An older
preservation backup remains valuable, but it is not by itself a qualified
analysis image if those records are absent.

`import_golden_wsl.ps1` refuses an existing distribution name and install
directory, verifies the archive before import, and never calls unregister.
After import it runs the same preflight and known-answer verification. A failed
qualification leaves the new copy present but unqualified for inspection; it
does not delete or alter another distribution.
