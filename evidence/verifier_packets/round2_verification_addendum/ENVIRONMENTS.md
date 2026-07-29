# Validation Environments

## Round-2 environment

- Python: 3.12.13, MSC v.1944, 64-bit AMD64
- NumPy: 2.5.1
- h5py: 3.16.0
- linked HDF5: 2.0.0
- pytest: 9.1.1
- operating system: Windows 11, version 10.0.26200, AMD64
- interpreter:
  `work/testenv/Scripts/python.exe`

This environment produced raw files `00` through `07` and `12` through `13`.
That includes both collections, the reported focused extract and viz commands,
the full-file extract and viz commands, the NumPy 2.5.1 provenance-chain run,
and the seven cross-repository contract checks.

## Isolated compatibility environment

- Python: 3.12.13, MSC v.1944, 64-bit AMD64
- NumPy: 1.26.4
- h5py: 3.11.0
- linked HDF5: 1.14.2
- pytest: 9.1.1, loaded from the round-2 environment
- operating system: Windows 11, version 10.0.26200, AMD64
- interpreter:
  `work/numpy126env/Scripts/python.exe`

This environment produced raw files `08` through `11`. Candidate dependencies
other than NumPy and h5py were loaded from the round-2 environment. The existing
`work/test_shims/sitecustomize.py` legacy import shim was reused. The first two
launch attempts are retained because the shim was imported before the shared
dependency path was available; the third launcher reloaded the same shim after
adding that path and executed the unchanged test.
