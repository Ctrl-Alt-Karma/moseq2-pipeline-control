#!/usr/bin/env bash

# Shared guards for the home legacy-environment packet.

set -Eeuo pipefail

LEGACY_CONDA_ROOT="/home/ajm/miniforge3"
LEGACY_CONDA_ENV="moseq2-app"
LEGACY_CONDA_PREFIX="${LEGACY_CONDA_ROOT}/envs/${LEGACY_CONDA_ENV}"
VALIDATION_HOME_ROOT="/home/ajm"
VALIDATION_ROOT_SCHEMA="moseq2-home-pilot-validation-root-v1"
PHASE0_RECEIPT_SCHEMA="moseq2-home-pilot-phase0-receipt-v1"
LOCKED_SOURCE_RECEIPT_SCHEMA="moseq2-home-pilot-locked-source-receipt-v1"
VALIDATION_ROOT_MARKER_NAME=".moseq2-home-pilot-root"
PHASE0_RECEIPT_NAME="PHASE0_FREEZE_RECEIPT.txt"
PHASE0_MANIFEST_NAME="PHASE0_SHA256SUMS.txt"
LOCKED_SOURCE_RECEIPT_NAME="LOCKED_WORKTREE_RECEIPT.txt"
PACKET_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKET_MANIFEST_PATH="${PACKET_ROOT_DIR}/SHA256SUMS.txt"

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
        "${VALIDATION_HOME_ROOT}"/*) ;;
        *) die "output must be below ${VALIDATION_HOME_ROOT}: ${target}" ;;
    esac
}

set_synthetic_validation_home_for_test() {
    local target="$1"
    [[ "${MOSEQ_PACKET_SYNTHETIC_TEST_MODE:-}" == "1" ]] || {
        die "synthetic validation-home override requires test mode"
    }
    [[ -d "${target}" ]] || die "synthetic validation home is missing: ${target}"
    VALIDATION_HOME_ROOT="$(cd "${target}" && pwd)"
}

new_directory_only() {
    local target="$1"
    require_under_home_ajm "${target}"
    [[ ! -e "${target}" ]] || die "refusing to overwrite existing path: ${target}"
    mkdir -p "${target}"
}

new_directory_below_validation_root() {
    local root="$1"
    local target="$2"
    root="$(cd "${root}" && pwd)"
    case "${target}" in
        "${root}"/*) ;;
        *) die "phase output must be below validation root ${root}: ${target}" ;;
    esac
    [[ ! -e "${target}" ]] || die "refusing to overwrite existing path: ${target}"
    mkdir -p "${target}"
}

record_value() {
    local path="$1"
    local key="$2"
    local count
    count="$(grep -c "^${key}=" "${path}" || true)"
    [[ "${count}" -eq 1 ]] || die "expected one ${key} field in ${path}"
    sed -n "s/^${key}=//p" "${path}"
}

require_record_keys_only() {
    local path="$1"
    shift
    local expected_count="$#"
    local observed_count
    local key
    [[ -f "${path}" ]] || die "required record is missing: ${path}"
    observed_count="$(wc -l <"${path}" | tr -d '[:space:]')"
    [[ "${observed_count}" -eq "${expected_count}" ]] || {
        die "unexpected field count in ${path}: ${observed_count}"
    }
    for key in "$@"; do
        record_value "${path}" "${key}" >/dev/null
    done
}

initialize_validation_root() {
    local target="$1"
    local packet_manifest="$2"
    local marker
    local packet_manifest_hash
    require_under_home_ajm "${target}"
    [[ ! -e "${target}" ]] || die "refusing existing validation root: ${target}"
    [[ -f "${packet_manifest}" ]] || die "packet manifest is missing: ${packet_manifest}"
    require_command sha256sum
    mkdir -p "${target}"
    target="$(cd "${target}" && pwd)"
    marker="${target}/${VALIDATION_ROOT_MARKER_NAME}"
    packet_manifest_hash="$(sha256sum "${packet_manifest}" | awk '{print $1}')"
    {
        printf 'schema=%s\n' "${VALIDATION_ROOT_SCHEMA}"
        printf 'created_by=01_freeze_legacy_environment.sh\n'
        printf 'created_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        printf 'root=%s\n' "${target}"
        printf 'packet_manifest_sha256=%s\n' "${packet_manifest_hash}"
    } >"${marker}"
    printf '%s\n' "${target}"
}

require_validation_root_marker() {
    local root="$1"
    local marker="${root}/${VALIDATION_ROOT_MARKER_NAME}"
    local created_utc
    local manifest_hash
    [[ -d "${root}" ]] || die "validation root is missing: ${root}"
    root="$(cd "${root}" && pwd)"
    require_under_home_ajm "${root}"
    require_record_keys_only "${marker}" \
        schema created_by created_utc root packet_manifest_sha256
    [[ "$(record_value "${marker}" schema)" == "${VALIDATION_ROOT_SCHEMA}" ]] || {
        die "validation-root schema mismatch: ${marker}"
    }
    [[ "$(record_value "${marker}" created_by)" == "01_freeze_legacy_environment.sh" ]] || {
        die "validation root was not initialized by script 01: ${marker}"
    }
    [[ "$(record_value "${marker}" root)" == "${root}" ]] || {
        die "validation-root marker path mismatch: ${marker}"
    }
    created_utc="$(record_value "${marker}" created_utc)"
    [[ "${created_utc}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]] || {
        die "invalid validation-root creation timestamp: ${created_utc}"
    }
    manifest_hash="$(record_value "${marker}" packet_manifest_sha256)"
    [[ "${manifest_hash}" =~ ^[0-9a-f]{64}$ ]] || {
        die "invalid packet manifest hash in ${marker}"
    }
    [[ -f "${PACKET_MANIFEST_PATH}" ]] || {
        die "current packet manifest is missing: ${PACKET_MANIFEST_PATH}"
    }
    require_command sha256sum
    [[ "${manifest_hash}" == "$(sha256sum "${PACKET_MANIFEST_PATH}" | awk '{print $1}')" ]] || {
        die "validation root was initialized by a different packet manifest"
    }
}

require_phase0_complete() {
    local root="$1"
    local receipt
    local manifest
    local manifest_hash
    local output
    local evidence_path
    require_validation_root_marker "${root}"
    require_command sha256sum
    root="$(cd "${root}" && pwd)"
    receipt="${root}/${PHASE0_RECEIPT_NAME}"
    manifest="${root}/${PHASE0_MANIFEST_NAME}"
    require_record_keys_only "${receipt}" \
        schema status root output production_environment \
        environment_changed packages_installed phase0_manifest \
        phase0_manifest_sha256 installed_source_identity \
        sitecustomize_evidence classifier_custody configuration_custody
    [[ "$(record_value "${receipt}" schema)" == "${PHASE0_RECEIPT_SCHEMA}" ]] || {
        die "Phase 0 receipt schema mismatch: ${receipt}"
    }
    [[ "$(record_value "${receipt}" status)" == "COMPLETE" ]] || {
        die "Phase 0 receipt is not COMPLETE: ${receipt}"
    }
    [[ "$(record_value "${receipt}" root)" == "${root}" ]] || {
        die "Phase 0 receipt root mismatch: ${receipt}"
    }
    [[ "$(record_value "${receipt}" production_environment)" == "${LEGACY_CONDA_PREFIX}" ]] || {
        die "Phase 0 production environment mismatch: ${receipt}"
    }
    [[ "$(record_value "${receipt}" environment_changed)" == "false" ]] || {
        die "Phase 0 receipt does not attest environment_changed=false"
    }
    [[ "$(record_value "${receipt}" packages_installed)" == "false" ]] || {
        die "Phase 0 receipt does not attest packages_installed=false"
    }
    output="$(record_value "${receipt}" output)"
    case "${output}" in
        "${root}"/evidence/*) ;;
        *) die "Phase 0 output is outside the validation root: ${output}" ;;
    esac
    [[ -d "${output}" ]] || die "Phase 0 output directory is missing: ${output}"
    [[ "$(record_value "${receipt}" phase0_manifest)" == "${manifest}" ]] || {
        die "Phase 0 manifest path mismatch: ${receipt}"
    }
    [[ -f "${manifest}" ]] || die "Phase 0 manifest is missing: ${manifest}"
    manifest_hash="$(sha256sum "${manifest}" | awk '{print $1}')"
    [[ "${manifest_hash}" == "$(record_value "${receipt}" phase0_manifest_sha256)" ]] || {
        die "Phase 0 manifest hash mismatch: ${manifest}"
    }
    for key in \
        installed_source_identity \
        sitecustomize_evidence \
        classifier_custody \
        configuration_custody; do
        evidence_path="$(record_value "${receipt}" "${key}")"
        case "${evidence_path}" in
            "${output}"/*) ;;
            *) die "Phase 0 evidence path is outside its output for ${key}" ;;
        esac
        [[ -f "${evidence_path}" ]] || {
            die "Phase 0 evidence path is missing for ${key}"
        }
    done
    (
        cd "${root}"
        sha256sum -c "${PHASE0_MANIFEST_NAME}" >/dev/null
    ) || die "Phase 0 internal manifest verification failed"
    printf '%s\n' "${root}"
}

require_locked_source_complete() {
    local root="$1"
    local receipt
    require_phase0_complete "${root}" >/dev/null
    root="$(cd "${root}" && pwd)"
    receipt="${root}/${LOCKED_SOURCE_RECEIPT_NAME}"
    require_record_keys_only "${receipt}" \
        schema status created_utc root source_mode \
        conda_install_performed floating_refs_used
    [[ "$(record_value "${receipt}" schema)" == "${LOCKED_SOURCE_RECEIPT_SCHEMA}" ]] || {
        die "locked-source receipt schema mismatch: ${receipt}"
    }
    [[ "$(record_value "${receipt}" status)" == "COMPLETE" ]] || {
        die "locked-source receipt is not COMPLETE: ${receipt}"
    }
    [[ "$(record_value "${receipt}" root)" == "${root}" ]] || {
        die "locked-source receipt root mismatch: ${receipt}"
    }
    [[ "$(record_value "${receipt}" source_mode)" == "PYTHONPATH_ONLY" ]] || {
        die "locked-source mode mismatch: ${receipt}"
    }
    [[ "$(record_value "${receipt}" conda_install_performed)" == "false" ]] || {
        die "locked-source receipt reports a Conda install"
    }
    [[ "$(record_value "${receipt}" floating_refs_used)" == "false" ]] || {
        die "locked-source receipt reports floating refs"
    }
    [[ -d "${root}/worktrees" ]] || die "locked worktree directory is missing"
    [[ -f "${root}/locked_worktrees.tsv" ]] || die "locked worktree table is missing"
    [[ -f "${root}/locked_source.env" ]] || die "locked source environment is missing"
    printf '%s\n' "${root}"
}

load_locked_source_environment() {
    local env_file="$1"
    local root
    [[ -n "${env_file}" ]] || die "locked source environment path is required"
    [[ -r "${env_file}" ]] || die "locked source environment is missing: ${env_file}; run 02_prepare_locked_worktrees.sh"
    root="$(cd "$(dirname "${env_file}")" && pwd)"
    require_locked_source_complete "${root}" >/dev/null
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
