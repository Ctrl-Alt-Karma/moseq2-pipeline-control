"""Verifier-supplied abrupt-death harness, imported verbatim except child filename.

Prerequisite: build ``flipmod.py`` from the audited app head as documented in
../summaries/OPUS_2026-07-29_EXECUTABLE_EVIDENCE.md.
"""

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
