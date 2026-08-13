#!/usr/bin/env bash

# Synthetic-only fail-loud regression for the real-pilot provenance gate.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PYTHON_BIN="${PYTHON_BIN:-python3}"
TEMP_BASE="${TMPDIR:-/tmp}"
TEST_ROOT="$(mktemp -d "${TEMP_BASE%/}/moseq-real-pilot-provenance.XXXXXX")"
cleanup() {
    case "${TEST_ROOT}" in
        "${TEMP_BASE%/}"/moseq-real-pilot-provenance.*) rm -rf -- "${TEST_ROOT}" ;;
        *) printf 'Refusing unsafe cleanup path: %s\n' "${TEST_ROOT}" >&2 ;;
    esac
}
trap cleanup EXIT

printf 'synthetic recording bytes\n' >"${TEST_ROOT}/recording.dat"
printf 'synthetic PCA bytes\n' >"${TEST_ROOT}/pca.h5"
printf 'synthetic model bytes\n' >"${TEST_ROOT}/model.p"

RECORDING_SHA="$(sha256sum "${TEST_ROOT}/recording.dat" | awk '{print $1}')"
PCA_SHA="$(sha256sum "${TEST_ROOT}/pca.h5" | awk '{print $1}')"
MODEL_SHA="$(sha256sum "${TEST_ROOT}/model.p" | awk '{print $1}')"
WRONG_RECORDING_SHA="$(printf 'intentional mismatch\n' | sha256sum | awk '{print $1}')"

write_spec() {
    local recording_sha="$1"
    local output="$2"
    "${PYTHON_BIN}" - "${output}" "${recording_sha}" "${PCA_SHA}" "${MODEL_SHA}" "${TEST_ROOT}" <<'PY'
import json
import os
import sys

output, recording_sha, pca_sha, model_sha, root = sys.argv[1:]
record = {
    "schema": "moseq2-real-session-run-spec-v1",
    "session_id": "synthetic-provenance-fixture",
    "recording": {"path": os.path.join(root, "recording.dat"), "sha256": recording_sha},
    "pca_components": {"path": os.path.join(root, "pca.h5"), "sha256": pca_sha},
    "production_model": {
        "path": os.path.join(root, "model.p"),
        "sha256": model_sha,
        "seed": 20260802,
        "kappa": 464159,
    },
}
with open(output, "w") as stream:
    json.dump(record, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY
}

run_gate() {
    local spec="$1"
    local receipt="$2"
    "${PYTHON_BIN}" "${PACKET_ROOT}/helpers/verify_real_pilot_provenance.py" \
        --run-spec "${spec}" \
        --recording "${TEST_ROOT}/recording.dat" \
        --pca-components "${TEST_ROOT}/pca.h5" \
        --production-model "${TEST_ROOT}/model.p" \
        --required-pca-sha256 "${PCA_SHA}" \
        --required-model-sha256 "${MODEL_SHA}" \
        --required-model-seed 20260802 \
        --required-model-kappa 464159 \
        --receipt "${receipt}"
}

SOURCE_BEFORE="$(sha256sum "${TEST_ROOT}/recording.dat" | awk '{print $1}')"
write_spec "${WRONG_RECORDING_SHA}" "${TEST_ROOT}/mismatch.json"
if run_gate "${TEST_ROOT}/mismatch.json" "${TEST_ROOT}/mismatch-receipt.json"; then
    printf 'intentional checksum mismatch passed the provenance gate\n' >&2
    exit 1
fi
[[ ! -e "${TEST_ROOT}/scientific-processing-started" ]]
"${PYTHON_BIN}" - "${TEST_ROOT}/mismatch-receipt.json" "${WRONG_RECORDING_SHA}" "${RECORDING_SHA}" <<'PY'
import json
import sys

with open(sys.argv[1]) as stream:
    receipt = json.load(stream)
assert receipt["status"] == "FAILED_HOLD"
assert receipt["scientific_processing_started"] is False
assert receipt["recording"]["expected_sha256"] == sys.argv[2]
assert receipt["recording"]["observed_sha256"] == sys.argv[3]
assert receipt["recording"]["checks"]["sha256_matches_run_spec"] is False
PY

write_spec "${RECORDING_SHA}" "${TEST_ROOT}/match.json"
run_gate "${TEST_ROOT}/match.json" "${TEST_ROOT}/match-receipt.json"
touch "${TEST_ROOT}/proceeded-past-provenance-gate"
[[ -f "${TEST_ROOT}/proceeded-past-provenance-gate" ]]
"${PYTHON_BIN}" - "${TEST_ROOT}/match-receipt.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as stream:
    receipt = json.load(stream)
assert receipt["status"] == "PASS"
assert receipt["scientific_processing_started"] is False
PY

SOURCE_AFTER="$(sha256sum "${TEST_ROOT}/recording.dat" | awk '{print $1}')"
[[ "${SOURCE_BEFORE}" == "${SOURCE_AFTER}" ]]

printf 'intentional_checksum_mismatch_fail_loud=PASS\n'
printf 'failure_receipt_expected_and_observed=PASS\n'
printf 'matching_hash_proceeds_past_gate=PASS\n'
printf 'source_input_unchanged=PASS\n'
printf 'scientific_processing_executed=false\n'
