# Research Kit: Recall Skill

Guidance for an agent executing the `research.recall` flow.

## Purpose

The recall flow queries the knowledge store for prior captured sources and compiled insights. Every result returned to the caller must carry provenance so that the agent's downstream reasoning can be traced.

## Step 1: form-query

Articulate the query. The gate (`form-query-gate`) requires a `research.recall.query` claim.

Checklist:
- Specify the query intent: keyword terms, a topic description, or a semantic embedding target.
- Specify the scope: `captured`, `compiled`, or `both`.
- Optional: date range, category filter, or tag filter.

## Step 2: retrieve-results

Execute the query against the knowledge store. The gate (`retrieve-results-gate`) requires a `research.recall.results` claim.

Checklist:
- An empty result set is a valid outcome — record it as such.
- A retrieval failure (store error, timeout, index unavailable) is not valid — surface the failure before advancing.
- Return raw results including their metadata; do not filter yet (that is the next step's job).

## Step 3: verify-provenance

Filter and verify provenance on results. The gate (`verify-provenance-gate`) requires a `research.recall.provenance-verified` claim.

Checklist:
- Every non-empty result must carry either a `source_id` (resolves to a captured or compiled record) or a `source_ref` (direct citation).
- Remove results that carry no provenance. Log each removed result.
- If the entire result set is removed by provenance filtering, the recall returns empty (valid) with a note explaining provenance failures.
- Surface the final provenance-verified list as the gate evidence payload.

## Knowledge Kit substrate

If the workspace has the Knowledge Kit installed, the recall query targets the same store that capture and compile write to. The Knowledge Kit store contract's `get()` and `listByType()` / `listByCategory()` operations are the retrieval primitives. `includeRetired` is off by default; pass it explicitly if retired records should be visible.
