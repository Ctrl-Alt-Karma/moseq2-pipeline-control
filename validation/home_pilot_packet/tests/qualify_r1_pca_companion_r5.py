#!/usr/bin/env python
"""R5 PCA companion-dependency qualification. Non-candidate fixtures only."""
from __future__ import print_function

import hashlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PKT = os.path.dirname(HERE)
OPERATOR = os.path.join(PKT, "08_run_r1_full_session_validation.sh")
PREFLIGHT = os.path.join(PKT, "helpers", "verify_r1_full_session_provenance.py")
PY_BIN = sys.executable

PCA = "/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca.h5"
PCA_SHA = "6b587854412c1b0a0b69759f4262e4fac3583b1aa6144093fcd3d2bf1ff0b368"
YML = "/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca.yaml"
YML_SHA = "ba47df9b1229ab6dae884adf2fab49cfde4a07c5d44575e35547be12277af0d9"
YML_BYTES = 2714
R1 = "/home/ajm/moseq2-validation-20260730/validation/r1_existing_outside_corpus_v5"
FROZEN = {
    "config": "ef42bf756eef975277d5dc62d0d7719daf75f374a2e58d96a6c3eb39ecd75269",
    "classifier": "4b06e1e56928bb1ac227329d0932d4637cdd541a3af49865ae127b57991c2c00",
    "production_model": "5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964",
}


def sha(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


sys.path.insert(0, os.path.join(PKT, "helpers"))
from verify_r1_full_session_provenance import pca_component_role  # noqa: E402

cases = []


def add(name, ok, detail=None):
    cases.append({"case": name, "result": "PASS" if ok else "FAIL", "detail": detail})


add("pca_component_basis_hash", sha(PCA) == PCA_SHA)
observed, role_checks = pca_component_role(PCA)
add("pca_component_role_gate", all(role_checks.values()),
    {"shape": observed["shape"], "dtype": observed["dtype"]})
add("pca_companion_yaml_exists", os.path.isfile(YML))
add("pca_companion_yaml_hash_and_bytes",
    sha(YML) == YML_SHA and os.path.getsize(YML) == YML_BYTES,
    {"sha256": YML_SHA, "bytes": os.path.getsize(YML)})

try:
    from moseq2_pca.helpers.data import get_pca_yaml_data
    use_fft, clean_params, mask_params, missing_data = get_pca_yaml_data(YML)
    add("locked_get_pca_yaml_data_parses_companion",
        isinstance(clean_params, dict) and isinstance(mask_params, dict),
        {"clean_param_keys": sorted(clean_params), "mask_param_keys": sorted(mask_params)})
except Exception as error:
    add("locked_get_pca_yaml_data_parses_companion", False, repr(error))

try:
    get_pca_yaml_data("/tmp/definitely-absent-companion.yaml")
    add("locked_parser_fails_on_missing_companion", False, "returned without error")
except Exception as error:
    add("locked_parser_fails_on_missing_companion", True, type(error).__name__)

op = io.open(OPERATOR, encoding="utf-8").read()
add("operator_binds_companion_sha", ('FROZEN_PCA_YAML_SHA256="%s"' % YML_SHA) in op)
add("operator_requires_companion_present", "companion PCA yaml is missing" in op)
add("operator_passes_companion_to_preflight", '--pca-yaml "${PCA_YAML}"' in op)
add("stage03_uses_verified_original_not_copy",
    '--pca-file "${PCA}"' in op and '--pca-file "${PCA_COPY}"' not in op)
add("immutable_pca_evidence_copy_retained",
    'PCA_COPY="${OUTPUT_REAL}/inputs/pca_components.h5"' in op
    and 'cp --preserve=timestamps "${PCA}" "${PCA_COPY}"' in op)
add("no_pca_yaml_written_into_run_output", "pca_components.yaml" not in op)
add("no_fit_refit_resume_adaptation_route",
    not re.findall(r"moseq2-model (?:learn-model|fit-model)|use-checkpoint|resume-model", op))

man = json.load(io.open(R1 + "/preexecution_v5_r5/R5_RUN_SPEC_MANIFEST.json", encoding="utf-8"))
r4 = json.load(io.open(R1 + "/preexecution_v5_r1/R1_RUN_SPEC_MANIFEST.json", encoding="utf-8"))
r4map = dict((e["roster_index"], e) for e in r4["run_specs"])
binds = same = manifest_ok = 0
for entry in sorted(man["run_specs"], key=lambda x: x["roster_index"]):
    spec = json.load(io.open(entry["path"], encoding="utf-8"))
    art = spec["scientific_artifacts"]
    if (art["pca"]["sha256"] == PCA_SHA and art["pca_yaml"]["sha256"] == YML_SHA
            and art["pca_yaml"]["path"] == YML and art["pca_yaml"]["bytes"] == YML_BYTES):
        binds += 1
    if sha(entry["path"]) == entry["sha256"]:
        manifest_ok += 1
    s4 = json.load(io.open(r4map[entry["roster_index"]]["path"], encoding="utf-8"))
    probe = json.loads(json.dumps(spec))
    del probe["scientific_artifacts"]["pca_yaml"]
    probe["scientific_artifacts"]["pca"] = s4["scientific_artifacts"]["pca"]
    if json.dumps(probe, sort_keys=True) == json.dumps(s4, sort_keys=True):
        same += 1
add("all_eight_bind_identical_pca_and_companion", binds == 8, "%d/8" % binds)
add("all_other_spec_fields_unchanged_vs_r4", same == 8, "%d/8" % same)
add("r5_spec_manifest_hashes_match", manifest_ok == 8, "%d/8" % manifest_ok)
add("r4_specs_unmutated", all(sha(v["path"]) == v["sha256"] for v in r4map.values()))

first = sorted(man["run_specs"], key=lambda x: x["roster_index"])[0]
s0 = json.load(io.open(first["path"], encoding="utf-8"))
add("config_classifier_model_unchanged",
    all(sha(s0["scientific_artifacts"][k]["path"]) == v for k, v in FROZEN.items()))
raw_ok = True
for entry in man["run_specs"]:
    spec = json.load(io.open(entry["path"], encoding="utf-8"))
    for key in ("depth", "metadata", "timestamps"):
        if sha(spec["raw_inputs"][key]["path"]) != spec["raw_inputs"][key]["sha256"]:
            raw_ok = False
add("raw_identities_unchanged", raw_ok)

tmp = tempfile.mkdtemp(prefix="r5-companion-")
try:
    art = s0["scientific_artifacts"]
    receipt_path = os.path.join(tmp, "receipt.json")
    base = [PY_BIN, "-B", PREFLIGHT,
            "--run-spec", first["path"],
            "--staged-root", R1 + "/raw",
            "--depth", s0["raw_inputs"]["depth"]["path"],
            "--metadata", s0["raw_inputs"]["metadata"]["path"],
            "--timestamps", s0["raw_inputs"]["timestamps"]["path"],
            "--config", art["config"]["path"],
            "--classifier", art["classifier"]["path"],
            "--pca", art["pca"]["path"],
            "--model", art["production_model"]["path"],
            "--required-config-sha256", FROZEN["config"],
            "--required-classifier-sha256", FROZEN["classifier"],
            "--required-pca-sha256", PCA_SHA,
            "--required-pca-yaml-sha256", YML_SHA,
            "--required-model-sha256", FROZEN["production_model"],
            "--required-model-seed", "20260802",
            "--required-model-kappa", "464159",
            "--receipt", receipt_path]

    def run(companion):
        if os.path.exists(receipt_path):
            os.remove(receipt_path)
        proc = subprocess.Popen(base + ["--pca-yaml", companion],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        proc.communicate()
        doc = json.load(io.open(receipt_path, encoding="utf-8")) \
            if os.path.exists(receipt_path) else {}
        return proc.returncode, doc.get("status")

    wrong = os.path.join(tmp, "wrong.yaml")
    io.open(wrong, "w", encoding="utf-8").write(u"rank: 25\n")
    rc, st = run(wrong)
    add("wrong_companion_fails_preflight_closed", rc == 42 and st == "FAILED_HOLD",
        {"exit": rc, "status": st})
    rc, st = run("/tmp/definitely-absent-companion.yaml")
    add("missing_companion_fails_preflight_closed", rc == 42 and st == "FAILED_HOLD",
        {"exit": rc, "status": st})
    rc, st = run(YML)
    add("correct_companion_passes_preflight", rc == 0 and st == "PASS",
        {"exit": rc, "status": st})
finally:
    shutil.rmtree(tmp, ignore_errors=True)

overall = "PASS" if all(c["result"] == "PASS" for c in cases) else "FAIL"
receipt = {
    "schema": "moseq-r1-r5-pca-companion-qualification-v1",
    "classification": "RUNTIME_DEPENDENCY_CORRECTION",
    "status": overall,
    "case_count": len(cases),
    "cases": cases,
    "pca_component_basis_sha256": PCA_SHA,
    "pca_companion_yaml_sha256": YML_SHA,
    "pca_companion_yaml_bytes": YML_BYTES,
    "candidate_science_executed": False,
    "candidate_result_artifact_opened": False,
    "operator_sha256": sha(OPERATOR),
    "preflight_sha256": sha(PREFLIGHT),
}
out = os.path.join(HERE, "R5_PCA_COMPANION_QUALIFICATION_RECEIPT.json")
io.open(out, "w", encoding="utf-8", newline="\n").write(
    json.dumps(receipt, indent=2, sort_keys=True) + "\n")
for case in cases:
    print("%-48s %s" % (case["case"], case["result"]))
print("OVERALL:", overall)
sys.exit(0 if overall == "PASS" else 2)
