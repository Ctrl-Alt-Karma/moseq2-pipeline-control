#!/usr/bin/env bash

# Creates isolated source clones only. It never installs those sources into the
# production Conda environment and never touches an existing project checkout.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash 02_prepare_locked_worktrees.sh --root /home/ajm/NEW-validation-root

The root is required, must be below /home/ajm, and must have been initialized
by script 01 with a complete, structurally valid Phase 0 receipt. Script 02
refuses arbitrary roots, unknown state, partial runs, reruns, or any existing
script-02 output. Every checkout is detached at a hard-coded 40-character
commit SHA. No package installation is performed.
EOF
}

ROOT=""
VALIDATE_ROOT_ONLY=false
SYNTHETIC_TEST_HOME=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --validate-root-only) VALIDATE_ROOT_ONLY=true; shift ;;
        --synthetic-test-home)
            SYNTHETIC_TEST_HOME="${2:?missing --synthetic-test-home value}"
            shift 2
            ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${ROOT}" ]] || {
    die "--root is required and must name the Phase-0-initialized validation root"
}

if [[ -n "${SYNTHETIC_TEST_HOME}" ]]; then
    [[ "${VALIDATE_ROOT_ONLY}" == true ]] || {
        die "--synthetic-test-home is allowed only with --validate-root-only"
    }
    set_synthetic_validation_home_for_test "${SYNTHETIC_TEST_HOME}"
fi

ROOT="$(require_phase0_complete "${ROOT}")"
WORKTREES="${ROOT}/worktrees"
RECEIPT="${ROOT}/locked_worktrees.tsv"
ENV_FILE="${ROOT}/locked_source.env"
CONTROL_RECEIPT="${ROOT}/LOCKED_WORKTREE_RECEIPT.txt"

for script02_target in \
    "${WORKTREES}" \
    "${RECEIPT}" \
    "${ENV_FILE}" \
    "${CONTROL_RECEIPT}"; do
    [[ ! -e "${script02_target}" ]] || {
        die "conflicting prior script-02 state; refusing overwrite or rerun: ${script02_target}"
    }
done

while IFS= read -r -d '' root_entry; do
    root_name="$(basename "${root_entry}")"
    case "${root_name}" in
        "${VALIDATION_ROOT_MARKER_NAME}"|"evidence"|"${PHASE0_RECEIPT_NAME}"|"${PHASE0_MANIFEST_NAME}")
            ;;
        *)
            die "unknown or conflicting validation-root state: ${root_entry}"
            ;;
    esac
done < <(find "${ROOT}" -mindepth 1 -maxdepth 1 -print0)

if [[ "${VALIDATE_ROOT_ONLY}" == true ]]; then
    printf 'VALID_ROOT_FOR_SCRIPT_02=%s\n' "${ROOT}"
    exit 0
fi

require_command git
mkdir "${WORKTREES}"

declare -A URLS=(
    [moseq2-extract]="https://github.com/Ctrl-Alt-Karma/moseq2-extract.git"
    [moseq2-viz]="https://github.com/Ctrl-Alt-Karma/moseq2-viz.git"
    [moseq2-app]="https://github.com/Ctrl-Alt-Karma/moseq2-app.git"
    [moseq2-pca]="https://github.com/Ctrl-Alt-Karma/moseq2-pca.git"
    [moseq2-model]="https://github.com/Ctrl-Alt-Karma/moseq2-model.git"
)
declare -A SHAS=(
    [moseq2-extract]="e7f585104ba25b66e5326c88c77a47e33db95635"
    [moseq2-viz]="b80192dc20353bf77c36610f315543b57afa908c"
    [moseq2-app]="e0b85201226d03e15944473a734f71417698c31e"
    [moseq2-pca]="efb6fcfa5d5af5bb4274540c371d0ddf96440b78"
    [moseq2-model]="6e542e3f1db125202d42b59f390c922281e64f39"
)

ORDER=(
    moseq2-extract
    moseq2-viz
    moseq2-app
    moseq2-pca
    moseq2-model
)

printf 'repository\tpath\texpected_sha\tobserved_sha\torigin\n' >"${RECEIPT}"

for repository in "${ORDER[@]}"; do
    expected="${SHAS[${repository}]}"
    [[ "${expected}" =~ ^[0-9a-f]{40}$ ]] || die "non-SHA ref refused for ${repository}"
    checkout="${WORKTREES}/${repository}"

    if [[ ! -e "${checkout}" ]]; then
        git clone --no-checkout "${URLS[${repository}]}" "${checkout}"
    else
        [[ -d "${checkout}/.git" ]] || die "existing path is not a script-managed clone: ${checkout}"
        [[ -z "$(git -C "${checkout}" status --porcelain)" ]] || {
            die "refusing to change a dirty script-managed clone: ${checkout}"
        }
        observed_origin="$(git -C "${checkout}" remote get-url origin)"
        [[ "${observed_origin}" == "${URLS[${repository}]}" ]] || {
            die "origin mismatch for ${repository}: ${observed_origin}"
        }
    fi

    if ! git -C "${checkout}" cat-file -e "${expected}^{commit}" 2>/dev/null; then
        git -C "${checkout}" fetch --no-tags origin "${expected}"
    fi
    git -C "${checkout}" checkout --detach "${expected}"
    observed="$(git -C "${checkout}" rev-parse HEAD)"
    [[ "${observed}" == "${expected}" ]] || {
        die "${repository} checkout mismatch: expected ${expected}, observed ${observed}"
    }
    [[ -z "$(git -C "${checkout}" status --porcelain)" ]] || {
        die "${repository} checkout is not clean after detached checkout"
    }
    printf '%s\t%s\t%s\t%s\t%s\n' \
        "${repository}" "${checkout}" "${expected}" "${observed}" \
        "$(git -C "${checkout}" remote get-url origin)" >>"${RECEIPT}"
done

cat >"${ENV_FILE}" <<EOF
# Generated by 02_prepare_locked_worktrees.sh. Source this file; do not install.
export MOSEQ_VALIDATION_ROOT='${ROOT}'
export MOSEQ2_EXTRACT_REPO='${WORKTREES}/moseq2-extract'
export MOSEQ2_VIZ_REPO='${WORKTREES}/moseq2-viz'
export MOSEQ2_APP_REPO='${WORKTREES}/moseq2-app'
export MOSEQ2_PCA_REPO='${WORKTREES}/moseq2-pca'
export MOSEQ2_MODEL_REPO='${WORKTREES}/moseq2-model'
export MOSEQ_HOME_PACKET='${SCRIPT_DIR}'
export PYTHONPATH='${WORKTREES}/moseq2-extract:${WORKTREES}/moseq2-viz:${WORKTREES}/moseq2-app:${WORKTREES}/moseq2-pca:${WORKTREES}/moseq2-model'
EOF

{
    printf 'schema=%s\n' "${LOCKED_SOURCE_RECEIPT_SCHEMA}"
    printf 'status=COMPLETE\n'
    printf 'created_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'root=%s\n' "${ROOT}"
    printf 'source_mode=PYTHONPATH_ONLY\n'
    printf 'conda_install_performed=false\n'
    printf 'floating_refs_used=false\n'
} >"${CONTROL_RECEIPT}"

printf 'Locked detached worktrees are ready under: %s\n' "${WORKTREES}"
printf 'Generated environment file: %s\n' "${ENV_FILE}"
