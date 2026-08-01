# Phase 0 Input Approval Ledger

Date: 2026-07-31

Scope: durable recording of architect-approved inputs for the home golden-
environment freeze. This record does not assert that Phase 0 ran.

## Code-state definitions

- `VANILLA`: immutable upstream `dattalab` release HEAD at the verified branch
  point with the corresponding fork and candidate.
- `FORK_RELEASE`: immutable `Ctrl-Alt-Karma` release commit used as the candidate
  base.
- `CANDIDATE`: immutable locked candidate commit to qualify.

| Repository | Upstream URL | Fork URL | VANILLA | FORK_RELEASE | CANDIDATE |
|---|---|---|---|---|---|
| `moseq2-extract` | `https://github.com/dattalab/moseq2-extract.git` | `https://github.com/Ctrl-Alt-Karma/moseq2-extract.git` | `39a6f0f88d28fc311c8be96619ee9e53b14d3a96` | `424d643affb685e1cad145e3c7051b814d11265c` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-pca` | `https://github.com/dattalab/moseq2-pca.git` | `https://github.com/Ctrl-Alt-Karma/moseq2-pca.git` | `a7bdbe179084c5d366290cd04f4ab26ee8387aa0` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| `moseq2-model` | `https://github.com/dattalab/moseq2-model.git` | `https://github.com/Ctrl-Alt-Karma/moseq2-model.git` | `c7c1e1f1ff22c8670bcf0d929d4ca3a12d53190d` | `6e542e3f1db125202d42b59f390c922281e64f39` | `6e542e3f1db125202d42b59f390c922281e64f39` |
| `moseq2-viz` | `https://github.com/dattalab/moseq2-viz.git` | `https://github.com/Ctrl-Alt-Karma/moseq2-viz.git` | `f571e0ac84cc26cd7f04ea5cf7478657894b02d8` | `68ca6a34055987ff22f8651b4dca2aa254380c87` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | `https://github.com/dattalab/moseq2-app.git` | `https://github.com/Ctrl-Alt-Karma/moseq2-app.git` | `7be1af1f96d7873ff44d6ea5ae45262881d76f9f` | `36d40e098a5c4629116b7a4e233573218345bd5d` | `e0b85201226d03e15944473a734f71417698c31e` |

## Project, configuration, and classifier custody

- project root:
  `/home/ajm/moseq_work/5xfad_exploratory_20`;
- explicit configuration files:
  `/home/ajm/moseq_work/5xfad_exploratory_20/config.yaml` and
  `/home/ajm/moseq_work/5xfad_exploratory_20/moseq2-index.yaml`;
- canonical classifier:
  `/home/ajm/moseq_work/5xfad_exploratory_20/flip/flip_classifier_k2_c57_10to13weeks.pkl`;
- `VERIFIED_BYTE_IDENTICAL_ALIAS`:
  `/home/ajm/moseq_work/historical_smoke_test/flip/flip_classifier_k2_c57_10to13weeks.pkl`.

The historical-smoke config is not explicit. `pca/pca.yaml` is not explicit
but remains eligible for bounded discovery.

Classifier identity: `11981487` bytes, SHA-256
`4b06e1e56928bb1ac227329d0932d4637cdd541a3af49865ae127b57991c2c00`.

## Extraction-time configuration limitation

Status: `UNRESOLVED_HISTORICAL_VERSION`.

The current primary config is the golden Phase 0 artifact and had SHA-256
`ef42bf756eef975277d5dc62d0d7719daf75f374a2e58d96a6c3eb39ecd75269`
during input resolution. Preserved historical records disagree:

- `config.sha256`:
  `2c15965715759bc082964364dd79e864cbb04606b205a92a34eb7ca7265bcbe1`;
- `production_file_hashes.sha256`:
  `23f147577ac12e3272659e97c8b4a5b42dead317f8b22ea674d8c5fc6a84e1a1`.

No reconstruction of missing extraction-time bytes is authorized or required
before Phase 0.
