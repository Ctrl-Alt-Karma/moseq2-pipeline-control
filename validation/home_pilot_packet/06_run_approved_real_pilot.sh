#!/usr/bin/env bash

# The only real-data processing script in this packet. It refuses to run unless
# all scientific inputs and the explicit confirmation token are supplied.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

CONFIRM_TOKEN="RUN_APPROVED_REAL_PILOT"
FROZEN_PCA_SHA256="26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912"
FROZEN_MODEL_SHA256="5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964"
FROZEN_MODEL_SEED=20260802
FROZEN_MODEL_KAPPA=464159

usage() {
    cat <<EOF
Usage:
  bash 06_run_approved_real_pilot.sh \\
    --run-spec /mnt/c/.../REAL_SESSION_RUN_SPEC.json \\
    --recording /mnt/c/.../depth.dat \\
    --config /mnt/c/.../config.yaml \\
    --classifier /mnt/c/.../flip-classifier.pkl \\
    --pca-components /mnt/c/.../pca.h5 \\
    --production-model /home/ajm/.../model-k200-kappa464159-seed20260802-iter500.p \\
    --confirm ${CONFIRM_TOKEN} \\
    --root DIR [--pilot-frames 3000] [--output DIR]

All scientific input files are read-only references. The run specification
binds the expected recording, PCA, and frozen production-model SHA-256 values.
That provenance gate runs before extraction, PCA, or model application.
Config, classifier, and PCA components are copied into a new validation output
directory before use. The raw recording and model are never overwritten or
copied by default. The frozen model is applied held-out; fitting never starts.
EOF
}

ROOT=""
OUTPUT=""
RUN_SPEC=""
RECORDING=""
CONFIG=""
CLASSIFIER=""
PCA_COMPONENTS=""
PRODUCTION_MODEL=""
CONFIRM=""
PILOT_FRAMES=3000
PROVENANCE_PREFLIGHT_ONLY=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --run-spec) RUN_SPEC="${2:?missing --run-spec value}"; shift 2 ;;
        --recording) RECORDING="${2:?missing --recording value}"; shift 2 ;;
        --config) CONFIG="${2:?missing --config value}"; shift 2 ;;
        --classifier) CLASSIFIER="${2:?missing --classifier value}"; shift 2 ;;
        --pca-components) PCA_COMPONENTS="${2:?missing --pca-components value}"; shift 2 ;;
        --production-model) PRODUCTION_MODEL="${2:?missing --production-model value}"; shift 2 ;;
        --confirm) CONFIRM="${2:?missing --confirm value}"; shift 2 ;;
        --pilot-frames) PILOT_FRAMES="${2:?missing --pilot-frames value}"; shift 2 ;;
        --provenance-preflight-only) PROVENANCE_PREFLIGHT_ONLY=true; shift ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${ROOT}" ]] || die "--root is required"
ROOT="$(require_locked_source_complete "${ROOT}")"
[[ -n "${RUN_SPEC}" ]] || die "--run-spec is required"
[[ -n "${RECORDING}" ]] || die "--recording is required"
[[ -n "${PRODUCTION_MODEL}" ]] || die "--production-model is required"
[[ "${CONFIRM}" == "${CONFIRM_TOKEN}" ]] || {
    die "explicit --confirm ${CONFIRM_TOKEN} is required"
}
[[ -f "${RUN_SPEC}" ]] || die "run spec is not a regular file: ${RUN_SPEC}"
[[ -f "${RECORDING}" ]] || die "recording is not a regular file: ${RECORDING}"
[[ -f "${CONFIG}" ]] || die "config is not a regular file: ${CONFIG}"
[[ -f "${CLASSIFIER}" ]] || die "classifier is not a regular file: ${CLASSIFIER}"
[[ -f "${PCA_COMPONENTS}" ]] || die "PCA components are not a regular file: ${PCA_COMPONENTS}"
[[ -f "${PRODUCTION_MODEL}" ]] || die "production model is not a regular file: ${PRODUCTION_MODEL}"
[[ "${PILOT_FRAMES}" =~ ^[0-9]+$ ]] || die "--pilot-frames must be an integer"
[[ "${PILOT_FRAMES}" -ge 1 && "${PILOT_FRAMES}" -le 10000 ]] || {
    die "--pilot-frames must be between 1 and 10000"
}

RECORDING="$(cd "$(dirname "${RECORDING}")" && pwd)/$(basename "${RECORDING}")"
case "${RECORDING}" in
    /mnt/c/*) ;;
    *) die "approved real recording must be a /mnt/c read-only reference" ;;
esac

if [[ -z "${OUTPUT}" ]]; then
    OUTPUT="${ROOT}/real_pilot/pilot_$(timestamp_utc)"
fi
new_directory_below_validation_root "${ROOT}" "${OUTPUT}"
mkdir -p "${OUTPUT}/inputs" "${OUTPUT}/logs"

# This is the fail-loud scientific-input gate. Only the receipt/output shell
# exists when it runs; no extraction, PCA, model application, or normal result
# directory has been started.
PROVENANCE_PYTHON="${LEGACY_CONDA_PREFIX}/bin/python"
[[ -x "${PROVENANCE_PYTHON}" ]] || die "provenance Python is unavailable: ${PROVENANCE_PYTHON}"
PROVENANCE_RECEIPT="${OUTPUT}/inputs/provenance_preflight.json"
set +e
"${PROVENANCE_PYTHON}" "${SCRIPT_DIR}/helpers/verify_real_pilot_provenance.py" \
    --run-spec "${RUN_SPEC}" \
    --recording "${RECORDING}" \
    --pca-components "${PCA_COMPONENTS}" \
    --production-model "${PRODUCTION_MODEL}" \
    --required-pca-sha256 "${FROZEN_PCA_SHA256}" \
    --required-model-sha256 "${FROZEN_MODEL_SHA256}" \
    --required-model-seed "${FROZEN_MODEL_SEED}" \
    --required-model-kappa "${FROZEN_MODEL_KAPPA}" \
    --receipt "${PROVENANCE_RECEIPT}" \
    >"${OUTPUT}/logs/00_provenance_preflight.stdout.txt" \
    2>"${OUTPUT}/logs/00_provenance_preflight.stderr.txt"
PROVENANCE_EXIT=$?
set -e
printf '%s\n' "${PROVENANCE_EXIT}" >"${OUTPUT}/logs/00_provenance_preflight.exit_code.txt"
if [[ "${PROVENANCE_EXIT}" -ne 0 ]]; then
    {
        printf 'status=FAILED_HOLD\n'
        printf 'reason=INPUT_PROVENANCE_IDENTITY_MISMATCH_OR_INVALID_SPEC\n'
        printf 'provenance_receipt=%s\n' "${PROVENANCE_RECEIPT}"
        printf 'scientific_processing_started=false\n'
        printf 'source_input_modified=false\n'
    } >"${OUTPUT}/REAL_PILOT_FAILURE_RECEIPT.txt"
    die "input provenance preflight failed with exit code ${PROVENANCE_EXIT}; scientific processing was not started"
fi

MODEL_SHA_BEFORE="$(sha256sum "${PRODUCTION_MODEL}" | awk '{print $1}')"
[[ "${MODEL_SHA_BEFORE}" == "${FROZEN_MODEL_SHA256}" ]] || {
    die "production model changed after provenance preflight"
}

if [[ "${PROVENANCE_PREFLIGHT_ONLY}" == true ]]; then
    [[ "${MOSEQ_PACKET_SYNTHETIC_TEST_MODE:-0}" == 1 ]] || {
        die "--provenance-preflight-only is restricted to MOSEQ_PACKET_SYNTHETIC_TEST_MODE=1"
    }
    {
        printf 'status=PASS\n'
        printf 'scope=PROVENANCE_GATE_ONLY_SYNTHETIC_TEST\n'
        printf 'scientific_processing_started=false\n'
        printf 'production_model_sha256=%s\n' "${MODEL_SHA_BEFORE}"
    } >"${OUTPUT}/PROVENANCE_PREFLIGHT_ONLY_RECEIPT.txt"
    printf 'Synthetic provenance preflight passed; scientific processing was not started.\n'
    exit 0
fi

mkdir -p \
    "${OUTPUT}/stages/01_roi" \
    "${OUTPUT}/stages/02_extract" \
    "${OUTPUT}/stages/03_pca" \
    "${OUTPUT}/stages/04_model" \
    "${OUTPUT}/summaries"

activate_legacy_environment
load_locked_source_environment "${ROOT}/locked_source.env"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=0
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export DASK_NUM_WORKERS=1

RUN_SPEC_COPY="${OUTPUT}/inputs/REAL_SESSION_RUN_SPEC.json"
CONFIG_ORIGINAL="${OUTPUT}/inputs/config.original.yaml"
CONFIG_COPY="${OUTPUT}/inputs/config.working.yaml"
CLASSIFIER_COPY="${OUTPUT}/inputs/flip_classifier$(basename "${CLASSIFIER}" | sed 's/^[^.]*//')"
PCA_COPY="${OUTPUT}/inputs/pca_components.h5"
cp --preserve=timestamps "${RUN_SPEC}" "${RUN_SPEC_COPY}"
cp --preserve=timestamps "${CONFIG}" "${CONFIG_ORIGINAL}"
cp --preserve=timestamps "${CONFIG}" "${CONFIG_COPY}"
cp --preserve=timestamps "${CLASSIFIER}" "${CLASSIFIER_COPY}"
cp --preserve=timestamps "${PCA_COMPONENTS}" "${PCA_COPY}"
chmod a-w "${RUN_SPEC_COPY}" "${CONFIG_ORIGINAL}" "${CLASSIFIER_COPY}" "${PCA_COPY}"

{
    printf 'input_type\tpath\tsha256\tbytes\n'
    printf 'recording\t%s\t%s\t%s\n' \
        "${RECORDING}" "$(sha256sum "${RECORDING}" | awk '{print $1}')" \
        "$(wc -c <"${RECORDING}")"
    for entry in \
        "run_spec:${RUN_SPEC_COPY}" \
        "config_original:${CONFIG_ORIGINAL}" \
        "config_working:${CONFIG_COPY}" \
        "classifier:${CLASSIFIER_COPY}" \
        "pca_components:${PCA_COPY}"; do
        label="${entry%%:*}"
        path="${entry#*:}"
        printf '%s\t%s\t%s\t%s\n' \
            "${label}" "${path}" \
            "$(sha256sum "${path}" | awk '{print $1}')" \
            "$(wc -c <"${path}")"
    done
    printf 'production_model\t%s\t%s\t%s\n' \
        "${PRODUCTION_MODEL}" "$(sha256sum "${PRODUCTION_MODEL}" | awk '{print $1}')" \
        "$(wc -c <"${PRODUCTION_MODEL}")"
} >"${OUTPUT}/inputs/input_custody.tsv"
printf '%s\n' "${RECORDING}" >"${OUTPUT}/inputs/recording_reference.txt"
write_process_environment "${OUTPUT}/process_environment.txt"

run_stage() {
    local stage="$1"
    shift
    printf '%q ' "$@" >"${OUTPUT}/logs/${stage}.command.txt"
    printf '\n' >>"${OUTPUT}/logs/${stage}.command.txt"
    set +e
    "$@" >"${OUTPUT}/logs/${stage}.stdout.txt" \
        2>"${OUTPUT}/logs/${stage}.stderr.txt"
    local code=$?
    set -e
    printf '%s\n' "${code}" >"${OUTPUT}/logs/${stage}.exit_code.txt"
    if [[ "${code}" -ne 0 ]]; then
        die "stage ${stage} failed with exit code ${code}; no later stage was started"
    fi
}

run_stage 01_find_roi \
    moseq2-extract find-roi "${RECORDING}" \
    --config-file "${CONFIG_COPY}" \
    --output-dir "${OUTPUT}/stages/01_roi"

run_stage 02_extract \
    moseq2-extract extract "${RECORDING}" \
    --config-file "${CONFIG_COPY}" \
    --output-dir "${OUTPUT}/stages/02_extract" \
    --cluster-type local \
    --num-frames "${PILOT_FRAMES}" \
    --compute-raw-scalars \
    --flip-classifier "${CLASSIFIER_COPY}"

mapfile -t EXTRACTION_H5S < <(
    find "${OUTPUT}/stages/02_extract" -maxdepth 5 -type f \
        -name 'results_*.h5' | LC_ALL=C sort
)
[[ "${#EXTRACTION_H5S[@]}" -eq 1 ]] || {
    die "expected one extraction HDF5, found ${#EXTRACTION_H5S[@]}"
}
EXTRACTION_H5="${EXTRACTION_H5S[0]}"

run_stage 03_apply_pca \
    moseq2-pca apply-pca \
    --input-dir "${OUTPUT}/stages/02_extract" \
    --output-dir "${OUTPUT}/stages/03_pca" \
    --output-file pca_scores \
    --pca-file "${PCA_COPY}" \
    --cluster-type nodask \
    --config-file "${CONFIG_COPY}" \
    --overwrite-pca-apply True

PCA_SCORES="${OUTPUT}/stages/03_pca/pca_scores.h5"
[[ -f "${PCA_SCORES}" ]] || die "PCA score output was not created: ${PCA_SCORES}"

APPLIED_MODEL="${OUTPUT}/stages/04_model/model-applied-heldout.p"
run_stage 04_apply_frozen_model \
    moseq2-model apply-model \
    "${PRODUCTION_MODEL}" \
    "${PCA_SCORES}" \
    "${APPLIED_MODEL}" \
    --load-groups False
[[ -f "${APPLIED_MODEL}" ]] || die "held-out model application output was not created: ${APPLIED_MODEL}"

MODEL_SHA_AFTER="$(sha256sum "${PRODUCTION_MODEL}" | awk '{print $1}')"
if [[ "${MODEL_SHA_AFTER}" != "${MODEL_SHA_BEFORE}" || "${MODEL_SHA_AFTER}" != "${FROZEN_MODEL_SHA256}" ]]; then
    {
        printf 'status=FAILED_HOLD\n'
        printf 'reason=PRODUCTION_MODEL_IDENTITY_CHANGED_DURING_HELDOUT_APPLICATION\n'
        printf 'production_model_sha256_before=%s\n' "${MODEL_SHA_BEFORE}"
        printf 'production_model_sha256_after=%s\n' "${MODEL_SHA_AFTER}"
        printf 'model_fit_started=false\n'
        printf 'model_adaptation_started=false\n'
    } >"${OUTPUT}/REAL_PILOT_FAILURE_RECEIPT.txt"
    die "production model identity changed during held-out application"
fi

run_stage 05_summarize_handoffs \
    python "${SCRIPT_DIR}/helpers/summarize_real_pilot.py" \
    --extraction-h5 "${EXTRACTION_H5}" \
    --pca-scores "${PCA_SCORES}" \
    --output-dir "${OUTPUT}/summaries"

{
    printf 'completed_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'recording_reference=%s\n' "${RECORDING}"
    printf 'recording_sha256=%s\n' "$(sha256sum "${RECORDING}" | awk '{print $1}')"
    printf 'pilot_frames=%s\n' "${PILOT_FRAMES}"
    printf 'run_spec_sha256=%s\n' "$(sha256sum "${RUN_SPEC}" | awk '{print $1}')"
    printf 'pca_components_sha256=%s\n' "$(sha256sum "${PCA_COMPONENTS}" | awk '{print $1}')"
    printf 'production_model_reference=%s\n' "${PRODUCTION_MODEL}"
    printf 'production_model_seed=%s\n' "${FROZEN_MODEL_SEED}"
    printf 'production_model_kappa=%s\n' "${FROZEN_MODEL_KAPPA}"
    printf 'production_model_sha256_before=%s\n' "${MODEL_SHA_BEFORE}"
    printf 'production_model_sha256_after=%s\n' "${MODEL_SHA_AFTER}"
    printf 'production_model_sha256_unchanged=true\n'
    printf 'applied_model_output=%s\n' "${APPLIED_MODEL}"
    printf 'applied_model_sha256=%s\n' "$(sha256sum "${APPLIED_MODEL}" | awk '{print $1}')"
    printf 'model_application=HELDOUT_ONLY_STORED_PARAMETERS\n'
    printf 'provenance_preflight=PASS\n'
    printf 'original_recording_modified=false\n'
    printf 'existing_project_outputs_modified=false\n'
    printf 'model_fit_started=false\n'
    printf 'model_adaptation_started=false\n'
} >"${OUTPUT}/REAL_PILOT_RECEIPT.txt"

printf 'Approved bounded real pilot completed: %s\n' "${OUTPUT}"
printf 'Frozen model applied held-out. No model fit or adaptation was started.\n'
