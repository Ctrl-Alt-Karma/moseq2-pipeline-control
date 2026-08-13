#!/usr/bin/env bash

# Full-operator synthetic regression for the pre-science provenance boundary.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../lib/common.sh
source "${PACKET_ROOT}/lib/common.sh"

FROZEN_PCA="/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca_scores.h5"
FROZEN_MODEL="/home/ajm/moseq2-validation-20260730/analysis/locked_464159_k200_long_chain_convergence_sentinel_20260812_R1/model/model-k200-kappa464159-seed20260802-iter500.p"
FROZEN_PCA_SHA="26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912"
FROZEN_MODEL_SHA="5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964"
TEST_ROOT="$(mktemp -d /home/ajm/moseq-real-pilot-operator-gate.XXXXXX)"
FIXTURE_ROOT="$(mktemp -d "${PACKET_ROOT}/tests/operator-gate-fixture.XXXXXX")"

cleanup() {
    case "${TEST_ROOT}" in
        /home/ajm/moseq-real-pilot-operator-gate.*) rm -rf -- "${TEST_ROOT}" ;;
        *) printf 'Refusing unsafe cleanup path: %s\n' "${TEST_ROOT}" >&2 ;;
    esac
    case "${FIXTURE_ROOT}" in
        "${PACKET_ROOT}"/tests/operator-gate-fixture.*) rm -rf -- "${FIXTURE_ROOT}" ;;
        *) printf 'Refusing unsafe cleanup path: %s\n' "${FIXTURE_ROOT}" >&2 ;;
    esac
}
trap cleanup EXIT

[[ "${FIXTURE_ROOT}" == /mnt/c/* ]] || {
    printf 'fixture root must resolve under /mnt/c for the production guard\n' >&2
    exit 1
}
[[ "$(sha256sum "${FROZEN_PCA}" | awk '{print $1}')" == "${FROZEN_PCA_SHA}" ]]
[[ "$(sha256sum "${FROZEN_MODEL}" | awk '{print $1}')" == "${FROZEN_MODEL_SHA}" ]]

make_locked_synthetic_root() {
    local root="$1"
    local evidence="${root}/evidence/environment_freeze"
    local phase0_manifest="${root}/${PHASE0_MANIFEST_NAME}"
    local phase0_hash
    mkdir -p "${evidence}" "${root}/worktrees"
    {
        printf 'schema=%s\n' "${VALIDATION_ROOT_SCHEMA}"
        printf 'created_by=01_freeze_legacy_environment.sh\n'
        printf 'created_utc=2026-08-13T00:00:00Z\n'
        printf 'root=%s\n' "${root}"
        printf 'packet_manifest_sha256=%s\n' "$(sha256sum "${PACKET_ROOT}/SHA256SUMS.txt" | awk '{print $1}')"
    } >"${root}/${VALIDATION_ROOT_MARKER_NAME}"
    for name in installed_moseq_source_identity.json active_sitecustomize.json classifier_custody.json configuration_custody.json; do
        printf '{}\n' >"${evidence}/${name}"
    done
    (
        cd "${root}"
        {
            printf '%s\0' "${VALIDATION_ROOT_MARKER_NAME}"
            find evidence -type f -print0
        } | LC_ALL=C sort -z | xargs -0 sha256sum >"${PHASE0_MANIFEST_NAME}"
    )
    phase0_hash="$(sha256sum "${phase0_manifest}" | awk '{print $1}')"
    {
        printf 'schema=%s\n' "${PHASE0_RECEIPT_SCHEMA}"
        printf 'status=COMPLETE\n'
        printf 'root=%s\n' "${root}"
        printf 'output=%s\n' "${evidence}"
        printf 'production_environment=%s\n' "${LEGACY_CONDA_PREFIX}"
        printf 'environment_changed=false\n'
        printf 'packages_installed=false\n'
        printf 'phase0_manifest=%s\n' "${phase0_manifest}"
        printf 'phase0_manifest_sha256=%s\n' "${phase0_hash}"
        printf 'installed_source_identity=%s\n' "${evidence}/installed_moseq_source_identity.json"
        printf 'sitecustomize_evidence=%s\n' "${evidence}/active_sitecustomize.json"
        printf 'classifier_custody=%s\n' "${evidence}/classifier_custody.json"
        printf 'configuration_custody=%s\n' "${evidence}/configuration_custody.json"
    } >"${root}/${PHASE0_RECEIPT_NAME}"
    {
        printf 'schema=%s\n' "${LOCKED_SOURCE_RECEIPT_SCHEMA}"
        printf 'status=COMPLETE\n'
        printf 'created_utc=2026-08-13T00:00:00Z\n'
        printf 'root=%s\n' "${root}"
        printf 'source_mode=PYTHONPATH_ONLY\n'
        printf 'conda_install_performed=false\n'
        printf 'floating_refs_used=false\n'
    } >"${root}/${LOCKED_SOURCE_RECEIPT_NAME}"
    printf 'synthetic\n' >"${root}/locked_worktrees.tsv"
    printf 'export PYTHONPATH=/synthetic/not-loaded-in-preflight-only\n' >"${root}/locked_source.env"
}

write_spec() {
    local expected_recording_sha="$1"
    local output="$2"
    "${LEGACY_CONDA_PREFIX}/bin/python" - "${output}" "${FIXTURE_ROOT}/recording.dat" "${expected_recording_sha}" <<'PY'
import json
import sys

output, recording, recording_sha = sys.argv[1:]
record = {
    "schema": "moseq2-real-session-run-spec-v1",
    "session_id": "synthetic-operator-provenance-fixture",
    "recording": {"path": recording, "sha256": recording_sha},
    "pca_components": {
        "path": "/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca_scores.h5",
        "sha256": "26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912",
    },
    "production_model": {
        "path": "/home/ajm/moseq2-validation-20260730/analysis/locked_464159_k200_long_chain_convergence_sentinel_20260812_R1/model/model-k200-kappa464159-seed20260802-iter500.p",
        "sha256": "5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964",
        "seed": 20260802,
        "kappa": 464159,
    },
}
with open(output, "w") as stream:
    json.dump(record, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY
}

run_operator() {
    local spec="$1"
    local output="$2"
    shift 2
    MOSEQ_PACKET_SYNTHETIC_TEST_MODE=1 bash "${PACKET_ROOT}/06_run_approved_real_pilot.sh" \
        --root "${TEST_ROOT}" \
        --output "${output}" \
        --run-spec "${spec}" \
        --recording "${FIXTURE_ROOT}/recording.dat" \
        --config "${FIXTURE_ROOT}/config.yaml" \
        --classifier "${FIXTURE_ROOT}/classifier.pkl" \
        --pca-components "${FROZEN_PCA}" \
        --production-model "${FROZEN_MODEL}" \
        --confirm RUN_APPROVED_REAL_PILOT "$@"
}

make_locked_synthetic_root "${TEST_ROOT}"
printf 'synthetic non-scientific recording\n' >"${FIXTURE_ROOT}/recording.dat"
printf '{}\n' >"${FIXTURE_ROOT}/config.yaml"
printf 'synthetic classifier\n' >"${FIXTURE_ROOT}/classifier.pkl"
RECORDING_SHA="$(sha256sum "${FIXTURE_ROOT}/recording.dat" | awk '{print $1}')"
WRONG_SHA="$(printf 'intentional mismatch\n' | sha256sum | awk '{print $1}')"
SOURCE_BEFORE="${RECORDING_SHA}"

write_spec "${WRONG_SHA}" "${FIXTURE_ROOT}/mismatch.json"
MISMATCH_OUTPUT="${TEST_ROOT}/real_pilot/mismatch"
if run_operator "${FIXTURE_ROOT}/mismatch.json" "${MISMATCH_OUTPUT}"; then
    printf 'operator accepted intentional checksum mismatch\n' >&2
    exit 1
fi
[[ -f "${MISMATCH_OUTPUT}/REAL_PILOT_FAILURE_RECEIPT.txt" ]]
grep -q '^status=FAILED_HOLD$' "${MISMATCH_OUTPUT}/REAL_PILOT_FAILURE_RECEIPT.txt"
grep -q '^scientific_processing_started=false$' "${MISMATCH_OUTPUT}/REAL_PILOT_FAILURE_RECEIPT.txt"
[[ ! -e "${MISMATCH_OUTPUT}/stages" ]]
[[ ! -e "${MISMATCH_OUTPUT}/summaries" ]]
[[ -z "$(find "${MISMATCH_OUTPUT}" -type f \( -name 'results_*.h5' -o -name 'pca_scores.h5' -o -name 'model-applied-heldout.p' \) -print -quit)" ]]

write_spec "${RECORDING_SHA}" "${FIXTURE_ROOT}/match.json"
MATCH_OUTPUT="${TEST_ROOT}/real_pilot/match"
run_operator "${FIXTURE_ROOT}/match.json" "${MATCH_OUTPUT}" --provenance-preflight-only
grep -q '^status=PASS$' "${MATCH_OUTPUT}/PROVENANCE_PREFLIGHT_ONLY_RECEIPT.txt"
grep -q '^scientific_processing_started=false$' "${MATCH_OUTPUT}/PROVENANCE_PREFLIGHT_ONLY_RECEIPT.txt"
[[ ! -e "${MATCH_OUTPUT}/stages" ]]
[[ "$(sha256sum "${FIXTURE_ROOT}/recording.dat" | awk '{print $1}')" == "${SOURCE_BEFORE}" ]]

printf 'operator_mismatch_exit_nonzero=PASS\n'
printf 'operator_failure_receipt_explicit=PASS\n'
printf 'operator_failed_root_has_no_scientific_artifacts=PASS\n'
printf 'matching_hash_positive_control_passes_gate=PASS\n'
printf 'expected_hash_origin=frozen_run_spec\n'
printf 'source_input_unchanged=PASS\n'
printf 'validation_candidate_processed=false\n'
