#!/usr/bin/env bash
# Tests that every skill in the skills/ directory is referenced in the master routing table.
# Prevents orphaned skills that exist but are never invoked.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
MASTER_SKILL="$REPO_ROOT/skills/core/using-shipworthy/SKILL.md"
PASSED=0
FAILED=0
WARNED=0

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

warn() {
  WARNED=$((WARNED + 1))
  echo "  WARN: $1"
}

echo "=== Skill routing validation tests ==="
echo ""

# Check master routing skill exists
if [ ! -f "$MASTER_SKILL" ]; then
  fail "Master routing skill not found at $MASTER_SKILL"
  exit 1
fi

# Get the routing table content from master skill
ROUTING_CONTENT=$(cat "$MASTER_SKILL")

# Find all skill names from SKILL.md frontmatter
SKILL_FILES=$(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null)

echo "--- Checking skill reachability ---"
echo ""

SKILL_COUNT=0
ORPHAN_COUNT=0

while IFS= read -r skill_file; do
  SKILL_COUNT=$((SKILL_COUNT + 1))

  # Extract skill name from frontmatter
  skill_name=$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -1 | tr -d '\r')

  if [ -z "$skill_name" ]; then
    fail "$(echo "${skill_file#$REPO_ROOT/}"): no name in frontmatter"
    continue
  fi

  # Skip the master skill itself (it's always loaded, doesn't need routing)
  if [ "$skill_name" = "using-shipworthy" ]; then
    pass "$skill_name — master skill (always loaded)"
    continue
  fi

  # Check if skill name appears anywhere in the master routing skill
  if echo "$ROUTING_CONTENT" | grep -q "$skill_name"; then
    pass "$skill_name — referenced in routing table"
  else
    # Check if it's referenced by the invoke_when field (skill may be invoked by another skill)
    invoke_when=$(sed -n 's/^invoke_when:[[:space:]]*//p' "$skill_file" | head -1)
    if echo "$invoke_when" | grep -qiE '(session start|hook|automatically|always)'; then
      pass "$skill_name — auto-invoked (via hook or always-on)"
    else
      warn "$skill_name — NOT in routing table (may be orphaned)"
      ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
    fi
  fi
done <<< "$SKILL_FILES"

echo ""
echo "--- Checking routing table references ---"
echo ""

# Extract all skill names referenced in the routing table
REFERENCED_SKILLS=$(grep -oE '`[a-z][a-z0-9-]+`' "$MASTER_SKILL" | sort -u | tr -d '`')

# Check each referenced skill actually exists
MISSING_COUNT=0
while IFS= read -r ref_skill; do
  [ -z "$ref_skill" ] && continue

  # Check if a SKILL.md exists with this name
  found="false"
  while IFS= read -r skill_file; do
    skill_name=$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -1 | tr -d '\r')
    if [ "$skill_name" = "$ref_skill" ]; then
      found="true"
      break
    fi
  done <<< "$SKILL_FILES"

  if [ "$found" = "true" ]; then
    pass "$ref_skill — exists on disk"
  else
    # Could be a tool name or concept, not a skill
    if echo "$ref_skill" | grep -qE '^(writing-plans|executing-plans|brainstorming|test-driven-development|systematic-debugging|architecture-awareness|intent-to-spec|verification-before-completion|quality-gates|security-first-development|dependency-management|subagent-driven-development|dispatching-parallel-agents|requesting-code-review|receiving-code-review|using-git-worktrees|finishing-a-development-branch|error-handling-patterns|observability-by-default|performance-budgets|ci-cd-awareness|tech-debt-tracking|documentation-as-code|writing-skills|accessibility|frontend-standards|api-design-standards|database-design|session-memory|mcp-integration|project-diagnosis)$'; then
      fail "$ref_skill — referenced in routing table but SKILL.md not found"
      MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
  fi
done <<< "$REFERENCED_SKILLS"

echo ""
echo "=== Results ==="
echo "Skills on disk: $SKILL_COUNT"
echo "Orphaned (not in routing): $ORPHAN_COUNT"
echo "Missing (in routing, not on disk): $MISSING_COUNT"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Warnings: $WARNED"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "TESTS FAILED"
  exit 1
elif [ "$WARNED" -gt 0 ]; then
  echo "ALL PASSED WITH WARNINGS"
  exit 0
else
  echo "ALL TESTS PASSED"
  exit 0
fi
