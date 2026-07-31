#!/usr/bin/env bash

# Packages bounded evidence for Fable. Raw recordings are excluded unless an
# explicit raw path is supplied with --include-raw-recording.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash collect_evidence.sh [options]

Options:
  --root DIR                    Required Phase-0-initialized validation root.
  --output DIR                  New verifier-package directory.
  --include-binary-outputs      Include derived HDF5/classifier/Pickle outputs.
  --include-raw-recording FILE  Explicitly include one raw recording file.

By default, raw recordings, video, HDF5, classifier, and Pickle payloads are
excluded. Logs, manifests, environment records, configs, summaries, JUnit XML,
commands, exit codes, and packet source are included and individually hashed.
EOF
}

ROOT=""
OUTPUT=""
INCLUDE_BINARY=false
RAW_RECORDING=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --include-binary-outputs) INCLUDE_BINARY=true; shift ;;
        --include-raw-recording) RAW_RECORDING="${2:?missing raw recording path}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done
[[ -n "${ROOT}" ]] || die "--root is required"
ROOT="$(require_phase0_complete "${ROOT}")"
if [[ -z "${OUTPUT}" ]]; then
    OUTPUT="${ROOT}/verifier_packages/fable_$(timestamp_utc)"
fi
new_directory_below_validation_root "${ROOT}" "${OUTPUT}"

ARGS=(
    --validation-root "${ROOT}"
    --packet-root "${SCRIPT_DIR}"
    --output-dir "${OUTPUT}"
)
if [[ "${INCLUDE_BINARY}" == true ]]; then
    ARGS+=(--include-binary-outputs)
fi
if [[ -n "${RAW_RECORDING}" ]]; then
    [[ -f "${RAW_RECORDING}" ]] || die "raw recording is not a file: ${RAW_RECORDING}"
    ARGS+=(--include-raw-recording "${RAW_RECORDING}")
fi

python "${SCRIPT_DIR}/helpers/collect_evidence.py" "${ARGS[@]}"

printf 'Verifier ZIP: %s\n' "${OUTPUT}/MOSEQ_FABLE_HOME_PILOT_EVIDENCE.zip"
printf 'ZIP receipt: %s\n' "${OUTPUT}/MOSEQ_FABLE_HOME_PILOT_EVIDENCE.zip.sha256.txt"
