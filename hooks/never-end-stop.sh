#!/bin/bash

# Crypto Never-End Stop Hook
# Intercepts session exit ONLY when never-end loop is active in THIS session
# Feeds pipeline prompt back to continue 24/7 autonomous strategy discovery

set -uo pipefail

HOOK_INPUT=$(cat)

STATE_FILE=".crypto/never-end-state.md"

# No state file → not a never-end session
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Check if THIS session is actually a never-end session
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path' 2>/dev/null || echo "")

if [[ -z "$TRANSCRIPT_PATH" ]] || [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

# Look for never-end marker in transcript
if ! grep -q 'NEVER-END-SESSION-ACTIVE' "$TRANSCRIPT_PATH" 2>/dev/null; then
  # This session was NOT started by never-end — allow exit
  exit 0
fi

# Check if Claude voluntarily ended the loop
LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1 || true)
if [[ -n "$LAST_LINE" ]]; then
  LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
    .message.content |
    map(select(.type == "text")) |
    map(.text) |
    join("\n")
  ' 2>/dev/null || echo "")

  # Detect voluntary completion signals
  if echo "$LAST_OUTPUT" | grep -qiE '<never-end-complete>' 2>/dev/null; then
    echo "Never-End: Loop completed — Claude determined no further strategies available." >&2

    # Parse counters for final report
    FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE") || true
    STRATEGIES_FOUND=$(echo "$FRONTMATTER" | grep '^strategies_found:' | sed 's/strategies_found: *//' || echo "0")
    STRATEGIES_REJECTED=$(echo "$FRONTMATTER" | grep '^strategies_rejected:' | sed 's/strategies_rejected: *//' || echo "0")
    SCOUT_RUNS=$(echo "$FRONTMATTER" | grep '^scout_runs:' | sed 's/scout_runs: *//' || echo "0")
    MUTATOR_RUNS=$(echo "$FRONTMATTER" | grep '^mutator_runs:' | sed 's/mutator_runs: *//' || echo "0")
    TOTAL=$((STRATEGIES_FOUND + STRATEGIES_REJECTED))

    echo "" >&2
    echo "=== Final Results ===" >&2
    echo "Strategies: $STRATEGIES_FOUND validated / $STRATEGIES_REJECTED rejected / $TOTAL total" >&2
    echo "Expansion: $SCOUT_RUNS scout runs / $MUTATOR_RUNS mutator runs" >&2

    rm -f "$STATE_FILE"
    exit 0
  fi
fi

# Parse frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE") || true
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' || echo "0")
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//' || echo "0")
STRATEGIES_FOUND=$(echo "$FRONTMATTER" | grep '^strategies_found:' | sed 's/strategies_found: *//' || echo "0")
STRATEGIES_REJECTED=$(echo "$FRONTMATTER" | grep '^strategies_rejected:' | sed 's/strategies_rejected: *//' || echo "0")
SCOUT_RUNS=$(echo "$FRONTMATTER" | grep '^scout_runs:' | sed 's/scout_runs: *//' || echo "0")
MUTATOR_RUNS=$(echo "$FRONTMATTER" | grep '^mutator_runs:' | sed 's/mutator_runs: *//' || echo "0")

# Validate
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]] || [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Never-End: State file corrupted. Loop stopping." >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Check max iterations (0 = unlimited)
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  TOTAL=$((STRATEGIES_FOUND + STRATEGIES_REJECTED))
  echo "" >&2
  echo "Never-End complete: $MAX_ITERATIONS iterations reached." >&2
  echo "Results: $STRATEGIES_FOUND validated / $STRATEGIES_REJECTED rejected / $TOTAL total" >&2
  echo "Expansion: $SCOUT_RUNS scout runs / $MUTATOR_RUNS mutator runs" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Update counters from last output
if [[ -n "${LAST_OUTPUT:-}" ]]; then
  if echo "$LAST_OUTPUT" | grep -qi "Result:.*VALIDATED" 2>/dev/null; then
    STRATEGIES_FOUND=$((STRATEGIES_FOUND + 1))
  elif echo "$LAST_OUTPUT" | grep -qi "Result:.*REJECTED" 2>/dev/null; then
    STRATEGIES_REJECTED=$((STRATEGIES_REJECTED + 1))
  fi

  # Track scout/mutator runs
  if echo "$LAST_OUTPUT" | grep -qi "trading-external-scout" 2>/dev/null; then
    SCOUT_RUNS=$((SCOUT_RUNS + 1))
  fi
  if echo "$LAST_OUTPUT" | grep -qi "trading-strategy-mutator" 2>/dev/null; then
    MUTATOR_RUNS=$((MUTATOR_RUNS + 1))
  fi
fi

# Increment iteration
NEXT_ITERATION=$((ITERATION + 1))

# Build continuation prompt
PROMPT_TEXT="Continue the 24/7 autonomous strategy discovery loop.

Current state:
- Iteration: $NEXT_ITERATION
- Strategies found: $STRATEGIES_FOUND
- Strategies rejected: $STRATEGIES_REJECTED
- Scout runs: $SCOUT_RUNS
- Mutator runs: $MUTATOR_RUNS

Instructions:
1. Read .crypto/BOOTSTRAP.md for current state
2. Check .crypto/knowledge/registry.yaml for recent results
3. Run the next iteration of the pipeline (Phase 0-2)
4. If meeting produces no NOVEL ideas, run External Scout and Strategy Mutator
5. Report results at end of iteration

Remember: This loop NEVER stops on its own. Keep discovering strategies until manually stopped or you output <never-end-complete>."

# Update state file
TEMP_FILE="${STATE_FILE}.tmp.$$"
cat > "$TEMP_FILE" << EOF
---
iteration: $NEXT_ITERATION
max_iterations: $MAX_ITERATIONS
strategies_found: $STRATEGIES_FOUND
strategies_rejected: $STRATEGIES_REJECTED
scout_runs: $SCOUT_RUNS
mutator_runs: $MUTATOR_RUNS
started: $(echo "$FRONTMATTER" | grep '^started:' | sed 's/started: *//' || date -Iseconds)
---

$PROMPT_TEXT
EOF
mv "$TEMP_FILE" "$STATE_FILE"

TOTAL=$((STRATEGIES_FOUND + STRATEGIES_REJECTED))
SYSTEM_MSG="Never-End iteration $NEXT_ITERATION | Found: $STRATEGIES_FOUND | Rejected: $STRATEGIES_REJECTED | Total: $TOTAL | Scout: $SCOUT_RUNS | Mutator: $MUTATOR_RUNS$(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo " | Max: $MAX_ITERATIONS"; fi)"

# Output ONLY the JSON to stdout
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
