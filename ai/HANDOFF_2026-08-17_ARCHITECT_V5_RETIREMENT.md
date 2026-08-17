# Handoff — Architect V5 retirement (2026-08-17)

Immutable. Additive to all prior handoffs. Supersedes `ai/HANDOFF_CURRENT.md` as
the live handoff pointer; does not rewrite it.

## 1. Mission

Determine whether the repaired, frozen MoSeq2 pipeline and the frozen production
model behave as a trustworthy instrument on real recordings outside the fitting
corpus. The gate asks whether the instrument behaves correctly, not whether
expected biology appears. No model fitting occurs on validation sessions.

## 2. Last genuinely closed gate

Final production-kappa selection. Both named seeds independently resolved to
kappa `464159` under the frozen R3 protocol; Architect V4 adjudicated the
selection (D-021, D-022) after independent Fable verification. Local Builder
receipts record `TWO_SEED_CONJUNCTION_SATISFIED_PENDING_ARCHITECT` with
`final_production_kappa_selected: false`; the Architect decision is the layer
that closed it. Both records stand, at their own claim classes.

Also closed on 2026-08-17: OQ-V4-001, the exact 20-UUID fitting-corpus roster and
order, closed against a cited primary artifact.

## 3. Active gate

Real-session production validation, protocol
`REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1`, status **ARCHITECT
CANDIDATE R1 / NOT YET SEALED**.

R1 is **not sealed**. Independent Scientific Counsel returned
`FABLE_COUNSEL_HOLD_R1_PRESEAL_RECONSTRUCTION`. After reconciliation against
local primary evidence, seven of the ten tracked pre-seal rows remain unresolved
or partially established. See `ai/OPEN_QUESTIONS.md` for the row-level state and
the closing or blocking artifact for each.

## 4. Roles

- AJ / Karma: Owner, sole final authority for merge, push, deployment,
  scientific acceptance and scope.
- Architect V5: **RETIRED** by this handoff.
- Successor Architect: not yet established.
- Codex: primary Builder/operator.
- Claude Code: authorized stand-in Builder; executed this reconciliation.
- Fable: independent Verifier or Scientific Counsel only when the active brief
  names the role.

## 5. Current authority

No scientific execution authority is live. No Builder operation is authorized
beyond documentary work already completed. The successor Architect holds no
operational authority until the comprehension handshake in section 13 is
accepted by the Owner.

## 6. Accepted identities needed for continuation

| Item | Identity |
|---|---|
| BRIDGE canon | `Ctrl-Alt-Karma/bridge` main `328c7eee85cf57a5af4211b3d36f5ee7560ebc5d` (unchanged) |
| Accepted R3 branch | `codex/r1-full-session-operator-r3` |
| Accepted R3 commit | `59b15ce796bdda2b1d534fc34cded3e877360cac` |
| R3 packet manifest | `3d9c3442e63453be9b4a74bafeb2ba8ef0d99cfebd86dbb6cedc969fa413895b` |
| moseq2-extract | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| moseq2-pca | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| moseq2-model | `6e542e3f1db125202d42b59f390c922281e64f39` |
| moseq2-viz | `b80192dc20353bf77c36610f315543b57afa908c` |
| moseq2-app | `e0b85201226d03e15944473a734f71417698c31e` |
| pyhsmm | 0.1.6 `4e739166746f92bfc968d281f2c1d31e3471409f` |
| pybasicbayes | 0.2.4 `61f65ad6c781288605ec5f7347efcc5dbd73c4fc` |
| autoregressive | 0.1.2 `2a4c73c08dcda959b9bac2f03a2b976dabbc37af` |
| PCA | `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912` |
| Production model | `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964` |
| Corpus order identity | `cb1a7b4676c3ee64ad006c26ae19f5a90a84811c7a2955d9c54321564bb046bd` |
| Production regime | `max_states=200`, `kappa=464159`, `seed=20260802`, `num_iter=500`, `npcs=10`, `nlags=3`, `whiten=all`, `alpha=5.7`, `gamma=1000`, `ncpus=2`, `percent_split=0`, `noise_level=0` |
| Environment | WSL Ubuntu 22.04, Conda `moseq2-app`, Python 3.7.12, NumPy 1.18.3, Dask 2.30.0 |

All five scientific worktrees and all three external model packages were
re-verified clean and on the identities above on 2026-08-17, both by direct
inspection and against the local receipts `FROZEN_SOURCE_ENVIRONMENT_RECEIPT`
and `GOVERNED_EXTERNAL_DEPENDENCIES_RECEIPT`.

## 7. Smallest authoritative evidence set

1. `ai/OPEN_QUESTIONS.md` — the closure matrix; the successor should re-derive
   gate status from these rows and their linked artifacts, not from prose.
2. `validation/protocols/REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1.md`.
3. `ai/DECISIONS.md` D-001 through D-034.
4. `ai/reviews/FABLE_COUNSEL_2026-08-17_R1_PRESEAL_RECONSTRUCTION.md` and the
   preserved counsel report it cites.
5. Local retirement receipt (path and SHA-256 in section 10).

## 8. Settled decisions

Generic calibration and final-kappa selection are closed and are not reopened
absent contradictory primary evidence (D-021, D-022, D-025). Environment,
deployment and custody decisions D-012 through D-020 stand. Evidence-transport
and validation-discipline rules stand. BRIDGE requires no canon edit (D-029).

## 9. Genuine unresolved items after local reconciliation

- Historical-existing versus prospective validation-roster design (OQ-V5-009).
  This gates the inventory and roster rows.
- Custody chain from source archive to staged validation raw (OQ-V5-010).
- Outside-corpus inventory (OQ-V4-002).
- Roster selection basis, replacements, expected-flag dimensions (OQ-V4-003;
  the roster list itself is bound, its selection basis is not).
- Visualization orientation qualification (OQ-V4-004).
- Load-bearing supported statistics (OQ-V4-005).
- Tier-B and Tier-C formulas, envelopes and mechanical flag rules (OQ-V4-006).
- Tier-E named negative-control binding (OQ-V4-007; machinery established).
- Replay selection and materially-distinct-path analysis (OQ-V4-008).
- External R3 operator qualification receipt and golden-machine gate-test
  outcomes are not attached to this repository.

## 10. Access and capability limits

Fable had repository access only, no `/home/ajm` access, and no commits API.
This repository is public, so candidate identities, subject metadata, raw
manifests, run-spec contents and acquisition paths are deliberately excluded from
it and are cited by local path plus SHA-256 instead. Any successor without golden
host access inherits Fable's limitation and must not treat repository absence as
project absence.

## 11. Retiring-chat condition

- Context condition: **HEAVY**.
- Known context contamination discovered: yes.
- Known unsupported load-bearing assertion: Architect V5 asserted Tier-B numeric
  envelopes were previously reported READY. No such artifact has ever existed.
  The assertion was withdrawn.
- A related assertion that "only one item remains" before seal was also
  unsupported; the reconciled count is seven unresolved or partially established
  rows out of ten.
- The successor must independently reacquire every load-bearing gate status from
  the closure matrix and its linked artifacts, and must treat any inherited
  status absent from that matrix as UNVERIFIED.

## 12. Known limitations and claim boundaries

The accepted kappa claim is that `464159` was selected under the sealed two-seed
protocol on this corpus. It is not a claim of universal seed robustness, unique
optimality, mathematical convergence, or biological validity. K=200 and 500
iterations are working production choices, not convergence proofs. Nothing in
this handoff establishes that the instrument behaves correctly on outside-corpus
recordings; that is exactly what the unsealed gate is for.

## 13. Exactly one next authorized action

**Formal successor Architect comprehension handshake.**

The successor reconstructs mission, authority, frozen state, evidence boundary,
active gate, next authorized action and stop boundary in its own words, derived
from the closure matrix and linked artifacts, and presents it to the Owner. No
other operation is authorized.

## 14. Canon synchronization

BRIDGE is unchanged at `328c7eee85cf57a5af4211b3d36f5ee7560ebc5d`. Retirement
flush classifications:

- evidence before narrative: `ALREADY_CANON`
- repository over chat memory: `ALREADY_CANON`
- successor independent reconstruction: `ALREADY_CANON`
- atomic OQ status plus closing-evidence linkage: `PROJECT_ONLY` for MoSeq,
  implemented as operating rule 40
- phase-scoped shorter cockpit lifetime: `AMBIGUOUS / HELD`
- context-contamination succession trigger: `AMBIGUOUS / HELD`
- persistent-memory disabling as operating mode: `AMBIGUOUS / HELD`

No BRIDGE mutation was authorized or performed.

## 15. Stop boundary

No R1 scientific execution and no Tier-B computation before successor
reconstruction and new-Architect adjudication. The eight staged validation
sessions remain unprocessed; `scientific_processing_started` is `false` in the
sealed run-spec manifest.

## 16. Succession status

**PENDING successor reconstruction.** Architect V5 authority is relinquished by
this handoff. No future scientific Builder prompts are preloaded.
