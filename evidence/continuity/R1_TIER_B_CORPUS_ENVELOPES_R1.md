# R1 Tier-B corpus envelopes — sanitized pointer

Local root (not repository-accessible):
`/home/ajm/moseq2-validation-20260730/evidence/r1_tier_b_corpus_envelopes_r1`

| Artifact | SHA-256 |
|---|---|
| `TIER_B_CORPUS_ENVELOPES_R1.json` | `122a0a76af2179c875782e32c471dd65300de6f375c9b3c4b9c2b16c92562506` |
| `TIER_B_CORPUS_ENVELOPES_R1.md` | `45ae32c0f37c96c7320a1ac3846b2b091412df4aa3ace7692d6835dd2c33a4d5` |
| `TIER_B_CORPUS_SESSION_VALUES_R1.csv` | `ba04fc2a04e00cda29f1093a8d31db79f774a8aab1620f4901ed3a1ca1794fa8` |
| `SHA256SUMS` | `e9f119cb76c0f241beee936f212eca0c357d75409d2c8d1bd8dc23e29bc1758c` |

Computed under the formulas frozen in `TIER_B_FORMULA_FREEZE_R1.json`
(`87907d48...`), unchanged, over the exact 20-session corpus `keys` roster
(`cb1a7b46...`) — not the HDF5 group listing.

**20/20 sessions evaluated. Zero fail-loud conditions.**

    B1_lower = 2.410095327226669
    B1_upper = 3.925567393155021
    B2_lower = 0.9979228486646884

B1 flags two-sided; B2 flags lower-only with no upper flag. Every breach is HOLD FOR
ADJUDICATION and never authorises automatic failure, exclusion, PCA or whitening
change, model change, threshold movement, or replacement. Degenerate-envelope
semantics were frozen before the values were visible and no tolerance was added
afterwards.

Per-session corpus values and identities are held in the protected CSV above and are
deliberately not published.

No validation-candidate data was accessed. R1 remains **UNSEALED**.
