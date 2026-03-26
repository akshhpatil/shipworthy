#!/usr/bin/env bash
# =============================================================================
# run-benchmark.sh
#
# Main benchmark runner. Sets up a clean project, runs Claude Code with or
# without the plugin, and scores the output.
#
# Usage:
#   ./run-benchmark.sh --task 1                    # Run task 1 in --both mode
#   ./run-benchmark.sh --task 1 --with-plugin      # Run task 1 with plugin only
#   ./run-benchmark.sh --task 1 --without-plugin   # Run task 1 without plugin only
#   ./run-benchmark.sh --all                       # Run all 10 tasks in --both mode
#   ./run-benchmark.sh --all --with-plugin         # Run all tasks with plugin only
#
# Prerequisites:
#   - claude CLI installed and authenticated
#   - Node.js / npm available
#   - jq installed (for JSON processing)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASKS_DIR="${SCRIPT_DIR}/tasks"
RESULTS_DIR="${SCRIPT_DIR}/results"
SCORING_DIR="${SCRIPT_DIR}/scoring"
PLUGIN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
TASK_NUM=""
RUN_ALL=false
MODE="both"  # with-plugin | without-plugin | both

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --task N              Run a specific task (1-10)
  --all                 Run all available tasks
  --with-plugin         Run with the plugin installed
  --without-plugin      Run without the plugin
  --both                Run both with and without, then compare (default)
  --help                Show this help message

Examples:
  $0 --task 1
  $0 --task 3 --with-plugin
  $0 --all --both
EOF
  exit 0
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      TASK_NUM="$2"
      shift 2
      ;;
    --all)
      RUN_ALL=true
      shift
      ;;
    --with-plugin)
      MODE="with-plugin"
      shift
      ;;
    --without-plugin)
      MODE="without-plugin"
      shift
      ;;
    --both)
      MODE="both"
      shift
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

if [[ -z "$TASK_NUM" ]] && [[ "$RUN_ALL" == "false" ]]; then
  echo "Error: specify --task N or --all" >&2
  usage
fi

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
check_prerequisites() {
  local missing=()

  if ! command -v claude &>/dev/null; then
    missing+=("claude CLI")
  fi

  if ! command -v node &>/dev/null; then
    missing+=("node")
  fi

  if ! command -v npm &>/dev/null; then
    missing+=("npm")
  fi

  if ! command -v jq &>/dev/null; then
    missing+=("jq")
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Error: missing required tools: ${missing[*]}" >&2
    echo "Install them before running the benchmark." >&2
    exit 1
  fi
}

check_prerequisites

# ---------------------------------------------------------------------------
# Parse a task markdown file to extract prompt and setup files
# ---------------------------------------------------------------------------
extract_prompt() {
  local task_file="$1"
  # Extract everything between ## Prompt and the next ## heading
  sed -n '/^## Prompt$/,/^## /{/^## Prompt$/d;/^## /d;p}' "$task_file" | \
    sed 's/^> //' | \
    sed '/^$/d' | \
    head -20
}

extract_setup_file() {
  local task_file="$1"
  local filename="$2"
  # Extract the code block after **filename**
  local in_block=false
  local found_file=false
  local content=""

  while IFS= read -r line; do
    if [[ "$found_file" == "false" ]] && echo "$line" | grep -q "^\*\*${filename}\*\*"; then
      found_file=true
      continue
    fi
    if [[ "$found_file" == "true" ]] && [[ "$in_block" == "false" ]] && echo "$line" | grep -q '```'; then
      in_block=true
      continue
    fi
    if [[ "$in_block" == "true" ]]; then
      if echo "$line" | grep -q '```'; then
        break
      fi
      if [[ -n "$content" ]]; then
        content="${content}
${line}"
      else
        content="${line}"
      fi
    fi
  done < "$task_file"

  echo "$content"
}

# ---------------------------------------------------------------------------
# Set up a clean project directory from a task file
# ---------------------------------------------------------------------------
setup_project() {
  local task_file="$1"
  local project_dir="$2"

  mkdir -p "$project_dir"

  # Extract and write package.json if present
  local pkg_json
  pkg_json=$(extract_setup_file "$task_file" "package.json")
  if [[ -n "$pkg_json" ]]; then
    echo "$pkg_json" > "$project_dir/package.json"
  fi

  # Extract and write tsconfig.json if present
  local tsconfig
  tsconfig=$(extract_setup_file "$task_file" "tsconfig.json")
  if [[ -n "$tsconfig" ]]; then
    echo "$tsconfig" > "$project_dir/tsconfig.json"
  fi

  # Extract and write any other setup files (requirements.txt, go.mod, etc.)
  for fname in "requirements.txt" "go.mod" "Makefile" "Dockerfile"; do
    local content
    content=$(extract_setup_file "$task_file" "$fname")
    if [[ -n "$content" ]]; then
      echo "$content" > "$project_dir/$fname"
    fi
  done

  echo "Project set up at: $project_dir"
}

# ---------------------------------------------------------------------------
# Run Claude Code on a project
# ---------------------------------------------------------------------------
run_claude() {
  local project_dir="$1"
  local prompt="$2"
  local use_plugin="$3"  # true | false

  echo "  Running Claude Code (plugin=$use_plugin)..."

  cd "$project_dir"

  # Install dependencies if package.json exists
  if [[ -f "package.json" ]]; then
    npm install --ignore-scripts 2>/dev/null || true
  fi

  if [[ "$use_plugin" == "true" ]]; then
    # Run with the plugin installed by pointing CLAUDE_CONFIG to include it
    # The plugin is installed by adding it to the project's .claude/settings.json
    mkdir -p "$project_dir/.claude"
    cat > "$project_dir/.claude/settings.json" <<SETTINGS
{
  "permissions": {
    "allow": ["Bash(*)", "Read(*)", "Write(*)", "Edit(*)"],
    "deny": []
  }
}
SETTINGS
    # Copy the plugin's CLAUDE.md (the main instructions file) so Claude picks it up
    if [[ -f "${PLUGIN_DIR}/CLAUDE.md" ]]; then
      cp "${PLUGIN_DIR}/CLAUDE.md" "$project_dir/CLAUDE.md"
    fi

    # Also make the skills available by symlinking the skills directory
    if [[ -d "${PLUGIN_DIR}/skills" ]]; then
      ln -sf "${PLUGIN_DIR}/skills" "$project_dir/.skills-ref"
    fi

    claude --print "$prompt" 2>&1 || true
  else
    # Run without any plugin -- clean environment
    # Ensure no CLAUDE.md is present
    rm -f "$project_dir/CLAUDE.md"
    rm -f "$project_dir/.skills-ref"

    mkdir -p "$project_dir/.claude"
    cat > "$project_dir/.claude/settings.json" <<SETTINGS
{
  "permissions": {
    "allow": ["Bash(*)", "Read(*)", "Write(*)", "Edit(*)"],
    "deny": []
  }
}
SETTINGS

    claude --print "$prompt" 2>&1 || true
  fi

  cd "$SCRIPT_DIR"
}

# ---------------------------------------------------------------------------
# Run a single task
# ---------------------------------------------------------------------------
run_task() {
  local task_num="$1"
  local mode="$2"

  # Zero-pad task number
  local padded
  padded=$(printf "%02d" "$task_num")

  # Find the task file
  local task_file
  task_file=$(find "$TASKS_DIR" -name "${padded}-*.md" -type f 2>/dev/null | head -1)

  if [[ -z "$task_file" ]] || [[ ! -f "$task_file" ]]; then
    echo "Warning: task file for task ${padded} not found in ${TASKS_DIR}, skipping." >&2
    return 1
  fi

  local task_name
  task_name=$(basename "$task_file" .md)
  echo "=============================================="
  echo "Task ${padded}: ${task_name}"
  echo "=============================================="

  # Extract the prompt
  local prompt
  prompt=$(extract_prompt "$task_file")
  if [[ -z "$prompt" ]]; then
    echo "Error: could not extract prompt from ${task_file}" >&2
    return 1
  fi

  echo "Prompt: ${prompt}"
  echo ""

  local run_with=false
  local run_without=false

  case "$mode" in
    with-plugin)    run_with=true ;;
    without-plugin) run_without=true ;;
    both)           run_with=true; run_without=true ;;
  esac

  # --- Run with plugin ---
  if [[ "$run_with" == "true" ]]; then
    echo "--- Running WITH plugin ---"
    local with_dir="${RESULTS_DIR}/${task_name}-with"
    rm -rf "$with_dir"
    setup_project "$task_file" "$with_dir"
    run_claude "$with_dir" "$prompt" "true"

    echo "  Scoring..."
    local with_score_file="${RESULTS_DIR}/${task_name}-with-score.json"
    bash "${SCORING_DIR}/automated-checks.sh" "$with_dir" > "$with_score_file" 2>/dev/null || true
    if [[ -f "$with_score_file" ]] && [[ -s "$with_score_file" ]]; then
      echo "  Score: $(jq -r '.total_points' "$with_score_file")/$(jq -r '.max_points' "$with_score_file") ($(jq -r '.grade' "$with_score_file"))"
    else
      echo "  Scoring failed -- see $with_score_file"
    fi
    echo ""
  fi

  # --- Run without plugin ---
  if [[ "$run_without" == "true" ]]; then
    echo "--- Running WITHOUT plugin ---"
    local without_dir="${RESULTS_DIR}/${task_name}-without"
    rm -rf "$without_dir"
    setup_project "$task_file" "$without_dir"
    run_claude "$without_dir" "$prompt" "false"

    echo "  Scoring..."
    local without_score_file="${RESULTS_DIR}/${task_name}-without-score.json"
    bash "${SCORING_DIR}/automated-checks.sh" "$without_dir" > "$without_score_file" 2>/dev/null || true
    if [[ -f "$without_score_file" ]] && [[ -s "$without_score_file" ]]; then
      echo "  Score: $(jq -r '.total_points' "$without_score_file")/$(jq -r '.max_points' "$without_score_file") ($(jq -r '.grade' "$without_score_file"))"
    else
      echo "  Scoring failed -- see $without_score_file"
    fi
    echo ""
  fi

  # --- Compare if both were run ---
  if [[ "$run_with" == "true" ]] && [[ "$run_without" == "true" ]]; then
    echo "--- Comparison ---"
    local with_total=0
    local without_total=0

    if [[ -f "${RESULTS_DIR}/${task_name}-with-score.json" ]]; then
      with_total=$(jq -r '.total_points' "${RESULTS_DIR}/${task_name}-with-score.json" 2>/dev/null || echo 0)
    fi
    if [[ -f "${RESULTS_DIR}/${task_name}-without-score.json" ]]; then
      without_total=$(jq -r '.total_points' "${RESULTS_DIR}/${task_name}-without-score.json" 2>/dev/null || echo 0)
    fi

    echo "  With plugin:    ${with_total} points"
    echo "  Without plugin: ${without_total} points"
    echo "  Difference:     $((with_total - without_total)) points"
    echo ""

    # Save combined result
    local scores_file="${RESULTS_DIR}/${task_name}-scores.json"
    cat > "$scores_file" <<SCORES
{
  "task": "${task_name}",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "with_plugin": {
    "score": ${with_total},
    "score_file": "${task_name}-with-score.json"
  },
  "without_plugin": {
    "score": ${without_total},
    "score_file": "${task_name}-without-score.json"
  },
  "difference": $((with_total - without_total)),
  "winner": "$( [[ $with_total -gt $without_total ]] && echo "with-plugin" || ([[ $with_total -lt $without_total ]] && echo "without-plugin" || echo "tie") )"
}
SCORES
    echo "  Combined scores saved to: $scores_file"

    # Run blind A/B comparison if the script exists
    if [[ -x "${SCRIPT_DIR}/compare-ab.sh" ]]; then
      echo ""
      echo "--- Running blind A/B comparison ---"
      bash "${SCRIPT_DIR}/compare-ab.sh" \
        "${RESULTS_DIR}/${task_name}-with" \
        "${RESULTS_DIR}/${task_name}-without" || true
    fi
  fi

  echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
mkdir -p "$RESULTS_DIR"

echo "Benchmark Runner"
echo "  Mode: ${MODE}"
echo "  Results: ${RESULTS_DIR}"
echo ""

if [[ "$RUN_ALL" == "true" ]]; then
  # Find all task files and run them
  task_count=0
  total_with=0
  total_without=0

  for task_file in "$TASKS_DIR"/*.md; do
    if [[ ! -f "$task_file" ]]; then
      continue
    fi
    # Extract task number from filename (e.g., 01-rest-api-crud.md -> 1)
    task_basename=$(basename "$task_file" .md)
    task_num=$(echo "$task_basename" | grep -oE '^[0-9]+' | sed 's/^0*//')
    if [[ -z "$task_num" ]]; then
      continue
    fi

    run_task "$task_num" "$MODE" || true
    task_count=$((task_count + 1))
  done

  echo "=============================================="
  echo "All tasks complete. ${task_count} task(s) evaluated."
  echo "Results in: ${RESULTS_DIR}/"
  echo "=============================================="

  # Print aggregate summary if both modes were run
  if [[ "$MODE" == "both" ]]; then
    echo ""
    echo "--- Aggregate Summary ---"
    for score_file in "$RESULTS_DIR"/*-scores.json; do
      if [[ -f "$score_file" ]]; then
        task=$(jq -r '.task' "$score_file" 2>/dev/null || echo "unknown")
        with=$(jq -r '.with_plugin.score' "$score_file" 2>/dev/null || echo "?")
        without=$(jq -r '.without_plugin.score' "$score_file" 2>/dev/null || echo "?")
        diff=$(jq -r '.difference' "$score_file" 2>/dev/null || echo "?")
        winner=$(jq -r '.winner' "$score_file" 2>/dev/null || echo "?")
        printf "  %-30s  with=%-3s  without=%-3s  diff=%-3s  winner=%s\n" \
          "$task" "$with" "$without" "$diff" "$winner"
      fi
    done
  fi

else
  run_task "$TASK_NUM" "$MODE"
fi
