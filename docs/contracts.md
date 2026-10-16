# Source contracts and storage boundaries

Research Kit is an experimental collection of declarative assets. [`kit.json`](../kit.json) registers three flows and three skills. Each skill also appears under `docs`, alongside the overview. Declaration does not establish that an adapter surfaces those assets to an agent. The historical experiment reported skipped skill/doc assets; see [F-4](../FINDINGS.md#f-4-skills-and-docs-are-skipped_assets-with-no-activation-path).

## Capture

[`research.capture`](../flows/research.capture.flow.json) advances through `receive-source`, `record-provenance`, and `classify-source` to `done`. The gates require claims of types `research.capture.source-received`, `research.capture.provenance-ref`, and `research.capture.classification`. Their descriptions require non-empty source content, a traceable reference, and classification with a category and content-type label.

The [capture skill](../skills/capture.md) asks the executing agent to store attribution and classification in metadata. It provides suggested categories; the JSON definition does not implement extraction, fetching, or storage.

## Compile

[`research.compile`](../flows/research.compile.flow.json) advances through `select-sources`, `draft-insight`, and `record-provenance` to `done`. It requires `research.compile.source-selection`, `research.compile.insight-draft`, and `research.compile.provenance-links` claims. Their descriptions call for existing source IDs, a draft, and a stored note whose `provenance.source_ids` lists every contributing source.

The [compile skill](../skills/compile.md) asks the agent to select by durable ID, reject unresolved sources, and store only with traceable provenance. The repository does not implement resolution or writes.

## Recall

[`research.recall`](../flows/research.recall.flow.json) advances through `form-query`, `retrieve-results`, and `verify-provenance` to `done`. It requires `research.recall.query`, `research.recall.results`, and `research.recall.provenance-verified` claims. Query scope must be specified. An empty result set is valid; retrieval errors or timeouts are not. Every remaining result must have a traceable `source_id` or `source_ref`.

The [recall skill](../skills/recall.md) asks the agent to exclude results without provenance and log removals. This repository does not implement retrieval or filtering.

## Claims and storage

All nine gate expectations are required `surface.claim` entries on an `artifact`, accepting `trusted` or `accepted` status. A compatible host must evaluate the claims, bind them to the right artifact, and enforce progression. A valid definition alone does not establish any of that behavior.

The skills describe an optional Knowledge Kit mapping: captured sources to `type='raw'`, compiled insights to `type='compiled'`, and recall through a workspace store. This is an authoring relationship, not a tested store integration. Confirm the selected store's current API, provenance requirements, and history visibility before adapting the guidance, including its historical `includeRetired` wording.

Neither a Knowledge Kit dependency nor a Corpus store adapter is declared here. The kit has no npm dependency manifest; `corpus.json` uses `builtOn: []` rather than inventing a verified package dependency. [Flow](https://github.com/kontourai/flow) defines the container/definition contracts, [Flow Agents](https://github.com/kontourai/flow-agents) supplies the experimental install/activation tooling, and [Corpus](https://github.com/kontourai/corpus) projects this documentation. None of those relationships proves runtime integration.
