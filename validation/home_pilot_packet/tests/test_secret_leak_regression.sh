#!/usr/bin/env bash

# Proves credential-shaped variables do not enter process records or evidence.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../lib/common.sh
source "${PACKET_ROOT}/lib/common.sh"

TEMP_BASE="${TMPDIR:-/tmp}"
TEST_ROOT="$(mktemp -d "${TEMP_BASE%/}/moseq-secret-leak.XXXXXX")"
cleanup() {
    case "${TEST_ROOT}" in
        "${TEMP_BASE%/}"/moseq-secret-leak.*) rm -rf -- "${TEST_ROOT}" ;;
        *) printf 'Refusing unsafe cleanup path: %s\n' "${TEST_ROOT}" >&2 ;;
    esac
}
trap cleanup EXIT

VALIDATION_ROOT="${TEST_ROOT}/validation"
PROCESS_DIR="${VALIDATION_ROOT}/evidence/secret-leak-regression"
OUTPUT_DIR="${TEST_ROOT}/collected-evidence"
mkdir -p "${PROCESS_DIR}" "${OUTPUT_DIR}"

secret_names=(
    "GITHUB_""TOKEN"
    "AWS_""SECRET_ACCESS_KEY"
    "ANTHROPIC_""API_KEY"
    "OPENAI_""API_KEY"
)
secret_values=(
    "dummy-github-""credential-20260729"
    "dummy-aws-""credential-20260729"
    "dummy-anthropic-""credential-20260729"
    "dummy-openai-""credential-20260729"
)

for index in "${!secret_names[@]}"; do
    export "${secret_names[${index}]}=${secret_values[${index}]}"
done
unset DASK_NUM_WORKERS

for record_name in \
    process-environment.txt \
    export-process-environment.txt \
    pipeline-process-environment.txt; do
    write_process_environment "${PROCESS_DIR}/${record_name}"
done

python "${PACKET_ROOT}/helpers/collect_evidence.py" \
    --validation-root "${VALIDATION_ROOT}" \
    --packet-root "${PACKET_ROOT}" \
    --output-dir "${OUTPUT_DIR}"

python - \
    "${PROCESS_DIR}" \
    "${OUTPUT_DIR}/staging" \
    "${OUTPUT_DIR}/MOSEQ_FABLE_HOME_PILOT_EVIDENCE.zip" \
    "${secret_names[@]}" -- "${secret_values[@]}" <<'PY'
from __future__ import print_function

import os
import sys
import zipfile

arguments = sys.argv[1:]
separator = arguments.index("--")
process_root, staging_root, archive_path = arguments[:3]
needles = arguments[3:separator] + arguments[separator + 1 :]
expected_record_names = {
    "captured_utc",
    "pwd",
    "PATH",
    "PYTHONPATH",
    "PYTHONHASHSEED",
    "CONDA_PREFIX",
    "CONDA_DEFAULT_ENV",
    "CONDA_EXE",
    "CONDA_SHLVL",
    "LD_LIBRARY_PATH",
    "OMP_NUM_THREADS",
    "MKL_NUM_THREADS",
    "OPENBLAS_NUM_THREADS",
    "NUMEXPR_NUM_THREADS",
    "DASK_NUM_WORKERS",
    "LANG",
    "LC_ALL",
    "TZ",
}


def reject_leak(payload, location):
    for needle in needles:
        if needle.encode("utf-8") in payload:
            raise SystemExit("credential leak detected in {}".format(location))


for filename in sorted(os.listdir(process_root)):
    path = os.path.join(process_root, filename)
    with open(path, "r") as stream:
        lines = [line.rstrip("\n") for line in stream]
    observed_names = {line.split("=", 1)[0] for line in lines}
    if observed_names != expected_record_names:
        raise SystemExit("unexpected process-environment keys in {}".format(path))
    if "DASK_NUM_WORKERS=<UNSET>" not in lines:
        raise SystemExit("missing allowlisted variable was not recorded as unset")

for root in (process_root, staging_root):
    for current, directories, files in os.walk(root):
        directories.sort()
        files.sort()
        for filename in files:
            path = os.path.join(current, filename)
            with open(path, "rb") as stream:
                reject_leak(stream.read(), path)

with zipfile.ZipFile(archive_path, "r") as archive:
    for member in sorted(archive.infolist(), key=lambda item: item.filename):
        reject_leak(member.filename.encode("utf-8"), member.filename)
        reject_leak(archive.read(member), member.filename)

print("secret_leak_regression=PASS")
print("safe_allowlist_only=true")
print("missing_allowlisted_variable_recorded_unset=true")
print("process_environment_records_scanned=3")
print("collected_evidence_tree_scanned=true")
print("final_evidence_zip_scanned=true")
PY
