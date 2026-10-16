# Research Kit

**Status: EXPERIMENTAL prototype.** Research Kit explores source-traced research as a third-party Flow Kit. It was authored outside Flow Agents to exercise the authoring path in [flow-agents#50](https://github.com/kontourai/flow-agents/issues/50).

This repository contains three flow definitions, a `kit.json` container manifest, and Markdown guidance. It supplies no store, ingestion service, retrieval implementation, provider adapter, or execution engine. Production use, provider behavior, and live activation are unverified here.

## Flow contracts

| Flow | Intent | Guidance |
| --- | --- | --- |
| `research.capture` | Receive a source, record provenance, classify it | [Capture skill](../skills/capture.md) |
| `research.compile` | Select sources, draft an insight, record provenance links | [Compile skill](../skills/compile.md) |
| `research.recall` | Form a query, retrieve results, verify provenance | [Recall skill](../skills/recall.md) |

Read the [source contracts and storage boundaries](contracts.md) before adapting the flows. Their gates declare required claims. A compatible host must evaluate those claims and enforce progression; reading or installing the definitions does not prove enforcement or source truth.

## Try the prototype from source

Use a disposable workspace and an explicit Research Kit revision. These commands reproduce the tool version recorded in the [authoring findings](../FINDINGS.md); they are an experimental path, not a claim that this version is current or qualified. Prerequisites are Git, Node.js, npm, network access, and a reviewed Flow Agents package.

```sh
git clone https://github.com/kontourai/kit-research.git
cd kit-research
git checkout <reviewed-research-kit-commit>
research_kit_root="$PWD"
research_workspace="$(mktemp -d "${TMPDIR:-/tmp}/research-kit.XXXXXX")"

npm exec --yes --package=@kontourai/flow-agents@0.4.0 -- flow-agents flow-kit install-local "$research_kit_root" --dest "$research_workspace"
npm exec --yes --package=@kontourai/flow-agents@0.4.0 -- flow-agents flow-kit list --dest "$research_workspace"
npm exec --yes --package=@kontourai/flow-agents@0.4.0 -- flow-agents flow-kit status research --dest "$research_workspace"
npm exec --yes --package=@kontourai/flow-agents@0.4.0 -- flow-agents flow-kit activate --dest "$research_workspace" --format json
```

Inspect the actual exit status, `errors`, `skipped_assets`, adapter output, and copied bytes. The earlier experiment observed flow files under `.flow-agents/runtime/codex/flows/research/` and `.flow-agents/runtime/strands/flows/research/`; file presence proves copying only. It does not prove a provider loaded or executed a flow. This repository supplies no flow-execution command: execution requires a separately configured host, claim evidence, and store.

The historical `0.4.0` activation could exit non-zero despite writing files because a catalog was missing in the npm cache context ([F-3](../FINDINGS.md#f-3-activate-exits-1-in-npx-context--catalogjson-false-failure)). Treat that as failed activation with partial output. The findings also reported local-only installation and skipped skill/doc activation. Check current tooling and issue status before drawing conclusions about newer versions.

## Evidence limits

[FINDINGS.md](../FINDINGS.md) preserves the original third-party authoring report and five friction findings. Its validation and runtime-file observations belong to that experiment. The report's “fully functional” wording and final verdict are historical conclusions, not current production evidence.

The existing [Kit Validation workflow](https://github.com/kontourai/kit-research/blob/main/.github/workflows/validate.yml) builds a moving Flow `main` and invokes an unpinned Flow Agents package. Its activation step catches a non-zero exit before checking file presence. A green workflow therefore cannot establish clean activation or provider execution. This documentation adoption does not requalify that experiment or change flow logic.

## Maintain the documentation

See [validation and maintenance](maintenance.md) for source validation, the pinned Corpus commands, source ownership, and the distinction between local docs builds and live Pages or MCP activation.
