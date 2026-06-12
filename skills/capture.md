# Research Kit: Capture Skill

Guidance for an agent executing the `research.capture` flow.

## Purpose

The capture flow ingests one source — a transcript, article, web page, or discussion excerpt — and gates progression at each step. Your job is to satisfy each gate's evidence requirement before advancing.

## Step 1: receive-source

Collect the raw source content. The gate (`receive-source-gate`) requires a `research.capture.source-received` claim on the artifact.

Checklist:
- Source text is non-empty.
- If the source is a URL, fetch its content and store it alongside the URL.
- Record the character count or word count as a basic completeness signal.

## Step 2: record-provenance

Record where the source came from. The gate (`record-provenance-gate`) requires a `research.capture.provenance-ref` claim.

Checklist:
- URL, DOI, citation, author + date, or speaker + meeting context — whichever applies.
- If a source cannot be attributed, it must not advance. Mark it blocked and surface the gap.
- Store the ref in the record's metadata, not only in the prose.

## Step 3: classify-source

Classify the source. The gate (`classify-source-gate`) requires a `research.capture.classification` claim.

Suggested categories:
- `transcript` — meeting, interview, or talk recording
- `article` — published written work
- `reference` — technical spec, documentation, standard
- `discussion` — forum thread, chat, informal exchange
- `note` — first-person notes or diary entry

Checklist:
- Category must be non-empty.
- Content-type label (e.g. `video-transcript`, `blog-post`, `rfc`) refines the category.
- Both category and content-type must be stored alongside the provenance ref.

## Knowledge Kit substrate

This kit's store strategy is left to the workspace. If the workspace has the Knowledge Kit installed, captured sources map to `type='raw'` records. See the Knowledge Kit store contract for the create-op provenance requirements that a compatible store must satisfy.
