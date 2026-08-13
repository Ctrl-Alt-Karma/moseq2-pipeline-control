# Repair Round 2 — Verification-Only Addendum

Date: 2026-07-29

Scope remained narrow: verify F-02, F-04, and F-08, reconcile the reported
extract/viz counts, and execute the actual extract-writer-to-viz-reader
provenance chain. No production source changed.

## Outcome

- Seven locked-head cross-repository checks passed.
- The actual chain reached the real extract writer in the round-2 environment
  and failed because NumPy 2.5.1 removed `np.string_`.
- The unchanged chain passed in an isolated NumPy 1.26.4/h5py 3.11.0
  environment. It accepted identical records and rejected both a policy
  mismatch and corrupt provenance.
- The reported extract count was 3 explicitly selected nodes out of 11 in the
  file. The full file later produced 10 passed and 1 environment/test-setup
  failure.
- The reported viz count was 43 provenance nodes plus 18 explicitly selected
  scalar nodes, or 61 out of 76. The full two-file run produced 65 passed and
  11 failed: 9 absent-fixture blocks and 2 current-`cytoolz` compatibility
  failures.

## External-verifier status

- F-02: IMPLEMENTED, EXTERNAL VERIFICATION PENDING
- F-04: IMPLEMENTED, EXTERNAL VERIFICATION PENDING
- F-08: IMPLEMENTED, EXTERNAL VERIFICATION PENDING

The private verifier packet is under
`evidence/verifier_packets/round2_verification_addendum/`.
