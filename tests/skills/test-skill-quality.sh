#!/usr/bin/env bash
# Tests skill quality: minimum content, anti-patterns section for core skills,
# no duplicate skill names, proper markdown structure.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PASSED=0
FAILED=0
WARNED=0

pass() { PASSED=$((PASSED + 1)); echo "  PASS: $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  FAIL: $1"; [ -n "${2:-}" ] && echo "        $2"; }
warn() { WARNED=$((WARNED + 1)); echo "  WARN: $1"; }

echo "=== Skill quality validation tests ==="
echo ""

# ---- Test 1: No duplicate skill names ----
echo "--- Checking for duplicate skill names ---"
echo ""

declare -A SKILL_NAMES 2>/dev/null || true
NAMES_SEEN=""
DUPES_FOUND=0

while IFS= read -r skill_file; do
  [ -z "$skill_file" ] && continue
  skill_name=$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -1 | tr -d '\r')
  relative_path="${skill_file#$REPO_ROOT/}"

  if echo "$NAMES_SEEN" | grep -q "|${skill_name}|"; then
    fail "Duplicate skill name '$skill_name' in $relative_path"
    DUPES_FOUND=$((DUPES_FOUND + 1))
  else
    NAMES_SEEN="${NAMES_SEEN}|${skill_name}|"
    pass "Unique name: $skill_name"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null | sort)

echo ""

# ---- Test 2: Minimum content length ----
echo "--- Checking minimum content length ---"
echo ""

while IFS= read -r skill_file; do
  [ -z "$skill_file" ] && continue
  relative_path="${skill_file#$REPO_ROOT/}"

  # Count words in the file (excluding frontmatter)
  # Use awk to properly skip YAML frontmatter (between first and second ---)
  word_count=$(awk 'BEGIN{in_fm=0; fm_end=0} /^---$/{if(in_fm==0){in_fm=1;next}else if(fm_end==0){fm_end=1;next}} fm_end{print}' "$skill_file" | wc -w | tr -d ' ')

  if [ "$word_count" -ge 50 ]; then
    pass "$relative_path: $word_count words (minimum 50)"
  else
    fail "$relative_path: only $word_count words (minimum 50)" "Skills must have enough content to be actionable"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null | sort)

echo ""

# ---- Test 3: Core/planning/quality skills have anti-patterns or rationalization sections ----
echo "--- Checking core skills for anti-patterns/rationalization sections ---"
echo ""

CORE_SKILL_DIRS="core planning quality"
for category in $CORE_SKILL_DIRS; do
  CATEGORY_DIR="$SKILLS_DIR/$category"
  [ ! -d "$CATEGORY_DIR" ] && continue

  while IFS= read -r skill_file; do
    [ -z "$skill_file" ] && continue
    relative_path="${skill_file#$REPO_ROOT/}"
    skill_name=$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -1 | tr -d '\r')

    # Check for anti-patterns, rationalization, or pressure test sections
    if grep -qi -E '(anti-pattern|rationalization|pressure test|red flag|common mistake)' "$skill_file"; then
      pass "$relative_path: has anti-patterns/rationalization section"
    else
      warn "$relative_path: no anti-patterns or rationalization section found"
    fi
  done < <(find "$CATEGORY_DIR" -name "SKILL.md" -type f 2>/dev/null | sort)
done

echo ""

# ---- Test 4: Markdown structure — has at least one heading ----
echo "--- Checking markdown structure ---"
echo ""

while IFS= read -r skill_file; do
  [ -z "$skill_file" ] && continue
  relative_path="${skill_file#$REPO_ROOT/}"

  # Check for at least one H1 or H2 heading after frontmatter
  heading_count=$(awk 'BEGIN{in_fm=0; fm_end=0} /^---$/{if(in_fm==0){in_fm=1;next}else if(fm_end==0){fm_end=1;next}} fm_end{print}' "$skill_file" | grep -c '^#' || true)

  if [ "$heading_count" -ge 1 ]; then
    pass "$relative_path: has $heading_count headings"
  else
    fail "$relative_path: no headings found (skills need structure)"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null | sort)

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Warnings: $WARNED"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "SKILL QUALITY CHECKS FAILED"
  exit 1
else
  echo "ALL SKILL QUALITY CHECKS PASSED"
  exit 0
fi
