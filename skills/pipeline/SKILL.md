---
name: trading-pipeline
description: "Run the full autonomous strategy development pipeline. Use when the user says 'new strategy', 'run pipeline', 'start pipeline', or 'develop strategy'. Orchestrates all agents through Phase 1-2 autonomously."
user-invocable: true
argument-hint: "[strategy idea or 'continue']"
model: opus
---

# Trading Strategy Pipeline

This skill runs the full autonomous strategy development pipeline from ideation through validated backtest results.

## Pipeline Phases

### Phase 1: Strategy Ideation (Autonomous)

1. **Bootstrap**: Read session context
   - Read `.crypto/BOOTSTRAP.md`
   - Read `.crypto/knowledge/registry.yaml`
   - Read `.crypto/knowledge/learnings.md`
   - Read `.crypto/config/thresholds.yaml`

2. **Ideation**: Delegate to `trading-strategy-researcher`
   - If user provided a strategy idea: use it as starting point
   - If 'continue': pick next item from `.crypto/pipeline/queue.yaml`
   - If neither: researcher proposes based on gaps in registry
   - Output: `.crypto/knowledge/strategies/STR-{NNN}/hypothesis.md` + `parameters.yaml`

3. **Quantitative Review**: Delegate to `trading-quant-analyst`
   - Input: hypothesis.md + parameters.yaml
   - Output: `quant-review.md`
   - AUTO-GATE: If NOT FEASIBLE → auto-reject, log reason, try next idea

4. **Data Collection**: Delegate to `trading-data-collector`
   - Input: hypothesis.md + parameters.yaml
   - Output: `data-spec.yaml` + collected data files
   - AUTO-GATE: If data unavailable → auto-reject, log reason

### Phase 2: Validation (Autonomous)

5. **Backtesting**: Delegate to `trading-backtester`
   - Input: hypothesis + parameters + data
   - Output: `backtest-results/BT-{NNN}.yaml`
   - AUTO-GATE: Check against `.crypto/config/thresholds.yaml`
     - All hard_pass met → proceed
     - Any hard_fail → auto-reject
     - Marginal → route to Critic

6. **Critic Review**: Delegate to `trading-critic`
   - Input: hypothesis + backtest results
   - Output: `critic-review.md`
   - If CONDITIONAL PASS with required actions:
     - Route back to Backtester for fixes (max 3 cycles)
   - If REJECT: auto-reject, log detailed reasons

7. **Risk Assessment**: Delegate to `trading-risk-manager`
   - Input: backtest results + current portfolio state
   - Output: `risk-assessment.yaml`
   - AUTO-GATE: If risk limits exceeded → reject

8. **Pipeline Complete**: Update knowledge files
   - Update `.crypto/knowledge/registry.yaml` with final status
   - Update `.crypto/BOOTSTRAP.md` with new state
   - Update `.crypto/pipeline/current-run.yaml`
   - Log session to `.crypto/knowledge/session-log.yaml`

### Phase 3: Deployment (Human Required)

9. **Present Evidence Chain** to user:
   - Strategy hypothesis summary
   - Backtest key metrics (OOS)
   - Critic verdict
   - Risk assessment
   - Recommended capital allocation
   - ASK: "Deploy to paper trading?"

## Auto-Rejection Protocol

When a strategy is rejected at any gate:
1. Record rejection reason in `.crypto/knowledge/strategies/STR-{NNN}/decision.yaml`
2. Update `.crypto/knowledge/registry.yaml` status to `rejected`
3. Check if rejection reveals a new learning → add to `.crypto/knowledge/learnings.md`
4. If user provided the idea: report why it was rejected
5. If autonomous: try the next strategy in queue

## Resume Protocol

If session was interrupted:
1. Read `.crypto/pipeline/current-run.yaml` for active runs
2. Resume from the last completed phase
3. All intermediate results persist in strategy folder

## Concurrency

Multiple strategies can be in different phases simultaneously:
- STR-007 in backtest while STR-008 in critic review
- Update `.crypto/pipeline/current-run.yaml` to track all active runs
