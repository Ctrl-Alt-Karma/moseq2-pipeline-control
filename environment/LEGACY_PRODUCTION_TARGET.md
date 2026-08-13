# Frozen Legacy Production Target

Date frozen: 2026-07-29

Supported environment for this study:

- Windows user: `AJM_LAPTOP\AJM`;
- WSL: version `2.7.11.0`, exact distribution `Ubuntu-22.04`, observed
  `Stopped` during the 2026-07-29 read-only preflight;
- host: existing home WSL2 Ubuntu `22.04.5 LTS` distribution;
- Linux user and home: `ajm`, `/home/ajm`;
- Conda root: `/home/ajm/miniforge3`;
- Conda environment: `moseq2-app`;
- Conda prefix: `/home/ajm/miniforge3/envs/moseq2-app`;
- Python: 3.7.12;
- NumPy: 1.18.3.

The confirmed local non-OneDrive backup root is
`C:\Users\AJM\Documents`; the packet uses
`C:\Users\AJM\Documents\MoSeq2-WSL-Backups`. Available C: space observed
during preflight was `549915922432` bytes. State and capacity are
point-in-time observations and must be rechecked before export.

Locked source:

| Repository | Commit |
|---|---|
| extract | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| viz | `b80192dc20353bf77c36610f315543b57afa908c` |
| app | `e0b85201226d03e15944473a734f71417698c31e` |
| pca | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| model | `6e542e3f1db125202d42b59f390c922281e64f39` |

The locked source is supplied through `PYTHONPATH` from isolated detached
worktrees. It is not installed into or over the Conda environment.

## Validation-root and Phase 0 identity contract

Script 01 creates one fresh explicit validation root below `/home/ajm` and
writes a versioned packet marker, Phase 0 evidence manifest, and Phase 0
receipt. Script 02 and every later home-pilot phase must reuse that exact root.
They validate the required prior state before creating any new child path and
refuse arbitrary roots, unknown state, partial runs, and reruns.

Installed `moseq2-*` source identity is a deterministic aggregate of per-file
SHA-256 records. Version labels are metadata, not identity. Each installed
package is classified as exactly one of `VANILLA_MATCH`,
`FORK_RELEASE_MATCH`, `CANDIDATE_MATCH`, `MULTIPLE_IDENTICAL_MATCHES`,
`NEITHER`, or `UNRESOLVED`.

Active `sitecustomize.py` custody is `PRESENT_AND_HASHED`,
`VERIFIED_ABSENT`, or `UNRESOLVED`. A verified absence records the interpreter,
`sys.path`, candidate locations, and import-system search method. Classifier
custody is `FOUND_AND_HASHED` or `UNRESOLVED`; an unresolved record includes
all bounded search locations. Configuration custody is explicitly bounded: it
hashes discovered and referenced files, records unresolved references, and
does not claim comprehensive custody.

## Approved Phase 0 source comparison states

Architect approval dated 2026-07-31 freezes three distinct code states. Branch
names are provenance only and are not identities after checkout.

- `VANILLA`: exact upstream `dattalab` release HEAD at the verified branch
  point with the fork and candidate;
- `FORK_RELEASE`: exact `Ctrl-Alt-Karma` fork release commit from which the
  candidate was prepared;
- `CANDIDATE`: exact locked candidate commit proposed for qualification.

| Repository | VANILLA | FORK_RELEASE | CANDIDATE |
|---|---|---|---|
| `moseq2-extract` | `39a6f0f88d28fc311c8be96619ee9e53b14d3a96` | `424d643affb685e1cad145e3c7051b814d11265c` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-pca` | `a7bdbe179084c5d366290cd04f4ab26ee8387aa0` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| `moseq2-model` | `c7c1e1f1ff22c8670bcf0d929d4ca3a12d53190d` | `6e542e3f1db125202d42b59f390c922281e64f39` | `6e542e3f1db125202d42b59f390c922281e64f39` |
| `moseq2-viz` | `f571e0ac84cc26cd7f04ea5cf7478657894b02d8` | `68ca6a34055987ff22f8651b4dca2aa254380c87` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | `7be1af1f96d7873ff44d6ea5ae45262881d76f9f` | `36d40e098a5c4629116b7a4e233573218345bd5d` | `e0b85201226d03e15944473a734f71417698c31e` |

## Approved Phase 0 project custody

- project root:
  `/home/ajm/moseq_work/5xfad_exploratory_20`;
- explicit load-bearing configuration:
  `/home/ajm/moseq_work/5xfad_exploratory_20/config.yaml`;
- explicit load-bearing configuration:
  `/home/ajm/moseq_work/5xfad_exploratory_20/moseq2-index.yaml`;
- canonical classifier:
  `/home/ajm/moseq_work/5xfad_exploratory_20/flip/flip_classifier_k2_c57_10to13weeks.pkl`;
- verified byte-identical classifier alias:
  `/home/ajm/moseq_work/historical_smoke_test/flip/flip_classifier_k2_c57_10to13weeks.pkl`.

The historical-smoke config is not an explicit Phase 0 configuration. The PCA
config is not explicitly designated but may be captured by bounded discovery.

Both classifier paths were verified at `11981487` bytes with SHA-256
`4b06e1e56928bb1ac227329d0932d4637cdd541a3af49865ae127b57991c2c00`.
The alias status is `VERIFIED_BYTE_IDENTICAL_ALIAS`.

The current primary config is the Phase 0 golden artifact. Its SHA-256 during
input resolution was
`ef42bf756eef975277d5dc62d0d7719daf75f374a2e58d96a6c3eb39ecd75269`.
Extraction-time configuration status is `UNRESOLVED_HISTORICAL_VERSION`:
the earlier `config.sha256` record named
`2c15965715759bc082964364dd79e864cbb04606b205a92a34eb7ca7265bcbe1`,
and `production_file_hashes.sha256` named
`23f147577ac12e3272659e97c8b4a5b42dead317f8b22ea674d8c5fc6a84e1a1`.
Those conflicting records are preserved as evidence; Phase 0 must not attempt
to reconstruct missing historical bytes.

Modernization, Python migration, NumPy upgrades, and multi-environment
equivalence testing are out of scope and are not planned work in this control
repository.
