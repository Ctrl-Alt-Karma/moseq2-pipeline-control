# R1 sealed real-session execution — HOLD (environment contradiction)

Disposition: `HOLD_R1_SEALED_REAL_SESSION_EXECUTION_R1`
Reason: declared executable checkout, validation root, staged raw corpus, frozen
scientific artifacts and MoSeq2 runtime are all absent from the acting environment.

Nothing scientific was started. No validation root was created. No raw input was
staged. Tier-E was not attempted. Primary runs attempted: 0. Candidate files
opened: 0. No result-bearing output was inspected.

## Identity reacquisition — PASS

Verified read-only against the control repository:

| Binding | Declared | Observed |
| --- | --- | --- |
| canonical control main | `91142e4aca3649954ec2efc1230378e9c4156cbd` | HEAD matches |
| accepted R3 operator commit | `59b15ce796bdda2b1d534fc34cded3e877360cac` | present |
| `SHA256SUMS_R3.txt` SHA-256 | `3d9c3442e63453be9b4a74bafeb2ba8ef0d99cfebd86dbb6cedc969fa413895b` | matches |
| manifest member count | 58 | 58 |
| operator Git blob | `715d33777a180e200987a36ba9c48c0c3c43c991` | `08_run_r1_full_session_validation.sh` |
| operator on-disk SHA-256 (LF) | `f01f6c45b1407324e8dcae9542fb7ef3900071d09b47cc9c18124c8cb8325580` | matches its manifest line |

The packet root at `59b15ce7` holds 59 tracked files; excluding `SHA256SUMS_R3.txt`
itself yields exactly 58 manifest members. The stale 47-member expectation is
superseded and is not a defect. Packet materialization did not need redoing.

Seal-bound identities remain intact in `validation/protocols/R1_FINAL_SEAL_R1.json`:
roster receipt `e8526258...`, predetermined replacement receipt `c6f1fd96...`,
run-spec manifest `74febdaa...`, Tier-E machinery receipt `a4c49384...`, production
model `5e10803a...`, PCA `26e30500...`, corpus order `cb1a7b46...`.

## Blocking contradiction

The acting session is an ephemeral remote container, not the operator workstation.

Absent:

- `/home/ajm` (no such user or directory)
- `/home/ajm/moseq2-r1-operator-r3-59b15ce` (declared executable checkout)
- `/home/ajm/moseq2-validation-20260730` (declared existing validation root)
- staged raw corpus `.../r1_existing_outside_corpus_v5/raw/<candidate_identity_id>/`
  (`depth.dat`, `depth_ts.txt`, `metadata.json`)
- frozen scientific artifacts: `config.yaml`, flip classifier, `pca_scores.h5`,
  production model `.p`
- MoSeq2 runtime (`moseq2_extract` not importable; no conda environment)

The frozen operator forecloses any substitution. `08_run_r1_full_session_validation.sh`
calls `require_locked_source_complete "/home/ajm/moseq2-validation-20260730"` at a
literal path, and requires `--recording` to resolve beneath the fixed staged-raw
root as a non-symlink regular file. Satisfying those gates here would mean creating
a validation root and staging inputs that did not come from the frozen corpus —
fabrication of the provenance chain the protocol exists to protect. Held instead.

Resource state of the acting container, recorded operationally only (no
configuration was altered): 15 GiB RAM, 0 B swap, 30 GiB writable, 4 CPUs.

## Secondary observation — authorization scope

`validation/protocols/R1_FINAL_SEAL_R1.json` records
`seal_scope: "documentary. Sealing the protocol does not authorize execution; the
next scientific operation requires separate Architect authorization."`

The token `PASS_ARCHITECT_R3_PACKET_MATERIALIZATION_R1` does not appear anywhere in
this repository, and names packet materialization rather than execution. This is
recorded for adjudication; it is not the blocking cause.

The identifier "Rule 25" is not defined anywhere in this repository, so no
Rule-25-conformant return could be rendered against its actual specification.

## Release condition

Resume requires an acting environment that is the operator workstation itself, with
the existing validation root `/home/ajm/moseq2-validation-20260730` and the executable
checkout `/home/ajm/moseq2-r1-operator-r3-59b15ce` present and verifying at 58/58.
Order on release is unchanged: frozen Tier-E negative control, then the eight frozen
primary sessions sequentially, then deterministic replay of frozen roster position 1,
then the protected execution evidence package, then the sanitized pointer.

No model, PCA, config, classifier, formula, threshold, roster or replacement
ordering was changed.
