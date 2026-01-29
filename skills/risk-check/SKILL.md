---
name: trading-risk-check
description: "Quick portfolio risk check. Use when the user asks about current risk exposure, portfolio health, or before any deployment decision. Shows current capital allocation and risk metrics."
user-invocable: true
argument-hint: "[detailed | summary]"
model: sonnet
---

# Portfolio Risk Check

Quick assessment of current portfolio risk status.

## Steps

1. **Read Current State**:
   - `.crypto/BOOTSTRAP.md` for overview
   - `.crypto/knowledge/registry.yaml` for deployed strategies
   - `.crypto/knowledge/risk-parameters.yaml` for limits

2. **For Each Deployed Strategy**:
   - Read latest `live-performance/report-*.yaml`
   - Check current allocation vs limit
   - Check drawdown vs circuit breaker levels

3. **Portfolio Aggregate**:
   - Total capital deployed (vs 60% limit)
   - Correlated exposure (vs 30% limit)
   - Current portfolio drawdown (vs circuit breaker levels)
   - Number of active strategies

4. **Output Summary**:
   ```
   Portfolio Risk Summary
   ═══════════════════════
   Total Deployed:     34% / 60% limit    ✅
   Correlated Exp:     12% / 30% limit    ✅
   Current DD:         2.3% / 10% alert   ✅
   Active Strategies:  1
   Circuit Breaker:    INACTIVE

   Per-Strategy:
   STR-001 Funding Arb  │ 34% alloc │ DD: 2.3% │ Status: healthy
   ```

5. **Alerts**: If any limit >80% of threshold, flag as WARNING
