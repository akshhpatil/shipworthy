#!/usr/bin/env bash
# Tests for the pre-tool-use hook
# Validates secret detection, console.log warnings, and approval logic

set -euo pipefail

HOOK_PATH="$(cd "$(dirname "$0")/../../hooks" && pwd)/pre-tool-use"
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

setup_temp_project() {
  local dir
  dir=$(mktemp -d)
  git -C "$dir" init --quiet 2>/dev/null
  echo "$dir"
}

cleanup() {
  rm -rf "$1" 2>/dev/null || true
}

validate_json() {
  python3 -c "import json,sys; json.loads(sys.stdin.read())" 2>/dev/null
}

echo "=== pre-tool-use hook tests ==="
echo ""

# ---------------------------------------------------------------
# Test 1: Normal file write -> approve
# ---------------------------------------------------------------
echo "Test 1: Normal file write -> approve"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_name":"Write","tool_input":{"file_path":"/tmp/test/src/index.ts","content":"export const hello = () => \"world\";"}}'
OUTPUT=$(cd "$TMPDIR" && echo "$INPUT" | "$HOOK_PATH" 2>/dev/null || true)
if echo "$OUTPUT" | validate_json; then
  if echo "$OUTPUT" | grep -q '"approve"'; then
    if echo "$OUTPUT" | grep -q 'Advisory'; then
      fail "Normal write should not produce advisory" "Got: $OUTPUT"
    else
      pass "Normal file write approved without warnings"
    fi
  else
    fail "Expected approve decision" "Got: $OUTPUT"
  fi
else
  fail "Output is not valid JSON" "Got: $OUTPUT"
fi
cleanup "$TMPDIR"

# ---------------------------------------------------------------
# Test 2: File with hardcoded password -> advisory warning
# ---------------------------------------------------------------
echo "Test 2: Hardcoded password -> advisory warning"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_name":"Write","tool_input":{"file_path":"/tmp/test/config.ts","content":"const password = \"SuperSecret123!\""}}'
OUTPUT=$(cd "$TMPDIR" && echo "$INPUT" | "$HOOK_PATH" 2>/dev/null || true)
if echo "$OUTPUT" | validate_json; then
  if echo "$OUTPUT" | grep -q '"approve"'; then
    if echo "$OUTPUT" | grep -qi 'secret\|password\|credential'; then
      pass "Hardcoded password triggers advisory warning"
    else
      fail "Expected secret/password warning" "Got: $OUTPUT"
    fi
  else
    fail "Expected approve decision even with warning" "Got: $OUTPUT"
  fi
else
  fail "Output is not valid JSON" "Got: $OUTPUT"
fi
cleanup "$TMPDIR"

# ---------------------------------------------------------------
# Test 3: AWS key pattern (AKIA...) -> advisory warning
# ---------------------------------------------------------------
echo "Test 3: AWS key pattern -> advisory warning"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_name":"Write","tool_input":{"file_path":"/tmp/test/config.ts","content":"const awsKey = \"AKIAIOSFODNN7EXAMPLE\""}}'
OUTPUT=$(cd "$TMPDIR" && echo "$INPUT" | "$HOOK_PATH" 2>/dev/null || true)
if echo "$OUTPUT" | validate_json; then
  if echo "$OUTPUT" | grep -q '"approve"'; then
    if echo "$OUTPUT" | grep -qi 'AWS\|key\|AKIA'; then
      pass "AWS key pattern triggers advisory warning"
    else
      fail "Expected AWS key warning" "Got: $OUTPUT"
    fi
  else
    fail "Expected approve decision" "Got: $OUTPUT"
  fi
else
  fail "Output is not valid JSON" "Got: $OUTPUT"
fi
cleanup "$TMPDIR"

# ---------------------------------------------------------------
# Test 4: console.log in production file -> advisory warning
# ---------------------------------------------------------------
echo "Test 4: console.log in production file -> advisory warning"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_name":"Write","tool_input":{"file_path":"/tmp/test/src/service.ts","content":"console.log(\"debug info\"); export function run() {}"}}'
OUTPUT=$(cd "$TMPDIR" && echo "$INPUT" | "$HOOK_PATH" 2>/dev/null || true)
if echo "$OUTPUT" | validate_json; then
  if echo "$OUTPUT" | grep -qi 'console.log\|structured logging'; then
    pass "console.log in production code triggers warning"
  else
    fail "Expected console.log warning for production file" "Got: $OUTPUT"
  fi
else
  fail "Output is not valid JSON" "Got: $OUTPUT"
fi
cleanup "$TMPDIR"

# ---------------------------------------------------------------
# Test 5: console.log in test file -> no warning
# ---------------------------------------------------------------
echo "Test 5: console.log in test file -> no warning"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_name":"Write","tool_input":{"file_path":"/tmp/test/src/service.test.ts","content":"console.log(\"test debug\"); test(\"it works\", () => {});"}}'
OUTPUT=$(cd "$TMPDIR" && echo "$INPUT" | "$HOOK_PATH" 2>/dev/null || true)
if echo "$OUTPUT" | validate_json; then
  if echo "$OUTPUT" | grep -qi 'console.log\|structured logging'; then
    fail "console.log in test file should not trigger warning" "Got: $OUTPUT"
  else
    pass "console.log in test file does not trigger warning"
  fi
else
  fail "Output is not valid JSON" "Got: $OUTPUT"
fi
cleanup "$TMPDIR"

# ---------------------------------------------------------------
# Test 6: Empty input -> approve
# ---------------------------------------------------------------
echo "Test 6: Empty input -> approve"
TMPDIR=$(setup_temp_project)
OUTPUT=$(cd "$TMPDIR" && echo "" | "$HOOK_PATH" 2>/dev/null || true)
if echo "$OUTPUT" | validate_json; then
  if echo "$OUTPUT" | grep -q '"approve"'; then
    pass "Empty input returns approve"
  else
    fail "Expected approve for empty input" "Got: $OUTPUT"
  fi
else
  fail "Output is not valid JSON for empty input" "Got: $OUTPUT"
fi
cleanup "$TMPDIR"

# ---------------------------------------------------------------
# Test 7: Missing architecture.md -> approve (no crash)
# ---------------------------------------------------------------
echo "Test 7: Missing architecture.md -> approve (no crash)"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_name":"Write","tool_input":{"file_path":"/tmp/test/src/app.ts","content":"export const app = true;"}}'
OUTPUT=$(cd "$TMPDIR" && echo "$INPUT" | "$HOOK_PATH" 2>/dev/null || true)
if echo "$OUTPUT" | validate_json; then
  if echo "$OUTPUT" | grep -q '"approve"'; then
    pass "Missing architecture.md still approves"
  else
    fail "Expected approve without architecture.md" "Got: $OUTPUT"
  fi
else
  fail "Output is not valid JSON without architecture.md" "Got: $OUTPUT"
fi
cleanup "$TMPDIR"

# ---------------------------------------------------------------
# Summary
# ---------------------------------------------------------------
echo ""
echo "=== Results ==="
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
