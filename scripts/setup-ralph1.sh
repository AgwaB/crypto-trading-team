#!/bin/bash

# Crypto Ralph1 Setup Script
# Creates state file for autonomous Phase 0-2 pipeline loop with tiered validation
# v0.7.0: Added --never-end mode with external scout + mutator on exhaustion

set -euo pipefail

MAX_ITERATIONS=0
FOCUS=""
NEVER_END=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Crypto Ralph1 - Autonomous Strategy Discovery Loop (v0.7.0)

USAGE:
  /crypto:ralph1 [OPTIONS] [FOCUS_AREA]

ARGUMENTS:
  FOCUS_AREA   Optional focus hint (e.g., "funding rate", "momentum", "altcoin")
               If omitted, strategy meeting decides based on gaps in registry.

OPTIONS:
  --max-iterations <n>   Maximum pipeline runs (default: unlimited)
  --never-end            24/7 mode: on exhaustion, run External Scout + Mutator
                         to expand search space, then continue (default: off)
  -h, --help             Show this help

DESCRIPTION:
  Runs the enhanced Phase 0-2 pipeline in a loop:
    Strategy Meeting (Senior + Maverick + DataCurious)
    -> Insight Agent (dedup) -> Feedback Agent (learning injection)
    -> L0 (30s) -> L1 (5min) -> L2 (30min) -> Critic -> L3 (60min) -> Risk

  Each iteration either validates a strategy or rejects it and extracts
  learnings. Multiple ideas per meeting: if Idea A fails at L0, try Idea B
  before running a new meeting.

  --never-end MODE (24/7 Operation):
  When internal ideas are exhausted, instead of stopping:
    1. Run External Scout (arxiv, twitter, onchain, exchanges)
    2. Run Strategy Mutator (transform existing strategies)
    3. Add new signals/mutations to search space
    4. Continue loop with expanded idea pool

  This enables truly continuous operation until --max-iterations or manual stop.

EXAMPLES:
  /crypto:ralph1                                    # Auto-discover, stops on exhaustion
  /crypto:ralph1 --never-end                        # 24/7 mode, never stops
  /crypto:ralph1 --never-end --max-iterations 100   # 24/7 but cap at 100
  /crypto:ralph1 --max-iterations 5                 # Stop after 5 strategies
  /crypto:ralph1 "funding rate arbitrage"            # Focus on funding rate

MONITORING:
  cat .crypto/ralph1-state.md                       # Current state
  cat .crypto/knowledge/registry.yaml               # All strategies
  cat .crypto/knowledge/external-signals.yaml       # External scout findings
  cat .crypto/knowledge/mutations/                  # Strategy mutations
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
    --never-end)
      NEVER_END=true
      shift
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

# Create directories
mkdir -p .crypto
mkdir -p .crypto/knowledge/mutations
mkdir -p .crypto/scripts/collectors

FOCUS_LINE=""
if [[ -n "$FOCUS" ]]; then
  FOCUS_LINE="focus: \"$FOCUS\""
else
  FOCUS_LINE="focus: null"
fi

NEVER_END_LINE="never_end: $NEVER_END"

cat > .crypto/ralph1-state.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
$NEVER_END_LINE
strategies_found: 0
strategies_rejected: 0
meetings_held: 0
scout_runs: 0
mutator_runs: 0
l0_rejections: 0
l1_rejections: 0
l2_rejections: 0
$FOCUS_LINE
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

## Crypto Ralph1 — Autonomous Strategy Discovery (v0.7.0)

You are in an AUTONOMOUS LOOP running Phase 0-2 of the crypto trading pipeline.
Each iteration discovers and validates strategies using tiered validation and creative junior agents.
Results persist in .crypto/.

$(if [[ "$NEVER_END" == "true" ]]; then
cat << 'NEVEREND'
### 24/7 MODE ACTIVE

When you exhaust internal ideas, DO NOT output <ralph1-complete>.
Instead, run the EXPANSION PROTOCOL:

1. **External Scout** (\`trading-external-scout\`):
   - Search arxiv for new papers
   - Check crypto twitter trends
   - Scan on-chain anomalies
   - Monitor exchange updates
   - Output: .crypto/knowledge/external-signals.yaml
   - If API keys needed, request from user and WAIT

2. **Strategy Mutator** (\`trading-strategy-mutator\`):
   - Read all strategies from registry
   - Apply mutation operators (parameter shift, asset swap, etc.)
   - Generate 5-10 new hypotheses from existing strategies
   - Output: .crypto/knowledge/mutations/MUT-{NNN}.yaml

3. **Incorporate & Continue**:
   - Add external signals to next Strategy Meeting agenda
   - Add top mutations to idea pool
   - Resume normal loop with expanded search space

Only output <ralph1-complete> if:
- External Scout finds nothing new AND
- Mutator generates no viable mutations AND
- This has happened 3 times consecutively

NEVEREND
fi)

### Your Task Each Iteration

#### Phase 0: Pre-Pipeline (Ideation + Screening)

1. **Bootstrap**: Read .crypto/BOOTSTRAP.md, .crypto/knowledge/registry.yaml, .crypto/knowledge/learnings.md, .crypto/config/thresholds.yaml, .crypto/config/tiered-validation-protocol.yaml

2. **Check External Signals**: Read .crypto/knowledge/external-signals.yaml for pending signals from Scout

3. **Check Mutations**: Read .crypto/knowledge/mutations/ for pending mutations

4. **Strategy Meeting** (spawn 3 agents in parallel):
   - \`trading-strategy-researcher\` (senior): 2-3 hypotheses based on registry gaps. $(if [[ -n "$FOCUS" ]]; then echo "FOCUS: $FOCUS."; else echo "Choose based on gaps in registry and search-space-map.yaml."; fi)
   - \`trading-junior-maverick\` (contrarian, temp 0.95): 2+ wild ideas from cross-domain analogies
   - \`trading-junior-datacurious\` (data hunter, temp 0.8): anomalies + derived features
   - Include any pending external signals and mutations in the agenda
   - Collect all proposals (expect 6-10 total)

5. **Insight Agent** (\`trading-insight\`):
   - Deduplicate all proposals against registry
   - Verdict: DUPLICATE / SIMILAR / NOVEL
   - Select top 3 NOVEL ideas by novelty score

6. **Feedback Agent** (\`trading-feedback\`):
   - Pre-flight check for top idea: match keywords to L-XXX learnings
   - CRITICAL / WARNING / INFO injection report
   - BLOCK if unaddressed CRITICAL learnings -> try next idea

7. **Formalize**: Write .crypto/knowledge/strategies/STR-{NNN}/hypothesis.md + parameters.yaml

#### Phase 1: Quant + Data

8. **Quant Review** (\`trading-quant-analyst\`): feasibility check -> quant-review.md. NOT FEASIBLE -> reject, try next idea.
9. **Data Check** (\`trading-data-collector\`): data availability -> data-spec.yaml. Unavailable -> reject, try next idea.

#### Phase 2: Tiered Validation

10. **L0** (30s): 6mo, 1 asset. Gate: frequency>10, hit_rate!=50%, IC>0.01. FAIL -> reject, try next idea.
11. **L1** (5min): 1yr, primary. Gate: Sharpe>0.5, PF>1.0, trades>30. FAIL -> reject.
12. **L2** (30min): 3yr, full sweep. Self-diagnostics. Gate: thresholds.yaml. Marginal -> Critic.
13. **Critic** (\`trading-critic\`): adversarial review. REJECT -> stop. CONDITIONAL -> max 3 cycles.
14. **L3** (60min): 5yr, WF (3/5 windows) + MC (95% CI+) + regime (2/3). FAIL -> reject.
15. **Risk** (\`trading-risk-manager\`): alpha_corr < 0.7 with portfolio. Exceeded -> reject.

#### Record & Loop

16. Update registry.yaml, BOOTSTRAP.md, learnings.md, failure-taxonomy.yaml, search-space-map.yaml
17. If ideas remain from meeting -> try next idea (back to step 6)
18. If all ideas exhausted:
$(if [[ "$NEVER_END" == "true" ]]; then
    echo "    - Run EXPANSION PROTOCOL (External Scout + Mutator)"
    echo "    - Then run new meeting with expanded ideas (back to step 2)"
else
    echo "    - Run new meeting (back to step 4)"
    echo "    - If meetings produce no novel ideas 3x in a row -> <ralph1-complete>"
fi)

### Rules
- NEVER fabricate backtest results. Run actual analysis.
- ALWAYS extract a learning from rejected strategies.
- ALWAYS try all meeting ideas before running a new meeting.
- L0 rejection = fast fail. Don't spend 30 min on what fails in 30 sec.
- ALWAYS increment next_id in registry counters.
$(if [[ "$NEVER_END" == "true" ]]; then
    echo "- In 24/7 mode: run External Scout + Mutator before giving up"
    echo "- Request API keys when needed for external data collection"
fi)

### End of Iteration Report
\`\`\`
Iteration N complete.
Strategy: STR-{NNN} {name}
Result: VALIDATED / REJECTED (tier: L0/L1/L2/L3/Critic/Risk, reason)
Meeting ideas used: X/Y (remaining: Z)
Learning: {one-line takeaway}
Running total: {validated}/{rejected}/{total}
$(if [[ "$NEVER_END" == "true" ]]; then
    echo "Scout runs: N | Mutator runs: N"
fi)
Compute saved: {hours saved by L0/L1 early rejection}
\`\`\`
EOF

# Output setup message with session marker (hook checks for this)
cat <<EOF
<!-- RALPH1-SESSION-ACTIVE -->
Crypto Ralph1 activated — autonomous strategy discovery loop (v0.7.0).

Iteration: 1
Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
24/7 Mode: $(if [[ "$NEVER_END" == "true" ]]; then echo "ON (External Scout + Mutator on exhaustion)"; else echo "OFF (stops on exhaustion)"; fi)
Focus: $(if [[ -n "$FOCUS" ]]; then echo "$FOCUS"; else echo "auto (strategy meeting decides)"; fi)

Enhanced pipeline per iteration:
  Meeting (Senior + Maverick + DataCurious)
  -> Insight (dedup) -> Feedback (learning injection)
  -> L0 (30s) -> L1 (5min) -> L2 (30min) -> Critic -> L3 (60min) -> Risk
$(if [[ "$NEVER_END" == "true" ]]; then
cat << 'MSG24'

24/7 Expansion Protocol (on exhaustion):
  -> External Scout (arxiv, twitter, onchain, exchanges)
  -> Strategy Mutator (transform existing strategies)
  -> Resume with expanded search space
MSG24
fi)

Multi-idea efficiency: 3 ideas per meeting, try all before next meeting.
All results persist in .crypto/ and survive across sessions.

Starting first iteration...
EOF
