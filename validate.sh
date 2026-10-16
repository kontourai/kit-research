#!/usr/bin/env bash
# Validate with the package-local Flow CLI, or an explicitly supplied reviewed entry point.
# This script never downloads or builds a CLI.
set -euo pipefail

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLOW_CLI_SCRIPT="${FLOW_CLI_SCRIPT:-$KIT_DIR/node_modules/@kontourai/flow/dist/cli.js}"
ERRORS=0

if [ ! -f "$FLOW_CLI_SCRIPT" ]; then
  echo "[validate:FAIL] Flow CLI not found at $FLOW_CLI_SCRIPT. Run pnpm install --frozen-lockfile or set FLOW_CLI_SCRIPT to a reviewed CLI entry point." >&2
  exit 1
fi

validate() {
  local label="$1" result status
  shift
  echo "[validate] $label"
  if result="$(node "$FLOW_CLI_SCRIPT" "$@" --json 2>&1)"; then
    status=0
  else
    status=$?
  fi
  printf '%s\n' "$result"
  if [ "$status" -eq 0 ] && printf '%s' "$result" | node -e '
    let data = "";
    process.stdin.on("data", chunk => data += chunk);
    process.stdin.on("end", () => {
      try { if (JSON.parse(data).valid !== true) process.exitCode = 1; }
      catch { process.exitCode = 1; }
    });
  '; then
    echo "[validate:PASS] $label"
  else
    echo "[validate:FAIL] $label (CLI exit $status)" >&2
    ERRORS=$((ERRORS + 1))
  fi
}

validate "flow kit validate" kit validate "$KIT_DIR"
for flow_file in "$KIT_DIR"/flows/*.flow.json; do
  validate "flow validate-definition: $(basename "$flow_file")" validate-definition "$flow_file"
done

if [ "$ERRORS" -ne 0 ]; then
  echo "[validate:FAIL] $ERRORS validation(s) failed." >&2
  exit 1
fi
echo "[validate:PASS] Container and all flow definitions are valid."
