# Validation and maintenance

## Validate the source

Use a reviewed, already built Flow checkout that provides `validate-kit` and `validate-definition`. Supply its entry point explicitly to prevent `validate.sh` from cloning and installing unpinned upstream code:

```sh
FLOW_CLI_SCRIPT=/absolute/path/to/flow/dist/cli.js bash ./validate.sh
```

[`validate.sh`](../validate.sh) calls `flow validate-kit` for the container and `flow validate-definition` for every flow. Without `FLOW_CLI_SCRIPT`, it attempts to clone and build Flow automatically. Its `FLOW_CLI` usage comment is not an implemented override; use `FLOW_CLI_SCRIPT`.

Successful validation establishes container/definition acceptance by that CLI revision. Record the Flow revision, kit revision, command, exit status, and diagnostics. It does not establish gate enforcement, store durability, provider behavior, or production readiness. If no built CLI is available, report validation as **NOT_RUN**, with the missing prerequisite.

## Documentation ownership

`docs/README.md` is the landing page. `corpus.json` curates the root README, contract guide, maintenance guide, skill guidance, and historical findings. The findings are retained as evidence history; update the overview with current, revision-bound results instead of silently rewriting the original observations.

The manifest's `allowLocalPaths` entry is limited to `FINDINGS.md`, which contains a historical runner-home error excerpt. Corpus skips dependency comparison when there is no `package.json`; a passing documentation check therefore does not verify `builtOn` relationships for this kit.

When `kit.json`, `flows/`, or `skills/` changes, review [contracts](contracts.md) and the affected skill against the new source. The contracts guide owns those semantic source bindings in `covers`. When `validate.sh` or workflows change, update this maintenance guide. Keep topics and local links valid. The root README stays a short entry point.

## Check and build docs

Run the same pinned Corpus revision used by the [Docs workflow](https://github.com/kontourai/kit-research/blob/main/.github/workflows/docs.yml). No local package manifest or install is required. Corpus requires Node.js 22 or newer.

```sh
npm exec --yes --package=github:kontourai/corpus#340b66fc8f723c1babe35fce8240c82cd196b0db -- corpus check
research_docs_out="$(mktemp -d "${TMPDIR:-/tmp}/research-docs.XXXXXX")/site"
npm exec --yes --package=github:kontourai/corpus#340b66fc8f723c1babe35fce8240c82cd196b0db -- corpus build --out "$research_docs_out"
# After committing, also check source/doc co-change against the review base:
npm exec --yes --package=github:kontourai/corpus#340b66fc8f723c1babe35fce8240c82cd196b0db -- corpus check --base <review-base-commit>
```

The Docs workflow runs the shared documentation gate for pull requests and merge groups. Main pushes and manual dispatches can build and deploy Pages after that gate passes, once repository Pages is configured. A local build creates a site and source-bound `docs-bundle.json` for Corpus consumers, including MCP; it does not establish live Pages deployment, catalog inclusion, or an active MCP connection. Keep those activation receipts separate from local checks.

The existing [Kit Validation workflow](https://github.com/kontourai/kit-research/blob/main/.github/workflows/validate.yml) checks container/definition validity and runtime file presence. It uses moving upstream tooling and catches activation errors, as explained in the [overview's evidence limits](README.md#evidence-limits). It cannot qualify provider execution or clean activation.
