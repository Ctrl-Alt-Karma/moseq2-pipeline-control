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

Modernization, Python migration, NumPy upgrades, and multi-environment
equivalence testing are out of scope and are not planned work in this control
repository.
