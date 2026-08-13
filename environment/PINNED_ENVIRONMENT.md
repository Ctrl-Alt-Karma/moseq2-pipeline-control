# Pinned Environment

## Intended legacy test stack

Use these versions where the repository supports them:

| Component | Version |
|---|---:|
| Python | 3.7 |
| NumPy | 1.18.3 |
| SciPy | 1.3.2 |
| pandas | 1.0.5 |
| OpenCV | 4.1.2.30 |
| scikit-image | 0.16.2 |
| h5py | 2.10.0 |
| moseq2-app | 1.3.1 |
| moseq2-extract | 1.2.0 |
| moseq2-pca | 1.2.0 |
| moseq2-model | 1.2.0 |
| moseq2-viz | 1.3.0 |

Pinning a version is not proof that every transitive dependency or external binary is reproducible. Capture the resolved environment for every validation run.

## Execution contexts

### Home analysis machine — WSL/Linux

This is the intended context for later real-recording access and representative operational validation. Real recordings will be attached from this environment through manifests and checksums; raw data remains outside Git. Its exact installed state has not been asserted by this bootstrap and must be captured with `environment-report-template.txt` when used.

### Current work computer — native Windows/Codex

The current work computer is a native Windows/Codex execution context. Do not describe it as WSL. The targeted structural suites were rerun using an existing native Python 3.7 environment. Windows-specific ffmpeg/path behavior, absent legacy optional dependencies, and unsupported Unix multiprocessing modes must be recorded separately from product failures.

## Reproducibility rule

Every result must name:

- operating system and architecture;
- Python executable version;
- exact repository SHAs;
- resolved package versions;
- external binary versions;
- environment variables that affect behavior;
- command and working directory;
- exit code and full failure classification.
