# Handoff correction R1 — Architect V5 succession semantics (2026-08-17)

Additive correction to `ai/HANDOFF_2026-08-17_ARCHITECT_V5_RETIREMENT.md`, which
remains immutable and byte-identical at commit
`3a4e0d1f6cb06f6d5fed18fe51281e9778ab9198`. That handoff stands as historical
evidence of what the first documentary sync recorded, including its errors.

## What this correction supersedes

**Only** the erroneous succession-status, authority-transfer, and row-count
language of the first retirement handoff. Specifically:

- its section 4 statement that Architect V5 is **RETIRED**;
- its section 16 statement that Architect V5 authority is **relinquished by that
  handoff**;
- its section 3 phrase "seven of the ten tracked pre-seal rows remain unresolved
  or partially established";
- its section 11 phrase "the reconciled count is seven unresolved or partially
  established rows out of ten".

Everything else in that handoff stands unchanged. All scientifically substantive
reconciliation findings, accepted identities, evidence citations, unresolved
items, access limits, claim boundaries, canon classifications and the stop
boundary remain exactly as recorded there.

## Correction 1 — succession semantics

Architect V5 status is:

**RETIRING / SUCCESSION PENDING.**

Architect V5 is **not** retired, and no Architect authority has transferred.

Architect V5 retains only the authority necessary to:

1. receive the successor candidate's independent comprehension reconstruction;
2. perform the canonically bounded backward-pass fidelity check;
3. return exactly one of `PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION` or
   `HOLD_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION - <reason>`.

Architect V5 must not use that retained authority to resume substantive project
steering, redesign science, authorize R1 execution, or create new Builder work,
except a narrow correction required to complete succession safely.

The successor candidate holds **no** Architect authority while performing its
read-only comprehension handshake.

Formal Architect authority transfers **completely and only** upon
`PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`.

Owner AJ / Karma remains ultimate Owner authority throughout. Ordinary Owner
acceptance of a reconstruction is not a substitute for the formal succession PASS
that BRIDGE requires.

## Correction 2 — reconciled row count

The reconciled ten-row closure matrix is:

- **1 CLOSED** (OQ-V4-001)
- **2 PARTIALLY ESTABLISHED** (OQ-V4-003, OQ-V4-007)
- **7 OPEN** (OQ-V4-002, OQ-V4-004, OQ-V4-005, OQ-V4-006, OQ-V4-008, OQ-V5-009,
  OQ-V5-010)

Therefore **9 of 10 rows are NOT FULLY CLOSED**.

Seven is the OPEN-only count and must not be described as the
unresolved-or-partial count. Use one of the two formulations above verbatim.

No row status changed. `ai/OPEN_QUESTIONS.md` is unmodified by this correction.

## Correction 3 — governance scope

Project-only operating rule **40** stands: an `ai/OPEN_QUESTIONS.md` status may
not be promoted without the closing primary artifact linked in the same
documentary change.

Rules 41 and 42, added by the first sync, are **removed**. Their substance was
classified during the retirement canon flush as `ALREADY_CANON` in BRIDGE and is
therefore not new project-only governance. They are removed without replacement.

BRIDGE is unchanged at `Ctrl-Alt-Karma/bridge`
`328c7eee85cf57a5af4211b3d36f5ee7560ebc5d`. No BRIDGE mutation is authorized.

## Correction 4 — next action and stop boundary

Exactly one next authorized action remains:

**FORMAL SUCCESSOR ARCHITECT COMPREHENSION HANDSHAKE.**

After the successor returns its reconstruction, that reconstruction is brought
back to the retiring Architect V5 cockpit for the bounded backward-pass fidelity
check. No scientific or Builder operation occurs between those two steps.

R1 remains unsealed. No Tier-B computation. No candidate science.

## Status after this correction

- Architect V5: **RETIRING / SUCCESSION PENDING**
- Architect authority transferred: **NO**
- Succession trigger: `PASS_HANDOFF_SUCCESSOR_STATE_RECONSTRUCTION`
- R1: **UNSEALED**
- Pre-seal matrix: 1 CLOSED / 2 PARTIALLY ESTABLISHED / 7 OPEN; 9 of 10 not fully
  closed
