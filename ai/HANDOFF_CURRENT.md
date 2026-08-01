# Phase 2 Closeout to Pilot-Preparation Handoff

## Handoff ID

`HANDOFF-2026-08-01-PHASE2-CLOSEOUT-TO-PILOT-PREPARATION`

This is the live control-state pointer and a compact phase delta. Earlier
handoffs and formal run evidence remain immutable audit history.

## Ultimate scientific objective

Produce scientifically defensible MoSeq outputs for Katya's study by running
the repaired, locked candidate source in the exact legacy production
environment, with provenance, flip-state, scalar semantics, and custody strong
enough to prevent silent mixing or reinterpretation.

## Exact current phase

Phase 2 fixture-backed candidate qualification is closed by architect
adjudication. The project is at the clean boundary before preparation of one
bounded real-recording pilot. No pilot design or execution authority exists
yet.

## Proven

- Phase 0 golden-environment freeze and Phase 1 locked-worktree preparation are
  closed with independent Fable `PASS` verdicts.
- The frozen target is WSL2 Ubuntu 22.04, Conda environment `moseq2-app`, Python
  3.7, NumPy 1.18.3, with locked candidate source supplied by `PYTHONPATH`.
- Locked SHAs:
  - extract `e7f585104ba25b66e5326c88c77a47e33db95635`
  - PCA `efb6fcfa5d5af5bb4274540c371d0ddf96440b78`
  - model `6e542e3f1db125202d42b59f390c922281e64f39`
  - viz `b80192dc20353bf77c36610f315543b57afa908c`
  - app `e0b85201226d03e15944473a734f71417698c31e`
- Fixture identities:
  - viz `de6c4d30a67c800888fc27ec395ff8e3821b2903248235c972a63b0e72b27728`
  - extract `21f9dd7a55a44eae329c76ba48686c36cc26dc2da4264d199c7ccd3b7eb370f9`
- The accepted external pytest harness is
  `/home/ajm/moseq2-test-harnesses/pytest541_cov251_20260801_R2`.
- Fixture R1, R2, and R3 remain formally **FAIL CLOSED**. Combined immutable
  evidence proves targeted 10/10 non-vacuously, correct candidate suites
  128/128, and prior cross-repository contracts 7/7.
- Architect adjudication: **SUBSTANTIVE FIXTURE-BACKED CANDIDATE QUALIFICATION
  COMPLETE.** This does not rewrite any formal result.
- R3's ignored app `.coverage` mutation was preserved outside the worktree and
  removed; the protected worktree was touched and then exactly restored.

## Unresolved

- Exact custody of floating Git-installed dependencies.
- Within-environment variability from unseeded PCA.
- Exact active flip-classifier custody where not already conclusively bound.
- Real-recording behavior and the operating policy for unstamped or mixed-policy
  historical data.
- Qualification of any future analysis machine.
- Pilot design, input selection, retention contract, and approval.

## Roles and capabilities

- **AJ:** project owner, final approval, sole merge authority.
- **Hex:** architect, conductor, and reconciler; normally no live workstation
  access.
- **Codex:** builder/operator; local access only within AJ's explicit boundary.
- **Fable:** independent attachment-only verifier; no live workstation access.

Presentation follows `ai/ARCHITECT_INTERACTION_GUIDE.md`. That style guide does
not weaken skepticism, evidence standards, technical reasoning, uncertainty,
independence, or disagreement.

## Critical artifacts

```text
Control closeout:
  ai/PHASE2_FIXTURE_QUALIFICATION_CLOSEOUT_2026-08-01.md
Phase 1 closeout:
  ai/PHASE1_CLOSEOUT_2026-08-01.md
Operating canon:
  ai/OPERATING_RULES.md
Phase 0/1 validation root:
  /home/ajm/moseq2-validation-20260730
R3 evidence:
  /home/ajm/moseq2-validation-20260730/evidence/fixture_backed_validation_20260801_R3
Closeout and coverage preservation:
  /home/ajm/moseq2-validation-20260730/evidence/fixture_qualification_closeout_20260801
Accepted harness:
  /home/ajm/moseq2-test-harnesses/pytest541_cov251_20260801_R2
Audited packet:
  C:\deployment\MoSeq2-Pilot-Reusable-Root-Corrected-2026-07-30\Extracted-20260801T011401Z\MOSEQ_LEGACY_HOME_PILOT_REUSABLE_ROOT_CORRECTED_2026-07-30
```

## Prohibitions

- Do not run pytest, script 03, script 04, any packet step, scientific command,
  or real-data operation.
- Do not install, remove, upgrade, downgrade, or repair packages.
- Do not modify the golden environment, candidate repositories, fixtures,
  immutable evidence, or scientific data.
- Do not merge or mark a draft PR ready. AJ alone may authorize and perform a
  merge.
- Do not design or authorize the real-recording pilot during the comprehension
  check.

## One next authorized action

Conduct a **read-only new-architect comprehension check**. The new architect
must restate the following from this handoff:

1. The scientific goal.
2. The exact current phase.
3. The frozen environment and all five candidate identities.
4. The latest immutable evidence, formal R1/R2/R3 results, and separate
   architect adjudication.
5. The unresolved scientific and custody risks.
6. Agent roles, capabilities, and access limits.
7. This one next authorized action.
8. Every prohibited action.
9. The expected communication style and the fact that style cannot override
   reasoning or evidence.

No operational authority is granted until AJ or the existing architect reviews
that restatement. Stop after the reviewed handshake; a later authorization is
required even to design the bounded pilot, and another explicit authorization
is required to execute it.
