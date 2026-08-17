# Operating Rules

## Principal commandment

**Governance should be proportional to the risk of the action and the value of
the evidence. Do not split a clear, reversible remediation into multiple gates
merely because each boundary can be documented. Prefer one bounded,
evidence-preserving operation when the technical path is understood and
protected state can remain isolated.**

## Standing roles and control boundaries

1. One active architect cockpit during an active gate.
2. One active Codex operator during an active gate.
3. Migrate chats only at a clean formal phase boundary.
4. Fable is attachment-only and cannot inspect the live workstation.
5. Codex has local access only when AJ enables Full Access.
6. Hex is architect/reconciler and normally has no live workstation access.
7. AJ is project owner and sole merge authority.
8. Prompts should control authority, scope, evidence, and stop boundaries without becoming implementation encyclopedias.
9. Destination-agent capability must be checked before a prompt is issued.
10. Late optional hardening must not retroactively fail completed work unless it reveals material safety or validity risk.
11. Preserve technically valid completed work; prefer narrow append-only recovery over unnecessary reruns.
12. File handoffs should default to parent-folder path plus exact filenames. Create an extra transfer ZIP only when it materially simplifies delivery.
13. Handoffs should be compact phase deltas containing state, artifacts, decisions, access limits, blockers, and one next authorized action.

## Evidence and recovery

14. Preserve valid completed work across operator, runner-context, or evidence-capture defects. A failed receipt does not erase independently retained substantive evidence.
15. Read-only syntax, quoting, serialization, or invocation errors that occur before substantive mutation do not automatically consume authorization. Retain the failed probe, exact error, read-only classification, correction, and result.
16. Acceptance checks must validate substantive facts. Incidental stdout, stderr, whitespace, ordering, or display formatting is not a validity criterion unless the format itself is the governed interface.
17. A narrow append-only adjudication may resolve a conclusively proven false-negative receipt. It must preserve the immutable receipt, state the exact defect, and bind the correction to unchanged accepted identities.
18. Immutable runs may be reconciled when every substantive criterion passed under identical accepted identities and a later failure is conclusively an operator-context defect. Each formal run result remains unchanged.
19. Do not rerun scientifically satisfied tests solely to manufacture one cosmetically green aggregate report.
20. Distinguish candidate-code, scientific, dependency, fixture, runner, environment, evidence-capture, command, and governance failures. Do not collapse them into a generic test failure.

## Preflight and execution context

21. Preflight every required external executable, module, plugin, credential, fixture, and configuration-injected requirement before substantive execution begins.
22. External fixtures are governed dependencies. Record their authoritative source, acquisition path, byte size, SHA-256, archive safety, and extracted inventory.
23. Empty-glob and zero-iteration tests are vacuous and cannot count as substantive passes. Prove the intended input count and iteration count.
24. Validate selected pytest nodes against pytest's emitted collection IDs. Do not construct selectors from display names or assumptions about class scope.
25. A ZIP member named exactly `/` may be narrowly allowlisted only when it is a root directory entry, has zero uncompressed bytes, is not a link, device, or special member, and is the sole absolute or empty-normalized member. Absolute files, traversal, duplicates, links, devices, special members, and extraction escapes remain forbidden.
26. Git-clean is not synonymous with unchanged. Coverage databases, caches, bytecode, and other ignored outputs must be routed outside protected worktrees where possible and explicitly considered in protected-state checks.
27. A replacement runner must reproduce the complete authoritative execution context: exported environment variables, working directory, configuration-injected flags, plugins, source paths, and output paths.

## Proportional collaboration

28. Do not split understood, reversible work into unnecessary separate gates. One bounded operation may include preservation, remediation, verification, documentation, and sealing when risk remains isolated.
29. Do not turn newly visible models, effort settings, tools, UI controls, or other "shiny new knobs" into governed prerequisites without task-based justification.
30. Do not migrate an active architect or operator chat mid-gate. At a clean phase boundary, refresh durable state and test the new handoff before authorizing the next phase.
31. AJ is project owner and decision authority, not middleware between agents. Durable artifacts and direct role-appropriate handoffs carry the state.
32. Fable receives completed substantive evidence worth independent review, not every intermediate operator step.
33. Side conversations are not context corruption. Resume through a concise anchor check against durable state.
34. Interaction style never overrides skepticism, evidence standards, technical reasoning, uncertainty reporting, independence, or willingness to disagree with AJ.

## Scientific evidence transport and validation discipline

35. When a reviewer must characterize a frozen executable rule, provide the authoritative executable artifact, protocol, and conformance receipt when practical. Do not reconstruct load-bearing semantics from prose when the exact artifact exists.
36. A portable evidence package must satisfy exact set equality: manifested members equal physical transport members union explicit exclusion-ledger members. Every omitted manifested member belongs in the ledger regardless of artifact type.
37. Freeze numeric, mechanically evaluable load-bearing validation rules before opening validation values. “Materially outside” is not a mechanical rule.
38. Out-of-family flags trigger causal and scientific adjudication; they do not automatically exclude data or authorize retuning.
39. Do not tune through a HOLD. Any scientific component changed after validation evidence is opened requires explicit Architect adjudication of whether the affected held-out evidence remains valid.

## Status integrity (project-only)

40. An `ai/OPEN_QUESTIONS.md` status may not be promoted to `CLOSED` or `RESOLVED` unless the same documentary change directly links the exact closing primary artifact or sealed local evidence identity. Where the artifact is not reachable from this public repository, record the exact local path, SHA-256, the narrow claim established, and the access limitation. A summary, handoff, review, or chat assertion cannot itself close a row.
41. Any assertion that a gate, binding, or requirement is complete — in any wording, not only the words READY, PASS, SEALED, or CLOSED — must cite a primary artifact or carry the label UNVERIFIED or INHERITED. The citation must be to a primary artifact, never to another summary.
42. A successor Architect's comprehension handshake must re-derive gate statuses from the closure matrix and its linked artifacts. Any inherited status absent from that matrix is UNVERIFIED by default.
