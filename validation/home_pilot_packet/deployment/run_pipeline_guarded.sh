#!/usr/bin/env bash

# Only supported production entry point for a separately qualified machine.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../lib/common.sh
source "${PACKET_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash deployment/run_pipeline_guarded.sh \
    --bundle /home/ajm/exact-offline-bundle \
    --runtime-env /home/ajm/moseq2-study-qualified-v1/locked_runtime.env \
    --qualification-report /home/ajm/moseq-qualification/qualification-report.json \
    --output /home/ajm/new-analysis-output \
    [--conda-executable /home/ajm/miniforge3/bin/conda] \
    -- pipeline-command [arguments ...]

The output must be new. The wrapper reruns exact preflight, validates the
qualification report against the current deployment lock and golden
known-answer manifest, writes the environment fingerprint into the output, and
only then launches the command. The command runs from the new output directory
with MOSEQ_ANALYSIS_OUTPUT and MOSEQ_ENVIRONMENT_FINGERPRINT exported.
EOF
}

BUNDLE=""
RUNTIME_ENV=""
QUALIFICATION_REPORT=""
OUTPUT=""
CONDA_EXE="/home/ajm/miniforge3/bin/conda"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --bundle) BUNDLE="${2:?missing --bundle value}"; shift 2 ;;
        --runtime-env) RUNTIME_ENV="${2:?missing --runtime-env value}"; shift 2 ;;
        --qualification-report) QUALIFICATION_REPORT="${2:?missing --qualification-report value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --conda-executable) CONDA_EXE="${2:?missing --conda-executable value}"; shift 2 ;;
        --) shift; break ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown wrapper argument: $1" ;;
    esac
done

[[ "$#" -gt 0 ]] || die "pipeline command is required after --"
[[ -d "${BUNDLE}" ]] || die "deployment bundle is missing"
[[ -f "${BUNDLE}/deployment-lock.json" ]] || die "deployment lock is missing"
[[ -f "${BUNDLE}/records/golden-known-answer.json" ]] || {
    die "golden known-answer manifest is missing"
}
[[ -f "${RUNTIME_ENV}" ]] || die "locked runtime environment file is missing"
[[ -f "${QUALIFICATION_REPORT}" ]] || die "qualification report is missing"
[[ -x "${CONDA_EXE}" ]] || die "Conda executable is missing"
[[ -n "${OUTPUT}" ]] || die "--output is required"
new_directory_only "${OUTPUT}"

# shellcheck source=/dev/null
source "${RUNTIME_ENV}"
[[ -n "${MOSEQ_CONDA_ENVIRONMENT:-}" ]] || {
    die "runtime environment does not identify the isolated Conda environment"
}
PYTHON_RUN=(
    "${CONDA_EXE}" run --no-capture-output
    --name "${MOSEQ_CONDA_ENVIRONMENT}" python
)

set +e
"${PYTHON_RUN[@]}" "${SCRIPT_DIR}/preflight_environment.py" \
    --lock "${BUNDLE}/deployment-lock.json" \
    --output "${OUTPUT}/environment-fingerprint.json" \
    >"${OUTPUT}/preflight.stdout.txt" 2>"${OUTPUT}/preflight.stderr.txt"
preflight_code=$?
set -e
printf '%s\n' "${preflight_code}" >"${OUTPUT}/preflight.exit_code.txt"
[[ "${preflight_code}" -eq 0 ]] || {
    die "preflight failed; analysis was not launched"
}

"${PYTHON_RUN[@]}" - \
    "${QUALIFICATION_REPORT}" \
    "${BUNDLE}/deployment-lock.json" \
    "${BUNDLE}/records/golden-known-answer.json" \
    "${OUTPUT}/environment-fingerprint.json" \
    "${OUTPUT}/qualification-gate.json" <<'PY'
from __future__ import print_function
import hashlib
import json
import sys

report_path, lock_path, expected_path, fingerprint_path, output = sys.argv[1:]
def load(path):
    with open(path, "r") as stream:
        return json.load(stream)
def digest(path):
    value = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()

report = load(report_path)
fingerprint = load(fingerprint_path)
checks = {
    "report_status": report.get("status") == "QUALIFIED",
    "contract": report.get("contract_id")
        == "moseq2-legacy-study-2026-07-29-v1",
    "fixture_contract": report.get("fixture_contract") == "moseq-known-answer-v1",
    "current_preflight": fingerprint.get("status") == "VERIFIED",
    "deployment_lock": report.get("deployment_lock_sha256") == digest(lock_path),
    "fingerprint": report.get("fingerprint_sha256")
        == fingerprint.get("fingerprint_sha256"),
    "known_answer": report.get("expected_known_answer_sha256")
        == digest(expected_path),
    "operator_signoff": bool(
        report.get("operator_signoff", {}).get("name")
        and report.get("operator_signoff", {}).get("attestation")
    ),
}
status = "QUALIFIED" if all(checks.values()) else "MISMATCH"
record = {
    "status": status,
    "contract_id": "moseq2-legacy-study-2026-07-29-v1",
    "checks": checks,
    "qualification_report_sha256": digest(report_path),
    "deployment_lock_sha256": digest(lock_path),
    "fingerprint_sha256": fingerprint.get("fingerprint_sha256"),
    "expected_known_answer_sha256": digest(expected_path),
}
with open(output, "w") as stream:
    json.dump(record, stream, indent=2, sort_keys=True)
    stream.write("\n")
if status != "QUALIFIED":
    raise SystemExit("qualification report does not match current environment")
PY

cp -p "${QUALIFICATION_REPORT}" "${OUTPUT}/qualification-report.json"
export MOSEQ_ANALYSIS_OUTPUT="${OUTPUT}"
export MOSEQ_ENVIRONMENT_FINGERPRINT="${OUTPUT}/environment-fingerprint.json"
export MOSEQ_QUALIFICATION_GATE="${OUTPUT}/qualification-gate.json"
printf '%q ' "$@" >"${OUTPUT}/pipeline.command.txt"
printf '\n' >>"${OUTPUT}/pipeline.command.txt"
write_process_environment "${OUTPUT}/pipeline-process-environment.txt"

set +e
(
    cd "${OUTPUT}"
    "${CONDA_EXE}" run --no-capture-output \
        --name "${MOSEQ_CONDA_ENVIRONMENT}" "$@"
) >"${OUTPUT}/pipeline.stdout.txt" 2>"${OUTPUT}/pipeline.stderr.txt"
pipeline_code=$?
set -e
printf '%s\n' "${pipeline_code}" >"${OUTPUT}/pipeline.exit_code.txt"

(
    cd "${OUTPUT}"
    find . -type f ! -name ANALYSIS_EVIDENCE_SHA256SUMS.txt -print0 |
        LC_ALL=C sort -z |
        xargs -0 sha256sum >ANALYSIS_EVIDENCE_SHA256SUMS.txt
)
exit "${pipeline_code}"
