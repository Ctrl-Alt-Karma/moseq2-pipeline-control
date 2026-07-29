# Opus executable evidence export

Date: 2026-07-29  
Audited app SHA: `192921f1aff3ea58d3b1f268d71731ed222011d2`

## Source acquisition

The verifier downloaded codeload tarballs at the six exact base/head SHAs listed in the audit manifest and diffed the extracted trees. Tarball SHA-256 values are recorded in `../manifests/opus-audit-2026-07-29.json`. Codeload gzip framing is not guaranteed stable; extracted-tree identity at the commit SHA is the meaningful check.

## Derived `flipmod.py`

The verifier avoided importing the app's heavy UI dependency graph by extracting the flip-record constants and state-machine functions from the exact app head. The exported recipe selected the block from the flip-record constants through the function before `_extraction_complete`, retained:

- flip record path constants;
- `_sha256` and `_app_version`;
- extraction-provenance readers;
- `read_flip_record`;
- `write_flip_record`;
- `check_flip_state`;
- `FlipProcessingError`.

It then supplied `h5py` and restored three constants separated from their comments by the extraction regex:

```python
FLIP_RECORD_JOURNAL_PATH = FLIP_RECORD_PATH + '_journal'
LEGACY_FLIP_ATTR = 'flip_classifier_applied'
FLIP_RECORD_UPDATE_ATTR = 'flip_classifier_record_update_in_progress'
```

The reported final derived-module hash was:

```text
bb29bff760445e63af4da5a4b745954fadbb14e796125055676d3fca52c312e1  flipmod.py
```

The builder must independently review this derivation before using it as evidence.

## Non-mapping records

Reported execution against the derived exact-head state machine:

```text
'null'   -> AttributeError: 'NoneType' object has no attribute 'pop'
'123'    -> AttributeError: 'int' object has no attribute 'pop'
'["a"]'  -> {'state': 'failed', 'error': 'processing record is corrupt: ...'}
'"str"'  -> AttributeError: 'str' object has no attribute 'pop'
```

The list result is incidental: `list.pop('_journal_sequence', 0)` raises `TypeError`, which the candidate catches.

## In-process exception versus abrupt death

At `after_new_slot_create`:

```text
in-process raise + clean close -> ['flip_classifier', 'flip_classifier_journal']
SIGKILL at same checkpoint     -> ['flip_classifier']
```

The PR test therefore does not reproduce actual process-death disk state.

## Five-checkpoint process-death matrix

```text
after_sentinel_flush         rc=  -9  slots=['flip_classifier']                           -> failed
after_inactive_slot_clear    rc=  -9  slots=['flip_classifier']                           -> failed
after_new_slot_create        rc=  -9  slots=['flip_classifier']                           -> failed
after_new_slot_flush         rc=  -9  slots=['flip_classifier','flip_classifier_journal'] -> failed
after_sentinel_clear         rc=  -9  slots=['flip_classifier','flip_classifier_journal'] -> complete
```

No generated HDF5 file became unreadable. This establishes fail-closed behavior under abrupt process death on the reported Linux/overlayfs environment. It does not establish power-loss durability.

## Sentinel with valid complete slot

Reported state after an interruption at `after_new_slot_flush`:

```text
slots: flip_classifier=in_progress, flip_classifier_journal=complete
read_flip_record -> failed: flip processing record update was interrupted
check_flip_state -> raises FlipProcessingError
```

The repair specification requires conservative behavior but accurate diagnostics. It does not authorize automatic recovery from the complete slot.

## Pixel-to-mm arithmetic

Focal-length reproduction:

```text
pinhole fx,fy = 361.6 367.2
smallangle fx,fy = 415.5 404.9
pinhole vs 368: -1.75% -0.22%
smallangle vs 368: 12.91% 10.02%
```

Integer-coordinate reproduction:

```text
exact x: [-476.58136532, 0, 476.58136532]
exact y: [-388.61446619, 0, 388.61446619]
dtype: int64
stored: [[-476, -388], [0, 0], [476, 388]]
```

## Environment and limits

```text
python     3.12.3
h5py       3.16.0
HDF5       2.0.0
numpy      2.4.4
platform   Linux-6.18.5-x86_64-with-glibc2.39
filesystem overlayfs
```

This is not the repositories' pinned Python 3.7 environment. The verifier did not run the repositories' own suites. Viz's fixture-dependent suite was unavailable in the downloaded tree. Generated HDF5 fixture bytes were not attached; their reported hashes are preserved in the manifest.
