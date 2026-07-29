"""Executable contracts across the three candidate repositories.

The checks deliberately fail when a sibling checkout is absent or is not at the
SHA locked by this repository. Cross-repository validation must not silently
turn into a single-repository unit test.
"""

import ast
import os
from pathlib import Path
import re
import shutil
import subprocess

import numpy as np


CONTROL_ROOT = Path(__file__).resolve().parents[2]
LOCK_PATH = CONTROL_ROOT / "repositories" / "repos.lock.yaml"
REPOSITORIES = {
    "moseq2-extract": "MOSEQ2_EXTRACT_REPO",
    "moseq2-viz": "MOSEQ2_VIZ_REPO",
    "moseq2-app": "MOSEQ2_APP_REPO",
}


def _repository_path(name):
    configured = os.environ.get(REPOSITORIES[name])
    path = Path(configured).resolve() if configured else CONTROL_ROOT.parent / name
    assert path.is_dir(), (
        "{} checkout is required at {} (or set {})".format(
            name, path, REPOSITORIES[name]
        )
    )
    return path


def _locked_candidate_sha(name):
    text = LOCK_PATH.read_text(encoding="utf-8")
    candidate = text.split("  candidate_drafts:", 1)[1]
    marker = "      {}:".format(name)
    assert marker in candidate, "{} is absent from candidate_drafts".format(name)
    block = candidate.split(marker, 1)[1]
    next_repo = re.search(r"^      moseq2-[a-z]+:", block, re.MULTILINE)
    if next_repo:
        block = block[:next_repo.start()]
    match = re.search(r'^\s+sha: "([0-9a-f]{40})"$', block, re.MULTILINE)
    assert match, "candidate SHA is absent or malformed for {}".format(name)
    return match.group(1)


def _git_executable():
    configured = os.environ.get("GIT_EXE")
    executable = configured or shutil.which("git")
    assert executable, "git is required (or set GIT_EXE)"
    return executable


def _head(path):
    return subprocess.check_output(
        [_git_executable(), "-C", str(path), "rev-parse", "HEAD"],
        text=True,
    ).strip()


def _assignments(path):
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    values = {}
    for node in tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1:
            target = node.targets[0]
            if isinstance(target, ast.Name):
                values[target.id] = node.value
    return values


def _static_value(path, name, cache=None):
    cache = {} if cache is None else cache
    if name in cache:
        return cache[name]
    nodes = _assignments(path)
    assert name in nodes, "{} is not assigned in {}".format(name, path)

    def evaluate(node):
        try:
            return ast.literal_eval(node)
        except (TypeError, ValueError):
            pass
        if isinstance(node, ast.BinOp) and isinstance(node.op, ast.Add):
            return evaluate(node.left) + evaluate(node.right)
        if isinstance(node, ast.Name):
            return _static_value(path, node.id, cache)
        raise AssertionError(
            "{} in {} is not a static contract value".format(name, path)
        )

    cache[name] = evaluate(nodes[name])
    return cache[name]


def _function(path, name):
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    functions = [
        node for node in tree.body
        if isinstance(node, ast.FunctionDef) and node.name == name
    ]
    assert len(functions) == 1, "expected exactly one {} in {}".format(name, path)
    module = ast.Module(body=functions, type_ignores=[])
    namespace = {"np": np}
    exec(compile(module, str(path), "exec"), namespace)
    return namespace[name]


def test_checkouts_match_locked_candidate_shas():
    for name in REPOSITORIES:
        assert _head(_repository_path(name)) == _locked_candidate_sha(name)


def test_extract_policy_keys_match_viz_pooling_contract():
    extract_util = _repository_path("moseq2-extract") / "moseq2_extract" / "util.py"
    viz_util = _repository_path("moseq2-viz") / "moseq2_viz" / "util.py"
    extract_policies = _static_value(extract_util, "EXTRACT_OUTPUT_POLICIES")
    viz_policies = _static_value(viz_util, "EXTRACTION_POOLING_POLICIES")
    assert tuple(extract_policies) == tuple(viz_policies)


def test_pixel_conversion_agrees_for_float_and_integer_inputs():
    extract_util = _repository_path("moseq2-extract") / "moseq2_extract" / "util.py"
    viz_scalars = (
        _repository_path("moseq2-viz")
        / "moseq2_viz"
        / "scalars"
        / "util.py"
    )
    extract_convert = _function(extract_util, "convert_pxs_to_mm")
    viz_convert = _function(viz_scalars, "convert_pxs_to_mm")
    for coordinates in (
        np.asarray([[0.0, 0.0], [256.0, 212.0], [511.0, 423.0]]),
        np.asarray([[0, 0], [256, 212], [511, 423]], dtype=np.int64),
    ):
        extract_result = extract_convert(coordinates)
        viz_result = viz_convert(coordinates)
        assert extract_result.dtype == np.float64
        assert viz_result.dtype == np.float64
        np.testing.assert_allclose(extract_result, viz_result, rtol=0, atol=1e-12)


def test_provenance_and_flip_paths_are_one_cross_repo_contract():
    viz_util = _repository_path("moseq2-viz") / "moseq2_viz" / "util.py"
    app_widget = (
        _repository_path("moseq2-app")
        / "moseq2_app"
        / "flip"
        / "widget.py"
    )
    provenance_paths = _static_value(viz_util, "PIPELINE_PROVENANCE_PATHS")
    assert provenance_paths == _static_value(
        app_widget, "EXTRACTION_PROVENANCE_PATHS"
    )
    assert provenance_paths[0] == "metadata/extraction/pipeline"

    viz_flip_paths = _static_value(viz_util, "FLIP_RECORD_PATHS")
    app_flip_paths = (
        _static_value(app_widget, "FLIP_RECORD_PATH"),
        _static_value(app_widget, "FLIP_RECORD_JOURNAL_PATH"),
    )
    assert viz_flip_paths == app_flip_paths
    assert _static_value(
        app_widget, "EXTRACTION_FLIPS_PATH"
    ) == "metadata/extraction/flips"
    assert "flip_correction" in _static_value(
        viz_util, "SCALAR_POOLING_POLICIES"
    )


def test_invalid_extract_outputs_match_viz_deprecations():
    extract_util = _repository_path("moseq2-extract") / "moseq2_extract" / "util.py"
    viz_util = _repository_path("moseq2-viz") / "moseq2_viz" / "util.py"
    policies = _static_value(extract_util, "EXTRACT_OUTPUT_POLICIES")
    invalid_outputs = {
        name for name, policy in policies.items()
        if str(policy).startswith("invalid-")
    }
    deprecated = set(_static_value(viz_util, "DEPRECATED_SCALARS"))
    assert invalid_outputs == deprecated
