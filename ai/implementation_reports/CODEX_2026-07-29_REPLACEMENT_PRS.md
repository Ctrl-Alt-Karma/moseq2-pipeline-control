# Codex Replacement PR Report — 2026-07-29

## Audit-history PRs

| Repository | Old PR | Old head | Old head SHA | Merge base / base SHA | State |
|---|---:|---|---|---|---|
| `moseq2-extract` | #5 | `fix/deprecate-invalid-velocity-3d-px` | `740a3ba1932094c87fa120913828d99e3029a848` | `424d643affb685e1cad145e3c7051b814d11265c` | Closed, unmerged, superseded |
| `moseq2-viz` | #4 | `fix/viz-pinhole-provenance` | `a66b5f30c91c6316dbde467a63e8b230b63ee9a9` | `68ca6a34055987ff22f8651b4dca2aa254380c87` | Closed, unmerged, superseded |
| `moseq2-app` | #4 | `fix/app-processing-provenance` | `2ecec58bb09b5e3c2a0795bafa28454297dff789` | `36d40e098a5c4629116b7a4e233573218345bd5d` | Closed, unmerged, superseded |

The old branches and PRs remain for audit history.

## Replacement draft PRs

### `moseq2-extract` PR #6

- URL: https://github.com/Ctrl-Alt-Karma/moseq2-extract/pull/6
- Base: `release` at `424d643affb685e1cad145e3c7051b814d11265c`
- Head: `agent/repair-velocity-scalars` at `f028801e9a6b54ffa63e22d9e10179ea7419ccc4`
- State: draft, open, unmerged
- Exact changed files retrieved from GitHub:
  - `moseq2_extract/extract/proc.py`
  - `moseq2_extract/util.py`
  - `tests/unit_tests/test_extract_proc.py`

### `moseq2-viz` PR #5

- URL: https://github.com/Ctrl-Alt-Karma/moseq2-viz/pull/5
- Base: `release` at `68ca6a34055987ff22f8651b4dca2aa254380c87`
- Head: `agent/repair-pinhole-provenance` at `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`
- State: draft, open, unmerged
- Exact changed files retrieved from GitHub:
  - `moseq2_viz/scalars/util.py`
  - `moseq2_viz/util.py`
  - `tests/unit_tests/test_provenance.py`
  - `tests/unit_tests/test_scalar_utils.py`

### `moseq2-app` PR #5

- URL: https://github.com/Ctrl-Alt-Karma/moseq2-app/pull/5
- Base: `release` at `36d40e098a5c4629116b7a4e233573218345bd5d`
- Head: `agent/repair-flip-processing-journal` at `192921f1aff3ea58d3b1f268d71731ed222011d2`
- State: draft, open, unmerged
- Exact changed files retrieved from GitHub:
  - `moseq2_app/flip/widget.py`
  - `tests/controller_tests/test_flip_record.py`

## Targeted commands and results

`$PINNED_PYTHON` denotes the existing external Python 3.7 interpreter. Its user-specific absolute path is deliberately not committed. Pytest cache and bytecode generation were disabled; each source checkout remained clean.

### Extract

```powershell
$env:PYTHONDONTWRITEBYTECODE = '1'
& $PINNED_PYTHON -m pytest tests/unit_tests/test_extract_proc.py -q -p no:cacheprovider
git status -sb
```

Result at `f028801e9a6b54ffa63e22d9e10179ea7419ccc4`: **10 passed**; clean tracked and untracked state.

### Viz

```powershell
$env:PYTHONPATH = '..\moseq2-extract'
$env:PYTHONDONTWRITEBYTECODE = '1'
& $PINNED_PYTHON -m pytest tests/unit_tests/test_provenance.py tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars tests/unit_tests/test_scalar_utils.py::TestPinholeProjection -q -p no:cacheprovider
git status -sb
```

Result at `fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e`: **43 passed**; clean tracked and untracked state.

### App

```powershell
$env:PYTHONPATH = '..\moseq2-extract'
$env:PYTHONDONTWRITEBYTECODE = '1'
& $PINNED_PYTHON -m pytest tests/controller_tests/test_flip_record.py -q -p no:cacheprovider
git status -sb
```

Result at `192921f1aff3ea58d3b1f268d71731ed222011d2`: **29 passed**; clean tracked and untracked state.

## Broader-suite failures and classification

The replacement PRs report:

- **Extract:** 39 passed, 23 failed in the full unit suite. Reported causes are absent committed fixture/data files and ffmpeg/native-Windows path behavior. Classification: environmental or repository-fixture blocker pending per-failure proof.
- **Viz:** 64 passed, 45 failed in the broader runnable slice. Reported causes are absent committed data fixtures; Windows `forkserver` and optional `dtaidistance` also block parts of collection. Classification: environmental, optional-dependency, or repository-fixture blocker pending per-failure proof.
- **App:** broader collection is blocked by optional legacy `qgrid` and `dtaidistance` dependencies. Classification: optional-dependency blocker pending verification that no product path under review is hidden by collection failure.

The replacement PR descriptions did not preserve the exact historical broader-suite command strings. This report does not invent them. `ai/OPEN_QUESTIONS.md` requires commands, tracebacks, and base-versus-candidate evidence for every broader-suite failure before final classification.

A fresh exploratory viz run of both modified files, without fixture filtering and before adding the local extract checkout to `PYTHONPATH`, produced **48 passed, 10 failed**. Nine failures referenced absent `data/` fixtures; one cross-package equality test could not import `moseq2_extract`. The narrowed command above supplied the intended local cross-repository dependency and excluded legacy fixture-dependent tests.

## Confirmation

No candidate PR was merged. No candidate or superseded branch was deleted.
