# Fable Verifier Packet — Repair Round 2 Addendum

Date: 2026-07-29

This private packet contains the exact evidence needed to verify F-02, F-04,
and F-08. It is a verification-only addendum. It does not begin another repair
round, modify production code, approve a merge, or claim independent
verification.

## Heads under verification

- control head before this addendum:
  `95ad62120d6ba24f1a27a25fc74f334bee84438c`
- extract candidate:
  `e7f585104ba25b66e5326c88c77a47e33db95635`
- viz candidate:
  `b80192dc20353bf77c36610f315543b57afa908c`
- app candidate:
  `e0b85201226d03e15944473a734f71417698c31e`

All four pull requests were draft and unmerged when this evidence was
collected.

## Results

- seven locked-head cross-repository contract checks: 7 passed;
- actual extract writer to viz reader chain in round-2 NumPy 2.5.1: blocked at
  the legacy writer's removed `np.string_` API;
- unchanged actual-function chain in isolated NumPy 1.26.4/h5py 3.11.0:
  1 passed;
- identical provenance records were accepted;
- a policy mismatch was rejected;
- corrupt provenance was rejected.

No HDF5 provenance record was created directly as a substitute for the extract
writer. The chain test calls `moseq2_extract.util.write_pipeline_provenance` for
every initial record, then uses the real viz reader and consistency gate.

## Contents

- `source/validation/contracts/test_candidate_contract.py`: all seven
  cross-repository contract checks;
- `source/validation/contracts/test_real_provenance_chain.py`: the
  actual-function provenance chain;
- `source/repositories/repos.lock.yaml`: locked candidate SHAs;
- `COMMANDS.md`: exact commands;
- `ENVIRONMENTS.md`: exact runtime versions and command-to-environment mapping;
- `TEST_RECONCILIATION.md`: exact extract and viz count reconciliation;
- `raw/`: complete captured output, including failed and launcher-blocked runs;
- `COLLECTED_TEST_NAMES.txt`: collected test node IDs;
- `TEST_OUTCOMES.tsv`: every collected extract/viz node with focused selection,
  focused result, full-run result, and blocker/failure classification;
- `SHA256SUMS.txt`: SHA-256 for every other file in the packet.

`SHA256SUMS.txt` necessarily excludes itself. The ZIP SHA-256 is reported
alongside the delivered archive.

## Status

F-02, F-04, and F-08 are:

`IMPLEMENTED, EXTERNAL VERIFICATION PENDING`

They remain pending until Fable verifies these exported bytes.
