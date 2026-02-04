# Crypto Trading Team - Upgrade Summary

**Document:** `/Users/toby/.claude/plugins/marketplaces/crypto-trading-team/UPGRADE-PLAN.md`
**Lines:** 1,231
**Completion Time:** ~1 hour detailed analysis + recommendations

---

## Quick Overview

Your crypto-trading-team plugin has **17 agents** orchestrating an impressive strategy development pipeline with **tiered validation (L0-L3)** and **active learning injection**. The architecture is sound, but several gaps limit throughput and operational maturity.

---

## Current State: 17 Agents + 5 Skills

### Agent Breakdown
| Category | Count | Status |
|----------|-------|--------|
| Documented agents | 11 | Complete specs |
| Undocumented agents | 6 | Need specs created |
| **Total** | **17** | **Partial coverage** |

**Undocumented (blocking):**
- trading-feedback
- trading-strategy-researcher
- trading-junior-maverick
- trading-order-executor
- trading-strategy-mutator
- (1 more unclear)

### Skills Inventory
| Skill | Status | Trigger |
|-------|--------|---------|
| pipeline | Complete | "run pipeline" |
| evaluate | Complete | "evaluate strategy" |
| init | Complete | "init" |
| risk-check | Complete | "risk-check" |
| meeting | Complete | "meeting" |

---

## Critical Gaps (11 Total)

### Tier: P0 - BLOCKING (Fix First)

**Gap 1: Python REPL Missing from Quant Agents**
- Affects: quant-analyst, ml-engineer, risk-manager, junior-datacurious
- Impact: Can't run sensitivity analyses, model training, Kelly formula calculations
- Fix: Add `python_repl` tool (2 hours)

**Gap 2: LSP Tools Missing from Code Agents**
- Affects: signal-generator, ml-engineer, backtester
- Impact: Can't inspect Freqtrade/sklearn APIs during code generation
- Fix: Add `lsp_hover`, `lsp_diagnostics` (2 hours)

**Gap 3: Six Agents Completely Undocumented**
- Affects: feedback, researcher, maverick, order-executor, mutator
- Impact: Orchestrator tries to delegate to undefined agents
- Fix: Create agent specs with tools + model + role (8 hours)

**P0 Total Effort: 12 hours (1-2 days)**

---

### Tier: P1 - HIGH PRIORITY (Major Workflows)

**Gap 4: Single-Threaded Orchestrator**
- Current: Strategies process one-at-a-time
- Impact: While backtester runs (30+ min), others idle
- Solution: New `parallel-pipeline` skill for 3+ concurrent strategies
- Effort: 8 hours

**Gap 5: No Retry Logic**
- Current: Failed strategy = rejected immediately
- Impact: Marginal strategies (Sharpe 0.42 vs 0.5 threshold) not retried
- Solution: New `adapt-and-retry` skill with parameter variations
- Effort: 6 hours

**Gap 6: Manual Learning Extraction**
- Current: Learnings stored but not auto-extracted from failures
- Impact: Repeated mistakes not prevented
- Solution: Enhance pipeline Phase 14 with auto-extraction
- Effort: 4 hours

**Gap 7: No Paper Trading**
- Current: Strategies pass validation → human approval → ??? → live
- Impact: Missing execution quality validation
- Solution: New `paper-trading` skill (7-day dry run)
- Effort: 10 hours

**P1 Total Effort: 28 hours (3-4 days)**

---

### Tier: P2 - MEDIUM PRIORITY (Integrations)

**Gap 8-11:** Data schema standardization, signal-executor interface, API key management, visualization tools

**P2 Total Effort: 20 hours (2-3 days)**

---

## What You Get After Upgrades

| Metric | Before | After | Week |
|--------|--------|-------|------|
| **Pipeline Throughput** | 1 strategy/day | 3+ parallel/day | Week 4 |
| **L0-L2 Time** | 60+ min | 30+ min | Week 4 |
| **Rejection Rate** | 50% at L0 | 70% at L0 | Week 3 |
| **Marginal Strategies** | Rejected | Auto-retried | Week 3 |
| **Live vs Backtest Gap** | Unknown | <20% (via paper trading) | Week 5 |
| **Learning Coverage** | 30 entries | 60+ entries | Week 6 |

---

## Implementation Roadmap

```
Week 1-2: P0 (12h) - Fix blocking tool gaps + document missing agents
Week 2-3: P1 Early (26h) - Parallel pipeline + auto-retry + learning extraction
Week 3-4: P1 Late (26h) - Paper trading + integration testing
Week 4-5: P2 (22h) - Data schema + signal interface + API management
Week 5-6: E2E Testing & Release (24h)

TOTAL: ~110 hours (~2.5 weeks full-time)
```

---

## Key Recommendations

### Start Here (P0 - Week 1)
1. Add Python REPL tool to 4 quant/ML agents ✓ (2h)
2. Add LSP tools to 3 code-generation agents ✓ (2h)
3. Create specs for 6 missing agents ✓ (8h)

### Quick Win (P1.1 - Week 2)
4. Implement parallel pipeline skill (8h) → 2-3x throughput immediately

### Production Ready (P1.4 - Week 3)
5. Implement paper trading skill (10h) → Know execution quality before live

### Mature System (P2 - Week 4)
6. Standardize data/signal interfaces → Less fragile pipeline

---

## File Locations

**Main Document:**
- `/Users/toby/.claude/plugins/marketplaces/crypto-trading-team/UPGRADE-PLAN.md` (1,231 lines)

**Sections (in UPGRADE-PLAN.md):**
- Executive Summary
- Part 1: Current State Analysis (agent inventory, tool coverage)
- Part 2: Critical Gaps (P0, P1, P2 with detailed explanations)
- Part 3: Prioritized Recommendations (actionable fixes)
- Part 4: New Agent Proposals (optional enhancements)
- Part 5: New Skill Proposals (parallel-pipeline, paper-trading, etc)
- Part 6: Testing Strategy (unit + integration + E2E tests)
- Part 7: Implementation Roadmap (6-week timeline)
- Part 8: Risk Mitigation
- Part 9: Success Criteria (post-upgrade metrics)

---

## Next Steps

1. **Review UPGRADE-PLAN.md** (30 min read)
2. **Prioritize P0** → Start with tool additions (easiest, unblocks everything)
3. **Plan Sprint** → 2-week sprints for P0 + P1
4. **Test Thoroughly** → Use E2E test cases in Part 6
5. **Deploy Progressively** → P0 first, then P1, then P2

---

## Questions Answered in Full Document

- Why do agents need Python REPL?
- How does parallel pipeline avoid state collisions?
- What's the paper trading validation workflow?
- How does learning extraction work?
- How many hours for each upgrade?
- What are the success metrics?
- How to test each upgrade?
- What could go wrong (risk mitigation)?

---

**TL;DR:**
Your system is architecturally excellent but tool-limited and single-threaded. Add Python REPL (4 agents) + LSP tools (3 agents) to unblock quantitative work. Implement parallel-pipeline skill to handle 3+ concurrent strategies. Add paper-trading skill for execution quality validation. Total 6-week effort, 2.5x throughput improvement, production-ready autonomous trading research system.
