# Agent Tool Upgrade Specifications
## Crypto Trading Team — Enhanced Capabilities

**Document Version**: 1.0
**Last Updated**: 2026-02-05
**Status**: Ready for Implementation

---

## Overview

This document specifies tool enhancements for nine agents in the crypto-trading-team. The upgrades enable:

- **Python REPL**: Statistical calculations, model prototyping, portfolio math
- **LSP Tools**: Code validation, syntax verification, definition lookup
- **Visualization**: Chart generation, visual evidence capture, exploratory plots

Each agent upgrade is designed to enhance existing responsibilities without changing core role definitions.

---

## Table of Contents

1. [Python REPL Upgrades](#python-repl-upgrades) (4 agents)
2. [LSP Tools Upgrades](#lsp-tools-upgrades) (3 agents)
3. [Visualization Upgrades](#visualization-upgrades) (3 agents)
4. [Implementation Guide](#implementation-guide)

---

## PYTHON REPL UPGRADES

### 1. Quantitative Analyst (`quantitative-analyst`)

**Current Tools**: Read, Grep, Glob, Bash
**Model**: opus
**Proposed Addition**: Python REPL

#### Rationale

The Quantitative Analyst performs parameter sensitivity analysis, overfitting detection, and regime classification. These workflows require:

- Statistical calculations (parameter variance, correlation analysis)
- Numeric computations (degrees of freedom ratios, edge calculations)
- Regime detection math (ADX, volatility clustering, correlation breakdowns)

Python REPL enables in-session calculations without shell roundtrips, improving verification accuracy and iteration speed.

#### Current Responsibilities Impacted

| Responsibility | How REPL Helps |
|---|---|
| **Sensitivity Analysis** | Calculate parameter variations (+/-20%) on live data |
| **Overfitting Detection** | Compute IS vs OOS gap ratios, statistical significance |
| **Edge Viability** | Calculate gross edge, costs, net edge with precision |
| **Parameter Count Validation** | Compute degrees of freedom ratios (parameters / data_points) |
| **Regime Classification** | Calculate ADX, volatility clustering, correlation matrices |

#### Example Use Cases

**Use Case 1: Parameter Sensitivity Analysis**
```python
# Quant receives strategy with parameters:
# RSI period=14, threshold=30, stop_loss=2%
# Needs to test +/-20% variations

parameters = {
    'rsi_period': 14,
    'threshold': 30,
    'stop_loss': 0.02
}

variations = {}
for param, value in parameters.items():
    lower = value * 0.8
    upper = value * 1.2
    variations[param] = {
        'original': value,
        'lower': lower,
        'upper': upper,
        'range': upper - lower
    }
# Results show which parameters destroy profitability when varied
```

**Use Case 2: Degrees of Freedom Check**
```python
# Strategy has 6 parameters, tested on 2 years of daily data
parameters = 6
data_points = 252 * 2  # ~504 trading days
dof_ratio = parameters / data_points
# 6 / 504 = 0.012 (excellent, far below 1:50 threshold)
# Passes parameter count validation
```

**Use Case 3: Edge Calculation**
```python
win_rate = 0.55
avg_win_bps = 50
avg_loss_bps = 40
edge = (win_rate * avg_win_bps) - ((1 - win_rate) * avg_loss_bps)
# edge = (0.55 * 50) - (0.45 * 40) = 27.5 - 18 = 9.5 bps
# After fees (5 bps), net edge = 4.5 bps (REJECTED: < 5 bps minimum)
```

**Use Case 4: Correlation Matrix Analysis**
```python
# Quant needs to assess regime dependency by computing
# correlations between strategy returns and market regimes
import numpy as np

returns = np.array([...])  # strategy returns
atr_volatility = np.array([...])  # ATR-based volatility
correlation = np.corrcoef(returns, atr_volatility)[0, 1]
# If correlation < 0.3, strategy is regime-independent (good)
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/quantitative-analyst.md`, update the YAML frontmatter:

```yaml
---
name: trading-quant-analyst
description: "Validates trading strategies with statistical rigor. Use when checking indicator math, detecting overfitting, running sensitivity analysis, or classifying market regimes. Provides quantitative feasibility reports."
tools: Read, Grep, Glob, Bash, PythonREPL
model: opus
---
```

**Access Pattern in Prompts**

When Quant Analyst needs to run calculations, they should use Python REPL:

```
"I need to validate parameter sensitivity. Let me use Python to calculate variations..."
[Python code execution]
"Sensitivity analysis complete. All parameters survive ±20% variation."
```

**Data Sources**

- Backtest results (CSV/JSON files read via Read tool)
- Strategy parameters from parameters.yaml
- Historical market data from data catalog

**Output Integration**

Calculation results are embedded in:
- `quant-review.md` — Numeric calculations with justification
- Risk reports — Portfolio correlation matrices
- Sensitivity analysis tables

---

### 2. ML Engineer (`ml-engineer`)

**Current Tools**: Read, Write, Edit, Bash, Glob, Grep
**Model**: opus
**Proposed Addition**: Python REPL

#### Rationale

The ML Engineer builds machine learning models with:
- Feature engineering (80-120 candidate features)
- Model training (XGBoost, LightGBM, LSTM)
- Walk-forward validation (5+ splits)
- Overfitting audits (feature importance stability, IS/OOS gap)

Python REPL enables rapid prototyping, feature testing, and model experimentation without file I/O bottlenecks.

#### Current Responsibilities Impacted

| Responsibility | How REPL Helps |
|---|---|
| **Feature Engineering** | Test feature calculations on live data snippets |
| **Feature Selection** | Run correlation filters, feature importance ranking |
| **Model Training** | Prototype models before full pipeline execution |
| **Walk-Forward Setup** | Validate fold creation, gap verification |
| **Overfitting Audit** | Calculate IS/OOS Sharpe ratio gap, feature stability |
| **Baseline Comparison** | Quickly implement and test naive baselines |

#### Example Use Cases

**Use Case 1: Feature Testing**
```python
import pandas as pd
import numpy as np

# Test RSI calculation on price snippet
close = pd.Series([100, 101, 99, 102, 101, 100, 98, 99])

# RSI calculation
deltas = close.diff()
seed = deltas[:1]
up = seed[seed >= 0].sum()
down = -seed[seed < 0].sum()

rs = up / down if down > 0 else 0
rsi = 100 - (100 / (1 + rs))
print(f"RSI value: {rsi:.2f}")  # Verify formula is correct
```

**Use Case 2: Feature Importance Ranking**
```python
# After XGBoost training, analyze feature stability across folds
import pandas as pd

fold_importances = [
    {'rsi_14_zscore': 0.12, 'atr_ratio': 0.10, 'vol_zscore': 0.08, ...},
    {'rsi_14_zscore': 0.11, 'atr_ratio': 0.11, 'vol_zscore': 0.09, ...},
    {'rsi_14_zscore': 0.13, 'atr_ratio': 0.09, 'vol_zscore': 0.07, ...},
]

df = pd.DataFrame(fold_importances)
stability = df.std() / df.mean()  # Lower = more stable
print(stability[stability < 0.15])  # Top stable features
```

**Use Case 3: Walk-Forward Fold Verification**
```python
import pandas as pd
from datetime import datetime, timedelta

data_length = 1000
train_window = 252  # 1 year
test_window = 63    # 3 months
gap = 1

splits = []
for i in range(0, data_length - train_window - test_window, test_window):
    train_start = i
    train_end = i + train_window
    test_start = train_end + gap
    test_end = test_start + test_window

    splits.append({
        'fold': len(splits),
        'train_size': train_window,
        'gap': gap,
        'test_size': test_window,
        'no_overlap': True
    })

print(f"Created {len(splits)} folds with zero overlap")
```

**Use Case 4: Baseline Model Test**
```python
# Quick baseline: moving average crossover strategy
import numpy as np

close = np.array([...])
sma_20 = pd.Series(close).rolling(20).mean()
sma_50 = pd.Series(close).rolling(50).mean()

signals = np.where(sma_20 > sma_50, 1, 0)
returns = np.diff(np.log(close))
baseline_sharpe = np.mean(returns[50:]) / np.std(returns[50:]) * np.sqrt(252)
print(f"Baseline Sharpe: {baseline_sharpe:.2f}")
# ML model must beat this
```

**Use Case 5: Class Imbalance Analysis**
```python
import numpy as np

# Check target variable distribution
target = np.array([...])  # e.g., [1, 0, 1, 1, 0, 2, ...]
unique, counts = np.unique(target, return_counts=True)
class_balance = counts / len(target)

print("Class distribution:")
for cls, pct in zip(unique, class_balance):
    print(f"  Class {cls}: {pct:.1%}")

# Alert if imbalanced
if max(class_balance) > 0.6:
    print("WARNING: Class imbalance > 60%. May need SMOTE or weighting.")
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/ml-engineer.md`, update the YAML frontmatter:

```yaml
---
name: trading-ml-engineer
description: "ML engineer specializing in crypto trading model development: feature engineering, model training, walk-forward validation, and Freqtrade integration. Builds data-driven strategies using XGBoost, LightGBM, LSTM, and ensemble methods."
model: opus
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - PythonREPL
---
```

**Libraries Available**

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import TimeSeriesSplit
import xgboost as xgb
import lightgbm as lgb
from scipy import stats
```

**Typical Workflow**

```
1. Read raw data → Load into REPL
2. Engineer features → Test on snippet via REPL
3. Select features → Rank via REPL
4. Setup validation → Create folds via REPL (verify with print)
5. Train model → Use Bash (long-running)
6. Analyze results → Aggregate metrics via REPL
7. Write outputs → Use Write/Edit tools
```

**Data Loading Pattern**

```python
# Quant Analyst provides data via CSV/JSON
import pandas as pd
data = pd.read_csv('/path/to/data.csv', index_col='date', parse_dates=True)
print(data.info())
print(data.describe())
# Now ready for feature engineering
```

---

### 3. Junior DataCurious (`junior-datacurious`)

**Current Tools**: Read, Grep, Glob, Bash
**Model**: haiku
**Proposed Addition**: Python REPL

#### Rationale

Junior DataCurious finds anomalies and proposes features through data exploration. Their work requires:
- Computing statistics (percentiles, autocorrelation, correlations)
- Anomaly detection (Z-scores, distribution analysis)
- Feature derivation testing (ratio features, lag features)

Python REPL accelerates exploratory data analysis without shell overhead.

#### Current Responsibilities Impacted

| Responsibility | How REPL Helps |
|---|---|
| **Anomaly Detection** | Calculate Z-scores, identify outliers, test statistical significance |
| **Correlation Analysis** | Compute correlation matrices, test spurious relationships |
| **Distribution Analysis** | Calculate skewness, kurtosis, test for normality |
| **Feature Derivation** | Test ratio features, lag features on live data |
| **Data Questions** | Answer "what's the autocorrelation at lag 8?" with code |
| **Exploratory Queries** | Check day-of-week effects, time-of-day patterns |

#### Example Use Cases

**Use Case 1: Anomaly Detection via Z-Score**
```python
import numpy as np
from scipy import stats

# Volume analysis: find unusual volume spikes
volume = np.array([100, 95, 105, 98, 102, 450, 99, 101])  # 450 is spike

z_scores = np.abs(stats.zscore(volume))
anomalies = np.where(z_scores > 3)[0]

print(f"Found {len(anomalies)} anomalies (>3 sigma)")
for idx in anomalies:
    print(f"  Index {idx}: {volume[idx]} (z-score: {z_scores[idx]:.2f})")
```

**Use Case 2: Autocorrelation at Specific Lag**
```python
import numpy as np
from pandas.plotting import autocorrelation_plot

# Check if 8-hour volume spikes repeat
returns = np.array([...])  # hourly returns
acf_lag_8 = np.corrcoef(returns[:-8], returns[8:])[0, 1]
print(f"Autocorrelation at lag 8h: {acf_lag_8:.3f}")

# If > 0.3, there's a repeating pattern worth investigating
if abs(acf_lag_8) > 0.3:
    print("ANOMALY: Strong autocorrelation pattern found!")
```

**Use Case 3: Day-of-Week Effect Analysis**
```python
import pandas as pd
import numpy as np

# Check if returns differ by day of week
data = pd.read_csv('returns.csv', index_col='date', parse_dates=True)
data['day_of_week'] = data.index.dayofweek
data['day_name'] = data.index.day_name()

returns_by_day = data.groupby('day_name')['return'].agg(['mean', 'std', 'count'])
print(returns_by_day)

# Statistical test: ANOVA
from scipy.stats import f_oneway
groups = [data[data['day_of_week'] == i]['return'].values for i in range(5)]
f_stat, p_value = f_oneway(*groups)
print(f"Day-of-week effect p-value: {p_value:.4f}")
if p_value < 0.05:
    print("ANOMALY: Significant day-of-week effect detected!")
```

**Use Case 4: Feature Derivation Test**
```python
import pandas as pd

# Test ratio feature: volume_tuesday / volume_friday
data = pd.read_csv('data.csv', index_col='date', parse_dates=True)
data['day_name'] = data.index.day_name()

tuesday_vol = data[data['day_name'] == 'Tuesday']['volume'].mean()
friday_vol = data[data['day_name'] == 'Friday']['volume'].mean()
ratio = tuesday_vol / friday_vol

print(f"Tuesday volume / Friday volume ratio: {ratio:.3f}")
if abs(ratio - 1.0) > 0.2:
    print("FEATURE IDEA: This ratio might capture day-of-week behavior")
```

**Use Case 5: Distribution Analysis**
```python
import numpy as np
from scipy.stats import skew, kurtosis

returns = np.array([...])

skewness = skew(returns)
kurt = kurtosis(returns)
mean_return = np.mean(returns)
std_return = np.std(returns)

print(f"Return distribution:")
print(f"  Mean: {mean_return:.4f}")
print(f"  Std: {std_return:.4f}")
print(f"  Skewness: {skewness:.3f}")
print(f"  Kurtosis: {kurt:.3f}")

if skewness < -0.5:
    print("ANOMALY: Negatively skewed returns - left tail risk")
if kurt > 3:
    print("ANOMALY: Fat tails - expect larger drawdowns")
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/junior-datacurious.md`, update the YAML frontmatter:

```yaml
---
name: trading-junior-datacurious
description: "Data anomaly hunter for strategy brainstorming meetings. Finds weird patterns in data, proposes derived features, and asks questions nobody thought to ask. Data-first approach rather than theory-first."
tools: Read, Grep, Glob, Bash, PythonREPL
model: haiku
---
```

**Key Behaviors with REPL**

Junior DataCurious should use REPL for:
1. Quick calculations they report directly
2. Exploratory "What if..." questions
3. Statistical tests to validate observations
4. Feature derivation testing

**Example Output Pattern**

```
ANOMALY: BTC volume spikes every ~8 hours
[Runs Python REPL to calculate autocorrelation]
"I calculated the autocorrelation at 8-hour lag: 0.42
(p-value: 0.003). That's statistically significant!"

FEATURE IDEA: Volume ratio at 8h intervals
[Runs code to test feature on data snippet]
"Created feature vol_8h_ratio. Mean=1.15, shows consistent pattern."
```

---

### 4. Risk Manager (`risk-manager`)

**Current Tools**: Read, Grep, Glob, Bash
**Model**: opus
**Proposed Addition**: Python REPL

#### Rationale

The Risk Manager calculates position sizing, drawdown analysis, and portfolio correlation. These quantitative tasks are ideal for Python REPL:

- Position sizing calculations (Kelly Criterion, fractional sizing, ATR-based)
- Portfolio math (correlation matrices, drawdown projections)
- Monte Carlo simulations (10,000+ iterations for confidence intervals)
- Worst-case scenario analysis

#### Current Responsibilities Impacted

| Responsibility | How REPL Helps |
|---|---|
| **Position Sizing** | Calculate Kelly Criterion, fractional sizing formulas |
| **Portfolio Correlation** | Compute strategy correlation matrix, exposure analysis |
| **Drawdown Circuits** | Calculate DD thresholds, escalation triggers |
| **Monte Carlo Analysis** | Run simulations for confidence intervals |
| **Worst-Case Analysis** | Model portfolio behavior under stress scenarios |
| **Kelly Criterion Math** | Calculate optimal position sizing precisely |

#### Example Use Cases

**Use Case 1: Kelly Criterion Calculation**
```python
# Kelly Criterion: f* = (p*b - q) / b
# where: p = win rate, b = win/loss ratio, q = 1-p

win_rate = 0.55
avg_win = 50  # bps
avg_loss = 40  # bps

b = avg_win / avg_loss  # win/loss ratio = 1.25
q = 1 - win_rate  # 0.45

kelly_fraction = (win_rate * b - q) / b
kelly_fraction = (0.55 * 1.25 - 0.45) / 1.25
kelly_fraction = (0.6875 - 0.45) / 1.25
kelly_fraction = 0.1700  # 17% of capital per trade

print(f"Kelly fraction: {kelly_fraction:.2%}")
print(f"Conservative (Kelly/2): {kelly_fraction/2:.2%}")
```

**Use Case 2: Portfolio Correlation Matrix**
```python
import pandas as pd
import numpy as np

# Returns from 3 deployed strategies
str1_returns = np.array([...])  # Strategy 1 returns
str2_returns = np.array([...])  # Strategy 2 returns
str3_returns = np.array([...])  # Strategy 3 returns

df = pd.DataFrame({
    'STR-001': str1_returns,
    'STR-002': str2_returns,
    'STR-003': str3_returns
})

correlation_matrix = df.corr()
print("Portfolio Correlation Matrix:")
print(correlation_matrix)

# Check if correlated (>0.7 = high correlation = bad)
for i in range(len(correlation_matrix)):
    for j in range(i+1, len(correlation_matrix)):
        corr = correlation_matrix.iloc[i, j]
        if abs(corr) > 0.7:
            print(f"WARNING: {correlation_matrix.index[i]} <-> "
                  f"{correlation_matrix.columns[j]} correlation = {corr:.2f}")
```

**Use Case 3: Portfolio Drawdown Projection**
```python
import numpy as np

# Simulate portfolio drawdowns under stress
portfolio_returns = np.array([...])  # Daily portfolio returns
cumulative = np.cumprod(1 + portfolio_returns)

# Calculate running maximum and drawdown
running_max = np.maximum.accumulate(cumulative)
drawdown = (cumulative - running_max) / running_max

max_dd = np.min(drawdown)
current_dd = drawdown[-1]

print(f"Maximum historical DD: {max_dd:.2%}")
print(f"Current DD: {current_dd:.2%}")

# Circuit breaker thresholds
if current_dd < -0.10:
    print("ALERT: 10% DD threshold crossed")
elif current_dd < -0.15:
    print("ALERT: 15% DD threshold crossed → Halt new entries")
elif current_dd < -0.20:
    print("ALERT: 20% DD threshold crossed → Close 50% of positions")
elif current_dd < -0.25:
    print("EMERGENCY: 25% DD threshold crossed → KILL SWITCH")
```

**Use Case 4: Monte Carlo Confidence Interval**
```python
import numpy as np

# Monte Carlo simulation for position sizing
win_rate = 0.55
avg_win = 50
avg_loss = 40
num_trades = 100
simulations = 10000

np.random.seed(42)
results = []

for _ in range(simulations):
    trades = np.random.binomial(1, win_rate, num_trades)
    wins = trades.sum()
    losses = num_trades - wins
    pnl = wins * avg_win - losses * avg_loss
    results.append(pnl)

results = np.array(results)
ci_95_lower = np.percentile(results, 2.5)
ci_95_upper = np.percentile(results, 97.5)

print(f"95% Confidence Interval for 100-trade simulation:")
print(f"  Lower bound (2.5%): {ci_95_lower:.0f} bps")
print(f"  Upper bound (97.5%): {ci_95_upper:.0f} bps")
print(f"  Probability of positive return: {(results > 0).sum() / simulations:.1%}")
```

**Use Case 5: Exposure Limits Calculation**
```python
import numpy as np

# Portfolio constraints
total_capital = 1_000_000  # $1M
max_total_deployment = 0.60  # 60% max
max_correlated_exposure = 0.30  # 30% max per correlated group

# Current positions
positions = {
    'STR-001': {'size': 200_000, 'correlation_group': 'longish'},
    'STR-002': {'size': 150_000, 'correlation_group': 'shortish'},
    'STR-003': {'size': 100_000, 'correlation_group': 'longish'},
}

total_deployed = sum(p['size'] for p in positions.values())
pct_deployed = total_deployed / total_capital

# Check constraints
print(f"Total deployed: {total_deployed:,} ({pct_deployed:.1%})")
print(f"Within 60% limit: {total_deployed / total_capital <= 0.60}")

# Check correlation groups
for group in ['longish', 'shortish']:
    group_exposure = sum(p['size'] for p in positions.values()
                        if p['correlation_group'] == group)
    group_pct = group_exposure / total_capital
    print(f"{group} exposure: {group_pct:.1%} (limit: 30%)")
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/risk-manager.md`, update the YAML frontmatter:

```yaml
---
name: trading-risk-manager
description: "Enforces portfolio-level risk management. Use when assessing position sizing, drawdown limits, portfolio correlation, or executing emergency kill switches. The only agent with authority to force-close all positions."
tools: Read, Grep, Glob, Bash, PythonREPL
model: opus
---
```

**Standard Libraries**

```python
import numpy as np
import pandas as pd
from scipy.stats import norm, binom
```

**Output Integration**

Risk calculations flow into `risk-assessment.yaml`:

```yaml
position_sizing:
  method: kelly_criterion
  calculation: |
    Kelly fraction = (p*b - q) / b = 0.17
    Conservative (f*/2) = 0.085 = 8.5% of capital per trade
  risk_per_trade: 0.015  # 1.5% capital at risk
  max_position_pct: 0.085
```

---

## LSP TOOLS UPGRADES

### 1. Signal Generator (`signal-generator`)

**Current Tools**: Read, Write, Edit, Bash, Glob, Grep
**Model**: sonnet
**Proposed Addition**: LSP Tools (hover, goto_definition, find_references, diagnostics)

#### Rationale

The Signal Generator produces production-ready Freqtrade strategy code. LSP tools enable:

- **Code Validation**: Verify syntax before deployment
- **Type Checking**: Ensure type hints are correct
- **Import Verification**: Confirm all dependencies are available
- **Definition Lookup**: Navigate code without manual searching
- **Error Detection**: Catch runtime issues before backtesting

#### Current Responsibilities Impacted

| Responsibility | How LSP Helps |
|---|---|
| **Code Generation** | Generate code and verify with LSP diagnostics |
| **Code Quality** | Check type hints and syntax with hover/diagnostics |
| **Risk Integration** | Verify risk parameters are correctly imported |
| **Verification** | Run syntax check before claiming verification pass |

#### Example Use Cases

**Use Case 1: Post-Generation Syntax Verification**
```
Signal Generator generates: strategy_rsi_mean_reversion.py

[Uses LSP diagnostics]
✓ No syntax errors
✓ All imports resolvable
✓ Type hints valid
✓ Ready for testing
```

**Use Case 2: Type Hint Validation**
```python
# Generated code:
def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
    """Calculate indicators."""
    dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)
    return dataframe

[Uses LSP hover on 'DataFrame']
DataFrame is imported from freqtrade.persistence.Trade
✓ Type hint is correct
```

**Use Case 3: Dependency Verification**
```python
# Generated imports:
from freqtrade.strategy import IStrategy
from freqtrade.persistence import Trade
import talib as ta

[Uses LSP find_references on 'IStrategy']
✓ IStrategy found in 3 files
✓ All usage patterns validated
```

**Use Case 4: Definition Lookup**
```
Signal Generator needs to verify 'stoploss' parameter format.
[Uses LSP goto_definition on 'stoploss']
→ Found in IStrategy base class
→ Accepts float between -1 and 0
→ Code uses -0.05 ✓
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/signal-generator.md`, update the YAML frontmatter:

```yaml
---
name: trading-signal-generator
description: "Converts approved trading strategies into executable Freqtrade strategy code. Use when generating production-ready strategy classes from validated hypotheses and backtest results."
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - LSPHover
  - LSPGotoDefinition
  - LSPFindReferences
  - LSPDiagnostics
model: sonnet
---
```

**Verification Protocol**

After code generation:

```
1. [Uses LSPDiagnostics]
   Check for errors, warnings, hints

2. [Uses LSPHover on critical sections]
   - Verify strategy parameter types
   - Check indicator function signatures
   - Confirm return types

3. [Uses LSPFindReferences on base classes]
   - Ensure method overrides match IStrategy
   - Check parameter names against docs

4. [Run Python syntax check via Bash]
   python -c "import strategy_name"

If all pass → Code is production-ready
```

**Typical Workflow**

```
Signal Generator (you) → Generate code
                      → LSPDiagnostics (find issues)
                      → Fix issues via Edit
                      → LSPDiagnostics (verify fixed)
                      → Bash: syntax check
                      → Done: "Code verified and ready"
```

---

### 2. ML Engineer (`ml-engineer`)

**Current Tools**: Read, Write, Edit, Bash, Glob, Grep
**Model**: opus
**Proposed Addition**: LSP Tools (hover, goto_definition, find_references, diagnostics)

#### Rationale

The ML Engineer produces model code, feature engineering scripts, and Freqtrade integration code. LSP tools ensure:

- **Code Quality**: Validate Python syntax before execution
- **Type Safety**: Verify ML library function signatures
- **Import Resolution**: Confirm sklearn, xgboost, pytorch imports exist
- **Integration Testing**: Verify model code integrates with Freqtrade interface

#### Current Responsibilities Impacted

| Responsibility | How LSP Helps |
|---|---|
| **Feature Engineering** | Validate feature calculation scripts with diagnostics |
| **Model Training** | Verify model library calls and signatures |
| **Code Generation** | Produce Freqtrade-compatible code with LSP validation |
| **Integration Testing** | Verify output files work with standard pipeline |

#### Example Use Cases

**Use Case 1: Model Code Validation**
```python
# ML Engineer writes model training code:
import xgboost as xgb
from sklearn.model_selection import TimeSeriesSplit

model = xgb.XGBClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1
)

[Uses LSPDiagnostics]
✓ xgboost module imported
✓ XGBClassifier exists
✓ Parameters are valid
✓ Code ready to execute
```

**Use Case 2: Feature Engineering Code Check**
```python
# ML Engineer validates feature calculations:
import pandas as pd
import talib

def calculate_rsi(close, period=14):
    return talib.RSI(close, timeperiod=period)

[Uses LSPHover on 'talib.RSI']
→ Found: function RSI(close, timeperiod=14)
→ Returns: ndarray
→ Code matches signature ✓
```

**Use Case 3: Freqtrade Interface Validation**
```python
# ML Engineer generates Freqtrade strategy:
from freqtrade.strategy import IStrategy

class MLStrategy(IStrategy):
    def populate_indicators(self, dataframe, metadata):
        # ML predictions
        pass

[Uses LSPFindReferences on 'populate_indicators']
→ Found 8 references in IStrategy base class
→ Signature matches ✓
→ Return type is DataFrame ✓
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/ml-engineer.md`, update the YAML frontmatter:

```yaml
---
name: trading-ml-engineer
description: "ML engineer specializing in crypto trading model development: feature engineering, model training, walk-forward validation, and Freqtrade integration. Builds data-driven strategies using XGBoost, LightGBM, LSTM, and ensemble methods."
model: opus
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - LSPHover
  - LSPGotoDefinition
  - LSPFindReferences
  - LSPDiagnostics
---
```

**Verification for ML Code**

```
ML Engineer workflow:

1. Write feature engineering code
   [LSPDiagnostics] → Check syntax, imports
   [LSPHover] → Verify library function signatures

2. Write model training code
   [LSPDiagnostics] → Check syntax
   [LSPFindReferences] → Verify model API compatibility

3. Generate Freqtrade strategy
   [LSPFindReferences on IStrategy] → Ensure interface match
   [LSPDiagnostics] → Final syntax check

4. Test with Bash
   python -c "from strategy_name import MLStrategy"

5. Ready to hand off to Backtester
```

---

### 3. Backtester (`backtester`)

**Current Tools**: Read, Write, Edit, Bash, Glob, Grep
**Model**: sonnet
**Proposed Addition**: LSP Tools (hover, goto_definition, find_references, diagnostics)

#### Rationale

The Backtester implements strategies in VectorBT and Freqtrade. LSP tools enable:

- **Strategy Code Validation**: Verify VectorBT and Freqtrade strategy classes before execution
- **Framework Compatibility**: Ensure strategy code matches framework APIs
- **Error Prevention**: Catch syntax errors before 10-minute backtests
- **Rapid Iteration**: Fix code issues quickly via hover/diagnostics

#### Current Responsibilities Impacted

| Responsibility | How LSP Helps |
|---|---|
| **Strategy Implementation** | Validate VectorBT/Freqtrade code before execution |
| **Robustness Testing** | Verify test harness code with diagnostics |
| **Result Reporting** | Validate result-writing code |

#### Example Use Cases

**Use Case 1: Strategy Class Validation**
```python
# Backtester implements strategy in Freqtrade:
class RSIMeanReversionStrategy(IStrategy):
    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=self.rsi_period)
        return dataframe

[Uses LSPDiagnostics]
✓ Class inherits from IStrategy
✓ Method signature matches base class
✓ Returns DataFrame
✓ Ready for backtesting
```

**Use Case 2: VectorBT Code Validation**
```python
# Backtester writes VectorBT parameter sweep:
import vectorbt as vbt

price_history = vbt.YFData.download('BTC-USD')
indicators = price_history.high.ta.rsi(vbt.param.rsi_period)

[Uses LSPHover on 'vbt.param.rsi_period']
→ Found: vbt.param meta-variable for vectorized backtesting
→ Usage is correct ✓
```

**Use Case 3: Framework API Check**
```python
# Backtester needs to verify walk-forward loop:
from freqtrade.data.dataprovider import DataProvider

provider = DataProvider(config=config)
historical_data = provider.get_analyzed_dataframe()

[Uses LSPGotoDefinition on 'get_analyzed_dataframe']
→ Found in DataProvider class
→ Returns: Dict[str, DataFrame]
→ Code handles dict correctly ✓
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/backtester.md`, update the YAML frontmatter:

```yaml
---
name: trading-backtester
description: "Implements and backtests trading strategies using Freqtrade and VectorBT. Use when translating strategy hypotheses into executable backtest code, running walk-forward analysis, and producing backtest result reports."
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - LSPHover
  - LSPGotoDefinition
  - LSPFindReferences
  - LSPDiagnostics
model: sonnet
---
```

**Pre-Backtest Validation**

```
Backtester workflow:

1. Implement strategy code
   [LSPDiagnostics] → Check syntax errors

2. Validate framework usage
   [LSPHover] → Check function signatures
   [LSPFindReferences] → Ensure interface compliance

3. Verify data pipeline
   [LSPGotoDefinition] → Confirm DataProvider API
   [LSPDiagnostics] → Check data access code

4. Run syntax check
   bash: python -c "from strategy_class import StrategyName"

5. Execute backtest
   bash: freqtrade backtesting --strategy StrategyName ...

If validation passes → Backtest executes faster with confidence
```

---

## VISUALIZATION UPGRADES

### 1. Critic (`critic`)

**Current Tools**: Read, Grep, Glob, WebSearch
**Model**: opus
**Proposed Addition**: Vision (chart analysis), Matplotlib (chart generation)

#### Rationale

The Critic reviews strategy proposals and backtest results. Visual analysis enables:

- **Chart Verification**: Independently verify equity curve claims
- **Metric Visualization**: Visualize backtester's reported numbers
- **Anomaly Detection**: Spot drawdown spikes, return distribution issues visually
- **Evidence Capture**: Generate comparison charts for review documents

#### Current Responsibilities Impacted

| Responsibility | How Visualization Helps |
|---|---|
| **Backtest Review** | Visualize equity curves, drawdown charts, win/loss distribution |
| **Historical Comparison** | Create side-by-side comparison charts |
| **Anomaly Detection** | Chart-based detection of hidden patterns |
| **Review Checklist** | Attach visual evidence to checklist items |

#### Example Use Cases

**Use Case 1: Equity Curve Verification**
```
Backtester claims: "OOS Sharpe = 1.2, Max DD = 15%"

Critic uses Matplotlib to visualize the reported returns:
[Generates equity_curve.png from backtest CSV]

Equity curve shows:
- Smooth upward trend (visual evidence of positive Sharpe) ✓
- Max drawdown ~15% (visually matches claim) ✓
- No sudden crashes (good risk management) ✓
```

**Use Case 2: Win/Loss Distribution Analysis**
```
Backtester reports: "Win rate 55%, Avg win/loss = 1.25"

Critic visualizes returns distribution:
[Generates histogram of trade returns]

Visual inspection shows:
- Positive return distribution (skewed right) ✓
- Few large losses (limited downside) ✓
- No bimodal distribution (indicates consistency) ✓
```

**Use Case 3: Drawdown Comparison**
```
Comparing two similar strategies (STR-001 vs STR-002)

Critic generates comparison chart:
[Side-by-side drawdown curves]

Visual comparison reveals:
- STR-002 has sharper DD recovery (better risk control) ✓
- STR-001 has longer DD duration (worse) ✗
- Visual evidence supports Critic's preference
```

**Use Case 4: Regime-Based Performance**
```
Backtester claims: "Strategy works across bull/bear/sideways"

Critic visualizes performance by regime:
[Generates subplot: equity curve colored by regime]

Visual inspection shows:
- Bull regime: strong returns ✓
- Bear regime: small losses (profitable short strategy) ✓
- Sideways: slightly negative (acceptable) ✓
```

**Use Case 5: Parameter Sensitivity Heatmap**
```
Quant Analyst reports: "Strategy is robust to ±20% parameter variation"

Critic visualizes sensitivity:
[Generates heatmap of Sharpe vs parameter values]

Heatmap shows:
- No sharp cliffs (gradual degradation) ✓
- Peak performance away from boundaries (not overfitted) ✓
- Visual evidence supports robustness claim
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/critic.md`, update the YAML frontmatter:

```yaml
---
name: trading-critic
description: "Ruthlessly critiques trading strategies with evidence-based objections. Use when evaluating strategy proposals, reviewing backtest results, or providing adversarial analysis. Must provide alternatives for every criticism."
tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - Vision
  - Matplotlib
model: opus
---
```

**Chart Generation Pattern**

```python
import matplotlib.pyplot as plt
import pandas as pd

# Load backtest results
bt_results = pd.read_csv('.crypto/knowledge/strategies/STR-NNN/backtest-results/equity_curve.csv')

# Generate equity curve chart
fig, ax = plt.subplots(figsize=(12, 6))
ax.plot(bt_results['date'], bt_results['cumulative_return'], linewidth=2)
ax.set_title('Equity Curve - STR-NNN')
ax.set_ylabel('Cumulative Return')
ax.grid(True, alpha=0.3)
plt.savefig('equity_curve.png', dpi=150, bbox_inches='tight')

# Now Critic can examine the chart visually and compare to claims
```

**Vision Analysis Pattern**

```
Critic examines equity_curve.png using Vision tool:
"The equity curve shows consistent upward trend with smooth drawdowns.
The visual pattern supports the reported Sharpe of 1.2 because:
- No sudden crashes (limited tail risk)
- Regular profit realization (not luck-based)
- Drawdown recovery is quick (good system design)"
```

**Review Integration**

In `critic-review.md`:

```markdown
## Backtest Metrics Verification

[Embed equity_curve.png here]

Visual inspection of the equity curve:
- Smooth upward trend with minimal drawdowns
- Quick recovery from the 15% drawdown in 2024-Q2
- No regime-dependent collapses (good diversification)

[Embed drawdown_chart.png here]

Drawdown analysis:
- Maximum drawdown of ~14% (matches reported 15%, within tolerance)
- Average drawdown duration: ~2 weeks
- 90% of drawdowns recover within 1 month

**Verification Result**: CONFIRMED
All visual evidence supports backtester's reported metrics.
```

---

### 2. Monitor (`monitor`)

**Current Tools**: Read, Grep, Glob, Bash
**Model**: sonnet
**Proposed Addition**: Matplotlib (performance dashboards)

#### Rationale

The Monitor tracks live trading performance and must generate reports with visual evidence. Matplotlib enables:

- **Performance Dashboards**: 4-panel charts showing P&L, Sharpe, DD, win rate
- **Drift Detection Charts**: Visualize live vs backtest divergence
- **Anomaly Visualization**: Highlight unusual trading patterns
- **Trend Analysis**: Chart performance over time for reporting

#### Current Responsibilities Impacted

| Responsibility | How Visualization Helps |
|---|---|
| **Performance Tracking** | Generate dashboard charts of P&L, Sharpe, DD |
| **Drift Detection** | Visualize live vs backtest comparison charts |
| **Anomaly Detection** | Chart-based detection of unusual patterns |
| **Reporting** | Embed charts in weekly/monthly performance reports |

#### Example Use Cases

**Use Case 1: Weekly Performance Dashboard**
```python
import matplotlib.pyplot as plt
import pandas as pd

# Load live performance data
live_perf = pd.read_csv('.crypto/knowledge/strategies/STR-NNN/live-performance/week.csv')

fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(14, 10))

# P&L over time
ax1.plot(live_perf['date'], live_perf['cumulative_pnl'], color='green', linewidth=2)
ax1.fill_between(live_perf['date'], live_perf['cumulative_pnl'], alpha=0.3, color='green')
ax1.set_title('Cumulative P&L (7 days)')
ax1.set_ylabel('P&L ($)')

# Rolling Sharpe
ax2.plot(live_perf['date'], live_perf['rolling_sharpe_30d'], color='blue', linewidth=2)
ax2.axhline(y=live_perf['backtest_sharpe'].iloc[0], color='red', linestyle='--', label='Backtest Sharpe')
ax2.set_title('Rolling 30-Day Sharpe Ratio')
ax2.set_ylabel('Sharpe')
ax2.legend()

# Drawdown
ax3.plot(live_perf['date'], live_perf['drawdown'], color='red', linewidth=2)
ax3.axhline(y=live_perf['backtest_max_dd'].iloc[0], color='orange', linestyle='--', label='Backtest Max DD')
ax3.set_title('Current Drawdown')
ax3.set_ylabel('Drawdown %')
ax3.legend()

# Win rate
ax4.bar(live_perf['date'], live_perf['daily_win_rate'], color='purple', alpha=0.7)
ax4.axhline(y=live_perf['backtest_win_rate'].iloc[0], color='orange', linestyle='--', label='Backtest WR')
ax4.set_title('Daily Win Rate')
ax4.set_ylabel('Win Rate')
ax4.legend()

plt.tight_layout()
plt.savefig('weekly_dashboard.png', dpi=150)

# Generate report
report = {
    'dashboard_image': 'weekly_dashboard.png',
    'overall_status': 'healthy',
    'alerts': []
}
```

**Use Case 2: Live vs Backtest Comparison**
```python
import matplotlib.pyplot as plt
import numpy as np

# Backtest vs Live metrics
metrics = ['Sharpe', 'Max DD', 'Win Rate', 'Profit Factor']
backtest_values = [1.2, -0.15, 0.55, 1.8]
live_values = [1.0, -0.18, 0.52, 1.6]

x = np.arange(len(metrics))
width = 0.35

fig, ax = plt.subplots(figsize=(10, 6))
bars1 = ax.bar(x - width/2, backtest_values, width, label='Backtest', alpha=0.8)
bars2 = ax.bar(x + width/2, live_values, width, label='Live (30 days)', alpha=0.8)

ax.set_ylabel('Metric Value')
ax.set_title('Live vs Backtest Performance Comparison')
ax.set_xticks(x)
ax.set_xticklabels(metrics)
ax.legend()

# Add value labels on bars
for bars in [bars1, bars2]:
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.2f}', ha='center', va='bottom', fontsize=9)

plt.tight_layout()
plt.savefig('comparison.png', dpi=150)
```

**Use Case 3: Drift Detection Over Time**
```python
import matplotlib.pyplot as plt
import pandas as pd

# Track Sharpe drift over weeks
weeks_data = pd.read_csv('weekly_sharpe_drift.csv')

fig, ax = plt.subplots(figsize=(12, 6))

ax.plot(weeks_data['week'], weeks_data['backtest_sharpe'],
        label='Backtest Sharpe', linewidth=2, color='blue', linestyle='--')
ax.plot(weeks_data['week'], weeks_data['live_sharpe'],
        label='Live Sharpe (30d rolling)', linewidth=2, color='green')

# Highlight drift threshold
ax.fill_between(weeks_data['week'],
                weeks_data['backtest_sharpe'] * 0.7,
                weeks_data['backtest_sharpe'] * 1.3,
                alpha=0.2, color='gray', label='±30% tolerance band')

ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax.set_xlabel('Week')
ax.set_ylabel('Sharpe Ratio')
ax.set_title('Drift Detection: Live Sharpe vs Backtest')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('drift_detection.png', dpi=150)

# Alert if drift > 30%
drift_pct = (weeks_data['live_sharpe'].iloc[-1] - weeks_data['backtest_sharpe'].iloc[-1]) / weeks_data['backtest_sharpe'].iloc[-1]
if abs(drift_pct) > 0.30:
    print(f"ALERT: Sharpe drift of {drift_pct:.1%} exceeds 30% threshold")
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/monitor.md`, update the YAML frontmatter:

```yaml
---
name: trading-monitor
description: "Tracks live trading performance and detects anomalies. Use when checking strategy performance, comparing live vs backtest results, detecting drift, or generating performance reports."
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Matplotlib
model: sonnet
---
```

**Report Generation Pattern**

```
Monitor workflow:

1. Read live performance data
   [Load CSV files from live-performance/ directory]

2. Generate dashboard
   [Matplotlib: 4-panel chart of key metrics]

3. Generate comparison
   [Matplotlib: live vs backtest side-by-side]

4. Generate drift chart
   [Matplotlib: metric drift over time]

5. Write report with embedded images
   [Write YAML report with image paths]

6. Check for alerts
   [Calculate alert thresholds, flag if exceeded]
```

**Chart Storage**

```
.crypto/knowledge/strategies/STR-NNN/live-performance/
├── report-2026-02-05.yaml       (report with image paths)
├── dashboard-2026-02-05.png     (4-panel dashboard)
├── comparison-2026-02-05.png    (live vs backtest)
└── drift-2026-02-05.png         (drift detection chart)
```

---

### 3. Junior DataCurious (`junior-datacurious`)

**Current Tools**: Read, Grep, Glob, Bash
**Model**: haiku
**Proposed Addition**: Matplotlib (exploratory plots)

#### Rationale

Junior DataCurious finds anomalies and proposes features through exploration. Matplotlib enables:

- **Data Visualization**: Plot distributions, time series, correlations
- **Anomaly Visualization**: Highlight outliers in scatter plots
- **Feature Exploration**: Visualize proposed features against target
- **Report Evidence**: Include charts in anomaly/feature documentation

#### Current Responsibilities Impacted

| Responsibility | How Visualization Helps |
|---|---|
| **Anomaly Detection** | Visualize anomalies in scatter plots, distribution charts |
| **Feature Ideas** | Plot proposed features to show predictive patterns |
| **Data Questions** | Answer questions with visual evidence (charts, plots) |
| **Exploratory Analysis** | Create exploratory plots for brainstorming meetings |

#### Example Use Cases

**Use Case 1: Anomaly Visualization**
```python
import matplotlib.pyplot as plt
import numpy as np

# Volume anomalies
volume = np.array([100, 95, 105, 98, 102, 450, 99, 101])
dates = np.arange(len(volume))

fig, ax = plt.subplots(figsize=(10, 6))
colors = ['red' if v > 200 else 'blue' for v in volume]
ax.scatter(dates, volume, c=colors, s=100, alpha=0.7)
ax.set_xlabel('Time Index')
ax.set_ylabel('Volume')
ax.set_title('Volume Anomalies (Red = Spike >200)')
ax.axhline(y=np.mean(volume), color='green', linestyle='--', label='Mean')
ax.axhline(y=np.mean(volume) + 3*np.std(volume), color='red', linestyle=':', label='3-sigma threshold')
ax.legend()
plt.savefig('volume_anomalies.png', dpi=100)

# Anomaly report:
# Found 1 anomaly: Index 5 (volume=450) exceeds 3-sigma threshold
```

**Use Case 2: Feature Proposal Visualization**
```python
import matplotlib.pyplot as plt
import pandas as pd

# Proposed feature: volume_ratio (current_vol / 30d_avg)
data = pd.read_csv('data.csv', index_col='date', parse_dates=True)
data['volume_30d_avg'] = data['volume'].rolling(30).mean()
data['volume_ratio'] = data['volume'] / data['volume_30d_avg']

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

# Time series plot
ax1.plot(data.index, data['volume_ratio'], linewidth=1, color='blue')
ax1.axhline(y=1.0, color='red', linestyle='--', label='Normal (ratio=1)')
ax1.fill_between(data.index, 1.0, 1.5, alpha=0.2, color='green', label='High volume')
ax1.set_ylabel('Volume Ratio')
ax1.set_title('Proposed Feature: Volume Ratio (Current / 30d MA)')
ax1.legend()

# Distribution plot
ax2.hist(data['volume_ratio'].dropna(), bins=50, color='green', alpha=0.7)
ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Normal')
ax2.set_xlabel('Volume Ratio')
ax2.set_ylabel('Frequency')
ax2.set_title('Distribution: Most trading is near 1.0x average')
ax2.legend()

plt.tight_layout()
plt.savefig('volume_ratio_feature.png', dpi=100)

# Feature report:
# Created volume_ratio feature showing volume spikes relative to 30d average
# Pattern: Spikes occur 15% of days, distributed across all hours
```

**Use Case 3: Correlation Heatmap**
```python
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# Explore correlations for anomaly brainstorming
data = pd.read_csv('data.csv')
features = ['btc_price', 'eth_price', 'volume', 'volatility', 'funding_rate']

correlation_matrix = data[features].corr()

fig, ax = plt.subplots(figsize=(8, 6))
sns.heatmap(correlation_matrix, annot=True, fmt='.2f', cmap='coolwarm',
            center=0, square=True, ax=ax, vmin=-1, vmax=1)
ax.set_title('Cross-Asset Correlation Matrix')
plt.tight_layout()
plt.savefig('correlation_heatmap.png', dpi=100)

# Anomaly findings from heatmap:
# - BTC/ETH correlation: 0.92 (very high, expected)
# - Volume/Funding rate correlation: 0.15 (low, unexpected!)
# Feature idea: Does funding rate predict volume spikes?
```

**Use Case 4: Time-of-Day Pattern**
```python
import matplotlib.pyplot as plt
import pandas as pd

# Check for day-of-week or hour-of-day effects
data = pd.read_csv('hourly_data.csv', index_col='timestamp', parse_dates=True)
data['hour'] = data.index.hour
data['day_name'] = data.index.day_name()

# Hour-of-day pattern
hourly_returns = data.groupby('hour')['return'].agg(['mean', 'std'])

fig, ax = plt.subplots(figsize=(12, 6))
ax.bar(hourly_returns.index, hourly_returns['mean'], color='skyblue', alpha=0.7)
ax.errorbar(hourly_returns.index, hourly_returns['mean'],
            yerr=hourly_returns['std'], fmt='none', color='red',
            capsize=5, label='±1 Std Dev')
ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax.set_xlabel('Hour of Day (UTC)')
ax.set_ylabel('Average Return (%)')
ax.set_title('Anomaly: Hour-of-Day Return Pattern')
ax.legend()
plt.tight_layout()
plt.savefig('hour_of_day_pattern.png', dpi=100)

# Anomaly report:
# Found: Hours 8-10 UTC have significantly higher returns (3.2% on average)
# Statistical significance: p-value < 0.05 (ANOVA test)
# Feature idea: "is_high_return_hour" binary feature
```

**Use Case 5: Exploratory Scatter Plot**
```python
import matplotlib.pyplot as plt
import pandas as pd

# Explore relationship between two proposed features
data = pd.read_csv('data.csv')

fig, ax = plt.subplots(figsize=(10, 6))
scatter = ax.scatter(data['rsi_zscore'], data['return_next_hour'],
                    c=data['volatility_regime'], cmap='viridis',
                    alpha=0.6, s=30)
ax.set_xlabel('RSI Z-Score')
ax.set_ylabel('Next Hour Return (%)')
ax.set_title('Feature Relationship: RSI vs Future Returns (colored by volatility regime)')
cbar = plt.colorbar(scatter, ax=ax, label='Volatility Regime')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('feature_relationship.png', dpi=100)

# Exploratory finding:
# In low-volatility regime: Clear positive relationship (RSI extremes predict reversals)
# In high-volatility regime: No relationship (noise dominates)
# Feature idea: Use regime-dependent RSI thresholds
```

#### Implementation Notes

**How to Add to Agent Definition**

In `agents/junior-datacurious.md`, update the YAML frontmatter:

```yaml
---
name: trading-junior-datacurious
description: "Data anomaly hunter for strategy brainstorming meetings. Finds weird patterns in data, proposes derived features, and asks questions nobody thought to ask. Data-first approach rather than theory-first."
tools: Read, Grep, Glob, Bash, PythonREPL, Matplotlib
model: haiku
---
```

**Visualization Pattern**

```
Junior DataCurious workflow:

1. Ask data question
   "What's the hour-of-day effect on returns?"

2. Write Python to analyze
   [Load data, group by hour, compute statistics]

3. Visualize findings
   [Matplotlib: bar chart with error bars]

4. Interpret visual evidence
   "Chart shows hours 8-10 UTC have 3x normal returns"

5. Propose anomaly/feature
   "ANOMALY: Hour-of-day effect found (p < 0.05)"
   "FEATURE IDEA: is_high_return_hour binary"

6. Include chart in report
   [Embed PNG in brainstorming notes]
```

**Libraries Available**

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
```

---

## IMPLEMENTATION GUIDE

### Summary of Tool Additions

| Agent | Current Tools | Add | Tier | Impact |
|---|---|---|---|---|
| **quant-analyst** | Read, Grep, Glob, Bash | PythonREPL | opus | High |
| **ml-engineer** | Read, Write, Edit, Bash, Glob, Grep | PythonREPL | opus | High |
| **junior-datacurious** | Read, Grep, Glob, Bash | PythonREPL, Matplotlib | haiku | Medium |
| **risk-manager** | Read, Grep, Glob, Bash | PythonREPL | opus | High |
| **signal-generator** | Read, Write, Edit, Bash, Glob, Grep | LSPHover, LSPGotoDefinition, LSPFindReferences, LSPDiagnostics | sonnet | Medium |
| **ml-engineer** | (as above) | (as above + LSP tools) | opus | High |
| **backtester** | Read, Write, Edit, Bash, Glob, Grep | LSPHover, LSPGotoDefinition, LSPFindReferences, LSPDiagnostics | sonnet | Medium |
| **critic** | Read, Grep, Glob, WebSearch | Vision, Matplotlib | opus | High |
| **monitor** | Read, Grep, Glob, Bash | Matplotlib | sonnet | Medium |

### Phase 1: Python REPL Integration (Week 1)

**Goal**: Enable 4 agents to run calculations in-session

**Files to Update**:
```
agents/quantitative-analyst.md
agents/ml-engineer.md
agents/junior-datacurious.md
agents/risk-manager.md
```

**Change Template**:
```yaml
# Before
tools: Read, Grep, Glob, Bash

# After
tools: Read, Grep, Glob, Bash, PythonREPL
```

**Validation**:
- [ ] Each agent has PythonREPL in tools list
- [ ] Agent descriptions mention computational capabilities
- [ ] No conflicts with existing tools

### Phase 2: LSP Tools Integration (Week 2)

**Goal**: Enable 3 agents to validate code before deployment

**Files to Update**:
```
agents/signal-generator.md
agents/ml-engineer.md (add LSP to existing)
agents/backtester.md
```

**Change Template**:
```yaml
# Before
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep

# After
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - LSPHover
  - LSPGotoDefinition
  - LSPFindReferences
  - LSPDiagnostics
```

**Validation**:
- [ ] Each agent has all 4 LSP tools
- [ ] Agent descriptions mention code validation
- [ ] No breaking changes to existing workflows

### Phase 3: Visualization Integration (Week 3)

**Goal**: Enable 3 agents to generate visual evidence

**Files to Update**:
```
agents/critic.md
agents/monitor.md
agents/junior-datacurious.md (add Matplotlib to existing)
```

**Change Template for Matplotlib**:
```yaml
# Before
tools: Read, Grep, Glob, Bash

# After
tools: Read, Grep, Glob, Bash, Matplotlib
```

**Change Template for Vision**:
```yaml
# Before
tools: Read, Grep, Glob, WebSearch

# After
tools: Read, Grep, Glob, WebSearch, Vision, Matplotlib
```

**Validation**:
- [ ] Each agent has required visualization tools
- [ ] Agent descriptions mention visual analysis
- [ ] Chart output directories documented

### Post-Implementation Checklist

After implementing all upgrades:

- [ ] All 9 agent files updated with new tools
- [ ] No duplicate tools in any agent's tool list
- [ ] All agent descriptions mention new capabilities
- [ ] Git commit created: "feat: add tool enhancements to crypto-trading-team agents"
- [ ] Agents tested in live trading scenarios
- [ ] Tool usage documented in agent skill files (if applicable)
- [ ] Team notified of new capabilities via CHANGELOG

### Rollback Plan

If issues arise during implementation:

1. **Stage 1 Rollback** (Python REPL):
   ```bash
   git checkout agents/quantitative-analyst.md
   git checkout agents/ml-engineer.md
   git checkout agents/junior-datacurious.md
   git checkout agents/risk-manager.md
   ```

2. **Stage 2 Rollback** (LSP Tools):
   ```bash
   git checkout agents/signal-generator.md
   git checkout agents/backtester.md
   # ml-engineer already reverted above
   ```

3. **Stage 3 Rollback** (Visualization):
   ```bash
   git checkout agents/critic.md
   git checkout agents/monitor.md
   # junior-datacurious already reverted above
   ```

---

## Frequently Asked Questions

### Q: Can these tools be added to other agents?

**A**: Yes. The specifications here focus on 9 agents, but other agents may benefit from these tools:
- **Data Collector**: Could add PythonREPL for data cleaning/validation
- **Strategy Researcher**: Could add PythonREPL for hypothesis testing
- **Orchestrator**: Could add Matplotlib for strategy selection dashboards

### Q: Are there any tool conflicts?

**A**: No. The added tools don't overlap with existing tools and don't conflict with agent responsibilities.

### Q: How does this affect agent model tier?

**A**: Not at all. Each agent's `model` field (haiku/sonnet/opus) remains unchanged. Tool additions don't require model upgrades.

### Q: Can agents share Python REPL sessions?

**A**: No. Each agent has its own isolated REPL session with independent state. This prevents cross-contamination of calculations.

### Q: How are visualization outputs stored?

**A**: Charts should be saved to agent-specific directories:
```
.crypto/knowledge/strategies/STR-{NNN}/
├── charts/
│   ├── equity_curve.png
│   ├── drawdown_chart.png
│   └── ...
```

### Q: Do agents need training on new tools?

**A**: No. The agent definitions already guide how to use tools. The tool additions are extensions of existing responsibilities, not new behaviors.

---

## Document History

| Version | Date | Changes |
|---|---|---|
| 1.0 | 2026-02-05 | Initial specification of 9 agent upgrades |

**Next Review**: 2026-03-05 (post-implementation assessment)
