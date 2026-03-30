#!/usr/bin/env bash
# Tests that all SKILL.md files have valid YAML frontmatter with required fields.
# Required fields: name, description, invoke_when

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
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

echo "=== SKILL.md frontmatter validation tests ==="
echo ""

# Find all SKILL.md files
SKILL_FILES=$(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null)

if [ -z "$SKILL_FILES" ]; then
  fail "No SKILL.md files found in $SKILLS_DIR"
  echo ""
  echo "=== Results ==="
  echo "Passed: 0"
  echo "Failed: 1"
  exit 1
fi

SKILL_COUNT=0

while IFS= read -r skill_file; do
  SKILL_COUNT=$((SKILL_COUNT + 1))
  relative_path="${skill_file#$REPO_ROOT/}"

  # Check: file starts with ---
  first_line=$(head -1 "$skill_file" 2>/dev/null || true)
  if [ "$first_line" != "---" ]; then
    fail "$relative_path: missing YAML frontmatter (no opening ---)"
    continue
  fi

  # Extract frontmatter (between first --- and second ---)
  frontmatter=$(sed -n '2,/^---$/p' "$skill_file" | sed '$d' 2>/dev/null || true)

  if [ -z "$frontmatter" ]; then
    fail "$relative_path: empty frontmatter"
    continue
  fi

  # Check required fields
  has_name="false"
  has_description="false"
  has_invoke_when="false"

  if echo "$frontmatter" | grep -q '^name:'; then
    has_name="true"
    # Check name is not empty
    name_value=$(echo "$frontmatter" | grep '^name:' | sed 's/^name:[[:space:]]*//')
    if [ -z "$name_value" ]; then
      fail "$relative_path: 'name' field is empty"
      continue
    fi
  fi

  if echo "$frontmatter" | grep -q '^description:'; then
    has_description="true"
    desc_value=$(echo "$frontmatter" | grep '^description:' | sed 's/^description:[[:space:]]*//')
    if [ -z "$desc_value" ]; then
      fail "$relative_path: 'description' field is empty"
      continue
    fi
  fi

  if echo "$frontmatter" | grep -q '^invoke_when:'; then
    has_invoke_when="true"
    invoke_value=$(echo "$frontmatter" | grep '^invoke_when:' | sed 's/^invoke_when:[[:space:]]*//')
    if [ -z "$invoke_value" ]; then
      fail "$relative_path: 'invoke_when' field is empty"
      continue
    fi
  fi

  if [ "$has_name" = "true" ] && [ "$has_description" = "true" ] && [ "$has_invoke_when" = "true" ]; then
    pass "$relative_path"
  else
    missing=""
    [ "$has_name" = "false" ] && missing="${missing}name, "
    [ "$has_description" = "false" ] && missing="${missing}description, "
    [ "$has_invoke_when" = "false" ] && missing="${missing}invoke_when, "
    missing="${missing%, }"
    fail "$relative_path: missing required fields: $missing"
  fi
done <<< "$SKILL_FILES"

echo ""
echo "=== Results ==="
echo "Skills checked: $SKILL_COUNT"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
TOTAL=$((PASSED + FAILED))
echo "Total:  $TOTAL"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "SOME TESTS FAILED"
  exit 1
else
  echo "ALL TESTS PASSED"
  exit 0
fi
