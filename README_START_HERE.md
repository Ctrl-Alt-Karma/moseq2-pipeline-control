# MoSeq2 Pipeline Control

## Purpose

This repository is the durable project-control record for MoSeq pipeline repair,
calibration, evidence, decisions, acceptance gates, production identities, and
handoffs across `moseq2-extract`, `moseq2-pca`, `moseq2-model`, `moseq2-viz`,
and `moseq2-app`.

Chats are workers, not memory. Any claim that matters must land here with an
exact repository/artifact identity, evidence, adjudication state, and unresolved
limitation.

The current live state includes project-specific scientific calibration and
production-validation governance. Biological hypotheses, genotype/treatment
effects, publication figures, and downstream interpretation remain separate
downstream workstreams.

## Roles

- **AJ / Karma — Owner.** Sole final authority for consequential decisions.
- **Hex / ChatGPT Architect V4 — Architect and reconciler.** Owns technical
  coherence, task boundaries, and gate adjudication.
- **Codex — primary Builder/operator.** Executes bounded work and reports
  evidence; it does not self-certify substantive conclusions.
- **Fable — independent Verifier or Scientific Counsel.** The active review role
  must be declared explicitly; Fable does not repair the review target.
- **Claude Code — authorized stand-in Builder when explicitly assigned.**

## Start here

Read, in order:

1. `ai/CURRENT_STATE.md`;
2. `ai/HANDOFF_CURRENT.md`;
3. `ai/TASK_SPEC.md`;
4. `validation/protocols/REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1.md`
   for the current open scientific gate.

Use `ai/DECISIONS.md` for settled decisions and `ai/REVIEW_LOG.md` for review
history and project lessons. Do not treat a PR description or chat recollection
as durable scientific evidence.
