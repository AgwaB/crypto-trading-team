---
description: Check current portfolio risk exposure
---

# Portfolio Risk Check

Quick assessment of current portfolio risk status.

## Steps

1. Read `.crypto/BOOTSTRAP.md`, `.crypto/knowledge/registry.yaml`, `.crypto/knowledge/risk-parameters.yaml`
2. For each deployed strategy: read latest `.crypto/knowledge/strategies/STR-{NNN}/live-performance/report-*.yaml`
3. Calculate aggregate:
   - Total capital deployed vs 60% limit
   - Correlated exposure vs 30% limit
   - Current drawdown vs circuit breaker levels
4. Output summary:
```
Portfolio Risk Summary
Total Deployed:     __% / 60% limit
Correlated Exp:     __% / 30% limit
Current DD:         __% / 10% alert
Active Strategies:  __
Circuit Breaker:    INACTIVE / LEVEL N

Per-Strategy:
STR-001 name │ alloc% │ DD% │ status
```
5. Flag WARNING if any limit >80% of threshold
