# Third-Party Kit Authoring: Friction Findings

This file indexes every friction point discovered while authoring the Research Kit outside the `kontourai/flow-agents` monorepo. Each finding has a corresponding issue in `kontourai/flow-agents` with a proposed fix direction.

## Context

The Research Kit was authored in this repo (`kontourai/kit-research`) to exercise the full third-party authoring path described in `kontourai/flow-agents#50`. The experiment covered:

1. Authoring `kit.json` per the Flow Kit container contract (kontourai/flow PR #67).
2. Validating with `flow validate-kit` from the `@kontourai/flow` CLI.
3. Installing into a scratch workspace using `npx @kontourai/flow-agents@0.4.0 flow-kit install-local`.
4. Activating via the `codex-local` and `strands-local` adapters.

## What worked

- Kit authoring: authoring `kit.json`, `.flow.json` definitions, and `skills/*.md` guidance files with zero imports of flow-agents code — **fully functional**.
- Container validation: `flow validate-kit /tmp/kit-research --json` returns `{"valid":true,"error_count":0}` after building the flow CLI from source.
- Flow-definition validation: all three definitions (`research.capture`, `research.compile`, `research.recall`) pass `flow validate-definition --json`.
- Install: `npx @kontourai/flow-agents@0.4.0 flow-kit install-local <local-path> --dest <workspace>` installs the kit correctly. `flow-kit list` and `flow-kit status research` show the installed kit with the correct hash.
- Activation (runtime files): all three `.flow.json` files appear correctly in `.flow-agents/runtime/codex/flows/research/` and `.flow-agents/runtime/strands/flows/research/` after activation. The flow gate structure is fully available to both adapters.

## Findings (actionable gaps)

### F-1: install-local always warns "Flow validation surface unavailable"

**Issue:** https://github.com/kontourai/flow-agents/issues/55

**Expected:** Install validates against `flow validate-kit` from `@kontourai/flow`.

**Actual:**
```
warning: Flow validation surface unavailable; local kit check uses the minimal Flow Definition fallback
installed local kit 'research' at .../kits/local/repositories/research
```
The warning fires unconditionally. The internal fallback does validate, but the warning looks like an error to authors.

**Command:** `npx @kontourai/flow-agents@0.4.0 flow-kit install-local /tmp/kit-research --dest /tmp/scratch`

---

### F-2: No git-ref or remote install — install-local only

**Issue:** https://github.com/kontourai/flow-agents/issues/56

**Expected:** `flow-kit install-git https://github.com/kontourai/kit-research` or equivalent.

**Actual:** Passing a URL to `install-local` treats it as a relative path and fails with an ENOENT:
```
Flow Kit repository validation failed:
 - /tmp/scratch/https:/github.com/kontourai/kit-research/kit.json: invalid JSON: ENOENT
```
`flow-kit --help` confirms only `install-local|list|status|activate` exist.

**Command:** `npx @kontourai/flow-agents@0.4.0 flow-kit install-local https://github.com/kontourai/kit-research --dest /tmp/scratch`

---

### F-3: activate exits 1 in npx context — catalog.json false failure

**Issue:** https://github.com/kontourai/flow-agents/issues/57

**Expected:** `flow-kit activate` exits 0 when all runtime files are written successfully.

**Actual:** Exits 1 with error even though all three flow files were written correctly:
```json
"errors": ["/Users/runner/.npm/_npx/.../node_modules/kits/catalog.json: missing Kit Catalog"]
```
The `sourceRoot` defaults to the npm cache directory (not a flow-agents checkout), which has no `kits/catalog.json`. The built-in catalog check is an internal concern that incorrectly fails external users.

**Workaround:** `--source-root /path/to/flow-agents` silences it, but this is undocumented and requires a checkout.

**Command:** `npx @kontourai/flow-agents@0.4.0 flow-kit activate --dest /tmp/scratch --format json`

---

### F-4: skills and docs are skipped_assets with no activation path

**Issue:** https://github.com/kontourai/flow-agents/issues/58

**Expected:** `skills/*.md` declared in `kit.json` are copied to the runtime so agents can use skill guidance alongside flow definitions.

**Actual:** All seven skill/doc entries appear as `skipped_assets` with reason `"asset class is diagnostic-only for codex-local"`. Skill guidance is declared but never surfaced to the agent at runtime.

This is the most significant functional gap for kit authors: the skills layer has no activation path.

---

### F-5: flow validate-kit requires building @kontourai/flow from source

**Issue:** https://github.com/kontourai/flow-agents/issues/59

**Expected:** `npx @kontourai/flow validate-kit <kit-dir>` works out of the box.

**Actual:** `@kontourai/flow` is not published to npm:
```
npm error 404 Not Found - GET https://registry.npmjs.org/@kontourai/flow
```
Running `flow validate-kit` requires cloning the repo and building it (4 commands, requires git + Node + npm + build environment).

**Command:** `npm view @kontourai/flow` → 404

The kit-authoring guide references `flow validate-kit` without explaining how to obtain the CLI.

---

## Verdict

A third party **can** author a valid kit today — the container contract is well-specified, the flow definition schema is solid, and the install-local + activate path works end-to-end for the core deliverable (flow runtime files). **The kit authoring contract is real and usable.**

However, the end-user experience has five material gaps:

| # | Gap | Severity |
|---|---|---|
| F-1 | Persistent false warning on every install | Medium — erodes trust |
| F-2 | No git-ref or remote install | High — blocks distribution |
| F-3 | activate exits 1 in npx context | High — breaks CI |
| F-4 | Skills not activated | High — key feature absent |
| F-5 | flow validate-kit not available via npx | Medium — CI setup friction |

F-2 (no remote install) and F-3 (activate exits 1) together mean that a third party publishing to GitHub or npm has no clean end-user install + activate story today. The workarounds require either a local clone or a hidden `--source-root` flag. These should be fixed before advertising the third-party authoring path.
