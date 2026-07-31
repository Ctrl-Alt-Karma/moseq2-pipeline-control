#!/usr/bin/env bash

# Inspection-only. Initializes one controlled validation root and freezes
# environment/source/custody evidence without changing installed packages.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash 01_freeze_legacy_environment.sh \
    --root /home/ajm/NEW-validation-root \
    [--project-root /bounded/project/root] \
    --configuration-file /exact/load-bearing/config.yaml \
      [--configuration-file /another/load-bearing/config.yaml] \
    [--classifier-file /exact/load-bearing/flip-classifier.pkl] \
    [--vanilla-root /bounded/vanilla/reference/root] \
    [--fork-release-root /bounded/fork-release/reference/root] \
    [--candidate-root /bounded/candidate/reference/root]

--root is required, must be below /home/ajm, and must not already exist.
Script 01 initializes the reusable packet root, writes a versioned marker, and
creates evidence/environment_freeze below it.

The three optional reference roots must each contain the relevant moseq2_*
package trees. Installed source is compared by deterministic per-file hashes,
never by package version labels. Omitting or supplying an unreadable reference
class leaves source classification UNRESOLVED.

--project-root adds one explicit, bounded project directory to classifier and
configuration discovery. At least one --configuration-file is required so a
bounded search cannot masquerade as load-bearing configuration custody. No
broad home-directory scan is performed.
EOF
}

ROOT=""
PROJECT_ROOT=""
VANILLA_ROOT=""
FORK_RELEASE_ROOT=""
CANDIDATE_ROOT=""
CONFIGURATION_FILES=()
CLASSIFIER_FILES=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --project-root) PROJECT_ROOT="${2:?missing --project-root value}"; shift 2 ;;
        --vanilla-root) VANILLA_ROOT="${2:?missing --vanilla-root value}"; shift 2 ;;
        --fork-release-root) FORK_RELEASE_ROOT="${2:?missing --fork-release-root value}"; shift 2 ;;
        --candidate-root) CANDIDATE_ROOT="${2:?missing --candidate-root value}"; shift 2 ;;
        --configuration-file)
            CONFIGURATION_FILES+=("${2:?missing --configuration-file value}")
            shift 2
            ;;
        --classifier-file)
            CLASSIFIER_FILES+=("${2:?missing --classifier-file value}")
            shift 2
            ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${ROOT}" ]] || die "--root is required"
[[ "${#CONFIGURATION_FILES[@]}" -gt 0 ]] || {
    die "at least one --configuration-file is required"
}
for reference_root in \
    "${PROJECT_ROOT}" \
    "${VANILLA_ROOT}" \
    "${FORK_RELEASE_ROOT}" \
    "${CANDIDATE_ROOT}"; do
    if [[ -n "${reference_root}" ]]; then
        [[ -d "${reference_root}" ]] || {
            die "bounded reference root does not exist: ${reference_root}"
        }
    fi
done
for configuration_file in "${CONFIGURATION_FILES[@]}"; do
    [[ -f "${configuration_file}" ]] || {
        die "load-bearing configuration is missing: ${configuration_file}"
    }
done
for classifier_file in "${CLASSIFIER_FILES[@]}"; do
    [[ -f "${classifier_file}" ]] || {
        die "explicit classifier is missing: ${classifier_file}"
    }
done

export PYTHONDONTWRITEBYTECODE=1
initialize_validation_root "${ROOT}" "${SCRIPT_DIR}/SHA256SUMS.txt" >/dev/null
ROOT="$(cd "${ROOT}" && pwd)"
OUTPUT="${ROOT}/evidence/environment_freeze"
new_directory_only "${OUTPUT}"
mkdir -p "${OUTPUT}/commands" "${OUTPUT}/sitecustomize"

activate_legacy_environment
require_command conda
require_command python
require_command sha256sum
require_command file
require_command tar
require_command find

COMMAND_FAILURES=()
run_record() {
    local label="$1"
    shift
    local command_file="${OUTPUT}/commands/${label}.command.txt"
    local stdout_file="${OUTPUT}/commands/${label}.stdout.txt"
    local stderr_file="${OUTPUT}/commands/${label}.stderr.txt"
    local exit_file="${OUTPUT}/commands/${label}.exit_code.txt"
    printf '%q ' "$@" >"${command_file}"
    printf '\n' >>"${command_file}"
    set +e
    "$@" >"${stdout_file}" 2>"${stderr_file}"
    local code=$?
    set -e
    printf '%s\n' "${code}" >"${exit_file}"
    if [[ "${code}" -ne 0 ]]; then
        COMMAND_FAILURES+=("${label}:${code}")
    fi
}

write_process_environment "${OUTPUT}/process_environment.txt"

run_record python_version python --version
run_record conda_info conda info --all
run_record conda_list conda list
run_record conda_list_explicit conda list --explicit
run_record conda_env_export conda env export --name "${LEGACY_CONDA_ENV}"
run_record pip_freeze python -m pip freeze --all
run_record pip_list python -m pip list --format=freeze
run_record ffmpeg_version ffmpeg -version
run_record uname uname -a
run_record architecture uname -m
run_record cpu lscpu
run_record os_release cat /etc/os-release

SEARCH_ROOTS=("${CONDA_PREFIX}")
for candidate in \
    "/home/ajm/.config/moseq2" \
    "/home/ajm/moseq2" \
    "/home/ajm/moseq2-project" \
    "/home/ajm/moseq2-analysis"; do
    [[ -d "${candidate}" ]] && SEARCH_ROOTS+=("${candidate}")
done
if [[ -n "${PROJECT_ROOT}" ]]; then
    SEARCH_ROOTS+=("$(cd "${PROJECT_ROOT}" && pwd)")
fi

{
    printf 'search_root\n'
    printf '%s\n' "${SEARCH_ROOTS[@]}"
} >"${OUTPUT}/bounded_search_roots.txt"

INSPECTION_ARGS=(
    --output-dir "${OUTPUT}"
)
for search_root in "${SEARCH_ROOTS[@]}"; do
    INSPECTION_ARGS+=(--search-root "${search_root}")
done
for configuration_file in "${CONFIGURATION_FILES[@]}"; do
    INSPECTION_ARGS+=(
        --configuration-file \
        "$(cd "$(dirname "${configuration_file}")" && pwd)/$(basename "${configuration_file}")"
    )
done
for classifier_file in "${CLASSIFIER_FILES[@]}"; do
    INSPECTION_ARGS+=(
        --classifier-file \
        "$(cd "$(dirname "${classifier_file}")" && pwd)/$(basename "${classifier_file}")"
    )
done
if [[ -n "${VANILLA_ROOT}" ]]; then
    INSPECTION_ARGS+=(--vanilla-root "$(cd "${VANILLA_ROOT}" && pwd)")
fi
if [[ -n "${FORK_RELEASE_ROOT}" ]]; then
    INSPECTION_ARGS+=(--fork-release-root "$(cd "${FORK_RELEASE_ROOT}" && pwd)")
fi
if [[ -n "${CANDIDATE_ROOT}" ]]; then
    INSPECTION_ARGS+=(--candidate-root "$(cd "${CANDIDATE_ROOT}" && pwd)")
fi

python "${SCRIPT_DIR}/helpers/inspect_legacy_environment.py" \
    "${INSPECTION_ARGS[@]}"

python - "${OUTPUT}/active_sitecustomize.json" "${OUTPUT}/sitecustomize" <<'PY'
from __future__ import print_function
import json
import os
import shutil
import sys

record_path, destination = sys.argv[1:]
with open(record_path, "r") as stream:
    record = json.load(stream)
if record.get("status") == "PRESENT_AND_HASHED":
    source = record["path"]
    target = os.path.join(destination, "sitecustomize.py")
    shutil.copy2(source, target)
    with open(os.path.join(destination, "source_path.txt"), "w") as stream:
        stream.write(source + "\n")
PY

if [[ -f "${OUTPUT}/sitecustomize/sitecustomize.py" ]]; then
    tar -czf "${OUTPUT}/active_sitecustomize.tar.gz" \
        -C "${OUTPUT}/sitecustomize" sitecustomize.py source_path.txt
fi

{
    if [[ "${#COMMAND_FAILURES[@]}" -eq 0 ]]; then
        printf 'NONE\n'
    else
        printf '%s\n' "${COMMAND_FAILURES[@]}"
    fi
} >"${OUTPUT}/command_failures.txt"

HELPER_STATUS="$(python - "${OUTPUT}/phase0_evidence_summary.json" <<'PY'
from __future__ import print_function
import json
import sys
with open(sys.argv[1], "r") as stream:
    print(json.load(stream).get("status", "INCOMPLETE"))
PY
)"
PHASE0_STATUS="COMPLETE"
if [[ "${HELPER_STATUS}" != "COMPLETE" || "${#COMMAND_FAILURES[@]}" -ne 0 ]]; then
    PHASE0_STATUS="INCOMPLETE"
fi

{
    printf 'schema=%s\n' "${PHASE0_RECEIPT_SCHEMA}"
    printf 'status=%s\n' "${PHASE0_STATUS}"
    printf 'root=%s\n' "${ROOT}"
    printf 'output=%s\n' "${OUTPUT}"
    printf 'production_environment=%s\n' "${CONDA_PREFIX}"
    printf 'environment_changed=false\n'
    printf 'packages_installed=false\n'
} >"${OUTPUT}/FREEZE_RECEIPT.txt"

(
    cd "${ROOT}"
    {
        printf '%s\0' "${VALIDATION_ROOT_MARKER_NAME}"
        find evidence -type f -print0
    } |
        LC_ALL=C sort -z |
        xargs -0 sha256sum >"${PHASE0_MANIFEST_NAME}"
)
PHASE0_MANIFEST="${ROOT}/${PHASE0_MANIFEST_NAME}"
PHASE0_MANIFEST_HASH="$(sha256sum "${PHASE0_MANIFEST}" | awk '{print $1}')"
{
    printf 'schema=%s\n' "${PHASE0_RECEIPT_SCHEMA}"
    printf 'status=%s\n' "${PHASE0_STATUS}"
    printf 'root=%s\n' "${ROOT}"
    printf 'output=%s\n' "${OUTPUT}"
    printf 'production_environment=%s\n' "${CONDA_PREFIX}"
    printf 'environment_changed=false\n'
    printf 'packages_installed=false\n'
    printf 'phase0_manifest=%s\n' "${PHASE0_MANIFEST}"
    printf 'phase0_manifest_sha256=%s\n' "${PHASE0_MANIFEST_HASH}"
    printf 'installed_source_identity=%s\n' \
        "${OUTPUT}/installed_moseq_source_identity.json"
    printf 'sitecustomize_evidence=%s\n' \
        "${OUTPUT}/active_sitecustomize.json"
    printf 'classifier_custody=%s\n' \
        "${OUTPUT}/classifier_custody.json"
    printf 'configuration_custody=%s\n' \
        "${OUTPUT}/configuration_custody.json"
} >"${ROOT}/${PHASE0_RECEIPT_NAME}"

printf 'Legacy environment evidence written to: %s\n' "${OUTPUT}"
printf 'Reusable validation root: %s\n' "${ROOT}"
printf 'Phase 0 status: %s\n' "${PHASE0_STATUS}"
if [[ "${PHASE0_STATUS}" != "COMPLETE" ]]; then
    printf 'Phase 0 evidence is retained but incomplete; script 02 must refuse it.\n' >&2
    exit 1
fi
