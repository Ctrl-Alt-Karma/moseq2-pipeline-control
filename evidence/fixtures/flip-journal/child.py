
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
