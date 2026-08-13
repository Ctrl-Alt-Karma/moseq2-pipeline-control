# Golden-Machine Preflight

Date confirmed: 2026-07-29

Method: independent read-only identity and version inspection under the actual
Windows user context. No backup, environment freeze, bootstrap, scientific
test, or data-processing command was run.

| Check | Verified value |
|---|---|
| Windows user | `AJM_LAPTOP\AJM` |
| WSL distribution | `Ubuntu-22.04` |
| WSL state during inspection | `Stopped` |
| WSL version | `2.7.11.0` |
| Ubuntu | `22.04.5 LTS` |
| Linux user | `ajm` |
| Linux home | `/home/ajm` |
| Miniforge | `/home/ajm/miniforge3` |
| Conda environment | `moseq2-app` |
| Conda prefix | `/home/ajm/miniforge3/envs/moseq2-app` |
| Python | `3.7.12` |
| NumPy | `1.18.3` |
| Confirmed local non-OneDrive backup root | `C:\Users\AJM\Documents` |
| Available C: space observed | `549915922432` bytes |

The state and free-space observations are point-in-time values. The backup
script must independently confirm that `Ubuntu-22.04` is still `Stopped` and
that the explicit destination still has sufficient free space before export.
The approved destination is:

```text
C:\Users\AJM\Documents\MoSeq2-WSL-Backups
```
