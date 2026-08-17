# R1 Tier-B formula freeze — sanitized pointer

Local root (not repository-accessible):
`/home/ajm/moseq2-validation-20260730/evidence/r1_tier_b_formula_freeze_r1`

| Artifact | SHA-256 |
|---|---|
| `TIER_B_FORMULA_FREEZE_R1.json` | `87907d48a4897a5295da52ec0765d51035ffaa72cc5a262b0966e5d3a4dd35b9` |
| `TIER_B_FORMULA_FREEZE_R1.md` | `34c7bf2e42c5f6df86b372fa6fae3620d4874a7a1998345ff42d0823d2514113` |
| `TIER_B_SCIENTIFIC_COUNSEL_RECEIPT_R1.json` | `771bb4d2e691d377d0e0f3608f732c26dab59d3a5691c9f70ede28d6d798e0fa` |
| `SHA256SUMS` | `170db174fc230b075235417e0792f30d8a946416abd4b87d570e0f469c74bcfc` |

**Frozen before any Tier-B value existed.** No corpus value, no validation value, no
threshold, no envelope.

B1 `tier_b_whitened_score_rms_radius` — RMS radial magnitude in the frozen whitened
10-PC space consumed by the production model, using mu/L/offset loaded unchanged from
the model artifact; two-sided. B2 `tier_b_finite_score_row_fraction` — finite
persisted score-row coverage across the ten production components; lower-only.

Zero total rows and zero finite rows are evidence-level HOLDs. A raw-finite row
transforming to a nonfinite value triggers `HOLD_TIER_B_WHITENING_NONFINITE` and is
never silently dropped. Envelope construction is frozen as a method; any future
breach is HOLD FOR ADJUDICATION and never authorises exclusion, retuning or threshold
movement.

Reconstruction quality is classified **NOT_SUPPORTED_WITHOUT_NEW_METHOD** on bound
source evidence, and the protocol carries a bounded R1 clarification waiving it by
documented absence rather than substituting an invented diagnostic.

Counsel marker `PASS_FABLE_COUNSEL_R1_TIER_B_FORMULA_FREEZE_R1`; Architect disposition
`PASS_ARCHITECT_COUNSEL_R1_TIER_B_FORMULA_FREEZE_R1`. The local receipt is a durable
pointer to that accepted result, not a Builder reproduction of the review.

Whitening arrays are deliberately not published; they are bound by stable digests.
