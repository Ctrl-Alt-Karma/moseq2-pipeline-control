# Open Questions

Date: 2026-08-17

These questions are exactly the pre-result bindings that keep
`REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1` from being sealed. They must
be answered without opening validation-model outputs.

## Status rule (project-only)

A status here may not move to `CLOSED` unless the same documentary change links
the exact closing primary artifact. Where the artifact is not reachable from this
public repository, the row records the local path, SHA-256, the narrow claim it
establishes, and the access limitation. A summary, handoff, or chat assertion
cannot close a row. See `ai/OPERATING_RULES.md` rule 40.

Claim classes: `MECHANICALLY_VERIFIED` (checked against the artifact),
`BUILDER_REPORTED` (artifact records a Builder claim not independently
reproduced here), `INDEPENDENTLY_VERIFIED`, `ARCHITECT_ADJUDICATED`,
`UNRESOLVED`.

## Reconciliation basis

Statuses below were reconciled on 2026-08-17 against local primary evidence on
the golden host under the operation
`V5_R1_PRESEAL_EVIDENCE_RECONCILIATION_AND_ARCHITECT_RETIREMENT_SYNC_R1`.
Independent Scientific Counsel (`FABLE_COUNSEL_HOLD_R1_PRESEAL_RECONSTRUCTION`,
see `ai/reviews/FABLE_COUNSEL_2026-08-17_R1_PRESEAL_RECONSTRUCTION.md`) reviewed
the repository only and did not have access to `/home/ajm`. Counsel's inability
to see local evidence is not evidence that work did not occur; equally, prior
chat assertion is not evidence that it did. Every row below cites an artifact or
records an absence.

| ID | Question | Status | Claim class | Closing or blocking evidence |
|---|---|---|---|---|
| OQ-V4-001 | What is the exact 20-UUID fitting-corpus roster and order? | CLOSED | MECHANICALLY_VERIFIED | Order identity `cb1a7b4676c3ee64ad006c26ae19f5a90a84811c7a2955d9c54321564bb046bd`, reproduced from the `keys` sequence of the sealed production-model artifact (`5e10803a…`) and recorded in the Phase A provenance receipts under local root `analysis/locked_k200_500iter_final_kappa_phase_A_seed20260802_20260812_R1` (manifest `53643e27002cc89e2ecbcdaa798dabc60b2ff7b9e62def7d04b5a8b2c100d095`). Corpus PCA `26e30500…`; 20 UUIDs, 539,189 persisted / 539,129 modeled / 60 lag-padding frames. Human-readable roster: local `planning/pca_corpus_inventory_20260802_R1/PCA_CORPUS_INVENTORY.csv`, SHA-256 `293fea78a9328939e0a28a727f7f9db683a5ee0ffe1571023712c270dd1a114b`, 20 data rows; contents not published (contains source acquisition paths). **Caution for successors:** the PCA file's `scores` group listing is name-sorted and hashes to `c2adb111d0432a470595c2a6aa09963b8898667e5e64a4a7765f7159a57a1b0d`; it is not the corpus order and must not be substituted for it. |
| OQ-V4-002 | Which outside-corpus sessions are eligible from metadata and raw QC alone? | OPEN | UNRESOLVED | No outside-corpus inventory artifact exists locally or in this repository. Searched local evidence, analysis, planning and validation roots on 2026-08-17. |
| OQ-V4-003 | Which exact eight-session roster and predetermined replacements satisfy the frozen selection procedure? | PARTIALLY ESTABLISHED | MECHANICALLY_VERIFIED for the roster list; UNRESOLVED for selection basis | An ordered eight-candidate roster with per-session run specs exists locally at `validation/r1_existing_outside_corpus_v5/preexecution_v5_r1/R1_RUN_SPEC_MANIFEST.json` (schema `moseq-r1-run-spec-roster-manifest-v1`), binding R3 branch/commit `59b15ce7…`, R3 packet manifest `3d9c3442…`, eight run-spec SHA-256 values, `scientific_processing_started: false`, status `SEALED_CANDIDATES_PENDING_ARCHITECT_R1_SEAL`. Candidate identifiers, subject metadata and run-spec contents are deliberately not published. **Blocking:** no artifact records the selection strata, predetermined replacements, deliberate stressors, or expected-flag dimensions, so the roster exists without an evidenced selection basis. |
| OQ-V4-004 | Which exact viz/app/source bytes implement the repaired orientation path, and what regression proves the historical 180-degree defect is absent? | OPEN | UNRESOLVED | Locked viz `b80192dc…` and app `e0b85201…` identities are verified clean, but no orientation/asymmetric-fixture regression receipt exists locally or in this repository. Unaccepted candidate heads must stay out of the validation stack. |
| OQ-V4-005 | Which supported PCA/model global QC statistics are load-bearing? | OPEN | UNRESOLVED | No load-bearing statistics battery is frozen in any artifact. |
| OQ-V4-006 | What corpus-only Tier-B/Tier-C envelopes and numeric mechanical flag rules will govern validation? | OPEN | UNRESOLVED | No Tier-B or Tier-C formula, envelope value, or flag rule exists in this repository or in any local evidence root. Exhaustive search on 2026-08-17 across all repository refs and all local roots returned zero occurrences of the candidate metric names. See local `analysis/r1_tier_b_numeric_reacquisition_v5_r1/TIER_B_REACQUISITION_HOLD_RECEIPT.json`, SHA-256 `4435968a391c9ee242fa532b168855d8edc128bc1ec17af38d501d0b7b3e50dc`, disposition `HOLD_R1_TIER_B_FORMULA_IDENTITY_UNRESOLVED`. |
| OQ-V4-007 | What exact invalid-input/provenance condition will be the Tier-E negative control? | PARTIALLY ESTABLISHED | MECHANICALLY_VERIFIED for machinery; UNRESOLVED for the named binding | Counsel mechanically established that the R3 operator preflight verifies expected SHA-256 values before any scientific stage, writes a `FAILED_HOLD` receipt with `scientific_processing_started=false`, and exits nonzero, with a gate test covering per-field mismatches. The single frozen condition and its expected behavior are still not named in any sealed artifact. |
| OQ-V4-008 | Which deterministic replay path(s) are materially distinct? | OPEN | UNRESOLVED | The equivalence rule is frozen in the protocol and the operator pins determinism controls, but no artifact binds the replay selection or the materially-distinct-path analysis. |
| OQ-V5-009 | Is the validation roster historical-existing or prospectively acquired, and which design governs? | OPEN | UNRESOLVED | The R3 operator confines staged raw beneath `validation/r1_existing_outside_corpus_v5`, and eight sessions are in fact staged there with all three load-bearing raw files present. No artifact records that the historical archive became available, that a metadata-first inventory was performed, or that the prospective fallback was retired. This fork gates OQ-V4-002, OQ-V4-003 and OQ-V5-010. |
| OQ-V5-010 | What is the custody chain from the source archive to the staged validation raw? | OPEN | UNRESOLVED | Run specs bind per-file SHA-256 for depth, metadata and timestamps at their staged paths, which establishes staged-artifact identity. No local artifact records the source of those bytes, the copy operation, or a source-versus-staged digest comparison, so custody upstream of the staged root is unevidenced. |

Nonblocking later work: golden regression harness, performance profiling,
fixed-reference drift canary, rig substitution plan, and separate anti-aging
study design.
