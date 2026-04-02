#!/usr/bin/env bash
# Tests that all shipworthy:skill-name cross-references point to real skills.
# Prevents broken references between skills.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  PASS: $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  FAIL: $1"; [ -n "${2:-}" ] && echo "        $2"; }

echo "=== Cross-reference validation tests ==="
echo ""

# Build a list of all valid skill names
VALID_SKILLS=""
while IFS= read -r skill_file; do
  [ -z "$skill_file" ] && continue
  skill_name=$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -1 | tr -d '\r')
  [ -n "$skill_name" ] && VALID_SKILLS="$VALID_SKILLS $skill_name "
done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null)

# Find all shipworthy:skill-name references across the entire repo
REF_COUNT=0
while IFS= read -r match; do
  [ -z "$match" ] && continue

  file_path=$(echo "$match" | cut -d: -f1)
  relative_path="${file_path#$REPO_ROOT/}"

  # Extract all shipworthy:xxx references from this line
  refs=$(echo "$match" | grep -oE 'shipworthy:[a-z][a-z0-9-]+' || true)

  for ref in $refs; do
    ref_name="${ref#shipworthy:}"

    # Skip placeholder/example patterns (used in docs to show the format)
    if [ "$ref_name" = "skill-name" ] || [ "$ref_name" = "example-skill" ] || [ "$ref_name" = "other-skill" ]; then
      continue
    fi

    REF_COUNT=$((REF_COUNT + 1))

    if echo "$VALID_SKILLS" | grep -q " $ref_name "; then
      pass "$relative_path: shipworthy:$ref_name -> exists"
    else
      fail "$relative_path: shipworthy:$ref_name -> SKILL NOT FOUND"
    fi
  done
done < <(grep -rn 'shipworthy:[a-z]' "$REPO_ROOT" --include='*.md' --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null || true)

echo ""
echo "=== Results ==="
echo "References found: $REF_COUNT"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "CROSS-REFERENCE VALIDATION FAILED"
  exit 1
elif [ "$REF_COUNT" -eq 0 ]; then
  echo "NO CROSS-REFERENCES FOUND (this is OK but unusual)"
  exit 0
else
  echo "ALL CROSS-REFERENCES VALID"
  exit 0
fi
