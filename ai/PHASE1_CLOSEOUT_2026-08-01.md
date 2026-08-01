# Phase 1 Closeout — 2026-08-01

This record closes Phase 1. It is an additive audit record; earlier evidence
and the dated Phase-0-to-Phase-1 handoff remain unchanged.

## Result

`02_prepare_locked_worktrees.sh` ran exactly once from the audited reusable-root
corrected packet with:

`bash 02_prepare_locked_worktrees.sh --root /home/ajm/moseq2-validation-20260730`

Execution ran from `2026-08-01T03:02:02Z` through `2026-08-01T03:02:09Z`,
exited `0`, created five clean detached candidate worktrees at the frozen SHAs,
recorded `source_mode=PYTHONPATH_ONLY`, and performed no Conda installation.
Script 02 was not rerun.

The explicitly authorized append-only seal did not alter the original run. Its
manifest at
`/home/ajm/moseq2-validation-20260730/evidence/script02_operator/SCRIPT02_POST_RUN_SHA256SUMS.txt`
has SHA-256 `d9184ad85b093b15135f85f1b6554de3274a528f22f208085debbadc64aca133`.
Verification exited `0` with all five entries `OK`: the locked-worktree
receipt, worktree table, source environment, original console, and post-run
execution-context attestation.

## Locked candidate source

| Repository | SHA |
|---|---|
| `moseq2-extract` | `e7f585104ba25b66e5326c88c77a47e33db95635` |
| `moseq2-pca` | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` |
| `moseq2-model` | `6e542e3f1db125202d42b59f390c922281e64f39` |
| `moseq2-viz` | `b80192dc20353bf77c36610f315543b57afa908c` |
| `moseq2-app` | `e0b85201226d03e15944473a734f71417698c31e` |

## Audit transport chronology

- R1 failed closed during staging validation. Its
  `transport\AUDIT_BUNDLE_INVENTORY.tsv` was malformed as literal Markdown
  content: 3,479 bytes, zero tab bytes, 90 backtick bytes, SHA-256
  `1a066212edbed767da6d4b0eb183824dded855f831ae40f07d3bbcae1cfd06cf`.
  The preserved R1 directory was not repaired.
- R2 rebuilt and validated the staging bundle, but its ZIP used backslash
  central-directory member names and was rejected for attachment transport.
  The invalid ZIP was 27,531 bytes with SHA-256
  `97c3747ee885a3311d89a362e9de82b871738c9c1f314897851fa8b0c26ce299`.
- R3 reused the unchanged valid R2 staging bundle and created a standards-valid
  ZIP with explicit forward-slash member names. It contains exactly 14 members;
  its detached manifest and verification record cover all 14.

## R3 delivery artifacts

| Artifact | Windows path | SHA-256 |
|---|---|---|
| ZIP | `C:\deployment\MOSEQ_PHASE1_SCRIPT02_FABLE_AUDIT_2026-07-31_R3.zip` | `daf8a3aeb480e918eb5422d92258f453d626e2392e13b072f5d52776d659fb48` |
| ZIP-member manifest | `C:\deployment\MOSEQ_PHASE1_SCRIPT02_FABLE_AUDIT_2026-07-31_R3_ZIP_MEMBERS_SHA256SUMS.txt` | `17ec0f4d127f32c0cc0ed77591863b267d69fc518641c27c99646512555b1e9e` |
| Manifest check | `C:\deployment\MOSEQ_PHASE1_SCRIPT02_FABLE_AUDIT_2026-07-31_R3_ZIP_MEMBERS_SHA256SUMS_CHECK.txt` | `12e81920c568b2a323c8e61ff671f1617d373a3fc2a2b06994d5e17fabd5b704` |
| Delivery receipt | `C:\deployment\MOSEQ_PHASE1_SCRIPT02_FABLE_AUDIT_2026-07-31_R3_DELIVERY_RECEIPT.txt` | `6f2006cc9dbb273f3b96bec3aec8dfc93c31fd79a0d6ed11d4f2aedce1df44e0` |

## Independent verdict

Fable performed an attachment-only independent audit and returned
`VERDICT: PASS`, `RECOMMEND PHASE 1 CLOSURE`, and `BLOCKS NEXT GATE: NONE`.
Fable verified all four R3 identities, exactly 14 valid ZIP members and their
hashes, the detached and internal manifests, the original script-02 evidence,
the append-only seal, and all 12 frozen script-02 acceptance criteria.

Accepted `IMPORTANT, NON-BLOCKING` findings:

1. The immutable R3 receipt contains
   `teen_staged_members_unchanged=PASS` instead of
   `fourteen_staged_members_unchanged=PASS`. Do not repair it.
2. The attached evidence does not directly record the R2 backslash-path failure
   reason.
3. Worktree cleanliness and live environment state remain builder-captured
   evidence reviewed by Fable rather than independently reproduced live.
4. Hostname formatting differs cosmetically among artifacts.

Accepted backlog:

- Script 02 should natively create and verify its integrity manifest.
- Normalize future ZIP permission metadata where practical.
- Preserve the previously recorded Phase 0 and historical-configuration
  backlog.

## Closure boundary

**Phase 1 is CLOSED with an independent PASS.** Script 03 is **NOT YET
AUTHORIZED**; its next gate remains pending read-only preflight reconciliation
and explicit Hex authorization. No merge is authorized by this closeout.
