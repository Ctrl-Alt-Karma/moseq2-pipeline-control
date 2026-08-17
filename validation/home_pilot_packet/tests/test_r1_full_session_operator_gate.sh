#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OPERATOR="${PACKET_ROOT}/08_run_r1_full_session_validation.sh"
STAGED_ROOT=/home/ajm/moseq2-validation-20260730/validation/r1_existing_outside_corpus_v5/raw
RUNS_ROOT=/home/ajm/moseq2-validation-20260730/validation/r1_existing_outside_corpus_v5/runs
QUALIFIER="CID-SYNTHETIC-R3-QUALIFICATION"
SESSION="${STAGED_ROOT}/${QUALIFIER}"
WORK="$(mktemp -d /home/ajm/r1-r3-qualification.XXXXXX)"
OUTSIDE="${WORK}/outside-depth.dat"
FROZEN_CONFIG=/home/ajm/moseq_work/5xfad_exploratory_20/config.yaml
FROZEN_CLASSIFIER=/home/ajm/moseq_work/5xfad_exploratory_20/flip/flip_classifier_k2_c57_10to13weeks.pkl
FROZEN_PCA=/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca_scores.h5
FROZEN_MODEL=/home/ajm/moseq2-validation-20260730/analysis/locked_464159_k200_long_chain_convergence_sentinel_20260812_R1/model/model-k200-kappa464159-seed20260802-iter500.p

cleanup() {
    case "${SESSION}" in "${STAGED_ROOT}"/CID-SYNTHETIC-R3-QUALIFICATION) chmod -R u+w "${SESSION}" 2>/dev/null || true; rm -rf -- "${SESSION}" ;; esac
    case "${STAGED_ROOT}/CID-SYNTHETIC-R3-ESCAPE" in "${STAGED_ROOT}"/CID-SYNTHETIC-R3-ESCAPE) rm -rf -- "${STAGED_ROOT}/CID-SYNTHETIC-R3-ESCAPE" ;; esac
    find "${RUNS_ROOT}" -mindepth 1 -maxdepth 1 -type d -name 'r3-qualification-*' -exec rm -rf -- {} + 2>/dev/null || true
    case "${WORK}" in /home/ajm/r1-r3-qualification.*) rm -rf -- "${WORK}" ;; esac
}
trap cleanup EXIT

mkdir -p "${SESSION}" "${RUNS_ROOT}"
truncate -s $((512 * 424 * 2 * 2)) "${SESSION}/depth.dat"
printf '{"DepthDataType":"UInt16[]","DepthResolution":[512,424],"SessionName":"synthetic_r3_qualification","StartTime":"01/01/2000 00:00:00","SubjectName":"synthetic_0_1_nonbiological"}\n' >"${SESSION}/metadata.json"
printf '0\n1\n' >"${SESSION}/depth_ts.txt"
printf '{"fixture":"frozen_source_environment"}\n' >"${WORK}/source_environment.json"
printf '{"fixture":"governed_external_dependencies"}\n' >"${WORK}/external_dependencies.json"
chmod 444 "${SESSION}/depth.dat" "${SESSION}/metadata.json" "${SESSION}/depth_ts.txt"

PYTHON=/home/ajm/miniforge3/envs/moseq2-app/bin/python
BASE_SPEC="${WORK}/base.json"
PYTHONDONTWRITEBYTECODE=1 "${PYTHON}" -B - "${BASE_SPEC}" "${SESSION}" "${WORK}" "${FROZEN_CONFIG}" "${FROZEN_CLASSIFIER}" "${FROZEN_PCA}" "${FROZEN_MODEL}" <<'PY'
import hashlib
import json
import os
import sys

output, session, work, config, classifier, pca, model = sys.argv[1:]
def item(path):
    data = open(path, "rb").read()
    return {"path": os.path.realpath(path), "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}
spec = {
    "schema": "moseq2-r1-real-session-run-spec-v2",
    "candidate_identity_id": "CID-SYNTHETIC-R3-QUALIFICATION",
    "identity": {"subject_name": "synthetic_0_1_nonbiological", "session_name": "synthetic_r3_qualification", "rig": 1, "acquisition_start": "01/01/2000 00:00:00"},
    "raw_inputs": {"depth": item(os.path.join(session, "depth.dat")), "metadata": item(os.path.join(session, "metadata.json")), "timestamps": dict(item(os.path.join(session, "depth_ts.txt")), rows=2)},
    "scientific_artifacts": {"config": item(config), "classifier": item(classifier), "pca": item(pca), "production_model": dict(item(model), seed=20260802, kappa=464159)},
    "environment_receipts": {"frozen_source_environment": item(os.path.join(work, "source_environment.json")), "governed_external_dependencies": item(os.path.join(work, "external_dependencies.json"))},
}
with open(output, "w") as stream:
    json.dump(spec, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY

operator() {
    local spec="$1"
    local recording="$2"
    local output="$3"
    shift 3
    MOSEQ_PACKET_SYNTHETIC_TEST_MODE=1 bash "${OPERATOR}" \
        --run-spec "${spec}" --recording "${recording}" \
        --config "${FROZEN_CONFIG}" --classifier "${FROZEN_CLASSIFIER}" \
        --pca "${FROZEN_PCA}" --production-model "${FROZEN_MODEL}" \
        --confirm RUN_SEALED_R1_FULL_SESSION --output "${output}" "$@"
}

expect_fail() {
    local label="$1"
    shift
    if "$@"; then
        printf '%s unexpectedly passed\n' "${label}" >&2
        exit 1
    fi
    printf '%s=PASS\n' "${label}"
}

POSITIVE_OUTPUT="${RUNS_ROOT}/r3-qualification-positive-$$"
operator "${BASE_SPEC}" "${SESSION}/depth.dat" "${POSITIVE_OUTPUT}" --provenance-preflight-only
grep -q '^status=PASS$' "${POSITIVE_OUTPUT}/R1_FULL_SESSION_PREFLIGHT_ONLY_RECEIPT.txt"
grep -q '^scientific_processing_started=false$' "${POSITIVE_OUTPUT}/R1_FULL_SESSION_PREFLIGHT_ONLY_RECEIPT.txt"
[[ ! -e "${POSITIVE_OUTPUT}/stages" ]]
printf 'approved_staged_root_path_accepted=PASS\n'

# R4: the list-form DepthResolution fixture must traverse raw-frame accounting
# and stop before any candidate science begins.
[[ -f "${POSITIVE_OUTPUT}/inputs/raw_frame_accounting.json" ]]
grep -q '"status": "PASS"' "${POSITIVE_OUTPUT}/inputs/raw_frame_accounting.json"
grep -q '"bytes_per_frame": 434176' "${POSITIVE_OUTPUT}/inputs/raw_frame_accounting.json"
[[ ! -e "${POSITIVE_OUTPUT}/stages" ]]
[[ ! -e "${POSITIVE_OUTPUT}/summaries" ]]
printf 'list_form_resolution_traverses_raw_frame_accounting=PASS\n'

for family in mnt_e mnt_c arbitrary_home; do
    case "${family}" in
        mnt_e) rejected=/mnt/e/nonexistent-r3-qualification/depth.dat ;;
        mnt_c) rejected=/mnt/c/nonexistent-r3-qualification/depth.dat ;;
        arbitrary_home) rejected=/home/ajm/nonexistent-r3-qualification/depth.dat ;;
    esac
    expect_fail "${family}_path_rejected" operator "${BASE_SPEC}" "${rejected}" "${RUNS_ROOT}/r3-qualification-${family}-$$" --provenance-preflight-only
done

printf 'outside\n' >"${OUTSIDE}"
mkdir -p "${STAGED_ROOT}/CID-SYNTHETIC-R3-ESCAPE"
ln -s "${OUTSIDE}" "${STAGED_ROOT}/CID-SYNTHETIC-R3-ESCAPE/depth.dat"
expect_fail symlink_escape_rejected operator "${BASE_SPEC}" "${STAGED_ROOT}/CID-SYNTHETIC-R3-ESCAPE/depth.dat" "${RUNS_ROOT}/r3-qualification-symlink-$$" --provenance-preflight-only

mv "${SESSION}/metadata.json" "${SESSION}/metadata.absent"
expect_fail missing_metadata_rejected operator "${BASE_SPEC}" "${SESSION}/depth.dat" "${RUNS_ROOT}/r3-qualification-missing-metadata-$$" --provenance-preflight-only
mv "${SESSION}/metadata.absent" "${SESSION}/metadata.json"
mv "${SESSION}/depth_ts.txt" "${SESSION}/depth_ts.absent"
expect_fail missing_timestamps_rejected operator "${BASE_SPEC}" "${SESSION}/depth.dat" "${RUNS_ROOT}/r3-qualification-missing-timestamps-$$" --provenance-preflight-only
mv "${SESSION}/depth_ts.absent" "${SESSION}/depth_ts.txt"

make_bad_spec() {
    local field="$1"
    local output="$2"
    PYTHONDONTWRITEBYTECODE=1 "${PYTHON}" -B - "${BASE_SPEC}" "${field}" "${output}" <<'PY'
import json
import sys
source, field, output = sys.argv[1:]
with open(source) as stream:
    spec = json.load(stream)
container, name = field.split(".", 1)
if container == "raw_inputs":
    spec[container][name]["sha256"] = "0" * 64
else:
    spec["scientific_artifacts"][name]["sha256"] = "0" * 64
with open(output, "w") as stream:
    json.dump(spec, stream, indent=2, sort_keys=True)
    stream.write("\n")
PY
}

for field in raw_inputs.depth raw_inputs.metadata raw_inputs.timestamps scientific_artifacts.pca scientific_artifacts.production_model scientific_artifacts.config scientific_artifacts.classifier; do
    safe="${field//./_}"
    bad="${WORK}/bad-${safe}.json"
    make_bad_spec "${field}" "${bad}"
    expect_fail "bad_${safe}_hash_rejected" operator "${bad}" "${SESSION}/depth.dat" "${RUNS_ROOT}/r3-qualification-bad-${safe}-$$" --provenance-preflight-only
done

if grep -nE -- '--num-frames|--frame-range|--start-frame|--stop-frame' "${OPERATOR}"; then
    printf 'full-session operator contains a truncation option\n' >&2
    exit 1
fi
grep -q 'MODEL_SHA_BEFORE' "${OPERATOR}"
grep -q 'MODEL_SHA_AFTER' "${OPERATOR}"
grep -q 'moseq2-model apply-model' "${OPERATOR}"
if grep -nE 'moseq2-model (learn-model|fit-model)|use-checkpoint|resume-model' "${OPERATOR}"; then
    printf 'model fitting/resume route found\n' >&2
    exit 1
fi
grep -q 'require_locked_source_complete' "${OPERATOR}"
grep -q 'load_locked_source_environment' "${OPERATOR}"
grep -q 'verify_r1_runtime_identity.py' "${OPERATOR}"
grep -q 'extraction_time_flip_classifier=true' "${OPERATOR}"
grep -q 'app_level_reflip=false' "${OPERATOR}"

printf 'full_session_has_no_truncation_argument=PASS\n'
printf 'production_model_before_after_immutability=PASS\n'
printf 'no_fit_refit_resume_adaptation_route=PASS\n'
printf 'frozen_pythonpath_worktree_runtime_gate=PASS\n'
printf 'candidate_recording_processed=false\n'
