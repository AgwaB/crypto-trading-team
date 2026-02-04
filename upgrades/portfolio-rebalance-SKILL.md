---
name: trading-portfolio-rebalance
description: "Automatically rebalance portfolio positions based on correlation analysis and performance drift. Adjust allocations to maintain target exposures, reduce correlated risk, and respect circuit breaker limits. Daily drift check at 02:00 UTC. Use 'rebalance', 'adjust positions', or 'reduce correlation'."
user-invocable: true
argument-hint: "[--mode proportional|correlation-aware|performance-weighted|risk-adjusted | --dry-run | --execute]"
model: opus
---

# Portfolio Rebalance

Automatically maintain portfolio balance by analyzing allocation drift, correlation patterns, and performance. Generate rebalancing proposals, simulate impact, and execute with circuit breaker validation.

## Trigger Patterns

- **Auto-trigger**: Daily 02:00 UTC (drift analysis), or when drift threshold exceeded
- **Manual**: `/trading-portfolio-rebalance --mode correlation-aware --dry-run`
- **Context keywords**: "rebalance", "adjust positions", "reduce correlation", "fix drift"

## Workflow Overview

```
BOOTSTRAP        DRIFT ANALYSIS      CORRELATION      DECISION &        EXECUTION
┌──────────┐    ┌──────────────┐    ┌────────────┐    SIMULATION      ┌──────────┐
│Load dep  │───▶│Compare curr  │───▶│Calculate   │───▶┌──────────────┐ │Exec trades│
│strategies│    │vs target     │    │corr matrix │   │Generate prop │ │Verify lim │
│& allocs  │    │Flag drift    │    │Identify    │   │Simulate      │ │Update     │
└──────────┘    └──────────────┘    │pairs      │   │impact        │ │registry   │
                                     └────────────┘   │Check circuit │ └──────────┘
                                                      │breakers      │
                                                      └──────────────┘
```

## Detailed Steps

### 1. Bootstrap & Current State Assessment

**Delegate to**: Orchestrator

On scheduled trigger or manual invocation:
- Read `.crypto/BOOTSTRAP.md`
  - Extract: deployed strategies and current allocations
  - Extract: total capital deployed
  - Extract: current portfolio state
- Read `.crypto/knowledge/registry.yaml`
  - For each deployed strategy: target allocation, deployment date
  - Extract: strategy metadata (assets, risk profile)
- Read `.crypto/live-monitoring/live-performance/`
  - For each strategy: current P&L (1h, 4h, 1d windows)
  - Extract: current market values of positions
- Calculate current allocations:
  ```yaml
  current_allocations:
    STR-001: {capital: 20400, target: 20000, alloc_percent: 34, drift_percent: 2}
    STR-003: {capital: 12100, target: 12000, alloc_percent: 20, drift_percent: 0.8}
    STR-007: {capital: 6200, target: 6000, alloc_percent: 10.3, drift_percent: 3.3}
    total_deployed: {capital: 38700, alloc_percent: 64.5, target: 60}
  ```
- Write assessment to `.crypto/portfolio-rebalance/assessment-{DATE}.yaml`
- Identify candidates for rebalancing:
  - Individual drift > 5% → high priority
  - Individual drift 2-5% → medium priority
  - Individual drift <2% → low priority (leave alone)

**Output**: Current state assessment with drift analysis

### 2. Correlation Analysis

**Delegate to**: Orchestrator + Quantitative Analyst (for interpretation)

Calculate correlation matrix for all deployed strategies:
- Use 30-day lookback window
- Data source: `.crypto/live-monitoring/live-performance/{STR}/`
- For each pair of strategies:
  - Calculate Pearson correlation on daily returns
  - Result: correlation coefficient -1 to +1
  - Interpretation:
    - >0.7: HIGH correlation (correlated)
    - 0.4-0.7: MEDIUM correlation
    - <0.4: LOW correlation (diversified)

Example correlation matrix:
```yaml
correlation_matrix:
  as_of: "2025-02-05"
  lookback_days: 30
  strategies: [STR-001, STR-003, STR-007]
  correlation:
    STR-001:
      STR-001: 1.0
      STR-003: 0.78     # HIGH - these move together
      STR-007: 0.35     # LOW - diversified
    STR-003:
      STR-001: 0.78
      STR-003: 1.0
      STR-007: 0.42     # MEDIUM
    STR-007:
      STR-001: 0.35
      STR-003: 0.42
      STR-007: 1.0
```

Identify correlated clusters:
- STR-001 + STR-003 highly correlated (0.78)
  - Combined allocation: 34% + 20% = 54% of portfolio
  - Exceeds 30% correlated exposure limit
  - Action: Reduce one or both

Aggregate correlated exposure:
```yaml
correlated_clusters:
  cluster_1:
    strategies: [STR-001, STR-003]
    correlation_avg: 0.78
    combined_allocation: 54
    exceeds_limit: true
    limit_30_percent: true
    reduction_needed: 24 percent units

  cluster_2:
    strategies: [STR-007]
    correlation_avg: N/A (single)
    combined_allocation: 10.3
    exceeds_limit: false
```

**Output**: Correlation matrix + cluster analysis

### 3. Rebalance Decision (DRY-RUN)

**Delegate to**: Orchestrator

Apply rebalancing algorithm based on mode selection:

**Mode 1: PROPORTIONAL** (scale all equally)
- Goal: Reduce all allocations proportionally to stay ≤60%
- Method: Scale all by factor = 0.60 / current_total
- Example: current 64.5% → scale by 0.931 → new 60.0%
- Effect: Reduce all strategies by ~6.9%

**Mode 2: CORRELATION_AWARE** (reduce correlated pairs)
- Goal: Reduce correlated pairs to meet 30% limit
- Method:
  1. Identify high-correlation clusters
  2. For each cluster exceeding 30%:
     - Reduce highest-allocation member first
     - Target: cluster total ≤ 30%
  3. Maintain proportions within uncorrelated strategies
- Example:
  - Cluster (STR-001, STR-003) = 54% → reduce to 30%
  - Reduce STR-001: 34% → 16%
  - Keep STR-003: 20% (no further reduction)
  - Keep STR-007: 10.3% (uncorrelated)
  - Result: 16% + 20% + 10.3% = 46.3% (well under 60%)

**Mode 3: PERFORMANCE_WEIGHTED** (increase winners, decrease losers)
- Goal: Shift capital from underperformers to outperformers
- Method:
  1. Calculate 30-day Sharpe for each strategy
  2. Rank strategies: high_sharpe → increase, low_sharpe → decrease
  3. Redistribute capital within limits
- Example:
  - STR-001 Sharpe: 0.55 (top performer) → increase by 5%
  - STR-003 Sharpe: 0.32 (underperformer) → decrease by 5%
  - STR-007 Sharpe: 0.48 (mid) → keep stable
- Result: Increase winner, decrease loser, maintain total

**Mode 4: RISK_ADJUSTED** (account for individual volatility)
- Goal: Allocate more to lower-volatility strategies
- Method:
  1. Calculate 30-day volatility for each strategy
  2. Compute inverse-vol weights
  3. Rebalance to vol-adjusted target allocations
- Example:
  - STR-001 vol: 15% → weight: 1/0.15 = 6.67
  - STR-003 vol: 20% → weight: 1/0.20 = 5.00
  - STR-007 vol: 18% → weight: 1/0.18 = 5.56
  - Normalized: STR-001: 37%, STR-003: 28%, STR-007: 35%

Generate proposed allocation changes:
```yaml
rebalance_proposal:
  mode: "correlation_aware"
  as_of: "2025-02-05T02:15:00Z"
  current_allocations: {STR-001: 34, STR-003: 20, STR-007: 10.3}
  proposed_allocations: {STR-001: 16, STR-003: 20, STR-007: 10.3}
  changes:
    STR-001: {from: 34, to: 16, change: -18, reason: "Reduce correlation cluster"}
    STR-003: {from: 20, to: 20, change: 0, reason: "Keep stable, moderate contribution"}
    STR-007: {from: 10.3, to: 10.3, change: 0, reason: "Uncorrelated, no change needed"}
  summary:
    total_deployed_before: 64.3
    total_deployed_after: 46.3
    total_reduction: 18 percent units
    correlated_exposure_before: 54
    correlated_exposure_after: 36
    limit_exceeded_before: true
    limit_exceeded_after: false
```

**Output**: Proposed rebalancing allocation changes

### 4. Circuit Breaker Compliance Check

**Delegate to**: Orchestrator + Risk Manager (for validation)

Verify proposed allocations respect all limits:

**Hard Limits** (from `.crypto/config/portfolio-rebalance.yaml`):
- Total deployed ≤ 60%
- Correlated exposure ≤ 30%
- Individual strategy ≤ 40%
- Minimum allocation ≥ 1% (don't allocate <1%)

Check each limit:
```yaml
circuit_breaker_check:
  total_deployed:
    proposed: 46.3
    limit: 60
    status: "PASS"
    buffer: 13.7
  correlated_exposure:
    cluster_1: 36  (STR-001 + STR-003)
    limit: 30
    status: "FAIL"
    violation: 6 percent units
  individual_max:
    STR-001: 16 (limit: 40) - PASS
    STR-003: 20 (limit: 40) - PASS
    STR-007: 10.3 (limit: 40) - PASS
  individual_min:
    STR-001: 16 (limit: 1) - PASS
    STR-003: 20 (limit: 1) - PASS
    STR-007: 10.3 (limit: 1) - PASS
```

If any limit violated:
1. Flag the violation in proposal
2. Adjust proposal to fix violation
3. Iterate until all limits respected
4. Document adjustments made

Example adjustment for correlated cluster:
- Previous: STR-001: 16%, STR-003: 20% → total 36%
- Adjustment: Reduce STR-003 further: STR-001: 16%, STR-003: 14% → total 30%
- Result: All limits now satisfied

**Output**: Circuit breaker validated proposal

### 5. Impact Simulation

**Delegate to**: Quantitative Analyst

Simulate rebalancing impact and project new metrics:

**Simulation Setup**:
- Historical data: 30 days of returns per strategy
- Rebalancing: Apply proposed allocation changes to historical data
- Recalculate: Portfolio metrics with new weights

**Metrics Calculated**:
```yaml
impact_simulation:
  baseline_metrics:  # Current allocation
    sharpe_ratio: 0.42
    max_drawdown: -8.7
    win_rate: 0.62
    return_30d: 5.2

  projected_metrics:  # After rebalancing
    sharpe_ratio: 0.48      # Improvement
    max_drawdown: -6.2      # Reduction
    win_rate: 0.65          # Improvement
    return_30d: 4.8         # Slight decrease (acceptable for risk reduction)

  improvements:
    sharpe_improvement: 0.06
    max_dd_improvement: 2.5
    win_rate_improvement: 0.03
    estimated_improvement_percent: 14.3  # Weighted improvement

  trading_costs:
    estimated_slippage_bps: 25           # 0.25%
    estimated_commissions_bps: 5
    total_cost_percent: 0.30

  net_improvement:
    gross_improvement: 14.3
    trading_costs: 0.30
    net_improvement: 14.0

  recommendation:
    improvement_exceeds_threshold: true  # 14% > 5% threshold
    recommendation: "REBALANCE"
    confidence: "HIGH"
```

Compare baseline to projected:
- If improvement > 5% threshold: RECOMMEND rebalancing
- If neutral (±5%): OPTIONAL (user decides)
- If worse: DO NOT REBALANCE (keep current allocation)

**Output**: Impact simulation + recommendation

### 6. Approval & Execution Decision

**Delegate to**: Orchestrator

**If DRY_RUN mode**:
1. Stop here
2. Present proposal + impact simulation to user
3. User can:
   - Approve: `/trading-portfolio-rebalance --execute`
   - Modify: Request different mode
   - Reject: Keep current allocation

**If AUTO_EXECUTE mode** (with pre-approval):
1. Generate rebalancing trades:
   - For each strategy with allocation change:
     - If allocation increasing: BUY more
     - If allocation decreasing: SELL excess
   - Example trades:
     ```yaml
     rebalancing_trades:
       - strategy: STR-001
         action: SELL
         percent_of_portfolio: 18
         reason: Reduce correlation
       - strategy: STR-003
         action: HOLD
         percent_of_portfolio: 0
       - strategy: STR-007
         action: HOLD
         percent_of_portfolio: 0
     ```
2. Delegate to `trading-order-executor`
   - Input: Rebalancing trades in batch
   - Execute all trades together (minimize market impact)
   - Monitor for slippage vs estimated
3. Await all fills before continuing
4. Record execution to `.crypto/portfolio-rebalance/execution-{DATE}.yaml`

**If USER_APPROVAL required** (default):
1. Present to user:
   - Current allocation
   - Proposed allocation
   - Impact simulation (improvement %)
   - Trading costs
   - Net benefit
2. Allow modification before execution
3. Execute once user approves
4. Log approval timestamp

**Output**: Execution decision made or awaiting approval

### 7. Post-Rebalance Verification

**Delegate to**: Orchestrator + Risk Manager

After trades executed:
- Confirm all orders filled (or log partial fills)
- Recalculate allocations from new positions:
  ```yaml
  post_rebalance_allocations:
    STR-001: {capital: 9600, target: 9600, alloc: 16, drift: 0}
    STR-003: {capital: 12000, target: 12000, alloc: 20, drift: 0}
    STR-007: {capital: 6180, target: 6180, alloc: 10.3, drift: 0}
    total_deployed: {capital: 27780, alloc: 46.3, drift: 0}
  ```
- Verify all limits still respected:
  - Total deployed ≤ 60%? YES (46.3%)
  - Correlated exposure ≤ 30%? YES (30%)
  - Individual max ≤ 40%? YES (all <40%)
- Calculate actual trading costs:
  - Slippage: estimated 25 bps, actual 28 bps
  - Commissions: actual fees paid
  - Total cost: 0.33% (vs estimated 0.30%)
- Update `.crypto/knowledge/registry.yaml` with new allocations:
  - Set new target allocations
  - Record rebalance timestamp
  - Record reason for rebalance
- Update `.crypto/BOOTSTRAP.md` with new portfolio state
- Write summary to `.crypto/portfolio-rebalance/execution-summary-{DATE}.yaml`:
  ```yaml
  rebalance_execution_summary:
    date: "2025-02-05"
    mode: "correlation_aware"
    trades_executed: 1
    trades_successful: 1
    total_slippage_bps: 28
    total_commissions_bps: 5
    total_cost_bps: 33
    execution_time_minutes: 2.3
    new_portfolio_sharpe: 0.48
    new_correlated_exposure: 30
    status: "SUCCESS"
  ```

**Output**: Execution verified, registry + BOOTSTRAP updated

### 8. Monitoring & Feedback (Post-Rebalance)

**Delegate to**: Monitor Agent + Feedback Agent

Monitor new allocations for 7 days:
- Track new allocations vs targets
- Monitor performance drift
- Compare actual post-rebalance performance to simulation
- If actual performance diverges >10% from projection:
  - Log discrepancy in `.crypto/portfolio-rebalance/feedback.yaml`
  - Delegate to `trading-feedback` for learning extraction
  - Example: "Projected +2.5% max DD improvement, actual +1.2%"
  - Root cause analysis: market regime changed, correlation changed
- Update rebalance algorithm success rate
- Record learning for future rebalancing decisions

**Output**: Feedback captured, algorithm tuned

## Agents Involved

### Orchestrator
- Role: Primary coordinator
- Responsibilities:
  - Load current state and calculate drift
  - Calculate correlation matrix
  - Route to appropriate rebalancing algorithm
  - Validate circuit breakers
  - Manage execution flow

### Quantitative Analyst (on simulation)
- Role: Impact simulator
- Responsibilities:
  - Simulate rebalancing on historical data
  - Project portfolio metrics post-rebalance
  - Assess trading cost impact
  - Make REBALANCE/HOLD recommendation

### Risk Manager (on verification)
- Role: Limit validator
- Responsibilities:
  - Review proposed allocations
  - Confirm circuit breaker compliance
  - Approve or reject proposal

### Order Executor (on execution)
- Role: Trade executor
- Responsibilities:
  - Execute rebalancing trades in batch
  - Monitor for slippage
  - Confirm fills and balances

### Feedback Agent (post-execution)
- Role: Learning extractor
- Responsibilities:
  - Compare projected vs actual performance
  - Extract learnings on prediction accuracy
  - Update algorithm with feedback

## Tools & Capabilities Required

### New Tools Needed

```yaml
calculate_correlation_matrix:
  signature: calculate_correlation_matrix(strategy_ids, lookback_days)
  inputs:
    strategy_ids: ["STR-001", "STR-003", "STR-007"]
    lookback_days: 30
  outputs:
    correlation_matrix: {yaml}
    high_correlation_pairs: [{strs, correlation}]
    correlated_clusters: [{strategies, total_alloc, exceeds_limit}]

generate_rebalance_proposal:
  signature: generate_rebalance_proposal(current_allocs, algorithm_mode)
  inputs:
    current_allocations: {STR-001: 34, ...}
    algorithm_mode: "correlation_aware"
  outputs:
    proposed_allocations: {yaml}
    changes_per_strategy: [{strategy, from, to, reason}]

simulate_rebalance_impact:
  signature: simulate_rebalance_impact(proposal)
  outputs:
    baseline_metrics: {sharpe, dd, win_rate, return}
    projected_metrics: {sharpe, dd, win_rate, return}
    improvements: {sharpe_improvement, dd_improvement}
    trading_costs: {slippage_bps, commissions_bps}
    net_improvement_percent: N

verify_allocation_compliance:
  signature: verify_allocation_compliance(allocations, limits)
  outputs:
    total_deployed_ok: boolean
    correlated_exposure_ok: boolean
    individual_max_ok: boolean
    all_limits_met: boolean
    violations: [{limit, proposed, limit_val, status}]

execute_rebalance_trades:
  signature: execute_rebalance_trades(orders)
  outputs:
    executed_trades: N
    successful_trades: N
    partial_fills: [{strategy, intended, actual}]
    total_slippage_bps: N
    total_commissions_bps: N
```

### Existing Tools Used

- **File I/O**: Read/write rebalance files, registry, bootstrap, live-performance
- **Agent delegation**: order-executor, risk-manager, feedback
- **Correlation calculation**: Quantitative analysis
- **Performance tracking**: From live-monitoring data

### Resource Requirements

- **Frequency**: Daily drift check (5-10 min), rebalancing as needed (10-30 min)
- **Computation**: Correlation matrix for N strategies (O(N²) operations)
  - 3 strategies: <1 minute
  - 10 strategies: ~5 minutes
- **Storage**: 50MB/month for rebalancing records
- **Uptime**: 24/7 for daily checks, responsive on-demand

## Configuration

Add to `.crypto/config/portfolio-rebalance.yaml`:

```yaml
portfolio_rebalance:
  enabled: true

  # Scheduling
  schedule: "0 2 * * *"                 # Daily 02:00 UTC

  # Drift thresholds
  drift_thresholds:
    individual_drift_percent: 5.0       # Flag if drift > 5%
    portfolio_drift_percent: 2.0        # Portfolio-level drift
    auto_rebalance_threshold: 10.0      # Trigger rebalance if >10%

  # Correlation analysis
  correlation_analysis:
    lookback_days: 30
    high_correlation_threshold: 0.7
    correlated_cluster_max_allocation: 0.30  # 30% limit
    redundancy_score_min: 0.5           # Minimum to consider redundant

  # Rebalancing modes
  rebalancing_modes:
    default: correlation_aware          # Default algorithm
    available:
      - proportional                    # Scale all equally
      - correlation_aware               # Reduce correlated pairs
      - performance_weighted            # Increase winners
      - risk_adjusted                   # Account for volatility

  # Circuit breakers (hard limits)
  circuit_breakers:
    max_total_deployed_percent: 60
    max_correlated_exposure_percent: 30
    max_individual_allocation_percent: 40
    min_allocation_percent: 1.0         # Don't allocate <1%

  # Execution
  execution:
    mode: dry_run_default               # dry_run_default | auto_execute
    approval_required: true              # Require user approval
    batch_execution: true               # Execute all trades together
    slippage_tolerance_bps: 50          # 0.5% max slippage
    max_trades_per_rebalance: 10

  # Impact simulation
  impact_simulation:
    estimate_slippage: true
    estimate_commissions: true
    simulate_drawdown: true
    lookback_windows: [1h, 4h, 1d]
    improvement_threshold_percent: 5.0  # Rebalance if >5% improvement

  # Post-rebalance monitoring
  monitoring:
    post_rebalance_days: 7
    tracking_interval_hours: 1
    divergence_alert_threshold_percent: 10.0

  # Learning & feedback
  learning:
    extract_learnings: true
    update_algorithm_on_divergence: true
    feedback_agent_enabled: true
```

## Integration Points

### Triggers
- **Auto-trigger**: Daily at 02:00 UTC, or when drift >10%
- **Manual**: `/trading-portfolio-rebalance --mode correlation-aware --dry-run`

### Upstream Dependencies
- Strategies must be deployed (in BOOTSTRAP.md)
- Live performance data must exist (from live-monitoring)
- Registry must exist (`.crypto/knowledge/registry.yaml`)

### Downstream Integration
- Feeds to: Order executor (rebalancing trades)
- Feeds to: Live monitoring (updated allocations)
- Updates: `.crypto/knowledge/registry.yaml`, `.crypto/BOOTSTRAP.md`
- Notifies: User on major rebalancing decisions

## Error Handling

### Correlation Calculation Failure
1. Log error, skip correlation analysis
2. Use fallback mode: PROPORTIONAL
3. Continue with basic drift rebalancing

### Live Performance Data Missing
1. Log warning
2. Use last available snapshot (up to 7 days old)
3. Proceed with available data
4. Mark proposal as "based on stale data"

### Order Execution Failure
1. Log error, revert to previous allocation state
2. Do NOT proceed with partial rebalancing
3. Alert user, ask for manual intervention

### Circuit Breaker Violation (after adjustment)
1. Log that violation couldn't be fixed
2. Flag proposal as BLOCKED
3. Alert user: "Cannot rebalance while respecting all limits"
4. Recommend manual action

## Monitoring & Metrics

### Key Metrics

```yaml
portfolio_rebalance_metrics:
  run_period: "2025-02-01 to 2025-02-28"
  total_rebalances: 8
  successful_rebalances: 8
  success_rate_percent: 100

  by_mode:
    correlation_aware: {triggered: 5, successful: 5}
    performance_weighted: {triggered: 3, successful: 3}

  improvements_achieved:
    avg_sharpe_improvement: 6.2
    avg_dd_improvement: 2.1
    median_improvement_percent: 5.8

  trading_costs:
    avg_slippage_bps: 27
    avg_commissions_bps: 5
    avg_total_cost_bps: 32

  drift_management:
    avg_drift_before_rebalance: 8.5
    avg_drift_after_rebalance: 0.2
    drift_correction_percent: 97.6

  limit_compliance:
    all_limits_respected: 100
    violations_pre_rebalance: 4
    violations_post_rebalance: 0
```

### Alerts & Warnings

- **Alert**: Correlation spike >0.95 (extreme correlation)
- **Alert**: Drift exceeds 15% (severe imbalance)
- **Alert**: Circuit breaker violation unresolved (manual action needed)
- **Warning**: Projected improvement <3% (marginal benefit)

### Dashboard Location

Track metrics in: `.crypto/live-monitoring/rebalance-metrics.yaml`

Update after each rebalance, retain last 50 rebalances (6 months).

## Examples

### Example 1: Correlation-Aware Rebalance

**Setup**:
- STR-001 (funding arb): 34% allocation, Sharpe 0.55
- STR-003 (yield opt): 20% allocation, Sharpe 0.32
- STR-007 (spot vol): 10.3% allocation, Sharpe 0.48
- Correlation(STR-001, STR-003) = 0.78 (high)
- Combined: 54% > 30% limit (EXCEEDED)

**Execution**:
1. Orchestrator detects: correlation_aware mode needed
2. Quant Analyst calculates: reduce STR-001 to bring pair under 30%
3. Proposed: STR-001: 34% → 16%, STR-003: 20%, STR-007: 10.3%
4. Result: Correlated pair = 36% → then reduce further to 30%
5. Final: STR-001: 16%, STR-003: 14%, STR-007: 10.3% = 40.3% total
6. Simulation: Sharpe 0.42 → 0.48 (+14% improvement)
7. User approves, executes SELL 18% from STR-001
8. Post-exec: Allocations verified, limits respected
9. User notified: "Rebalanced to reduce correlation exposure"

**Output**: Correlation-driven rebalance complete, risk reduced

### Example 2: Performance-Weighted Rebalance

**Setup**:
- STR-001 (winner): Sharpe 0.65, allocation 30%
- STR-005 (loser): Sharpe 0.25, allocation 25%
- STR-008 (middle): Sharpe 0.45, allocation 10%

**Execution**:
1. Orchestrator triggers: performance-weighted mode
2. Quant Analyst calculates weights by Sharpe:
   - STR-001: 0.65 → weight 37% (increase)
   - STR-005: 0.25 → weight 20% (decrease)
   - STR-008: 0.45 → weight 28% (stable)
3. Proposed changes:
   - STR-001: 30% → 37% (+7%)
   - STR-005: 25% → 20% (-5%)
   - STR-008: 10% → 28% (+18%)
4. Simulation: Sharpe 0.40 → 0.44 (+10% improvement)
5. User approves, executes: BUY 7% STR-001, SELL 5% STR-005, BUY 18% STR-008
6. Post-exec: Verified, logged
7. Monitor: Actual Sharpe becomes 0.43 (close to projection)

**Output**: Winners increased, losers reduced, performance improved

### Example 3: Dry-Run (User Override)

**Setup**:
- Drift triggered: STR-009 allocation drifted +12%
- Auto-rebalance triggered

**Execution**:
1. Orchestrator: Correlation_aware mode, dry-run
2. Proposes: Reduce STR-009 by 12%
3. Simulates: +3% Sharpe improvement
4. Presents to user with circuit breaker validation (PASS)
5. User reviews:
   - "I want to keep STR-009 higher, it's my conviction"
   - Selects: PERFORMANCE_WEIGHTED instead
6. Orchestrator re-runs with selected mode
7. New proposal: More conservative reduction
8. User approves
9. Executes trade
10. Result: User's preference respected, drift controlled

**Output**: User-driven rebalancing with mode selection

## Success Metrics

- **Rebalancing frequency**: 1-2 times per week
- **Allocation compliance**: 100% adherence to circuit breakers
- **Performance improvement**: Average >3% Sharpe improvement post-rebalance
- **Drift control**: Keep all individual strategies <5% drift from target
- **Limit maintenance**: Never exceed 60% total, 30% correlated, 40% individual
