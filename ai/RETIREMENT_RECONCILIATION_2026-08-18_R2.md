# Global Retirement Reconciliation — 2026-08-18 R2

Final continuity sweep before formal Architect V6 to V7 succession. Compact and
complete; not a project history.

## Continuation-critical repositories and refs

| Repository | Canonical ref | Canonical HEAD after reconciliation | Accepted runtime/control commit | Reachable from canonical | Local clean | Unpushed accepted | Open accepted PR | Classification |
|---|---|---|---|---|---|---|---|---|
| Ctrl-Alt-Karma/bridge | `main` | `a919e0ad170134fcce5ef56de14c1cf352130165` | `a919e0ad170134fcce5ef56de14c1cf352130165` | yes | yes | no | no | `CANONICAL_CURRENT` |
| Ctrl-Alt-Karma/moseq2-pipeline-control | `main` | final R2 retirement commit (this change) | control-plane lineage `54d8d7b5783c0810088ed96694a6bc10dcd7c94f` -> `1cd7c900780a423f2b2186025ee3a324b2bf7fbd` -> `9934cb67a2400d6e3ec29cb672701542af0da256` | yes | yes | no | no | `CANONICAL_CURRENT` |
| Ctrl-Alt-Karma/moseq2-extract | `release` | `2c9cd86571bcc23ad6870e4da344e0f558f3f54c` | `2c9cd86571bcc23ad6870e4da344e0f558f3f54c` | yes | yes | no | no (PR#6 auto-MERGED) | `CANONICAL_CURRENT` |
| Ctrl-Alt-Karma/moseq2-pca | worktree pin | `efb6fcfa5d5af5bb4274540c371d0ddf96440b78` | same | yes | yes | no | no | `CANONICAL_CURRENT` |
| Ctrl-Alt-Karma/moseq2-model | worktree pin | `6e542e3f1db125202d42b59f390c922281e64f39` | same | yes | yes | no | no | `CANONICAL_CURRENT` |
| Ctrl-Alt-Karma/moseq2-viz | worktree pin | `b80192dc20353bf77c36610f315543b57afa908c` | same | yes | yes | no | no | `CANONICAL_CURRENT` |
| Ctrl-Alt-Karma/moseq2-app | worktree pin | `e0b85201226d03e15944473a734f71417698c31e` | same | yes | yes | no | no | `CANONICAL_CURRENT` |

Repository set discovered from the runtime-identity helper's `EXPECTED_SOURCES`,
the R6 run specs, `locked_worktrees.tsv`, execution provenance, and the seal
addendum — not from a hardcoded list.

## BRIDGE

Live `main` `a919e0ad170134fcce5ef56de14c1cf352130165`, verified before use and unchanged after. Clone clean, no
unpushed work, no open PRs, `main` protected. Two remaining remote branches
(`architect/retirement-continuity-hardening-r2` `0e38dd1d`,
`architect/return-contract-completeness-r1` `0ec61298`) are not ancestors of `main`
because their PRs (#4, #5) were merged non-fast-forward; both are MERGED, so they
are `HISTORICAL_PRESERVED`, not unresolved accepted governance. BRIDGE was **not
edited**.

## moseq2-extract

`release` fast-forwarded `424d643affb685e1cad145e3c7051b814d11265c` -> `2c9cd86571bcc23ad6870e4da344e0f558f3f54c`. Preflight proved merge base
== release, ahead 4 / behind 0, linear, zero merges, and that the four intervening
commits are exactly the accepted repair lineage (`5cc8586` remove mixed-unit
velocity_3d_px, `f028801` velocity scalar regression, `e7f5851` fractional pixel
conversions — the frozen R5 validation source, `2c9cd86` deterministic
plane_ransac). R6 determinism tests revalidated 7/7 and existing ROI tests 4/4
before the write. PR#6 was automatically recognised as MERGED once its head became
an ancestor of `release`; the reason was recorded on the PR. Historical `e7f585104ba25b66e5326c88c77a47e33db95635`
remains reachable and the historical R5 detached worktree remains exact and clean.
`fix/area-mm-units` and `fix/deprecate-invalid-velocity-3d-px` are not ancestors of
the accepted source: `HISTORICAL_PRESERVED`, intentionally unmerged.

## pipeline-control

Control-plane lineage `54d8d7b5783c0810088ed96694a6bc10dcd7c94f` -> `1cd7c900780a423f2b2186025ee3a324b2bf7fbd` -> `9934cb67a2400d6e3ec29cb672701542af0da256` -> this R2 commit:
linear, two intervening commits before R2, zero merge commits.

`54d8d7b5783c0810088ed96694a6bc10dcd7c94f` remains the **R6 execution runtime commit** — the commit that actually
produced the preserved R6 runs. Later commits are control-plane only.

Branch dispositions: every remote branch is an ancestor of `9934cb67a2400d6e3ec29cb672701542af0da256` except two.
`claude/r1-r6-architect-v6-retirement-r1` `c955f428edc2579b3cf18d1763e1d9be936a28bd` is `SUPERSEDED_PRESERVED`
(retirement R1, superseded before succession because it predates the
comparator-correction and verifier state); it is not merged, not deleted, not
rewritten. `claude/moseq2-r1-sealed-resume-d1l9p1` `5ea0ec15` is
`HISTORICAL_PRESERVED`: one documentary commit dated 2026-08-17 adding
`evidence/continuity/R1_SEALED_EXECUTION_ENVIRONMENT_HOLD_R1.md`, a superseded
environment-contradiction HOLD note, durably pushed and intentionally unmerged.

Eleven local worktrees, all clean, zero unpushed commits. The local `main` ref in
the operator clone trails `origin/main` and is a stale tracking artifact, not
accepted unpushed work.

## Local-only evidence roots

- `/home/ajm/moseq2-validation-20260730/evidence/r1_primary_execution_r6_r1` — R6 execution evidence, including the original comparator report and
  the residual-decomposition receipt.
- `/home/ajm/moseq2-validation-20260730/validation/r1_existing_outside_corpus_v5/runs`
  — 21 run directories, of which the nine R6 directories are the preserved
  primary/replay evidence.
- `/home/ajm/moseq2-validation-20260730/worktrees` and `worktrees_historical` —
  locked and historical source pins.
- Windows Codex artifact store — searched in earlier operations, local-only.

All are protected golden-host local evidence and are **not** repository-accessible.
Nothing in this record claims they were independently repository-verified.

## Accepted identities reacquired from bytes

| Item | Identity |
|---|---|
| Original final seal | `ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2` |
| R6 packet manifest | `3bfc5ac04dd71f1d7b7a6010442561e2ef3d6399c88ebff88c4390781a59de5e`, 75 entries |
| Original R6 comparator report | `22be3cecc3c586a8f47950802be71fcc689741eeb957340d0d1a94954d288a2c` |
| Residual decomposition receipt | `4b2d931b5ea1f44ed818cd5aaae6b3a354421cdd3be9c7d44b0f081e2a241675` |
| Production model | `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964` |
| Runtime PCA component basis | `6b587854412c1b0a0b69759f4262e4fac3583b1aa6144093fcd3d2bf1ff0b368` |
| PCA companion yaml | `ba47df9b1229ab6dae884adf2fab49cfde4a07c5d44575e35547be12277af0d9` |
| **Training scores** (archival, **not** the runtime PCA basis) | `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912` |
| Accepted comparator | `0697df76e49d43b3bf352d41230cd2385e3d5f8bdc87ddaf9eeaeee53c588840` |
| Accepted contract JSON / MD | `b5e2dcb3c0179ce1dba8bbb499a7335096c570cf1fbb091e0c6e4e00c2128d13` / `9f0da41a876b287729c8bc834f60a8e97d21395251d62ea68718ecd311555359` |
| Qualification suite / receipt | `06bb6c3dc2e3572c2d79a252cb127586454f7a2ad1279e3184238c4ec426dc9f` / `58ac11375a4ed4b228123632d646214d20bd89abd27b513b74b8eb68e8766a70`, 37/37 PASS |

Partition 25 MUST_MATCH / 19 DECLARED_IGNORED, scientific tolerance 0. Kappa
`464159`, production seed `20260802`.

## Operation boundary

No candidate processing, extraction, PCA or model application or fitting,
visualization, scientific-value inspection, corrected-comparator evaluation against
preserved R6 outputs, or seal advancement occurred in this reconciliation. Nothing
was deleted.

GLOBAL_CONTINUITY_RECONCILIATION: PASS
