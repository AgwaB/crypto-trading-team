---
name: trading-evaluate
description: "Evaluate backtest results against thresholds. Use when backtest results are ready, when you see 'evaluate', 'check results', or 'review backtest'. Auto-triggers after backtester produces results."
user-invocable: true
argument-hint: "[STR-NNN or 'latest']"
model: opus
---

# Backtest Evaluation Pipeline

Evaluates backtest results through Critic + Risk Manager pipeline autonomously.

## Steps

1. **Load Results**: Read the specified strategy's backtest results
   - If 'latest': find most recent BT-*.yaml in any strategy folder
   - If STR-NNN: read from `.crypto/knowledge/strategies/STR-{NNN}/backtest-results/`

2. **Auto-Gate Check**: Apply `.crypto/config/thresholds.yaml`
   - All hard_pass → mark as PASS, proceed to Critic
   - Any hard_fail → mark as FAIL, auto-reject
   - Marginal → flag for Critic special attention

3. **Critic Review**: Delegate to `trading-critic`
   - Critic reads hypothesis, backtest results, and learnings
   - Critic writes `critic-review.md`
   - If REJECT: update registry, record learning, STOP
   - If CONDITIONAL PASS: list required actions
   - If PASS: proceed

4. **Risk Assessment**: Delegate to `trading-risk-manager`
   - Risk Manager reads backtest results + current portfolio
   - Risk Manager writes `risk-assessment.yaml`
   - If REJECTED: update registry, STOP
   - If APPROVED: strategy is ready for human review

5. **Update State**:
   - Update `.crypto/knowledge/registry.yaml`
   - Update `.crypto/pipeline/current-run.yaml`
   - Update `.crypto/BOOTSTRAP.md`
   - If approved: notify that strategy is ready for deployment review
