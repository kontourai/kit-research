# Research Kit: Compile Skill

Guidance for an agent executing the `research.compile` flow.

## Purpose

The compile flow synthesises one or more previously captured sources into an insight note. Provenance is mandatory: every insight must trace back to its contributing sources.

## Step 1: select-sources

Choose which captured sources to compile. The gate (`select-sources-gate`) requires a `research.compile.source-selection` claim.

Checklist:
- Select by ID (not by title or text match) to ensure the link is durable.
- At least one source ID must be provided.
- Each selected ID must resolve to an existing captured source. Reject IDs that do not resolve before advancing.

## Step 2: draft-insight

Write the insight note. The gate (`draft-insight-gate`) requires a `research.compile.insight-draft` claim.

Checklist:
- The draft must be non-trivial (more than a copy-paste of the source).
- Extract key points, tensions, open questions, or decisions from the selected sources.
- Flag uncertainty where sources conflict or are ambiguous.
- Do not store the note yet — the next step handles storage with provenance.

## Step 3: record-provenance

Store the insight note with provenance links. The gate (`record-provenance-gate`) requires a `research.compile.provenance-links` claim.

Checklist:
- The stored note's `provenance.source_ids` must list every selected source ID.
- Each source ID must be resolvable after storage.
- Notes without traceable provenance must not be stored. If a source ID became unresolvable, surface the gap and do not advance.

## Knowledge Kit substrate

If the workspace has the Knowledge Kit installed, compiled insight notes map to `type='compiled'` records. The Knowledge Kit compile flow's `link-integrity` gate is the equivalent gate in that substrate. You may run both flows in sequence — capture first, then compile — sharing the same source IDs.
