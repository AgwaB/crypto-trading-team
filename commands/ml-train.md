---
description: "Develop ML-based trading strategy (feature engineering → model training → validation)"
argument-hint: "[TARGET_DESCRIPTION]"
---

# ML Strategy Development Pipeline

Develop a machine learning-based trading strategy through the full ML lifecycle.

## Arguments
- Target description (e.g., "4h BTC direction using momentum features") → use as starting point
- No argument → ML Engineer decides based on gaps in registry and learnings

## Steps

1. **Bootstrap**: Read `.crypto/BOOTSTRAP.md`, `.crypto/knowledge/registry.yaml`, `.crypto/knowledge/learnings.md`, `.crypto/config/thresholds.yaml`, `.crypto/knowledge/data-catalog/sources.yaml`

2. **Delegate to `trading-ml-engineer`**:
   - Feature engineering from available data
   - Model selection and training with walk-forward validation
   - Overfitting analysis
   - Outputs: `ml-spec.yaml`, `features.yaml`, `ml-report.md`, `code/ml_strategy_{name}.py`
   - Write to `.crypto/knowledge/strategies/STR-{NNN}/`

3. **Delegate to `trading-data-collector`** (if new data needed):
   - Source additional data per ML Engineer's requirements
   - Output: `data-spec.yaml`

4. **Delegate to `trading-backtester`**:
   - Run standard robustness tests on ML signals
   - Walk-forward, fee stress, Monte Carlo, market regime
   - Output: `backtest-results/BT-{NNN}.yaml`

5. **Gate check** against `.crypto/config/thresholds.yaml`:
   - hard_pass → proceed
   - hard_fail → reject, extract ML-specific learnings
   - marginal → Critic review

6. **Delegate to `trading-critic`** (if marginal):
   - Focus on overfitting risk, data leakage, feature stability
   - Output: `critic-review.md`

7. **Delegate to `trading-risk-manager`**:
   - Portfolio fit check for ML strategy
   - Output: `risk-assessment.yaml`

8. **Record**: Update registry.yaml, BOOTSTRAP.md, learnings.md

## ML-Specific Learnings to Capture
- Which features worked/didn't and why
- Model architecture that performed best for this target
- Optimal walk-forward window sizes
- Overfitting indicators discovered
- Data quality issues encountered
