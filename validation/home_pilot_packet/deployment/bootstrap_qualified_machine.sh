#!/usr/bin/env bash

# Provisions a new isolated candidate environment from a complete offline lock.
# It never mutates an existing environment and never uses floating references.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../lib/common.sh
source "${PACKET_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash deployment/bootstrap_qualified_machine.sh \
    --bundle /home/ajm/exact-offline-bundle \
    --environment-name moseq2-study-qualified-v1 \
    --deployment-root /home/ajm/moseq2-study-qualified-v1 \
    [--conda-executable /home/ajm/miniforge3/bin/conda]

Targets Ubuntu 22.04 or Ubuntu 22.04 under WSL2. The environment name and
deployment root must not already exist. The script runs offline, consumes only
exact artifacts and Git bundles from a COMPLETE deployment lock, and stops on
any missing artifact/build/SHA. Installation alone does not QUALIFY a machine;
preflight and the known-answer qualification must still pass.
EOF
}

BUNDLE=""
ENVIRONMENT_NAME=""
DEPLOYMENT_ROOT=""
CONDA_EXE="/home/ajm/miniforge3/bin/conda"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --bundle) BUNDLE="${2:?missing --bundle value}"; shift 2 ;;
        --environment-name) ENVIRONMENT_NAME="${2:?missing --environment-name value}"; shift 2 ;;
        --deployment-root) DEPLOYMENT_ROOT="${2:?missing --deployment-root value}"; shift 2 ;;
        --conda-executable) CONDA_EXE="${2:?missing --conda-executable value}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -d "${BUNDLE}" ]] || die "--bundle must name an extracted deployment bundle"
[[ "${ENVIRONMENT_NAME}" =~ ^[A-Za-z0-9._-]+$ ]] || {
    die "--environment-name is required and may not contain a path"
}
[[ -n "${DEPLOYMENT_ROOT}" ]] || die "--deployment-root is required"
require_under_home_ajm "${DEPLOYMENT_ROOT}"
[[ ! -e "${DEPLOYMENT_ROOT}" ]] || {
    die "deployment root already exists; refusing overwrite: ${DEPLOYMENT_ROOT}"
}
[[ -x "${CONDA_EXE}" ]] || die "Conda executable is unavailable: ${CONDA_EXE}"
require_command python3
require_command git
require_command sha256sum

grep -q '^ID=ubuntu$' /etc/os-release || die "target must be Ubuntu"
grep -q '^VERSION_ID="22.04"$' /etc/os-release || {
    die "target must be exactly Ubuntu 22.04"
}
[[ -f "${BUNDLE}/deployment-lock.json" ]] || die "deployment-lock.json missing"
[[ -f "${BUNDLE}/SHA256SUMS.txt" ]] || die "bundle SHA256SUMS.txt missing"
(
    cd "${BUNDLE}"
    sha256sum -c SHA256SUMS.txt
)

python3 - "${BUNDLE}/deployment-lock.json" <<'PY'
from __future__ import print_function
import json
import sys
with open(sys.argv[1], "r") as stream:
    lock = json.load(stream)
if lock.get("contract_id") != "moseq2-legacy-study-2026-07-29-v1":
    raise SystemExit("deployment contract mismatch")
if lock.get("status") != "COMPLETE":
    raise SystemExit("deployment lock is not COMPLETE")
if lock.get("unresolved"):
    raise SystemExit("deployment lock contains unresolved requirements")
PY

existing_environments="$("${CONDA_EXE}" env list --json)"
if python3 - "${ENVIRONMENT_NAME}" "${existing_environments}" <<'PY'
from __future__ import print_function
import json
import os
import sys
name = sys.argv[1]
record = json.loads(sys.argv[2])
for path in record.get("envs", []):
    if os.path.basename(path.rstrip(os.sep)) == name:
        raise SystemExit(0)
raise SystemExit(1)
PY
then
    die "Conda environment already exists; refusing modification: ${ENVIRONMENT_NAME}"
fi

mkdir -p "${DEPLOYMENT_ROOT}/bootstrap" "${DEPLOYMENT_ROOT}/worktrees"
python3 - \
    "${BUNDLE}/records/conda-explicit.txt" \
    "${BUNDLE}/records/copied-artifacts.tsv" \
    "${DEPLOYMENT_ROOT}/bootstrap/conda-explicit-offline.txt" <<'PY'
from __future__ import print_function
import csv
import os
import sys

explicit_path, copied_path, output = sys.argv[1:]
with open(copied_path, "r") as stream:
    copied = list(csv.DictReader(stream, delimiter="\t"))
by_name = {
    os.path.basename(item["source_path"]): os.path.abspath(
        os.path.join(os.path.dirname(copied_path), "..", item["bundle_path"])
    )
    for item in copied
}
lines = ["@EXPLICIT"]
with open(explicit_path, "r") as stream:
    for raw in stream:
        line = raw.strip()
        if not line or line.startswith("#") or line == "@EXPLICIT":
            continue
        name = line.split("#", 1)[0].rsplit("/", 1)[-1]
        artifact = by_name.get(name)
        if not artifact or not os.path.isfile(artifact):
            raise SystemExit("missing exact Conda artifact: {}".format(name))
        lines.append("file://" + artifact)
with open(output, "w") as stream:
    stream.write("\n".join(lines) + "\n")
PY

"${CONDA_EXE}" create --yes --offline --name "${ENVIRONMENT_NAME}" \
    --file "${DEPLOYMENT_ROOT}/bootstrap/conda-explicit-offline.txt"

python3 - \
    "${BUNDLE}/records/conda-list.json" \
    "${BUNDLE}/records/pip-freeze.txt" \
    "${BUNDLE}/records/copied-artifacts.tsv" \
    "${DEPLOYMENT_ROOT}/bootstrap/pip-install-plan.txt" <<'PY'
from __future__ import print_function
import csv
import json
import os
import re
import sys

conda_path, freeze_path, copied_path, output = sys.argv[1:]
with open(conda_path, "r") as stream:
    conda = json.load(stream)
conda_names = set(
    re.sub(r"[-_.]+", "-", str(item.get("name", "")).lower()) for item in conda
)
with open(copied_path, "r") as stream:
    copied = list(csv.DictReader(stream, delimiter="\t"))
artifacts = []
for item in copied:
    path = os.path.abspath(
        os.path.join(os.path.dirname(copied_path), "..", item["bundle_path"])
    )
    if "/artifacts/pip/" in path.replace("\\", "/"):
        artifacts.append(path)

plan = []
with open(freeze_path, "r") as stream:
    for raw in stream:
        requirement = raw.strip()
        if not requirement or requirement.startswith("#"):
            continue
        if "#egg=" in requirement:
            name = requirement.split("#egg=", 1)[1].split("&", 1)[0].strip()
        else:
            name = re.split(r"===|==| @ ", requirement, maxsplit=1)[0].strip()
        normalized = re.sub(r"[-_.]+", "-", name.lower())
        if normalized in conda_names:
            continue
        if normalized in (
            "pyhsmm", "pybasicbayes", "autoregressive",
            "moseq2-extract", "moseq2-viz", "moseq2-app",
            "moseq2-pca", "moseq2-model",
        ):
            continue
        matches = [
            path for path in artifacts
            if re.sub(r"[-_.]+", "-", os.path.basename(path).lower()).startswith(
                normalized + "-"
            )
        ]
        if len(matches) != 1:
            raise SystemExit(
                "expected one exact pip artifact for {!r}; found {}".format(
                    requirement, len(matches)
                )
            )
        plan.append(matches[0])
with open(output, "w") as stream:
    for path in plan:
        stream.write(path + "\n")
PY

while IFS= read -r artifact || [[ -n "${artifact}" ]]; do
    [[ -n "${artifact}" ]] || continue
    "${CONDA_EXE}" run --no-capture-output --name "${ENVIRONMENT_NAME}" \
        python -m pip install --no-index --no-deps "${artifact}"
done <"${DEPLOYMENT_ROOT}/bootstrap/pip-install-plan.txt"

python3 - \
    "${BUNDLE}/records/git-dependency-bundles.tsv" \
    "${BUNDLE}" "${DEPLOYMENT_ROOT}/bootstrap/dependency-plan.tsv" <<'PY'
from __future__ import print_function
import csv
import os
import re
import sys
source, bundle, output = sys.argv[1:]
with open(source, "r") as stream:
    rows = list(csv.DictReader(stream, delimiter="\t"))
with open(output, "w") as stream:
    stream.write("name\tcommit\tbundle\n")
    for row in rows:
        commit = row.get("commit", "")
        path = os.path.join(bundle, row.get("bundle_path", ""))
        if row.get("status") != "RESOLVED":
            raise SystemExit("unresolved Git dependency: {}".format(row.get("name")))
        if not re.match(r"^[0-9a-fA-F]{40}$", commit):
            raise SystemExit("non-exact Git dependency SHA")
        if not os.path.isfile(path):
            raise SystemExit("missing Git dependency bundle: {}".format(path))
        stream.write("{}\t{}\t{}\n".format(row["name"], commit.lower(), path))
PY

while IFS=$'\t' read -r name commit dependency_bundle; do
    [[ "${name}" != "name" ]] || continue
    target="${DEPLOYMENT_ROOT}/git-dependencies/${name}"
    mkdir -p "$(dirname "${target}")"
    git clone --no-checkout "${dependency_bundle}" "${target}"
    git -C "${target}" checkout --detach "${commit}"
    [[ "$(git -C "${target}" rev-parse HEAD)" == "${commit}" ]] || {
        die "Git dependency SHA mismatch: ${name}"
    }
    "${CONDA_EXE}" run --no-capture-output --name "${ENVIRONMENT_NAME}" \
        python -m pip install --no-index --no-deps --editable "${target}"
done <"${DEPLOYMENT_ROOT}/bootstrap/dependency-plan.tsv"

python3 - "${BUNDLE}/deployment-lock.json" \
    "${BUNDLE}" "${DEPLOYMENT_ROOT}/bootstrap/repository-plan.tsv" <<'PY'
from __future__ import print_function
import json
import os
import sys
lock_path, bundle, output = sys.argv[1:]
with open(lock_path, "r") as stream:
    repositories = json.load(stream)["repositories"]
with open(output, "w") as stream:
    stream.write("name\tcommit\tbundle\n")
    for name in sorted(repositories):
        record = repositories[name]
        path = os.path.join(bundle, record["bundle"]["path"])
        if record.get("status") != "VERIFIED" or not os.path.isfile(path):
            raise SystemExit("repository bundle is not verified: {}".format(name))
        stream.write("{}\t{}\t{}\n".format(name, record["commit"], path))
PY

while IFS=$'\t' read -r name commit repository_bundle; do
    [[ "${name}" != "name" ]] || continue
    target="${DEPLOYMENT_ROOT}/worktrees/${name}"
    git clone --no-checkout "${repository_bundle}" "${target}"
    git -C "${target}" checkout --detach "${commit}"
    [[ "$(git -C "${target}" rev-parse HEAD)" == "${commit}" ]] || {
        die "repository SHA mismatch: ${name}"
    }
done <"${DEPLOYMENT_ROOT}/bootstrap/repository-plan.tsv"

mkdir -p "${DEPLOYMENT_ROOT}/custody" "${DEPLOYMENT_ROOT}/configurations"
cp -p "${BUNDLE}"/custody/flip_classifier_* "${DEPLOYMENT_ROOT}/custody/"
cp -p "${BUNDLE}"/configurations/* "${DEPLOYMENT_ROOT}/configurations/"

site_status="$(python3 - "${BUNDLE}/deployment-lock.json" <<'PY'
from __future__ import print_function
import json
import sys
with open(sys.argv[1], "r") as stream:
    print(json.load(stream)["sitecustomize"]["status"])
PY
)"
if [[ "${site_status}" == "RESOLVED" ]]; then
    site_packages="$("${CONDA_EXE}" run --name "${ENVIRONMENT_NAME}" python - <<'PY'
import site
print(site.getsitepackages()[0])
PY
)"
    cp -p "${BUNDLE}/custody/sitecustomize.py" "${site_packages}/sitecustomize.py"
elif [[ "${site_status}" != "VERIFIED_ABSENT" ]]; then
    die "sitecustomize custody is neither RESOLVED nor VERIFIED_ABSENT"
fi

classifier_path="$(find "${DEPLOYMENT_ROOT}/custody" -maxdepth 1 -type f \
    -name 'flip_classifier_*' -print -quit)"
[[ -n "${classifier_path}" ]] || die "deployed classifier is missing"

cat >"${DEPLOYMENT_ROOT}/locked_runtime.env" <<EOF
# Generated from the exact offline bundle. Source before qualification.
export MOSEQ_DEPLOYMENT_ROOT='${DEPLOYMENT_ROOT}'
export MOSEQ_DEPLOYMENT_BUNDLE='${BUNDLE}'
export MOSEQ_DEPLOYMENT_LOCK='${BUNDLE}/deployment-lock.json'
export MOSEQ_CONDA_ENVIRONMENT='${ENVIRONMENT_NAME}'
export MOSEQ_CLASSIFIER_PATH='${classifier_path}'
export MOSEQ_CONFIGURATION_ROOT='${DEPLOYMENT_ROOT}/configurations'
export MOSEQ2_APP_REPO='${DEPLOYMENT_ROOT}/worktrees/moseq2-app'
export MOSEQ2_EXTRACT_REPO='${DEPLOYMENT_ROOT}/worktrees/moseq2-extract'
export MOSEQ2_MODEL_REPO='${DEPLOYMENT_ROOT}/worktrees/moseq2-model'
export MOSEQ2_PCA_REPO='${DEPLOYMENT_ROOT}/worktrees/moseq2-pca'
export MOSEQ2_VIZ_REPO='${DEPLOYMENT_ROOT}/worktrees/moseq2-viz'
export MOSEQ_PYHSMM_REPO='${DEPLOYMENT_ROOT}/git-dependencies/pyhsmm'
export MOSEQ_PYBASICBAYES_REPO='${DEPLOYMENT_ROOT}/git-dependencies/pybasicbayes'
export MOSEQ_AUTOREGRESSIVE_REPO='${DEPLOYMENT_ROOT}/git-dependencies/autoregressive'
export PYTHONPATH='${DEPLOYMENT_ROOT}/worktrees/moseq2-extract:${DEPLOYMENT_ROOT}/worktrees/moseq2-viz:${DEPLOYMENT_ROOT}/worktrees/moseq2-app:${DEPLOYMENT_ROOT}/worktrees/moseq2-pca:${DEPLOYMENT_ROOT}/worktrees/moseq2-model'
EOF

python3 - "${BUNDLE}/deployment-lock.json" \
    "${DEPLOYMENT_ROOT}/locked_runtime.env" <<'PY'
from __future__ import print_function
import json
import shlex
import sys
with open(sys.argv[1], "r") as stream:
    values = json.load(stream)["expected_environment"]["thread_environment"]
with open(sys.argv[2], "a") as stream:
    for name, value in sorted(values.items()):
        if value == "UNSET":
            stream.write("unset {}\n".format(name))
        else:
            stream.write("export {}={}\n".format(name, shlex.quote(str(value))))
PY

{
    printf 'status=INSTALLED_UNQUALIFIED\n'
    printf 'contract_id=moseq2-legacy-study-2026-07-29-v1\n'
    printf 'environment=%s\n' "${ENVIRONMENT_NAME}"
    printf 'existing_environment_modified=false\n'
    printf 'network_package_source_used=false\n'
    printf 'next=bash deployment/run_known_answer_qualification.sh\n'
} >"${DEPLOYMENT_ROOT}/INSTALLATION_RECEIPT.txt"

printf 'Installed new isolated environment. Status: INSTALLED_UNQUALIFIED\n'
printf 'Run preflight and known-answer qualification before any real data.\n'
