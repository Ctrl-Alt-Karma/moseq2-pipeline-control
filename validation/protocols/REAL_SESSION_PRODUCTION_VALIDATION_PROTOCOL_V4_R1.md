# Real-Session Production Validation Protocol V4 R1

Protocol ID: `REAL_SESSION_PRODUCTION_VALIDATION_PROTOCOL_V4_R1`

Status: **SEALED — ARCHITECT R1

Scientific Counsel R0: `FABLE_COUNSEL_PASS_REAL_SESSION_VALIDATION_PROTOCOL_R0`

Architect adjudication:
`ARCHITECT_V4_ACCEPTS_REAL_SESSION_VALIDATION_PROTOCOL_R0_WITH_BOUNDED_R1_CHANGES`

## 1. Purpose and claim boundary

This gate decides whether the frozen production model and pipeline are
trustworthy for routine Katya use on real recordings. It is not a genotype or
treatment-effect test, a biological efficacy study, or a reopening of model
selection.

The production model is applied without refitting or adaptation. Group effects
must not be used as an acceptance criterion and must not be interpreted before
this gate passes.

## 2. Accepted production identity

- model source: `6e542e3f1db125202d42b59f390c922281e64f39`;
- PCA: `/home/ajm/moseq_work/5xfad_exploratory_20/pca/pca_scores.h5`;
- PCA SHA-256: `26e30500be1e885422307c707e0b7b5ec619c70149d557a764d3daa475108912`;
- kappa: `464159`;
- production seed: `20260802`;
- model: `/home/ajm/moseq2-validation-20260730/analysis/locked_464159_k200_long_chain_convergence_sentinel_20260812_R1/model/model-k200-kappa464159-seed20260802-iter500.p`;
- model SHA-256: `5e10803af7017bd32cc491483fcfa3bfc570e617d427649b4d0f1ca86c49d964`;
- regime: K=`200`, iterations=`500`, `npcs=10`, `nlags=3`,
  `whiten=all`, `alpha=5.7`, `gamma=1000`, `ncpus=2`,
  `percent_split=0`, `noise_level=0`;
- execution target: accepted WSL Ubuntu 22.04 `moseq2-app` Conda environment,
  Python 3.7.12, NumPy 1.18.3, with locked source supplied from the accepted
  worktrees.

## 3. No-peek freeze point

Before any final-model validation output, crowd movie, syllable usage, or
validation PCA/model diagnostic is inspected, freeze:

1. the exact validation roster and predetermined replacements;
2. exact production model, PCA, visualization, source, and environment identities;
3. corpus-derived numeric QC thresholds and comparison envelopes;
4. the exact visualization implementation and its orientation regression;
5. the Tier-E negative-control condition;
6. the deterministic replay plan and any predeclared equivalence criteria.

Session selection may use metadata, raw-recording integrity, raw/extraction QC,
rig, animal, and acquisition date. It may not use production-model outputs,
syllable content, or genotype/treatment outcome differences.

If validation exposes a defect and a scientific component changes afterward,
the affected validation set may no longer be clean confirmatory evidence for
that changed component. Architect adjudication determines whether a new
held-out set is required.

## 4. Eligibility, inventory, and roster construction

Each candidate must be a real depth recording outside the locked 20-session
PCA/model corpus, with recoverable identity and provenance, animal, recording
date, rig where known, input checksum, raw QC, and recoverable prior processing
and result-inspection history.

Prior exposure should distinguish:

- extraction/QC-only exposure;
- PCA/model exposure;
- visualization exposure;
- statistical exposure;
- whether result-bearing outputs were actually inspected.

Prefer sessions never previously **modeled and inspected**. Any unavoidable
modeled-and-inspected exception must be disclosed before execution.

Target eight ordinary or challenging-but-processable sessions. Where inventory
permits, include both Kinect rigs, multiple animals and dates, at least one
session near each end of the available date range, and at least two sessions
with a documented pre-existing, scientifically processable acquisition stressor.

For each deliberately challenging session, predeclare before result inspection:

- the known stressor;
- the QC or representation dimensions reasonably expected to flag;
- outcomes that remain genuinely alarming.

A known challenge excuses no unrelated defect. If the inventory cannot support
the target structure, take the widest feasible spread and document the
limitation before execution.

## 5. Replacement rule

An ordinary selected session may be replaced only when proven input-invalid
before model-result inspection because of corruption, missing recording,
checksum failure, unrecoverable provenance, or an equivalent raw-input defect.

Use only the predetermined next eligible session from the same selection
stratum. Preserve the exclusion and replacement record. Never replace a session
because the pipeline or model produces an inconvenient scientific result.

## 6. Visualization qualification gate

Crowd-movie evidence is inadmissible until the exact visualization path passes
qualification. Reacquire the authoritative fix and evidence for the historical
stale flip-provenance / 180-degree render defect. Bind the exact viz, app, and
source identities; run or reacquire a regression demonstrating intended
orientation after app-level flip correction; and prove the path does not
silently pool incompatible flip or provenance states.

If qualification fails, numerical validation may continue but qualitative
production acceptance remains `HOLD`.

Visualization was prohibited during kappa selection. After kappa selection is
closed, qualified crowd-movie review is required before final production
acceptance.

## 7. Tier A — input and extraction integrity

Every ordinary session requires a documented disposition covering at least:

- required files present and checksummed;
- depth-file size coherent with recording metadata;
- timestamp and drop-frame integrity;
- persistent void or speckle behavior;
- selected floor range and floor diagnostics;
- ROI and arena position;
- off-center or buried animal when material;
- camera-height consistency where the rig specification supports it;
- flip-classifier state and provenance;
- QC preview alignment and orientation;
- extraction completion;
- actionable failure reporting.

A raw-input defect may classify a session `INPUT_INVALID` under the replacement
rule. Silent failure, provenance ambiguity, unexplained truncation, or a
scientifically material extraction defect causes `HOLD`.

## 8. Tier B — PCA and representation generalization

Before opening validation-session PCA diagnostics, derive and seal a comparison
baseline from the locked 20-session corpus only.

Use the smallest supported defensible set, including per-session PCA
reconstruction error or the closest supported load-bearing reconstruction
quality metric, plus selected global PCA-score magnitude or coverage metrics
sufficient to detect gross out-of-distribution projection.

For every load-bearing Tier-B metric, freeze a numeric, mechanically evaluable
flag rule at the same time as the corpus envelope. “Materially outside” is not
a rule. Do not invent a new methodology merely to produce an impressive QC
number.

A flag causes `HOLD` for causal and scientific adjudication. It does not
automatically discard the session, authorize PCA tuning, or permit threshold
movement after values are seen. A challenging session's known stressor may
inform only the predeclared expected-flag dimensions.

### R1 clarification — reconstruction-quality requirement

The accepted PCA implementation (`moseq2-pca`
`efb6fcfa5d5af5bb4274540c371d0ddf96440b78`) exposes no implemented
reconstruction-error or reconstruction-quality diagnostic; source retains
reconstruction error only as an unimplemented TODO. For R1, the
reconstruction-quality requirement is therefore explicitly waived by documented
source absence rather than replaced by a new diagnostic, and the supported Tier-B
battery is the frozen magnitude-and-coverage battery bound by the Tier-B
formula-freeze artifact.

## 9. Tier C — model application and reproducibility

Apply the frozen production model with no refit or adaptation. For every session
record at least:

- successful application and exact production-model binding;
- modeled-frame accounting;
- occupied-state count;
- overall and pooled bout-duration summaries;
- gross syllable-usage concentration;
- unscorable or missing-state behavior.

Before validation values are opened, seal corpus-derived reference ranges from
the locked 20-session corpus and numeric mechanically evaluable flag rules for
every load-bearing summary. Flags require adjudication and are not automatic
biological exclusions. Rules do not move after values become visible.

Replay at least one ordinary session with identical inputs, model, and pinned
environment. If represented rig-specific or full-pipeline paths are materially
different, replay one per distinct path when practical. Two rig names alone do
not justify two replays if the replayed computation is the identical downstream
path. Outputs expected to be deterministic must match exactly. Any component
requiring an equivalence criterion must have that criterion frozen before the
replay result is seen.

## 10. Tier D — qualitative syllable and crowd-movie review

Tier D begins only after visualization qualification passes. Generate crowd
movies from the frozen production model for the validation set.

Review every syllable needed to cover 90% cumulative validation-frame mass,
plus every additional syllable exceeding 2% usage in any individual validation
session. Blind reviewers to genotype and treatment identity.

For each syllable assess:

- recognizable, temporally coherent movement or postural motif;
- absence of arbitrary mixing;
- anatomically plausible rendered orientation;
- absence of the known 180-degree flip artifact;
- absence of extraction-artifact dominance;
- absence of boundary clipping, floor, or ROI-failure dominance;
- whether a high-mass state is a garbage collector for heterogeneous motion.

Record every per-syllable verdict and reason before discussing or recording the
aggregate judgment. The aggregate must derive from those frozen individual
calls. A materially incoherent high-mass syllable causes `HOLD`. Rare low-mass
oddities outside the required set may be documented without automatic failure.

At least one domain scientist familiar with the assay—Katya or a designated
equivalent—must participate. AI may assist but cannot substitute for domain
judgment.

## 11. Tier E — operator, provenance, and fail-loud behavior

Every validation run identifies its input session, model, PCA/config,
source/environment, status, output location, and failure/HOLD condition. No
silent overwrite is permitted. A failed or incomplete operation must produce
an actionable failure, never a normal-looking result.

Run one bounded negative control for an exact invalid-input or provenance
condition frozen before validation execution. It must demonstrate fail-loud
behavior without mutating source recordings.

## 12. Dispositions

### `PASS_REAL_SESSION_PRODUCTION_VALIDATION`

Requires all of the following:

- roster frozen before result inspection;
- load-bearing identity and provenance complete;
- valid input/extraction dispositions for ordinary sessions;
- no unresolved scientific OOD HOLD;
- replay or predeclared equivalence passes;
- visualization qualification passes;
- required high-mass syllable review is coherent;
- operator/provenance behavior is traceable and fail-loud;
- no model, PCA, or pipeline retuning against validation outputs.

### `HOLD_REAL_SESSION_PRODUCTION_VALIDATION`

Use when evidence is incomplete, a value breaches a frozen rule, visualization
qualification is unresolved, a high-mass syllable is incoherent, or meaningful
ambiguity needs adjudication. Do not tune through `HOLD`.

### `FAIL_REAL_SESSION_PRODUCTION_VALIDATION`

Reserve for reproducible, material scientific or operational defects showing
that the frozen pipeline cannot be trusted for intended use without change.

## 13. Required pre-seal bindings

R1 may not become `SEALED` until these are bound without inspecting
validation-model outputs:

1. exact UUID roster of the locked 20-session fitting corpus;
2. metadata-only eligible outside-corpus inventory with rig, animal, date, raw
   QC, and prior processing/result-inspection history;
3. exact selected roster, modeled/inspected exceptions, predetermined
   replacements, and expected-flag dimensions for deliberate challenges;
4. authoritative repaired visualization identity and 180-degree regression;
5. exact supported PCA/model global QC statistics;
6. corpus-derived Tier-B/Tier-C envelopes and numeric mechanical flag rules;
7. exact Tier-E negative-control condition;
8. deterministic replay plan and decision on materially distinct paths.

The only next authorized scientific operation is bounded read-only
reacquisition and freeze work for these eight items. Validation execution is a
separate later operation after Architect sealing and authorization.

## 14. Golden regression policy

After a successful validation PASS, designate accepted validation-run outputs
as the initial golden regression reference while full provenance exists.
Preserve model and PCA identity, environment, input checksums, deterministic
labels or other load-bearing outputs, QC diagnostics, and hashes/receipts.

This does not delay initial use of the validated pipeline. It blocks a future
optimized or modernized replacement from displacing the accepted pipeline
without demonstrated equivalence.

## 15. Performance and production-QC policy

Standing rule: **correct first, fast second**. Performance work cannot delay or
contaminate production validation or reopen model selection. Later profiling
may cover CPU, multiprocessing, RAM, WSL configuration, I/O, BLAS/threading,
checkpoint overhead, and environment modernization only behind the golden
equivalence gate.

Production QC is a small fixed battery: timestamps/drop frames, depth and
metadata coherence, ROI/floor/extraction health, void/speckle behavior,
provenance, PCA/OOD diagnostics, gross usage/duration sanity, explicit run
completion, and no silent overwrite. Out-of-family behavior normally flags or
holds for adjudication rather than automatically excluding data.

## 16. Nonblocking durability and future-study backlog

A fixed-reference drift canary and rig-substitution policy are desirable for
long-term Kinect v2 / legacy-stack durability, but do not block first valid use.

The proposed longitudinal anti-aging program is a separate future project. It
must start from biological dimensions, observable phenotypes, and suitable
repeatable measurement systems; it must not assume MoSeq or Kinect is the
answer. It is outside this validation gate.
