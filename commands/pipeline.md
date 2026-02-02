---
description: Run autonomous strategy development pipeline with tiered validation
---

# Trading Strategy Pipeline

Run the full autonomous pipeline with tiered validation (L0->L3), insight/feedback pre-checks, and active learning injection.

## Arguments
- Strategy idea (e.g., "funding rate arbitrage") -> use as starting point
- `ml:` prefix (e.g., "ml: 4h BTC direction prediction") -> use ML path
- `meeting` -> run strategy brainstorming meeting first
- `continue` -> pick next from `.crypto/pipeline/queue.yaml`
- No argument -> researcher proposes based on gaps

## Enhanced Pipeline

### Phase 0: Pre-Pipeline
1. Bootstrap: Read `.crypto/BOOTSTRAP.md`, registry, learnings, thresholds, tiered-validation-protocol
2. If `meeting`: Run strategy meeting (Senior + Maverick + DataCurious + Insight)
3. **Insight Check**: Delegate to `trading-insight` -> DUPLICATE/SIMILAR/NOVEL
4. **Feedback Pre-Flight**: Delegate to `trading-feedback` -> CRITICAL/WARNING/INFO

### Phase 1: Ideation (Auto)
5. **Route by type:**
   - **Rule-based** (default): `trading-strategy-researcher` -> `hypothesis.md` + `parameters.yaml`
   - **ML-based** (`ml:` prefix): `trading-ml-engineer` -> `ml-spec.yaml`, `features.yaml`, `ml-report.md`
6. `trading-quant-analyst` -> `quant-review.md`. NOT FEASIBLE -> auto-reject.
7. `trading-data-collector` -> `data-spec.yaml`. Unavailable -> auto-reject.

### Phase 2: Tiered Validation (Auto)
8. **L0** (30s): 6mo, 1 asset. Gate: frequency>10, hit_rate!=50%, IC>0.01. FAIL -> reject.
9. **L1** (5min): 1yr, primary. Gate: Sharpe>0.5, PF>1.0, trades>30. FAIL -> reject.
10. **L2** (30min): 3yr, full sweep. Gate: thresholds.yaml. Self-diagnostics. Marginal -> Critic.
11. **Critic Review**: `trading-critic` -> REJECT/CONDITIONAL/PASS. Max 3 revision cycles.
12. **L3** (60min): 5yr, WF+MC+regime. Gate: 3/5 WF, MC 95% CI+, 2/3 regimes. FAIL -> reject.

### Phase 3: Deploy (Human)
13. `trading-risk-manager` -> alpha_corr < 0.7 check. Risk exceeded -> reject.
14. Update registry, BOOTSTRAP, pipeline state. Extract learnings.
15. Present evidence chain. Ask: "Deploy to paper trading?"

## Auto-Rejection
- Record in `decision.yaml` with tier that rejected
- Extract learning via `trading-feedback`
- Update `failure-taxonomy.yaml` with root cause

## Resume
Read `.crypto/pipeline/current-run.yaml` to find active runs and resume from last completed tier.
