---
name: trading-pipeline
description: "Run the full autonomous strategy development pipeline. Use when the user says 'new strategy', 'run pipeline', 'start pipeline', or 'develop strategy'. Orchestrates all agents through the enhanced pipeline with tiered validation."
user-invocable: true
argument-hint: "[strategy idea or 'continue' or 'meeting']"
model: opus
---

# Trading Strategy Pipeline

This skill runs the full autonomous strategy development pipeline from ideation through validated backtest results, using tiered validation (L0->L3) and active learning injection.

## Pipeline Phases

### Phase 0: Pre-Pipeline (NEW)

1. **Bootstrap**: Read session context
   - Read `.crypto/BOOTSTRAP.md`
   - Read `.crypto/knowledge/registry.yaml`
   - Read `.crypto/knowledge/learnings.md`
   - Read `.crypto/config/thresholds.yaml`
   - Read `.crypto/config/tiered-validation-protocol.yaml`

2. **Strategy Meeting** (if argument is 'meeting' or no specific idea):
   - Run strategy meeting protocol (`.crypto/config/strategy-meeting-protocol.yaml`)
   - Spawn in parallel: `trading-strategy-researcher`, `trading-junior-maverick`, `trading-junior-datacurious`
   - Collect all proposals
   - Route through Insight Agent for deduplication

3. **Insight Check**: Delegate to `trading-insight`
   - If user provided a strategy idea: check novelty vs registry
   - If 'continue': pick next item from `.crypto/pipeline/queue.yaml`
   - Output: DUPLICATE (reject) / SIMILAR (needs differentiation) / NOVEL (proceed)
   - AUTO-GATE: DUPLICATE -> auto-reject, log reason

4. **Feedback Pre-Flight**: Delegate to `trading-feedback`
   - Input: hypothesis keywords
   - Output: CRITICAL/WARNING/INFO learning injection report
   - AUTO-GATE: If CRITICAL learnings unaddressed -> BLOCK

### Phase 1: Strategy Ideation (Autonomous)

5. **Ideation**: Delegate to `trading-strategy-researcher`
   - Input: Novel hypothesis + feedback agent context
   - Output: `.crypto/knowledge/strategies/STR-{NNN}/hypothesis.md` + `parameters.yaml`

6. **Quantitative Review**: Delegate to `trading-quant-analyst`
   - Input: hypothesis.md + parameters.yaml + feedback agent learnings
   - Output: `quant-review.md`
   - AUTO-GATE: If NOT FEASIBLE -> auto-reject, log reason, try next idea

7. **Data Collection**: Delegate to `trading-data-collector`
   - Input: hypothesis.md + parameters.yaml
   - Output: `data-spec.yaml` + collected data files
   - AUTO-GATE: If data unavailable -> auto-reject, log reason

### Phase 2: Tiered Validation (Autonomous)

8. **L0: Sanity Check** (30 seconds)
   - Delegate to `trading-backtester` with L0 config
   - Data: 6 months, 1 asset, default parameters
   - Gate: signal frequency > 10, hit_rate != 50%, IC > 0.01
   - AUTO-GATE: FAIL -> auto-reject immediately (save compute)

9. **L1: Quick Validation** (5 minutes)
   - Delegate to `trading-backtester` with L1 config
   - Data: 1 year, primary asset, default parameters
   - Gate: Sharpe > 0.5, PF > 1.0, trades > 30
   - AUTO-GATE: FAIL -> auto-reject

10. **L2: Full Backtest** (30 minutes)
    - Delegate to `trading-backtester` with L2 config
    - Data: 3 years, full asset universe, parameter sweep
    - Gate: `.crypto/config/thresholds.yaml` OR `.crypto/config/portfolio-thresholds.yaml`
    - Run self-diagnostic catalog checks (`.crypto/config/self-diagnostic-catalog.yaml`)
    - AUTO-GATE: hard_fail -> reject, marginal -> route to Critic

11. **Critic Review**: Delegate to `trading-critic`
    - Input: hypothesis + L2 backtest results
    - Output: `critic-review.md`
    - If CONDITIONAL PASS: route back to Backtester (max 3 cycles)
    - If REJECT: auto-reject, extract learnings via Feedback Agent

12. **L3: Extended Validation** (60 minutes)
    - Delegate to `trading-backtester` with L3 config
    - Data: 5 years, walk-forward + Monte Carlo + regime analysis
    - Gate: 3/5 WF windows profitable, MC 95% CI positive, 2/3 regimes profitable
    - AUTO-GATE: FAIL -> reject with detailed analysis

### Phase 3: Risk & Deployment (Human Required)

13. **Risk Assessment**: Delegate to `trading-risk-manager`
    - Input: L3 results + current portfolio state
    - Output: `risk-assessment.yaml`
    - Check: alpha_corr < 0.7 with existing portfolio
    - AUTO-GATE: If risk limits exceeded -> reject

14. **Pipeline Complete**: Update knowledge files
    - Update `.crypto/knowledge/registry.yaml` with final status
    - Update `.crypto/BOOTSTRAP.md` with new state
    - Update `.crypto/pipeline/current-run.yaml`
    - Log session to `.crypto/knowledge/session-log.yaml`
    - Extract learnings via Feedback Agent (whether pass or fail)

15. **Telegram Notification** (if configured):
    - Run `.crypto/scripts/send_telegram.sh` with pipeline result notification:
      - Strategy name and ID
      - Result: VALIDATED or REJECTED (with tier and reason)
      - Key metrics (Sharpe, PF, Win Rate, Max Drawdown)
    - Script silently skips if not configured
    - **IMPORTANT**: Never let notification failure block the pipeline

16. **Present Evidence Chain** to user:
    - Strategy hypothesis summary
    - Tiered validation results (L0 -> L1 -> L2 -> L3)
    - Critic verdict
    - Risk assessment
    - Recommended capital allocation
    - ASK: "Deploy to paper trading?"

## Auto-Rejection Protocol

When a strategy is rejected at any gate:
1. Record rejection reason in `.crypto/knowledge/strategies/STR-{NNN}/decision.yaml`
2. Record which tier rejected it (L0/L1/L2/L3/Critic/Risk)
3. Update `.crypto/knowledge/registry.yaml` status to `rejected`
4. Delegate to `trading-feedback` to extract new learnings
5. Update `.crypto/knowledge/failure-taxonomy.yaml` with root cause
6. If user provided the idea: report why it was rejected with tier info
7. If autonomous: try the next strategy in queue

## Tiered Validation Efficiency

Track rejection stats by tier to measure pipeline efficiency:
```yaml
rejection_stats:
  L0_rejections: N  # Saved ~30min each
  L1_rejections: N  # Saved ~25min each
  L2_rejections: N  # Saved ~30min each
  L3_rejections: N  # Full validation attempted
  critic_rejections: N
  risk_rejections: N
  total_compute_saved: "X hours"
```

## Resume Protocol

If session was interrupted:
1. Read `.crypto/pipeline/current-run.yaml` for active runs
2. Resume from the last completed tier/phase
3. All intermediate results persist in strategy folder

## Concurrency

Multiple strategies can be in different tiers simultaneously:
- STR-059 in L0 while STR-058 in L2
- Update `.crypto/pipeline/current-run.yaml` to track all active runs
