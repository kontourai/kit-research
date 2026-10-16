# Validation and maintenance

## Validate the source

Use Node.js 22 or later and pnpm 11.25.0, pinned in the private root tooling package:

```sh
pnpm install --frozen-lockfile
npm run validate
npm run validate:install
```

The lockfile pins published `@kontourai/flow@5.2.0` and its dependency graph. The root package is private development tooling, not an npm-distributed kit or a kit release version. The [Kit Validation workflow](https://github.com/kontourai/kit-research/blob/main/.github/workflows/validate.yml) runs frozen installs and these two commands on Node 22 and 24, including pull requests and merge groups.

[`validate.sh`](../validate.sh) calls `flow kit validate` for the container and `flow validate-definition` for every flow. It requires both a successful CLI exit and JSON `valid: true`; malformed output, missing prerequisites, and rejected definitions fail. It reports each invalid flow and exits nonzero after the checks. It never clones, installs, or builds a CLI automatically. An owned reviewed CLI can be supplied explicitly:

```sh
FLOW_CLI_SCRIPT=/absolute/path/to/reviewed/flow/dist/cli.js npm run validate
```

Record the actual version when overriding the package-local CLI; an override is not proof of the pinned default. `FLOW_CLI` and `FLOW_REPO_DIR` are no longer supported overrides.

### Compatibility migration and proof

Flow 5.2.0 accepts the kit container but rejects the original nine `surface.claim` expectations. Definition version `1.1` uses `trust.bundle` with `bundle_claim.claimType` and `subjectType`. The nine claim types, `artifact` subject type, `trusted` / `accepted` statuses, required flags, descriptions, and gate/step order remain unchanged. The old `validate-kit` command is now `kit validate`.

The local validation route checks all three migrated definitions against the published CLI. The installation smoke uses `git archive HEAD`, an owned temporary HOME/config/cache/destination, and the real public `kit install` and `kit inspect` commands. It compares installed manifest/declared asset bytes, checks flow IDs and asset-class names, and validates the installed container and definitions. Commit before running that smoke: it deliberately tests HEAD rather than unstaged source. It is structural installation proof, with no Flow Agents activation.

For a regression control, start from a clean committed tree, revert one migrated expectation kind to `surface.claim`, and run `npm run validate`. The named definition must fail with `definition.expectation.kind.unsupported`; restore the committed bytes and rerun validation successfully. A missing CLI must likewise produce a nonzero exit. Preserve the exit statuses and diagnostics; do not count a wrapper exit or missing prerequisite as a pass.

Successful checks establish acceptance and copying by that CLI revision. They do not establish gate enforcement, store durability, provider behavior, or production readiness. Record the kit revision, Flow version, commands, statuses, and diagnostics. Report unavailable runtime evidence explicitly.

## Documentation ownership

`docs/README.md` is the landing page. `corpus.json` curates the root README, contract guide, maintenance guide, skills, and historical findings. Keep [FINDINGS.md](../FINDINGS.md) unchanged as evidence history; put current, revision-bound conclusions in the canonical guides.

The manifest's `allowLocalPaths` entry is limited to `FINDINGS.md`, which contains a historical runner-home error excerpt. `builtOn` declares Flow through the actual pinned development dependency; it does not declare a Flow Agents or Knowledge integration.

When `kit.json`, `flows/`, or `skills/` changes, update [contracts](contracts.md) and review the affected skill. When validation scripts, tooling dependencies/lockfile, or workflows change, update this guide. The `covers` routes bind those sources to their canonical docs. Keep topics and local links valid; the root README stays a short entry point.

## Check and build docs

Use the same reviewed Corpus revision as the [Docs workflow](https://github.com/kontourai/kit-research/blob/main/.github/workflows/docs.yml):

```sh
npm run docs:check
npm run docs:build
# After committing, check source/doc co-change against the review base:
npm run docs:check -- --base <review-base-commit>
```

Both scripts pin Corpus commit `340b66fc8f723c1babe35fce8240c82cd196b0db`. The default output is ignored `dist-pages/`, including a source-bound `docs-bundle.json` for Corpus consumers such as MCP. The Docs workflow gates PRs and merge groups; main pushes and dispatches can deploy Pages after the gate once repository Pages is configured. Local output does not establish live deployment, catalog inclusion, or an active MCP connection.
