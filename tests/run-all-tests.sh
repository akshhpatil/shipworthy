#!/usr/bin/env bash
# Engineering With Vibes — Test Runner
# Executes all test scripts and reports overall results

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
FAILED_NAMES=""

echo "============================================"
echo "  Engineering With Vibes — Test Runner"
echo "============================================"
echo ""

# Find and run all test scripts
for test_file in "$SCRIPT_DIR"/hooks/test-*.sh; do
  if [ ! -f "$test_file" ]; then
    continue
  fi

  SUITE_NAME=$(basename "$test_file" .sh)
  TOTAL_SUITES=$((TOTAL_SUITES + 1))

  echo "--------------------------------------------"
  echo "Running: $SUITE_NAME"
  echo "--------------------------------------------"

  if bash "$test_file"; then
    PASSED_SUITES=$((PASSED_SUITES + 1))
  else
    FAILED_SUITES=$((FAILED_SUITES + 1))
    FAILED_NAMES="$FAILED_NAMES  - $SUITE_NAME\n"
  fi

  echo ""
done

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
