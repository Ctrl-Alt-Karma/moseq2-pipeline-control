#!/usr/bin/env bash

# Qualification only. Runs locked source through PYTHONPATH; it does not install
# or edit any package or source checkout.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash 03_run_legacy_candidate_tests.sh --root DIR [--output DIR]

The script runs every suite even if an earlier suite fails, then exits nonzero
if any collect or test command failed. Raw stdout, stderr, commands, exit codes,
JUnit XML, collected nodes, and a per-test status manifest are retained.
EOF
}

ROOT=""
OUTPUT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done
[[ -n "${ROOT}" ]] || die "--root is required"
ROOT="$(require_locked_source_complete "${ROOT}")"
if [[ -z "${OUTPUT}" ]]; then
    OUTPUT="${ROOT}/evidence/tests_$(timestamp_utc)"
fi
new_directory_below_validation_root "${ROOT}" "${OUTPUT}"
mkdir -p "${OUTPUT}/suites" "${OUTPUT}/sitecustomize"

activate_legacy_environment
load_locked_source_environment "${ROOT}/locked_source.env"
require_command pytest

export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=0
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export DASK_NUM_WORKERS=1
export GIT_EXE="${GIT_EXE:-$(command -v git)}"

write_process_environment "${OUTPUT}/process_environment.txt"
python - <<'PY' >"${OUTPUT}/python_runtime.txt"
from __future__ import print_function
import platform
import sys
import h5py
import numpy
print("Python:", sys.version.replace("\n", " "))
print("NumPy:", numpy.__version__)
print("h5py:", h5py.__version__)
print("linked HDF5:", h5py.version.hdf5_version)
print("OS:", platform.platform())
print("machine:", platform.machine())
PY

python - "${OUTPUT}/sitecustomize" <<'PY'
from __future__ import print_function
import hashlib
import json
import os
import shutil
import sys

destination = sys.argv[1]
record = {"status": "NOT_LOADED"}
try:
    import sitecustomize
    source = os.path.abspath(sitecustomize.__file__)
    target = os.path.join(destination, "sitecustomize.py")
    shutil.copy2(source, target)
    digest = hashlib.sha256(open(target, "rb").read()).hexdigest()
    record = {
        "status": "COPIED",
        "source": source,
        "packet_copy": target,
        "sha256": digest,
        "bytes": os.path.getsize(target),
    }
except Exception as error:
    record["error"] = "{}: {}".format(type(error).__name__, error)
with open(os.path.join(destination, "custody.json"), "w") as stream:
    json.dump(record, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY

FAILURES=0
run_suite() {
    local label="$1"
    local cwd="$2"
    shift 2
    local suite_dir="${OUTPUT}/suites/${label}"
    mkdir -p "${suite_dir}"

    {
        printf 'cwd=%q\n' "${cwd}"
        printf 'pytest --collect-only -q -p no:cacheprovider '
        printf '%q ' "$@"
        printf '\n'
    } >"${suite_dir}/collect.command.txt"

    set +e
    (
        cd "${cwd}"
        pytest --collect-only -q -p no:cacheprovider "$@"
    ) >"${suite_dir}/collect.stdout.txt" 2>"${suite_dir}/collect.stderr.txt"
    local collect_code=$?
    set -e
    printf '%s\n' "${collect_code}" >"${suite_dir}/collect.exit_code.txt"

    {
        printf 'cwd=%q\n' "${cwd}"
        printf 'pytest -vv -ra -p no:cacheprovider --junitxml=%q ' \
            "${suite_dir}/junit.xml"
        printf '%q ' "$@"
        printf '\n'
    } >"${suite_dir}/test.command.txt"

    set +e
    (
        cd "${cwd}"
        pytest -vv -ra -p no:cacheprovider \
            --junitxml="${suite_dir}/junit.xml" "$@"
    ) >"${suite_dir}/test.stdout.txt" 2>"${suite_dir}/test.stderr.txt"
    local test_code=$?
    set -e
    printf '%s\n' "${test_code}" >"${suite_dir}/test.exit_code.txt"

    if [[ "${collect_code}" -ne 0 || "${test_code}" -ne 0 ]]; then
        FAILURES=$((FAILURES + 1))
    fi
}

run_suite provenance_chain "${SCRIPT_DIR}" \
    validation/contracts/test_real_provenance_chain.py

run_suite extract_targeted "${MOSEQ2_EXTRACT_REPO}" \
    tests/unit_tests/test_extract_proc.py

run_suite viz_targeted "${MOSEQ2_VIZ_REPO}" \
    tests/unit_tests/test_provenance.py \
    tests/unit_tests/test_scalar_utils.py

run_suite app_targeted "${MOSEQ2_APP_REPO}" \
    tests/controller_tests/test_flip_record.py

run_suite cross_repository_contract "${SCRIPT_DIR}" \
    validation/contracts/test_candidate_contract.py

python "${SCRIPT_DIR}/helpers/summarize_pytest.py" --run-dir "${OUTPUT}"

{
    printf 'run_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'output=%s\n' "${OUTPUT}"
    printf 'suite_commands_with_nonzero_exit=%s\n' "${FAILURES}"
    printf 'environment_modified=false\n'
    printf 'source_modified=false\n'
} >"${OUTPUT}/TEST_RUN_RECEIPT.txt"

printf 'Qualification evidence written to: %s\n' "${OUTPUT}"
if [[ "${FAILURES}" -ne 0 ]]; then
    printf 'One or more suites failed or were blocked. Raw evidence was preserved.\n' >&2
    exit 1
fi
