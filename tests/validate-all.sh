#!/usr/bin/env bash
# Shipworthy — Pre-Push Validation Gate
# Comprehensive validation of the entire repo before pushing.
# Run this before any push: bash tests/validate-all.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
START_TIME=$(date +%s)

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
SECTION_RESULTS=""

section_pass() {
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  PASSED_CHECKS=$((PASSED_CHECKS + 1))
  SECTION_RESULTS="$SECTION_RESULTS  ✓ $1\n"
}

section_fail() {
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
  SECTION_RESULTS="$SECTION_RESULTS  ✗ $1\n"
}

echo "╔══════════════════════════════════════════════╗"
echo "║  Shipworthy — Pre-Push Validation Gate       ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Running comprehensive checks...            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ---- 1. Hook Tests ----
echo "━━━ 1/8: Hook Tests ━━━"
if bash "$SCRIPT_DIR/run-all-tests.sh" > /tmp/shipworthy-hooks.log 2>&1; then
  section_pass "Hook tests (37 tests)"
  echo "  All hook tests passed."
else
  section_fail "Hook tests"
  tail -20 /tmp/shipworthy-hooks.log
fi
echo ""

# ---- 2. Skill Frontmatter ----
echo "━━━ 2/8: Skill Frontmatter ━━━"
if bash "$SCRIPT_DIR/skills/test-skill-frontmatter.sh" > /tmp/shipworthy-frontmatter.log 2>&1; then
  section_pass "Skill frontmatter validation"
  SKILL_COUNT=$(grep "Skills checked:" /tmp/shipworthy-frontmatter.log | grep -oE '[0-9]+' || echo "?")
  echo "  $SKILL_COUNT skills validated."
else
  section_fail "Skill frontmatter validation"
  grep "FAIL:" /tmp/shipworthy-frontmatter.log || true
fi
echo ""

# ---- 3. CSO Compliance ----
echo "━━━ 3/8: CSO Compliance ━━━"
if [ -f "$SCRIPT_DIR/skills/test-cso-format.sh" ]; then
  if bash "$SCRIPT_DIR/skills/test-cso-format.sh" > /tmp/shipworthy-cso.log 2>&1; then
    section_pass "CSO (Claude Search Optimization)"
    echo "  All skills follow 'Use when...' format."
  else
    section_fail "CSO (Claude Search Optimization)"
    grep "FAIL:" /tmp/shipworthy-cso.log || true
  fi
else
  section_fail "CSO test script missing"
fi
echo ""

# ---- 4. Skill Routing ----
echo "━━━ 4/8: Skill Routing ━━━"
if bash "$SCRIPT_DIR/skills/test-skill-routing.sh" > /tmp/shipworthy-routing.log 2>&1; then
  section_pass "Skill routing table"
  echo "  All skills reachable from routing table."
else
  section_fail "Skill routing table"
  grep -E "(FAIL|WARN):" /tmp/shipworthy-routing.log | head -10 || true
fi
echo ""

# ---- 5. Cross-References ----
echo "━━━ 5/8: Cross-References ━━━"
if [ -f "$SCRIPT_DIR/skills/test-cross-references.sh" ]; then
  if bash "$SCRIPT_DIR/skills/test-cross-references.sh" > /tmp/shipworthy-xref.log 2>&1; then
    section_pass "Cross-reference validation"
    echo "  All shipworthy:skill-name references resolve."
  else
    section_fail "Cross-reference validation"
    grep "FAIL:" /tmp/shipworthy-xref.log || true
  fi
else
  section_fail "Cross-reference test script missing"
fi
echo ""

# ---- 6. Skill Quality ----
echo "━━━ 6/8: Skill Quality ━━━"
if [ -f "$SCRIPT_DIR/skills/test-skill-quality.sh" ]; then
  if bash "$SCRIPT_DIR/skills/test-skill-quality.sh" > /tmp/shipworthy-quality.log 2>&1; then
    section_pass "Skill quality checks"
    echo "  No duplicate names, minimum content met, proper structure."
  else
    section_fail "Skill quality checks"
    grep "FAIL:" /tmp/shipworthy-quality.log | head -10 || true
  fi
else
  section_fail "Skill quality test script missing"
fi
echo ""

# ---- 7. Repo Structure ----
echo "━━━ 7/8: Repository Structure ━━━"
if [ -f "$SCRIPT_DIR/structure/test-repo-structure.sh" ]; then
  if bash "$SCRIPT_DIR/structure/test-repo-structure.sh" > /tmp/shipworthy-structure.log 2>&1; then
    section_pass "Repository structure"
    echo "  All required files, directories, and configs present."
  else
    section_fail "Repository structure"
    grep "FAIL:" /tmp/shipworthy-structure.log | head -10 || true
  fi
else
  section_fail "Repo structure test script missing"
fi
echo ""

# ---- 8. Security Audit ----
echo "━━━ 8/8: Security Audit ━━━"
if [ -f "$SCRIPT_DIR/security/test-security-audit.sh" ]; then
  if bash "$SCRIPT_DIR/security/test-security-audit.sh" > /tmp/shipworthy-security.log 2>&1; then
    section_pass "Security audit"
    echo "  All security checks passed."
  else
    section_fail "Security audit"
    grep "FAIL:" /tmp/shipworthy-security.log | head -10 || true
  fi
else
  section_fail "Security audit test script missing"
fi
echo ""

# ---- Summary ----
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "╔══════════════════════════════════════════════╗"
echo "║  Validation Summary                          ║"
echo "╠══════════════════════════════════════════════╣"
printf "$SECTION_RESULTS"
echo "╠══════════════════════════════════════════════╣"
echo "║  Total: $TOTAL_CHECKS  Passed: $PASSED_CHECKS  Failed: $FAILED_CHECKS"
echo "║  Duration: ${DURATION}s"
echo "╚══════════════════════════════════════════════╝"
echo ""

if [ "$FAILED_CHECKS" -gt 0 ]; then
  echo "❌ VALIDATION FAILED — Do not push until all checks pass."
  exit 1
else
  echo "✅ ALL CHECKS PASSED — Safe to push."
  exit 0
fi
