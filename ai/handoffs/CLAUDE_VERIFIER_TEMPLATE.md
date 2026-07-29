# Claude Code Bounded Verifier Handoff

## Role boundary

Claude Code is a bounded backup verifier unless this handoff explicitly authorizes implementation. Do not expand repository, path, or finding scope. Do not merge or delete branches.

## Assignment

- Mode: verifier / explicitly authorized backup builder
- Finding IDs:
- Repository:
- Remote URL:
- Base branch and exact SHA:
- Candidate branch and exact SHA:
- Allowed paths:
- Prohibited paths:

## Required checks

- Claimed invariant:
- Required falsifying test:
- Exact environment/profile:
- Exact commands:
- Cross-repository assumptions to verify:

## Required return

- Repository and exact SHA:
- Paths inspected or changed:
- Exact evidence:
- Test result at base:
- Test result at candidate:
- Implementation commit, if explicitly authorized:
- Working-tree state:
- Unresolved limitations:

Anything outside this boundary returns to the reconciler for a new handoff.
