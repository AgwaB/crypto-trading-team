#!/bin/bash

# Crypto Ralph1 Stop Hook
# Intercepts session exit when ralph1 loop is active
# Feeds pipeline prompt back to continue autonomous strategy discovery

set -euo pipefail

HOOK_INPUT=$(cat)

STATE_FILE=".crypto/ralph1-state.md"

if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
STRATEGIES_FOUND=$(echo "$FRONTMATTER" | grep '^strategies_found:' | sed 's/strategies_found: *//')
STRATEGIES_REJECTED=$(echo "$FRONTMATTER" | grep '^strategies_rejected:' | sed 's/strategies_rejected: *//')

# Validate
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]] || [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Ralph1: State file corrupted. Loop stopping." >&2
  rm "$STATE_FILE"
  exit 0
fi

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  TOTAL=$((STRATEGIES_FOUND + STRATEGIES_REJECTED))
  echo ""
  echo "Ralph1 complete: $MAX_ITERATIONS iterations reached."
  echo "Results: $STRATEGIES_FOUND validated / $STRATEGIES_REJECTED rejected / $TOTAL total"
  echo "See .crypto/knowledge/registry.yaml for all strategies."
  rm "$STATE_FILE"
  exit 0
fi

# Read transcript to update counters from last iteration output
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ -f "$TRANSCRIPT_PATH" ]]; then
  LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
  if [[ -n "$LAST_LINE" ]]; then
    LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
      .message.content |
      map(select(.type == "text")) |
      map(.text) |
      join("\n")
    ' 2>/dev/null || echo "")

    # Count validated/rejected from output
    if echo "$LAST_OUTPUT" | grep -qi "Result:.*VALIDATED" 2>/dev/null; then
      STRATEGIES_FOUND=$((STRATEGIES_FOUND + 1))
    elif echo "$LAST_OUTPUT" | grep -qi "Result:.*REJECTED" 2>/dev/null; then
      STRATEGIES_REJECTED=$((STRATEGIES_REJECTED + 1))
    fi
  fi
fi

# Increment iteration
NEXT_ITERATION=$((ITERATION + 1))

# Extract prompt (everything after closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Ralph1: State file corrupted. Loop stopping." >&2
  rm "$STATE_FILE"
  exit 0
fi

# Update state file
TEMP_FILE="${STATE_FILE}.tmp.$$"
sed \
  -e "s/^iteration: .*/iteration: $NEXT_ITERATION/" \
  -e "s/^strategies_found: .*/strategies_found: $STRATEGIES_FOUND/" \
  -e "s/^strategies_rejected: .*/strategies_rejected: $STRATEGIES_REJECTED/" \
  "$STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$STATE_FILE"

TOTAL=$((STRATEGIES_FOUND + STRATEGIES_REJECTED))
SYSTEM_MSG="Ralph1 iteration $NEXT_ITERATION | Found: $STRATEGIES_FOUND | Rejected: $STRATEGIES_REJECTED | Total: $TOTAL$(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo " / $MAX_ITERATIONS max"; fi)"

jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
