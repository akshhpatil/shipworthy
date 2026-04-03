#!/usr/bin/env bash
# Tests for the transparency instruction track
# Validates: all skills, commands, agents, templates, and adapters have transparency instructions

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PASSED=0
FAILED=0

pass() {
  PASSED=$((PASSED + 1))
  echo "  PASS: $1"
}

fail() {
  FAILED=$((FAILED + 1))
  echo "  FAIL: $1"
  if [ -n "${2:-}" ]; then
    echo "        $2"
  fi
}

echo "=== transparency instruction tests ==="
echo ""

# ---------------------------------------------------------------
# Test 1: Master skill has Transparency Protocol section
# ---------------------------------------------------------------
echo "Test 1: Master skill contains Transparency Protocol"
MASTER_SKILL="$REPO_ROOT/skills/core/using-shipworthy/SKILL.md"
if grep -q "## Transparency Protocol" "$MASTER_SKILL" 2>/dev/null; then
  pass "using-shipworthy has Transparency Protocol section"
else
  fail "using-shipworthy missing Transparency Protocol section"
fi

# ---------------------------------------------------------------
# Test 2: All command files have transparency header
# ---------------------------------------------------------------
echo "Test 2: All commands have transparency header"
CMD_FAIL=0
for cmd_file in "$REPO_ROOT"/commands/*.md; do
  [ -f "$cmd_file" ] || continue
  cmd_name=$(basename "$cmd_file" .md)
  if ! grep -q "shipworthy.*command:" "$cmd_file" 2>/dev/null; then
    fail "commands/$cmd_name.md missing transparency header"
    CMD_FAIL=1
  fi
done
if [ "$CMD_FAIL" -eq 0 ]; then
  CMD_COUNT=$(ls -1 "$REPO_ROOT"/commands/*.md 2>/dev/null | wc -l | tr -d ' ')
  pass "All $CMD_COUNT commands have transparency headers"
fi

# ---------------------------------------------------------------
# Test 3: All agent files have transparency header
# ---------------------------------------------------------------
echo "Test 3: All agents have transparency header"
AGENT_FAIL=0
for agent_file in "$REPO_ROOT"/agents/*.md; do
  [ -f "$agent_file" ] || continue
  agent_name=$(basename "$agent_file" .md)
  if ! grep -q "shipworthy.*agent:" "$agent_file" 2>/dev/null; then
    fail "agents/$agent_name.md missing transparency header"
    AGENT_FAIL=1
  fi
done
if [ "$AGENT_FAIL" -eq 0 ]; then
  AGENT_COUNT=$(ls -1 "$REPO_ROOT"/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
  pass "All $AGENT_COUNT agents have transparency headers"
fi

# ---------------------------------------------------------------
# Test 4: All template files have transparency instruction
# ---------------------------------------------------------------
echo "Test 4: All templates have transparency instruction"
TMPL_FAIL=0
for tmpl_file in "$REPO_ROOT"/templates/*.md; do
  [ -f "$tmpl_file" ] || continue
  tmpl_name=$(basename "$tmpl_file" .md)
  if ! grep -q "shipworthy.*template:" "$tmpl_file" 2>/dev/null; then
    fail "templates/$tmpl_name.md missing transparency instruction"
    TMPL_FAIL=1
  fi
done
if [ "$TMPL_FAIL" -eq 0 ]; then
  TMPL_COUNT=$(ls -1 "$REPO_ROOT"/templates/*.md 2>/dev/null | wc -l | tr -d ' ')
  pass "All $TMPL_COUNT templates have transparency instructions"
fi

# ---------------------------------------------------------------
# Test 5: All adapter files have transparency instruction
# ---------------------------------------------------------------
echo "Test 5: All adapters have transparency instruction"
ADAPT_FAIL=0
# Adapters are in subdirectories, check all text-based config files
for adapter_dir in "$REPO_ROOT"/adapters/*/; do
  [ -d "$adapter_dir" ] || continue
  adapter_name=$(basename "$adapter_dir")
  # Find the main config file in the adapter directory
  found=0
  for f in "$adapter_dir"*.md "$adapter_dir".cursorrules "$adapter_dir".windsurfrules "$adapter_dir".github/*.md; do
    [ -f "$f" ] || continue
    if grep -q "shipworthy.*adapter:" "$f" 2>/dev/null; then
      found=1
      break
    fi
  done
  if [ "$found" -eq 0 ]; then
    fail "adapters/$adapter_name missing transparency instruction"
    ADAPT_FAIL=1
  fi
done
if [ "$ADAPT_FAIL" -eq 0 ]; then
  ADAPT_COUNT=$(ls -d "$REPO_ROOT"/adapters/*/ 2>/dev/null | wc -l | tr -d ' ')
  pass "All $ADAPT_COUNT adapters have transparency instructions"
fi

# ---------------------------------------------------------------
# Summary
# ---------------------------------------------------------------
echo ""
echo "=== Results: $PASSED passed, $FAILED failed ==="

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
