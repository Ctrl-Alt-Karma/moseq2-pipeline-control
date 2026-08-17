# R1 Repository Hash / Line-Ending Provenance Check

## 1. Canonical bytes established, triple-bound

Fetched `validation/protocols/R1_FINAL_SEAL_R1.json` directly from the canonical repository at commit `56ecf0b5fa8775a9952b29735ba1f5079b742263` (the control repository is publicly reachable, so this is first-party canonical access, not builder-mediated). The content is 3,540 bytes, pure LF (57 newlines, zero CRLF). Identity bound three independent ways: the GitHub Trees/Contents API reports blob `5de59c6a…` at 3,540 bytes; my own recomputation of the git blob SHA-1 over the fetched bytes (`sha1("blob 3540\0" + content)`) reproduces `5de59c6a5446cec5ec05faf62b53e91a5a672580` exactly, proving the fetched bytes are the committed object; and SHA-256 over those bytes is:

ac0cde7d0f65fe6e74116c7d9b4fa69764b651194ddbfb45a9394dde3e7254e2

The Builder-reported canonical hash is **independently confirmed correct**.

## 2. CRLF mechanism verified exactly, not approximately

Applying LF→CRLF to the same canonical bytes yields 3,597 bytes (3,540 + 57, one byte per newline, exact) and SHA-256:

b6d4089eeba624d446b7cdd8c99508505b36192ee809b034ee39922fe68a58aa

which reproduces the recorded historical value **bit-for-bit**. The historical hash is therefore fully explained by `core.autocrlf=true` worktree materialization of tracked-LF content, with no residual difference to attribute to anything else.

## 3. Representation-only: confirmed

`json.loads` of the canonical bytes and of the CRLF variant produce identical objects. The semantic payload — including every binding inside the seal (`bound_bindings.*`, `frozen_scientific_identities.*`) — is unchanged. Two of those internal identities cross-check against my own sealed verification record: `pca_scores_h5_sha256 = 26e30500…` is the locked PCA I have verified repeatedly, and `corpus_order_sha256 = cb1a7b46…` matches the uuid-order hash from the Phase B metric-qualification receipt. The seal's content is internally consistent with the verified program history.

## 4. Bounded exposure survey

Enumerated all 150 tracked blobs at the pinned commit (tree not truncated), scanned every continuation/seal/handoff/protocol record for 64-hex values co-located with repo-tracked text paths, and classified each binding against both the canonical and CRLF-transformed hashes of the referenced file.

**Repository-tracked text files bound by SHA-256 in durable records: exactly one.**

File: validation/protocols/R1_FINAL_SEAL_R1.json
Recorded hash: b6d4089e…
Canonical hash: ac0cde7d…
Differ: Yes
CRLF explains exactly: Yes, bit-exact
Load-bearing use: Continuity/handoff binding of the R1 final seal

The recorded CRLF-variant value appears in **four** locations, all of which remediation must touch together:

ai/CURRENT_STATE.md
ai/DECISIONS.md
ai/HANDOFF_2026-08-17_R1_FINAL_SEAL_R1.md
evidence/continuity/R1_FINAL_SEAL_R1.md

The canonical value `ac0cde7d…` currently appears nowhere in the tracked record.

No other repo-tracked text binding exists in the durable record, and — importantly — **no binding classified as NEITHER**, which would have indicated content drift rather than representation drift. The seal's other bindings reference WSL-side evidence artifacts, transports, and frozen scientific identities whose provenance is the Linux/canonical hashing path, all out of scope per the brief and none showing the exposure signature.

## Disposition rationale

Canonical identity independently established with the blob-level proof; the CRLF mechanism verified exactly rather than assumed; the affected set is closed and enumerated to the occurrence level, sufficient to remediate without guessing: replace `b6d4089e…` with `ac0cde7d…` in the four listed locations, ideally annotating the correction as an append-only amendment per project convention rather than a silent edit. No writes performed by me.

## MATERIAL OBSERVATIONS OUTSIDE THE BRIEF

Two.

**1. The durable record currently binds the seal only in its Windows-worktree representation.** Until remediated, any verifier on a Linux checkout (or any `git cat-file` consumer) computing the canonical hash will get a mismatch against all four records simultaneously, which would present as a seal-integrity failure rather than the representation artifact it is. Conversely, a `.gitattributes` entry pinning `*.json text eol=lf` (or `-text` for sealed protocol files) would prevent the class entirely; the repository currently relies on each clone's `autocrlf` setting, which is exactly how this happened.

**2. The control repository is now publicly readable.** That materially changes my verification reach going forward — control-repo commits, working-tree pins, and sealed records are now independently checkable by me at canonical byte level, which retires a builder-bound category that has appeared in every review since the R1 pilot design ("the control repository remains private and unverifiable to me"). If the public visibility is intentional, the standing briefs can drop that limitation; if it is not intentional, that is worth knowing today for a different reason.

PASS_R1_REPOSITORY_HASH_PROVENANCE_CHECK

No writes. No candidate access. No science executed. Stopping here.
