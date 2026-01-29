---
description: Initialize crypto trading workspace in current directory
---

# Initialize Trading Workspace

Set up `.crypto/` directory with all required files for the trading team.

## Steps

1. Check if `.crypto/BOOTSTRAP.md` exists. If yes, inform user "Already initialized" and stop.

2. Create directories:
   - `.crypto/knowledge/strategies/`
   - `.crypto/knowledge/decisions/`
   - `.crypto/knowledge/data-catalog/datasets/`
   - `.crypto/pipeline/`
   - `.crypto/config/`
   - `.crypto/scripts/`
   - `.crypto/data/`

3. Create these template files:

### `.crypto/BOOTSTRAP.md`
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

## Active Alerts
- NONE

## Quick Links
- Strategy registry: .crypto/knowledge/registry.yaml
- Pipeline state: .crypto/pipeline/current-run.yaml
- Risk parameters: .crypto/knowledge/risk-parameters.yaml
- Thresholds: .crypto/config/thresholds.yaml

## Recent Decisions
- (none yet)

## Key Learnings
- (none yet)

## For New Sessions
Read in order:
1. This file
2. .crypto/knowledge/registry.yaml
3. .crypto/pipeline/current-run.yaml
4. .crypto/config/thresholds.yaml

## Pipeline
Ideation → Backtest → Critic → Risk → [HUMAN] → Deploy → Monitor
Phase 1-2 autonomous. Human approves deployment only.
```

### `.crypto/knowledge/registry.yaml`
```yaml
strategies: {}
counters:
  next_id: 1
  total_evaluated: 0
  total_deployed: 0
  total_rejected: 0
  total_archived: 0
  total_in_pipeline: 0
```

### `.crypto/knowledge/session-log.yaml`
```yaml
sessions: []
```

### `.crypto/knowledge/learnings.md`
```markdown
# Cross-Cutting Learnings
Read BEFORE proposing or evaluating any strategy.
---
(No learnings yet.)
```

### `.crypto/knowledge/risk-parameters.yaml`
```yaml
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
  level_1: { threshold: 0.10, action: "Alert + reduce new positions 50%" }
  level_2: { threshold: 0.15, action: "Halt new entries, tighten stops" }
  level_3: { threshold: 0.20, action: "Close 50% of all positions" }
  level_4: { threshold: 0.25, action: "KILL SWITCH: Close all positions" }
current_state:
  total_deployed_pct: 0.0
  current_drawdown: 0.0
  active_strategies: 0
  circuit_breaker_level: 0
```

### `.crypto/config/thresholds.yaml`
```yaml
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
```

### `.crypto/pipeline/current-run.yaml`
```yaml
active_runs: []
queue: []
completed_today: []
```

### `.crypto/knowledge/data-catalog/sources.yaml`
```yaml
sources:
  binance:
    type: centralized_exchange
    data_types: [ohlcv, funding_rate, open_interest, liquidations]
    access: ccxt
  bybit:
    type: centralized_exchange
    data_types: [ohlcv, funding_rate, open_interest]
    access: ccxt
  okx:
    type: centralized_exchange
    data_types: [ohlcv, funding_rate, open_interest]
    access: ccxt
```

4. Output confirmation:
```
Trading workspace initialized at .crypto/

Created:
- .crypto/BOOTSTRAP.md
- .crypto/knowledge/ (registry, learnings, risk params)
- .crypto/config/thresholds.yaml
- .crypto/pipeline/current-run.yaml

Next: /crypto:pipeline to start developing strategies.
```

Replace `{current_date}` with actual ISO date.
