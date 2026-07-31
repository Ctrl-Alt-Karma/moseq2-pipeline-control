#!/usr/bin/env bash

# Synthetic-only regression for the reusable packet-root contract.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../lib/common.sh
source "${PACKET_ROOT}/lib/common.sh"

TEMP_BASE="${TMPDIR:-/tmp}"
TEST_HOME="$(mktemp -d "${TEMP_BASE%/}/moseq-root-lifecycle.XXXXXX")"
cleanup() {
    case "${TEST_HOME}" in
        "${TEMP_BASE%/}"/moseq-root-lifecycle.*) rm -rf -- "${TEST_HOME}" ;;
        *) printf 'Refusing unsafe cleanup path: %s\n' "${TEST_HOME}" >&2 ;;
    esac
}
trap cleanup EXIT

export MOSEQ_PACKET_SYNTHETIC_TEST_MODE=1
set_synthetic_validation_home_for_test "${TEST_HOME}"

make_valid_phase0_root() {
    local root="$1"
    local output="${root}/evidence/environment_freeze"
    local manifest="${root}/${PHASE0_MANIFEST_NAME}"
    local manifest_hash
    mkdir -p "${output}"
    root="$(cd "${root}" && pwd)"
    output="${root}/evidence/environment_freeze"
    manifest="${root}/${PHASE0_MANIFEST_NAME}"
    {
        printf 'schema=%s\n' "${VALIDATION_ROOT_SCHEMA}"
        printf 'created_by=01_freeze_legacy_environment.sh\n'
        printf 'created_utc=2026-07-30T00:00:00Z\n'
        printf 'root=%s\n' "${root}"
        printf 'packet_manifest_sha256=%s\n' \
            "$(sha256sum "${PACKET_ROOT}/SHA256SUMS.txt" | awk '{print $1}')"
    } >"${root}/${VALIDATION_ROOT_MARKER_NAME}"
    for evidence_name in \
        installed_moseq_source_identity.json \
        active_sitecustomize.json \
        classifier_custody.json \
        configuration_custody.json; do
        printf '{}\n' >"${output}/${evidence_name}"
    done
    (
        cd "${root}"
        {
            printf '%s\0' "${VALIDATION_ROOT_MARKER_NAME}"
            find evidence -type f -print0
        } |
            LC_ALL=C sort -z |
            xargs -0 sha256sum >"${PHASE0_MANIFEST_NAME}"
    )
    manifest_hash="$(sha256sum "${manifest}" | awk '{print $1}')"
    {
        printf 'schema=%s\n' "${PHASE0_RECEIPT_SCHEMA}"
        printf 'status=COMPLETE\n'
        printf 'root=%s\n' "${root}"
        printf 'output=%s\n' "${output}"
        printf 'production_environment=%s\n' "${LEGACY_CONDA_PREFIX}"
        printf 'environment_changed=false\n'
        printf 'packages_installed=false\n'
        printf 'phase0_manifest=%s\n' "${manifest}"
        printf 'phase0_manifest_sha256=%s\n' "${manifest_hash}"
        printf 'installed_source_identity=%s\n' \
            "${output}/installed_moseq_source_identity.json"
        printf 'sitecustomize_evidence=%s\n' \
            "${output}/active_sitecustomize.json"
        printf 'classifier_custody=%s\n' \
            "${output}/classifier_custody.json"
        printf 'configuration_custody=%s\n' \
            "${output}/configuration_custody.json"
    } >"${root}/${PHASE0_RECEIPT_NAME}"
}

run_validation() {
    bash "${PACKET_ROOT}/02_prepare_locked_worktrees.sh" \
        --root "$1" \
        --validate-root-only \
        --synthetic-test-home "${TEST_HOME}"
}

VALID_ROOT="${TEST_HOME}/valid-root"
make_valid_phase0_root "${VALID_ROOT}"
run_validation "${VALID_ROOT}" >"${TEST_HOME}/valid.stdout" \
    2>"${TEST_HOME}/valid.stderr"
grep -q '^VALID_ROOT_FOR_SCRIPT_02=' "${TEST_HOME}/valid.stdout"

ARBITRARY_ROOT="${TEST_HOME}/arbitrary-root"
mkdir "${ARBITRARY_ROOT}"
if run_validation "${ARBITRARY_ROOT}" >"${TEST_HOME}/arbitrary.stdout" \
    2>"${TEST_HOME}/arbitrary.stderr"; then
    printf 'script 02 accepted an arbitrary existing root\n' >&2
    exit 1
fi
grep -q 'required record is missing' "${TEST_HOME}/arbitrary.stderr"

WORKTREE_CONFLICT_ROOT="${TEST_HOME}/worktree-conflict-root"
make_valid_phase0_root "${WORKTREE_CONFLICT_ROOT}"
mkdir "${WORKTREE_CONFLICT_ROOT}/worktrees"
if run_validation "${WORKTREE_CONFLICT_ROOT}" \
    >"${TEST_HOME}/worktree-conflict.stdout" \
    2>"${TEST_HOME}/worktree-conflict.stderr"; then
    printf 'script 02 accepted prior worktree state\n' >&2
    exit 1
fi
grep -q 'conflicting prior script-02 state' \
    "${TEST_HOME}/worktree-conflict.stderr"

RECEIPT_CONFLICT_ROOT="${TEST_HOME}/receipt-conflict-root"
make_valid_phase0_root "${RECEIPT_CONFLICT_ROOT}"
printf 'partial\n' >"${RECEIPT_CONFLICT_ROOT}/locked_worktrees.tsv"
if run_validation "${RECEIPT_CONFLICT_ROOT}" \
    >"${TEST_HOME}/receipt-conflict.stdout" \
    2>"${TEST_HOME}/receipt-conflict.stderr"; then
    printf 'script 02 accepted prior receipt state\n' >&2
    exit 1
fi
grep -q 'conflicting prior script-02 state' \
    "${TEST_HOME}/receipt-conflict.stderr"

if (new_directory_only "${VALID_ROOT}") >/dev/null 2>&1; then
    printf 'negative control unexpectedly accepted a preexisting Phase 0 root\n' >&2
    exit 1
fi

printf 'valid_phase0_root_accepted=PASS\n'
printf 'arbitrary_existing_root_rejected=PASS\n'
printf 'prior_worktree_state_rejected=PASS\n'
printf 'prior_receipt_state_rejected=PASS\n'
printf 'old_nonexistent_root_contract_negative_control=PASS\n'
