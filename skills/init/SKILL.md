---
name: init
description: "Initialize crypto trading team workspace in the current directory. Use when the user says 'init', 'setup trading', 'initialize workspace', or starts a new trading project. Creates all required directories and template files."
user-invocable: true
argument-hint: "[project-name]"
model: sonnet
---

# Initialize Trading Team Workspace

Set up the current directory as a crypto trading team workspace with all required knowledge persistence files.

## Steps

1. **Check if already initialized**: Look for `.crypto/BOOTSTRAP.md` in current directory. If exists, inform user and skip.

2. **Create directory structure**:
   ```
   .crypto/
   .crypto/knowledge/
   .crypto/knowledge/strategies/
   .crypto/knowledge/decisions/
   .crypto/knowledge/data-catalog/
   .crypto/knowledge/data-catalog/datasets/
   .crypto/knowledge/weekly-insights/
   .crypto/pipeline/
   .crypto/config/
   .crypto/config/agents/
   .crypto/scripts/
   .crypto/data/
   ```

3. **Create template files** (use Write tool for each):

### .crypto/BOOTSTRAP.md
```markdown
# Crypto Trading Team - Bootstrap Context

> Last updated: {current_date}
> Updated by: Initial Setup

## Current State
- Active strategies in production: 0
- Strategies in pipeline: 0
- Total strategies evaluated: 0
- Portfolio exposure: 0%
- Current drawdown: 0%
- Team size: 12 agents (10 specialist + 2 junior creative)

## Active Alerts
- NONE

## Quick Links
- Full strategy registry: .crypto/knowledge/registry.yaml
- Current pipeline state: .crypto/pipeline/current-run.yaml
- Risk parameters: .crypto/knowledge/risk-parameters.yaml
- Auto-pass/fail thresholds: .crypto/config/thresholds.yaml
- Tiered validation: .crypto/config/tiered-validation-protocol.yaml
- Self-diagnostics: .crypto/config/self-diagnostic-catalog.yaml
- Meeting protocol: .crypto/config/strategy-meeting-protocol.yaml

## Recent Decisions
- (none yet)

## Key Learnings
- (none yet - learnings will accumulate as strategies are evaluated)

## For New Sessions
If you are starting a new session, read these files in order:
1. This file (you're reading it)
2. .crypto/knowledge/registry.yaml (scan strategy IDs and statuses)
3. .crypto/pipeline/current-run.yaml (see what's actively being worked on)
4. .crypto/config/thresholds.yaml (know the auto-pass/fail rules)
5. .crypto/config/tiered-validation-protocol.yaml (understand L0-L3 gates)

## Pipeline
Insight -> Feedback -> L0 -> L1 -> L2 -> Critic -> L3 -> Risk -> [HUMAN] -> Deploy -> Monitor
Phase 0-2 (Pre-Pipeline through Validation) are fully autonomous. Human approves deployment only.
```

### .crypto/knowledge/registry.yaml
```yaml
# Strategy Registry - Master Index
# Updated ONLY by the Orchestrator.
# Last updated: {current_date}

strategies: {}

counters:
  next_id: 1
  total_evaluated: 0
  total_deployed: 0
  total_rejected: 0
  total_archived: 0
  total_in_pipeline: 0
```

### .crypto/knowledge/session-log.yaml
```yaml
# Session History - Chronological audit trail
# Updated by Orchestrator at session end.

sessions: []
```

### .crypto/knowledge/learnings.md
```markdown
# Cross-Cutting Learnings

Institutional memory for the trading team. Every failed strategy teaches something.
Read this file BEFORE proposing or evaluating any strategy.

## Format
Each learning: ID | Date | Source | Severity (CRITICAL/HIGH/MEDIUM/LOW) | Lesson

---

(No learnings yet. They will accumulate as strategies are evaluated.)
```

### .crypto/knowledge/risk-parameters.yaml
```yaml
# Portfolio-Level Risk Parameters
# Updated by Risk Manager. Read by all agents.
# Last updated: {current_date}

portfolio:
  total_capital: 0
  currency: USDT
  max_deployed_pct: 0.60
  max_correlated_exposure_pct: 0.30

per_strategy:
  max_allocation_pct: 0.30
  max_leverage: 3
  default_risk_per_trade: 0.02

drawdown_circuit_breakers:
  level_1:
    threshold: 0.10
    action: "Alert + reduce new positions 50%"
  level_2:
    threshold: 0.15
    action: "Halt new entries, tighten stops"
  level_3:
    threshold: 0.20
    action: "Close 50% of all positions"
  level_4:
    threshold: 0.25
    action: "KILL SWITCH: Close all positions"

current_state:
  total_deployed_pct: 0.0
  current_drawdown: 0.0
  active_strategies: 0
  circuit_breaker_level: 0
  last_checked: null
```

### .crypto/config/thresholds.yaml
```yaml
# Autonomous Gate Criteria
# Phase 1-2 run fully autonomous using these thresholds.
# Human review required ONLY for deployment (Phase 3+).

hard_pass:
  min_sharpe_oos: 1.0
  min_calmar_oos: 0.5
  max_drawdown: 0.25
  min_trade_count: 100
  min_profit_factor: 1.3
  param_sensitivity_pass: true
  monte_carlo_95ci_positive: true
  fee_stress_2x_profitable: true
  oos_is_sharpe_ratio: 0.70
  min_market_regimes_tested: 3

hard_fail:
  sharpe_below: 0.5
  max_dd_above: 0.40
  profit_factor_below: 1.0
  trade_count_below: 30
  oos_is_ratio_below: 0.50
  monte_carlo_95ci_negative: true

marginal_zone:
  escalation_target: critic
  max_revision_cycles: 3

composite_score:
  formula: "0.4*sharpe + 0.3*calmar + 0.2*profit_factor + 0.1*win_rate"
  min_pass: 1.0

phase_gates:
  ideation_to_backtest: auto
  backtest_to_critic: auto
  critic_to_risk: auto
  risk_to_human: auto
  human_to_paper: human
  paper_to_live: human

revision_limits:
  max_strategy_revisions: 3
  max_backtest_reruns: 5
  auto_archive_after_days: 90
```

### .crypto/config/portfolio-thresholds.yaml
```yaml
# Portfolio Mode Thresholds
# Relaxed individual thresholds + strict portfolio-level requirements
# Use when building a diversified portfolio of weak-but-uncorrelated alphas

individual_strategy:
  min_sharpe_oos: 0.6
  max_drawdown: 0.40
  min_trade_count: 50
  min_profit_factor: 1.1
  oos_is_sharpe_ratio: 0.50
  monte_carlo_95ci_positive: true

portfolio_level:
  min_portfolio_sharpe: 1.5
  max_portfolio_drawdown: 0.25
  max_single_strategy_weight: 0.30
  max_alpha_correlation: 0.7
  min_strategies_for_portfolio: 5

optimization:
  method: HRP
  rebalance_frequency: monthly
  lookback_window: 90

lifecycle:
  stages: [candidate, paper, incubation, active, degraded, disabled]
  paper_trading_days: 30
  incubation_days: 60
  degraded_threshold_sharpe: 0.3
  disable_threshold_days: 30
```

### .crypto/config/tiered-validation-protocol.yaml
```yaml
# Tiered Validation Protocol
# Smart scaling: test small before big. Fail fast, save compute.

tiers:
  L0:
    name: "Sanity Check"
    duration: "30 seconds"
    data_period: "6 months"
    assets: 1
    parameters: "default only"
    gates:
      min_signal_frequency: 10
      hit_rate_not_equal: 0.50
      min_ic: 0.01
    action_on_fail: "REJECT immediately"
    action_on_pass: "Proceed to L1"

  L1:
    name: "Quick Validation"
    duration: "5 minutes"
    data_period: "1 year"
    assets: "primary asset"
    parameters: "default + 2 variants"
    gates:
      min_sharpe: 0.5
      min_profit_factor: 1.0
      min_trades: 30
    action_on_fail: "REJECT"
    action_on_pass: "Proceed to L2"

  L2:
    name: "Full Backtest"
    duration: "30 minutes"
    data_period: "3 years"
    assets: "full universe"
    parameters: "sweep"
    gates: "thresholds.yaml OR portfolio-thresholds.yaml"
    self_diagnostic: true
    action_on_fail: "REJECT"
    action_on_marginal: "Route to Critic"
    action_on_pass: "Proceed to L3"

  L3:
    name: "Extended Validation"
    duration: "60 minutes"
    data_period: "5 years"
    assets: "full universe"
    parameters: "optimized from L2"
    walk_forward:
      windows: 5
      min_profitable: 3
    monte_carlo:
      simulations: 1000
      ci_level: 0.95
      must_be_positive: true
    regime_analysis:
      regimes: [bull, bear, sideways]
      min_profitable: 2
    action_on_fail: "REJECT with detailed analysis"
    action_on_pass: "Proceed to Risk Assessment"

rejection_tracking:
  track_by_tier: true
  compute_savings_formula: "L0_rejections * 30min + L1_rejections * 25min + L2_rejections * 30min"
```

### .crypto/config/self-diagnostic-catalog.yaml
```yaml
# Self-Diagnostic Catalog
# Post-backtest sanity checks run automatically after every backtest.

mandatory_checks:
  benchmark_sanity:
    description: "Compare strategy returns to BTC buy-and-hold"
    check: "If strategy_return >> 3x benchmark AND low trade count, likely bug"
    threshold: 3.0
    severity: CRITICAL

  trade_count_vs_signal:
    description: "Actual trades should be within 30% of expected signal frequency"
    check: "abs(actual_trades - expected_signals) / expected_signals < 0.30"
    threshold: 0.30
    severity: HIGH

  metric_consistency:
    description: "Daily Sharpe vs weekly Sharpe should differ by less than 50%"
    check: "abs(daily_sharpe - weekly_sharpe) / daily_sharpe < 0.50"
    threshold: 0.50
    severity: HIGH

  profit_factor_vs_win_rate:
    description: "High PF with low win rate implies extreme R:R - verify"
    check: "If PF > 2.0 AND win_rate < 0.35, verify avg_win/avg_loss ratio"
    severity: MEDIUM

  position_size_sanity:
    description: "No single trade should be >5% of equity"
    check: "max_position_size / equity < 0.05"
    threshold: 0.05
    severity: CRITICAL

  equity_curve_shape:
    description: "Equity curve should not have single-day jumps >20% of total PnL"
    check: "max_daily_pnl / total_pnl < 0.20"
    threshold: 0.20
    severity: HIGH

  drawdown_recovery:
    description: "Max drawdown recovery period should be < 50% of total period"
    check: "max_recovery_days / total_days < 0.50"
    threshold: 0.50
    severity: MEDIUM

  too_good_to_be_true:
    description: "Sharpe > 3.0 on daily data is suspicious"
    check: "sharpe_daily < 3.0 (if higher, re-verify entire pipeline)"
    threshold: 3.0
    severity: CRITICAL

  parameter_cliff:
    description: "Performance should not drop >50% with 10% parameter change"
    check: "All +/-10% parameter variations retain >50% of Sharpe"
    threshold: 0.50
    severity: HIGH

  oos_is_ratio:
    description: "OOS/IS performance ratio sanity"
    check: "OOS Sharpe / IS Sharpe between 0.3 and 1.5 (outside = suspicious)"
    range: [0.3, 1.5]
    severity: HIGH

auto_expansion:
  trigger: "After 3 occurrences of same undetected error"
  action: "Add new mandatory check to this catalog"
  review: "Orchestrator approves new checks"
```

### .crypto/config/strategy-meeting-protocol.yaml
```yaml
# Strategy Meeting Protocol
# Continuous discovery loop with creative junior agents

meeting:
  participants:
    senior_strategist:
      agent: trading-strategy-researcher
      model: sonnet
      temperature: 0.5
      role: "Domain expert, hypothesis generator"
    junior_maverick:
      agent: trading-junior-maverick
      model: haiku
      temperature: 0.95
      role: "Contrarian, cross-domain analogies"
    junior_datacurious:
      agent: trading-junior-datacurious
      model: haiku
      temperature: 0.8
      role: "Data anomaly hunter, feature engineer"
    insight_agent:
      agent: trading-insight
      model: sonnet
      temperature: 0.3
      role: "Deduplication, creative twists on failures"

  phases:
    1_diverge:
      description: "All participants generate ideas freely"
      duration: "10 minutes"
      rules:
        - "No criticism allowed"
        - "Quantity over quality"
        - "Build on others' ideas"
        - "Junior agents speak first"

    2_collect:
      description: "Gather all proposals, remove exact duplicates"
      duration: "5 minutes"
      rules:
        - "Combine similar ideas"
        - "Preserve original attribution"

    3_filter:
      description: "Insight Agent deduplication + Feedback Agent learning check"
      duration: "5 minutes"
      verdicts: [NOVEL, SIMILAR_WITH_TWIST, DUPLICATE]
      auto_reject: DUPLICATE

    4_select:
      description: "Rank by novelty x feasibility, select top 3 for L0"
      duration: "5 minutes"
      max_selections: 3

    5_learn:
      description: "Record which ideas survived, track agent effectiveness"
      duration: "5 minutes"
      metrics:
        - "ideas_per_agent"
        - "l0_survival_rate_per_agent"
        - "novel_ideas_per_meeting"

continuous_loop:
  enabled: true
  cycle: "Meeting -> L0 Screen -> Results -> Next Meeting"
  anti_stagnation:
    trigger: "5 consecutive meetings with 0 L0 survivors"
    actions:
      - "Rotate junior agent prompts"
      - "Change meeting theme (e.g., 'only altcoin strategies')"
      - "Invite external data source review"
  performance_tracking:
    track: "Which agent's ideas survive to L1, L2, L3"
    review_frequency: "Every 10 meetings"
```

### .crypto/knowledge/search-space-map.yaml
```yaml
# Search Space Map
# Tracks tested vs untested strategy archetypes and variants
# Updated by Insight Agent after each strategy evaluation

archetypes: {}

data_sources:
  daily_ohlcv:
    status: ACTIVE
    coverage: "BTC, ETH, top-20 alts"
  hourly_ohlcv:
    status: ACTIVE
    coverage: "BTC, ETH"
  funding_rate:
    status: ACTIVE
    coverage: "Binance perpetuals"

untested_frontiers:
  - "Options/IV data strategies"
  - "Cross-exchange arbitrage"
  - "Real-time on-chain analytics"
  - "L2/tick data microstructure"
  - "Sentiment/social media signals"
```

### .crypto/knowledge/failure-taxonomy.yaml
```yaml
# Failure Taxonomy
# Root cause categories for strategy failures
# Updated by Feedback Agent after each rejection

categories:
  conceptual_flaw:
    description: "Fundamental hypothesis is wrong"
    count: 0
    examples: []
  cost_structure:
    description: "Edge exists but transaction costs exceed it"
    count: 0
    examples: []
  regime_nonstationarity:
    description: "Strategy works in one regime but not others"
    count: 0
    examples: []
  data_insufficiency:
    description: "Not enough data or trades for statistical significance"
    count: 0
    examples: []
  parameter_sensitivity:
    description: "Narrow profitable parameter space"
    count: 0
    examples: []
  implementation_bug:
    description: "Code error producing false results"
    count: 0
    examples: []

meta:
  total_failures: 0
  most_common: null
  preventable_pct: 0
```

### .crypto/pipeline/current-run.yaml
```yaml
# Current Pipeline State
# Updated by Orchestrator after each phase transition.
# Last updated: {current_date}

active_runs: []
queue: []
completed_today: []
```

### .crypto/knowledge/data-catalog/sources.yaml
```yaml
# Available Data Sources
# Maintained by Data Collector

sources:
  binance:
    type: centralized_exchange
    data_types: [ohlcv, funding_rate, open_interest, liquidations]
    access: ccxt
    api_key_required: true
    rate_limit: "1200 requests/min"

  bybit:
    type: centralized_exchange
    data_types: [ohlcv, funding_rate, open_interest]
    access: ccxt
    api_key_required: true
    rate_limit: "120 requests/min"

  okx:
    type: centralized_exchange
    data_types: [ohlcv, funding_rate, open_interest]
    access: ccxt
    api_key_required: true
    rate_limit: "60 requests/2s"
```

### .crypto/knowledge/learning-violations.yaml
```yaml
# Learning Violation Tracker
# Records when agents ignore known learnings
# Maintained by Feedback Agent

violations: []

stats:
  total_violations: 0
  violations_that_caused_failure: 0
  compliance_rate: 1.0
```

4. **Confirmation**: After creating all files, output:
   ```
   Trading team workspace initialized.

   Created:
   - .crypto/BOOTSTRAP.md (session entry point)
   - .crypto/knowledge/ (registry, learnings, risk params, search-space, failure taxonomy)
   - .crypto/config/ (thresholds, portfolio-thresholds, tiered-validation, self-diagnostics, meeting protocol)
   - .crypto/pipeline/current-run.yaml (pipeline state)

   Team: 12 agents (Orchestrator, Insight, Feedback, Researcher, Maverick, DataCurious, Quant, Data, Backtester, Critic, Risk, ML Engineer)
   Pipeline: Insight -> Feedback -> L0 -> L1 -> L2 -> Critic -> L3 -> Risk -> [HUMAN]

   Next: /crypto:pipeline to start developing strategies.
   Next: /crypto:pipeline meeting to run a strategy brainstorming session.
   ```

Replace `{current_date}` with the actual current date in ISO format when creating files.
