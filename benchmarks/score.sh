#!/usr/bin/env bash
# Shipworthy Benchmark Scorer — Objective, Automated
# Usage: ./score.sh <project-directory>
# Outputs JSON with metrics. No LLM judgment — only measurable facts.

set -uo pipefail
# Note: intentionally no -e flag. Grep returning 1 (no matches) is expected, not an error.

DIR="${1:?Usage: ./score.sh <project-directory>}"

if [ ! -d "$DIR" ]; then
  echo "Error: $DIR is not a directory"
  exit 1
fi

cd "$DIR"

SCORE=0
MAX_SCORE=0
DETAILS=""

add_check() {
  local name="$1"
  local passed="$2"
  local points="$3"
  local detail="${4:-}"
  MAX_SCORE=$((MAX_SCORE + points))
  if [ "$passed" = "1" ]; then
    SCORE=$((SCORE + points))
    DETAILS="${DETAILS}  PASS (+${points}): ${name}"
  else
    DETAILS="${DETAILS}  FAIL (+0/${points}): ${name}"
  fi
  if [ -n "$detail" ]; then
    DETAILS="${DETAILS} — ${detail}"
  fi
  DETAILS="${DETAILS}\n"
}

# ============================================================
# 1. BUILD & RUN (can it even start?)
# ============================================================

# Check: package.json or pyproject.toml exists
HAS_MANIFEST=0
LANG="unknown"
if [ -f "package.json" ]; then
  HAS_MANIFEST=1
  LANG="node"
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  HAS_MANIFEST=1
  LANG="python"
elif [ -f "go.mod" ]; then
  HAS_MANIFEST=1
  LANG="go"
fi
add_check "Project manifest exists" "$HAS_MANIFEST" 1 "$LANG"

# Check: dependencies installed
DEPS_INSTALLED=0
if [ "$LANG" = "node" ] && [ -d "node_modules" ]; then
  DEPS_INSTALLED=1
elif [ "$LANG" = "python" ] && { [ -d ".venv" ] || [ -d "venv" ] || pip list 2>/dev/null | grep -q "." ; }; then
  DEPS_INSTALLED=1
elif [ "$LANG" = "go" ] && [ -f "go.sum" ]; then
  DEPS_INSTALLED=1
fi
add_check "Dependencies installed" "$DEPS_INSTALLED" 1

# Check: build succeeds
BUILD_OK=0
if [ "$LANG" = "node" ]; then
  if grep -q '"build"' package.json 2>/dev/null; then
    if timeout 30 npm run build --silent 2>/dev/null; then
      BUILD_OK=1
    fi
  else
    # No build script = interpreted, counts as pass
    BUILD_OK=1
  fi
elif [ "$LANG" = "python" ]; then
  # Python doesn't need a build step for most apps
  if python3 -c "import ast; [ast.parse(open(f).read()) for f in __import__('glob').glob('**/*.py', recursive=True)]" 2>/dev/null; then
    BUILD_OK=1
  fi
elif [ "$LANG" = "go" ]; then
  if go build ./... 2>/dev/null; then
    BUILD_OK=1
  fi
fi
add_check "Build/parse succeeds" "$BUILD_OK" 2

# ============================================================
# 2. TESTING
# ============================================================

# Check: test files exist
TEST_FILE_COUNT=0
TEST_FILE_COUNT=$(find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" -o -name "*_test.go" -o -name "*_test.py" \) -not -path "*/node_modules/*" -not -path "*/.venv/*" 2>/dev/null | wc -l | tr -d ' ')
HAS_TESTS=0
[ "$TEST_FILE_COUNT" -gt 0 ] && HAS_TESTS=1
add_check "Test files exist" "$HAS_TESTS" 2 "${TEST_FILE_COUNT} test file(s)"

# Check: tests pass
TESTS_PASS=0
TEST_OUTPUT=""
if [ "$LANG" = "node" ] && grep -q '"test"' package.json 2>/dev/null; then
  TEST_OUTPUT=$(timeout 30 npm test 2>&1 || true)
  if echo "$TEST_OUTPUT" | grep -qiE '(passed|tests passed|✓|PASS)' 2>/dev/null; then
    if ! echo "$TEST_OUTPUT" | grep -qiE '(failed|FAIL|✗|error)' 2>/dev/null; then
      TESTS_PASS=1
    fi
  fi
elif [ "$LANG" = "python" ]; then
  TEST_OUTPUT=$(python3 -m pytest --tb=no -q 2>&1 || true)
  if echo "$TEST_OUTPUT" | grep -qE '[0-9]+ passed' 2>/dev/null; then
    if ! echo "$TEST_OUTPUT" | grep -qE '[0-9]+ (failed|error)' 2>/dev/null; then
      TESTS_PASS=1
    fi
  fi
fi
add_check "Tests pass" "$TESTS_PASS" 3

# Count passing tests
PASSING_TESTS=0
if [ "$TESTS_PASS" = "1" ]; then
  if [ "$LANG" = "node" ]; then
    PASSING_TESTS=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ (passed|tests)' | head -1 | grep -oE '[0-9]+' || echo "0")
  elif [ "$LANG" = "python" ]; then
    PASSING_TESTS=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+' || echo "0")
  fi
fi
add_check "Passing test count" "$([ "$PASSING_TESTS" -gt 5 ] && echo 1 || echo 0)" 2 "${PASSING_TESTS} tests"

# Check: coverage configured
HAS_COVERAGE=0
if [ "$LANG" = "node" ]; then
  if grep -rq 'coverage' package.json 2>/dev/null || [ -f "vitest.config.ts" ] && grep -q 'coverage' vitest.config.ts 2>/dev/null; then
    HAS_COVERAGE=1
  fi
elif [ "$LANG" = "python" ]; then
  if grep -rq 'pytest-cov\|coverage' pyproject.toml requirements.txt 2>/dev/null; then
    HAS_COVERAGE=1
  fi
fi
add_check "Coverage configured" "$HAS_COVERAGE" 1

# ============================================================
# 3. CODE QUALITY
# ============================================================

# Check: linter configured
HAS_LINTER=0
if [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f ".eslintrc.yml" ]; then
  HAS_LINTER=1
elif [ -f "ruff.toml" ] || ([ -f "pyproject.toml" ] && grep -q '\[tool\.ruff\]' pyproject.toml 2>/dev/null); then
  HAS_LINTER=1
elif [ -f ".golangci.yml" ]; then
  HAS_LINTER=1
fi
add_check "Linter configured" "$HAS_LINTER" 1

# Check: linter passes
LINT_PASSES=0
if [ "$HAS_LINTER" = "1" ]; then
  if [ "$LANG" = "node" ] && grep -q '"lint"' package.json 2>/dev/null; then
    if timeout 15 npm run lint --silent 2>/dev/null; then
      LINT_PASSES=1
    fi
  elif [ "$LANG" = "python" ]; then
    if ruff check . 2>/dev/null; then
      LINT_PASSES=1
    fi
  fi
fi
add_check "Linter passes" "$LINT_PASSES" 1

# Check: no console.log in production code
CONSOLE_LOG_COUNT=0
if [ "$LANG" = "node" ]; then
  CONSOLE_LOG_COUNT=$(grep -r 'console\.log' --include="*.ts" --include="*.js" --include="*.mjs" \
    --exclude-dir=node_modules --exclude-dir=dist --exclude="*.test.*" --exclude="*.spec.*" \
    . 2>/dev/null | wc -l | tr -d ' ')
fi
NO_CONSOLE_LOG=0
[ "$CONSOLE_LOG_COUNT" -eq 0 ] && NO_CONSOLE_LOG=1
add_check "No console.log in production code" "$NO_CONSOLE_LOG" 1 "${CONSOLE_LOG_COUNT} instances"

# Check: structured logging used
HAS_STRUCTURED_LOGGING=0
if [ "$LANG" = "node" ]; then
  if grep -rq 'pino\|winston\|bunyan' package.json 2>/dev/null; then
    HAS_STRUCTURED_LOGGING=1
  fi
elif [ "$LANG" = "python" ]; then
  if grep -rq 'import logging\|from logging' --include="*.py" . 2>/dev/null; then
    HAS_STRUCTURED_LOGGING=1
  fi
fi
add_check "Structured logging" "$HAS_STRUCTURED_LOGGING" 1

# Check: no `: any` in TypeScript
ANY_COUNT=0
if [ "$LANG" = "node" ]; then
  ANY_COUNT=$(grep -r ': any' --include="*.ts" --include="*.tsx" \
    --exclude-dir=node_modules --exclude-dir=dist --exclude="*.d.ts" \
    . 2>/dev/null | wc -l | tr -d ' ')
fi
NO_ANY=0
[ "$ANY_COUNT" -eq 0 ] && NO_ANY=1
add_check "No TypeScript : any" "$NO_ANY" 1 "${ANY_COUNT} instances"

# ============================================================
# 4. INPUT VALIDATION & ERROR HANDLING
# ============================================================

# Check: input validation library used
HAS_VALIDATION=0
if [ "$LANG" = "node" ]; then
  if grep -rq 'zod\|joi\|yup\|class-validator' package.json 2>/dev/null; then
    HAS_VALIDATION=1
  fi
elif [ "$LANG" = "python" ]; then
  if grep -rq 'pydantic\|marshmallow\|cerberus' pyproject.toml requirements.txt 2>/dev/null; then
    HAS_VALIDATION=1
  fi
fi
add_check "Input validation library" "$HAS_VALIDATION" 2

# Check: validation actually used in route handlers
VALIDATION_USED=0
if [ "$HAS_VALIDATION" = "1" ]; then
  if [ "$LANG" = "node" ]; then
    if grep -rq 'z\.\|schema\.\|validate(' --include="*.ts" --include="*.js" \
      --exclude-dir=node_modules . 2>/dev/null; then
      VALIDATION_USED=1
    fi
  elif [ "$LANG" = "python" ]; then
    if grep -rq 'BaseModel\|@validate' --include="*.py" . 2>/dev/null; then
      VALIDATION_USED=1
    fi
  fi
fi
add_check "Validation used in handlers" "$VALIDATION_USED" 2

# Check: error handling on routes (try/catch or error middleware)
HAS_ERROR_HANDLING=0
if [ "$LANG" = "node" ]; then
  ERROR_HANDLER_COUNT=$(grep -r 'catch\|errorHandler\|error.*middleware\|\.use.*err' --include="*.ts" --include="*.js" \
    --exclude-dir=node_modules --exclude="*.test.*" . 2>/dev/null | wc -l | tr -d ' ')
  [ "$ERROR_HANDLER_COUNT" -gt 2 ] && HAS_ERROR_HANDLING=1
elif [ "$LANG" = "python" ]; then
  ERROR_HANDLER_COUNT=$(grep -r 'except\|HTTPException\|exception_handler' --include="*.py" \
    --exclude-dir=.venv . 2>/dev/null | wc -l | tr -d ' ')
  [ "$ERROR_HANDLER_COUNT" -gt 2 ] && HAS_ERROR_HANDLING=1
fi
add_check "Error handling on routes" "$HAS_ERROR_HANDLING" 2

# Check: proper HTTP status codes (not just 200 for everything)
PROPER_STATUS=0
if [ "$LANG" = "node" ]; then
  STATUS_VARIETY=$(grep -roE '(status|statusCode)\s*\(\s*(201|204|400|404|409|422|500)\s*\)' --include="*.ts" --include="*.js" \
    --exclude-dir=node_modules . 2>/dev/null | sort -u | wc -l | tr -d ' ')
  [ "$STATUS_VARIETY" -ge 2 ] && PROPER_STATUS=1
elif [ "$LANG" = "python" ]; then
  STATUS_VARIETY=$(grep -roE 'status_code\s*=\s*(201|204|400|404|409|422|500)\b|status\.(HTTP_[24]\w+)' --include="*.py" \
    --exclude-dir=.venv . 2>/dev/null | sort -u | wc -l | tr -d ' ')
  [ "$STATUS_VARIETY" -ge 2 ] && PROPER_STATUS=1
fi
add_check "Varied HTTP status codes" "$PROPER_STATUS" 1

# ============================================================
# 5. DATABASE & ARCHITECTURE
# ============================================================

# Check: uses a real database (not in-memory arrays)
USES_DB=0
if [ "$LANG" = "node" ]; then
  if grep -rq 'sqlite\|postgres\|mysql\|prisma\|drizzle\|knex\|sequelize\|typeorm\|better-sqlite3\|pg\b' package.json 2>/dev/null; then
    USES_DB=1
  fi
elif [ "$LANG" = "python" ]; then
  if grep -rq 'sqlite\|sqlalchemy\|psycopg\|asyncpg\|tortoise\|peewee\|django\.db\|databases' pyproject.toml requirements.txt 2>/dev/null; then
    USES_DB=1
  fi
elif [ "$LANG" = "go" ]; then
  if grep -rq 'database/sql\|gorm\|sqlx\|pgx\|sqlite' go.mod 2>/dev/null; then
    USES_DB=1
  fi
fi
# Also check source code for DB imports
if [ "$USES_DB" = "0" ]; then
  if grep -rq 'sqlite\|postgres\|mysql\|prisma\|drizzle\|knex\|better-sqlite\|CREATE TABLE\|sequelize\|typeorm' \
    --include="*.ts" --include="*.js" --include="*.py" --include="*.go" \
    --exclude-dir=node_modules --exclude-dir=.venv . 2>/dev/null; then
    USES_DB=1
  fi
fi
add_check "Uses real database" "$USES_DB" 2

# Check: database migrations or schema file
HAS_MIGRATIONS=0
if [ -d "prisma" ] || [ -d "migrations" ] || [ -d "drizzle" ] || [ -d "alembic" ]; then
  HAS_MIGRATIONS=1
fi
# Also check for schema definition files
if grep -rq 'CREATE TABLE\|createTable\|db\.exec\|schema\.' --include="*.ts" --include="*.js" --include="*.py" --include="*.sql" \
  --exclude-dir=node_modules --exclude-dir=.venv . 2>/dev/null; then
  HAS_MIGRATIONS=1
fi
add_check "Database schema defined" "$HAS_MIGRATIONS" 1

# Check: proper directory structure (not everything in root)
SRC_FILES_IN_ROOT=$(find . -maxdepth 1 -name "*.ts" -o -name "*.js" -o -name "*.py" 2>/dev/null | grep -v 'config\|setup\|vitest\|eslint\|jest' | wc -l | tr -d ' ')
HAS_STRUCTURE=0
if [ -d "src" ] || [ -d "app" ] || [ -d "lib" ] || [ "$SRC_FILES_IN_ROOT" -le 2 ]; then
  HAS_STRUCTURE=1
fi
add_check "Organized directory structure" "$HAS_STRUCTURE" 1

# ============================================================
# 6. SECURITY BASICS
# ============================================================

# Check: .gitignore exists
HAS_GITIGNORE=0
[ -f ".gitignore" ] && HAS_GITIGNORE=1
add_check ".gitignore exists" "$HAS_GITIGNORE" 1

# Check: .env in .gitignore
ENV_IGNORED=0
if [ -f ".gitignore" ] && grep -q '\.env' .gitignore 2>/dev/null; then
  ENV_IGNORED=1
fi
add_check ".env in .gitignore" "$ENV_IGNORED" 1

# Check: no hardcoded secrets in source
NO_SECRETS=1
if grep -rqiE '(password|secret|api_key|apikey)\s*[:=]\s*["\x27][^"]{8,}' \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules --exclude-dir=.venv --exclude="*.test.*" --exclude="*.spec.*" \
  . 2>/dev/null; then
  NO_SECRETS=0
fi
add_check "No hardcoded secrets" "$NO_SECRETS" 2

# ============================================================
# 7. FEATURE COMPLETENESS (endpoint/route count)
# ============================================================

ENDPOINT_COUNT=0
if [ "$LANG" = "node" ]; then
  ENDPOINT_COUNT=$(grep -roE '(app|router)\.(get|post|put|patch|delete)\s*\(' --include="*.ts" --include="*.js" \
    --exclude-dir=node_modules --exclude="*.test.*" . 2>/dev/null | wc -l | tr -d ' ')
elif [ "$LANG" = "python" ]; then
  ENDPOINT_COUNT=$(grep -roE '@(app|router)\.(get|post|put|patch|delete)\b' --include="*.py" \
    --exclude-dir=.venv . 2>/dev/null | wc -l | tr -d ' ')
fi
HAS_ENDPOINTS=0
[ "$ENDPOINT_COUNT" -ge 5 ] && HAS_ENDPOINTS=1
add_check "5+ API endpoints" "$HAS_ENDPOINTS" 2 "${ENDPOINT_COUNT} endpoints"

# ============================================================
# 8. DOCUMENTATION & SPECS
# ============================================================

# Check: architecture spec or design doc exists
HAS_SPEC=0
if [ -f ".shipworthy/architecture.md" ] || [ -d ".shipworthy/specs" ] || [ -f "ARCHITECTURE.md" ] || [ -f "docs/design.md" ]; then
  HAS_SPEC=1
fi
add_check "Architecture/design spec exists" "$HAS_SPEC" 1

# Check: README exists with content
HAS_README=0
if [ -f "README.md" ] && [ "$(wc -l < README.md)" -gt 5 ]; then
  HAS_README=1
fi
add_check "README with content" "$HAS_README" 1

# ============================================================
# FINAL SCORE
# ============================================================

PERCENTAGE=0
if [ "$MAX_SCORE" -gt 0 ]; then
  PERCENTAGE=$(( (SCORE * 100) / MAX_SCORE ))
fi

# Grade
GRADE="F"
[ "$PERCENTAGE" -ge 90 ] && GRADE="A"
[ "$PERCENTAGE" -ge 80 ] && [ "$PERCENTAGE" -lt 90 ] && GRADE="B"
[ "$PERCENTAGE" -ge 70 ] && [ "$PERCENTAGE" -lt 80 ] && GRADE="C"
[ "$PERCENTAGE" -ge 60 ] && [ "$PERCENTAGE" -lt 70 ] && GRADE="D"

echo "============================================"
echo " SHIPWORTHY BENCHMARK SCORE"
echo "============================================"
echo ""
echo " Project: $(basename "$DIR")"
echo " Language: $LANG"
echo ""
echo "--------------------------------------------"
echo " CHECKS"
echo "--------------------------------------------"
printf "$DETAILS"
echo ""
echo "--------------------------------------------"
echo " SUMMARY"
echo "--------------------------------------------"
echo "  Score:      $SCORE / $MAX_SCORE"
echo "  Percentage: ${PERCENTAGE}%"
echo "  Grade:      $GRADE"
echo "  Tests:      $PASSING_TESTS passing"
echo "  Endpoints:  $ENDPOINT_COUNT"
echo "  Console.log: $CONSOLE_LOG_COUNT instances"
echo "  : any count: $ANY_COUNT instances"
echo "============================================"
