#!/bin/bash

# Crypto Ralph1 Setup Script
# Creates state file for autonomous Phase 1-2 pipeline loop

set -euo pipefail

MAX_ITERATIONS=0
FOCUS=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Crypto Ralph1 - Autonomous Strategy Discovery Loop

USAGE:
  /crypto:ralph1 [OPTIONS] [FOCUS_AREA]

ARGUMENTS:
  FOCUS_AREA   Optional focus hint (e.g., "funding rate", "momentum", "mean reversion")
               If omitted, researcher decides based on gaps in registry.

OPTIONS:
  --max-iterations <n>   Maximum pipeline runs (default: unlimited)
  -h, --help             Show this help

DESCRIPTION:
  Runs the Phase 1-2 pipeline (Ideation → Quant → Data → Backtest → Critic → Risk)
  in a loop. Each iteration either validates a strategy or rejects it and
  extracts learnings. Loop continues until max iterations or context exhaustion.

  All results persist in .crypto/ — strategies, learnings, and registry survive
  across sessions.

EXAMPLES:
  /crypto:ralph1                                    # Auto-discover, unlimited
  /crypto:ralph1 --max-iterations 5                 # Stop after 5 strategies
  /crypto:ralph1 "funding rate arbitrage"            # Focus on funding rate
  /crypto:ralph1 --max-iterations 3 "momentum"       # 3 iterations, momentum focus

MONITORING:
  cat .crypto/ralph1-state.md                       # Current state
  cat .crypto/knowledge/registry.yaml               # All strategies
  cat .crypto/BOOTSTRAP.md                          # Portfolio overview
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations requires a positive integer" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    *)
      FOCUS="${FOCUS:+$FOCUS }$1"
      shift
      ;;
  esac
done

# Check workspace is initialized
if [[ ! -f ".crypto/BOOTSTRAP.md" ]]; then
  echo "Error: Trading workspace not initialized." >&2
  echo "Run /crypto:init first." >&2
  exit 1
fi

# Create state file
mkdir -p .crypto

FOCUS_LINE=""
if [[ -n "$FOCUS" ]]; then
  FOCUS_LINE="focus: \"$FOCUS\""
else
  FOCUS_LINE="focus: null"
fi

cat > .crypto/ralph1-state.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
strategies_found: 0
strategies_rejected: 0
$FOCUS_LINE
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

## Crypto Ralph1 — Autonomous Strategy Discovery

You are in an AUTONOMOUS LOOP running Phase 1-2 of the crypto trading pipeline.
Each iteration discovers and validates one strategy. Results persist in .crypto/.

### Your Task Each Iteration

1. **Bootstrap**: Read .crypto/BOOTSTRAP.md, .crypto/knowledge/registry.yaml, .crypto/knowledge/learnings.md, .crypto/config/thresholds.yaml
2. **Ideation**: Propose a NEW strategy (never repeat rejected ones). $(if [[ -n "$FOCUS" ]]; then echo "FOCUS AREA: $FOCUS."; else echo "Choose based on gaps in registry and learnings."; fi)
   - Write .crypto/knowledge/strategies/STR-{NNN}/hypothesis.md + parameters.yaml
3. **Quant Review**: Statistical feasibility check → quant-review.md. If NOT FEASIBLE → reject, extract learning, move to next.
4. **Data Check**: Verify data availability → data-spec.yaml. If unavailable → reject, extract learning, move to next.
5. **Backtest**: Run walk-forward backtest (70/30 IS/OOS). 4 robustness tests: parameter sensitivity, fee stress 2x, Monte Carlo, market regime.
   - Write backtest-results/BT-{NNN}.yaml
   - Check thresholds.yaml: hard_pass → proceed, hard_fail → reject, marginal → Critic.
6. **Critic Review**: Adversarial review → critic-review.md. REJECT → stop, CONDITIONAL → revise (max 3 cycles).
7. **Risk Assessment**: Portfolio fit check → risk-assessment.yaml. Limits exceeded → reject.
8. **Record**: Update registry.yaml, BOOTSTRAP.md, learnings.md with results.

### Rules
- NEVER fabricate backtest results. Run actual analysis.
- ALWAYS extract a learning from rejected strategies into learnings.md.
- ALWAYS update registry.yaml with the strategy outcome.
- ALWAYS increment next_id in registry counters.
- Each iteration = one complete strategy evaluation.

### End of Iteration
Report:
\`\`\`
Iteration N complete.
Strategy: STR-{NNN} {name}
Result: VALIDATED / REJECTED (reason)
Learning: {one-line takeaway}
Running total: {validated}/{rejected}/{total}
\`\`\`
EOF

# Output setup message
cat <<EOF
Crypto Ralph1 activated — autonomous strategy discovery loop.

Iteration: 1
Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
Focus: $(if [[ -n "$FOCUS" ]]; then echo "$FOCUS"; else echo "auto (based on registry gaps)"; fi)

Each iteration runs the full Phase 1-2 pipeline:
  Ideation → Quant → Data → Backtest → Critic → Risk

All results persist in .crypto/ and survive across sessions.

Starting first iteration...
EOF
