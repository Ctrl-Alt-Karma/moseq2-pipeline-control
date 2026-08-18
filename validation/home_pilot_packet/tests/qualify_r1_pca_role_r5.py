#!/usr/bin/env python
"""R5 PCA role-correction qualification. Synthetic/provenance only; no candidate science."""
from __future__ import print_function
import hashlib, io, json, os, re, subprocess, sys

import h5py

HERE = os.path.dirname(os.path.abspath(__file__))
PKT = os.path.dirname(HERE)
OPERATOR = os.path.join(PKT, "08_run_r1_full_session_validation.sh")
PREFLIGHT = os.path.join(PKT, "helpers", "verify_r1_full_session_provenance.py")

PCA_BASIS = "/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca.h5"
PCA_BASIS_SHA = "6b587854412c1b0a0b69759f4262e4fac3583b1aa6144093fcd3d2bf1ff0b368"
PCA_SCORES = "/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca_scores.h5"
PCA_SCORES_SHA = "26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912"
R1 = "/home/ajm/moseq2-validation-20260730/validation/r1_existing_outside_corpus_v5"
FROZEN = {
    "config": "ef42bf756eef975277d5dc62d0d7719daf75f374a2e58d96a6c3eb39ecd75269",
    "classifier": "4b06e1e56928bb1ac227329d0932d4637cdd541a3af49865ae127b57991c2c00",
    "production_model": "5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964",
}


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


sys.path.insert(0, os.path.join(PKT, "helpers"))
from verify_r1_full_session_provenance import pca_component_role  # noqa: E402

cases = []


def add(name, ok, detail=None):
    cases.append({"case": name, "result": "PASS" if ok else "FAIL", "detail": detail})


# 1. corrected component-basis hash
add("pca_component_basis_hash", sha(PCA_BASIS) == PCA_BASIS_SHA, PCA_BASIS_SHA)

# 2. semantic role check passes for the component basis
obs, chk = pca_component_role(PCA_BASIS)
add("component_basis_passes_role_check", all(chk.values()),
    {"observed_shape": obs["shape"], "observed_dtype": obs["dtype"], "checks": chk})

# 3. training-score artifact must FAIL the role check
obs_s, chk_s = pca_component_role(PCA_SCORES)
add("training_scores_fail_role_check", not all(chk_s.values()),
    {"readable_hdf5": obs_s["readable_hdf5"], "has_components": obs_s["has_components"],
     "checks": chk_s})
add("training_scores_hash_still_intact", sha(PCA_SCORES) == PCA_SCORES_SHA, PCA_SCORES_SHA)

# 4/5. eight R5 specs bind pca.h5 and differ from R4 only in the PCA binding
r4 = json.load(io.open(R1 + "/preexecution_v5_r1/R1_RUN_SPEC_MANIFEST.json", encoding="utf-8"))
r5 = json.load(io.open(R1 + "/preexecution_v5_r5/R5_RUN_SPEC_MANIFEST.json", encoding="utf-8"))
r4map = {e["roster_index"]: e for e in r4["run_specs"]}


def leaves(o, p=""):
    if isinstance(o, dict):
        for k in sorted(o):
            for r in leaves(o[k], p + "/" + k):
                yield r
    elif isinstance(o, list):
        for i, v in enumerate(o):
            for r in leaves(v, p + "[%d]" % i):
                yield r
    else:
        yield (p, o)


binds = same = 0
for e in sorted(r5["run_specs"], key=lambda x: x["roster_index"]):
    s5 = json.load(io.open(e["path"], encoding="utf-8"))
    s4 = json.load(io.open(r4map[e["roster_index"]]["path"], encoding="utf-8"))
    if s5["scientific_artifacts"]["pca"]["sha256"] == PCA_BASIS_SHA:
        binds += 1
    a, b = dict(leaves(s4)), dict(leaves(s5))
    changed = sorted(k for k in (set(a) & set(b)) if a[k] != b[k])
    if (changed == ["/scientific_artifacts/pca/bytes",
                    "/scientific_artifacts/pca/path",
                    "/scientific_artifacts/pca/sha256"]
            and set(a) == set(b)):
        same += 1
add("all_eight_r5_specs_bind_component_basis", binds == 8, "%d/8" % binds)
add("all_eight_r5_specs_differ_only_in_pca_binding", same == 8, "%d/8" % same)
add("r4_specs_unmutated",
    all(sha(v["path"]) == v["sha256"] for v in r4map.values()), "8/8")

# 6. non-PCA scientific identities unchanged
s0 = json.load(io.open(sorted(r5["run_specs"], key=lambda x: x["roster_index"])[0]["path"], encoding="utf-8"))
ok = all(sha(s0["scientific_artifacts"][k]["path"]) == v for k, v in FROZEN.items())
add("config_classifier_model_identities_unchanged", ok, sorted(FROZEN))
raw_ok = True
for e in sorted(r5["run_specs"], key=lambda x: x["roster_index"]):
    s = json.load(io.open(e["path"], encoding="utf-8"))
    for key in ("depth", "metadata", "timestamps"):
        if sha(s["raw_inputs"][key]["path"]) != s["raw_inputs"][key]["sha256"]:
            raw_ok = False
add("raw_input_identities_unchanged", raw_ok, "24 files across 8 slots")

# 7. no fit/refit route introduced
op = io.open(OPERATOR, encoding="utf-8").read()
# Same predicate the accepted full-operator gate uses, so this qualification
# cannot disagree with the gate. Matching the operator prose that *denies* a fit
# route is a false positive, so only real invocation routes are searched.
forbidden = re.findall(
    r"moseq2-model (?:learn-model|fit-model)|use-checkpoint|resume-model", op)
add("no_fit_refit_resume_adaptation_route", not forbidden, forbidden)

# operator binds the component basis
add("operator_binds_component_basis",
    ('FROZEN_PCA_SHA256="%s"' % PCA_BASIS_SHA) in op, None)
add("operator_records_training_score_role",
    PCA_SCORES_SHA in op and "NOT the runtime input" in op, None)

overall = "PASS" if all(c["result"] == "PASS" for c in cases) else "FAIL"
receipt = {
    "schema": "moseq-r1-r5-pca-role-qualification-v1",
    "classification": "PROVENANCE_ROLE_CORRECTION",
    "status": overall,
    "case_count": len(cases),
    "cases": cases,
    "pca_component_basis_sha256": PCA_BASIS_SHA,
    "pca_training_score_sha256": PCA_SCORES_SHA,
    "candidate_science_executed": False,
    "candidate_result_artifact_opened": False,
    "preflight_sha256": sha(PREFLIGHT),
    "operator_sha256": sha(OPERATOR),
}
out = os.path.join(HERE, "R5_PCA_ROLE_QUALIFICATION_RECEIPT.json")
with io.open(out, "w", encoding="utf-8", newline="\n") as fh:
    fh.write(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
for c in cases:
    print("%-48s %s" % (c["case"], c["result"]))
print("OVERALL:", overall)
sys.exit(0 if overall == "PASS" else 2)
