#!/usr/bin/env bash

# Bounded synthetic qualification. Stops immediately on the first unexplained
# failure and writes only below a new /home/ajm validation output directory.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash 04_run_synthetic_pipeline.sh [--root DIR] [--output DIR]

This uses a new synthetic HDF5 file, a deterministic synthetic classifier, and
real extract/app/PCA/viz/model production interfaces. It never writes into a
source checkout, Conda environment, or real recording directory.
EOF
}

ROOT="${LEGACY_VALIDATION_ROOT_DEFAULT}"
OUTPUT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done
if [[ -z "${OUTPUT}" ]]; then
    OUTPUT="${ROOT}/evidence/synthetic_$(timestamp_utc)"
fi
new_directory_only "${OUTPUT}"

activate_legacy_environment
load_locked_source_environment "${ROOT}/locked_source.env"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=0
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export DASK_NUM_WORKERS=1

write_process_environment "${OUTPUT}/process_environment.txt"
{
    printf 'cwd=%q\n' "${SCRIPT_DIR}"
    printf 'python %q --output-dir %q\n' \
        "${SCRIPT_DIR}/helpers/synthetic_pipeline.py" "${OUTPUT}"
} >"${OUTPUT}/command.txt"

python "${SCRIPT_DIR}/helpers/synthetic_pipeline.py" \
    --output-dir "${OUTPUT}" \
    >"${OUTPUT}/stdout.txt" \
    2>"${OUTPUT}/stderr.txt"
printf '0\n' >"${OUTPUT}/exit_code.txt"

printf 'Synthetic qualification passed: %s\n' "${OUTPUT}"
