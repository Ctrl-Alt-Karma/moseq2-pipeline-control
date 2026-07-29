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
| D-010 | App flip correction and extraction-time flip correction are alternative workflows, not cumulative passes. | Layering them adds pi twice and can leave extraction flip metadata inconsistent with corrected frames and angles. |
| D-011 | An uncleared app journal sentinel remains authoritative and fail-closed. | Slot contents are useful diagnostics, but without a power-loss durability guarantee they are not sufficient for automatic recovery. |
| D-012 | Katya's exact existing Python 3.7 / NumPy 1.18.3 MoSeq Conda environment is the supported production environment for this study. | It is the environment that produced the study's existing work and is the only approved target for the structural real-data pilot. Preserve it; do not upgrade it in place. |
| D-013 | Python 3.8/3.11 migration, NumPy upgrades, modernization, and multi-environment equivalence testing are out of scope. | The study has frozen its production target. These subjects are not planned work in this control repository. |
| D-014 | Legacy preservation precedes real-data processing. | Export the WSL distribution, freeze environment and dependency custody, and verify locked source before an explicitly approved bounded pilot. |
| D-015 | The home WSL environment is the golden reference and pilot host, not an assumed final-analysis machine. | Full analysis may move to separate hardware, but the study environment identity may not drift with the hardware. |
| D-016 | The frozen environment is portable only through a complete locked offline deployment bundle or a SHA-256-verified import of the golden WSL archive. | Approximate version matches, floating references, and opportunistic reinstallations cannot establish equivalence. |
| D-017 | Every new machine must independently pass exact preflight and the versioned known-answer fixture before real data. | Installation success is not qualification. Any `UNRESOLVED` or `MISMATCH` result is fail-closed. |
| D-018 | `deployment/run_pipeline_guarded.sh` is the supported production entry point on a separate analysis machine. | It refuses unqualified execution and records the verified fingerprint and qualification binding in each analysis output. |
