# Decisions

All decisions below are dated 2026-07-29.

| ID | Decision | Rationale |
|---|---|---|
| D-001 | One active builder at a time. | Avoid overlapping implementation and ambiguous authorship. |
| D-002 | Fable is verifier, not builder. | Preserve an independent adversarial review channel. |
| D-003 | Claude Code is a backup builder or bounded verifier. | Use it only under an explicit, limited handoff. |
| D-004 | No SEEP integration during this repair phase. | The shared-evidence experiment is unrelated to the present control system. |
| D-005 | Study design and biological analysis are separate downstream workstreams. | Structural repair must not inherit experiment-specific assumptions. |
| D-006 | Raw recordings never go in implementation repositories. | Keep large/sensitive operational inputs external and separately governed. |
| D-007 | Unstamped provenance means unknown. | Missing provenance does not justify compatibility claims. |
| D-008 | Old superseded PRs and branches remain for audit history. | Preserve the record of prior proposals and why they were replaced. |
| D-009 | No merges without AJ. | AJ is the final merge authority. |
