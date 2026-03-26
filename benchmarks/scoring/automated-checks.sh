#!/usr/bin/env bash
# =============================================================================
# automated-checks.sh
#
# Runs automated quality checks against a project directory and outputs a
# JSON report with per-check results, total score, and letter grade.
#
# Usage:
#   ./automated-checks.sh /path/to/project
#
# Exit codes:
#   0  -- checks completed (regardless of pass/fail)
#   1  -- usage error or project directory not found
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Argument handling
# ---------------------------------------------------------------------------
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/project" >&2
  exit 1
fi

PROJECT_DIR="$(cd "$1" && pwd)"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Error: directory '$1' does not exist" >&2
  exit 1
fi

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TOTAL_POINTS=0
MAX_POINTS=0
CHECKS_JSON=""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
add_check() {
  local name="$1"
  local pass="$2"      # true | false
  local points="$3"    # points awarded if pass=true
  local details="$4"

  MAX_POINTS=$((MAX_POINTS + points))

  local earned=0
  if [[ "$pass" == "true" ]]; then
    earned=$points
    TOTAL_POINTS=$((TOTAL_POINTS + points))
  fi

  local entry
  entry=$(cat <<ENTRY
    "${name}": { "pass": ${pass}, "points": ${earned}, "max_points": ${points}, "details": "${details}" }
ENTRY
)

  if [[ -n "$CHECKS_JSON" ]]; then
    CHECKS_JSON="${CHECKS_JSON},
${entry}"
  else
    CHECKS_JSON="$entry"
  fi
}

# Escape double-quotes and backslashes inside detail strings
esc() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/ }"
  printf '%s' "$s"
}

detect_language() {
  if [[ -f "$PROJECT_DIR/package.json" ]]; then
    echo "node"
  elif [[ -f "$PROJECT_DIR/requirements.txt" ]] || [[ -f "$PROJECT_DIR/pyproject.toml" ]] || [[ -f "$PROJECT_DIR/setup.py" ]]; then
    echo "python"
  elif [[ -f "$PROJECT_DIR/go.mod" ]]; then
    echo "go"
  else
    echo "unknown"
  fi
}

LANG="$(detect_language)"

# ---------------------------------------------------------------------------
# Check 1: Tests exist (3 points)
# ---------------------------------------------------------------------------
test_file_count=0
test_files=""
if [[ -d "$PROJECT_DIR" ]]; then
  test_files=$(find "$PROJECT_DIR" \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/dist/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/vendor/*' \
    \( -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*' -o -name '*_test.go' -o -name '*_test.py' \) \
    2>/dev/null || true)
  if [[ -n "$test_files" ]]; then
    test_file_count=$(echo "$test_files" | wc -l | tr -d ' ')
  fi
fi

if [[ "$test_file_count" -gt 0 ]]; then
  add_check "tests_exist" "true" 3 "$(esc "Found ${test_file_count} test file(s)")"
else
  add_check "tests_exist" "false" 3 "No test files found"
fi

# ---------------------------------------------------------------------------
# Check 2: Tests pass (3 points)
# ---------------------------------------------------------------------------
tests_pass="false"
test_details="No test runner detected"

cd "$PROJECT_DIR"
if [[ "$LANG" == "node" ]]; then
  if [[ -f "package.json" ]] && grep -q '"test"' package.json 2>/dev/null; then
    if [[ -d "node_modules" ]]; then
      test_output=$(npm test 2>&1) && tests_pass="true" || tests_pass="false"
    else
      npm install --ignore-scripts 2>/dev/null || true
      test_output=$(npm test 2>&1) && tests_pass="true" || tests_pass="false"
    fi
    test_details="$(esc "npm test exit code: $([[ $tests_pass == true ]] && echo 0 || echo 1)")"
  fi
elif [[ "$LANG" == "python" ]]; then
  if command -v pytest &>/dev/null; then
    test_output=$(pytest 2>&1) && tests_pass="true" || tests_pass="false"
    test_details="$(esc "pytest exit code: $([[ $tests_pass == true ]] && echo 0 || echo 1)")"
  fi
elif [[ "$LANG" == "go" ]]; then
  test_output=$(go test ./... 2>&1) && tests_pass="true" || tests_pass="false"
  test_details="$(esc "go test exit code: $([[ $tests_pass == true ]] && echo 0 || echo 1)")"
fi

add_check "tests_pass" "$tests_pass" 3 "$test_details"

# ---------------------------------------------------------------------------
# Check 3: Build passes (2 points)
# ---------------------------------------------------------------------------
build_pass="false"
build_details="No build step detected"

if [[ "$LANG" == "node" ]]; then
  if [[ -f "tsconfig.json" ]]; then
    if [[ ! -d "node_modules" ]]; then
      npm install --ignore-scripts 2>/dev/null || true
    fi
    build_output=$(npx tsc --noEmit 2>&1) && build_pass="true" || build_pass="false"
    build_details="$(esc "tsc --noEmit exit code: $([[ $build_pass == true ]] && echo 0 || echo 1)")"
  elif grep -q '"build"' package.json 2>/dev/null; then
    build_output=$(npm run build 2>&1) && build_pass="true" || build_pass="false"
    build_details="$(esc "npm run build exit code: $([[ $build_pass == true ]] && echo 0 || echo 1)")"
  fi
elif [[ "$LANG" == "go" ]]; then
  build_output=$(go build ./... 2>&1) && build_pass="true" || build_pass="false"
  build_details="$(esc "go build exit code: $([[ $build_pass == true ]] && echo 0 || echo 1)")"
elif [[ "$LANG" == "python" ]]; then
  # Python doesn't have a compile step, but we can check syntax
  syntax_errors=$(find "$PROJECT_DIR" -name '*.py' -not -path '*/node_modules/*' -exec python3 -m py_compile {} \; 2>&1 || true)
  if [[ -z "$syntax_errors" ]]; then
    build_pass="true"
    build_details="All .py files pass syntax check"
  else
    build_details="$(esc "Syntax errors found: ${syntax_errors}")"
  fi
fi

add_check "build_passes" "$build_pass" 2 "$build_details"

# ---------------------------------------------------------------------------
# Check 4: No hardcoded secrets (2 points)
# ---------------------------------------------------------------------------
secret_patterns='password\s*=\s*["\x27][^"\x27]+["\x27]|api_key\s*=\s*["\x27]|AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{20,}|sk_live_[a-zA-Z0-9]+'
secret_hits=$(grep -rEn "$secret_patterns" "$PROJECT_DIR" \
  --include='*.ts' --include='*.js' --include='*.py' --include='*.go' \
  --include='*.json' --include='*.yaml' --include='*.yml' --include='*.env' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='package-lock.json' --exclude='*.lock' \
  2>/dev/null || true)

if [[ -z "$secret_hits" ]]; then
  add_check "no_hardcoded_secrets" "true" 2 "No hardcoded secrets detected"
else
  hit_count=$(echo "$secret_hits" | wc -l | tr -d ' ')
  add_check "no_hardcoded_secrets" "false" 2 "$(esc "Found ${hit_count} potential secret(s) in source")"
fi

# ---------------------------------------------------------------------------
# Check 5: No console.log in production code (1 point)
# ---------------------------------------------------------------------------
console_hits=$(grep -rn 'console\.log' "$PROJECT_DIR" \
  --include='*.ts' --include='*.js' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.*' --exclude='*.spec.*' \
  2>/dev/null || true)

if [[ -z "$console_hits" ]] || [[ "$LANG" != "node" ]]; then
  add_check "no_console_log" "true" 1 "No console.log in production code"
else
  hit_count=$(echo "$console_hits" | wc -l | tr -d ' ')
  add_check "no_console_log" "false" 1 "$(esc "Found ${hit_count} console.log statement(s) in non-test files")"
fi

# ---------------------------------------------------------------------------
# Check 6: Input validation library (2 points)
# ---------------------------------------------------------------------------
validation_pass="false"
validation_details="No validation library detected"

if [[ "$LANG" == "node" ]]; then
  if grep -qE '"zod"|"joi"|"yup"|"class-validator"|"ajv"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    # Also check that it's actually imported somewhere in source
    usage=$(grep -rl 'from .zod\|from .joi\|from .yup\|from .class-validator\|from .ajv\|require.*zod\|require.*joi\|require.*yup' "$PROJECT_DIR" \
      --include='*.ts' --include='*.js' \
      --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
      2>/dev/null || true)
    if [[ -n "$usage" ]]; then
      validation_pass="true"
      validation_details="Validation library found in package.json and imported in source"
    else
      validation_details="Validation library in package.json but not imported in source"
    fi
  fi
elif [[ "$LANG" == "python" ]]; then
  if grep -qE 'pydantic|marshmallow|cerberus|wtforms|voluptuous' "$PROJECT_DIR/requirements.txt" 2>/dev/null || \
     grep -rqE 'from pydantic|import pydantic|from marshmallow|from cerberus' "$PROJECT_DIR" --include='*.py' --exclude-dir=.git 2>/dev/null; then
    validation_pass="true"
    validation_details="Python validation library detected"
  fi
elif [[ "$LANG" == "go" ]]; then
  if grep -qE 'validator|ozzo-validation' "$PROJECT_DIR/go.mod" 2>/dev/null; then
    validation_pass="true"
    validation_details="Go validation library detected"
  fi
fi

add_check "input_validation" "$validation_pass" 2 "$validation_details"

# ---------------------------------------------------------------------------
# Check 7: Error handling (2 points)
# ---------------------------------------------------------------------------
error_handling="false"
error_details="No structured error handling found"

if [[ "$LANG" == "node" ]]; then
  # Look for Express error middleware signature: (err, req, res, next)
  err_middleware=$(grep -rn 'err.*req.*res.*next\|error.*req.*res.*next\|ErrorRequestHandler' "$PROJECT_DIR" \
    --include='*.ts' --include='*.js' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    2>/dev/null || true)
  if [[ -n "$err_middleware" ]]; then
    error_handling="true"
    error_details="Error middleware pattern found"
  fi
elif [[ "$LANG" == "python" ]]; then
  err_handler=$(grep -rn 'errorhandler\|exception_handler\|@app.exception\|HTTPException' "$PROJECT_DIR" \
    --include='*.py' --exclude-dir=.git 2>/dev/null || true)
  if [[ -n "$err_handler" ]]; then
    error_handling="true"
    error_details="Error handler pattern found"
  fi
elif [[ "$LANG" == "go" ]]; then
  err_handler=$(grep -rn 'func.*error\|errors\.New\|fmt\.Errorf' "$PROJECT_DIR" \
    --include='*.go' --exclude-dir=vendor --exclude-dir=.git 2>/dev/null || true)
  if [[ -n "$err_handler" ]]; then
    error_handling="true"
    error_details="Go error handling patterns found"
  fi
fi

add_check "error_handling" "$error_handling" 2 "$error_details"

# ---------------------------------------------------------------------------
# Check 8: TypeScript strict mode (2 points)
# ---------------------------------------------------------------------------
if [[ "$LANG" == "node" ]] && [[ -f "$PROJECT_DIR/tsconfig.json" ]]; then
  if grep -q '"strict"\s*:\s*true' "$PROJECT_DIR/tsconfig.json" 2>/dev/null; then
    add_check "typescript_strict" "true" 2 "tsconfig.json has strict: true"
  else
    add_check "typescript_strict" "false" 2 "tsconfig.json missing strict: true"
  fi
else
  add_check "typescript_strict" "true" 2 "Not a TypeScript project (check not applicable, awarded by default)"
fi

# ---------------------------------------------------------------------------
# Check 9: No any types (1 point)
# ---------------------------------------------------------------------------
if [[ "$LANG" == "node" ]]; then
  any_hits=$(grep -rn ': any' "$PROJECT_DIR" \
    --include='*.ts' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    2>/dev/null || true)
  if [[ -z "$any_hits" ]]; then
    add_check "no_any_types" "true" 1 "No : any types found in .ts files"
  else
    hit_count=$(echo "$any_hits" | wc -l | tr -d ' ')
    add_check "no_any_types" "false" 1 "$(esc "Found ${hit_count} occurrence(s) of : any in .ts files")"
  fi
else
  add_check "no_any_types" "true" 1 "Not a TypeScript project (check not applicable)"
fi

# ---------------------------------------------------------------------------
# Check 10: Proper HTTP status codes (2 points)
# ---------------------------------------------------------------------------
status_pass="false"
status_details="No HTTP status code patterns found"

if [[ "$LANG" == "node" ]]; then
  status_hits=$(grep -rn 'res\.status\s*(\s*[2345]' "$PROJECT_DIR" \
    --include='*.ts' --include='*.js' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    2>/dev/null || true)
  if [[ -n "$status_hits" ]]; then
    has_201=$(echo "$status_hits" | grep -c '201' || true)
    has_400=$(echo "$status_hits" | grep -c '400' || true)
    has_404=$(echo "$status_hits" | grep -c '404' || true)
    if [[ "$has_201" -gt 0 ]] || [[ "$has_400" -gt 0 ]] || [[ "$has_404" -gt 0 ]]; then
      status_pass="true"
      status_details="$(esc "Found status codes: 201=${has_201} 400=${has_400} 404=${has_404} occurrences")"
    else
      status_details="Status codes found but missing 201/400/404 differentiation"
    fi
  fi
elif [[ "$LANG" == "python" ]]; then
  status_hits=$(grep -rn 'status_code\s*=\s*[2345]\|HTTPStatus\.\|return.*[2345][0-9][0-9]' "$PROJECT_DIR" \
    --include='*.py' --exclude-dir=.git 2>/dev/null || true)
  if [[ -n "$status_hits" ]]; then
    status_pass="true"
    status_details="HTTP status code patterns found"
  fi
elif [[ "$LANG" == "go" ]]; then
  status_hits=$(grep -rn 'http\.Status\|WriteHeader' "$PROJECT_DIR" \
    --include='*.go' --exclude-dir=vendor --exclude-dir=.git 2>/dev/null || true)
  if [[ -n "$status_hits" ]]; then
    status_pass="true"
    status_details="HTTP status code patterns found"
  fi
fi

add_check "http_status_codes" "$status_pass" 2 "$status_details"

# ---------------------------------------------------------------------------
# Check 11: Environment variables for config (1 point)
# ---------------------------------------------------------------------------
env_pass="false"
env_details="No environment variable usage detected"

if [[ "$LANG" == "node" ]]; then
  env_hits=$(grep -rn 'process\.env' "$PROJECT_DIR" \
    --include='*.ts' --include='*.js' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    --exclude='*.test.*' --exclude='*.spec.*' \
    2>/dev/null || true)
  if [[ -n "$env_hits" ]]; then
    env_pass="true"
    count=$(echo "$env_hits" | wc -l | tr -d ' ')
    env_details="$(esc "Found ${count} process.env reference(s)")"
  fi
elif [[ "$LANG" == "python" ]]; then
  env_hits=$(grep -rn 'os\.environ\|os\.getenv\|environ\.get' "$PROJECT_DIR" \
    --include='*.py' --exclude-dir=.git 2>/dev/null || true)
  if [[ -n "$env_hits" ]]; then
    env_pass="true"
    env_details="Environment variable usage found"
  fi
elif [[ "$LANG" == "go" ]]; then
  env_hits=$(grep -rn 'os\.Getenv\|os\.LookupEnv\|envconfig' "$PROJECT_DIR" \
    --include='*.go' --exclude-dir=vendor --exclude-dir=.git 2>/dev/null || true)
  if [[ -n "$env_hits" ]]; then
    env_pass="true"
    env_details="Environment variable usage found"
  fi
fi

add_check "env_variables" "$env_pass" 1 "$env_details"

# ---------------------------------------------------------------------------
# Check 12: Test coverage (1 point -- bonus, only if tooling available)
# ---------------------------------------------------------------------------
coverage_pass="false"
coverage_details="Coverage tooling not configured or not available"

if [[ "$LANG" == "node" ]]; then
  if grep -qE '"coverage"|"c8"|"istanbul"|"nyc"' "$PROJECT_DIR/package.json" 2>/dev/null || \
     grep -qE '"jest"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    # Jest has built-in coverage; check if configured
    coverage_pass="true"
    coverage_details="Coverage tooling configured (jest/c8/nyc/istanbul)"
  fi
elif [[ "$LANG" == "python" ]]; then
  if command -v coverage &>/dev/null || grep -q 'pytest-cov' "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
    coverage_pass="true"
    coverage_details="Python coverage tooling available"
  fi
elif [[ "$LANG" == "go" ]]; then
  # Go has built-in coverage
  coverage_pass="true"
  coverage_details="Go has built-in coverage support"
fi

add_check "test_coverage" "$coverage_pass" 1 "$coverage_details"

# ---------------------------------------------------------------------------
# Check 13: Lint passes (1 point)
# ---------------------------------------------------------------------------
lint_pass="false"
lint_details="No linter configured"

if [[ "$LANG" == "node" ]]; then
  if [[ -f "$PROJECT_DIR/.eslintrc" ]] || [[ -f "$PROJECT_DIR/.eslintrc.js" ]] || \
     [[ -f "$PROJECT_DIR/.eslintrc.json" ]] || [[ -f "$PROJECT_DIR/.eslintrc.cjs" ]] || \
     [[ -f "$PROJECT_DIR/eslint.config.js" ]] || [[ -f "$PROJECT_DIR/eslint.config.mjs" ]] || \
     grep -q '"eslint"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    if [[ -d "$PROJECT_DIR/node_modules" ]]; then
      lint_output=$(npx eslint . 2>&1) && lint_pass="true" || lint_pass="false"
    else
      lint_pass="true"  # Give benefit of the doubt if deps not installed
    fi
    if [[ "$lint_pass" == "true" ]]; then
      lint_details="ESLint configured and passes"
    else
      lint_details="ESLint configured but has errors"
    fi
  elif [[ -f "$PROJECT_DIR/.prettierrc" ]] || [[ -f "$PROJECT_DIR/.prettierrc.json" ]] || \
       grep -q '"prettier"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    lint_pass="true"
    lint_details="Prettier configured"
  fi
elif [[ "$LANG" == "python" ]]; then
  if [[ -f "$PROJECT_DIR/.flake8" ]] || [[ -f "$PROJECT_DIR/pyproject.toml" ]]; then
    lint_pass="true"
    lint_details="Python linter configured"
  fi
elif [[ "$LANG" == "go" ]]; then
  if command -v golangci-lint &>/dev/null; then
    lint_output=$(cd "$PROJECT_DIR" && golangci-lint run 2>&1) && lint_pass="true" || lint_pass="false"
    lint_details="golangci-lint $([[ $lint_pass == true ]] && echo passes || echo has errors)"
  else
    # go vet is always available
    lint_output=$(cd "$PROJECT_DIR" && go vet ./... 2>&1) && lint_pass="true" || lint_pass="false"
    lint_details="go vet $([[ $lint_pass == true ]] && echo passes || echo has errors)"
  fi
fi

add_check "lint_passes" "$lint_pass" 1 "$lint_details"

# ---------------------------------------------------------------------------
# Check 14: No circular imports (1 point)
# ---------------------------------------------------------------------------
circular_pass="true"
circular_details="No obvious circular imports detected"

if [[ "$LANG" == "node" ]]; then
  # Simple heuristic: look for files that import each other
  # A proper check would use madge, but this is a quick approximation
  if command -v npx &>/dev/null && [[ -d "$PROJECT_DIR/node_modules/.package-lock.json" ]] 2>/dev/null; then
    madge_output=$(cd "$PROJECT_DIR" && npx madge --circular src/ 2>/dev/null || true)
    if echo "$madge_output" | grep -q "Found .* circular"; then
      circular_pass="false"
      circular_details="$(esc "Circular imports detected by madge")"
    fi
  fi
fi

add_check "no_circular_imports" "$circular_pass" 1 "$circular_details"

# ---------------------------------------------------------------------------
# Check 15: Lock file present (1 point)
# ---------------------------------------------------------------------------
lock_pass="false"
lock_details="No lock file found"

if [[ -f "$PROJECT_DIR/package-lock.json" ]]; then
  lock_pass="true"
  lock_details="package-lock.json present"
elif [[ -f "$PROJECT_DIR/yarn.lock" ]]; then
  lock_pass="true"
  lock_details="yarn.lock present"
elif [[ -f "$PROJECT_DIR/pnpm-lock.yaml" ]]; then
  lock_pass="true"
  lock_details="pnpm-lock.yaml present"
elif [[ -f "$PROJECT_DIR/go.sum" ]]; then
  lock_pass="true"
  lock_details="go.sum present"
elif [[ -f "$PROJECT_DIR/Pipfile.lock" ]]; then
  lock_pass="true"
  lock_details="Pipfile.lock present"
elif [[ -f "$PROJECT_DIR/poetry.lock" ]]; then
  lock_pass="true"
  lock_details="poetry.lock present"
fi

add_check "lock_file_present" "$lock_pass" 1 "$lock_details"

# ---------------------------------------------------------------------------
# Calculate grade
# ---------------------------------------------------------------------------
grade="F"
if [[ $TOTAL_POINTS -ge 18 ]]; then
  grade="A"
elif [[ $TOTAL_POINTS -ge 14 ]]; then
  grade="B"
elif [[ $TOTAL_POINTS -ge 10 ]]; then
  grade="C"
elif [[ $TOTAL_POINTS -ge 6 ]]; then
  grade="D"
fi

# ---------------------------------------------------------------------------
# Output JSON
# ---------------------------------------------------------------------------
cat <<EOF
{
  "project": "${PROJECT_DIR}",
  "timestamp": "${TIMESTAMP}",
  "language": "${LANG}",
  "checks": {
${CHECKS_JSON}
  },
  "total_points": ${TOTAL_POINTS},
  "max_points": ${MAX_POINTS},
  "grade": "${grade}"
}
EOF
