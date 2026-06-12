# Research Kit

A Flow Kit for source-traced research workflows. Three flows cover the full cycle from raw source ingestion to provenance-verified recall.

## Flows

| Flow | What it does | Key gate |
|---|---|---|
| `research.capture` | Ingest a source (transcript, article, URL) with provenance | Source ref + classification must be recorded |
| `research.compile` | Compile captured sources into an insight note | Provenance links to every contributing source must be recorded |
| `research.recall` | Query prior captured and compiled knowledge | Every result must carry provenance back to its originating source |

All three flows enforce provenance at the gate level. A source without a traceable reference cannot advance past `record-provenance`. A compiled note without source links cannot be stored. A recall result without provenance is excluded before the gate can pass.

## Relationship to the Knowledge Kit

The Research Kit defines the **workflow contract** (gates, steps, evidence expectations). It does not define a store implementation.

If a workspace has the [Knowledge Kit](https://kontourai.github.io/flow-agents/knowledge-kit) installed, the Research Kit composes naturally on top of it:

- `research.capture` captured sources → Knowledge Kit `type='raw'` records
- `research.compile` compiled insights → Knowledge Kit `type='compiled'` records
- `research.recall` queries → Knowledge Kit store `listByType`, `listByCategory`, `get()` operations

The Knowledge Kit's store contract (provenance requirements, mutation gates, supersede-not-delete invariant) is the substrate. The Research Kit adds the workflow gates that govern when an agent may write to or read from that substrate.

Neither kit imports the other's code. They compose through the shared store interface and the shared concept of `source_id` provenance references. Zero vendor lock-in between kits.

## Skills

The `skills/` directory contains agent guidance for each flow:

- `skills/capture.md` — how to extract source refs, choose classification categories, and record provenance
- `skills/compile.md` — how to select sources, draft insight notes, and link provenance
- `skills/recall.md` — how to form queries and verify provenance on results

Skills are markdown guidance assets. They are listed in `kit.json` under both `skills` and `docs` so that any runtime that surfaces docs to agents will also surface skill guidance.

## Activation

Install into a workspace via the flow-agents kit tooling:

```sh
npx @kontourai/flow-agents flow-kit install-local /path/to/kit-research --dest /your/workspace
npx @kontourai/flow-agents flow-kit activate --dest /your/workspace --format json
```

Or from a git ref (once remote install is available — see FINDINGS.md):

```sh
# Remote install is not yet supported in the end-user path. See FINDINGS.md.
```

After activation, the three flow definitions appear in `.flow-agents/runtime/codex/flows/research/`. The `codex-local` adapter reads them for Claude Code, Codex, and Kiro. The `strands-local` adapter reads the same activation output for AWS Strands workloads.

Skills and docs are listed as `skipped_assets` in the activation output — they are declared but not yet activated by any adapter. See FINDINGS.md, Finding F-4.

## Validation

To validate the kit's container manifest against the [Flow Kit container contract](https://kontourai.github.io/flow/flow-kit-container):

```sh
# Using the @kontourai/flow CLI (requires a flow repo build):
node /path/to/flow/dist/cli.js validate-kit /path/to/kit-research --json

# Using the flow-agents validate script in this repo:
./validate.sh
```

The `validate.sh` script at the kit root also runs `flow validate-definition` on each flow file.

## Authoring notes

This kit was authored as a third-party kit outside the `kontourai/flow-agents` monorepo to exercise the end-user authoring path and surface integration gaps. Findings are indexed in [FINDINGS.md](../FINDINGS.md) with links to the resulting `kontourai/flow-agents` issues.

**Zero imports of flow-agents code.** This kit contains only Flow Definitions (`.flow.json`), a manifest (`kit.json`), skill guidance (`.md`), and this documentation. No `require()` or `import` of any flow-agents internal. The contract boundary is the published `kit.json` schema and the flow CLI's `validate-kit` command.
