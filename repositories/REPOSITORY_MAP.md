# Repository Map

## Responsibility boundaries

| Repository | Primary responsibility | Produces | Must not silently own |
|---|---|---|---|
| `moseq2-extract` | Convert raw depth recordings into per-session extracted frames, metadata, and scalar features. | Extracted HDF5/session outputs and extraction provenance. | PCA/model semantics or downstream biological interpretation. |
| `moseq2-pca` | Build and apply the dimensionality-reduction transform to aligned extracted data. | PCA artifacts and score files with PCA provenance. | Extraction-unit conversion or model-label semantics. |
| `moseq2-model` | Fit and serialize behavioral models from aligned PCA outputs. | Model results, labels, keys, and model provenance. | Repairing upstream session alignment or scalar units. |
| `moseq2-viz` | Load, join, validate, summarize, and visualize extract/PCA/model outputs. | Analysis tables, plots, and summaries. | Declaring incompatible or unknown upstream outputs compatible. |
| `moseq2-app` | Provide interactive workflow controllers around pipeline operations. | User-driven configuration and controlled in-place operations such as flip correction. | Reprocessing uncertain partial outputs or rewriting upstream provenance claims. |
| `moseq2-pipeline-control` | Lock revisions, coordinate review, record findings/evidence, and define structural acceptance. | Durable state, manifests, review records, and validation controls. | Runtime package behavior, raw data storage, merges, or biological conclusions. |

## Dependency and evidence flow

```text
raw recordings (external)
        |
        v
moseq2-extract --> extracted sessions/scalars + extraction provenance
        |
        v
moseq2-pca ----> PCA artifacts/scores + PCA provenance
        |
        v
moseq2-model --> model results/labels/keys + model provenance
        |
        +--------------------+
        |                    |
        v                    v
   moseq2-viz           moseq2-app
 load/join/validate     orchestrate controlled operations
        \                    /
         \                  /
          v                v
       manifests, logs, bounded evidence, and findings
                         |
                         v
              moseq2-pipeline-control
```

`moseq2-pipeline-control` is a control plane, not a runtime dependency. The implementation repositories must remain usable without importing it.

`shared-evidence-exchange` is an unrelated, currently unused experimental tooling repository. It is not part of this repair phase.
