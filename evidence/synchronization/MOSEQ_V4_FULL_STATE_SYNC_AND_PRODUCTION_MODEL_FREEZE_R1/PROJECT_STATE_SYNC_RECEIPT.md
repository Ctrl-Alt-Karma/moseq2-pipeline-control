# Project State Sync Receipt

Operation: `MOSEQ_V4_FULL_STATE_SYNC_AND_PRODUCTION_MODEL_FREEZE_R1`

## Files updated

| File | Reason |
|---|---|
| `README_START_HERE.md` | Point future operators to the live V4 cockpit and current protocol. |
| `ai/CURRENT_STATE.md` | Replace the stale Phase-2/pilot boundary with the accepted final-kappa, production artifact, open validation gate, and claim limits. |
| `ai/DECISIONS.md` | Preserve D-021 through D-029: final kappa, artifact freeze, corrected transport hash, validation boundary, project lessons, and BRIDGE disposition. |
| `ai/HANDOFF_CURRENT.md` | Create the compact V4-to-V5-ready live handoff and one next operation. |
| `ai/TASK_SPEC.md` | Define—but do not authorize—the bounded read-only R1 pre-seal reacquisition. |
| `ai/OPEN_QUESTIONS.md` | Replace stale pilot questions with the exact eight validation pre-seal bindings. |
| `ai/OPERATING_RULES.md` | Add project-only executable-rule transport, exact set-equality, numeric-rule, OOD, and no-tuning-through-HOLD practices. |
| `ai/REVIEW_LOG.md` | Record final-kappa closeout and the two required Phase A/Phase B lessons. |
| `validation/ACCEPTANCE_CRITERIA.md` | Bind general-use approval to the candidate real-session validation protocol. |

## Files created

| File | Purpose |
|---|---|
| `validation/protocols/REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1.md` | Durable Architect candidate R1 architecture and pre-seal boundary. |
| `evidence/synchronization/MOSEQ_V4_FULL_STATE_SYNC_AND_PRODUCTION_MODEL_FREEZE_R1/REACQUIRED_REPOSITORIES.md` | Repository/remotes/heads/dirty-state handling. |
| `.../PRODUCTION_MODEL_ARTIFACT_DECISION.md` | Exact frozen model and fallback basis. |
| `.../SCIENTIFIC_IDENTITY_VERIFICATION.md` | Read-only primary-byte and manifest checks. |
| `.../BRIDGE_RECONCILIATION_RECEIPT.md` | Live canon commit, classifications, and no-edit result. |
| `.../V5_SUCCESSION_READINESS.md` | Closed/open state, next action, backlog, and retirement boundary. |
| `.../PROJECT_STATE_SYNC_RECEIPT.md` | This change and validation inventory. |

## Required validations

- verify all expected 64-character hashes in durable state;
- reject any surviving 63-character Phase B transport digest;
- verify the selected model path/hash/seed/kappa is identical across current
  state, decisions, handoff, and artifact receipt;
- verify protocol status is always `NOT YET SEALED`;
- verify no wording authorizes validation execution or V4 retirement;
- check Markdown links and trailing whitespace;
- run repository tests/static validators relevant to documentation and existing
  control contracts;
- inspect staged diff and final `git status --short`;
- publish through the existing PR branch and reacquire the remote state.

## Validation results

- `git diff --check`: PASS.
- state literal checks: PASS; all required disposition/boundary tokens present.
- 63-character Phase B transport-digest negative search: PASS; zero matches.
- deployment static validator: PASS, including safe process environment,
  stopped-state backup, reusable-root controls, fabricated mismatch control,
  and confirmation that future bootstrap/golden export did not execute.
- cross-repository contracts plus evidence-identity tests: 16 passed with the
  accepted external pytest 5.4.1 harness and exact locked extract/viz/app
  worktrees; cache and bytecode creation disabled.

The first host-Python attempt did not run because the sandbox has no `python`
executable. A first WSL pytest collection then correctly failed against the
installed vanilla extract package because the locked candidate paths had not
yet been injected. The corrected, repository-contract-complete invocation above
passed 16/16. Neither failed attempt mutated scientific state.

## Mutation audit

Scientific data and sealed evidence were read and hashed only. No model fit,
resume, extension, seed, kappa, PCA operation, scorer, extraction, visualization,
validation-model application, biological analysis, or environment change ran.

The original dirty project checkout and its two untracked entries were not
modified. BRIDGE was read-only and required no canon edit.

Exact commit, push, PR, merge, and final remote identities are authoritative in
the repository Git history and the final operator return after publication; a
commit cannot truthfully contain its own not-yet-created SHA.
