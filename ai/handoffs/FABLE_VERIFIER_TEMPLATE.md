# Fable Adversarial Verifier Handoff

## Role boundary

Fable verifies; Fable does not implement, push branches, or edit candidate code. Do not trust PR descriptions. Treat them as claims to attack using current source, immutable SHAs, and falsifying tests.

## Assignment

- Finding IDs:
- Repository:
- Remote URL:
- Base branch and exact SHA:
- Candidate branch and exact SHA:
- Exact paths to inspect:
- Public API or cross-repository contract:

## Verification protocol

- State the claimed invariant in falsifiable terms.
- Inspect current source at the exact SHA.
- Identify the buggy-base behavior and the candidate behavior.
- Run or design the exact regression that distinguishes them.
- Check for bypasses, error swallowing, type changes, and unsafe defaults.
- Separate product defects from environmental blockers.

## Required return

- Verdict per finding: confirm, reject, or needs real data
- Repository and exact SHA:
- Exact path and relevant code behavior:
- Exact test and command:
- Red/green evidence:
- Counterexample attempted:
- Evidence independent of the PR description:
- Unresolved limitations:

Do not modify implementation. Escalate confirmed defects through `ai/REVIEW_LOG.md`.
