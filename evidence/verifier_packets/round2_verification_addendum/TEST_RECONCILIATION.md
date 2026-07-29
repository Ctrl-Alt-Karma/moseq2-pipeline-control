# Extract and Viz Test-Count Reconciliation

## Extract

Collection target:
`tests/unit_tests/test_extract_proc.py`

- collected by the full-file collection: 11;
- selected by the reported focused command: 3 explicitly named nodes;
- passed in the reported focused command: 3;
- deselected by pytest in that command: 0, because explicit node IDs were the
  collection arguments;
- not collected by that focused command: the other 8 file nodes;
- skipped: 0;
- failed in the focused command: 0;
- blocked in the focused command: 0.

The later full-file run collected all 11 and produced 10 passed, 1 failed,
0 skipped. The failure was
`TestExtractProc::test_crop_and_rotate`. It occurred in test setup at
`cv2.getRotationMatrix2D(tuple(center), ...)` before the MoSeq2 function under
test ran, because the current OpenCV build rejected a NumPy integer scalar.

The reported `3 of 11` therefore meant “three explicitly selected repair
regressions passed,” not “the file has only three tests” and not “eleven tests
passed.”

`TEST_OUTCOMES.tsv` lists all 11 node IDs and their focused and full-run
outcomes. No extract node was reported by pytest as deselected or skipped.

## Viz

Collection targets:

- `tests/unit_tests/test_provenance.py`: 43 nodes;
- `tests/unit_tests/test_scalar_utils.py`: 33 nodes;
- total: 76 nodes.

The reported focused command selected all 43 provenance nodes and 18 explicitly
named scalar nodes:

- selected: 61;
- passed: 61;
- deselected by pytest: 0, because explicit file/node arguments were used;
- not collected by that focused command: 15 scalar nodes;
- skipped: 0;
- failed in the focused command: 0.

The later full two-file run collected all 76 and produced 65 passed, 11 failed,
0 skipped.

Of the 15 nodes omitted from the focused 61:

- 4 passed in the full run and were unrelated to the repair focus:
  `TestScalarUtils::test_generate_empty_feature_dict`,
  `TestScalarUtils::test_is_legacy`, `TestScalarUtils::test_nanzscore`, and
  `TestScalarUtils::test_pca_matches_labels`;
- 9 were blocked by absent repository fixture/data files:
  `TestScalarUtils::test_compute_all_pdf_data`,
  `TestScalarUtils::test_compute_mouse_dist_to_center`,
  `TestScalarUtils::test_compute_syllable_position_heatmaps`,
  `TestScalarUtils::test_get_scalar_map`,
  `TestScalarUtils::test_process_scalars`,
  `TestScalarUtils::test_scalar_triggered_average`,
  `TestScalarUtils::test_scalars_to_dataframe`,
  `TestScalarUtils::test_star_valmap`, and
  `TestScalarUtils::test_convert_legacy_scalars`;
- 2 failed under current `cytoolz.get` behavior outside the legacy pinned
  dependency set:
  `TestDeprecatedScalars::test_legacy_conversion_does_not_recreate_it` and
  `TestPinholeProjection::test_legacy_force_conversion_reaches_the_pinhole_path`.

The earlier shorthand “8 absent fixtures” was wrong by one. The exact count is
9. The raw full run is authoritative.

`TEST_OUTCOMES.tsv` lists all 76 node IDs and their focused and full-run
outcomes. No viz node was reported by pytest as deselected or skipped.
