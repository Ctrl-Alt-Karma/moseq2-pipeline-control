# Rebuild the extracted flip state-machine module

### 3.0 Prerequisite: dependency install and `flipmod` extraction

```bash
pip install --break-system-packages h5py numpy
```

`flipmod.py` lifts the constants and the three state-machine functions out of `app_head/moseq2_app/flip/widget.py` byte-for-byte, so the app's heavy imports (panel, holoviews, bokeh, moseq2_extract) are not needed. Two steps, exactly as run:

```bash
cd /tmp && python3 - <<'PY'
import re
src = open('/tmp/src/app_head/moseq2_app/flip/widget.py').read()
start = src.index("#: h5 dataset holding the flip-classifier processing record.")
end   = src.index("def _extraction_complete(file_path: Path):")
block = src[start:end]
keep = []
for chunk in re.split(r'\n(?=(?:#: |def |class ))', block):
    if chunk.lstrip().startswith(('#: h5','#: Second','#: Durable','def _sha256','def _app_version','def read_extraction_provenance','def _extraction_policy_snapshot','def read_flip_record','def write_flip_record','def check_flip_state','class FlipProcessingError')):
        keep.append(chunk)
mod = "import json, hashlib, warnings, datetime\nfrom pathlib import Path\n" + "\n".join(keep)
open('/tmp/flipmod.py','w').write(mod)
print("extracted", len(mod), "bytes")
PY
```

```bash
cd /tmp && python3 - <<'PY'
mod = open('/tmp/flipmod.py').read()
mod = mod.replace("import json, hashlib, warnings, datetime",
                  "import json, hashlib, warnings, datetime, h5py")
mod += """

FLIP_RECORD_JOURNAL_PATH = FLIP_RECORD_PATH + '_journal'
LEGACY_FLIP_ATTR = 'flip_classifier_applied'
FLIP_RECORD_UPDATE_ATTR = 'flip_classifier_record_update_in_progress'
"""
open('/tmp/flipmod.py','w').write(mod)
PY
```

The second step is required because the regex split in step one severs the three constants from their leading `#:` comment blocks. Re-appending them is equivalent to the source; verify against `widget.py:20-35` before trusting downstream results. Step one prints `extracted 9814 bytes`; the final file is 9994 bytes.
