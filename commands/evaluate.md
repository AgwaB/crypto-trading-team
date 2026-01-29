---
description: Evaluate backtest results through Critic + Risk pipeline
---

# Backtest Evaluation

Evaluate strategy backtest results autonomously through Critic and Risk Manager.

## Arguments
- `STR-NNN` → evaluate specific strategy
- `latest` → find most recent backtest result

## Steps

1. Load backtest results from `.crypto/knowledge/strategies/STR-{NNN}/backtest-results/`
2. Auto-gate check against `.crypto/config/thresholds.yaml`
   - All hard_pass → PASS, proceed
   - Any hard_fail → FAIL, auto-reject
   - Marginal → flag for Critic
3. Delegate to `trading-critic` → writes `critic-review.md`
4. Delegate to `trading-risk-manager` → writes `risk-assessment.yaml`
5. Update `.crypto/knowledge/registry.yaml` and `.crypto/BOOTSTRAP.md`
6. If approved → notify strategy ready for deployment review
