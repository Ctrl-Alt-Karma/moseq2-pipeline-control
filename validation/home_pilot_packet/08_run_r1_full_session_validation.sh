#!/usr/bin/env bash

# Sealed R1 whole-session operator. This is distinct from the historical
# bounded pilot operator and has no user-selectable frame truncation.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

CONFIRM_TOKEN="RUN_SEALED_R1_FULL_SESSION"
FROZEN_CONFIG_SHA256="ef42bf756eef975277d5dc62d0d7719daf75f374a2e58d96a6c3eb39ecd75269"
FROZEN_CLASSIFIER_SHA256="4b06e1e56928bb1ac227329d0932d4637cdd541a3af49865ae127b57991c2c00"
FROZEN_PCA_SHA256="26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912"
FROZEN_MODEL_SHA256="5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964"
FROZEN_MODEL_SEED=20260802
FROZEN_MODEL_KAPPA=464159
R1_ROOT="/home/ajm/moseq2-validation-20260730/validation/r1_existing_outside_corpus_v5"
STAGED_RAW_ROOT="${R1_ROOT}/raw"
RUNS_ROOT="${R1_ROOT}/runs"
ORIGINAL_FREEZE_PACKET_MANIFEST="/mnt/c/deployment/MoSeq2-Pilot-Reusable-Root-Corrected-2026-07-30/Extracted-20260801T011401Z/MOSEQ_LEGACY_HOME_PILOT_REUSABLE_ROOT_CORRECTED_2026-07-30/SHA256SUMS.txt"
ORIGINAL_FREEZE_PACKET_MANIFEST_SHA256="bd100aff8b55ade07c373ef70e57916184a6a14539e02ad0d7e42d69efa415cb"

usage() {
    cat <<EOF
Usage:
  bash 08_run_r1_full_session_validation.sh \\
    --run-spec /path/to/CANDIDATE_RUN_SPEC.json \\
    --recording ${STAGED_RAW_ROOT}/CID-.../depth.dat \\
    --config /home/ajm/.../config.yaml \\
    --classifier /home/ajm/.../flip_classifier.pkl \\
    --pca /home/ajm/.../pca_scores.h5 \\
    --production-model /home/ajm/.../model.p \\
    --confirm ${CONFIRM_TOKEN} \\
    [--output ${RUNS_ROOT}/unique-new-directory]

The operator processes the complete staged recording. Raw inputs must be
non-writable and resolve beneath the fixed R1 staged-raw root. No model fit,
resume, refit, or adaptation exists in this operator.
EOF
}

RUN_SPEC=""
RECORDING=""
CONFIG=""
CLASSIFIER=""
PCA=""
PRODUCTION_MODEL=""
CONFIRM=""
OUTPUT=""
PROVENANCE_PREFLIGHT_ONLY=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --run-spec) RUN_SPEC="${2:?missing --run-spec value}"; shift 2 ;;
        --recording) RECORDING="${2:?missing --recording value}"; shift 2 ;;
        --config) CONFIG="${2:?missing --config value}"; shift 2 ;;
        --classifier) CLASSIFIER="${2:?missing --classifier value}"; shift 2 ;;
        --pca) PCA="${2:?missing --pca value}"; shift 2 ;;
        --production-model) PRODUCTION_MODEL="${2:?missing --production-model value}"; shift 2 ;;
        --confirm) CONFIRM="${2:?missing --confirm value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --provenance-preflight-only) PROVENANCE_PREFLIGHT_ONLY=true; shift ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ "${CONFIRM}" == "${CONFIRM_TOKEN}" ]] || die "explicit --confirm ${CONFIRM_TOKEN} is required"
[[ -n "${RUN_SPEC}" ]] || die "--run-spec is required"
[[ -n "${RECORDING}" ]] || die "--recording is required"
[[ -n "${CONFIG}" ]] || die "--config is required"
[[ -n "${CLASSIFIER}" ]] || die "--classifier is required"
[[ -n "${PCA}" ]] || die "--pca is required"
[[ -n "${PRODUCTION_MODEL}" ]] || die "--production-model is required"

# Evaluate the supplied path lexically and through existing symlinks before
# checking file existence, so rejected mount families fail at the path gate.
RECORDING_REAL="$(realpath -m "${RECORDING}")"
case "${RECORDING_REAL}" in
    "${STAGED_RAW_ROOT}"/*/depth.dat) ;;
    *) die "recording must resolve to ${STAGED_RAW_ROOT}/<candidate_identity_id>/depth.dat" ;;
esac
[[ -f "${RECORDING_REAL}" ]] || die "staged depth.dat is not a regular file: ${RECORDING_REAL}"
[[ ! -L "${RECORDING}" ]] || die "staged depth.dat may not be a symbolic link"
SESSION_DIR="$(dirname "${RECORDING_REAL}")"
SESSION_REAL="$(realpath -e "${SESSION_DIR}")"
case "${SESSION_REAL}" in
    "${STAGED_RAW_ROOT}"/*) ;;
    *) die "staged session directory escapes the approved raw root" ;;
esac
METADATA="${SESSION_REAL}/metadata.json"
TIMESTAMPS="${SESSION_REAL}/depth_ts.txt"

for path in "${RUN_SPEC}" "${CONFIG}" "${CLASSIFIER}" "${PCA}" "${PRODUCTION_MODEL}"; do
    [[ -f "${path}" ]] || die "required file is missing: ${path}"
done

# The validation-root marker binds the original Phase-0 freeze packet, not this
# later R3 operator packet. Preserve that chain explicitly; R3 source integrity
# is independently enforced by SHA256SUMS_R3.txt and the committed Git tree.
[[ -f "${ORIGINAL_FREEZE_PACKET_MANIFEST}" ]] || die "original freeze packet manifest is missing"
[[ "$(sha256sum "${ORIGINAL_FREEZE_PACKET_MANIFEST}" | awk '{print $1}')" == "${ORIGINAL_FREEZE_PACKET_MANIFEST_SHA256}" ]] || die "original freeze packet manifest identity mismatch"
PACKET_MANIFEST_PATH="${ORIGINAL_FREEZE_PACKET_MANIFEST}"
require_locked_source_complete "/home/ajm/moseq2-validation-20260730" >/dev/null
mkdir -p "${RUNS_ROOT}"
if [[ -z "${OUTPUT}" ]]; then
    OUTPUT="${RUNS_ROOT}/$(basename "${SESSION_REAL}")_$(timestamp_utc)"
fi
OUTPUT_REAL="$(realpath -m "${OUTPUT}")"
case "${OUTPUT_REAL}" in
    "${RUNS_ROOT}"/*) ;;
    *) die "output must be a fresh directory beneath ${RUNS_ROOT}" ;;
esac
[[ ! -e "${OUTPUT_REAL}" ]] || die "refusing to overwrite existing output: ${OUTPUT_REAL}"
mkdir -p "${OUTPUT_REAL}/inputs" "${OUTPUT_REAL}/logs"

PROVENANCE_PYTHON="${LEGACY_CONDA_PREFIX}/bin/python"
PROVENANCE_RECEIPT="${OUTPUT_REAL}/inputs/provenance_preflight.json"
set +e
PYTHONDONTWRITEBYTECODE=1 "${PROVENANCE_PYTHON}" -B "${SCRIPT_DIR}/helpers/verify_r1_full_session_provenance.py" \
    --run-spec "${RUN_SPEC}" \
    --staged-root "${STAGED_RAW_ROOT}" \
    --depth "${RECORDING_REAL}" \
    --metadata "${METADATA}" \
    --timestamps "${TIMESTAMPS}" \
    --config "${CONFIG}" \
    --classifier "${CLASSIFIER}" \
    --pca "${PCA}" \
    --model "${PRODUCTION_MODEL}" \
    --required-config-sha256 "${FROZEN_CONFIG_SHA256}" \
    --required-classifier-sha256 "${FROZEN_CLASSIFIER_SHA256}" \
    --required-pca-sha256 "${FROZEN_PCA_SHA256}" \
    --required-model-sha256 "${FROZEN_MODEL_SHA256}" \
    --required-model-seed "${FROZEN_MODEL_SEED}" \
    --required-model-kappa "${FROZEN_MODEL_KAPPA}" \
    --receipt "${PROVENANCE_RECEIPT}" \
    >"${OUTPUT_REAL}/logs/00_provenance_preflight.stdout.txt" \
    2>"${OUTPUT_REAL}/logs/00_provenance_preflight.stderr.txt"
PROVENANCE_EXIT=$?
set -e
printf '%s\n' "${PROVENANCE_EXIT}" >"${OUTPUT_REAL}/logs/00_provenance_preflight.exit_code.txt"
if [[ "${PROVENANCE_EXIT}" -ne 0 ]]; then
    {
        printf 'status=FAILED_HOLD\n'
        printf 'reason=R1_FULL_SESSION_PROVENANCE_PREFLIGHT_FAILED\n'
        printf 'scientific_processing_started=false\n'
        printf 'source_input_modified=false\n'
    } >"${OUTPUT_REAL}/R1_FULL_SESSION_FAILURE_RECEIPT.txt"
    die "R1 full-session provenance preflight failed; science was not started"
fi

RAW_ACCOUNTING="${OUTPUT_REAL}/inputs/raw_frame_accounting.json"
PYTHONDONTWRITEBYTECODE=1 "${PROVENANCE_PYTHON}" -B "${SCRIPT_DIR}/helpers/record_r1_raw_frame_accounting.py" \
    --depth "${RECORDING_REAL}" --metadata "${METADATA}" --timestamps "${TIMESTAMPS}" --output "${RAW_ACCOUNTING}" || {
        printf 'status=FAILED_HOLD\nreason=RAW_FRAME_ACCOUNTING_FAILED\nscientific_processing_started=false\n' >"${OUTPUT_REAL}/R1_FULL_SESSION_FAILURE_RECEIPT.txt"
        die "raw frame accounting failed before science"
    }

MODEL_SHA_BEFORE="$(sha256sum "${PRODUCTION_MODEL}" | awk '{print $1}')"
[[ "${MODEL_SHA_BEFORE}" == "${FROZEN_MODEL_SHA256}" ]] || die "production model changed after provenance preflight"

activate_legacy_environment
load_locked_source_environment "/home/ajm/moseq2-validation-20260730/locked_source.env"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=0
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export DASK_NUM_WORKERS=1

PYTHONDONTWRITEBYTECODE=1 python -B "${SCRIPT_DIR}/helpers/verify_r1_runtime_identity.py" \
    --receipt "${OUTPUT_REAL}/inputs/runtime_identity.json" || {
        printf 'status=FAILED_HOLD\nreason=FROZEN_RUNTIME_IDENTITY_FAILED\nscientific_processing_started=false\n' >"${OUTPUT_REAL}/R1_FULL_SESSION_FAILURE_RECEIPT.txt"
        die "frozen runtime identity failed before science"
    }

if [[ "${PROVENANCE_PREFLIGHT_ONLY}" == true ]]; then
    [[ "${MOSEQ_PACKET_SYNTHETIC_TEST_MODE:-0}" == 1 ]] || die "preflight-only mode is restricted to synthetic qualification"
    {
        printf 'status=PASS\n'
        printf 'scope=R1_FULL_SESSION_PRE_SCIENCE_SYNTHETIC_QUALIFICATION\n'
        printf 'scientific_processing_started=false\n'
        printf 'production_model_sha256=%s\n' "${MODEL_SHA_BEFORE}"
    } >"${OUTPUT_REAL}/R1_FULL_SESSION_PREFLIGHT_ONLY_RECEIPT.txt"
    exit 0
fi

mkdir -p \
    "${OUTPUT_REAL}/stages/01_roi" \
    "${OUTPUT_REAL}/stages/02_extract" \
    "${OUTPUT_REAL}/stages/03_pca" \
    "${OUTPUT_REAL}/stages/04_model" \
    "${OUTPUT_REAL}/summaries"

RUN_SPEC_COPY="${OUTPUT_REAL}/inputs/R1_FULL_SESSION_RUN_SPEC.json"
CONFIG_ORIGINAL="${OUTPUT_REAL}/inputs/config.original.yaml"
CONFIG_COPY="${OUTPUT_REAL}/inputs/config.working.yaml"
CLASSIFIER_COPY="${OUTPUT_REAL}/inputs/flip_classifier.pkl"
PCA_COPY="${OUTPUT_REAL}/inputs/pca_components.h5"
cp --preserve=timestamps "${RUN_SPEC}" "${RUN_SPEC_COPY}"
cp --preserve=timestamps "${CONFIG}" "${CONFIG_ORIGINAL}"
cp --preserve=timestamps "${CONFIG}" "${CONFIG_COPY}"
cp --preserve=timestamps "${CLASSIFIER}" "${CLASSIFIER_COPY}"
cp --preserve=timestamps "${PCA}" "${PCA_COPY}"
chmod a-w "${RUN_SPEC_COPY}" "${CONFIG_ORIGINAL}" "${CLASSIFIER_COPY}" "${PCA_COPY}"
write_process_environment "${OUTPUT_REAL}/process_environment.txt"

run_stage() {
    local stage="$1"
    shift
    printf '%q ' "$@" >"${OUTPUT_REAL}/logs/${stage}.command.txt"
    printf '\n' >>"${OUTPUT_REAL}/logs/${stage}.command.txt"
    set +e
    "$@" >"${OUTPUT_REAL}/logs/${stage}.stdout.txt" 2>"${OUTPUT_REAL}/logs/${stage}.stderr.txt"
    local code=$?
    set -e
    printf '%s\n' "${code}" >"${OUTPUT_REAL}/logs/${stage}.exit_code.txt"
    [[ "${code}" -eq 0 ]] || die "stage ${stage} failed with exit code ${code}; no later stage started"
}

run_stage 01_find_roi \
    moseq2-extract find-roi "${RECORDING_REAL}" \
    --config-file "${CONFIG_COPY}" \
    --output-dir "${OUTPUT_REAL}/stages/01_roi"

run_stage 02_extract_full_session \
    moseq2-extract extract "${RECORDING_REAL}" \
    --config-file "${CONFIG_COPY}" \
    --output-dir "${OUTPUT_REAL}/stages/02_extract" \
    --cluster-type local \
    --compute-raw-scalars \
    --flip-classifier "${CLASSIFIER_COPY}"

mapfile -t EXTRACTION_H5S < <(find "${OUTPUT_REAL}/stages/02_extract" -maxdepth 5 -type f -name 'results_*.h5' | LC_ALL=C sort)
[[ "${#EXTRACTION_H5S[@]}" -eq 1 ]] || die "expected exactly one extraction HDF5"
EXTRACTION_H5="${EXTRACTION_H5S[0]}"
PYTHONDONTWRITEBYTECODE=1 python -B "${SCRIPT_DIR}/helpers/verify_r1_extraction_frame_accounting.py" \
    --raw-accounting "${RAW_ACCOUNTING}" \
    --extraction-h5 "${EXTRACTION_H5}" \
    --output "${OUTPUT_REAL}/inputs/extraction_frame_accounting.json" || die "unexplained full-session frame truncation"

run_stage 03_apply_frozen_pca \
    moseq2-pca apply-pca \
    --input-dir "${OUTPUT_REAL}/stages/02_extract" \
    --output-dir "${OUTPUT_REAL}/stages/03_pca" \
    --output-file pca_scores \
    --pca-file "${PCA_COPY}" \
    --cluster-type nodask \
    --config-file "${CONFIG_COPY}" \
    --overwrite-pca-apply True

PCA_SCORES="${OUTPUT_REAL}/stages/03_pca/pca_scores.h5"
[[ -f "${PCA_SCORES}" ]] || die "PCA score output was not created"
APPLIED_MODEL="${OUTPUT_REAL}/stages/04_model/model-applied-heldout.p"
run_stage 04_apply_frozen_model_heldout \
    moseq2-model apply-model \
    "${PRODUCTION_MODEL}" "${PCA_SCORES}" "${APPLIED_MODEL}" --load-groups False
[[ -f "${APPLIED_MODEL}" ]] || die "held-out applied-model output was not created"

MODEL_SHA_AFTER="$(sha256sum "${PRODUCTION_MODEL}" | awk '{print $1}')"
if [[ "${MODEL_SHA_AFTER}" != "${MODEL_SHA_BEFORE}" || "${MODEL_SHA_AFTER}" != "${FROZEN_MODEL_SHA256}" ]]; then
    printf 'status=FAILED_HOLD\nreason=PRODUCTION_MODEL_IDENTITY_CHANGED\nmodel_fit_started=false\nmodel_adaptation_started=false\n' >"${OUTPUT_REAL}/R1_FULL_SESSION_FAILURE_RECEIPT.txt"
    die "production model identity changed during held-out application"
fi

run_stage 05_summarize_handoffs \
    python "${SCRIPT_DIR}/helpers/summarize_real_pilot.py" \
    --extraction-h5 "${EXTRACTION_H5}" --pca-scores "${PCA_SCORES}" --output-dir "${OUTPUT_REAL}/summaries"

{
    printf 'status=PASS\n'
    printf 'completed_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'recording_reference=%s\n' "${RECORDING_REAL}"
    printf 'full_session=true\n'
    printf 'production_model_sha256_before=%s\n' "${MODEL_SHA_BEFORE}"
    printf 'production_model_sha256_after=%s\n' "${MODEL_SHA_AFTER}"
    printf 'model_application=HELDOUT_ONLY_STORED_PARAMETERS\n'
    printf 'extraction_time_flip_classifier=true\n'
    printf 'app_level_reflip=false\n'
    printf 'model_fit_started=false\n'
    printf 'model_adaptation_started=false\n'
    printf 'source_inputs_modified=false\n'
} >"${OUTPUT_REAL}/R1_FULL_SESSION_RECEIPT.txt"
