#!/usr/bin/env bash
# Shipworthy — Security Audit Tests
# Static analysis of hook scripts, skills, templates, and CLI
# for security anti-patterns. Ensures the plugin is safe for users.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOOKS_DIR="$REPO_ROOT/hooks"
SKILLS_DIR="$REPO_ROOT/skills"
TEMPLATES_DIR="$REPO_ROOT/templates"
BIN_DIR="$REPO_ROOT/bin"

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  PASS: $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  FAIL: $1"; [ -n "${2:-}" ] && echo "        $2"; }

echo "=== Security audit tests ==="
echo ""

# ---- Test 1: No shell variable interpolation in Python code ----
echo "--- Test 1: No Python string interpolation in hooks ---"
echo ""

# Detect python3 -c "...$VAR..." (double-quoted Python with shell vars)
# Safe pattern uses single-quoted strings with os.environ[]
UNSAFE_PYTHON=0
for hook_file in "$HOOKS_DIR"/*; do
  [ ! -f "$hook_file" ] && continue
  # Look for python3 -c " (double-quoted) containing $ that isn't escaped
  # We match multi-line python blocks: python3 -c " followed by lines until closing "
  # Simple heuristic: find python3 -c " on a line, then check if $VAR appears before closing quote
  if grep -Pn 'python3\s+-c\s+"[^"]*\$[A-Za-z_]' "$hook_file" 2>/dev/null; then
    fail "Python string interpolation in $(basename "$hook_file")" "Found \$VAR inside double-quoted python3 -c string"
    UNSAFE_PYTHON=$((UNSAFE_PYTHON + 1))
  fi
done

# Also check multi-line python blocks (python3 -c " on one line, $VAR on subsequent lines before closing ")
for hook_file in "$HOOKS_DIR"/*; do
  [ ! -f "$hook_file" ] && continue
  # Extract python3 -c blocks and check for unescaped $VAR
  # Use awk to find python3 -c " ... " blocks with shell variables
  matches=$(awk '
    /python3 -c "/ { in_block=1; block="" }
    in_block { block = block "\n" $0 }
    in_block && /^"/ && NR > 1 { in_block=0; if (block ~ /\$[A-Za-z_]/ && block !~ /\\$/) print FILENAME ":" NR ": " block; block="" }
    in_block && /"[[:space:]]*2>/ { in_block=0; if (block ~ /\$[A-Za-z_]/ && block !~ /\\\$/) print FILENAME ":" NR; block="" }
  ' "$hook_file" 2>/dev/null || true)
  if [ -n "$matches" ]; then
    fail "Multi-line Python interpolation in $(basename "$hook_file")" "$matches"
    UNSAFE_PYTHON=$((UNSAFE_PYTHON + 1))
  fi
done

if [ "$UNSAFE_PYTHON" -eq 0 ]; then
  pass "No unsafe Python string interpolation in hooks"
fi

echo ""

# ---- Test 2: No eval/exec in hook scripts ----
echo "--- Test 2: No eval/exec in hooks ---"
echo ""

EVAL_FOUND=0
for hook_file in "$HOOKS_DIR"/*; do
  [ ! -f "$hook_file" ] && continue
  fname=$(basename "$hook_file")
  # Skip non-script files (e.g., hooks.json)
  [[ "$fname" == *.json ]] && continue

  # Check for eval as a command (not in grep patterns or variable names)
  # Matches: eval "...", eval $..., but not: grep.*eval, echo.*eval, "eval()"
  eval_matches=$(grep -nE '^\s*eval\s' "$hook_file" 2>/dev/null || true)
  if [ -n "$eval_matches" ]; then
    fail "eval command found in $fname" "$eval_matches"
    EVAL_FOUND=$((EVAL_FOUND + 1))
  fi

  # Check for source command (only lib.sh is allowed)
  # Matches: source <path>, but not variable names like $source or "source"
  source_matches=$(grep -nE '^\s*source\s' "$hook_file" 2>/dev/null | grep -v 'lib.sh' || true)
  if [ -n "$source_matches" ]; then
    fail "Unauthorized source in $fname" "$source_matches"
    EVAL_FOUND=$((EVAL_FOUND + 1))
  fi
done

if [ "$EVAL_FOUND" -eq 0 ]; then
  pass "No eval/exec or unauthorized source in hooks"
fi

echo ""

# ---- Test 3: No hardcoded URLs except allowlist ----
echo "--- Test 3: No hardcoded URLs in hooks/bin ---"
echo ""

URL_ALLOWLIST="fonts.googleapis.com|fonts.gstatic.com|github.com|json-schema.org|pris.ly|npmjs.com|shields.io|img.shields.io|opensource.org|creativecommons.org|contributor-covenant.org"
URL_FOUND=0

for dir in "$HOOKS_DIR" "$BIN_DIR"; do
  for f in "$dir"/*; do
    [ ! -f "$f" ] && continue
    urls=$(grep -onE 'https?://[a-zA-Z0-9._/-]+' "$f" 2>/dev/null | grep -vE "$URL_ALLOWLIST" || true)
    if [ -n "$urls" ]; then
      fail "Unexpected URL in $(basename "$f")" "$urls"
      URL_FOUND=$((URL_FOUND + 1))
    fi
  done
done

if [ "$URL_FOUND" -eq 0 ]; then
  pass "No unexpected URLs in hooks or bin"
fi

echo ""

# ---- Test 4: No network requests in hooks ----
echo "--- Test 4: No network requests in hooks ---"
echo ""

NET_FOUND=0
NET_PATTERNS='curl\b|wget\b|fetch\(|http\.get|urllib|requests\.get|requests\.post|nc\s+-|ncat\b|socat\b'
for hook_file in "$HOOKS_DIR"/*; do
  [ ! -f "$hook_file" ] && continue
  net_matches=$(grep -nE "$NET_PATTERNS" "$hook_file" 2>/dev/null | grep -v '^[[:space:]]*#' || true)
  if [ -n "$net_matches" ]; then
    fail "Network request in $(basename "$hook_file")" "$net_matches"
    NET_FOUND=$((NET_FOUND + 1))
  fi
done

if [ "$NET_FOUND" -eq 0 ]; then
  pass "No network requests in hooks (offline-only)"
fi

echo ""

# ---- Test 5: No unsafe /tmp operations ----
echo "--- Test 5: No unsafe /tmp operations in hooks ---"
echo ""

TMP_FOUND=0
for hook_file in "$HOOKS_DIR"/*; do
  [ ! -f "$hook_file" ] && continue
  # Flag direct /tmp/ paths (mktemp is safe, /tmp/shipworthy-* is not)
  tmp_matches=$(grep -n '/tmp/' "$hook_file" 2>/dev/null | grep -v '^[[:space:]]*#' | grep -v 'mktemp' || true)
  if [ -n "$tmp_matches" ]; then
    fail "Unsafe /tmp usage in $(basename "$hook_file")" "$tmp_matches"
    TMP_FOUND=$((TMP_FOUND + 1))
  fi
done

if [ "$TMP_FOUND" -eq 0 ]; then
  pass "No unsafe /tmp operations in hooks"
fi

echo ""

# ---- Test 6: No obfuscated code ----
echo "--- Test 6: No obfuscated code ---"
echo ""

OBFUSC_FOUND=0
OBFUSC_PATTERNS='base64\s+-d|base64\s+--decode|atob\(|btoa\(|Buffer\.from\([^)]*base64|b64decode|b64encode'
for dir in "$HOOKS_DIR" "$BIN_DIR" "$REPO_ROOT/commands" "$REPO_ROOT/agents"; do
  [ ! -d "$dir" ] && continue
  for f in "$dir"/*; do
    [ ! -f "$f" ] && continue
    obfusc_matches=$(grep -nE "$OBFUSC_PATTERNS" "$f" 2>/dev/null || true)
    if [ -n "$obfusc_matches" ]; then
      fail "Obfuscated code in $(basename "$f")" "$obfusc_matches"
      OBFUSC_FOUND=$((OBFUSC_FOUND + 1))
    fi
  done
done

if [ "$OBFUSC_FOUND" -eq 0 ]; then
  pass "No obfuscated code (base64 encode/decode) in executable files"
fi

echo ""

# ---- Test 7: Skills don't instruct download-and-execute ----
echo "--- Test 7: No download-and-execute in skills ---"
echo ""

DL_EXEC_FOUND=0
# Positive download-and-execute patterns (not in "NEVER" / "Don't" context)
for skill_file in "$SKILLS_DIR"/**/SKILL.md; do
  [ ! -f "$skill_file" ] && continue
  # Find curl|bash or wget|sh patterns
  dl_matches=$(grep -inE 'curl\s+[^|]*\|\s*(bash|sh|zsh)|wget\s+[^|]*\|\s*(bash|sh|zsh)' "$skill_file" 2>/dev/null || true)
  if [ -n "$dl_matches" ]; then
    # Check if it's in a negative context (NEVER, Don't, avoid, do not)
    for match in $dl_matches; do
      if ! echo "$match" | grep -qiE 'never|don.t|avoid|do not|anti.pattern|bad|unsafe|dangerous'; then
        fail "Download-and-execute in $(echo "$skill_file" | sed "s|$REPO_ROOT/||")" "$dl_matches"
        DL_EXEC_FOUND=$((DL_EXEC_FOUND + 1))
        break
      fi
    done
  fi
done

if [ "$DL_EXEC_FOUND" -eq 0 ]; then
  pass "No download-and-execute instructions in skills"
fi

echo ""

# ---- Test 8: Templates have no insecure defaults ----
echo "--- Test 8: No insecure defaults in templates ---"
echo ""

INSECURE_FOUND=0
for template_file in "$TEMPLATES_DIR"/*.md; do
  [ ! -f "$template_file" ] && continue
  tname=$(basename "$template_file")

  # Check for CORS wildcard as a positive instruction (not in "NEVER" context)
  cors_matches=$(grep -n 'Access-Control-Allow-Origin.*\*' "$template_file" 2>/dev/null | grep -viE 'never|don.t|avoid|no\b' || true)
  if [ -n "$cors_matches" ]; then
    fail "CORS wildcard in $tname" "$cors_matches"
    INSECURE_FOUND=$((INSECURE_FOUND + 1))
  fi

  # Check for DEBUG=True or NODE_ENV=development as positive defaults
  debug_matches=$(grep -nE '^\s*(DEBUG\s*=\s*True|NODE_ENV\s*=\s*development)' "$template_file" 2>/dev/null || true)
  if [ -n "$debug_matches" ]; then
    fail "Debug mode default in $tname" "$debug_matches"
    INSECURE_FOUND=$((INSECURE_FOUND + 1))
  fi
done

if [ "$INSECURE_FOUND" -eq 0 ]; then
  pass "No insecure defaults in templates"
fi

echo ""

# ---- Test 9: Hooks produce valid JSON on error ----
echo "--- Test 9: Hooks produce valid JSON on ERR trap ---"
echo ""

ERR_JSON_OK=0
ERR_JSON_FAIL=0
for hook_file in "$HOOKS_DIR"/*; do
  [ ! -f "$hook_file" ] && continue
  fname=$(basename "$hook_file")
  [ "$fname" = "lib.sh" ] && continue    # library, not a hook
  [[ "$fname" == *.json ]] && continue    # config file, not a hook

  # Check that each hook has an ERR trap that outputs JSON
  if grep -q "trap.*ERR" "$hook_file" 2>/dev/null; then
    # Verify the trap outputs JSON (contains hookSpecificOutput or valid JSON structure)
    trap_line=$(grep "trap.*ERR" "$hook_file" | head -1)
    if echo "$trap_line" | grep -qE 'hookSpecificOutput|echo.*\{'; then
      ERR_JSON_OK=$((ERR_JSON_OK + 1))
    else
      fail "ERR trap in $fname doesn't output JSON" "$trap_line"
      ERR_JSON_FAIL=$((ERR_JSON_FAIL + 1))
    fi
  else
    fail "No ERR trap in $fname" "Hooks must output valid JSON even on error"
    ERR_JSON_FAIL=$((ERR_JSON_FAIL + 1))
  fi
done

if [ "$ERR_JSON_FAIL" -eq 0 ]; then
  pass "All hooks have ERR traps producing valid JSON ($ERR_JSON_OK hooks)"
fi

echo ""

# ---- Test 10: No secrets patterns in tracked code ----
echo "--- Test 10: No secrets in tracked files ---"
echo ""

SECRET_PATTERNS=(
  'AKIA[0-9A-Z]{16}'                       # AWS access key
  'sk-[a-zA-Z0-9]{20,}'                    # OpenAI/Stripe key
  'ghp_[a-zA-Z0-9]{36}'                    # GitHub PAT
  'xox[baprs]-[a-zA-Z0-9-]+'              # Slack token
)

SECRETS_FOUND=0
for pattern in "${SECRET_PATTERNS[@]}"; do
  matches=$(grep -rn --include='*.sh' --include='*.js' --include='*.cjs' --include='*.json' --include='*.yml' \
    -E "$pattern" "$REPO_ROOT" \
    --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=benchmarks/results 2>/dev/null | head -5 || true)
  if [ -n "$matches" ]; then
    # Filter out SKILL.md references (they describe patterns, not contain real secrets)
    real_matches=$(echo "$matches" | grep -v 'SKILL.md' | grep -v 'test-' || true)
    if [ -n "$real_matches" ]; then
      fail "Potential secret: $pattern" "$real_matches"
      SECRETS_FOUND=$((SECRETS_FOUND + 1))
    fi
  fi
done

if [ "$SECRETS_FOUND" -eq 0 ]; then
  pass "No secret patterns in tracked code"
fi

echo ""

# ---- Test 11: Hook scripts have safe permissions ----
echo "--- Test 11: Hook file permissions ---"
echo ""

PERM_ISSUES=0

# lib.sh should NOT be executable (it's sourced, not run directly)
if [ -x "$HOOKS_DIR/lib.sh" ]; then
  fail "lib.sh should not be executable (644, not 755)"
  PERM_ISSUES=$((PERM_ISSUES + 1))
fi

# All other hooks should be executable
for hook_file in "$HOOKS_DIR"/*; do
  [ ! -f "$hook_file" ] && continue
  fname=$(basename "$hook_file")
  [ "$fname" = "lib.sh" ] && continue
  [[ "$fname" == *.json ]] && continue    # config file, not a hook
  if [ ! -x "$hook_file" ]; then
    fail "$fname is not executable" "Hooks must be executable (755)"
    PERM_ISSUES=$((PERM_ISSUES + 1))
  fi
done

if [ "$PERM_ISSUES" -eq 0 ]; then
  pass "All hook permissions correct (lib.sh=644, hooks=755)"
fi

echo ""

# ---- Test 12: Zero external dependencies ----
echo "--- Test 12: Zero external dependencies ---"
echo ""

DEP_ISSUES=0
PKG_FILE="$REPO_ROOT/package.json"
if [ -f "$PKG_FILE" ]; then
  # Check for dependencies or devDependencies keys
  if grep -q '"dependencies"' "$PKG_FILE" 2>/dev/null; then
    fail "package.json has 'dependencies' — should be zero-dependency"
    DEP_ISSUES=$((DEP_ISSUES + 1))
  fi
  if grep -q '"devDependencies"' "$PKG_FILE" 2>/dev/null; then
    fail "package.json has 'devDependencies' — should be zero-dependency"
    DEP_ISSUES=$((DEP_ISSUES + 1))
  fi
  # Check for postinstall or other lifecycle scripts
  if grep -qE '"(postinstall|preinstall|prepare|prepublish)"' "$PKG_FILE" 2>/dev/null; then
    fail "package.json has lifecycle scripts (potential supply chain risk)"
    DEP_ISSUES=$((DEP_ISSUES + 1))
  fi
fi

if [ "$DEP_ISSUES" -eq 0 ]; then
  pass "Zero external dependencies, no lifecycle scripts"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "SECURITY AUDIT FAILED"
  exit 1
else
  echo "ALL SECURITY AUDIT CHECKS PASSED"
  exit 0
fi
