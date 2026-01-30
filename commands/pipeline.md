---
description: Run autonomous strategy development pipeline
---

# Trading Strategy Pipeline

Run the full autonomous pipeline from ideation through validated backtest.

## Arguments
- Strategy idea (e.g., "funding rate arbitrage") → use as starting point
- `ml:` prefix (e.g., "ml: 4h BTC direction prediction") → use ML path instead of rule-based
- `continue` → pick next from `.crypto/pipeline/queue.yaml`
- No argument → researcher proposes based on gaps

## Pipeline

### Phase 1: Ideation (Auto)
1. Bootstrap: Read `.crypto/BOOTSTRAP.md`, `.crypto/knowledge/registry.yaml`, `.crypto/knowledge/learnings.md`, `.crypto/config/thresholds.yaml`
2. **Route by type:**
   - **Rule-based** (default): Delegate to `trading-strategy-researcher` → outputs `hypothesis.md` + `parameters.yaml`
   - **ML-based** (`ml:` prefix): Delegate to `trading-ml-engineer` → outputs `ml-spec.yaml`, `features.yaml`, `ml-report.md`, `code/ml_strategy_{name}.py`
3. Delegate to `trading-quant-analyst` → outputs `quant-review.md`. If NOT FEASIBLE → auto-reject.
4. Delegate to `trading-data-collector` → outputs `data-spec.yaml`. If unavailable → auto-reject.

### Phase 2: Validation (Auto)
5. Delegate to `trading-backtester` → outputs `backtest-results/BT-{NNN}.yaml`. Check `.crypto/config/thresholds.yaml`: hard_pass → proceed, hard_fail → reject, marginal → Critic.
6. Delegate to `trading-critic` → outputs `critic-review.md`. REJECT → stop. CONDITIONAL → max 3 revision cycles.
7. Delegate to `trading-risk-manager` → outputs `risk-assessment.yaml`. If limits exceeded → reject.
8. Update `.crypto/knowledge/registry.yaml`, `.crypto/BOOTSTRAP.md`, `.crypto/pipeline/current-run.yaml`.

### Phase 3: Deploy (Human)
9. Present evidence chain to user. Ask: "Deploy to paper trading?"

## Auto-Rejection
- Record in `.crypto/knowledge/strategies/STR-{NNN}/decision.yaml`
- Update registry status to `rejected`
- Extract learning → `.crypto/knowledge/learnings.md`

## Resume
Read `.crypto/pipeline/current-run.yaml` to find active runs and resume from last completed phase.
