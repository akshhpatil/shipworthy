#!/usr/bin/env bash
# Shipworthy — Shared Hook Library
# Sourced by all hooks for common functionality.

# --- Robust JSON field extraction ---
# Uses jq > python3 > regex fallback chain
# Usage: parse_json_field "$INPUT" "field_name"
parse_json_field() {
  local input="$1"
  local field="$2"
  local result=""

  # Try jq first (handles all edge cases)
  if command -v jq &>/dev/null; then
    result=$(printf '%s' "$input" | jq -r --arg f "$field" '.tool_input[$f] // .[$f] // empty' 2>/dev/null || true)
    if [ -n "$result" ] && [ "$result" != "null" ]; then
      printf '%s' "$result"
      return
    fi
  fi

  # Try python3 (handles escaped quotes)
  if command -v python3 &>/dev/null; then
    result=$(printf '%s' "$input" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    v = d.get('tool_input', d).get('$field', '')
    print(v, end='')
except: pass
" 2>/dev/null || true)
    if [ -n "$result" ]; then
      printf '%s' "$result"
      return
    fi
  fi

  # Regex fallback (fails on escaped quotes but better than nothing)
  result=$(printf '%s' "$input" | grep -o "\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"//" | sed 's/"$//' 2>/dev/null || true)
  printf '%s' "$result"
}

# --- Robust JSON escaping ---
# Uses jq > python3 > awk fallback chain
escape_json() {
  local input="$1"

  # Try jq first
  if command -v jq &>/dev/null; then
    printf '%s' "$input" | jq -Rs '.[:-1]' 2>/dev/null | sed 's/^"//;s/"$//' && return
  fi

  # Try python3
  if command -v python3 &>/dev/null; then
    printf '%s' "$input" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1], end="")' 2>/dev/null && return
  fi

  # Portable awk fallback (works on macOS and Linux)
  printf '%s' "$input" | LC_ALL=C awk '
    BEGIN { ORS="" }
    {
      gsub(/\\/, "\\\\")
      gsub(/"/, "\\\"")
      gsub(/\t/, "\\t")
      gsub(/\r/, "\\r")
      if (NR > 1) print "\\n"
      print
    }
  ' | tr -d '\000'
}

# --- Debug logging ---
# Logs to ~/.shipworthy/debug.log when SHIPWORTHY_DEBUG=1
# Usage: debug_log "hook-name" "message"
SHIPWORTHY_LOG_DIR="${HOME}/.shipworthy"
SHIPWORTHY_LOG_FILE="${SHIPWORTHY_LOG_DIR}/debug.log"
SHIPWORTHY_LOG_MAX_SIZE=1048576  # 1MB

debug_log() {
  [ "${SHIPWORTHY_DEBUG:-0}" = "1" ] || return 0
  local hook_name="$1"
  local message="$2"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "unknown")

  # Create log dir if needed
  [ -d "$SHIPWORTHY_LOG_DIR" ] || mkdir -p "$SHIPWORTHY_LOG_DIR" 2>/dev/null || return 0

  # Rotate if over max size
  if [ -f "$SHIPWORTHY_LOG_FILE" ]; then
    local size
    size=$(wc -c < "$SHIPWORTHY_LOG_FILE" 2>/dev/null || echo "0")
    if [ "$size" -gt "$SHIPWORTHY_LOG_MAX_SIZE" ]; then
      mv "$SHIPWORTHY_LOG_FILE" "${SHIPWORTHY_LOG_FILE}.old" 2>/dev/null || true
    fi
  fi

  printf '[%s] [%s] %s\n' "$timestamp" "$hook_name" "$message" >> "$SHIPWORTHY_LOG_FILE" 2>/dev/null || true
}

# --- Read project config overrides ---
# Returns value from .shipworthy/config.json, empty string if not found
# Usage: read_config "overrides.allow_console_log" "$PROJECT_ROOT"
read_config() {
  local key_path="$1"
  local project_root="${2:-.}"
  local config_file="$project_root/.shipworthy/config.json"

  [ -f "$config_file" ] || return 0

  if command -v jq &>/dev/null; then
    jq -r ".$key_path // empty" "$config_file" 2>/dev/null || true
  elif command -v python3 &>/dev/null; then
    python3 -c "
import json, functools
try:
    d = json.load(open('$config_file'))
    keys = '$key_path'.split('.')
    v = functools.reduce(lambda a,k: a[k], keys, d)
    print(v if v is not None else '', end='')
except: pass
" 2>/dev/null || true
  fi
}

# --- Check if path should be ignored ---
# Usage: is_ignored_path "$FILE_PATH" "$PROJECT_ROOT"
is_ignored_path() {
  local file_path="$1"
  local project_root="${2:-.}"
  local config_file="$project_root/.shipworthy/config.json"

  [ -f "$config_file" ] || return 1  # not ignored

  local relative_path="${file_path#$project_root/}"

  if command -v jq &>/dev/null; then
    local ignored
    ignored=$(jq -r '.ignore_paths[]? // empty' "$config_file" 2>/dev/null || true)
    while IFS= read -r pattern; do
      [ -z "$pattern" ] && continue
      case "$relative_path" in
        $pattern*) return 0 ;;  # ignored
      esac
    done <<< "$ignored"
  fi

  return 1  # not ignored
}
