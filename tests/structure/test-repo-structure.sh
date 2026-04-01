#!/usr/bin/env bash
# Tests repository structure: required files, directory layout,
# agent/template/command validation, CHANGELOG format.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  PASS: $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  FAIL: $1"; [ -n "${2:-}" ] && echo "        $2"; }

echo "=== Repository structure validation tests ==="
echo ""

# ---- Test 1: Required root files ----
echo "--- Required files ---"
echo ""

REQUIRED_FILES=(
  "LICENSE"
  "README.md"
  "CONTRIBUTING.md"
  "CODE_OF_CONDUCT.md"
  "SECURITY.md"
  "CHANGELOG.md"
  "RELEASE-NOTES.md"
  "package.json"
  ".gitignore"
)

for f in "${REQUIRED_FILES[@]}"; do
  if [ -f "$REPO_ROOT/$f" ]; then
    pass "$f exists"
  else
    fail "$f is MISSING"
  fi
done

echo ""

# ---- Test 2: Required directories ----
echo "--- Required directories ---"
echo ""

REQUIRED_DIRS=(
  "skills"
  "hooks"
  "agents"
  "adapters"
  "templates"
  "commands"
  "tests"
  ".github"
  ".github/ISSUE_TEMPLATE"
  ".github/workflows"
  ".claude-plugin"
)

for d in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$REPO_ROOT/$d" ]; then
    pass "$d/ exists"
  else
    fail "$d/ is MISSING"
  fi
done

echo ""

# ---- Test 3: GitHub community files ----
echo "--- GitHub community files ---"
echo ""

GITHUB_FILES=(
  ".github/FUNDING.yml"
  ".github/PULL_REQUEST_TEMPLATE.md"
  ".github/workflows/ci.yml"
)

for f in "${GITHUB_FILES[@]}"; do
  if [ -f "$REPO_ROOT/$f" ]; then
    pass "$f exists"
  else
    fail "$f is MISSING"
  fi
done

# Check issue templates exist (at least 2)
TEMPLATE_COUNT=$(find "$REPO_ROOT/.github/ISSUE_TEMPLATE" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$TEMPLATE_COUNT" -ge 2 ]; then
  pass "Issue templates: $TEMPLATE_COUNT found (minimum 2)"
else
  fail "Issue templates: only $TEMPLATE_COUNT found (minimum 2)"
fi

echo ""

# ---- Test 4: Agent files are valid markdown with required structure ----
echo "--- Agent validation ---"
echo ""

for agent_file in "$REPO_ROOT"/agents/*.md; do
  [ ! -f "$agent_file" ] && continue
  agent_name=$(basename "$agent_file" .md)

  # Check agent has at least a heading
  if grep -q '^#' "$agent_file"; then
    pass "Agent '$agent_name' has heading structure"
  else
    fail "Agent '$agent_name' has no headings"
  fi

  # Check agent has at least 20 words of content
  word_count=$(wc -w < "$agent_file" | tr -d ' ')
  if [ "$word_count" -ge 20 ]; then
    pass "Agent '$agent_name' has content ($word_count words)"
  else
    fail "Agent '$agent_name' too sparse ($word_count words, min 20)"
  fi
done

echo ""

# ---- Test 5: Template files are valid ----
echo "--- Template validation ---"
echo ""

for template_file in "$REPO_ROOT"/templates/*.md; do
  [ ! -f "$template_file" ] && continue
  template_name=$(basename "$template_file" .md)

  # Check template has a heading
  if grep -q '^#' "$template_file"; then
    pass "Template '$template_name' has heading structure"
  else
    fail "Template '$template_name' has no headings"
  fi

  # Check template mentions "Mandatory" rules
  if grep -qi 'mandatory\|required\|must\|always' "$template_file"; then
    pass "Template '$template_name' has enforced rules"
  else
    fail "Template '$template_name' lacks mandatory rules"
  fi
done

echo ""

# ---- Test 6: Command files are valid ----
echo "--- Command validation ---"
echo ""

for cmd_file in "$REPO_ROOT"/commands/*.md; do
  [ ! -f "$cmd_file" ] && continue
  cmd_name=$(basename "$cmd_file" .md)

  # Check command has content
  word_count=$(wc -w < "$cmd_file" | tr -d ' ')
  if [ "$word_count" -ge 10 ]; then
    pass "Command '/$cmd_name' has content ($word_count words)"
  else
    fail "Command '/$cmd_name' too sparse ($word_count words, min 10)"
  fi
done

echo ""

# ---- Test 7: CHANGELOG has version entries ----
echo "--- CHANGELOG validation ---"
echo ""

CHANGELOG="$REPO_ROOT/CHANGELOG.md"
if [ -f "$CHANGELOG" ]; then
  # Check it has at least one version header
  version_count=$(grep -c '^\## \[' "$CHANGELOG" || true)
  if [ "$version_count" -ge 1 ]; then
    pass "CHANGELOG has $version_count version entries"
  else
    fail "CHANGELOG has no version entries"
  fi

  # Check latest version has a date
  latest_version_line=$(grep '^\## \[' "$CHANGELOG" | head -1)
  if echo "$latest_version_line" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
    pass "Latest version has a date"
  else
    if echo "$latest_version_line" | grep -q 'Unreleased'; then
      pass "Latest entry is [Unreleased] (OK)"
    else
      fail "Latest version entry lacks a date: $latest_version_line"
    fi
  fi
fi

echo ""

# ---- Test 8: No secrets in tracked files ----
echo "--- Secrets scan ---"
echo ""

# Scan for common secret patterns
SECRET_PATTERNS=(
  'AKIA[0-9A-Z]{16}'                    # AWS access key
  'sk-[a-zA-Z0-9]{20,}'                 # OpenAI/Stripe key
  'ghp_[a-zA-Z0-9]{36}'                 # GitHub PAT
  'gho_[a-zA-Z0-9]{36}'                 # GitHub OAuth
  'glpat-[a-zA-Z0-9_-]{20}'             # GitLab PAT
  'xox[baprs]-[a-zA-Z0-9-]+'            # Slack token
  'password\s*[:=]\s*["\x27][^"\x27]{4,}'  # Hardcoded passwords
  'secret\s*[:=]\s*["\x27][^"\x27]{8,}'   # Hardcoded secrets
)

SECRETS_FOUND=0
for pattern in "${SECRET_PATTERNS[@]}"; do
  matches=$(grep -rn --include='*.md' --include='*.sh' --include='*.js' --include='*.ts' --include='*.json' --include='*.yml' --include='*.yaml' \
    -E "$pattern" "$REPO_ROOT" \
    --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=tests 2>/dev/null | head -5 || true)

  if [ -n "$matches" ]; then
    # Filter out false positives in skill content (they describe patterns, not contain real secrets)
    real_matches=$(echo "$matches" | grep -v 'SKILL.md' | grep -v 'example' | grep -v 'pattern' || true)
    if [ -n "$real_matches" ]; then
      fail "Potential secret pattern found: $pattern"
      echo "        $real_matches" | head -3
      SECRETS_FOUND=$((SECRETS_FOUND + 1))
    fi
  fi
done

if [ "$SECRETS_FOUND" -eq 0 ]; then
  pass "No secrets detected in tracked files"
fi

echo ""

# ---- Test 9: Skill categories are valid ----
echo "--- Skill category validation ---"
echo ""

VALID_CATEGORIES="core planning quality security architecture collaboration operations frontend debugging documentation meta"

for category_dir in "$SKILLS_DIR"/*/; do
  [ ! -d "$category_dir" ] && continue
  category_name=$(basename "$category_dir")

  if echo "$VALID_CATEGORIES" | grep -qw "$category_name"; then
    pass "Category '$category_name' is valid"
  else
    fail "Unknown category '$category_name'" "Valid categories: $VALID_CATEGORIES"
  fi
done

echo ""

# ---- Test 10: package.json has required fields ----
echo "--- Package.json validation ---"
echo ""

PKG="$REPO_ROOT/package.json"
if [ -f "$PKG" ]; then
  for field in name version description bin; do
    if grep -q "\"$field\"" "$PKG"; then
      pass "package.json has '$field' field"
    else
      fail "package.json missing '$field' field"
    fi
  done
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "REPO STRUCTURE CHECKS FAILED"
  exit 1
else
  echo "ALL REPO STRUCTURE CHECKS PASSED"
  exit 0
fi
