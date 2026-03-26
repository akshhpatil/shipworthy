#!/usr/bin/env bash
# =============================================================================
# compare-ab.sh
#
# Blind A/B comparison of two codebases using an LLM as judge. Randomly assigns
# the two directories to "A" and "B" so the judge cannot infer which used the
# plugin. After scoring, reveals the mapping.
#
# Usage:
#   ./compare-ab.sh results/task-01-with/ results/task-01-without/
#
# Prerequisites:
#   - claude CLI installed and authenticated
#   - jq installed
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/results"
SCORING_DIR="${SCRIPT_DIR}/scoring"
JUDGE_PROMPT_FILE="${SCORING_DIR}/llm-judge-prompt.md"
COMPARISON_LOG="${RESULTS_DIR}/comparison-log.json"

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 /path/to/codebase-with /path/to/codebase-without" >&2
  exit 1
fi

DIR_WITH="$(cd "$1" && pwd)"
DIR_WITHOUT="$(cd "$2" && pwd)"

if [[ ! -d "$DIR_WITH" ]]; then
  echo "Error: directory '$1' does not exist" >&2
  exit 1
fi

if [[ ! -d "$DIR_WITHOUT" ]]; then
  echo "Error: directory '$2' does not exist" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
if ! command -v claude &>/dev/null; then
  echo "Error: claude CLI is not installed" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed" >&2
  exit 1
fi

if [[ ! -f "$JUDGE_PROMPT_FILE" ]]; then
  echo "Error: judge prompt not found at $JUDGE_PROMPT_FILE" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Collect source code from a directory into a single text block
# ---------------------------------------------------------------------------
collect_code() {
  local dir="$1"
  local output=""

  while IFS= read -r -d '' file; do
    local relpath="${file#${dir}/}"

    # Skip non-source files
    case "$relpath" in
      node_modules/*|.git/*|dist/*|build/*|__pycache__/*|vendor/*|*.lock|package-lock.json)
        continue
        ;;
    esac

    # Only include text files we care about
    case "$relpath" in
      *.ts|*.js|*.tsx|*.jsx|*.py|*.go|*.json|*.yaml|*.yml|*.toml|*.cfg|*.env.example|Makefile|Dockerfile|*.sh|*.md|*.html|*.css)
        ;;
      *)
        continue
        ;;
    esac

    local content
    content=$(cat "$file" 2>/dev/null || true)
    if [[ -n "$content" ]]; then
      output="${output}
--- ${relpath} ---
${content}
"
    fi
  done < <(find "$dir" -type f -print0 2>/dev/null | sort -z)

  echo "$output"
}

# ---------------------------------------------------------------------------
# Random coin flip: assign "with" and "without" to A and B
# ---------------------------------------------------------------------------
COIN=$((RANDOM % 2))

if [[ $COIN -eq 0 ]]; then
  # A = with-plugin, B = without-plugin
  DIR_A="$DIR_WITH"
  DIR_B="$DIR_WITHOUT"
  MAPPING_A="with-plugin"
  MAPPING_B="without-plugin"
else
  # A = without-plugin, B = with-plugin
  DIR_A="$DIR_WITHOUT"
  DIR_B="$DIR_WITH"
  MAPPING_A="without-plugin"
  MAPPING_B="with-plugin"
fi

echo "Blind assignment: A=${MAPPING_A}, B=${MAPPING_B}"
echo "(This mapping is hidden from the judge.)"
echo ""

# ---------------------------------------------------------------------------
# Collect code from both directories
# ---------------------------------------------------------------------------
echo "Collecting code from Codebase A..."
CODE_A=$(collect_code "$DIR_A")

echo "Collecting code from Codebase B..."
CODE_B=$(collect_code "$DIR_B")

if [[ -z "$CODE_A" ]] && [[ -z "$CODE_B" ]]; then
  echo "Error: both codebases are empty. Nothing to compare." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Try to extract the task prompt from the task file
# ---------------------------------------------------------------------------
TASK_PROMPT="(Task prompt not available -- judge both codebases on general software quality.)"

# Attempt to find the task file from the directory name
dir_basename=$(basename "$DIR_WITH")
task_name="${dir_basename%-with}"
task_name="${task_name%-without}"

for task_file in "${SCRIPT_DIR}/tasks"/*.md; do
  if [[ "$(basename "$task_file" .md)" == "$task_name" ]]; then
    TASK_PROMPT=$(awk '/^## Prompt$/{found=1; next} /^## /{if(found) exit} found{print}' "$task_file" | \
      sed 's/^> //' | sed '/^$/d' | head -20)
    break
  fi
done

# ---------------------------------------------------------------------------
# Build the judge prompt
# ---------------------------------------------------------------------------
# Read the template and substitute placeholders
JUDGE_TEMPLATE=$(cat "$JUDGE_PROMPT_FILE")

# Extract just the prompt section (after the "## Prompt" heading, skip the metadata)
JUDGE_BODY=$(echo "$JUDGE_TEMPLATE" | sed -n '/^You are an expert/,$ p')

# Perform substitutions
FULL_PROMPT=$(echo "$JUDGE_BODY" | \
  sed "s|{{TASK_PROMPT}}|${TASK_PROMPT}|g")

# The codebase placeholders need special handling because they contain newlines
# Build the final prompt by concatenating parts
FINAL_PROMPT="$(echo "$FULL_PROMPT" | sed '/{{CODEBASE_A}}/,/{{CODEBASE_A}}/d' | sed '/{{CODEBASE_B}}/,/{{CODEBASE_B}}/d')"

# Since sed can't handle multi-line replacements well, build the prompt directly
read -r -d '' FINAL_PROMPT <<PROMPT_EOF || true
You are an expert software engineer performing a blind code review. You have been given two codebases -- Codebase A and Codebase B -- that were both generated from the same task prompt. You do not know anything about how they were generated. Your job is to evaluate each codebase independently and then determine which one is better.

Task prompt that was given to generate both codebases:

${TASK_PROMPT}

---

### Codebase A

${CODE_A}

---

### Codebase B

${CODE_B}

---

Score each codebase on five dimensions (0-5 scale): Correctness, Security, Testing, Architecture, Production Readiness.

Calibration:
- 1 = Fundamentally broken or missing
- 3 = Works but with gaps
- 5 = Excellent, production-grade

You MUST provide specific evidence (file names, function names, patterns) for every score.

Respond with ONLY valid JSON in this exact format:
{
  "codebase_a": {
    "correctness": <0-5>,
    "correctness_evidence": "<evidence>",
    "security": <0-5>,
    "security_evidence": "<evidence>",
    "testing": <0-5>,
    "testing_evidence": "<evidence>",
    "architecture": <0-5>,
    "architecture_evidence": "<evidence>",
    "production": <0-5>,
    "production_evidence": "<evidence>",
    "total": <sum>
  },
  "codebase_b": {
    "correctness": <0-5>,
    "correctness_evidence": "<evidence>",
    "security": <0-5>,
    "security_evidence": "<evidence>",
    "testing": <0-5>,
    "testing_evidence": "<evidence>",
    "architecture": <0-5>,
    "architecture_evidence": "<evidence>",
    "production": <0-5>,
    "production_evidence": "<evidence>",
    "total": <sum>
  },
  "winner": "<A|B|TIE>",
  "margin": <absolute difference>,
  "reasoning": "<2-3 sentence summary>"
}
PROMPT_EOF

# ---------------------------------------------------------------------------
# Call Claude as the judge
# ---------------------------------------------------------------------------
echo "Sending codebases to LLM judge..."
echo ""

JUDGE_OUTPUT=$(echo "$FINAL_PROMPT" | claude --print 2>/dev/null || true)

if [[ -z "$JUDGE_OUTPUT" ]]; then
  echo "Error: LLM judge returned empty response" >&2
  exit 1
fi

# Try to extract JSON from the response (the judge might include extra text)
JUDGE_JSON=$(echo "$JUDGE_OUTPUT" | sed -n '/^{/,/^}/p' | head -50)

if [[ -z "$JUDGE_JSON" ]]; then
  # Try to find JSON in a code block
  JUDGE_JSON=$(echo "$JUDGE_OUTPUT" | sed -n '/```json/,/```/{/```/d;p}' | head -50)
fi

if [[ -z "$JUDGE_JSON" ]]; then
  echo "Warning: could not extract JSON from judge response." >&2
  echo "Raw response:"
  echo "$JUDGE_OUTPUT"
  JUDGE_JSON="{}"
fi

# Validate JSON
if ! echo "$JUDGE_JSON" | jq . &>/dev/null; then
  echo "Warning: judge output is not valid JSON" >&2
  echo "Raw output:"
  echo "$JUDGE_JSON"
  JUDGE_JSON="{}"
fi

# ---------------------------------------------------------------------------
# Reveal the mapping and translate results
# ---------------------------------------------------------------------------
echo "=== Judge Results ==="
echo "$JUDGE_JSON" | jq . 2>/dev/null || echo "$JUDGE_JSON"
echo ""

echo "=== Mapping Reveal ==="
echo "  Codebase A was: ${MAPPING_A}"
echo "  Codebase B was: ${MAPPING_B}"
echo ""

# Translate the winner from A/B to with-plugin/without-plugin
JUDGE_WINNER=$(echo "$JUDGE_JSON" | jq -r '.winner // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
ACTUAL_WINNER="unknown"

if [[ "$JUDGE_WINNER" == "A" ]]; then
  ACTUAL_WINNER="$MAPPING_A"
elif [[ "$JUDGE_WINNER" == "B" ]]; then
  ACTUAL_WINNER="$MAPPING_B"
elif [[ "$JUDGE_WINNER" == "TIE" ]]; then
  ACTUAL_WINNER="tie"
fi

echo "  Judge picked: ${JUDGE_WINNER} = ${ACTUAL_WINNER}"
echo ""

# ---------------------------------------------------------------------------
# Append to comparison log
# ---------------------------------------------------------------------------
mkdir -p "$RESULTS_DIR"

# Build the log entry
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
MARGIN=$(echo "$JUDGE_JSON" | jq -r '.margin // 0' 2>/dev/null || echo 0)
REASONING=$(echo "$JUDGE_JSON" | jq -r '.reasoning // "N/A"' 2>/dev/null || echo "N/A")
SCORE_A=$(echo "$JUDGE_JSON" | jq -r '.codebase_a.total // 0' 2>/dev/null || echo 0)
SCORE_B=$(echo "$JUDGE_JSON" | jq -r '.codebase_b.total // 0' 2>/dev/null || echo 0)

# Determine with-plugin and without-plugin scores
if [[ "$MAPPING_A" == "with-plugin" ]]; then
  SCORE_WITH="$SCORE_A"
  SCORE_WITHOUT="$SCORE_B"
else
  SCORE_WITH="$SCORE_B"
  SCORE_WITHOUT="$SCORE_A"
fi

LOG_ENTRY=$(cat <<LOG
{
  "timestamp": "${TIMESTAMP}",
  "dir_with": "${DIR_WITH}",
  "dir_without": "${DIR_WITHOUT}",
  "mapping": {
    "A": "${MAPPING_A}",
    "B": "${MAPPING_B}"
  },
  "judge_winner_label": "${JUDGE_WINNER}",
  "actual_winner": "${ACTUAL_WINNER}",
  "score_with_plugin": ${SCORE_WITH},
  "score_without_plugin": ${SCORE_WITHOUT},
  "margin": ${MARGIN},
  "reasoning": $(echo "$REASONING" | jq -Rs .),
  "raw_judge_output": $(echo "$JUDGE_JSON" | jq -c . 2>/dev/null || echo '{}')
}
LOG
)

# Append to the log file (create as JSON array if it doesn't exist)
if [[ -f "$COMPARISON_LOG" ]]; then
  # Read existing array, append new entry
  EXISTING=$(cat "$COMPARISON_LOG")
  echo "$EXISTING" | jq ". + [${LOG_ENTRY}]" > "$COMPARISON_LOG" 2>/dev/null || \
    echo "[${LOG_ENTRY}]" > "$COMPARISON_LOG"
else
  echo "[${LOG_ENTRY}]" > "$COMPARISON_LOG"
fi

echo "Results appended to: ${COMPARISON_LOG}"
