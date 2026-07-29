#!/usr/bin/env bash

# The only real-data processing script in this packet. It refuses to run unless
# all scientific inputs and the explicit confirmation token are supplied.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

CONFIRM_TOKEN="RUN_APPROVED_REAL_PILOT"

usage() {
    cat <<EOF
Usage:
  bash 06_run_approved_real_pilot.sh \\
    --recording /mnt/c/.../depth.dat \\
    --config /mnt/c/.../config.yaml \\
    --classifier /mnt/c/.../flip-classifier.pkl \\
    --pca-components /mnt/c/.../pca.h5 \\
    --confirm ${CONFIRM_TOKEN} \\
    [--pilot-frames 3000] [--root DIR] [--output DIR]

All four input files are read-only references. Config, classifier, and PCA
components are copied into a new validation output directory before use.
The raw recording is never overwritten or copied by default. Extraction, PCA
application, and model-input loading run; model fitting never starts.
EOF
}

ROOT="${LEGACY_VALIDATION_ROOT_DEFAULT}"
OUTPUT=""
RECORDING=""
CONFIG=""
CLASSIFIER=""
PCA_COMPONENTS=""
CONFIRM=""
PILOT_FRAMES=3000
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --recording) RECORDING="${2:?missing --recording value}"; shift 2 ;;
        --config) CONFIG="${2:?missing --config value}"; shift 2 ;;
        --classifier) CLASSIFIER="${2:?missing --classifier value}"; shift 2 ;;
        --pca-components) PCA_COMPONENTS="${2:?missing --pca-components value}"; shift 2 ;;
        --confirm) CONFIRM="${2:?missing --confirm value}"; shift 2 ;;
        --pilot-frames) PILOT_FRAMES="${2:?missing --pilot-frames value}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${RECORDING}" ]] || die "--recording is required"
[[ "${CONFIRM}" == "${CONFIRM_TOKEN}" ]] || {
    die "explicit --confirm ${CONFIRM_TOKEN} is required"
}
[[ -f "${RECORDING}" ]] || die "recording is not a regular file: ${RECORDING}"
[[ -f "${CONFIG}" ]] || die "config is not a regular file: ${CONFIG}"
[[ -f "${CLASSIFIER}" ]] || die "classifier is not a regular file: ${CLASSIFIER}"
[[ -f "${PCA_COMPONENTS}" ]] || die "PCA components are not a regular file: ${PCA_COMPONENTS}"
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
new_directory_only "${OUTPUT}"
mkdir -p \
    "${OUTPUT}/inputs" \
    "${OUTPUT}/logs" \
    "${OUTPUT}/stages/01_roi" \
    "${OUTPUT}/stages/02_extract" \
    "${OUTPUT}/stages/03_pca" \
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

CONFIG_ORIGINAL="${OUTPUT}/inputs/config.original.yaml"
CONFIG_COPY="${OUTPUT}/inputs/config.working.yaml"
CLASSIFIER_COPY="${OUTPUT}/inputs/flip_classifier$(basename "${CLASSIFIER}" | sed 's/^[^.]*//')"
PCA_COPY="${OUTPUT}/inputs/pca_components.h5"
cp --preserve=timestamps "${CONFIG}" "${CONFIG_ORIGINAL}"
cp --preserve=timestamps "${CONFIG}" "${CONFIG_COPY}"
cp --preserve=timestamps "${CLASSIFIER}" "${CLASSIFIER_COPY}"
cp --preserve=timestamps "${PCA_COMPONENTS}" "${PCA_COPY}"
chmod a-w "${CONFIG_ORIGINAL}" "${CLASSIFIER_COPY}" "${PCA_COPY}"

{
    printf 'input_type\tpath\tsha256\tbytes\n'
    printf 'recording\t%s\t%s\t%s\n' \
        "${RECORDING}" "$(sha256sum "${RECORDING}" | awk '{print $1}')" \
        "$(wc -c <"${RECORDING}")"
    for entry in \
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

run_stage 04_summarize_handoffs \
    python "${SCRIPT_DIR}/helpers/summarize_real_pilot.py" \
    --extraction-h5 "${EXTRACTION_H5}" \
    --pca-scores "${PCA_SCORES}" \
    --output-dir "${OUTPUT}/summaries"

{
    printf 'completed_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'recording_reference=%s\n' "${RECORDING}"
    printf 'pilot_frames=%s\n' "${PILOT_FRAMES}"
    printf 'original_recording_modified=false\n'
    printf 'existing_project_outputs_modified=false\n'
    printf 'model_fit_started=false\n'
} >"${OUTPUT}/REAL_PILOT_RECEIPT.txt"

printf 'Approved bounded real pilot completed: %s\n' "${OUTPUT}"
printf 'No model fit was started.\n'
