#!/usr/bin/env bash
# Exercise Flow's public local-directory install/inspect contract at committed HEAD.
set -euo pipefail

KIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FLOW_CLI_SCRIPT="${FLOW_CLI_SCRIPT:-$KIT_DIR/node_modules/@kontourai/flow/dist/cli.js}"
if [ ! -f "$FLOW_CLI_SCRIPT" ]; then
  echo "Flow CLI missing: $FLOW_CLI_SCRIPT. Install the pinned dependencies first." >&2
  exit 1
fi
FLOW_CLI_SCRIPT="$(cd "$(dirname "$FLOW_CLI_SCRIPT")" && pwd)/$(basename "$FLOW_CLI_SCRIPT")"
research_scratch="$(mktemp -d "${TMPDIR:-/tmp}/research-kit-install.XXXXXX")"
trap 'rm -rf "$research_scratch"' EXIT
mkdir -p "$research_scratch/source" "$research_scratch/home" "$research_scratch/config" "$research_scratch/cache"
export HOME="$research_scratch/home"
export XDG_CONFIG_HOME="$research_scratch/config"
export XDG_CACHE_HOME="$research_scratch/cache"

# Archive tracked HEAD so development dependencies and untracked files do not become kit assets.
git -C "$KIT_DIR" archive HEAD | tar -xf - -C "$research_scratch/source"
node "$FLOW_CLI_SCRIPT" kit install "$research_scratch/source" --dest "$research_scratch/install"
node "$FLOW_CLI_SCRIPT" kit inspect "$research_scratch/install/research" --json > "$research_scratch/inspection.json"
cat "$research_scratch/inspection.json"
node --input-type=module - "$research_scratch" <<'NODE'
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
const scratch = process.argv[2];
const source = join(scratch, 'source');
const installed = join(scratch, 'install/research');
const manifest = JSON.parse(readFileSync(join(source, 'kit.json'), 'utf8'));
const inspection = JSON.parse(readFileSync(join(scratch, 'inspection.json'), 'utf8'));
assert.equal(inspection.valid, true);
assert.equal(inspection.kitId, 'research');
assert.deepEqual(inspection.flows, manifest.flows.map(({ id, path }) => ({ id, path })));
assert.deepEqual(inspection.assetClasses.sort(), ['docs', 'skills']);
for (const path of new Set(['kit.json', ...[...manifest.flows, ...manifest.docs, ...manifest.skills].map(asset => asset.path)])) {
  assert.deepEqual(readFileSync(join(installed, path)), readFileSync(join(source, path)), `installed bytes: ${path}`);
}
console.log('PASS installed manifest, all declared asset bytes, flow IDs, and structural asset classes');
NODE
FLOW_CLI_SCRIPT="$FLOW_CLI_SCRIPT" bash "$research_scratch/install/research/validate.sh"
echo 'PASS isolated Flow kit install/inspect; no runtime activation performed'
