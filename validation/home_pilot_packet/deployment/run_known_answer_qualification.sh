#!/usr/bin/env bash

# Versioned synthetic known-answer qualification through real production paths.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../lib/common.sh
source "${PACKET_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage, golden-reference baseline:
  bash deployment/run_known_answer_qualification.sh \
    --mode establish-golden \
    --output /home/ajm/moseq-known-answer-golden-v1 \
    --signoff-name "AJ" \
    --root /home/ajm/exact-Phase-0-validation-root

Usage, candidate-machine qualification:
  bash deployment/run_known_answer_qualification.sh \
    --mode verify \
    --bundle /home/ajm/exact-offline-bundle \
    --runtime-env /home/ajm/moseq2-study-qualified-v1/locked_runtime.env \
    --output /home/ajm/moseq-qualification-host-v1 \
    --signoff-name "operator name" \
    [--conda-executable /home/ajm/miniforge3/bin/conda]

The output directory must be new. The fixture is synthetic and versioned; it
uses real candidate production functions and never processes experimental data
or starts a model fit. Verify mode emits QUALIFIED only when exact preflight
and known-answer comparison both pass.
EOF
}

MODE=""
OUTPUT=""
SIGNOFF_NAME=""
BUNDLE=""
RUNTIME_ENV=""
ROOT=""
CONDA_EXE="/home/ajm/miniforge3/bin/conda"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode) MODE="${2:?missing --mode value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --signoff-name) SIGNOFF_NAME="${2:?missing --signoff-name value}"; shift 2 ;;
        --bundle) BUNDLE="${2:?missing --bundle value}"; shift 2 ;;
        --runtime-env) RUNTIME_ENV="${2:?missing --runtime-env value}"; shift 2 ;;
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --conda-executable) CONDA_EXE="${2:?missing --conda-executable value}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ "${MODE}" == "establish-golden" || "${MODE}" == "verify" ]] || {
    die "--mode must be establish-golden or verify"
}
[[ -n "${OUTPUT}" ]] || die "--output is required"
[[ -n "${SIGNOFF_NAME}" ]] || die "--signoff-name is required"
if [[ "${MODE}" == "establish-golden" ]]; then
    [[ -n "${ROOT}" ]] || die "--root is required in establish-golden mode"
    ROOT="$(require_locked_source_complete "${ROOT}")"
fi
new_directory_only "${OUTPUT}"
mkdir -p "${OUTPUT}/commands" "${OUTPUT}/smoke"

run_record() {
    local label="$1"
    shift
    printf '%q ' "$@" >"${OUTPUT}/commands/${label}.command.txt"
    printf '\n' >>"${OUTPUT}/commands/${label}.command.txt"
    set +e
    "$@" >"${OUTPUT}/commands/${label}.stdout.txt" \
        2>"${OUTPUT}/commands/${label}.stderr.txt"
    local code=$?
    set -e
    printf '%s\n' "${code}" >"${OUTPUT}/commands/${label}.exit_code.txt"
    return "${code}"
}

if [[ "${MODE}" == "establish-golden" ]]; then
    grep -q '^VERSION_ID="22.04"$' /etc/os-release || {
        die "golden known-answer establishment requires Ubuntu 22.04"
    }
    grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease || {
        die "golden known-answer establishment requires WSL2"
    }
    activate_legacy_environment
    load_locked_source_environment "${ROOT}/locked_source.env"
    PYTHON_RUN=(python)
    DEPLOYMENT_LOCK=""
else
    [[ -d "${BUNDLE}" ]] || die "--bundle is required for verify mode"
    [[ -f "${BUNDLE}/deployment-lock.json" ]] || die "deployment lock is missing"
    [[ -f "${RUNTIME_ENV}" ]] || die "--runtime-env is required for verify mode"
    [[ -x "${CONDA_EXE}" ]] || die "Conda executable is missing: ${CONDA_EXE}"
    # shellcheck source=/dev/null
    source "${RUNTIME_ENV}"
    [[ -n "${MOSEQ_CONDA_ENVIRONMENT:-}" ]] || {
        die "runtime environment does not identify the isolated Conda environment"
    }
    PYTHON_RUN=(
        "${CONDA_EXE}" run --no-capture-output
        --name "${MOSEQ_CONDA_ENVIRONMENT}" python
    )
    DEPLOYMENT_LOCK="${BUNDLE}/deployment-lock.json"
fi

write_process_environment "${OUTPUT}/process_environment.txt"
FINAL_CODE=0
RUN_SYNTHETIC=true

if [[ "${MODE}" == "verify" ]]; then
    if ! run_record preflight \
        "${PYTHON_RUN[@]}" "${SCRIPT_DIR}/preflight_environment.py" \
        --lock "${DEPLOYMENT_LOCK}" --output "${OUTPUT}/preflight.json"; then
        REPORT_STATUS="UNQUALIFIED_PREFLIGHT"
        FINAL_CODE=2
        RUN_SYNTHETIC=false
        printf 'Preflight did not verify; machine remains unqualified.\n' >&2
    fi
fi

if [[ "${RUN_SYNTHETIC}" == true ]]; then
    if ! run_record synthetic_production_paths \
        "${PYTHON_RUN[@]}" "${PACKET_DIR}/helpers/synthetic_pipeline.py" \
        --output-dir "${OUTPUT}/smoke"; then
        REPORT_STATUS="UNQUALIFIED_KNOWN_ANSWER_EXECUTION"
        FINAL_CODE=2
        RUN_SYNTHETIC=false
        printf 'Known-answer production-path execution failed.\n' >&2
    fi
fi

if [[ "${RUN_SYNTHETIC}" == true && "${MODE}" == "establish-golden" ]]; then
    if run_record canonical_known_answer \
        "${PYTHON_RUN[@]}" "${SCRIPT_DIR}/known_answer_result.py" \
        --mode establish --smoke-dir "${OUTPUT}/smoke" \
        --output "${OUTPUT}/golden-known-answer.json"; then
        REPORT_STATUS="GOLDEN_BASELINE_ESTABLISHED"
    else
        REPORT_STATUS="UNQUALIFIED_GOLDEN_BASELINE"
        FINAL_CODE=2
    fi
elif [[ "${RUN_SYNTHETIC}" == true ]]; then
    if run_record canonical_known_answer \
        "${PYTHON_RUN[@]}" "${SCRIPT_DIR}/known_answer_result.py" \
        --mode verify --smoke-dir "${OUTPUT}/smoke" \
        --output "${OUTPUT}/observed-known-answer.json" \
        --expected "${BUNDLE}/records/golden-known-answer.json" \
        --preflight "${OUTPUT}/preflight.json" \
        --deployment-lock "${DEPLOYMENT_LOCK}"; then
        REPORT_STATUS="QUALIFIED"
    else
        REPORT_STATUS="UNQUALIFIED_KNOWN_ANSWER_MISMATCH"
        FINAL_CODE=2
        printf 'Known-answer mismatch; machine remains unqualified.\n' >&2
    fi
fi

if [[ "${RUN_SYNTHETIC}" != true && -z "${REPORT_STATUS:-}" ]]; then
    REPORT_STATUS="UNQUALIFIED"
    FINAL_CODE=2
fi

"${PYTHON_RUN[@]}" - \
    "${OUTPUT}" "${MODE}" "${REPORT_STATUS}" "${SIGNOFF_NAME}" \
    "${DEPLOYMENT_LOCK:-UNRESOLVED}" <<'PY'
from __future__ import print_function
import datetime
import hashlib
import json
import os
import sys

root, mode, status, operator, lock_path = sys.argv[1:]
def digest(path):
    value = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()

report = {
    "schema_version": 1,
    "contract_id": "moseq2-legacy-study-2026-07-29-v1",
    "fixture_contract": "moseq-known-answer-v1",
    "status": status,
    "mode": mode,
    "operator_signoff": {
        "name": operator,
        "signed_utc": datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z",
        "attestation": "I reviewed the raw command outputs and exact gate results.",
    },
    "deployment_lock_sha256": digest(lock_path)
    if os.path.isfile(lock_path) else "UNRESOLVED",
}
preflight = os.path.join(root, "preflight.json")
if os.path.isfile(preflight):
    record = json.load(open(preflight, "r"))
    report["preflight_sha256"] = digest(preflight)
    report["fingerprint_sha256"] = record.get("fingerprint_sha256")
    report["preflight_status"] = record.get("status")
known_name = (
    "golden-known-answer.json"
    if mode == "establish-golden"
    else "observed-known-answer.json"
)
known_path = os.path.join(root, known_name)
report["known_answer_sha256"] = (
    digest(known_path) if os.path.isfile(known_path) else "UNRESOLVED"
)
if mode == "verify" and os.path.isfile(known_path):
    known_record = json.load(open(known_path, "r"))
    report["expected_known_answer_sha256"] = known_record.get("expected_sha256")
else:
    report["expected_known_answer_sha256"] = "UNRESOLVED"
with open(os.path.join(root, "qualification-report.json"), "w") as stream:
    json.dump(report, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY

(
    cd "${OUTPUT}"
    find . -type f ! -name SHA256SUMS.txt -print0 |
        LC_ALL=C sort -z |
        xargs -0 sha256sum >SHA256SUMS.txt
)

evidence_zip="${OUTPUT}.zip"
[[ ! -e "${evidence_zip}" ]] || die "refusing to overwrite evidence ZIP"
"${PYTHON_RUN[@]}" - "${OUTPUT}" "${evidence_zip}" <<'PY'
from __future__ import print_function
import os
import sys
import zipfile
root, output = sys.argv[1:]
with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
    for current, unused, files in os.walk(root):
        for name in sorted(files):
            path = os.path.join(current, name)
            archive.write(path, os.path.relpath(path, os.path.dirname(root)))
PY
sha256_and_bytes "${evidence_zip}" "${evidence_zip}.sha256.txt"

printf '%s: %s\n' "${REPORT_STATUS}" "${OUTPUT}/qualification-report.json"
printf 'Evidence ZIP: %s\n' "${evidence_zip}"
exit "${FINAL_CODE}"
