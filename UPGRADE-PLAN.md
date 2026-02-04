# Crypto Trading Team - Comprehensive Upgrade Plan

**Version**: 2.0
**Last Updated**: 2025-02-05
**Status**: Ready for Implementation

---

## Executive Summary

The crypto-trading-team plugin is a sophisticated 17-agent orchestration system with 5 integrated skills that automates crypto strategy development through tiered validation (L0-L3). The current implementation successfully handles strategy hypothesis generation, validation, backtesting, and risk assessment.

**Current Capabilities:**
- 17 specialized agents covering strategy research → deployment
- 5 integrated skills (init, pipeline, risk-check, evaluate, meeting)
- Tiered validation reducing compute cost by smart early rejection
- Active learning injection preventing repeated failures
- 24/7 autonomous operation via never-end mode

**Critical Gaps Identified:**

| Gap Category | Severity | Impact | Agents Affected |
|-------------|----------|--------|-----------------|
| **Tool Access Gaps** | HIGH | Limited compute capability | quant-analyst, ml-engineer, risk-manager, junior-datacurious |
| **Workflow Gaps** | HIGH | Bottlenecks in parallel execution | orchestrator, all agents |
| **Integration Gaps** | MEDIUM | Manual setup overhead | external-scout, data-collector, signal-generator |
| **Visualization Gaps** | MEDIUM | Reduced decision confidence | critic, monitor, junior-datacurious |

---

## PART 1: CURRENT STATE ANALYSIS

### Agent Inventory

**17 Total Agents:**

| Agent | Model | Tools | Role |
|-------|-------|-------|------|
| **orchestrator** | opus | R,Gr,Gl,B,T | Strategy pipeline coordination |
| **trading-insight** | sonnet | R,Gr,Gl | Dedup + novelty checking |
| **trading-feedback** | ? | ? | Learning injection (undocumented) |
| **trading-strategy-researcher** | ? | ? | Hypothesis generation (undocumented) |
| **trading-junior-maverick** | ? | ? | Contrarian ideas (undocumented) |
| **trading-junior-datacurious** | ? | ? | Data anomaly hunting (undocumented) |
| **trading-quant-analyst** | opus | R,Gr,Gl,B | Statistical validation |
| **trading-data-collector** | sonnet | R,W,E,B,Gl,Gr | Data sourcing + validation |
| **trading-backtester** | sonnet | R,W,E,B,Gl,Gr | Strategy execution + robustness testing |
| **trading-critic** | opus | R,Gr,Gl,WS | Adversarial review |
| **trading-risk-manager** | opus | R,Gr,Gl,B | Portfolio risk enforcement |
| **trading-ml-engineer** | opus | R,W,E,B,Gl,Gr | ML model development |
| **trading-signal-generator** | sonnet | R,W,E,B,Gl,Gr | Code generation |
| **trading-order-executor** | ? | ? | Exchange integration (undocumented) |
| **trading-monitor** | sonnet | R,Gr,Gl,B | Live performance tracking |
| **trading-external-scout** | opus | R,W,E,B,Gl,Gr,WS,WF | External source scouting |
| **trading-strategy-mutator** | ? | ? | Strategy transformation (undocumented) |

**Legend:** R=Read, W=Write, E=Edit, B=Bash, T=Task, Gr=Grep, Gl=Glob, WS=WebSearch, WF=WebFetch

**Undocumented Agents (5):**
- trading-feedback
- trading-strategy-researcher
- trading-junior-maverick
- trading-junior-datacurious
- trading-order-executor
- trading-strategy-mutator

### Skill Inventory

| Skill | Commands | Invocable | Purpose |
|-------|----------|-----------|---------|
| **pipeline** | pipeline, init, evaluate | YES | Full strategy pipeline (L0-L3) |
| **evaluate** | evaluate | YES | Strategy evaluation standalone |
| **init** | init | YES | Plugin initialization |
| **risk-check** | risk-check | YES | Risk pre-flight assessment |
| **meeting** | meeting | YES | Strategy brainstorming session |

### Command Inventory

| Command | Skill | Purpose |
|---------|-------|---------|
| init | init | One-time setup |
| pipeline | pipeline | Full autonomous pipeline |
| evaluate | evaluate | Quick strategy evaluation |
| status | - | Pipeline status check |
| risk-check | risk-check | Risk pre-assessment |
| ml-train | - | ML model training trigger |
| meeting | meeting | Strategy discovery session |
| never-end | - | Continuous 24/7 operation |
| update | - | Plugin update mechanism |

### Tool Assignment Coverage

**Complete Tool Access (6 agents):**
- data-collector, backtester, signal-generator, external-scout (R,W,E,B,Gl,Gr,WS,WF)
- critic (R,Gr,Gl,WS)

**Limited Tool Access (5 agents with gaps):**
- orchestrator: Has B (Bash) ❌ Missing Bash (has Task instead)
- insight: R,Gr,Gl only ❌ Missing WebSearch/Fetch for novelty trending
- quant-analyst: R,Gr,Gl,B ❌ Missing Python REPL for calculations
- ml-engineer: R,W,E,B,Gl,Gr ❌ Missing Python REPL for model training
- risk-manager: R,Gr,Gl,B ❌ Missing Python REPL for calculations
- junior-datacurious: Unknown tools ❌ Likely missing Python REPL
- monitor: R,Gr,Gl,B ❌ Missing visualization tools (mermaid, graphing)
- critic: Has everything except visualization

**No Tools (6 agents - critical blocker):**
- trading-feedback
- trading-strategy-researcher
- trading-junior-maverick
- trading-order-executor
- trading-strategy-mutator

---

## PART 2: CRITICAL GAPS IDENTIFIED

### P0: Tool Access Gaps (BLOCKING)

#### Gap 1: Python REPL Missing from Quantitative Agents

**Affected Agents:**
- trading-quant-analyst (needs: `mcp__plugin_oh-my-claudecode_t__python_repl`)
- trading-ml-engineer (needs: `mcp__plugin_oh-my-claudecode_t__python_repl`)
- trading-risk-manager (needs: `mcp__plugin_oh-my-claudecode_t__python_repl`)
- trading-junior-datacurious (needs: confirmation + `python_repl`)

**Impact:**
- Quant Analyst cannot run sensitivity analyses without manual verification
- ML Engineer cannot prototype feature engineering interactively
- Risk Manager cannot calculate position sizing formulas in real-time
- Junior DataCurious cannot explore data anomalies programmatically

**Current Workaround:** Write Python scripts to bash files, execute via Bash. Inefficient.

**Solution:**
```yaml
upgrade:
  agents:
    - name: trading-quant-analyst
      add_tools:
        - mcp__plugin_oh-my-claudecode_t__python_repl  # for sensitivity analysis
    - name: trading-ml-engineer
      add_tools:
        - mcp__plugin_oh-my-claudecode_t__python_repl  # for feature prototyping
    - name: trading-risk-manager
      add_tools:
        - mcp__plugin_oh-my-claudecode_t__python_repl  # for Kelly/position calculations
    - name: trading-junior-datacurious
      add_tools:
        - mcp__plugin_oh-my-claudecode_t__python_repl  # for anomaly exploration
```

---

#### Gap 2: LSP Tools Missing from Code-Heavy Agents

**Affected Agents:**
- trading-signal-generator (needs: LSP navigation for Freqtrade API)
- trading-ml-engineer (needs: LSP for model library navigation)
- trading-backtester (needs: LSP for backtest framework inspection)

**Impact:**
- Signal Generator generates code blindly without checking Freqtrade API compatibility
- ML Engineer can't navigate library documentation via hover/definition
- Backtester can't verify library function signatures for framework calls

**Solution:**
```yaml
upgrade:
  agents:
    - name: trading-signal-generator
      add_tools:
        - mcp__plugin_oh-my-claudecode_t__lsp_hover
        - mcp__plugin_oh-my-claudecode_t__lsp_goto_definition
        - mcp__plugin_oh-my-claudecode_t__lsp_diagnostics
    - name: trading-ml-engineer
      add_tools:
        - mcp__plugin_oh-my-claudecode_t__lsp_hover
        - mcp__plugin_oh-my-claudecode_t__lsp_diagnostics
    - name: trading-backtester
      add_tools:
        - mcp__plugin_oh-my-claudecode_t__lsp_diagnostics
        - mcp__plugin_oh-my-claudecode_t__lsp_hover
```

---

#### Gap 3: Visualization Tools Missing from Analysis Agents

**Affected Agents:**
- trading-critic (needs: result visualization for evidence)
- trading-monitor (needs: performance charts for drift detection)
- trading-junior-datacurious (needs: anomaly pattern visualization)

**Impact:**
- Critic must describe charts in prose instead of generating visual evidence
- Monitor reports in text instead of showing performance graphs
- Junior DataCurious loses pattern recognition power of visual anomaly detection

**Solution:**
```yaml
upgrade:
  agents:
    - name: trading-critic
      add_tools:
        - mcp__plugin_oh-my-claudecode_t__ast_grep_search  # for code pattern analysis
    - name: trading-monitor
      add_tools:
        - python_repl  # for matplotlib charts
        - bash  # for gnuplot if needed
    - name: trading-junior-datacurious
      add_tools:
        - python_repl  # for pandas + visualization
```

---

#### Gap 4: Undocumented Agents (6 agents with no tool spec)

**Missing Agent Definitions:**
1. trading-feedback — role: learning injection pre-flight
2. trading-strategy-researcher — role: hypothesis generation
3. trading-junior-maverick — role: contrarian ideas
4. trading-junior-datacurious — role: data anomaly hunting
5. trading-order-executor — role: exchange integration
6. trading-strategy-mutator — role: strategy transformation

**Impact:**
- Orchestrator tries to delegate to undefined agents
- No clear tool specs → agents improvise
- No model tier specification → unknown performance/cost
- No recovery path if agent call fails

**Solution:** Create complete agent specs with tools + model + description for all 6.

---

### P1: Workflow Gaps (HIGH PRIORITY)

#### Gap 5: Orchestrator is Single-Threaded

**Problem:**
- Orchestrator delegates one strategy at a time
- While Strategy Researcher works, Data Collector is idle
- While Backtester works (30+ minutes), other agents waiting
- Pipeline is bottlenecked at orchestrator

**Current Flow (Serial):**
```
Insight Check → Researcher → Quant → Data Collector → BT(L0) → BT(L1) → BT(L2) → Critic → BT(L3) → Risk → Done
```

**Potential Flow (Parallel):**
```
Phase 1:
  Insight Check (all ideas in parallel)
  ↓
Phase 2 (parallel branches):
  Researcher-A → Data-A → BT-A-L0
  Researcher-B → Data-B → BT-B-L0
  Researcher-C → Data-C → BT-C-L0
  ↓
Phase 3 (conditional):
  BT-A-L1 | BT-B-L1 | BT-C-L1 (parallel, only those that passed L0)
```

**Current Limitation:**
- Orchestrator has no concurrency control
- No job queue for multiple strategies
- No dependency tracking

**Solution:**

New Skill: `trading-orchestrate-parallel`

```yaml
skill:
  name: trading-orchestrate-parallel
  triggers:
    - "parallel strategy meeting"
    - "batch pipeline"
  capabilities:
    - Parse multiple strategy ideas
    - Create job queue with dependencies
    - Delegate to agents in parallel where independent
    - Wait for critical gates before advancing
    - Aggregate results across strategies
  state_file: .crypto/pipeline/job-queue.yaml
```

---

#### Gap 6: No Retry Logic for Failed Strategies

**Problem:**
- Strategy fails at L2 → marked as rejected
- No automatic variation attempt
- Manual intervention required to try tweaks

**Example Failure Mode:**
```
Strategy: "Bollinger Band mean reversion"
L0: PASS
L1: PASS
L2: FAIL (Sharpe 0.4 < 0.5 threshold)
Status: REJECTED

Could have tried:
- Different timeframe
- Different asset pair
- Different risk sizing
- Different regime filter
```

**Solution:**

New Skill: `trading-adapt-and-retry`

```yaml
skill:
  name: trading-adapt-and-retry
  purpose: "Auto-vary parameters of marginal strategies"
  triggers:
    - "strategy failed with reason: parameter_sensitivity"
    - "L2 rejection but Sharpe > 0.3"
  capabilities:
    - Read rejection reason from decision.yaml
    - Suggest parameter variations
    - Requeue for next backtest with tweaks
    - Track retry attempts (max 3)
    - Extract learnings from each attempt
  auto_variations:
    - timeframe: shift ±1-2 steps
    - universe: add/remove assets
    - risk_sizing: kelly vs fixed
    - regime_filter: add conditional logic
```

---

#### Gap 7: No Incremental Learning Implementation

**Problem:**
- Learnings are captured in `.crypto/knowledge/learnings.md`
- But not automatically extracted from each strategy failure
- Requires manual review + manual entry

**Example:**
```
Strategy STR-089 fails: "Single-asset trend-following = market beta"
This learning exists: L-008: "Single-asset trend-following = market beta, not alpha"
But L-008 wasn't injected proactively before proposal

Feedback Agent READS learnings but doesn't EXTRACT new learnings.
```

**Solution:**

Enhance Skill: `trading-pipeline` Phase 14

```yaml
phase_14:
  name: "Automated Learning Extraction"
  trigger: "strategy rejection at any tier"
  agent: trading-feedback
  procedure:
    - Read rejection reason + backtest results
    - Classify into failure taxonomy
    - Extract: "What should we never do again?"
    - Extract: "What could we try instead?"
    - Generate L-XXX entry for .crypto/knowledge/learnings.md
    - AUTO-INJECT this learning into next 5 similar hypotheses
  output: new-learning.yaml
```

---

#### Gap 8: Phase 3 Human Bottleneck (No Paper Trading Bridge)

**Problem:**
- Strategies pass all gates → require human approval for deployment
- But no automated paper trading stage
- Missing real-world execution testing

**Current Flow:**
```
L3 PASS → Risk Check PASS → HUMAN APPROVAL → ??? → LIVE TRADING
                                             ↓
                                      Missing step!
```

**Solution:**

New Skill: `trading-paper-trading`

```yaml
skill:
  name: trading-paper-trading
  purpose: "Automated paper trading validation before live deployment"
  triggers:
    - "Human approved strategy: '{name}'"
    - "Strategy ready for paper trading"
  stages:
    - duration: "7 days"
      capital: "$1000 simulated"
      goal: "Validate live execution quality vs backtest"
    - checks:
        - Slippage vs backtest assumption
        - Execution fill rates
        - Order rejection rates
        - Actual fees vs estimated
        - Signal timing vs market hours
    - outputs:
        - paper-trading-report.yaml
        - execution-quality-metrics.yaml
        - recommended_live_capital.yaml
  auto_advancement:
    - if sharpe_paper >= 0.7 * sharpe_backtest: "ready for live"
    - elif sharpe_paper < 0.5 * sharpe_backtest: "flag for review"
```

---

### P2: Integration Gaps (MEDIUM PRIORITY)

#### Gap 9: External Scout Requires Manual API Key Management

**Problem:**
- External Scout needs keys for Etherscan, Glassnode, etc.
- No automated key validation
- No error recovery if key is invalid

**Solution:**

New Skill: `trading-api-key-management`

```yaml
skill:
  name: trading-api-key-management
  purpose: "Validate and manage external API keys"
  capabilities:
    - Detect required APIs from external-signals.yaml
    - Check if keys are set in environment
    - Validate keys are actually working (test call)
    - Store valid keys in .crypto/config/api-keys.env (gitignored)
    - Alert user to missing keys
    - Provide setup instructions per source
```

---

#### Gap 10: Data Collector → Backtester Integration Fragile

**Problem:**
- Data Collector outputs to `.crypto/data/`
- Backtester expects specific CSV format
- No schema validation between them
- CSV headers, date formats, timezone handling all implicit

**Solution:**

Standardize: `trading-data-schema.yaml`

```yaml
# .crypto/config/data-schema.yaml
ohlcv:
  format: csv
  columns:
    - timestamp: ISO8601  # YYYY-MM-DD HH:MM:SS
    - open: float         # 8 decimals
    - high: float
    - low: float
    - close: float
    - volume: float       # base asset volume
  validation:
    - High >= max(Open, Close)
    - Low <= min(Open, Close)
    - Volume > 0
    - No gaps in timestamp (within expected candle interval)
  example_path: .crypto/data/BTC-USDT_1h_example.csv

funding_rate:
  format: csv
  columns:
    - timestamp: ISO8601
    - symbol: string      # BTC/USDT:USDT
    - funding_rate: float # -0.0001 to +0.0001 range
  validation:
    - funding_rate in [-0.001, 0.001] range
    - timestamp aligned to 8h boundaries
```

Both Data Collector and Backtester validate against this schema.

---

#### Gap 11: Signal Generator → Order Executor Integration Missing

**Problem:**
- Signal Generator produces code
- Order Executor is undocumented
- No defined interface between them
- No integration testing

**Solution:**

Define Interface: `trading-signal-executor-interface.md`

```yaml
interface:
  input: "strategy_{name}.py (Freqtrade format)"
  output_required:
    - entry_signals: List[Entry]
    - exit_signals: List[Exit]
    - position_size: float [0.0-1.0]
  validation:
    - Signals generated from past data only (no future leakage)
    - Position sizes sum to <= 1.0
    - All signals have timestamps
  order_executor_capabilities:
    - Load strategy code dynamically
    - Execute on paper trading exchange simulation
    - Execute on live exchange (with human approval)
    - Track order status (pending, filled, canceled)
    - Report execution latency vs signal generation time
```

---

### P3: Documentation Gaps (MEDIUM PRIORITY)

#### Gap 12: 6 Agents Completely Undocumented

Agent specs needed:
1. **trading-feedback** (learning injection)
2. **trading-strategy-researcher** (hypothesis generation)
3. **trading-junior-maverick** (contrarian ideas)
4. **trading-order-executor** (exchange integration)
5. **trading-strategy-mutator** (strategy transformation)

Each needs:
- Model tier specification (haiku/sonnet/opus)
- Tool inventory
- Role description
- Input/output format specification
- Integration points with other agents

---

## PART 3: PRIORITIZED UPGRADE RECOMMENDATIONS

### P0: BLOCKING - DO FIRST (1-2 weeks)

#### P0.1: Add Python REPL to Quantitative Agents
**Priority:** CRITICAL
**Effort:** 2 hours
**Agents:** quant-analyst, ml-engineer, risk-manager, junior-datacurious

```yaml
action: "Add python_repl tool to agents"
files_to_modify:
  - agents/quantitative-analyst.md (add tools: python_repl)
  - agents/ml-engineer.md (add tools: python_repl)
  - agents/risk-manager.md (add tools: python_repl)
  - agents/junior-datacurious.md (add tools: python_repl)
testing:
  - quant-analyst uses python_repl for sensitivity analysis
  - ml-engineer uses for feature importance calculation
  - risk-manager uses for Kelly formula calculation
  - junior-datacurious uses for correlation analysis
```

#### P0.2: Add LSP Tools to Code-Heavy Agents
**Priority:** CRITICAL
**Effort:** 2 hours
**Agents:** signal-generator, ml-engineer, backtester

```yaml
action: "Add LSP tools for code intelligence"
files_to_modify:
  - agents/signal-generator.md (add: lsp_hover, lsp_goto_definition, lsp_diagnostics)
  - agents/ml-engineer.md (add: lsp_diagnostics)
  - agents/backtester.md (add: lsp_diagnostics)
testing:
  - signal-generator can inspect Freqtrade API
  - ml-engineer can navigate sklearn/xgboost docs
  - backtester gets real-time error detection
```

#### P0.3: Create Agent Specs for 6 Undocumented Agents
**Priority:** CRITICAL
**Effort:** 8 hours
**New Files:**
- agents/feedback.md
- agents/strategy-researcher.md
- agents/junior-maverick.md
- agents/order-executor.md
- agents/strategy-mutator.md

```yaml
template_for_each_agent:
  - name: trading-{name}
    description: "{clear role}"
    model: {haiku|sonnet|opus}  # based on task complexity
    tools: [list]

    # From orchestrator.md, extract delegation info
    # Fill in role, responsibilities, output format
```

---

### P1: HIGH PRIORITY - DO NEXT (2-3 weeks)

#### P1.1: Implement Parallel Pipeline Skill
**Priority:** HIGH
**Effort:** 8 hours
**Creates:** skills/parallel-pipeline/SKILL.md

```yaml
skill:
  name: trading-orchestrate-parallel
  purpose: "Run multiple strategies through pipeline in parallel"

  entry_point: "meeting" or "batch: [idea1, idea2, idea3]"

  phases:
    phase_0_insight:
      - Parallel: Run Insight checks on all ideas
      - Gate: DUPLICATE → reject, NOVEL → proceed

    phase_1_ideation:
      - Parallel: Researcher, Data Collector (independent)
      - Each strategy gets own folder

    phase_2_validation:
      - Phase 2a: All L0 tests in parallel
      - Phase 2b: Filter failures, run passing L1s in parallel
      - Phase 2c: Filter failures, run passing L2s in parallel
      - Gate: Marginal cases → serial Critic review

    phase_3_deployment:
      - Serial: Risk Manager reviews each sequentially
      - (Risk impacts portfolio, must be sequential)

  state_tracking: .crypto/pipeline/parallel-queue.yaml
  result_aggregation: parallel-pipeline-results.yaml
```

**Integration Testing:**
- Run 3 strategies simultaneously through L0
- Verify all 3 complete without interference
- Verify rejections are independent
- Verify orchestrator can manage state across 3 parallel runs

---

#### P1.2: Implement Auto-Retry for Marginal Strategies
**Priority:** HIGH
**Effort:** 6 hours
**Creates:** skills/adapt-and-retry/SKILL.md

```yaml
skill:
  name: trading-adapt-and-retry
  purpose: "Automatically vary parameters of marginal strategies"

  triggers:
    - "L2 Sharpe: 0.35-0.50 (below 0.5 threshold but not bad)"
    - "L3 failure: specific parameter too conservative"

  retry_strategies:
    - name: "timeframe_shift"
      from: original 4h
      try: [1h, 8h, daily]
      max_attempts: 2

    - name: "universe_expansion"
      from: single asset
      try: [top 5 tokens, top 10 tokens]
      max_attempts: 1

    - name: "risk_sizing"
      from: fixed 1% per trade
      try: [kelly_fraction=0.5, kelly_fraction=0.25]
      max_attempts: 1

  max_total_retries: 3
  learning_extraction: "Extract why each retry failed/succeeded"
```

---

#### P1.3: Implement Incremental Learning Extraction
**Priority:** HIGH
**Effort:** 4 hours
**Enhances:** skills/pipeline/SKILL.md Phase 14

```yaml
enhancement:
  phase: "Phase 14: Automated Learning Extraction"
  agent: trading-feedback

  on_strategy_failure:
    - Read: decision.yaml (rejection reason + tier)
    - Read: backtest results if available
    - Classify: Into failure taxonomy from failure-taxonomy.yaml

    - Extract learnings:
        - What indicator/signal is provably ineffective?
        - What dataset is insufficient?
        - What assumption was violated?
        - What could work instead?

    - Create: L-{next_id}.yaml with:
        - failure_root_cause
        - statement: "Single-asset momentum = beta, not alpha in crypto"
        - applicable_to: [list of similar strategies]
        - prevention: "Require multi-asset setup before backtest"
        - timestamp: now

    - Proactive injection: Next 5 hypotheses matching criteria
      get automatic WARNING: "This violates L-XXX, see mitigation"
```

---

#### P1.4: Create Paper Trading Validation Skill
**Priority:** HIGH
**Effort:** 10 hours
**Creates:** skills/paper-trading/SKILL.md

```yaml
skill:
  name: trading-paper-trading
  purpose: "Automated paper trading validation before live deployment"

  trigger: "Strategy approved for deployment"

  stages:
    - name: "Paper Trading Execution (7 days)"
      capital: "$1,000 simulated"
      exchange: "Freqtrade dry_run mode"
      duration: "7 calendar days or 100 trades"

    - metrics_collection:
        - Actual slippage vs backtest assumption
        - Fill rate (% of orders filled vs submitted)
        - Execution latency (signal generation → order submission)
        - Actual fees charged vs estimated
        - Order rejections / timeouts
        - Market impact estimation

    - quality_gates:
        - Sharpe_paper >= 0.7 * Sharpe_backtest → "READY FOR LIVE"
        - 0.5 * Sharpe_BT <= Sharpe_paper < 0.7 * Sharpe_BT → "MARGINAL"
        - Sharpe_paper < 0.5 * Sharpe_BT → "FAILED, REVIEW"

    - output: paper-trading-report.yaml
```

---

### P2: MEDIUM PRIORITY - DO LATER (3-4 weeks)

#### P2.1: Standardize Data Schema
**Priority:** MEDIUM
**Effort:** 4 hours
**Creates:** config/data-schema.yaml

```yaml
file: .crypto/config/data-schema.yaml

schemas:
  ohlcv:
    columns: [timestamp, open, high, low, close, volume]
    types: [ISO8601, float, float, float, float, float]
    validations:
      - High >= max(Open, Close)
      - Low <= min(Open, Close)
      - No gaps in timestamp

  funding_rate:
    columns: [timestamp, symbol, funding_rate]
    types: [ISO8601, string, float]
    validations:
      - funding_rate in [-0.001, 0.001]
      - timestamp aligned to 8h boundaries

  validation_script: .crypto/scripts/validate-data.py
```

Both Data Collector and Backtester validate against this.

---

#### P2.2: Define Signal-Executor Interface
**Priority:** MEDIUM
**Effort:** 4 hours
**Creates:** config/signal-executor-interface.md

```yaml
file: .crypto/config/signal-executor-interface.md

interface:
  input: "strategy_{name}.py (Freqtrade IStrategy format)"

  required_signals:
    - entry_signals: List[timestamp, symbol, position_size]
    - exit_signals: List[timestamp, symbol]

  validation:
    - All signals from past data only (no future leakage)
    - Position sizes in [0.0, 1.0]
    - Timestamps are valid market hours

  executor_requirements:
    - Load strategy dynamically
    - Execute on paper trading simulator first
    - Execute on live exchange (with audit trail)
    - Report: execution_latency, fill_rate, slippage
```

---

#### P2.3: Create API Key Management System
**Priority:** MEDIUM
**Effort:** 6 hours
**Creates:** skills/api-key-management/SKILL.md

```yaml
skill:
  name: trading-api-key-management
  purpose: "Manage external API keys securely"

  capabilities:
    - Detect required APIs from external-signals.yaml
    - Check environment variables
    - Validate keys (test call)
    - Store validated keys in .crypto/config/api-keys.env (gitignored)
    - Alert missing keys with setup instructions

  supported_apis:
    - etherscan
    - glassnode
    - nansen
    - twitter/x
    - coinglass

  output: api-key-status.yaml with all keys valid/invalid/missing
```

---

## PART 4: NEW AGENT PROPOSALS

### Proposed New Agents (Optional Enhancements)

#### Agent: trading-ensemble-coordinator
**Purpose:** Combine signals from multiple strategies into ensemble bets
**Model:** opus
**Tools:** R,W,B,Gr,python_repl
**Rationale:** Current system runs strategies in isolation. Ensemble methods (averaging, voting, weighted combination) can improve sharpe from 0.6 → 1.2 for weak signals.

**Responsibilities:**
1. Identify weak strategies (Sharpe 0.5-0.8) that could ensemble
2. Calculate correlation between their signals
3. Create ensemble strategy combining uncorrelated signals
4. Backtest ensemble
5. Estimate correlation stability across regimes

#### Agent: trading-backtester-optimizer
**Purpose:** Automated parameter optimization and sensitivity analysis
**Model:** sonnet
**Tools:** R,W,B,python_repl
**Rationale:** Current backtester reports results, but doesn't optimize. This agent: runs grid search, finds optimal parameters, generates sensitivity heatmaps.

**Responsibilities:**
1. Read hypothesis + parameters.yaml
2. Define parameter search space
3. Run Bayesian optimization or grid search
4. Generate sensitivity heatmaps (each parameter vs Sharpe)
5. Report optimal parameters with confidence intervals

---

## PART 5: NEW SKILL PROPOSALS

### Proposed New Skills (High Impact)

| Skill | Purpose | User Trigger | Agents |
|-------|---------|--------------|--------|
| **parallel-pipeline** | Run 3+ strategies simultaneously | "batch pipeline" | orchestrator, all agents |
| **adapt-and-retry** | Auto-vary failed strategies | "retry marginal" | orchestrator, feedback |
| **paper-trading** | 7-day paper trading validation | "paper trading" | orchestrator, monitor |
| **api-key-management** | Manage external API keys | "setup apis" | external-scout |

---

## PART 6: TESTING STRATEGY FOR UPGRADES

### Phase 1: Unit Testing (1 week)

#### Test P0.1: Python REPL Tool Addition
```python
def test_quant_analyst_python_repl():
    """Verify quant-analyst can execute Python code"""
    result = agent.python_repl.execute("""
        import numpy as np
        sensitivity = np.linspace(-0.2, 0.2, 11)
        print(f"Sensitivity analysis: {sensitivity}")
    """)
    assert "Sensitivity analysis" in result.stdout

def test_ml_engineer_feature_engineering():
    """Verify ml-engineer can prototype features interactively"""
    result = agent.python_repl.execute("""
        import pandas as pd
        df = pd.DataFrame({'close': [100, 102, 101, 103]})
        df['returns'] = df['close'].pct_change()
        print(df)
    """)
    assert "returns" in result.stdout
```

#### Test P0.2: LSP Tools Addition
```python
def test_signal_generator_lsp_hover():
    """Verify signal-generator can hover Freqtrade API"""
    hover_info = agent.lsp_hover(
        file="agents/signal-generator.md",
        line=50,
        character=10
    )
    assert hover_info.signature is not None
```

#### Test P0.3: New Agent Specs
```python
def test_feedback_agent_spec():
    """Verify feedback agent spec is complete"""
    spec = load_agent_spec("agents/feedback.md")
    assert spec.name == "trading-feedback"
    assert spec.model in ["haiku", "sonnet", "opus"]
    assert len(spec.tools) > 0
    assert spec.description is not None
```

### Phase 2: Integration Testing (2 weeks)

#### Test P1.1: Parallel Pipeline
```python
def test_parallel_three_strategies():
    """Verify 3 strategies process in parallel without collision"""
    strategies = [
        "funding rate arbitrage",
        "momentum crossover",
        "mean reversion bands"
    ]

    # Start parallel pipeline
    result = skill.parallel_pipeline(strategies)

    # Verify all 3 complete
    assert len(result.strategies) == 3

    # Verify independent state (no cross-contamination)
    for strat in result.strategies:
        assert strat.state_file.exists()
        assert strat.state_file.name.unique_id != others

    # Verify rejection independence
    if strat[0] rejected at L0, strat[1] should still process
```

#### Test P1.2: Auto-Retry
```python
def test_retry_marginal_strategy():
    """Verify marginal strategy gets retried with parameter variations"""
    original = {
        "timeframe": "4h",
        "universe": "BTC",
        "sizing": "fixed_1pct"
    }

    # Simulate L2 failure: Sharpe 0.42
    result = skill.adapt_and_retry(
        strategy_id="STR-091",
        original_params=original,
        failure_reason="Sharpe 0.42 < 0.5 threshold"
    )

    # Verify retries happened
    assert len(result.attempts) == 2  # max 2 retries

    # Verify variations applied
    attempt_1_params = result.attempts[0].params
    assert attempt_1_params.timeframe != "4h" or \
           attempt_1_params.universe != "BTC" or \
           attempt_1_params.sizing != "fixed_1pct"
```

#### Test P1.4: Paper Trading
```python
def test_paper_trading_validation():
    """Verify paper trading runs 7 days and generates quality gates"""
    result = skill.paper_trading(strategy_id="STR-088")

    assert result.duration_days >= 7
    assert result.trades_executed > 0

    # Verify execution quality metrics
    assert hasattr(result, 'slippage_vs_backtest')
    assert hasattr(result, 'fill_rate')
    assert hasattr(result, 'execution_latency')

    # Verify quality gates
    backtest_sharpe = 1.0
    paper_sharpe = result.sharpe

    if paper_sharpe >= 0.7 * backtest_sharpe:
        assert result.verdict == "READY_FOR_LIVE"
    elif paper_sharpe >= 0.5 * backtest_sharpe:
        assert result.verdict == "MARGINAL"
    else:
        assert result.verdict == "FAILED_REVIEW"
```

### Phase 3: End-to-End Testing (1 week)

#### Test Full Pipeline with Upgrades
```python
def test_e2e_pipeline_with_all_upgrades():
    """Verify full pipeline works with P0+P1 upgrades"""

    # Trigger pipeline with 3 ideas
    result = skill.pipeline("batch: [idea-1, idea-2, idea-3]")

    # Verify Phase 0: Parallel Insight checks
    assert len(result.insight_results) == 3

    # Verify Phase 1: Parallel ideation
    assert len(result.strategies) == num_novel_ideas

    # Verify Phase 2: Parallel L0-L2, serial review
    for strat in result.strategies:
        if strat.passed_l2:
            assert strat.critic_review is not None

    # Verify Phase 3: Risk checks (serial, portfolio-aware)
    total_capital = 0
    for strat in result.approved:
        total_capital += strat.capital_allocation
    assert total_capital <= 0.60  # 60% max deployed

    # Verify Phase 4: Learning extraction (automatic)
    for strat in result.rejected:
        assert strat.learning_extracted is not None
```

---

## PART 7: IMPLEMENTATION ROADMAP

### Timeline: 6 Weeks to Full Implementation

```
WEEK 1-2: P0 (Blocking Issues)
├── P0.1: Add Python REPL to 4 agents (2h)
├── P0.2: Add LSP tools to 3 agents (2h)
└── P0.3: Create 6 agent specs (8h)
Total: 12 hours (1-2 days of focused work)

WEEK 2-3: P1 Early (Critical Workflows)
├── P1.1: Parallel pipeline skill (8h)
├── P1.2: Auto-retry skill (6h)
├── P1.3: Learning extraction enhancement (4h)
└── Testing: Unit tests for all P1 features (8h)
Total: 26 hours (3 days)

WEEK 3-4: P1 Late (Deployment)
├── P1.4: Paper trading skill (10h)
├── P1.5: Integration tests (12h)
└── Documentation updates (4h)
Total: 26 hours (3 days)

WEEK 4-5: P2 (Integration Improvements)
├── P2.1: Data schema standardization (4h)
├── P2.2: Signal-executor interface (4h)
├── P2.3: API key management (6h)
└── Testing: Integration tests (8h)
Total: 22 hours (3 days)

WEEK 5-6: E2E Testing & Release
├── End-to-end pipeline tests (12h)
├── Performance benchmarking (4h)
├── User documentation (4h)
└── Release preparation (4h)
Total: 24 hours (3 days)

TOTAL EFFORT: ~110 hours of development (~2.5 weeks of full-time work)
```

### Implementation Checklist

**P0: Blocking (Week 1-2)**
- [ ] Add python_repl to quant-analyst, ml-engineer, risk-manager, junior-datacurious
- [ ] Add lsp_hover, lsp_goto_definition, lsp_diagnostics to signal-generator, ml-engineer, backtester
- [ ] Create feedback.md with tools + model + spec
- [ ] Create strategy-researcher.md
- [ ] Create junior-maverick.md
- [ ] Create order-executor.md
- [ ] Create strategy-mutator.md
- [ ] Verify all agents have complete tool specs

**P1: High Priority (Week 2-4)**
- [ ] Create skills/parallel-pipeline/SKILL.md
- [ ] Create skills/adapt-and-retry/SKILL.md
- [ ] Enhance skills/pipeline/SKILL.md with learning extraction
- [ ] Create skills/paper-trading/SKILL.md
- [ ] Unit tests for each new skill
- [ ] Integration tests (parallel execution, retry logic)
- [ ] Update commands/pipeline.md with new phases
- [ ] Update commands with: parallel, retry, paper-trading commands

**P2: Medium Priority (Week 4-5)**
- [ ] Create config/data-schema.yaml
- [ ] Create config/signal-executor-interface.md
- [ ] Create skills/api-key-management/SKILL.md
- [ ] Update data-collector.md to validate against schema
- [ ] Update backtester.md to validate against schema
- [ ] Update signal-generator.md to validate against interface

**Testing & Release (Week 5-6)**
- [ ] Run full E2E test suite
- [ ] Benchmark: parallel pipeline speedup
- [ ] Performance: memory usage with 3 concurrent strategies
- [ ] Documentation: update README.md
- [ ] User guide: how to use new parallel pipeline
- [ ] Tag version 0.8.0 or 1.0.0
- [ ] Test never-end mode with new features

---

## PART 8: RISK MITIGATION

### Risk 1: Parallel Pipeline State Collision
**Risk:** Multiple strategies write to `.crypto/pipeline/` simultaneously
**Mitigation:**
- Each strategy gets unique folder: `.crypto/pipeline/runs/STR-{NNN}-{timestamp}/`
- Orchestrator manages queue state in locked YAML file
- Atomic file operations (write temp file, rename)

### Risk 2: API Rate Limiting (External Scout)
**Risk:** External Scout hits API rate limits during scouting
**Mitigation:**
- Implement exponential backoff in WebFetch calls
- Cache external signals for 1 hour
- Respect rate limits per API (documented in api-key-management)
- Graceful degradation: skip unavailable sources

### Risk 3: Paper Trading Realistic Execution
**Risk:** Freqtrade dry_run slippage assumption unrealistic
**Mitigation:**
- Use actual exchange fees from live Binance/Bybit
- Add configurable slippage model (0-50 bps)
- Stress test with 2x slippage budget
- Compare to actual live performance after 7 days

### Risk 4: Learning Extraction Hallucination
**Risk:** Feedback Agent extracts spurious learnings
**Mitigation:**
- Every learning must cite specific evidence (backtest metric, failure tier)
- Learning must be falsifiable (can it be disproven?)
- Require 2+ similar failures before extracting general learning
- Manual review of L-{N} entries weekly

---

## PART 9: SUCCESS CRITERIA

### Post-Upgrade Metrics

| Metric | Baseline | Target | Timeline |
|--------|----------|--------|----------|
| **Pipeline Throughput** | 1 strategy/day | 3+ parallel strategies/day | Week 4 |
| **Time to L3 Pass** | 60+ minutes (serial) | 30+ minutes (parallel L0-L2) | Week 4 |
| **Rejection Rate at L0** | 50% | 70% (save time) | Week 3 |
| **Strategy Sharpe Avg** | 0.7 | 0.9+ (via ensemble) | Week 6 |
| **Live vs Backtest Gap** | Unknown | <20% drift (via paper trading) | Week 5 |
| **Learning Coverage** | 30 learnings | 60+ learnings (auto-extracted) | Week 6 |
| **API Integration** | 1 source (Twitter) | 5+ sources (Etherscan, Glassnode, etc) | Week 5 |

### Operational Improvements

After P0+P1 upgrades:
- **Parallel execution:** 3-5 strategies simultaneously (2-3x throughput)
- **Faster feedback:** Marginal strategies auto-retry instead of waiting for human
- **Richer learnings:** Each rejection generates L-{N} entry for future prevention
- **Production readiness:** Paper trading validates execution quality before live

---

## CONCLUSION

The crypto-trading-team plugin is architecturally sound with 17 specialized agents coordinating through tiered validation. The upgrade path is clear:

1. **P0 (1-2 weeks):** Fix tool gaps and document missing agents
2. **P1 (2-3 weeks):** Implement parallel execution, auto-retry, paper trading
3. **P2 (1 week):** Standardize data/signal interfaces

**Expected outcome:** A world-class autonomous crypto trading research system that develops, validates, and deploys strategies with minimal human intervention, producing consistent alpha across market regimes.

---

**Next Steps:**
1. Review this upgrade plan with team
2. Prioritize: focus on P0 first (blocker removal)
3. Implement in 6-week sprint
4. Test thoroughly before deployment
5. Deploy to production with monitoring

---

**Author's Notes:**
- This upgrade plan assumes the 6 undocumented agents exist and are functional
- If any are missing entirely, that becomes a P0 blocker
- The parallel pipeline requires careful state management — test thoroughly
- Paper trading validation is optional but highly recommended for live deployment
- Consider starting with P1.1 (parallel pipeline) for quick win on throughput
