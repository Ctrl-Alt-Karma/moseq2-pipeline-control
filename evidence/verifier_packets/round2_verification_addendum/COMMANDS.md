# Exact Validation Commands

All commands were run in Windows PowerShell on 2026-07-29. `$ROOT` below is
exactly:

```powershell
$ROOT = 'C:\Users\ajmitchell\Documents\Codex\2026-07-29\done-the-control-repository-is-live'
$ROUND2 = "$ROOT\work\testenv\Scripts\python.exe"
$CONTROL = "$ROOT\work\moseq2-pipeline-control"
$EXTRACT = "$ROOT\work\moseq2-extract"
$VIZ = "$ROOT\work\moseq2-viz"
$SHIMS = "$ROOT\work\test_shims"
$RAW = "$ROOT\work\verification_addendum_raw"
$GIT_EXE = 'C:\Users\ajmitchell\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\git\cmd\git.exe'
```

Output redirection used `2>&1 | Tee-Object -FilePath <raw-file>`. The raw file
named beside each command contains the complete captured output.

## Environment capture

Round-2 environment (`00_round2_environment.txt`):

```powershell
& $ROUND2 -c "import sys,platform,numpy,h5py,pytest; print('Python:',sys.version.replace(chr(10),' ')); print('NumPy:',numpy.__version__); print('h5py:',h5py.__version__); print('linked HDF5:',h5py.version.hdf5_version); print('pytest:',pytest.__version__); print('OS:',platform.platform()); print('machine:',platform.machine())"
```

Isolated environment creation and package installation:

```powershell
& $ROUND2 -m venv "$ROOT\work\numpy126env"
& "$ROOT\work\numpy126env\Scripts\python.exe" -m pip install numpy==1.26.4 h5py==3.11.0
```

Isolated environment capture (`08_numpy126_environment.txt`):

```powershell
& "$ROOT\work\numpy126env\Scripts\python.exe" -c "import sys,platform,numpy,h5py; print('Python:',sys.version.replace(chr(10),' ')); print('NumPy:',numpy.__version__); print('h5py:',h5py.__version__); print('linked HDF5:',h5py.version.hdf5_version); print('OS:',platform.platform()); print('machine:',platform.machine())"
```

## Extract collection and execution

Working directory: `$EXTRACT`

Collection (`01_extract_collect.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$EXTRACT"
& $ROUND2 -m pytest --collect-only -q tests/unit_tests/test_extract_proc.py
```

Reported focused command (`02_extract_reported_subset.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$EXTRACT"
& $ROUND2 -m pytest -vv tests/unit_tests/test_extract_proc.py::TestExtractProc::test_convert_integer_pixels_to_fractional_millimetres tests/unit_tests/test_extract_proc.py::TestExtractProc::test_compute_scalars_nonzero_velocity_components tests/unit_tests/test_extract_proc.py::TestExtractProc::test_velocity_3d_px_output_policy
```

Full-file reconciliation (`03_extract_full.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$EXTRACT"
& $ROUND2 -m pytest -vv tests/unit_tests/test_extract_proc.py
```

## Viz collection and execution

Working directory: `$VIZ`

Collection (`04_viz_collect.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$VIZ"
& $ROUND2 -m pytest --collect-only -q tests/unit_tests/test_provenance.py tests/unit_tests/test_scalar_utils.py
```

Reported focused command (`05_viz_reported_subset.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$VIZ"
& $ROUND2 -m pytest -vv tests/unit_tests/test_provenance.py tests/unit_tests/test_scalar_utils.py::TestScalarUtils::test_convert_pxs_to_mm tests/unit_tests/test_scalar_utils.py::TestScalarUtils::test_convert_pxs_to_mm_matches_camera_intrinsics tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_behavioral_statistics_rejects_manual_legacy_dataframe tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_downstream_analysis_works_without_the_key tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_explicit_request_raises_actionable_error tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_get_scalar_map_drops_legacy_key_without_losing_mapping tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_legacy_numeric_column_is_dropped_with_warning tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_legacy_numeric_mapping_stays_a_mapping tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_metadata_columns_follow_include_keys_not_source_dict_order tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_model_parse_errors_are_not_swallowed tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_not_produced_in_new_feature_dict tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_position_plot_rejects_manual_legacy_dataframe tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_public_scalar_selectors_reject_legacy_dataframe_column tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_scalar_embedding_rejects_manual_legacy_dataframe tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_scalar_plot_rejects_manual_legacy_dataframe tests/unit_tests/test_scalar_utils.py::TestDeprecatedScalars::test_valid_scalars_are_not_blocked tests/unit_tests/test_scalar_utils.py::TestPinholeProjection::test_focal_lengths_and_pixel_scale tests/unit_tests/test_scalar_utils.py::TestPinholeProjection::test_image_centre_maps_to_origin
```

Full two-file reconciliation (`06_viz_full.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$VIZ"
& $ROUND2 -m pytest -vv tests/unit_tests/test_provenance.py tests/unit_tests/test_scalar_utils.py
```

## Actual-function provenance chain

Working directory: `$CONTROL`

Round-2 NumPy 2.5.1 run (`07_provenance_chain_round2_numpy251.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$EXTRACT;$VIZ"
& $ROUND2 -m pytest -vv validation/contracts/test_real_provenance_chain.py
```

The first isolated launcher (`09_provenance_chain_numpy126_attempt1_import_blocked.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$EXTRACT;$VIZ"
& "$ROOT\work\numpy126env\Scripts\python.exe" -c "import site,sys; site.addsitedir(r'$ROOT\work\testenv\Lib\site-packages'); import pytest; raise SystemExit(pytest.main(['-vv','validation/contracts/test_real_provenance_chain.py']))"
```

The second isolated launcher
(`10_provenance_chain_numpy126_attempt2_shim_cached.txt`) explicitly imported
the existing shim, but Python had cached its earlier startup import before
shared dependencies were available:

```powershell
$env:PYTHONPATH = "$SHIMS;$EXTRACT;$VIZ"
& "$ROOT\work\numpy126env\Scripts\python.exe" -c "import site,sys; site.addsitedir(r'$ROOT\work\testenv\Lib\site-packages'); import sitecustomize,pytest; raise SystemExit(pytest.main(['-vv','validation/contracts/test_real_provenance_chain.py']))"
```

The successful isolated launcher reloaded that same shim after adding the
shared dependency path (`11_provenance_chain_numpy126.txt`):

```powershell
$env:PYTHONPATH = "$SHIMS;$EXTRACT;$VIZ"
& "$ROOT\work\numpy126env\Scripts\python.exe" -c "import importlib,site,sitecustomize,sys; site.addsitedir(r'$ROOT\work\testenv\Lib\site-packages'); importlib.reload(sitecustomize); import pytest; raise SystemExit(pytest.main(['-vv','validation/contracts/test_real_provenance_chain.py']))"
```

The test source and candidate source were unchanged across the NumPy 2.5.1 and
1.26.4 executions.

## Seven cross-repository contract checks

Working directory: `$CONTROL`

Collection (`12_cross_repo_contract_collect.txt`):

```powershell
$env:GIT_EXE = $GIT_EXE
& $ROUND2 -m pytest --collect-only -q validation/contracts/test_candidate_contract.py
```

Execution (`13_cross_repo_contract.txt`):

```powershell
$env:GIT_EXE = $GIT_EXE
& $ROUND2 -m pytest -vv validation/contracts/test_candidate_contract.py
```
