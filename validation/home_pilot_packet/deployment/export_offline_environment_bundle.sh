#!/usr/bin/env bash

# Golden-reference inspection/export only. No package or environment mutation.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../lib/common.sh
source "${PACKET_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash deployment/export_offline_environment_bundle.sh \
    --output /home/ajm/moseq2-deployment-bundle-YYYYMMDD \
    --classifier /exact/path/to/flip_classifier \
    --config /exact/path/to/config.yaml [--config FILE ...] \
    --artifact-allowlist /exact/path/to/reviewed-allowlist.txt \
    --golden-known-answer /exact/path/to/golden-known-answer.json \
    --root /home/ajm/exact-Phase-0-validation-root \
    [--confirm-sitecustomize-absent]

Run only inside Katya's golden-reference Ubuntu 22.04 WSL2 distribution.
The output must be new and below /home/ajm. This script reads the existing
environment and caches; it never installs, upgrades, removes, or edits a
package. It copies only cache artifacts explicitly approved in the allowlist.
An incomplete export is retained with an INCOMPLETE lock and exits nonzero.
EOF
}

OUTPUT=""
CLASSIFIER=""
ALLOWLIST=""
GOLDEN_KNOWN_ANSWER=""
ROOT=""
SITECUSTOMIZE_ABSENT=false
CONFIGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT="${2:?missing --output value}"; shift 2 ;;
        --classifier) CLASSIFIER="${2:?missing --classifier value}"; shift 2 ;;
        --config) CONFIGS+=("${2:?missing --config value}"); shift 2 ;;
        --artifact-allowlist) ALLOWLIST="${2:?missing --artifact-allowlist value}"; shift 2 ;;
        --golden-known-answer) GOLDEN_KNOWN_ANSWER="${2:?missing --golden-known-answer value}"; shift 2 ;;
        --root) ROOT="${2:?missing --root value}"; shift 2 ;;
        --confirm-sitecustomize-absent) SITECUSTOMIZE_ABSENT=true; shift ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${OUTPUT}" ]] || die "--output is required"
[[ -n "${ROOT}" ]] || die "--root is required"
ROOT="$(require_locked_source_complete "${ROOT}")"
[[ -f "${CLASSIFIER}" ]] || die "--classifier must name an existing file"
[[ -f "${ALLOWLIST}" ]] || die "--artifact-allowlist must name an existing file"
[[ -f "${GOLDEN_KNOWN_ANSWER}" ]] || {
    die "--golden-known-answer must name an established golden result"
}
[[ "${#CONFIGS[@]}" -gt 0 ]] || die "at least one --config is required"
for config in "${CONFIGS[@]}"; do
    [[ -f "${config}" ]] || die "configuration file is missing: ${config}"
done

require_under_home_ajm "${OUTPUT}"
require_command git
require_command sha256sum
require_command python
require_command tar
require_command uname

[[ "$(uname -s)" == "Linux" ]] || die "golden export requires Linux under WSL2"
grep -q '^VERSION_ID="22.04"$' /etc/os-release || {
    die "golden export requires Ubuntu 22.04"
}
grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease || {
    die "golden export requires the home WSL2 distribution"
}

activate_legacy_environment
load_locked_source_environment "${ROOT}/locked_source.env"
new_directory_only "${OUTPUT}"
mkdir -p \
    "${OUTPUT}/artifacts/conda" \
    "${OUTPUT}/artifacts/pip" \
    "${OUTPUT}/configurations" \
    "${OUTPUT}/custody" \
    "${OUTPUT}/git-dependencies" \
    "${OUTPUT}/records" \
    "${OUTPUT}/repositories"

PHASE0_OUTPUT="$(record_value "${ROOT}/${PHASE0_RECEIPT_NAME}" output)"
mkdir "${OUTPUT}/golden_environment"
cp -a "${PHASE0_OUTPUT}/." "${OUTPUT}/golden_environment/"

conda list --explicit >"${OUTPUT}/records/conda-explicit.txt"
conda env export --name "${LEGACY_CONDA_ENV}" >"${OUTPUT}/records/environment.yml"
python -m pip freeze --all >"${OUTPUT}/records/pip-freeze.txt"
python -m pip list --format=freeze >"${OUTPUT}/records/pip-list.txt"
conda list --json >"${OUTPUT}/records/conda-list.json"
ffmpeg -version >"${OUTPUT}/records/ffmpeg-version.txt" 2>&1
cp /etc/os-release "${OUTPUT}/records/os-release.txt"
write_process_environment "${OUTPUT}/records/export-process-environment.txt"

classifier_name="flip_classifier_$(sha256sum "${CLASSIFIER}" | awk '{print $1}')"
cp -p "${CLASSIFIER}" "${OUTPUT}/custody/${classifier_name}"
python - "${CLASSIFIER}" "${OUTPUT}/custody/${classifier_name}" \
    "${OUTPUT}/records/classifier.json" <<'PY'
from __future__ import print_function
import hashlib
import json
import os
import sys

source, archived, output = sys.argv[1:]
def digest(path):
    value = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()

record = {
    "status": "RESOLVED",
    "source_path": source,
    "bundle_path": "custody/" + os.path.basename(archived),
    "runtime_environment_variable": "MOSEQ_CLASSIFIER_PATH",
    "sha256": digest(archived),
    "bytes": os.path.getsize(archived),
}
with open(output, "w") as stream:
    json.dump(record, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY

if [[ -f "${OUTPUT}/golden_environment/sitecustomize/sitecustomize.py" ]]; then
    cp -p "${OUTPUT}/golden_environment/sitecustomize/sitecustomize.py" \
        "${OUTPUT}/custody/sitecustomize.py"
elif [[ "${SITECUSTOMIZE_ABSENT}" != true ]]; then
    printf '%s\n' \
        "UNRESOLVED: no active sitecustomize.py was archived and absence was not explicitly confirmed" \
        >"${OUTPUT}/records/sitecustomize-unresolved.txt"
fi

printf 'source_path\tbundle_path\tsha256\tbytes\n' \
    >"${OUTPUT}/records/configurations.tsv"
config_index=0
for config in "${CONFIGS[@]}"; do
    config_index=$((config_index + 1))
    config_hash="$(sha256sum "${config}" | awk '{print $1}')"
    config_name="$(printf '%02d_%s_%s' \
        "${config_index}" "${config_hash}" "$(basename "${config}")")"
    cp -p "${config}" "${OUTPUT}/configurations/${config_name}"
    printf '%s\t%s\t%s\t%s\n' \
        "${config}" "configurations/${config_name}" "${config_hash}" \
        "$(wc -c <"${config}")" >>"${OUTPUT}/records/configurations.tsv"
done
python - "${OUTPUT}/records/configurations.tsv" \
    "${OUTPUT}/records/configurations.json" <<'PY'
from __future__ import print_function
import csv
import json
import sys

source, output = sys.argv[1:]
with open(source, "r") as stream:
    rows = list(csv.DictReader(stream, delimiter="\t"))
record = {"status": "RESOLVED" if rows else "UNRESOLVED", "files": rows}
with open(output, "w") as stream:
    json.dump(record, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY

cp -p "${GOLDEN_KNOWN_ANSWER}" \
    "${OUTPUT}/records/golden-known-answer.json"
python - "${OUTPUT}/records/golden-known-answer.json" <<'PY'
from __future__ import print_function
import json
import sys
with open(sys.argv[1], "r") as stream:
    value = json.load(stream)
if value.get("status") != "GOLDEN_ESTABLISHED":
    raise SystemExit("known-answer record is not GOLDEN_ESTABLISHED")
if value.get("fixture_contract") != "moseq-known-answer-v1":
    raise SystemExit("known-answer fixture contract mismatch")
PY

declare -A REPOSITORY_PATHS=(
    [moseq2-extract]="${MOSEQ2_EXTRACT_REPO}"
    [moseq2-viz]="${MOSEQ2_VIZ_REPO}"
    [moseq2-app]="${MOSEQ2_APP_REPO}"
    [moseq2-pca]="${MOSEQ2_PCA_REPO}"
    [moseq2-model]="${MOSEQ2_MODEL_REPO}"
)
declare -A REPOSITORY_SHAS=(
    [moseq2-extract]="e7f585104ba25b66e5326c88c77a47e33db95635"
    [moseq2-viz]="b80192dc20353bf77c36610f315543b57afa908c"
    [moseq2-app]="e0b85201226d03e15944473a734f71417698c31e"
    [moseq2-pca]="efb6fcfa5d5af5bb4274540c371d0ddf96440b78"
    [moseq2-model]="6e542e3f1db125202d42b59f390c922281e64f39"
)

printf 'repository\tcommit\tbundle_path\tsha256\tbytes\n' \
    >"${OUTPUT}/records/repository-bundles.tsv"
for repository in \
    moseq2-extract moseq2-viz moseq2-app moseq2-pca moseq2-model; do
    source_repo="${REPOSITORY_PATHS[${repository}]}"
    expected="${REPOSITORY_SHAS[${repository}]}"
    [[ "$(git -C "${source_repo}" rev-parse HEAD)" == "${expected}" ]] || {
        die "${repository} is not at locked commit ${expected}"
    }
    [[ -z "$(git -C "${source_repo}" status --porcelain)" ]] || {
        die "${repository} locked worktree is dirty"
    }
    bundle_rel="repositories/${repository}-${expected}.bundle"
    git -C "${source_repo}" bundle create "${OUTPUT}/${bundle_rel}" "${expected}"
    git bundle verify "${OUTPUT}/${bundle_rel}" >/dev/null
    printf '%s\t%s\t%s\t%s\t%s\n' \
        "${repository}" "${expected}" "${bundle_rel}" \
        "$(sha256sum "${OUTPUT}/${bundle_rel}" | awk '{print $1}')" \
        "$(wc -c <"${OUTPUT}/${bundle_rel}")" \
        >>"${OUTPUT}/records/repository-bundles.tsv"
done
python - "${OUTPUT}/records/repository-bundles.tsv" \
    "${OUTPUT}/records/repository-bundles.json" <<'PY'
from __future__ import print_function
import csv
import json
import sys
with open(sys.argv[1], "r") as stream:
    rows = list(csv.DictReader(stream, delimiter="\t"))
record = {}
for row in rows:
    record[row["repository"]] = row
with open(sys.argv[2], "w") as stream:
    json.dump(record, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY

python - \
    "${OUTPUT}/golden_environment/floating_dependency_custody.json" \
    "${OUTPUT}/records/dependency-sources.tsv" <<'PY'
from __future__ import print_function
import json
import os
import re
import sys
with open(sys.argv[1], "r") as stream:
    records = json.load(stream)
with open(sys.argv[2], "w") as stream:
    stream.write("name\tstatus\tcommit\trepository\n")
    for name in ("pyhsmm", "pybasicbayes", "autoregressive"):
        record = records.get(name, {})
        commit = str(record.get("exact_git_sha", "UNRESOLVED"))
        repository = "UNRESOLVED"
        for item in record.get("git_evidence", []):
            if (
                item.get("status") == "RESOLVED"
                and str(item.get("sha", "")).lower() == commit.lower()
                and os.path.isdir(item.get("repository", ""))
            ):
                repository = item["repository"]
                break
        status = "RESOLVED"
        if not re.match(r"^[0-9a-fA-F]{40}$", commit) or repository == "UNRESOLVED":
            status = "UNRESOLVED"
        stream.write("{}\t{}\t{}\t{}\n".format(name, status, commit, repository))
PY

printf 'name\tstatus\tcommit\tbundle_path\tsha256\tbytes\n' \
    >"${OUTPUT}/records/git-dependency-bundles.tsv"
while IFS=$'\t' read -r name status commit repository; do
    [[ "${name}" != "name" ]] || continue
    if [[ "${status}" != "RESOLVED" ]]; then
        printf '%s\tUNRESOLVED\tUNRESOLVED\tUNRESOLVED\tUNRESOLVED\tUNRESOLVED\n' \
            "${name}" >>"${OUTPUT}/records/git-dependency-bundles.tsv"
        continue
    fi
    dependency_bundle_rel="git-dependencies/${name}-${commit}.bundle"
    git -C "${repository}" bundle create \
        "${OUTPUT}/${dependency_bundle_rel}" "${commit}"
    git bundle verify "${OUTPUT}/${dependency_bundle_rel}" >/dev/null
    printf '%s\tRESOLVED\t%s\t%s\t%s\t%s\n' \
        "${name}" "${commit}" "${dependency_bundle_rel}" \
        "$(sha256sum "${OUTPUT}/${dependency_bundle_rel}" | awk '{print $1}')" \
        "$(wc -c <"${OUTPUT}/${dependency_bundle_rel}")" \
        >>"${OUTPUT}/records/git-dependency-bundles.tsv"
done <"${OUTPUT}/records/dependency-sources.tsv"

python - \
    "${OUTPUT}" \
    "${OUTPUT}/golden_environment/python_environment.json" \
    "${OUTPUT}/records/dependency-sources.tsv" \
    "${OUTPUT}/records/golden_runtime.env" \
    "${MOSEQ2_EXTRACT_REPO}" "${MOSEQ2_VIZ_REPO}" "${MOSEQ2_APP_REPO}" \
    "${MOSEQ2_PCA_REPO}" "${MOSEQ2_MODEL_REPO}" <<'PY'
from __future__ import print_function
import csv
import json
import os
import shlex
import sys

(
    bundle, environment_path, dependency_path, output,
    extract, viz, app, pca, model,
) = sys.argv[1:]
with open(environment_path, "r") as stream:
    environment = json.load(stream)
with open(dependency_path, "r") as stream:
    dependencies = {
        row["name"]: row for row in csv.DictReader(stream, delimiter="\t")
    }
classifier = [
    name for name in os.listdir(os.path.join(bundle, "custody"))
    if name.startswith("flip_classifier_")
]
if len(classifier) != 1:
    raise SystemExit("expected exactly one archived classifier")
values = {
    "MOSEQ_DEPLOYMENT_ROOT": bundle,
    "MOSEQ_DEPLOYMENT_BUNDLE": bundle,
    "MOSEQ_DEPLOYMENT_LOCK": os.path.join(bundle, "deployment-lock.json"),
    "MOSEQ_CONDA_ENVIRONMENT": "moseq2-app",
    "MOSEQ_CLASSIFIER_PATH": os.path.join(bundle, "custody", classifier[0]),
    "MOSEQ_CONFIGURATION_ROOT": os.path.join(bundle, "configurations"),
    "MOSEQ2_EXTRACT_REPO": extract,
    "MOSEQ2_VIZ_REPO": viz,
    "MOSEQ2_APP_REPO": app,
    "MOSEQ2_PCA_REPO": pca,
    "MOSEQ2_MODEL_REPO": model,
    "MOSEQ_PYHSMM_REPO": dependencies.get("pyhsmm", {}).get(
        "repository", "UNRESOLVED"
    ),
    "MOSEQ_PYBASICBAYES_REPO": dependencies.get("pybasicbayes", {}).get(
        "repository", "UNRESOLVED"
    ),
    "MOSEQ_AUTOREGRESSIVE_REPO": dependencies.get(
        "autoregressive", {}
    ).get("repository", "UNRESOLVED"),
    "PYTHONPATH": ":".join((extract, viz, app, pca, model)),
}
with open(output, "w") as stream:
    stream.write("# Golden WSL/import runtime; generated without environment mutation.\n")
    for name, value in sorted(values.items()):
        stream.write("export {}={}\n".format(name, shlex.quote(str(value))))
    for name, value in sorted(environment.get("thread_environment", {}).items()):
        if value == "UNSET":
            stream.write("unset {}\n".format(name))
        else:
            stream.write("export {}={}\n".format(name, shlex.quote(str(value))))
PY

PIP_CACHE="$(python -m pip cache dir 2>/dev/null || true)"
CONDA_CACHE="${LEGACY_CONDA_ROOT}/pkgs"
printf 'source_path\tbundle_path\tsha256\tbytes\n' \
    >"${OUTPUT}/records/copied-artifacts.tsv"
while IFS= read -r approved || [[ -n "${approved}" ]]; do
    approved="${approved%$'\r'}"
    [[ -n "${approved}" ]] || continue
    [[ "${approved}" != \#* ]] || continue
    [[ -f "${approved}" ]] || die "approved artifact is missing: ${approved}"
    case "${approved}" in
        "${CONDA_CACHE}"/*) artifact_class="conda" ;;
        "${PIP_CACHE}"/*) artifact_class="pip" ;;
        *) die "approved artifact is outside exact Conda/pip caches: ${approved}" ;;
    esac
    artifact_hash="$(sha256sum "${approved}" | awk '{print $1}')"
    artifact_rel="artifacts/${artifact_class}/${artifact_hash}/$(basename "${approved}")"
    mkdir -p "$(dirname "${OUTPUT}/${artifact_rel}")"
    cp -p "${approved}" "${OUTPUT}/${artifact_rel}"
    printf '%s\t%s\t%s\t%s\n' \
        "${approved}" "${artifact_rel}" "${artifact_hash}" \
        "$(wc -c <"${approved}")" >>"${OUTPUT}/records/copied-artifacts.tsv"
done <"${ALLOWLIST}"

python - \
    "${OUTPUT}/records/conda-explicit.txt" \
    "${OUTPUT}/records/conda-list.json" \
    "${OUTPUT}/records/pip-freeze.txt" \
    "${OUTPUT}/records/copied-artifacts.tsv" \
    "${OUTPUT}/records/git-dependency-bundles.tsv" \
    "${OUTPUT}/records/artifact-report.json" <<'PY'
from __future__ import print_function
import csv
import json
import os
import re
import sys

explicit_path, conda_json, pip_freeze, copied_tsv, deps_tsv, output = sys.argv[1:]
with open(explicit_path, "r") as stream:
    explicit = [
        line.strip() for line in stream
        if line.strip() and not line.startswith("#") and not line.startswith("@")
    ]
with open(conda_json, "r") as stream:
    conda_records = json.load(stream)
conda_names = set(
    re.sub(r"[-_.]+", "-", str(item.get("name", "")).lower())
    for item in conda_records
)
with open(pip_freeze, "r") as stream:
    pip_lines = [
        line.strip() for line in stream
        if line.strip() and not line.startswith("#")
    ]
with open(copied_tsv, "r") as stream:
    copied = list(csv.DictReader(stream, delimiter="\t"))
with open(deps_tsv, "r") as stream:
    dependencies = list(csv.DictReader(stream, delimiter="\t"))

copied_sources = [os.path.basename(item["source_path"]) for item in copied]
missing = []
for url in explicit:
    basename = url.split("#", 1)[0].rsplit("/", 1)[-1]
    if basename not in copied_sources:
        missing.append({"type": "conda_artifact", "required": basename})

for line in pip_lines:
    if "#egg=" in line:
        name = line.split("#egg=", 1)[1].split("&", 1)[0].strip()
    else:
        name = re.split(r"===|==| @ ", line, maxsplit=1)[0].strip()
    normalized = re.sub(r"[-_.]+", "-", name.lower())
    if normalized in (
        "pyhsmm", "pybasicbayes", "autoregressive",
        "moseq2-extract", "moseq2-viz", "moseq2-app",
        "moseq2-pca", "moseq2-model",
    ):
        continue
    if normalized in conda_names:
        continue
    matched = any(
        re.sub(r"[-_.]+", "-", basename.lower()).startswith(normalized + "-")
        for basename in copied_sources
    )
    if not matched:
        missing.append({"type": "pip_artifact", "required": line})

for record in dependencies:
    if record.get("status") != "RESOLVED":
        missing.append(
            {"type": "git_dependency_bundle", "required": record.get("name")}
        )

record = {
    "status": "COMPLETE" if not missing else "INCOMPLETE",
    "copied": copied,
    "missing": missing,
    "legal_review_source": "explicit operator artifact allowlist",
    "automatic_redistribution_claim_made": False,
}
with open(output, "w") as stream:
    json.dump(record, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY

set +e
LOCK_ARGS=(--bundle-root "${OUTPUT}")
if [[ "${SITECUSTOMIZE_ABSENT}" == true ]]; then
    LOCK_ARGS+=(--sitecustomize-absent)
fi
python "${SCRIPT_DIR}/build_deployment_lock.py" "${LOCK_ARGS[@]}"
lock_code=$?
set -e

printf 'output=%s\n' "${OUTPUT}" >"${OUTPUT}/EXPORT_RECEIPT.txt"
printf 'existing_environment_changed=false\n' >>"${OUTPUT}/EXPORT_RECEIPT.txt"
printf 'cache_artifacts_copied_from_reviewed_allowlist_only=true\n' \
    >>"${OUTPUT}/EXPORT_RECEIPT.txt"
printf 'deployment_lock_exit_code=%s\n' "${lock_code}" \
    >>"${OUTPUT}/EXPORT_RECEIPT.txt"

python - "${OUTPUT}" "${OUTPUT}/BYTE_COUNTS.tsv" <<'PY'
from __future__ import print_function
import os
import sys
root, output = sys.argv[1:]
with open(output, "w") as stream:
    stream.write("path\tbytes\n")
    for current, unused, files in os.walk(root):
        for name in sorted(files):
            path = os.path.join(current, name)
            if os.path.abspath(path) == os.path.abspath(output) or name == "SHA256SUMS.txt":
                continue
            stream.write("{}\t{}\n".format(
                os.path.relpath(path, root).replace(os.sep, "/"),
                os.path.getsize(path),
            ))
PY
(
    cd "${OUTPUT}"
    find . -type f ! -name SHA256SUMS.txt -print0 |
        LC_ALL=C sort -z |
        xargs -0 sha256sum >SHA256SUMS.txt
)

if [[ "${lock_code}" -ne 0 ]]; then
    printf 'Offline bundle retained but INCOMPLETE: %s\n' "${OUTPUT}" >&2
    exit "${lock_code}"
fi
archive="${OUTPUT}.tar.gz"
[[ ! -e "${archive}" ]] || die "refusing to overwrite bundle archive: ${archive}"
tar -czf "${archive}" -C "$(dirname "${OUTPUT}")" "$(basename "${OUTPUT}")"
sha256_and_bytes "${archive}" "${archive}.sha256.txt"
printf 'Complete offline deployment directory: %s\n' "${OUTPUT}"
printf 'Complete offline deployment archive: %s\n' "${archive}"
