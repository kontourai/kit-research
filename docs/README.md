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

Use Node.js 22 or later and the pinned pnpm 11.25.0. Check out a reviewed kit revision before installing its development tooling:

```sh
git clone https://github.com/kontourai/kit-research.git
cd kit-research
git checkout <reviewed-research-kit-commit>
pnpm install --frozen-lockfile
npm run validate
npm run validate:install
```

`validate` checks the container and all three definitions with the local published `@kontourai/flow@5.2.0` CLI. `validate:install` archives committed HEAD into a disposable local source, installs it under an owned temporary destination with `flow kit install`, verifies all declared asset bytes, inspects flow IDs and structural asset-class names, and validates the installed definitions. Its temporary HOME/config/cache/destination are removed on exit. It does not install into an existing workspace or activate any runtime.

For a manual structural inspection of an isolated installation:

```sh
research_scratch="$(mktemp -d "${TMPDIR:-/tmp}/research-kit.XXXXXX")"
mkdir -p "$research_scratch/source"
git archive HEAD | tar -xf - -C "$research_scratch/source"
node node_modules/@kontourai/flow/dist/cli.js kit install "$research_scratch/source" --dest "$research_scratch/install"
node node_modules/@kontourai/flow/dist/cli.js kit inspect "$research_scratch/install/research" --json
```

Flow copies a kit container as-is and reports structure. Archiving HEAD prevents local dependencies and untracked files from becoming assets. `kit inspect` lists `docs` and `skills` as declared asset classes; it does not load them into an agent or qualify their runtime behavior. Remove the disposable directory after inspection. Execution requires a separately configured host, real claim evidence, and a store.

## Evidence limits

The definitions use version `1.1` and Flow's current `trust.bundle` / `bundle_claim` selectors. Local checks against published Flow 5.2.0 establish container/definition acceptance and isolated local install/inspection, not gate enforcement, source truth, store durability, provider execution, or live activation. The [maintenance guide](maintenance.md) describes the exact checks and failure control. The Kit Validation workflow runs that same pinned path on Node 22 and 24; hosted results must be checked separately.

[FINDINGS.md](../FINDINGS.md) preserves the original third-party authoring report and five friction findings from `@kontourai/flow-agents@0.4.0`. Its validation/runtime-file observations and “fully functional” verdict belong to that historical experiment. Those commands are not the current supported validation route. The former CI cloned moving Flow source, used obsolete `validate-kit` / Flow Agents commands, and caught activation failures; that history cannot qualify this migration or any provider.

## Maintain the documentation

See [validation and maintenance](maintenance.md) for source validation, the pinned Corpus commands, source ownership, and the distinction between local docs builds and live Pages or MCP activation.
