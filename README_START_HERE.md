# MoSeq2 Pipeline Control

## Purpose

This repository coordinates repair, independent review, and structural validation across five MoSeq repositories: `moseq2-extract`, `moseq2-pca`, `moseq2-model`, `moseq2-viz`, and `moseq2-app`.

It is the source of truth for current state, locked revisions, findings, decisions, evidence, and acceptance gates. Chats are workers, not memory. Any claim that matters must land here with a repository, immutable SHA, path, test, evidence, and unresolved limitation.

Structural correctness is independent of Kat's experiment. Study hypotheses, expected biological effects, sample-size planning, publication figures, and downstream interpretation belong to separate downstream workstreams.

No implementation PR may merge without AJ's explicit approval. PR descriptions are claims, not evidence. A finding is fixed only when both current source and a falsifying regression test support the fix.

## Roles

- **ChatGPT Classic — architect and reconciler.** Maintains task boundaries, reconciles independent findings, and keeps this repository internally consistent.
- **Codex — primary builder and executor.** Implements scoped work, runs checks, records exact evidence, and prepares draft PRs.
- **Fable — independent adversarial verifier.** Reviews source and tests independently; it does not implement.
- **Claude Code — bounded backup builder or verifier.** Works only within an explicit handoff and does not silently expand scope.
- **AJ — owner and final merge authority.** Decides what may merge and when.

## Operating rule

Start with `ai/CURRENT_STATE.md`, then `ai/TASK_SPEC.md`, then the relevant lock profile in `repositories/repos.lock.yaml`. Record findings in `ai/REVIEW_LOG.md`; do not treat chat history or a PR description as durable evidence.
