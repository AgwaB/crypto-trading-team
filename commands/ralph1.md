---
description: "Autonomous strategy discovery loop with tiered validation (Phase 0-2). Use --never-end for 24/7 mode."
argument-hint: "[--never-end] [--max-iterations N] [FOCUS_AREA]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph1.sh:*)"]
---

# Crypto Ralph1 — Autonomous Strategy Discovery

Execute the setup script to initialize the ralph1 loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph1.sh" $ARGUMENTS
```

You are now in an autonomous strategy discovery loop. Each iteration runs the full Phase 0-2 pipeline with tiered validation to find and validate trading strategies.

## Important

- Read `.crypto/BOOTSTRAP.md` and `.crypto/knowledge/registry.yaml` FIRST to know current state.
- Read `.crypto/knowledge/learnings.md` to avoid repeating past mistakes.
- Read `.crypto/config/tiered-validation-protocol.yaml` to understand L0-L3 gates.
- NEVER propose a strategy that was already rejected (check registry).
- NEVER fabricate backtest results. Run actual quantitative analysis.
- ALWAYS update registry, BOOTSTRAP.md, and learnings.md after each iteration.
- Each iteration = one complete strategy evaluation (validated or rejected).

## Pipeline Per Iteration

### Phase 0: Pre-Pipeline (Ideation + Screening)

1. **Strategy Meeting** (parallel agents):
   - Spawn `trading-strategy-researcher` (senior, temp 0.5): 2-3 hypotheses based on registry gaps
   - Spawn `trading-junior-maverick` (contrarian, temp 0.95): 2+ wild ideas from cross-domain analogies
   - Spawn `trading-junior-datacurious` (data hunter, temp 0.8): anomalies + derived features
   - If FOCUS_AREA provided, all agents focus on that area
   - Collect all proposals

2. **Insight Agent** (`trading-insight`):
   - Deduplicate all proposals against registry (58+ strategies)
   - Check search-space-map.yaml for already-tested archetypes
   - Verdict: DUPLICATE (reject) / SIMILAR (needs twist) / NOVEL (proceed)
   - Select top 1-3 NOVEL ideas by novelty score

3. **Feedback Agent** (`trading-feedback`):
   - Pre-flight check: match keywords to relevant L-XXX learnings
   - Generate injection report: CRITICAL / WARNING / INFO
   - BLOCK if unaddressed CRITICAL learnings
   - Inject relevant learnings into downstream agent prompts

4. **Hypothesis Formalization**:
   - Write `.crypto/knowledge/strategies/STR-{NNN}/hypothesis.md` + `parameters.yaml`
   - Include Feedback Agent's mandatory context

### Phase 1: Quant + Data

5. **Quant Review** (`trading-quant-analyst`):
   - Statistical feasibility check with injected learnings
   - Output: `quant-review.md`
   - If NOT FEASIBLE -> reject, extract learning, try next idea from meeting

6. **Data Check** (`trading-data-collector`):
   - Verify data availability
   - Output: `data-spec.yaml`
   - If unavailable -> reject, extract learning, try next idea

### Phase 2: Tiered Validation

7. **L0: Sanity Check** (30 seconds):
   - 6 months, 1 asset, default parameters
   - Gate: signal frequency > 10, hit_rate != 50%, IC > 0.01
   - FAIL -> reject immediately, try next idea from meeting (saves 30+ min)

8. **L1: Quick Validation** (5 minutes):
   - 1 year, primary asset, default + 2 variants
   - Gate: Sharpe > 0.5, PF > 1.0, trades > 30
   - FAIL -> reject, extract learning

9. **L2: Full Backtest** (30 minutes):
   - 3 years, full universe, parameter sweep
   - 4 robustness tests: parameter sensitivity, fee stress 2x, Monte Carlo, regime
   - Run self-diagnostic catalog checks (`.crypto/config/self-diagnostic-catalog.yaml`)
   - Gate: `.crypto/config/thresholds.yaml` or `.crypto/config/portfolio-thresholds.yaml`
   - hard_fail -> reject, marginal -> route to Critic

10. **Critic Review** (`trading-critic`):
    - Adversarial review with failure taxonomy context
    - Output: `critic-review.md`
    - REJECT -> stop, CONDITIONAL -> max 3 revision cycles

11. **L3: Extended Validation** (60 minutes):
    - 5 years, walk-forward (5 windows, 3 must profit) + Monte Carlo (1000 sims, 95% CI+) + regime (bull/bear/sideways, 2/3 must profit)
    - FAIL -> reject with detailed analysis

12. **Risk Assessment** (`trading-risk-manager`):
    - Portfolio fit: alpha_corr < 0.7 with existing portfolio
    - Output: `risk-assessment.yaml`
    - Limits exceeded -> reject

### Record & Loop

13. **Record Results**:
    - Update `.crypto/knowledge/registry.yaml` with outcome
    - Update `.crypto/BOOTSTRAP.md` with current state
    - Extract learnings via Feedback Agent -> `.crypto/knowledge/learnings.md`
    - Update `.crypto/knowledge/failure-taxonomy.yaml` with root cause (if rejected)
    - Update `.crypto/knowledge/search-space-map.yaml` with tested area

14. **Loop Decision**:
    - If strategy VALIDATED: record and continue to next iteration
    - If ALL meeting ideas rejected at L0: run new meeting immediately
    - If some ideas remain from meeting: try next idea (skip back to step 3)

## Efficiency: Multi-Idea Per Meeting

Each meeting generates 6-10 ideas. The Insight Agent selects top 3 NOVEL ones. If the first idea fails at L0/L1, try the 2nd and 3rd BEFORE running a new meeting. This saves meeting overhead.

```
Meeting -> [Idea A, Idea B, Idea C]
  Idea A -> L0 FAIL -> try Idea B
  Idea B -> L0 PASS -> L1 PASS -> L2 FAIL -> try Idea C
  Idea C -> L0 PASS -> L1 PASS -> L2 PASS -> Critic -> L3 -> Risk -> VALIDATED!
  -> Run new Meeting for next iteration
```

## End of Iteration Report

```
Iteration N complete.
Strategy: STR-{NNN} {name}
Result: VALIDATED / REJECTED (tier: L0/L1/L2/L3/Critic/Risk, reason)
Meeting ideas used: X/Y (remaining: Z)
Learning: {one-line takeaway}
Running total: {validated}/{rejected}/{total}
Compute saved: {hours saved by L0/L1 early rejection}
```

## Ending the Loop

If you determine there are no more viable strategies to explore (all data exhausted, all approaches tested, search space map fully covered), output `<ralph1-complete>` and the loop will cleanly terminate with a summary. Do NOT just stop — always use the tag so the state file is properly cleaned up.
