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
   .crypto/pipeline/
   .crypto/config/
   .crypto/scripts/
   .crypto/data/
   ```

3. **Create template files** (use Write tool for each):

### .crypto/BOOTSTRAP.md
```markdown
# Crypto Trading Team - Bootstrap Context

> Last updated: 2026-01-29T16:30:26Z
> Updated by: Initial Setup

## Current State
- Active strategies in production: 0
- Strategies in pipeline: 0
- Total strategies evaluated: 0
- Portfolio exposure: 0%
- Current drawdown: 0%

## Active Alerts
- NONE

## Quick Links
- Full strategy registry: .crypto/knowledge/registry.yaml
- Current pipeline state: .crypto/pipeline/current-run.yaml
- Risk parameters: .crypto/knowledge/risk-parameters.yaml
- Auto-pass/fail thresholds: .crypto/config/thresholds.yaml

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

## Architecture
Pipeline: Ideation → Backtest → Critic Review → Risk Assessment → [HUMAN] → Deploy → Monitor
Phase 1-2 (Research→Validation) are fully autonomous. Human approves deployment only.
```

### .crypto/knowledge/registry.yaml
```yaml
# Strategy Registry - Master Index
# Updated ONLY by the Orchestrator.
# Last updated: 2026-01-29T16:30:26Z

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
# Last updated: 2026-01-29T16:30:26Z

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

### .crypto/pipeline/current-run.yaml
```yaml
# Current Pipeline State
# Updated by Orchestrator after each phase transition.
# Last updated: 2026-01-29T16:30:26Z

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

4. **Confirmation**: After creating all files, output:
   ```
   ✅ Trading team workspace initialized.

   Created:
   - .crypto/BOOTSTRAP.md (session entry point)
   - .crypto/knowledge/ (strategy records, learnings, risk params)
   - .crypto/config/thresholds.yaml (auto-pass/fail criteria)
   - .crypto/pipeline/current-run.yaml (pipeline state)

   Next: /crypto-trading-team:trading-pipeline to start developing strategies.
   ```

Replace `{current_date}` with the actual current date in ISO format when creating files.
