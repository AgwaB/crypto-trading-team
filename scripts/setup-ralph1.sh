#!/bin/bash

# Crypto Ralph1 Setup Script
# Creates state file for autonomous Phase 0-2 pipeline loop with tiered validation

set -euo pipefail

MAX_ITERATIONS=0
FOCUS=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Crypto Ralph1 - Autonomous Strategy Discovery Loop (v0.6.0)

USAGE:
  /crypto:ralph1 [OPTIONS] [FOCUS_AREA]

ARGUMENTS:
  FOCUS_AREA   Optional focus hint (e.g., "funding rate", "momentum", "altcoin")
               If omitted, strategy meeting decides based on gaps in registry.

OPTIONS:
  --max-iterations <n>   Maximum pipeline runs (default: unlimited)
  -h, --help             Show this help

DESCRIPTION:
  Runs the enhanced Phase 0-2 pipeline in a loop:
    Strategy Meeting (Senior + Maverick + DataCurious)
    -> Insight Agent (dedup) -> Feedback Agent (learning injection)
    -> L0 (30s) -> L1 (5min) -> L2 (30min) -> Critic -> L3 (60min) -> Risk

  Each iteration either validates a strategy or rejects it and extracts
  learnings. Multiple ideas per meeting: if Idea A fails at L0, try Idea B
  before running a new meeting.

  All results persist in .crypto/ — strategies, learnings, and registry
  survive across sessions.

EXAMPLES:
  /crypto:ralph1                                    # Auto-discover, unlimited
  /crypto:ralph1 --max-iterations 5                 # Stop after 5 strategies
  /crypto:ralph1 "funding rate arbitrage"            # Focus on funding rate
  /crypto:ralph1 --max-iterations 3 "volatility"     # 3 iterations, vol focus

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
meetings_held: 0
l0_rejections: 0
l1_rejections: 0
l2_rejections: 0
$FOCUS_LINE
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

## Crypto Ralph1 — Autonomous Strategy Discovery (v0.6.0)

You are in an AUTONOMOUS LOOP running Phase 0-2 of the crypto trading pipeline.
Each iteration discovers and validates strategies using tiered validation and creative junior agents.
Results persist in .crypto/.

### Your Task Each Iteration

#### Phase 0: Pre-Pipeline (Ideation + Screening)

1. **Bootstrap**: Read .crypto/BOOTSTRAP.md, .crypto/knowledge/registry.yaml, .crypto/knowledge/learnings.md, .crypto/config/thresholds.yaml, .crypto/config/tiered-validation-protocol.yaml

2. **Strategy Meeting** (spawn 3 agents in parallel):
   - \`trading-strategy-researcher\` (senior): 2-3 hypotheses based on registry gaps. $(if [[ -n "$FOCUS" ]]; then echo "FOCUS: $FOCUS."; else echo "Choose based on gaps in registry and search-space-map.yaml."; fi)
   - \`trading-junior-maverick\` (contrarian, temp 0.95): 2+ wild ideas from cross-domain analogies
   - \`trading-junior-datacurious\` (data hunter, temp 0.8): anomalies + derived features
   - Collect all proposals (expect 6-10 total)

3. **Insight Agent** (\`trading-insight\`):
   - Deduplicate all proposals against registry
   - Verdict: DUPLICATE / SIMILAR / NOVEL
   - Select top 3 NOVEL ideas by novelty score

4. **Feedback Agent** (\`trading-feedback\`):
   - Pre-flight check for top idea: match keywords to L-XXX learnings
   - CRITICAL / WARNING / INFO injection report
   - BLOCK if unaddressed CRITICAL learnings -> try next idea

5. **Formalize**: Write .crypto/knowledge/strategies/STR-{NNN}/hypothesis.md + parameters.yaml

#### Phase 1: Quant + Data

6. **Quant Review** (\`trading-quant-analyst\`): feasibility check -> quant-review.md. NOT FEASIBLE -> reject, try next idea.
7. **Data Check** (\`trading-data-collector\`): data availability -> data-spec.yaml. Unavailable -> reject, try next idea.

#### Phase 2: Tiered Validation

8. **L0** (30s): 6mo, 1 asset. Gate: frequency>10, hit_rate!=50%, IC>0.01. FAIL -> reject, try next idea.
9. **L1** (5min): 1yr, primary. Gate: Sharpe>0.5, PF>1.0, trades>30. FAIL -> reject.
10. **L2** (30min): 3yr, full sweep. Self-diagnostics. Gate: thresholds.yaml. Marginal -> Critic.
11. **Critic** (\`trading-critic\`): adversarial review. REJECT -> stop. CONDITIONAL -> max 3 cycles.
12. **L3** (60min): 5yr, WF (3/5 windows) + MC (95% CI+) + regime (2/3). FAIL -> reject.
13. **Risk** (\`trading-risk-manager\`): alpha_corr < 0.7 with portfolio. Exceeded -> reject.

#### Record & Loop

14. Update registry.yaml, BOOTSTRAP.md, learnings.md, failure-taxonomy.yaml, search-space-map.yaml
15. If ideas remain from meeting -> try next idea (back to step 4)
16. If all ideas exhausted -> run new meeting (back to step 2)

### Rules
- NEVER fabricate backtest results. Run actual analysis.
- ALWAYS extract a learning from rejected strategies.
- ALWAYS try all meeting ideas before running a new meeting.
- L0 rejection = fast fail. Don't spend 30 min on what fails in 30 sec.
- ALWAYS increment next_id in registry counters.

### End of Iteration Report
\`\`\`
Iteration N complete.
Strategy: STR-{NNN} {name}
Result: VALIDATED / REJECTED (tier: L0/L1/L2/L3/Critic/Risk, reason)
Meeting ideas used: X/Y (remaining: Z)
Learning: {one-line takeaway}
Running total: {validated}/{rejected}/{total}
Compute saved: {hours saved by L0/L1 early rejection}
\`\`\`
EOF

# Output setup message with session marker (hook checks for this)
cat <<EOF
<!-- RALPH1-SESSION-ACTIVE -->
Crypto Ralph1 activated — autonomous strategy discovery loop (v0.6.0).

Iteration: 1
Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
Focus: $(if [[ -n "$FOCUS" ]]; then echo "$FOCUS"; else echo "auto (strategy meeting decides)"; fi)

Enhanced pipeline per iteration:
  Meeting (Senior + Maverick + DataCurious)
  -> Insight (dedup) -> Feedback (learning injection)
  -> L0 (30s) -> L1 (5min) -> L2 (30min) -> Critic -> L3 (60min) -> Risk

Multi-idea efficiency: 3 ideas per meeting, try all before next meeting.
All results persist in .crypto/ and survive across sessions.

Starting first iteration...
EOF
