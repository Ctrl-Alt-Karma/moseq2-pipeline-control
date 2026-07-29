#!/usr/bin/env bash

# Inspection-only. This script never installs, upgrades, removes, or edits a
# package in Katya's production Conda environment.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash 01_freeze_legacy_environment.sh [--output DIR] [--project-root DIR]

--output defaults to a new timestamped directory below
/home/ajm/moseq2-legacy-validation/evidence/.

--project-root adds one explicit, bounded Katya project directory to the
classifier/config inspection. No broad home-directory scan is performed.
EOF
}

OUTPUT=""
PROJECT_ROOT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --project-root) PROJECT_ROOT="${2:?missing --project-root value}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

if [[ -z "${OUTPUT}" ]]; then
    OUTPUT="${LEGACY_VALIDATION_ROOT_DEFAULT}/evidence/environment_$(timestamp_utc)"
fi
new_directory_only "${OUTPUT}"
mkdir -p "${OUTPUT}/commands" "${OUTPUT}/sitecustomize" "${OUTPUT}/classifier"

activate_legacy_environment
require_command conda
require_command python
require_command sha256sum
require_command file
require_command tar

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

python "${SCRIPT_DIR}/helpers/inspect_legacy_environment.py" \
    --output-dir "${OUTPUT}"

python - "${OUTPUT}/active_sitecustomize.json" "${OUTPUT}/sitecustomize" <<'PY'
from __future__ import print_function
import json
import os
import shutil
import sys

record_path, destination = sys.argv[1:]
with open(record_path, "r") as stream:
    record = json.load(stream)
if record.get("status") == "RESOLVED":
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

SEARCH_ROOTS=("${CONDA_PREFIX}")
for candidate in \
    "/home/ajm/.config/moseq2" \
    "/home/ajm/moseq2" \
    "/home/ajm/moseq2-project" \
    "/home/ajm/moseq2-analysis"; do
    [[ -d "${candidate}" ]] && SEARCH_ROOTS+=("${candidate}")
done
if [[ -n "${PROJECT_ROOT}" ]]; then
    [[ -d "${PROJECT_ROOT}" ]] || die "project root does not exist: ${PROJECT_ROOT}"
    SEARCH_ROOTS+=("$(cd "${PROJECT_ROOT}" && pwd)")
fi

{
    printf 'search_root\n'
    printf '%s\n' "${SEARCH_ROOTS[@]}"
} >"${OUTPUT}/classifier/bounded_search_roots.txt"

CLASSIFIER_CANDIDATES="${OUTPUT}/classifier/candidates.nul"
: >"${CLASSIFIER_CANDIDATES}"
for root in "${SEARCH_ROOTS[@]}"; do
    find "${root}" -xdev -maxdepth 7 -type f \
        \( -iname '*flip*classifier*.p' -o \
           -iname '*flip*classifier*.pkl' -o \
           -iname '*flip*classifier*.pickle' -o \
           -iname '*flip*classifier*.joblib' \) \
        -print0 >>"${CLASSIFIER_CANDIDATES}"
done

{
    printf 'path\tsha256\tbytes\tfile_type\n'
    classifier_count=0
    while IFS= read -r -d '' candidate; do
        printf '%s\t%s\t%s\t%s\n' \
            "${candidate}" \
            "$(sha256sum "${candidate}" | awk '{print $1}')" \
            "$(wc -c <"${candidate}")" \
            "$(file -b "${candidate}")"
        classifier_count=$((classifier_count + 1))
    done <"${CLASSIFIER_CANDIDATES}"
    if [[ "${classifier_count}" -eq 0 ]]; then
        printf 'UNRESOLVED\tUNRESOLVED\tUNRESOLVED\tUNRESOLVED\n'
    fi
} >"${OUTPUT}/classifier/classifier_custody.tsv"

{
    for root in "${SEARCH_ROOTS[@]}"; do
        find "${root}" -xdev -maxdepth 6 -type f \
            \( -iname '*.yaml' -o -iname '*.yml' -o -iname '*.json' -o -iname '*.toml' \) \
            -print0
    done
} >"${OUTPUT}/classifier/config_candidates.nul"

: >"${OUTPUT}/classifier/config_references.txt"
while IFS= read -r -d '' config; do
    if grep -EHina 'flip[_ -]?classifier|classifier[_ -]?path' "${config}" \
        >>"${OUTPUT}/classifier/config_references.txt" 2>/dev/null; then
        printf 'CONFIG_FILE=%s\n' "${config}" \
            >>"${OUTPUT}/classifier/config_references.txt"
    fi
done <"${OUTPUT}/classifier/config_candidates.nul"
if [[ ! -s "${OUTPUT}/classifier/config_references.txt" ]]; then
    printf 'UNRESOLVED: no flip-classifier reference found in bounded config roots\n' \
        >"${OUTPUT}/classifier/config_references.txt"
fi

{
    printf 'output=%s\n' "${OUTPUT}"
    printf 'production_environment=%s\n' "${CONDA_PREFIX}"
    printf 'environment_changed=false\n'
    printf 'packages_installed=false\n'
    printf 'broad_filesystem_scan=false\n'
} >"${OUTPUT}/FREEZE_RECEIPT.txt"

printf 'Legacy environment evidence written to: %s\n' "${OUTPUT}"
