#!/usr/bin/env bash
# validate.sh — Research Kit container + flow-definition validation.
#
# Uses the @kontourai/flow CLI for authoritative container validation
# (flow validate-kit, flow validate-definition — see kontourai/flow#67).
#
# Usage:
#   ./validate.sh                    # auto-clones kontourai/flow into /tmp if needed
#   FLOW_CLI=node ./validate.sh      # provide your own built flow CLI entry point
#   FLOW_CLI_SCRIPT=/path/dist/cli.js ./validate.sh

set -euo pipefail

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLOW_REPO_DIR="${FLOW_REPO_DIR:-/tmp/flow-validate-kit-$$}"
FLOW_CLI_SCRIPT="${FLOW_CLI_SCRIPT:-}"
ERRORS=0

log()   { echo "[validate] $*"; }
fail()  { echo "[validate:FAIL] $*" >&2; ERRORS=$((ERRORS + 1)); }
pass()  { echo "[validate:PASS] $*"; }

# ── Locate or build the flow CLI ──────────────────────────────────────────────
if [ -z "$FLOW_CLI_SCRIPT" ]; then
  log "Cloning kontourai/flow to get flow validate-kit..."
  if [ -d "$FLOW_REPO_DIR" ]; then
    log "Using existing clone at $FLOW_REPO_DIR"
  else
    git clone --depth 1 https://github.com/kontourai/flow.git "$FLOW_REPO_DIR" 2>&1 | grep -v "^remote:" || true
    (cd "$FLOW_REPO_DIR" && npm ci --silent 2>/dev/null || npm install --silent 2>/dev/null) || true
    (cd "$FLOW_REPO_DIR" && npm run build --silent 2>/dev/null) || true
  fi
  FLOW_CLI_SCRIPT="$FLOW_REPO_DIR/dist/cli.js"
fi

if [ ! -f "$FLOW_CLI_SCRIPT" ]; then
  fail "flow CLI not found at $FLOW_CLI_SCRIPT — cannot run container validation"
  ERRORS=$((ERRORS + 1))
else
  log "Using flow CLI at $FLOW_CLI_SCRIPT"

  # ── Container validation ─────────────────────────────────────────────────────
  log "Running: flow validate-kit $KIT_DIR --json"
  CONTAINER_RESULT="$(node "$FLOW_CLI_SCRIPT" validate-kit "$KIT_DIR" --json 2>&1)"
  echo "$CONTAINER_RESULT"
  CONTAINER_VALID="$(echo "$CONTAINER_RESULT" | node -e 'let d=""; process.stdin.on("data",c=>d+=c); process.stdin.on("end",()=>console.log(JSON.parse(d).valid))')"
  if [ "$CONTAINER_VALID" = "true" ]; then
    pass "flow validate-kit: container manifest is valid"
  else
    fail "flow validate-kit: container manifest is INVALID"
  fi

  # ── Flow-definition validation ────────────────────────────────────────────────
  for flow_file in "$KIT_DIR"/flows/*.flow.json; do
    log "Running: flow validate-definition $flow_file --json"
    DEF_RESULT="$(node "$FLOW_CLI_SCRIPT" validate-definition "$flow_file" --json 2>&1)"
    echo "$DEF_RESULT"
    DEF_VALID="$(echo "$DEF_RESULT" | node -e 'let d=""; process.stdin.on("data",c=>d+=c); process.stdin.on("end",()=>console.log(JSON.parse(d).valid))')"
    if [ "$DEF_VALID" = "true" ]; then
      pass "flow validate-definition: $(basename "$flow_file") is valid"
    else
      fail "flow validate-definition: $(basename "$flow_file") is INVALID"
    fi
  done
fi

# ── Summary ───────────────────────────────────────────────────────────────────
if [ "$ERRORS" -eq 0 ]; then
  log "All validations passed."
  exit 0
else
  log "$ERRORS validation error(s). See output above."
  exit 1
fi
