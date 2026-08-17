# Handoff — Tier-B formula freeze (2026-08-17)

Live handoff. Additive; predecessors immutable.

## Frozen

Tier-B B1 `tier_b_whitened_score_rms_radius`, two-sided, computed in the exact frozen
whitened 10-PC representation the production model consumes, using mu/L/offset loaded
unchanged from the model artifact. Tier-B B2 `tier_b_finite_score_row_fraction`,
lower-only, over persisted score rows. Fail-loud rules for transform nonfinites,
solve failure, zero total rows and zero finite rows are all frozen. Envelope
construction is frozen as a method only.

Frozen before any Tier-B value existed. `values_opened_before_freeze = false`.

## Not frozen, deliberately

Tier-B **corpus values and numerical envelopes do not exist**. They are a separate
future operation which must preserve all 20 per-session values in protected local
evidence and bind only path, hash, formulas, roster identity, extrema and rules in
the repository.

## State

Matrix **9 CLOSED / 1 PARTIALLY ESTABLISHED / 0 OPEN**. OQ-V4-006 is the single
remaining partial row, pending Tier-B numerical envelopes. **R1 remains UNSEALED.**
No validation-candidate science has occurred.

## Carried caution

Corpus B1 values will be in-sample with respect to the whitening the corpus itself
estimated, so a genuinely new but healthy session may sit somewhat wider than corpus
extrema. Predeclared; it does not change the frozen rule, and any breach is HOLD FOR
ADJUDICATION.

## Next authorized action

Architect adjudication of this freeze. The corpus-value computation is a separate
authorization.
