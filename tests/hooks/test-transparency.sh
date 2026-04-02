#!/usr/bin/env bash
# Tests for the transparency logging system (shell track)
# Validates: stderr output, toggle behavior, format correctness, JSON isolation

set -euo pipefail

HOOKS_DIR="$(cd "$(dirname "$0")/../../hooks" && pwd)"
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

echo "=== transparency logging tests ==="
echo ""

# ---------------------------------------------------------------
# Test 1: Transparency output goes to stderr, not stdout
# ---------------------------------------------------------------
echo "Test 1: Transparency output goes to stderr, not stdout"
TMPDIR=$(setup_temp_project)
# Clear any session markers
rm -f /tmp/shipworthy-session-* 2>/dev/null || true
STDOUT_OUTPUT=$(cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=1 "$HOOKS_DIR/session-start" 2>/tmp/sw-test-stderr)
STDERR_OUTPUT=$(cat /tmp/sw-test-stderr 2>/dev/null || true)
if echo "$STDERR_OUTPUT" | grep -q "shipworthy"; then
  pass "Transparency output found on stderr"
else
  fail "No transparency output on stderr" "stderr: $STDERR_OUTPUT"
fi
cleanup "$TMPDIR"
rm -f /tmp/sw-test-stderr /tmp/shipworthy-session-* 2>/dev/null || true

# ---------------------------------------------------------------
# Test 2: stdout remains valid JSON when transparency is on
# ---------------------------------------------------------------
echo "Test 2: stdout remains valid JSON with transparency enabled"
TMPDIR=$(setup_temp_project)
rm -f /tmp/shipworthy-session-* 2>/dev/null || true
STDOUT_OUTPUT=$(cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=1 "$HOOKS_DIR/session-start" 2>/dev/null)
if echo "$STDOUT_OUTPUT" | validate_json; then
  pass "stdout is valid JSON with transparency on"
else
  fail "stdout is not valid JSON" "Got: $(echo "$STDOUT_OUTPUT" | head -c 200)"
fi
cleanup "$TMPDIR"
rm -f /tmp/shipworthy-session-* 2>/dev/null || true

# ---------------------------------------------------------------
# Test 3: SHIPWORTHY_TRANSPARENCY=0 disables stderr output
# ---------------------------------------------------------------
echo "Test 3: SHIPWORTHY_TRANSPARENCY=0 disables transparency"
TMPDIR=$(setup_temp_project)
rm -f /tmp/shipworthy-session-* 2>/dev/null || true
cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=0 "$HOOKS_DIR/session-start" >/dev/null 2>/tmp/sw-test-stderr
STDERR_OUTPUT=$(cat /tmp/sw-test-stderr 2>/dev/null || true)
if [ -z "$STDERR_OUTPUT" ]; then
  pass "No stderr output when transparency disabled"
else
  fail "Unexpected stderr output when transparency=0" "stderr: $(echo "$STDERR_OUTPUT" | head -c 200)"
fi
cleanup "$TMPDIR"
rm -f /tmp/sw-test-stderr /tmp/shipworthy-session-* 2>/dev/null || true

# ---------------------------------------------------------------
# Test 4: Config file "transparency": false disables output
# ---------------------------------------------------------------
echo "Test 4: Config file transparency=false disables output"
TMPDIR=$(setup_temp_project)
rm -f /tmp/shipworthy-session-* 2>/dev/null || true
mkdir -p "$TMPDIR/.shipworthy"
echo '{"transparency": false}' > "$TMPDIR/.shipworthy/config.json"
# Unset env var to test config fallback
cd "$TMPDIR" && unset SHIPWORTHY_TRANSPARENCY && "$HOOKS_DIR/session-start" >/dev/null 2>/tmp/sw-test-stderr
STDERR_OUTPUT=$(cat /tmp/sw-test-stderr 2>/dev/null || true)
if [ -z "$STDERR_OUTPUT" ]; then
  pass "No stderr output when config transparency=false"
else
  fail "Unexpected stderr with config transparency=false" "stderr: $(echo "$STDERR_OUTPUT" | head -c 200)"
fi
cleanup "$TMPDIR"
rm -f /tmp/sw-test-stderr /tmp/shipworthy-session-* 2>/dev/null || true

# ---------------------------------------------------------------
# Test 5: Env var overrides config (env=0 wins over config=true)
# ---------------------------------------------------------------
echo "Test 5: Env var overrides config file"
TMPDIR=$(setup_temp_project)
rm -f /tmp/shipworthy-session-* 2>/dev/null || true
mkdir -p "$TMPDIR/.shipworthy"
echo '{"transparency": true}' > "$TMPDIR/.shipworthy/config.json"
cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=0 "$HOOKS_DIR/session-start" >/dev/null 2>/tmp/sw-test-stderr
STDERR_OUTPUT=$(cat /tmp/sw-test-stderr 2>/dev/null || true)
if [ -z "$STDERR_OUTPUT" ]; then
  pass "Env var=0 overrides config=true"
else
  fail "Env var did not override config" "stderr: $(echo "$STDERR_OUTPUT" | head -c 200)"
fi
cleanup "$TMPDIR"
rm -f /tmp/sw-test-stderr /tmp/shipworthy-session-* 2>/dev/null || true

# ---------------------------------------------------------------
# Test 6: Session banner contains box-drawing chars and tier
# ---------------------------------------------------------------
echo "Test 6: Session banner format"
TMPDIR=$(setup_temp_project)
rm -f /tmp/shipworthy-session-* 2>/dev/null || true
cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=1 "$HOOKS_DIR/session-start" >/dev/null 2>/tmp/sw-test-stderr
STDERR_OUTPUT=$(cat /tmp/sw-test-stderr 2>/dev/null || true)
if echo "$STDERR_OUTPUT" | grep -q "┌" && echo "$STDERR_OUTPUT" | grep -q "┘"; then
  pass "Banner contains box-drawing characters"
else
  fail "Banner missing box-drawing characters" "stderr: $(echo "$STDERR_OUTPUT" | head -c 300)"
fi
cleanup "$TMPDIR"
rm -f /tmp/sw-test-stderr /tmp/shipworthy-session-* 2>/dev/null || true

# ---------------------------------------------------------------
# Test 7: Security warning format includes check name and WARN
# ---------------------------------------------------------------
echo "Test 7: Security warning format"
TMPDIR=$(setup_temp_project)
# Feed a Write/Edit input with an AWS key pattern
INPUT='{"tool_input":{"file_path":"/tmp/test.ts","content":"const key = \"AKIA1234567890ABCDEF\""}}'
STDERR_OUTPUT=""
echo "$INPUT" | (cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=1 "$HOOKS_DIR/pre-tool-use" >/dev/null 2>/tmp/sw-test-stderr) || true
STDERR_OUTPUT=$(cat /tmp/sw-test-stderr 2>/dev/null || true)
if echo "$STDERR_OUTPUT" | grep -q "WARN"; then
  pass "Security warning shows WARN"
else
  fail "Security warning missing WARN indicator" "stderr: $(echo "$STDERR_OUTPUT" | head -c 300)"
fi
cleanup "$TMPDIR"
rm -f /tmp/sw-test-stderr 2>/dev/null || true

# ---------------------------------------------------------------
# Test 8: Clean check shows "passed"
# ---------------------------------------------------------------
echo "Test 8: Clean check shows passed"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_input":{"file_path":"/tmp/test.ts","content":"const x = 42;"}}'
echo "$INPUT" | (cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=1 "$HOOKS_DIR/pre-tool-use" >/dev/null 2>/tmp/sw-test-stderr) || true
STDERR_OUTPUT=$(cat /tmp/sw-test-stderr 2>/dev/null || true)
if echo "$STDERR_OUTPUT" | grep -q "passed"; then
  pass "Clean check shows passed"
else
  fail "Clean check missing passed indicator" "stderr: $(echo "$STDERR_OUTPUT" | head -c 300)"
fi
cleanup "$TMPDIR"
rm -f /tmp/sw-test-stderr 2>/dev/null || true

# ---------------------------------------------------------------
# Test 9: JSON output identical with and without transparency
# ---------------------------------------------------------------
echo "Test 9: JSON output unchanged by transparency"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_input":{"file_path":"/tmp/test.ts","content":"const x = 42;"}}'
rm -f /tmp/shipworthy-session-* 2>/dev/null || true
JSON_WITH=$(echo "$INPUT" | (cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=1 "$HOOKS_DIR/pre-tool-use" 2>/dev/null) || true)
JSON_WITHOUT=$(echo "$INPUT" | (cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=0 "$HOOKS_DIR/pre-tool-use" 2>/dev/null) || true)
if [ "$JSON_WITH" = "$JSON_WITHOUT" ]; then
  pass "JSON output identical with and without transparency"
else
  fail "JSON output differs" "With: $JSON_WITH | Without: $JSON_WITHOUT"
fi
cleanup "$TMPDIR"
rm -f /tmp/shipworthy-session-* 2>/dev/null || true

# ---------------------------------------------------------------
# Test 10: No stderr noise for no-op post-tool-use (ls command)
# ---------------------------------------------------------------
echo "Test 10: No noise on no-op hook invocations"
TMPDIR=$(setup_temp_project)
INPUT='{"tool_input":{"command":"ls -la"}}'
echo "$INPUT" | (cd "$TMPDIR" && SHIPWORTHY_TRANSPARENCY=1 "$HOOKS_DIR/post-tool-use" >/dev/null 2>/tmp/sw-test-stderr) || true
STDERR_OUTPUT=$(cat /tmp/sw-test-stderr 2>/dev/null || true)
if [ -z "$STDERR_OUTPUT" ]; then
  pass "No stderr noise for benign commands"
else
  fail "Unexpected stderr for no-op command" "stderr: $(echo "$STDERR_OUTPUT" | head -c 200)"
fi
cleanup "$TMPDIR"
rm -f /tmp/sw-test-stderr 2>/dev/null || true

# ---------------------------------------------------------------
# Summary
# ---------------------------------------------------------------
echo ""
echo "=== Results: $PASSED passed, $FAILED failed ==="

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
