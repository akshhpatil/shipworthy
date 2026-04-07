#!/usr/bin/env bash
# Shipworthy — Master Test Runner
# Executes all test suites: hooks, skills, and structure validation

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
FAILED_NAMES=""

echo "============================================"
echo "  Shipworthy — Test Runner"
echo "============================================"
echo ""

run_test_dir() {
  local dir_name="$1"
  local dir_path="$SCRIPT_DIR/$dir_name"

  if [ ! -d "$dir_path" ]; then
    return
  fi

  for test_file in "$dir_path"/test-*.sh; do
    if [ ! -f "$test_file" ]; then
      continue
    fi

    SUITE_NAME=$(basename "$test_file" .sh)
    TOTAL_SUITES=$((TOTAL_SUITES + 1))

    echo "--------------------------------------------"
    echo "Running: $dir_name/$SUITE_NAME"
    echo "--------------------------------------------"

    if bash "$test_file"; then
      PASSED_SUITES=$((PASSED_SUITES + 1))
    else
      FAILED_SUITES=$((FAILED_SUITES + 1))
      FAILED_NAMES="$FAILED_NAMES  - $dir_name/$SUITE_NAME\n"
    fi

    echo ""
  done
}

# Run all test categories
run_test_dir "hooks"
run_test_dir "skills"
run_test_dir "structure"
run_test_dir "security"

# Overall summary
echo "============================================"
echo "  Overall Results"
echo "============================================"
echo "Test suites run:    $TOTAL_SUITES"
echo "Test suites passed: $PASSED_SUITES"
echo "Test suites failed: $FAILED_SUITES"

if [ "$FAILED_SUITES" -gt 0 ]; then
  echo ""
  echo "Failed suites:"
  printf "$FAILED_NAMES"
  echo ""
  echo "OVERALL: SOME SUITES FAILED"
  exit 1
else
  echo ""
  echo "OVERALL: ALL SUITES PASSED"
  exit 0
fi
