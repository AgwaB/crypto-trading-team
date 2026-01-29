---
description: "Dashboard: strategy status overview"
---

# Crypto Status Dashboard

Show a clear overview of all strategies and their current status.

## Steps

1. Read `.crypto/BOOTSTRAP.md` and `.crypto/knowledge/registry.yaml`
2. Read `.crypto/knowledge/risk-parameters.yaml` for portfolio state
3. If ralph1 loop is active, read `.crypto/ralph1-state.md` for loop progress

4. Output dashboard in this exact format:

```
═══════════════════════════════════════════════════════════
 CRYPTO TRADING TEAM — STATUS DASHBOARD
═══════════════════════════════════════════════════════════

Portfolio
  Capital Deployed:  __% / 60% limit
  Drawdown:          __% / 10% alert
  Circuit Breaker:   INACTIVE

Pipeline
  In Progress:  __    Queued:  __

───────────────────────────────────────────────────────────
 VALIDATED (Phase 1-2 Passed — Ready for Deployment Review)
───────────────────────────────────────────────────────────
 ID       │ Name                    │ Sharpe │ MaxDD  │ Status
 STR-001  │ Funding Rate Arb        │  1.82  │ -8.3%  │ awaiting_human
 STR-004  │ Momentum Breakout       │  1.45  │ -12.1% │ paper_trading
 ...

───────────────────────────────────────────────────────────
 DEPLOYED (Live / Paper)
───────────────────────────────────────────────────────────
 ID       │ Name                    │ Alloc% │ P&L    │ Status
 STR-004  │ Momentum Breakout       │ 15%    │ +3.2%  │ paper_trading
 ...

───────────────────────────────────────────────────────────
 REJECTED (with learning extracted)
───────────────────────────────────────────────────────────
 ID       │ Name                    │ Reason              │ Learning
 STR-002  │ Grid Trading BTC        │ hard_fail: DD>40%   │ Grid fails in trending markets
 STR-003  │ Mean Reversion ALT      │ critic: overfitting │ OOS ratio too low on alts
 ...

───────────────────────────────────────────────────────────
 IN PIPELINE (currently being evaluated)
───────────────────────────────────────────────────────────
 ID       │ Name                    │ Phase               │ Next Step
 STR-005  │ Volatility Squeeze      │ backtesting          │ Awaiting BT results
 ...

───────────────────────────────────────────────────────────
 TOTALS
───────────────────────────────────────────────────────────
 Validated: __   Rejected: __   Deployed: __   In Pipeline: __   Total: __
═══════════════════════════════════════════════════════════
```

5. For each strategy, read the relevant files:
   - Validated: read `decision.yaml` or `risk-assessment.yaml` for key metrics
   - Rejected: read `decision.yaml` for rejection reason and learning
   - Deployed: read latest `live-performance/report-*.yaml` for P&L
   - In Pipeline: read the last completed phase file to determine current step

6. If no strategies exist yet, show:
```
No strategies evaluated yet. Run /crypto:pipeline or /crypto:ralph1 to start.
```

7. If ralph1 loop is active, append:
```
Ralph1 Loop: ACTIVE — Iteration __ | Found: __ | Rejected: __
```
