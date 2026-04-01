#!/usr/bin/env bash
# Tests CSO (Claude Search Optimization) compliance for all skills.
# Ensures invoke_when and description fields follow standardized format
# for reliable AI skill triggering.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PASSED=0
FAILED=0
WARNED=0

pass() { PASSED=$((PASSED + 1)); echo "  PASS: $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  FAIL: $1"; [ -n "${2:-}" ] && echo "        $2"; }
warn() { WARNED=$((WARNED + 1)); echo "  WARN: $1"; }

echo "=== CSO (Claude Search Optimization) validation tests ==="
echo ""

SKILL_FILES=$(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null)
SKILL_COUNT=0

while IFS= read -r skill_file; do
  [ -z "$skill_file" ] && continue
  SKILL_COUNT=$((SKILL_COUNT + 1))
  relative_path="${skill_file#$REPO_ROOT/}"

  # Extract frontmatter fields
  invoke_when=$(sed -n 's/^invoke_when:[[:space:]]*//p' "$skill_file" | head -1)
  description=$(sed -n 's/^description:[[:space:]]*//p' "$skill_file" | head -1)
  skill_name=$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -1 | tr -d '\r')

  # Check: invoke_when starts with "Use when"
  if echo "$invoke_when" | grep -q "^Use when"; then
    pass "$relative_path: invoke_when starts with 'Use when'"
  else
    fail "$relative_path: invoke_when must start with 'Use when'" "Got: $(echo "$invoke_when" | head -c 60)..."
  fi

  # Check: invoke_when length under 300 chars
  invoke_len=${#invoke_when}
  if [ "$invoke_len" -le 300 ]; then
    pass "$relative_path: invoke_when length OK ($invoke_len chars)"
  else
    fail "$relative_path: invoke_when too long ($invoke_len chars, max 300)"
  fi

  # Check: description length under 500 chars
  desc_len=${#description}
  if [ "$desc_len" -le 500 ]; then
    pass "$relative_path: description length OK ($desc_len chars)"
  else
    fail "$relative_path: description too long ($desc_len chars, max 500)"
  fi

  # Check: skill name matches directory name
  dir_name=$(basename "$(dirname "$skill_file")")
  if [ "$skill_name" = "$dir_name" ]; then
    pass "$relative_path: name '$skill_name' matches directory"
  else
    fail "$relative_path: name '$skill_name' does not match directory '$dir_name'"
  fi

done <<< "$SKILL_FILES"

echo ""
echo "=== Results ==="
echo "Skills checked: $SKILL_COUNT"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Warnings: $WARNED"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "CSO VALIDATION FAILED"
  exit 1
else
  echo "ALL CSO CHECKS PASSED"
  exit 0
fi
