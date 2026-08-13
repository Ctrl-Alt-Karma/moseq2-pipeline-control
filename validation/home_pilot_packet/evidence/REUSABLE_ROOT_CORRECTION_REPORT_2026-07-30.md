# Reusable-Root Packet Correction Report

Date: 2026-07-30

Artifact:
`MOSEQ_LEGACY_HOME_PILOT_REUSABLE_ROOT_CORRECTED_2026-07-30.zip`

## Scope

This correction repairs deployment-packet controls only. It did not invoke
WSL, create the real validation root, run a packet phase against the golden
environment, install packages, edit scientific repositories, inspect
scientific data, or merge a pull request.

## Corrected root lifecycle

Script 01 is the sole root initializer. It requires a fresh explicit path below
`/home/ajm`, writes a versioned marker bound to the current packet manifest,
creates only Phase 0 child paths, and retains a fail-closed receipt and
manifest.

Script 02 reuses that same root. Before creating a worktree or receipt it
requires:

- the current packet marker and schema;
- a structurally exact `COMPLETE` Phase 0 receipt;
- a valid internal Phase 0 SHA-256 manifest;
- the absence of every script-02 worktree, environment, and receipt target;
- no unknown top-level state.

Arbitrary directories, missing or malformed receipts, unknown state, partial
runs, and reruns are rejected. Scripts 03 through 06 and evidence collection
now require the same explicit root, validate their prerequisite receipt, keep
their outputs beneath it, and refuse overwrite. Golden-reference export and
known-answer establishment also require the explicit root.

## Corrected Phase 0 evidence

- Every installed `moseq2-*` distribution is located and recorded with package
  path, version, metadata, per-file SHA-256 records, and a deterministic
  aggregate source-tree identity.
- Installed source is compared by bytes against supplied pinned vanilla,
  fork-release, and candidate trees. Each package receives exactly one allowed
  identity status; version labels are not used as identity.
- Sitecustomize evidence is exactly `PRESENT_AND_HASHED`,
  `VERIFIED_ABSENT`, or `UNRESOLVED`. A verified absence includes the
  interpreter, `sys.path`, candidate locations, and import search method.
- Classifier custody is `FOUND_AND_HASHED` or `UNRESOLVED`; unresolved evidence
  retains all bounded search locations.
- At least one explicit load-bearing configuration is required. Discovered and
  referenced configuration files are hashed, unresolved references are
  retained, and the record explicitly refuses a comprehensive-custody claim.

## Regression coverage

Synthetic regressions cover valid-root acceptance, arbitrary-root rejection,
prior worktree and receipt rejection, the obsolete contradictory behavior as a
negative control, deterministic source hashing, all six source-identity
statuses, all three sitecustomize states, classifier unresolved search
locations, and bounded configuration custody. The existing credential-leak and
fabricated-preflight mismatch tests remain passing.

Full commands and results are recorded in `STATIC_VALIDATION.md`. Packet bytes
and the outer ZIP SHA-256 are recorded in the adjacent sidecar receipt. The
internal `SHA256SUMS.txt` covers every packet file other than itself.
