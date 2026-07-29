"""Actual extract-writer to viz-reader provenance-chain verification."""

import h5py
import pytest

from moseq2_extract.util import (
    EXTRACT_OUTPUT_POLICIES,
    write_pipeline_provenance,
)
from moseq2_viz.util import (
    ProvenanceError,
    SCALAR_POOLING_POLICIES,
    enforce_consistent_provenance,
    read_pipeline_provenance,
)


PROVENANCE_PATH = "metadata/extraction/pipeline"


def _write_with_real_extract_writer(path, policy_override=None):
    original = dict(EXTRACT_OUTPUT_POLICIES)
    try:
        if policy_override is not None:
            EXTRACT_OUTPUT_POLICIES.update(policy_override)
        with h5py.File(str(path), "w") as h5_file:
            write_pipeline_provenance(h5_file)
            assert PROVENANCE_PATH in h5_file
    finally:
        EXTRACT_OUTPUT_POLICIES.clear()
        EXTRACT_OUTPUT_POLICIES.update(original)


def test_real_extract_writer_to_viz_provenance_chain(tmp_path):
    identical_a = tmp_path / "identical-a.h5"
    identical_b = tmp_path / "identical-b.h5"
    mismatch = tmp_path / "mismatch.h5"
    corrupt = tmp_path / "corrupt.h5"

    # The actual extract writer creates every initial provenance record.
    _write_with_real_extract_writer(identical_a)
    _write_with_real_extract_writer(identical_b)

    read_a = read_pipeline_provenance(str(identical_a))
    read_b = read_pipeline_provenance(str(identical_b))
    assert read_a["package"] == "moseq2-extract"
    assert read_a["policies"] == read_b["policies"]
    assert read_a["policies"]["flip_correction"] == "not_applied"
    assert enforce_consistent_provenance(
        [str(identical_a), str(identical_b)],
        required_policies=SCALAR_POOLING_POLICIES,
        context="the actual provenance-chain verification",
    ) is True

    # A real writer call with one changed output policy must be rejected.
    _write_with_real_extract_writer(
        mismatch,
        policy_override={"scalar_px_to_mm": "verification-mismatch"},
    )
    with pytest.raises(ProvenanceError, match="scalar_px_to_mm"):
        enforce_consistent_provenance(
            [str(identical_a), str(mismatch)],
            required_policies=SCALAR_POOLING_POLICIES,
            context="the actual provenance-chain verification",
        )

    # Start with a real writer record, then damage those bytes deliberately to
    # prove the viz reader distinguishes CORRUPT from ABSENT.
    _write_with_real_extract_writer(corrupt)
    with h5py.File(str(corrupt), "a") as h5_file:
        del h5_file[PROVENANCE_PATH]
        h5_file.create_dataset(PROVENANCE_PATH, data=b"{")
    with pytest.raises(ProvenanceError, match="CORRUPT"):
        read_pipeline_provenance(str(corrupt))
