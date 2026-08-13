# Structural Acceptance Criteria

General-use approval requires all applicable criteria below. These are structural gates, not biological-validity claims.

## Cross-repository contracts

- Units, coordinate conventions, timing assumptions, key semantics, and formulas agree across producing and consuming repositories.
- Shared formulas are checked against independently derived fixed values; two copies agreeing with each other is insufficient by itself.
- UUID, key, session, frame, and timestamp alignment is explicit and fails on ambiguity.

## Scalar and API safety

- Invalid scalars cannot be emitted by producers or admitted to analysis by consumers.
- Deprecated or semantically invalid names fail closed at every public semantic-input boundary.
- Public APIs validate meaning, not merely type or shape.

## Provenance

- Provenance claims are machine-enforceable.
- Unstamped provenance is treated as unknown.
- Conflicting, mixed, malformed, and cross-package records fail safely or produce an explicit, reviewable override warning.
- A PR description, version string, or matching commit label alone is not compatibility evidence.

## Interruption and durability

- Interruption cannot silently corrupt, resume, or reprocess data.
- Partial and corrupt records are distinguishable from never-started work.
- Durable state is written before destructive mutation and recovered fail-closed after fault injection.

## Regression evidence

- Where practical, a falsifying regression fails at the exact buggy base SHA and passes at the exact candidate SHA.
- Tests use independent expected values and nontrivial inputs; self-mirroring and all-zero tests do not satisfy the gate.
- Test commands, environment, SHAs, exit codes, and unresolved limitations are recorded.

## Failure classification

- Environmental blockers are separated from product failures one failure at a time.
- Missing fixtures, optional dependencies, platform behavior, and external binaries are demonstrated with exact evidence rather than assumed.
- A blocked broader suite does not erase the need for targeted red/green evidence.

## Real-recording gate

Representative real recordings are required before general-use approval. They
remain external to Git and must be referenced through checksummed manifests.
Passing structural tests or final-kappa selection alone does not authorize
general use.

The controlling candidate gate is
`validation/protocols/REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1.md`.
It remains **NOT YET SEALED** until its eight pre-result bindings are frozen.
Its PASS requires input/extraction integrity, numeric corpus-derived PCA/model
rules, deterministic replay/equivalence, qualified visualization, recorded
high-mass syllable judgments, fail-loud provenance behavior, and no retuning
against validation outputs.
