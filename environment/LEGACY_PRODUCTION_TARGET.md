# Frozen Legacy Production Target

Date frozen: 2026-07-29

Supported environment for this study:

- host: existing home WSL2 Ubuntu 22.04 distribution;
- Conda root: `/home/ajm/miniforge3`;
- Conda environment: `moseq2-app`;
- Python: 3.7;
- NumPy: 1.18.3.

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

Modernization, Python migration, NumPy upgrades, and multi-environment
equivalence testing are out of scope and are not planned work in this control
repository.
