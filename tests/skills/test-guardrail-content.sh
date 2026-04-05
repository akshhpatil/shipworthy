#!/usr/bin/env bash
# Content-quality tests for guardrail skills.
# Unlike structural tests, these validate that skills contain the sections,
# patterns, and content they claim to have — not just that files exist.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  PASS: $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  FAIL: $1"; [ -n "${2:-}" ] && echo "        $2"; }

echo "=== Guardrail skill content validation tests ==="
echo ""

# ---- The 7 guardrail skills and their locations ----
declare -a GUARDRAIL_SKILLS=(
  "skills/quality/response-schema-validation/SKILL.md"
  "skills/security/bias-detection/SKILL.md"
  "skills/operations/guardrail-audit-log/SKILL.md"
  "skills/quality/feedback-driven-adaptation/SKILL.md"
  "skills/quality/confidence-based-strictness/SKILL.md"
  "skills/security/vendor-risk-assessment/SKILL.md"
  "skills/operations/scope-creep-detection/SKILL.md"
)

# ---- Test 1: Every guardrail skill has a Code Review Checklist ----
echo "--- Test 1: Code Review Checklists present ---"
echo ""

for skill in "${GUARDRAIL_SKILLS[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  if grep -q '## Code Review Checklist' "$filepath"; then
    # Verify checklist has actual items (not just a heading)
    checklist_items=$(grep -c '^\- \[' "$filepath" || true)
    if [ "$checklist_items" -ge 3 ]; then
      pass "$skill_name: has Code Review Checklist with $checklist_items items"
    else
      fail "$skill_name: Code Review Checklist has only $checklist_items items (minimum 3)"
    fi
  else
    fail "$skill_name: missing Code Review Checklist section"
  fi
done

echo ""

# ---- Test 2: Code examples do NOT use console.log (our own rule #1) ----
echo "--- Test 2: Code examples follow our own rules (no console.log) ---"
echo ""

for skill in "${GUARDRAIL_SKILLS[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  # Extract code blocks and check for console.log
  # Exclude lines that are explicitly showing BAD patterns (preceded by // BAD)
  violations=$(awk '/^```/{in_code=!in_code; next} in_code{print NR": "$0}' "$filepath" \
    | grep -i 'console\.log' \
    | grep -vi '// BAD\|// bad\|# BAD\|# bad\|NEVER\|never\|do not\|DON'\''T' || true)

  if [ -z "$violations" ]; then
    pass "$skill_name: no console.log in code examples"
  else
    fail "$skill_name: code examples use console.log (violates our rule #1)" "$violations"
  fi
done

echo ""

# ---- Test 3: TypeScript examples do NOT use : any (our own rule #5) ----
echo "--- Test 3: Code examples follow our own rules (no : any) ---"
echo ""

for skill in "${GUARDRAIL_SKILLS[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  # Check for `: any` in code blocks (excluding BAD examples)
  violations=$(awk '/^```/{in_code=!in_code; next} in_code{print NR": "$0}' "$filepath" \
    | grep -E ':\s*any\b' \
    | grep -vi '// BAD\|// bad\|NEVER\|FLAG' || true)

  if [ -z "$violations" ]; then
    pass "$skill_name: no : any in TypeScript examples"
  else
    fail "$skill_name: TypeScript examples use : any (violates our rule #5)" "$violations"
  fi
done

echo ""

# ---- Test 4: Skill-specific required content ----
echo "--- Test 4: Skill-specific required sections ---"
echo ""

# response-schema-validation MUST have sensitive fields blocklist
filepath="$REPO_ROOT/skills/quality/response-schema-validation/SKILL.md"
if grep -qi 'sensitive.*field.*blocklist\|fields.*blocklist\|blocklist' "$filepath"; then
  pass "response-schema-validation: has sensitive fields blocklist"
else
  fail "response-schema-validation: missing sensitive fields blocklist"
fi

# response-schema-validation MUST have patterns for multiple languages
for lang in "Zod" "Pydantic" "Go"; do
  if grep -q "$lang" "$filepath"; then
    pass "response-schema-validation: has $lang implementation pattern"
  else
    fail "response-schema-validation: missing $lang implementation pattern"
  fi
done

# bias-detection MUST have protected attributes section
filepath="$REPO_ROOT/skills/security/bias-detection/SKILL.md"
if grep -qi 'protected.*attribute' "$filepath"; then
  pass "bias-detection: has protected attributes section"
else
  fail "bias-detection: missing protected attributes section"
fi

# bias-detection MUST have proxy variables section
if grep -qi 'proxy.*variable' "$filepath"; then
  pass "bias-detection: has proxy variable detection"
else
  fail "bias-detection: missing proxy variable detection"
fi

# bias-detection MUST reference at least one regulation
for reg in "GDPR" "EU AI Act" "ECOA"; do
  if grep -q "$reg" "$filepath"; then
    pass "bias-detection: references $reg"
  else
    fail "bias-detection: missing $reg regulatory reference"
  fi
done

# guardrail-audit-log MUST have event schema
filepath="$REPO_ROOT/skills/operations/guardrail-audit-log/SKILL.md"
if grep -qi 'GuardrailEvent\|event.*schema\|guardrail.*event' "$filepath"; then
  pass "guardrail-audit-log: has guardrail event schema"
else
  fail "guardrail-audit-log: missing guardrail event schema"
fi

# guardrail-audit-log MUST reference all 5 guardrail layers
for layer in "input_output" "contextual" "security" "adaptive" "ethical_compliance"; do
  if grep -q "$layer" "$filepath"; then
    pass "guardrail-audit-log: covers '$layer' layer"
  else
    fail "guardrail-audit-log: missing '$layer' layer classification"
  fi
done

# guardrail-audit-log MUST have immutability rules
if grep -qi 'immutab\|append.only\|tamper' "$filepath"; then
  pass "guardrail-audit-log: has immutability/append-only rules"
else
  fail "guardrail-audit-log: missing immutability rules"
fi

# feedback-driven-adaptation MUST have signal types
filepath="$REPO_ROOT/skills/quality/feedback-driven-adaptation/SKILL.md"
for signal in "User Signal" "Project Trajectory" "Violation Pattern"; do
  if grep -qi "$signal" "$filepath"; then
    pass "feedback-driven-adaptation: has '$signal' section"
  else
    fail "feedback-driven-adaptation: missing '$signal' section"
  fi
done

# feedback-driven-adaptation MUST have graduation protocol
if grep -qi 'graduation\|upgrading.*strict\|downgrad' "$filepath"; then
  pass "feedback-driven-adaptation: has tier graduation protocol"
else
  fail "feedback-driven-adaptation: missing tier graduation protocol"
fi

# feedback-driven-adaptation MUST have non-downgradeable guardrails list
if grep -qi 'never downgrade\|non-negotiable\|regardless of user' "$filepath"; then
  pass "feedback-driven-adaptation: defines non-downgradeable guardrails"
else
  fail "feedback-driven-adaptation: missing non-downgradeable guardrails list"
fi

# confidence-based-strictness MUST have confidence levels
filepath="$REPO_ROOT/skills/quality/confidence-based-strictness/SKILL.md"
for level in "High Confidence" "Moderate Confidence" "Low Confidence" "Minimal Confidence"; do
  if grep -qi "$level" "$filepath"; then
    pass "confidence-based-strictness: has '$level' level"
  else
    fail "confidence-based-strictness: missing '$level' level"
  fi
done

# confidence-based-strictness MUST flag high-risk domains
for domain in "crypto" "price|financial" "mutex|concurrency|lock" "migration"; do
  if grep -qiE "$domain" "$filepath"; then
    pass "confidence-based-strictness: detects high-risk domain ($(echo $domain | cut -d'|' -f1))"
  else
    fail "confidence-based-strictness: missing high-risk domain detection ($domain)"
  fi
done

# vendor-risk-assessment MUST have vendor tiers
filepath="$REPO_ROOT/skills/security/vendor-risk-assessment/SKILL.md"
for tier in "Critical" "Operational" "Development"; do
  if grep -q "### Tier.*$tier\|$tier.*Vendor" "$filepath"; then
    pass "vendor-risk-assessment: has '$tier' vendor tier"
  else
    fail "vendor-risk-assessment: missing '$tier' vendor tier"
  fi
done

# vendor-risk-assessment MUST have failure planning
if grep -qi 'failure.*plan\|vendor.*down\|vendor.*breach' "$filepath"; then
  pass "vendor-risk-assessment: has vendor failure planning"
else
  fail "vendor-risk-assessment: missing vendor failure planning"
fi

# vendor-risk-assessment MUST require DPA or SOC 2 for critical vendors
if grep -qi 'DPA\|SOC 2\|Data Processing Agreement' "$filepath"; then
  pass "vendor-risk-assessment: requires DPA/SOC 2 for critical vendors"
else
  fail "vendor-risk-assessment: missing DPA/SOC 2 requirement for critical vendors"
fi

# scope-creep-detection MUST have detection triggers
filepath="$REPO_ROOT/skills/operations/scope-creep-detection/SKILL.md"
trigger_count=$(grep -c '### Trigger' "$filepath" || true)
if [ "$trigger_count" -ge 3 ]; then
  pass "scope-creep-detection: has $trigger_count detection triggers (minimum 3)"
else
  fail "scope-creep-detection: only $trigger_count detection triggers (minimum 3)"
fi

# scope-creep-detection MUST have response protocol
if grep -qi 'response protocol\|step 1.*identify\|present option' "$filepath"; then
  pass "scope-creep-detection: has response protocol"
else
  fail "scope-creep-detection: missing response protocol"
fi

# scope-creep-detection MUST define scope boundaries by task size
if grep -qi 'Quick Fix\|Feature\|Project' "$filepath" && grep -qi 'file.*change\|expected' "$filepath"; then
  pass "scope-creep-detection: defines scope boundaries by task size"
else
  fail "scope-creep-detection: missing scope boundaries by task size"
fi

echo ""

# ---- Test 5: Quality-category skills have rationalization pressure tests ----
echo "--- Test 5: Quality skills have rationalization pressure tests ---"
echo ""

QUALITY_GUARDRAILS=(
  "skills/quality/response-schema-validation/SKILL.md"
  "skills/quality/feedback-driven-adaptation/SKILL.md"
  "skills/quality/confidence-based-strictness/SKILL.md"
)

for skill in "${QUALITY_GUARDRAILS[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  if grep -qi -E 'rationalization|pressure test' "$filepath"; then
    # Verify it has actual table rows (not just a heading)
    table_rows=$(grep -c '^|.*|.*|' "$filepath" | head -1 || echo "0")
    # Subtract header + separator rows (2 per table)
    if [ "$table_rows" -ge 4 ]; then
      pass "$skill_name: has rationalization pressure test with table"
    else
      fail "$skill_name: rationalization section exists but lacks table content"
    fi
  else
    fail "$skill_name: quality skill missing rationalization pressure test"
  fi
done

echo ""

# ---- Test 6: Every guardrail skill has at least one table ----
echo "--- Test 6: Skills use structured tables (not just prose) ---"
echo ""

for skill in "${GUARDRAIL_SKILLS[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  table_count=$(grep -c '^|.*|.*|' "$filepath" || true)
  if [ "$table_count" -ge 3 ]; then
    pass "$skill_name: has structured tables ($table_count rows)"
  else
    fail "$skill_name: insufficient tables (only $table_count rows, minimum 3)" \
         "Skills should use tables for structured data, not just prose"
  fi
done

echo ""

# ---- Test 7: Every guardrail skill has code examples ----
echo "--- Test 7: Skills include code examples ---"
echo ""

for skill in "${GUARDRAIL_SKILLS[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  code_block_count=$(grep -c '^```' "$filepath" || true)
  # code blocks come in pairs (opening + closing), so divide by 2
  example_count=$((code_block_count / 2))

  if [ "$example_count" -ge 1 ]; then
    pass "$skill_name: has $example_count code example(s)"
  else
    fail "$skill_name: no code examples found" \
         "Guardrail skills should include implementation examples"
  fi
done

echo ""

# ---- Test 8: BAD/GOOD pattern — skills show what NOT to do ----
echo "--- Test 8: Skills show BAD vs GOOD patterns ---"
echo ""

# These skills specifically need BAD/GOOD contrast patterns
NEEDS_CONTRAST=(
  "skills/quality/response-schema-validation/SKILL.md"
  "skills/security/bias-detection/SKILL.md"
  "skills/security/vendor-risk-assessment/SKILL.md"
)

for skill in "${NEEDS_CONTRAST[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  bad_count=$(grep -ci '// BAD\|# BAD\|NEVER\|do not\|must not' "$filepath" || true)
  good_count=$(grep -ci '// GOOD\|# GOOD\|BETTER\|correct\|recommended' "$filepath" || true)

  if [ "$bad_count" -ge 1 ] && [ "$good_count" -ge 1 ]; then
    pass "$skill_name: has BAD ($bad_count) and GOOD ($good_count) contrast patterns"
  elif [ "$bad_count" -ge 1 ]; then
    fail "$skill_name: has BAD patterns but no GOOD alternatives shown"
  elif [ "$good_count" -ge 1 ]; then
    fail "$skill_name: has GOOD patterns but no BAD examples to contrast"
  else
    fail "$skill_name: missing BAD/GOOD contrast patterns"
  fi
done

echo ""

# ---- Test 9: Cross-references between guardrail skills resolve ----
echo "--- Test 9: Internal cross-references resolve ---"
echo ""

for skill in "${GUARDRAIL_SKILLS[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  # Find all shipworthy: references in this file
  refs=$(grep -oE 'shipworthy:[a-z][a-z0-9-]+' "$filepath" 2>/dev/null || true)

  if [ -z "$refs" ]; then
    pass "$skill_name: no cross-references (standalone)"
    continue
  fi

  all_resolved=true
  while IFS= read -r ref; do
    ref_name="${ref#shipworthy:}"
    # Skip placeholder names
    if [ "$ref_name" = "skill-name" ] || [ "$ref_name" = "example-skill" ]; then
      continue
    fi
    # Check if referenced skill exists
    if find "$SKILLS_DIR" -path "*/$ref_name/SKILL.md" -type f 2>/dev/null | grep -q .; then
      pass "$skill_name: cross-ref '$ref_name' resolves"
    else
      fail "$skill_name: cross-ref '$ref_name' does NOT resolve"
      all_resolved=false
    fi
  done <<< "$refs"
done

echo ""

# ---- Test 10: Logger usage in examples (pino/logging/slog, not console) ----
echo "--- Test 10: Examples use structured loggers ---"
echo ""

for skill in "${GUARDRAIL_SKILLS[@]}"; do
  filepath="$REPO_ROOT/$skill"
  skill_name=$(basename "$(dirname "$skill")")

  # Check if skill has logging examples at all
  has_logging=$(awk '/^```/{in_code=!in_code; next} in_code{print}' "$filepath" \
    | grep -ciE 'log\.\w+\(|logger\.\w+\(|logging\.\w+\(' || true)

  if [ "$has_logging" -gt 0 ]; then
    # If it has logging, verify it uses structured loggers
    uses_structured=$(awk '/^```/{in_code=!in_code; next} in_code{print}' "$filepath" \
      | grep -ciE 'pino|logger\.|logging\.|slog\.|log\.(info|warn|error|debug)\(' || true)

    if [ "$uses_structured" -gt 0 ]; then
      pass "$skill_name: uses structured logger in examples"
    else
      fail "$skill_name: has logging but not using structured logger (pino/logging/slog)"
    fi
  else
    pass "$skill_name: no logging examples (N/A)"
  fi
done

echo ""

echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "GUARDRAIL CONTENT CHECKS FAILED"
  exit 1
else
  echo "ALL GUARDRAIL CONTENT CHECKS PASSED"
  exit 0
fi
