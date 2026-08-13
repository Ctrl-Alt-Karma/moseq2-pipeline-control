Let me verify the container state is intact before exporting, then do the F-09 tracing work, which needs new investigation.MODE: FABLE / INDEPENDENT VERIFIER

Export follows. Everything below is verbatim from the container, not reconstructed. One prerequisite noted up front: `killtest.py` imports `flipmod`, a derived module containing the app state-machine functions extracted verbatim from the PR head. Its build recipe is in section 3.0 and must run first.

---

## 1. Full contents of `/tmp/killtest.py`

```python
import sys, os, json, h5py, signal, subprocess
sys.path.insert(0,'/tmp')
import flipmod as m

CHILD = '/tmp/child.py'
open(CHILD,'w').write('''
import sys, os, h5py
sys.path.insert(0,"/tmp")
import flipmod as m
path, stage = sys.argv[1], sys.argv[2]
def inject(s):
    if s == stage:
        os.kill(os.getpid(), 9)      # real process death, no clean close
with h5py.File(path, "a") as f:
    m.write_flip_record(f, {"state": "complete", "frames_corrected": 1800},
                        fault_inject=inject)
''')

for stage in ('after_sentinel_flush','after_inactive_slot_clear',
              'after_new_slot_create','after_new_slot_flush','after_sentinel_clear'):
    p = f'/tmp/fx/kill_{stage}.h5'
    with h5py.File(p,'w') as f:
        m.write_flip_record(f, {'state':'in_progress'})
    rc = subprocess.run([sys.executable, CHILD, p, stage]).returncode
    try:
        with h5py.File(p,'r') as f:
            slots = [k.split('/')[-1] for k in (m.FLIP_RECORD_PATH, m.FLIP_RECORD_JOURNAL_PATH) if k in f]
            rec = m.read_flip_record(f)
            print(f'{stage:28} rc={rc:4}  slots={slots}  -> {rec.get("state")}')
    except Exception as e:
        print(f'{stage:28} rc={rc:4}  FILE UNREADABLE: {type(e).__name__}: {str(e)[:70]}')
```

The child it writes, `/tmp/child.py`, verbatim (leading blank line is significant to the hash):

```python

import sys, os, h5py
sys.path.insert(0,"/tmp")
import flipmod as m
path, stage = sys.argv[1], sys.argv[2]
def inject(s):
    if s == stage:
        os.kill(os.getpid(), 9)      # real process death, no clean close
with h5py.File(path, "a") as f:
    m.write_flip_record(f, {"state": "complete", "frames_corrected": 1800},
                        fault_inject=inject)
```

---

## 2. Obtaining all six source trees

No GitHub authentication is required; all three repos are public. The REST API was rate-limited from this egress IP (HTTP 403), so codeload tarballs at explicit SHAs were used instead. This is preferable anyway: it pins bytes to the SHA rather than to a branch head that can move.

```bash
mkdir -p /tmp/src && cd /tmp/src

fetch() {   # $1=repo  $2=sha  $3=label
  curl -sSL -o $3.tar.gz -w "$3: HTTP %{http_code} " \
    https://codeload.github.com/Ctrl-Alt-Karma/$1/tar.gz/$2 \
    && ls -l $3.tar.gz | awk '{print "bytes="$5}'
}

fetch moseq2-extract f028801e9a6b54ffa63e22d9e10179ea7419ccc4 extract_head
fetch moseq2-extract 424d643affb685e1cad145e3c7051b814d11265c extract_base
fetch moseq2-viz     fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e viz_head
fetch moseq2-viz     68ca6a34055987ff22f8651b4dca2aa254380c87 viz_base
fetch moseq2-app     192921f1aff3ea58d3b1f268d71731ed222011d2 app_head
fetch moseq2-app     36d40e098a5c4629116b7a4e233573218345bd5d app_base

for f in *.tar.gz; do d=${f%.tar.gz}; mkdir -p $d && tar xzf $f -C $d --strip-components=1; done
```

Observed:

```
extract_head: HTTP 200 bytes=2915396
extract_base: HTTP 200 bytes=2914020
viz_head: HTTP 200 bytes=4164291
viz_base: HTTP 200 bytes=4150980
app_head: HTTP 200 bytes=45292744
app_base: HTTP 200 bytes=45282772
```

Changed-file enumeration:

```bash
cd /tmp/src
for p in extract viz app; do
  echo "======== $p : base -> head ========"
  diff -rq ${p}_base ${p}_head 2>/dev/null | sed 's|/tmp/src/||'
done
```

```
======== extract : base -> head ========
Files extract_base/moseq2_extract/extract/proc.py and extract_head/moseq2_extract/extract/proc.py differ
Files extract_base/moseq2_extract/util.py and extract_head/moseq2_extract/util.py differ
Files extract_base/tests/unit_tests/test_extract_proc.py and extract_head/tests/unit_tests/test_extract_proc.py differ
======== viz : base -> head ========
Files viz_base/moseq2_viz/scalars/util.py and viz_head/moseq2_viz/scalars/util.py differ
Files viz_base/moseq2_viz/util.py and viz_head/moseq2_viz/util.py differ
Only in viz_head/tests/unit_tests: test_provenance.py
Files viz_base/tests/unit_tests/test_scalar_utils.py and viz_head/tests/unit_tests/test_scalar_utils.py differ
======== app : base -> head ========
Files app_base/moseq2_app/flip/widget.py and app_head/moseq2_app/flip/widget.py differ
Only in app_head/tests/controller_tests: test_flip_record.py
```

---

## 3. Executed reproductions

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

### 3.1 Non-dict flip records (F-05) and durable-record-condemned (F-10)

```bash
mkdir -p /tmp/fx && cd /tmp && python3 - <<'PY'
import sys, json, h5py, os
sys.path.insert(0,'/tmp')
import flipmod as m
os.makedirs('/tmp/fx', exist_ok=True)

def fresh(p):
    with h5py.File(p,'w') as f: pass
    return p

print("--- A: durable complete record + uncleared sentinel ---")
p = fresh('/tmp/fx/a.h5')
with h5py.File(p,'a') as f:
    m.write_flip_record(f, {'state':'in_progress'})
    def inject(stage):
        if stage == 'after_new_slot_flush': raise RuntimeError('kill')
    try: m.write_flip_record(f, {'state':'complete','frames_corrected':1800}, fault_inject=inject)
    except RuntimeError: pass
with h5py.File(p,'r') as f:
    slots = {k: json.loads(f[k][()]) for k in (m.FLIP_RECORD_PATH, m.FLIP_RECORD_JOURNAL_PATH) if k in f}
    print("  slots on disk:", {k.split('/')[-1]: v.get('state') for k,v in slots.items()})
    rec = m.read_flip_record(f)
    print("  read_flip_record ->", rec)
    try:
        m.check_flip_state('sess','p',rec); print("  check_flip_state -> processed/skipped")
    except m.FlipProcessingError as e:
        print("  check_flip_state -> RAISES:", str(e).splitlines()[0][:90])

print("--- B: slot containing valid JSON that is not an object ---")
for payload in ('null', '123', '["a"]', '"str"'):
    p = fresh('/tmp/fx/b.h5')
    with h5py.File(p,'a') as f:
        f.create_dataset(m.FLIP_RECORD_PATH, data=payload)
    with h5py.File(p,'r') as f:
        try: print(f"  {payload!r:8} -> {m.read_flip_record(f)}")
        except Exception as e: print(f"  {payload!r:8} -> {type(e).__name__}: {e}")
PY
```

Observed:

```
--- A: durable complete record + uncleared sentinel ---
  slots on disk: {'flip_classifier': 'in_progress', 'flip_classifier_journal': 'complete'}
  read_flip_record -> {'state': 'failed', 'error': 'flip processing record update was interrupted'}
  check_flip_state -> RAISES: sess (p) has a failed flip-classifier run recorded: flip processing record update was inte
--- B: slot containing valid JSON that is not an object ---
  'null'   -> AttributeError: 'NoneType' object has no attribute 'pop'
  '123'    -> AttributeError: 'int' object has no attribute 'pop'
  '["a"]'  -> {'state': 'failed', 'error': 'processing record is corrupt: metadata/processing/flip_classifier'}
  '"str"'  -> AttributeError: 'str' object has no attribute 'pop'
```

`'["a"]'` is caught only incidentally: `list.pop('_journal_sequence', 0)` raises TypeError, which is in the caught tuple. The other three raise AttributeError, which is not.

### 3.2 In-process exception versus SIGKILL (F-06)

Requires `/tmp/child.py`, so run `killtest.py` (section 3.3) first or extract the child separately.

```bash
cd /tmp && python3 - <<'PY'
import sys, h5py, subprocess, os
sys.path.insert(0,'/tmp'); import flipmod as m
stage='after_new_slot_create'

# (1) exactly what the PR's test does: raise inside, then let the ctx manager close
p='/tmp/fx/inproc.h5'
with h5py.File(p,'w') as f: m.write_flip_record(f,{'state':'in_progress'})
def inject(s):
    if s==stage: raise RuntimeError('fault')
try:
    with h5py.File(p,'a') as f:
        m.write_flip_record(f,{'state':'complete'},fault_inject=inject)
except RuntimeError: pass
with h5py.File(p,'r') as f:
    print('in-process raise + clean close ->', [k.split("/")[-1] for k in (m.FLIP_RECORD_PATH,m.FLIP_RECORD_JOURNAL_PATH) if k in f])

# (2) real death at the same checkpoint
p2='/tmp/fx/killed.h5'
with h5py.File(p2,'w') as f: m.write_flip_record(f,{'state':'in_progress'})
subprocess.run([sys.executable,'/tmp/child.py',p2,stage])
with h5py.File(p2,'r') as f:
    print('SIGKILL at same checkpoint  ->', [k.split("/")[-1] for k in (m.FLIP_RECORD_PATH,m.FLIP_RECORD_JOURNAL_PATH) if k in f])
print('\nfsync in write_flip_record?', 'fsync' in open('/tmp/src/app_head/moseq2_app/flip/widget.py').read())
PY
```

Observed:

```
in-process raise + clean close -> ['flip_classifier', 'flip_classifier_journal']
SIGKILL at same checkpoint  -> ['flip_classifier']

fsync in write_flip_record? False
```

Divergent on-disk state at an identical checkpoint. This is the falsifying evidence for `test_fault_injection_never_fails_open`.

### 3.3 All five journal checkpoints under SIGKILL (F-06 positive result)

```bash
mkdir -p /tmp/fx && python3 /tmp/killtest.py
```

Observed:

```
after_sentinel_flush         rc=  -9  slots=['flip_classifier']  -> failed
after_inactive_slot_clear    rc=  -9  slots=['flip_classifier']  -> failed
after_new_slot_create        rc=  -9  slots=['flip_classifier']  -> failed
after_new_slot_flush         rc=  -9  slots=['flip_classifier', 'flip_classifier_journal']  -> failed
after_sentinel_clear         rc=  -9  slots=['flip_classifier', 'flip_classifier_journal']  -> complete
```

`rc=-9` confirms SIGKILL delivery at every stage. No file became unreadable. Fail-closed held at all five.

### 3.4 Integer conversion truncation (F-14) and focal-length verification

Focal lengths:

```bash
cd /tmp/src && python3 -c "
import numpy as np
res=(512,424); fov=(70.6,60)
fw=res[0]/(2*np.tan(np.deg2rad(fov[0]/2))); fh=res[1]/(2*np.tan(np.deg2rad(fov[1]/2)))
sw=res[0]/(2*np.deg2rad(fov[0]/2)); sh=res[1]/(2*np.deg2rad(fov[1]/2))
print('pinhole fx,fy = %.1f %.1f'%(fw,fh))
print('smallangle fx,fy = %.1f %.1f'%(sw,sh))
print('pinhole vs 368: %.2f%% %.2f%%'%(100*(fw-368)/368,100*(fh-368)/368))
print('smallangle vs 368: %.2f%% %.2f%%'%(100*(sw-368)/368,100*(sh-368)/368))
print('ratio small/pinhole: %.4f %.4f'%(sw/fw,sh/fh))
"
```

```
pinhole fx,fy = 361.6 367.2
smallangle fx,fy = 415.5 404.9
pinhole vs 368: -1.75% -0.22%
smallangle vs 368: 12.91% 10.02%
ratio small/pinhole: 1.1492 1.1027
```

Truncation:

```bash
cd /tmp/src && python3 -c "
import numpy as np
coords=np.asarray([[0,0],[256,212],[512,424]])
res=(512,424);fov=(70.6,60);td=673.1
fw=res[0]/(2*np.tan(np.deg2rad(fov[0]/2)));fh=res[1]/(2*np.tan(np.deg2rad(fov[1]/2)))
xh=coords[:,0]-256; yh=coords[:,1]-212
print('exact x:',td*xh/fw); print('exact y:',td*yh/fh)
nc=np.zeros_like(coords); nc[:,0]=td*xh/fw; nc[:,1]=td*yh/fh
print('dtype',nc.dtype); print('truncated:',nc.tolist())
"
```

```
exact x: [-476.58136532    0.          476.58136532]
exact y: [-388.61446619    0.          388.61446619]
dtype int64
truncated: [[-476, -388], [0, 0], [476, 388]]
```

`np.zeros_like(coords)` is line 566 of `extract_head/moseq2_extract/util.py` and line 74 of `viz_head/moseq2_viz/scalars/util.py`. The head test `test_convert_pxs_to_mm` asserts `assert_array_equal` against `[[-476,-388],[0,0],[476,388]]`, the truncated values.

---

## 4. Environment

```
python         3.12.3 (main, Mar  3 2026, 12:15:18) [GCC 13.3.0]
h5py           3.16.0
hdf5           2.0.0
numpy          2.4.4
platform       Linux-6.18.5-x86_64-with-glibc2.39
machine        x86_64
processor      x86_64
os-release     Ubuntu 24.04.4 LTS (VERSION_ID="24.04")
filesystem     overlayfs (container), no fsync barrier testing performed
```

Flagging a reproduction caveat explicitly: this is **not** the environment the repos target. `viz_head/setup.py` pins `python_requires='>=3.6,<3.8'`, `numpy==1.18.3`, `h5py==2.10.0`, `opencv-python==4.1.2.30`. The state-machine results in 3.1 through 3.3 depend only on h5py/JSON semantics and I expect them to hold on h5py 2.10, but I did not verify that. The 3.4 results are pure numpy arithmetic and are version-independent. Nothing in this export was obtained by running either repo's own test suite; the viz suite could not be run here (Python pin plus `data/` fixtures absent from the tarball).

---

## 5. SHA-256 hashes

Scripts:

```
e32b121299b06dfe6b1d55fec9f03f657d016fd827f7d0764f81120a4543f933  /tmp/killtest.py
959a50ee157a0b9e6598a9238b0e58ec84465335aa45fb326120d329932b05b0  /tmp/child.py
bb29bff760445e63af4da5a4b745954fadbb14e796125055676d3fca52c312e1  /tmp/flipmod.py
```

Source tarballs (these pin the audited bytes and are the ones worth checking):

```
5c96e8e630c453e75189d959579206b2864ddc850b1e461d4ebf39fb0bc6f436  extract_base.tar.gz
8eab256587f01e2d7622d604adf7e4077f575d3be72b53c4ca20a3a46c3af252  extract_head.tar.gz
46015e579846c584e264cf6ea3482d893997dcd04c98cbd629fa0fc6bd8bba3b  viz_base.tar.gz
269d0cb1fb54264d2495e79da54f2b15ced6b6119d284c702a1b2c3990b74656  viz_head.tar.gz
68a64e1401d812a0fa7daf6d992885809ee9d691df167e8a73f2e9b41aa676e6  app_base.tar.gz
4491f3d32be7895c5b84de1fe8494beb49003d201d40b4afe580f655bf823334  app_head.tar.gz
```

Generated h5 fixtures:

```
6002f763b55b6b0873f02729287b68f952538f78224c9d7044c5941c6418ea60  fx/a.h5
47e360f6f2154709e9677b6f040027323292b0258895cc7118f9ff82d054db69  fx/b.h5
a607cbf1a7368689db6e9cfba686de2e78f097affc247bdd44abec180b12fe16  fx/inproc.h5
316a5cfbbbffa641d8b89819969df08b046a4055db4eb85b92a8f5f12d9901d3  fx/kill_after_sentinel_flush.h5
316a5cfbbbffa641d8b89819969df08b046a4055db4eb85b92a8f5f12d9901d3  fx/kill_after_inactive_slot_clear.h5
c29e49c959fcb26229ea5dfd38e0fe710abe6b35518d618e230ab4fa22b7f28d  fx/kill_after_new_slot_create.h5
0ac12897cb7320c27ac6835aefdfe486a1da31cc422c90ea293c7e4ee0e95d8d  fx/kill_after_new_slot_flush.h5
880bdf31b05a2d826fc3a2df120a3a618a464190939268f272ff18e45233a29f  fx/kill_after_sentinel_clear.h5
c29e49c959fcb26229ea5dfd38e0fe710abe6b35518d618e230ab4fa22b7f28d  fx/killed.h5
```

Two collisions are meaningful rather than accidental and are themselves evidence. `kill_after_sentinel_flush` and `kill_after_inactive_slot_clear` hash identically, confirming the inactive-slot delete is a no-op when only one slot exists. `kill_after_new_slot_create` and `killed.h5` hash identically, confirming SIGKILL at that checkpoint is deterministic across independent runs. Do not treat h5 hashes as portable across h5py/HDF5 versions; treat the slot listings and record states as the reproducible assertions.

`tar.gz` hashes from codeload are also not guaranteed stable over time (gzip framing can change server-side). Compare extracted-tree contents if a hash mismatches.

---

## 6. Findings ledger

```json
{
  "audit": {
    "date_utc": "2026-07-29",
    "verifier_model": "claude-opus-5",
    "verdict": "READY FOR ANOTHER CODEX FIX ROUND",
    "repos": {
      "moseq2-extract": {"pr": 6, "base": "424d643affb685e1cad145e3c7051b814d11265c", "head": "f028801e9a6b54ffa63e22d9e10179ea7419ccc4"},
      "moseq2-viz":     {"pr": 5, "base": "68ca6a34055987ff22f8651b4dca2aa254380c87", "head": "fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e"},
      "moseq2-app":     {"pr": 5, "base": "36d40e098a5c4629116b7a4e233573218345bd5d", "head": "192921f1aff3ea58d3b1f268d71731ed222011d2"}
    }
  },
  "findings": [
    {
      "id": "F-01", "severity": "P1", "status": "OPEN",
      "repository": "moseq2-viz", "candidate_sha": "fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["moseq2_viz/viz.py:351", "moseq2_viz/viz.py:393"],
      "summary": "scalar_plot(show_scalars=) and position_plot(centroid_vars=) accept scalar names with no check_scalar_is_usable guard",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && grep -rn 'check_scalar_is_usable\\|drop_deprecated_scalars' viz_head --include=*.py | grep -v tests",
      "observed": "guards appear only at moseq2_viz/scalars/util.py lines 349, 383, 475, 662, 684, 717; zero hits in moseq2_viz/viz.py"
    },
    {
      "id": "F-02", "severity": "P1", "status": "OPEN",
      "repository": "moseq2-viz", "candidate_sha": "fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["tests/unit_tests/test_provenance.py:28", "moseq2_viz/util.py:455", "../moseq2-extract/moseq2_extract/util.py:31"],
      "summary": "test_the_required_key_set_is_what_extract_declares compares viz's tuple against a third hardcoded copy in the test file, never importing EXTRACT_OUTPUT_POLICIES",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && sed -n '/EXTRACT_OUTPUT_POLICIES = {/,/^}/p' extract_head/moseq2_extract/util.py; sed -n '/^SCALAR_POOLING_POLICIES/,/^)/p' viz_head/moseq2_viz/util.py; sed -n '28,36p' viz_head/tests/unit_tests/test_provenance.py",
      "observed": "three independent copies of the same 7 keys; currently identical, no runtime cross-check exists"
    },
    {
      "id": "F-03", "severity": "P1", "status": "OPEN",
      "repository": "moseq2-viz", "candidate_sha": "fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["moseq2_viz/util.py:411-427", "moseq2_viz/util.py:625-631"],
      "summary": "read_pipeline_provenance catches ValueError (superclass of JSONDecodeError) and returns None, conflating CORRUPT with ABSENT; a uniformly corrupt set takes the all-unstamped branch and pools with a warning only",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && sed -n '411,430p' viz_head/moseq2_viz/util.py; grep -n 'def test' viz_head/tests/unit_tests/test_provenance.py | grep -i corrupt",
      "observed": "except (OSError, ValueError, KeyError): return None; grep for a corrupt-record test returns nothing"
    },
    {
      "id": "F-04", "severity": "P1", "status": "OPEN",
      "repository": "moseq2-viz", "candidate_sha": "fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["tests/unit_tests/test_scalar_utils.py:547", "setup.py:28", "Pipfile"],
      "summary": "the only cross-repo numerical agreement test imports moseq2_extract, which is not declared in install_requires, Pipfile [packages], or [dev-packages]",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && grep -n 'moseq2_extract' viz_head/tests/unit_tests/test_scalar_utils.py; grep -n 'moseq2' viz_head/setup.py viz_head/Pipfile",
      "observed": "test_scalar_utils.py:547 imports it; setup.py and Pipfile list moseq2-viz only, never moseq2-extract"
    },
    {
      "id": "F-05", "severity": "P1", "status": "OPEN",
      "repository": "moseq2-app", "candidate_sha": "192921f1aff3ea58d3b1f268d71731ed222011d2",
      "path": ["moseq2_app/flip/widget.py:157-200", "moseq2_app/flip/widget.py:583"],
      "summary": "read_flip_record raises uncaught AttributeError on a slot whose JSON parses to a non-dict; called before the try block, so it aborts the whole multi-session run with no record written",
      "evidence_level": 2,
      "reproduction": "see export section 3.1 part B",
      "observed": "'null' -> AttributeError: 'NoneType' object has no attribute 'pop'; '123' -> AttributeError: 'int'...; '\"str\"' -> AttributeError: 'str'...; '[\"a\"]' -> correctly reported corrupt via TypeError"
    },
    {
      "id": "F-06", "severity": "P1", "status": "OPEN",
      "repository": "moseq2-app", "candidate_sha": "192921f1aff3ea58d3b1f268d71731ed222011d2",
      "path": ["tests/controller_tests/test_flip_record.py:94-129"],
      "summary": "fault injection raises in-process; the enclosing h5py.File __exit__ then closes cleanly and flushes, producing on-disk state that real process death does not produce",
      "evidence_level": 2,
      "reproduction": "see export sections 3.2 and 3.3",
      "observed": "at after_new_slot_create: in-process raise leaves ['flip_classifier','flip_classifier_journal']; SIGKILL leaves ['flip_classifier']. Design itself is sound: SIGKILL at all 5 checkpoints stayed fail-closed with no unreadable file."
    },
    {
      "id": "F-07", "severity": "P2", "status": "OPEN (reclassified, see section 8)",
      "repository": "moseq2-app", "candidate_sha": "192921f1aff3ea58d3b1f268d71731ed222011d2",
      "path": ["moseq2_app/flip/widget.py:203-260"],
      "summary": "write_flip_record calls f.flush() only; no fsync anywhere. 'durable' in the docstring overstates what H5Fflush provides",
      "evidence_level": 1,
      "reproduction": "grep -c fsync /tmp/src/app_head/moseq2_app/flip/widget.py",
      "observed": "0"
    },
    {
      "id": "F-08", "severity": "P2", "status": "OPEN",
      "repository": "cross-repo", "candidate_sha": "f028801e9a6b54ffa63e22d9e10179ea7419ccc4 + fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["extract: moseq2_extract/util.py:524", "viz: moseq2_viz/scalars/util.py:41"],
      "summary": "two independent convert_pxs_to_mm implementations; both correctly fixed, neither consolidated; kept in sync only by a comment and the untestable F-04 test",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && grep -rln 'def convert_pxs_to_mm' extract_head viz_head app_head",
      "observed": "extract_head/moseq2_extract/util.py and viz_head/moseq2_viz/scalars/util.py"
    },
    {
      "id": "F-09", "severity": "P1", "status": "OPEN",
      "repository": "cross-repo", "candidate_sha": "192921f1aff3ea58d3b1f268d71731ed222011d2 + fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["app: moseq2_app/flip/widget.py:20,669", "viz: moseq2_viz/util.py:425,455", "viz: moseq2_viz/viz.py:241-256", "extract: moseq2_extract/extract/extract.py:227"],
      "summary": "apply_flip_classifier mutates scalars/angle by +pi and records it at metadata/processing/flip_classifier, which no viz provenance path reads and no SCALAR_POOLING_POLICIES key represents. See section 7 for full downstream trace, including a second and arguably worse defect: stale metadata/extraction/flips causes a 180-degree crowd-movie render error.",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && grep -rn 'metadata/pipeline\\|metadata/extraction/pipeline\\|metadata/processing' extract_head viz_head app_head --include=*.py | grep -v /tests/",
      "observed": "extract writes metadata/extraction/pipeline; viz reads metadata/pipeline then metadata/extraction/pipeline; app writes metadata/processing/flip_classifier which appears in no reader"
    },
    {
      "id": "F-10", "severity": "P2", "status": "OPEN",
      "repository": "moseq2-app", "candidate_sha": "192921f1aff3ea58d3b1f268d71731ed222011d2",
      "path": ["moseq2_app/flip/widget.py:157-166"],
      "summary": "when the sentinel is set, read_flip_record returns 'failed' without inspecting slots, so a fully durable 'complete' record is discarded and check_flip_state demands re-extraction of a session that finished successfully",
      "evidence_level": 2,
      "reproduction": "see export section 3.1 part A",
      "observed": "slots on disk {'flip_classifier':'in_progress','flip_classifier_journal':'complete'}; read_flip_record -> {'state':'failed','error':'flip processing record update was interrupted'}; check_flip_state raises FlipProcessingError"
    },
    {
      "id": "F-11", "severity": "P2", "status": "OPEN",
      "repository": "moseq2-app", "candidate_sha": "192921f1aff3ea58d3b1f268d71731ed222011d2",
      "path": ["moseq2_app/flip/widget.py:678-745"],
      "summary": "the video_pipe finalization block sits inside the try; any exception in the batch loop skips it, so communicate() is never called and the ffmpeg subprocess is orphaned. video_pipe is also initialized once outside the session loop, so a stale handle can carry over",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && sed -n '565,745p' app_head/moseq2_app/flip/widget.py",
      "observed": "'if video_pipe is not None:' is inside try; 'except BaseException' writes the failed record and re-raises without touching video_pipe"
    },
    {
      "id": "F-12", "severity": "P2", "status": "OPEN",
      "repository": "cross-repo", "candidate_sha": "192921f1aff3ea58d3b1f268d71731ed222011d2 + fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["app: moseq2_app/flip/widget.py:115", "viz: moseq2_viz/util.py:425", "extract: moseq2_extract/util.py:80"],
      "summary": "opposite candidate ordering for the same two provenance paths; viz prefers metadata/pipeline, which extract never writes",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && sed -n '115p' app_head/moseq2_app/flip/widget.py; sed -n '425p' viz_head/moseq2_viz/util.py; sed -n '80p' extract_head/moseq2_extract/util.py",
      "observed": "app: ('metadata/extraction/pipeline','metadata/pipeline'); viz: [h5_path,'metadata/extraction/pipeline'] with h5_path='metadata/pipeline'; extract writer default path='metadata/extraction/pipeline'"
    },
    {
      "id": "F-13", "severity": "P2", "status": "OPEN",
      "repository": "moseq2-viz", "candidate_sha": "fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["tests/unit_tests/test_scalar_utils.py:225-232"],
      "summary": "df_cols metadata ordering changed from SessionName,SubjectName,StartTime to SessionName,StartTime,SubjectName with no code change in the diff that would cause it; looks like an expectation edited to match observed output",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && diff -u viz_base/tests/unit_tests/test_scalar_utils.py viz_head/tests/unit_tests/test_scalar_utils.py | sed -n '/df_cols/,+12p'",
      "observed": "reordering plus a comment attributing it to session yaml order; DataFrame.drop(columns=) preserves remaining column order, so this PR should not have caused it",
      "caveat": "viz suite could not be executed here (python_requires <3.8, data/ fixtures absent); this is diff reasoning, not a failing run"
    },
    {
      "id": "F-14", "severity": "P3", "status": "OPEN",
      "repository": "cross-repo", "candidate_sha": "f028801e9a6b54ffa63e22d9e10179ea7419ccc4 + fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["extract: moseq2_extract/util.py:566", "viz: moseq2_viz/scalars/util.py:74", "viz: tests/unit_tests/test_scalar_utils.py:44-58"],
      "summary": "np.zeros_like(coords) preserves integer dtype and truncates mm output; the revised test now asserts the truncated integers as correct, so it cannot detect a sub-mm regression",
      "evidence_level": 2,
      "reproduction": "see export section 3.4",
      "observed": "exact [-476.581, 388.614]; dtype int64; stored [[-476,-388],[0,0],[476,388]]. Production is unaffected because track_features['centroid'] is float64 (proc.py:435 np.full(...,np.nan))."
    },
    {
      "id": "F-15", "severity": "P3", "status": "OPEN",
      "repository": "moseq2-viz", "candidate_sha": "fc2d3298943275f9c44b95ea0a1a1b0af3ffe45e",
      "path": ["moseq2_viz/util.py:466", "moseq2_viz/util.py:682"],
      "summary": "provenance_from_model and assert_consistent_provenance have no production caller; model provenance is never gated anywhere, which the PR does disclose in the scalars_to_dataframe comment",
      "evidence_level": 1,
      "reproduction": "cd /tmp/src && grep -rn 'provenance_from_model\\|assert_consistent_provenance' viz_head --include=*.py",
      "observed": "definitions plus one docstring cross-reference plus test-only call sites; no production caller"
    }
  ]
}
```

---

## 7. F-09 clarified: downstream semantics of `angle`

The tracing turned up something more serious than the pooling gap I originally reported. Taking the sub-questions in order.

### 7a. Modulo pi or modulo 2*pi?

Both, at different stages. The period changes mid-pipeline, and that transition is the whole point of flip correction.

`extract_head/moseq2_extract/extract/extract.py:174-175`:

```python
    incl = ~np.isnan(features["orientation"])
    features["orientation"][incl] = np.unwrap(features["orientation"][incl] * 2) / 2
```

`np.unwrap(x*2)/2` is unwrapping with period **pi**, not 2*pi. That is correct for a raw ellipse major axis, which is head/tail ambiguous. Verified:

```
raw           : [0.0, 0.1, 3.0, 3.2]
unwrap(x*2)/2 : [ 0.     0.1   -0.142  0.058]
plain unwrap  : [0.  0.1 3.  3.2]
```

Then `extract_head/moseq2_extract/extract/extract.py:214-227`:

```python
    if flip_classifier:
        flips = get_flips(
            cropped_filtered_frames, flip_classifier, flip_classifier_smoothing
        )
        flip_indices = np.where(flips)
        cropped_frames[flip_indices] = np.rot90(...)
        ...
        features["orientation"][flips] += np.pi
```

and `extract/proc.py:592`: `features['angle'] = track_features['orientation']`.

So the flip classifier is what promotes a mod-pi axis orientation into a mod-2*pi directed heading. `scalar_attributes()` documents the result as `'Angle (radians, unwrapped)'`, and grep confirms **no modular normalization of `angle` exists anywhere** in any of the three repos after that point. A +pi offset is therefore a permanent absolute shift, never wrapped away.

The critical structural fact: `moseq2_app.flip.widget.apply_flip_classifier` performs the **same operation a second time**, on data extraction has usually already corrected.

### 7b. Which functions use it

| Consumer | Path | Treatment | Reaches the provenance gate? |
|---|---|---|---|
| `make_crowd_matrix` | `viz_head/moseq2_viz/viz.py:241-310` | absolute, mod 2*pi, fed to `cv2.getRotationMatrix2D` | **No.** Reads `h5['scalars/angle']` directly, bypassing `scalars_to_dataframe` and `get_scalar_map` entirely |
| `process_scalars` | `viz_head/moseq2_viz/scalars/util.py:480-482` | first difference | Yes, via `get_scalar_map` |
| `get_scalar_triggered_average` | `viz_head/moseq2_viz/scalars/util.py:415-417` | first difference | Yes, via `get_scalar_map` |
| `get_distances` combined mode | `viz_head/moseq2_viz/model/dist.py:77` | raw, in `include_scalars` default alongside `velocity_3d_mm` | Depends on caller |
| `scalars_to_dataframe` column | `viz_head/moseq2_viz/scalars/util.py:195` | raw column, available to every df consumer | Yes |
| `convert_legacy_scalars` | `viz_head/moseq2_viz/scalars/util.py:267` | passthrough | n/a |

The two diffing consumers share this exact code:

```python
            if scalar == 'angle':
                use_scalar = np.diff(use_scalar)
                use_scalar = np.insert(use_scalar, 0, 0)
```

### 7c. Does mixing change actual output?

Yes, in three distinct ways.

**(i) The diffing consumers are invariant to a global offset but not to a subset offset.** This matters because `apply_flip_classifier` shifts only classifier-flagged frames, never all of them:

```
diff(raw)         : [0.   0.05 0.05 0.05 0.05 0.05]
diff(global +pi)  : [0.   0.05 0.05 0.05 0.05 0.05]  identical -> True
diff(subset +pi)  : [ 0.     0.05   3.192  0.05  -3.092  0.05 ]  identical -> False
   max |delta| introduced by subset shift: 3.1416 rad
```

A corrected session has smooth angle-diffs; an uncorrected one carries ±pi spikes at every head/tail ambiguity. Pooling them into `process_scalars` or `get_scalar_triggered_average` mixes two different distributions of the same named quantity. Note the sign of the effect: correction makes the diff *smoother*, which is the intent, so this is a real between-session difference and not merely noise.

**(ii) Raw-column consumers see a bimodal `angle` distribution.** Anything reading the `angle` column off `scalars_to_dataframe` (including `dist.py`'s combined-distance default) sees two populations separated by pi with no signal distinguishing them.

**(iii) A 180-degree crowd-movie render error, independent of pooling.** This is the part I want to flag hardest. `viz_head/moseq2_viz/viz.py:246-252`:

```python
            if 'flips' in h5['metadata/extraction']:
                # h5 format as of v0.1.3
                flips = h5['metadata/extraction/flips'][idx_slice]
                angles[np.where(flips == True)] -= np.pi
```

`make_crowd_matrix` **undoes** the extraction-time flip correction using `metadata/extraction/flips`. `apply_flip_classifier` adds its own +pi to `scalars/angle` and **never updates that array** (grep confirms `flips` appears nowhere in `app_head/moseq2_app/flip/widget.py`). The compensation is therefore computed from a stale index set:

```
rendered angle (deg), no app pass : [ 0.     2.865  5.73   8.594 11.459 14.324]
rendered angle (deg), after app   : [  0.    182.865   5.73    8.594 191.459  14.324]
per-frame render delta (deg)      : [  0. 180.   0.   0. 180.   0.]
```

Every frame the app flips renders exactly 180 degrees wrong in the crowd movie. This affects a **single** session run through both passes; it does not require mixing anything. And because `make_crowd_matrix` reads the h5 directly, no provenance gate anywhere in the viz PR can see it or refuse it.

I have not confirmed whether `apply_flip_classifier` is intended to run on already-flip-corrected extractions or only on extractions run without `--flip-classifier`. That intent question determines whether (iii) is a defect in the app PR or a documented precondition that nothing enforces. Either way it needs an answer before a real-data pilot, and it is worth splitting out as its own finding rather than leaving it inside F-09.

**Minimum required change for F-09:** add a `flip_correction` key to `SCALAR_POOLING_POLICIES`, have the app stamp it where viz reads, have `enforce_consistent_provenance` treat mixed flip state as a conflict, and either update `metadata/extraction/flips` in `apply_flip_classifier` or make `make_crowd_matrix` aware of the app's record.

---

## 8. F-07 reclassified

You are right that NEEDS REAL DATA was the wrong status. Nothing about this depends on recordings. It is a process-death and power-loss durability question, answerable with a filesystem and a kill signal. Reclassifying to **P2 / OPEN**.

**What the SIGKILL matrix does establish.** Under abrupt termination of the writing process, with the OS and page cache surviving, the two-slot journal is fail-closed at all five mutation boundaries, and no checkpoint left a file HDF5 could not open. The `write_flip_record` ordering (legacy latch and sentinel first, inactive slot only, sentinel cleared last) is sound. This is a genuine positive result and it should not be lost when F-06's test defect is fixed.

**What it does not establish.** `f.flush()` maps to `H5Fflush`, which hands data to the operating system. It is not `fsync` and does not force a disk write. `grep -c fsync` on `widget.py` returns 0. SIGKILL kills the process, not the kernel, so the page cache still drains to disk afterward. That is exactly why the test passes and exactly why it proves less than the docstring claims.

**The narrowest accurate claim the current implementation can make:**

> Under abnormal termination of the writing process, on a filesystem that persists the page cache after that process dies, a reader will never interpret an interrupted record update as an untouched file. At every mutation boundary either the prior record slot or a set update sentinel remains readable, and the legacy Boolean latch stays true throughout, so neither the current nor the older reader will reprocess the session.

Everything outside those bounds is unverified. Specifically not claimed: durability under power loss, kernel panic, or the container/VM host dying; correctness on network or fuse filesystems where flush and visibility semantics differ; and any atomicity guarantee for HDF5's own metadata during `del f[path]` followed by `create_dataset`, which is the operation most likely to corrupt the file in a way no slot logic can recover from.

**Required change:** replace "durable" with "flushed" at each checkpoint description in the `write_flip_record` docstring and add the power-loss caveat, or add `os.fsync` after each flush and re-run the section 3.3 matrix. If you go the fsync route, the HDF5 metadata-atomicity question in the last sentence above still needs separate validation; fsync makes writes durable but does not make a two-step delete-then-create transactional.

No code was modified. All six trees remain at `/tmp/src`, harness at `/tmp/killtest.py`, extracted state machine at `/tmp/flipmod.py`.