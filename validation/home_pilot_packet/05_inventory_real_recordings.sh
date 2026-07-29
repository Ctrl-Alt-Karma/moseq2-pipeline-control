#!/usr/bin/env bash

# Inspection-only. Reads a bounded OneDrive data directory and writes manifests
# below /home/ajm. It never invokes a MoSeq processing command.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash 05_inventory_real_recordings.sh [options]

Options:
  --data-root DIR       Explicit actual-depth-data directory under /mnt/c.
  --windows-user NAME   Windows profile name used for bounded OneDrive lookup
                        (default: ajmitchell).
  --root DIR            Validation root under /home/ajm.
  --output DIR          New manifest output directory.
  --hash-max-bytes N    Hash files no larger than N bytes (default: 2147483648).

If --data-root is omitted, only /mnt/c/Users/NAME/OneDrive* is searched, to a
maximum depth of six, for a directory whose name resembles actual depth data.
EOF
}

ROOT="${LEGACY_VALIDATION_ROOT_DEFAULT}"
OUTPUT=""
DATA_ROOT=""
WINDOWS_USER="ajmitchell"
HASH_MAX_BYTES=2147483648
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --data-root) DATA_ROOT="${2:?missing --data-root value}"; shift 2 ;;
        --windows-user) WINDOWS_USER="${2:?missing --windows-user value}"; shift 2 ;;
        --hash-max-bytes) HASH_MAX_BYTES="${2:?missing --hash-max-bytes value}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done
[[ "${HASH_MAX_BYTES}" =~ ^[0-9]+$ ]] || die "--hash-max-bytes must be an integer"
if [[ -z "${OUTPUT}" ]]; then
    OUTPUT="${ROOT}/evidence/recording_inventory_$(timestamp_utc)"
fi
new_directory_only "${OUTPUT}"

if [[ -z "${DATA_ROOT}" ]]; then
    WINDOWS_HOME="/mnt/c/Users/${WINDOWS_USER}"
    [[ -d "${WINDOWS_HOME}" ]] || die "Windows profile is not mounted: ${WINDOWS_HOME}"
    mapfile -d '' ONEDRIVE_ROOTS < <(
        find "${WINDOWS_HOME}" -mindepth 1 -maxdepth 2 -type d \
            -iname 'OneDrive*' -print0
    )
    [[ "${#ONEDRIVE_ROOTS[@]}" -gt 0 ]] || die "no bounded OneDrive root found"
    CANDIDATE_FILE="${OUTPUT}/actual_depth_candidates.txt"
    : >"${CANDIDATE_FILE}"
    for one_drive in "${ONEDRIVE_ROOTS[@]}"; do
        find "${one_drive}" -mindepth 1 -maxdepth 6 -type d \
            \( -iname '*actual*depth*data*' -o -iname '*actual-depth-data*' \) \
            -print >>"${CANDIDATE_FILE}"
    done
    mapfile -t CANDIDATES < <(LC_ALL=C sort -u "${CANDIDATE_FILE}")
    if [[ "${#CANDIDATES[@]}" -ne 1 ]]; then
        printf 'Expected exactly one actual-depth-data directory; found %s.\n' \
            "${#CANDIDATES[@]}" >&2
        printf '%s\n' "${CANDIDATES[@]}" >&2
        die "rerun with an explicit --data-root"
    fi
    DATA_ROOT="${CANDIDATES[0]}"
fi

DATA_ROOT="$(cd "${DATA_ROOT}" && pwd)"
case "${DATA_ROOT}" in
    /mnt/c/*) ;;
    *) die "real recording inventory is restricted to read-only /mnt/c paths" ;;
esac

write_process_environment "${OUTPUT}/process_environment.txt"
{
    printf 'python %q --data-root %q --output-dir %q --hash-max-bytes %q\n' \
        "${SCRIPT_DIR}/helpers/inventory_recordings.py" \
        "${DATA_ROOT}" "${OUTPUT}" "${HASH_MAX_BYTES}"
} >"${OUTPUT}/command.txt"

python "${SCRIPT_DIR}/helpers/inventory_recordings.py" \
    --data-root "${DATA_ROOT}" \
    --output-dir "${OUTPUT}" \
    --hash-max-bytes "${HASH_MAX_BYTES}" \
    >"${OUTPUT}/stdout.txt" \
    2>"${OUTPUT}/stderr.txt"
printf '0\n' >"${OUTPUT}/exit_code.txt"

printf 'Read-only recording inventory written to: %s\n' "${OUTPUT}"
