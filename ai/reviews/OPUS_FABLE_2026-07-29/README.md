# MoSeq2 independent-audit evidence packet

Verifier: Claude Opus 5 operating under the project's Fable / independent-verifier role marker  
Audit date: 2026-07-29

## Contents

- `FABLE_AUDIT_EXPORT_2026-07-29.md`: full verifier export
- `findings.json`: machine-readable F-01 through F-15 ledger
- `killtest.py`: abrupt-process-death checkpoint harness
- `child.py`: child process written by the harness
- `BUILD_FLIPMOD_RECIPE.md`: recipe used to extract the app journal functions from the exact audited PR head
- `CODEX_REPAIR_ROUND_2.md`: bounded builder handoff

## Authority and caveats

The scripts and outputs are verifier evidence, not automatically accepted truth.

Codex must reproduce each finding at the exact audited candidate SHA before changing code.

The verifier executed the journal harness under Python 3.12, NumPy 2.4.4, h5py 3.16.0, and HDF5 2.0.0 on Ubuntu 24.04. The target repositories use a Python 3.7-era stack. The process-death results are important evidence but must be rerun on the pinned stack where possible.

The audit establishes process-termination behavior only. It does not establish power-loss, kernel-crash, host-loss, network-filesystem, or HDF5 metadata-transaction guarantees.

Raw HDF5 fixture hashes may vary across HDF5/h5py versions. Prefer semantic assertions about slot presence, sentinel state, file readability, and returned processing state.
