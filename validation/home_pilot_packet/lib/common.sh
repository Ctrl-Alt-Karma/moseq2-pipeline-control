#!/usr/bin/env bash

# Shared guards for the home legacy-environment packet.

set -Eeuo pipefail

LEGACY_CONDA_ROOT="/home/ajm/miniforge3"
LEGACY_CONDA_ENV="moseq2-app"
LEGACY_VALIDATION_ROOT_DEFAULT="/home/ajm/moseq2-legacy-validation"

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

timestamp_utc() {
    date -u +%Y%m%dT%H%M%SZ
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

activate_legacy_environment() {
    local conda_sh="${LEGACY_CONDA_ROOT}/etc/profile.d/conda.sh"
    [[ -r "${conda_sh}" ]] || die "cannot read ${conda_sh}"
    # shellcheck source=/dev/null
    source "${conda_sh}"
    conda activate "${LEGACY_CONDA_ENV}"

    local observed
    observed="$(python - <<'PY'
import sys
import numpy
print("{}.{}|{}".format(sys.version_info[0], sys.version_info[1], numpy.__version__))
PY
)"
    [[ "${observed}" == "3.7|1.18.3" ]] || {
        die "refusing non-production stack; expected Python 3.7 / NumPy 1.18.3, observed ${observed}"
    }
}

require_under_home_ajm() {
    local target="$1"
    case "${target}" in
        /home/ajm/*) ;;
        *) die "output must be below /home/ajm: ${target}" ;;
    esac
}

new_directory_only() {
    local target="$1"
    require_under_home_ajm "${target}"
    [[ ! -e "${target}" ]] || die "refusing to overwrite existing path: ${target}"
    mkdir -p "${target}"
}

load_locked_source_environment() {
    local env_file="${1:-${LEGACY_VALIDATION_ROOT_DEFAULT}/locked_source.env}"
    [[ -r "${env_file}" ]] || die "locked source environment is missing: ${env_file}; run 02_prepare_locked_worktrees.sh"
    # shellcheck source=/dev/null
    source "${env_file}"
    export PYTHONPATH
}

write_process_environment() {
    local output_file="$1"
    local name
    local -a safe_environment_names=(
        PATH
        PYTHONPATH
        PYTHONHASHSEED
        CONDA_PREFIX
        CONDA_DEFAULT_ENV
        CONDA_EXE
        CONDA_SHLVL
        LD_LIBRARY_PATH
        OMP_NUM_THREADS
        MKL_NUM_THREADS
        OPENBLAS_NUM_THREADS
        NUMEXPR_NUM_THREADS
        DASK_NUM_WORKERS
        LANG
        LC_ALL
        TZ
    )
    {
        printf 'captured_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        printf 'pwd=%s\n' "$(pwd)"
        for name in "${safe_environment_names[@]}"; do
            if [[ -v "${name}" ]]; then
                printf '%s=%q\n' "${name}" "${!name}"
            else
                printf '%s=<UNSET>\n' "${name}"
            fi
        done
    } >"${output_file}"
}

sha256_and_bytes() {
    local path="$1"
    local output_file="$2"
    {
        sha256sum "${path}"
        wc -c <"${path}" | awk '{print $1 "  bytes"}'
    } >"${output_file}"
}
