# Implementation Checklist - Crypto Trading Team Upgrades

Use this checklist to track progress through the 6-week upgrade plan.

---

## PHASE 1: P0 Blocking Fixes (Week 1-2)

### P0.1: Add Python REPL to Quantitative Agents (2 hours)

**File: `agents/quantitative-analyst.md`**
- [ ] Open file
- [ ] Locate `tools:` field (currently: `Read, Grep, Glob, Bash`)
- [ ] Add `python_repl` to tools list
- [ ] Update description to mention Python capability
- [ ] Verify syntax: `tools: Read, Grep, Glob, Bash, python_repl`

**File: `agents/ml-engineer.md`**
- [ ] Open file
- [ ] Locate `tools:` field (currently: `Read, Write, Edit, Bash, Glob, Grep`)
- [ ] Add `python_repl` to tools list
- [ ] Verify syntax
- [ ] Add example usage in "Example Workflow" section

**File: `agents/risk-manager.md`**
- [ ] Open file
- [ ] Locate `tools:` field (currently: `Read, Grep, Glob, Bash`)
- [ ] Add `python_repl` to tools list
- [ ] Verify syntax

**File: `agents/junior-datacurious.md`**
- [ ] Verify file exists (or create if missing)
- [ ] Add `tools: Read, Write, Bash, Glob, Grep, python_repl`
- [ ] Create agent spec with role, model (sonnet), responsibilities

**Verification:**
- [ ] All 4 files have `python_repl` in tools list
- [ ] No syntax errors (valid YAML front matter)
- [ ] Descriptions mention Python capability

---

### P0.2: Add LSP Tools to Code-Heavy Agents (2 hours)

**File: `agents/signal-generator.md`**
- [ ] Open file
- [ ] Current tools: `Read, Write, Edit, Bash, Glob, Grep`
- [ ] Add: `lsp_hover`, `lsp_goto_definition`, `lsp_diagnostics`
- [ ] New tools: `Read, Write, Edit, Bash, Glob, Grep, lsp_hover, lsp_goto_definition, lsp_diagnostics`
- [ ] Add section: "Using LSP Tools" explaining how to inspect Freqtrade API

**File: `agents/ml-engineer.md`**
- [ ] Add: `lsp_hover`, `lsp_diagnostics`
- [ ] New tools: `Read, Write, Edit, Bash, Glob, Grep, python_repl, lsp_hover, lsp_diagnostics`

**File: `agents/backtester.md`**
- [ ] Add: `lsp_diagnostics`, `lsp_hover`
- [ ] New tools: `Read, Write, Edit, Bash, Glob, Grep, lsp_diagnostics, lsp_hover`

**Verification:**
- [ ] All 3 files have LSP tools added
- [ ] No duplicate tools in list
- [ ] Descriptions updated to mention code intelligence

---

### P0.3: Create Specs for 6 Undocumented Agents (8 hours)

**File: `agents/feedback.md` (NEW)**
- [ ] Create file
- [ ] Add YAML front matter:
  ```yaml
  ---
  name: trading-feedback
  description: "Learning injection engine. Pre-flight check for strategies, auto-flagging risks based on past learnings."
  model: sonnet
  tools: Read, Grep, Glob, Bash
  ---
  ```
- [ ] Add sections:
  - [ ] Role & Responsibilities
  - [ ] Learning Injection Protocol
  - [ ] Output Format (CRITICAL/WARNING/INFO report)
  - [ ] Integration with Insight Agent
  - [ ] Learning Extraction from Failures
- [ ] Base on orchestrator.md feedback agent description

**File: `agents/strategy-researcher.md` (NEW)**
- [ ] Create file
- [ ] Add YAML front matter:
  ```yaml
  ---
  name: trading-strategy-researcher
  description: "Hypothesis generation. Creates detailed strategy specifications from validated ideas."
  model: opus
  tools: Read, Write, Bash, WebSearch
  ---
  ```
- [ ] Add sections:
  - [ ] Role & Responsibilities
  - [ ] Hypothesis Development Process
  - [ ] Output Format (hypothesis.md + parameters.yaml)
  - [ ] Collaboration with Insight Agent
  - [ ] Integration with Feedback Agent

**File: `agents/junior-maverick.md` (NEW)**
- [ ] Create file
- [ ] Add YAML front matter:
  ```yaml
  ---
  name: trading-junior-maverick
  description: "Contrarian ideas generator. Creates unconventional strategy proposals for strategy meetings."
  model: sonnet
  temperature: 0.9
  tools: Read, Write, Bash, WebSearch, WebFetch
  ---
  ```
- [ ] Add sections:
  - [ ] Role & Responsibilities
  - [ ] Contrarian Thinking Framework
  - [ ] Idea Proposal Format
  - [ ] Integration with Strategy Meeting

**File: `agents/order-executor.md` (NEW)**
- [ ] Create file
- [ ] Add YAML front matter:
  ```yaml
  ---
  name: trading-order-executor
  description: "Executes trading orders on exchanges and paper trading. Manages position entry/exit with risk controls."
  model: sonnet
  tools: Read, Write, Bash, Grep, Glob
  ---
  ```
- [ ] Add sections:
  - [ ] Role & Responsibilities
  - [ ] Order Execution Flow
  - [ ] Paper Trading vs Live Trading
  - [ ] Risk Control Integration
  - [ ] Output Format (execution-report.yaml)

**File: `agents/strategy-mutator.md` (NEW)**
- [ ] Create file
- [ ] Add YAML front matter:
  ```yaml
  ---
  name: trading-strategy-mutator
  description: "Transforms existing strategies via mutation operators. Creates variations of successful strategies."
  model: opus
  tools: Read, Write, Bash, Grep, python_repl
  ---
  ```
- [ ] Add sections:
  - [ ] Role & Responsibilities
  - [ ] Mutation Operators (invert, combine, scale, regime, ensemble)
  - [ ] Strategy Variation Process
  - [ ] Output Format (mutated-hypothesis.yaml)

**File: `agents/junior-datacurious.md` (UPDATE/CREATE)**
- [ ] Verify existence or create
- [ ] Add YAML front matter with: name, description, model (sonnet), tools, temperature (0.8)
- [ ] Add sections:
  - [ ] Role & Responsibilities
  - [ ] Data Anomaly Detection
  - [ ] Integration with Data Collector
  - [ ] Exploratory Analysis Workflow

**Verification:**
- [ ] All 6 files created/updated
- [ ] YAML front matter valid (tools, model, description present)
- [ ] All files have clear role descriptions
- [ ] All files have Output Format section
- [ ] No duplicate agent names

---

## PHASE 2: P1 High Priority (Week 2-4)

### P1.1: Create Parallel Pipeline Skill (8 hours)

**Create: `skills/parallel-pipeline/SKILL.md`**
- [ ] Create directory: `mkdir -p skills/parallel-pipeline`
- [ ] Create file `SKILL.md`
- [ ] Add YAML front matter:
  ```yaml
  name: trading-parallel-pipeline
  description: "Run 3+ strategies simultaneously through tiered validation"
  user-invocable: true
  argument-hint: "[strategy1, strategy2, strategy3] or 'batch' or 'meeting'"
  model: opus
  ```
- [ ] Add sections:
  - [ ] Parallel Phases (0-3)
  - [ ] Job Queue Management (state file: `.crypto/pipeline/parallel-queue.yaml`)
  - [ ] Dependency Tracking (which strategies can proceed to next tier)
  - [ ] Result Aggregation
  - [ ] Error Handling (if one fails, others continue)
- [ ] Add pseudocode for parallel execution
- [ ] Reference: skills/pipeline/SKILL.md for structure

**Create: `commands/parallel.md` (NEW)**
- [ ] Create file
- [ ] Content:
  ```yaml
  description: Run parallel strategy pipeline with 3+ concurrent strategies
  ---

  # Parallel Pipeline Command

  ## Usage

  `/crypto parallel: [idea-1, idea-2, idea-3]`
  `/crypto parallel meeting` (run strategy meeting, process all ideas in parallel)

  ## What It Does

  1. Phase 0: All ideas through Insight check in parallel
  2. Phase 1: Independent agents (Researcher, Data Collector) in parallel
  3. Phase 2: L0-L2 validation in parallel (only passing strategies)
  4. Phase 3: Sequential Risk + Critic reviews (portfolio-aware)

  ## Output

  - `.crypto/pipeline/parallel-queue.yaml` (job queue status)
  - `.crypto/pipeline/parallel-results.yaml` (aggregated results)
  - Individual strategy folders: `.crypto/knowledge/strategies/STR-{NNN}/`
  ```

**Verification:**
- [ ] SKILL.md complete with all sections
- [ ] State management plan included (queue.yaml structure)
- [ ] Error handling documented
- [ ] Tested: Run 3 strategies, verify parallel execution

---

### P1.2: Create Auto-Retry Skill (6 hours)

**Create: `skills/adapt-and-retry/SKILL.md`**
- [ ] Create directory: `mkdir -p skills/adapt-and-retry`
- [ ] Create file `SKILL.md`
- [ ] Add YAML front matter
- [ ] Add sections:
  - [ ] Trigger Conditions (Sharpe 0.35-0.50, specific parameter too conservative)
  - [ ] Retry Strategies (timeframe_shift, universe_expansion, risk_sizing)
  - [ ] Max Attempts Policy (3 total retries max)
  - [ ] Learning Extraction (why each retry failed/succeeded)
  - [ ] Output Format (retry-results.yaml)

**Create: `commands/retry.md` (NEW)**
- [ ] Create file
- [ ] Content: How to trigger auto-retry for marginal strategies

**Verification:**
- [ ] Auto-retry logic clear and testable
- [ ] Learning extraction built-in
- [ ] Max attempts enforced (no infinite retries)

---

### P1.3: Enhance Learning Extraction (4 hours)

**Update: `skills/pipeline/SKILL.md`**
- [ ] Add new "Phase 14: Automated Learning Extraction" section
- [ ] Document trigger: "on any strategy rejection"
- [ ] Agent: trading-feedback
- [ ] Procedure:
  1. Read decision.yaml (rejection reason + tier)
  2. Read backtest results if available
  3. Classify into failure taxonomy
  4. Extract: "What should we never do again?"
  5. Extract: "What could work instead?"
  6. Generate L-{next_id}.yaml
  7. Proactive injection: next 5 similar hypotheses get WARNING

**Create: `config/learning-extraction-template.yaml`**
- [ ] Create template for L-XXX entries:
  ```yaml
  learning_id: L-{NNN}
  created_date: {ISO8601}
  extracted_from: STR-{NNN}  # which strategy failure
  root_cause: {category from failure-taxonomy.yaml}

  statement: "{Concise, falsifiable statement}"
  applicable_to: [list of strategy archetypes]
  prevention: "{How to avoid this failure}"
  timestamp: {ISO8601}
  confidence: {high|medium|low}
  ```

**Verification:**
- [ ] Phase 14 added to pipeline skill
- [ ] Learning extraction automatic (no manual steps)
- [ ] Template matches existing L-XXX entries
- [ ] Proactive injection implemented

---

### P1.4: Create Paper Trading Skill (10 hours)

**Create: `skills/paper-trading/SKILL.md`**
- [ ] Create directory: `mkdir -p skills/paper-trading`
- [ ] Create file `SKILL.md`
- [ ] Add YAML front matter
- [ ] Add sections:
  - [ ] Purpose: 7-day paper trading validation
  - [ ] Trigger: "Strategy approved for deployment"
  - [ ] Stages (execution, quality gates, reporting)
  - [ ] Metrics Collection (slippage, fill rate, latency, fees)
  - [ ] Quality Gates (Sharpe >= 0.7x backtest, etc)
  - [ ] Output Format (paper-trading-report.yaml)
  - [ ] Automatic Advancement Rules

**Create: `commands/paper-trading.md` (NEW)**
- [ ] Usage: `/crypto paper-trading: STR-{NNN}`
- [ ] What it does: Runs 7-day dry run on Freqtrade
- [ ] Expected duration
- [ ] Output location

**Create: `config/paper-trading-config.yaml` (NEW)**
- [ ] Template for paper trading parameters:
  ```yaml
  paper_trading:
    duration_days: 7
    min_trades: 20
    simulated_capital: 1000
    slippage_model: "actual_spreads"  # or fixed_bps
    fee_structure: "binance_actual"

    quality_gates:
      min_sharpe_ratio_pct: 0.70  # 70% of backtest sharpe
      max_sharpe_drift_pct: 0.30
      max_winrate_drift_pct: 0.15
      max_dd_increase_pct: 0.10
  ```

**Verification:**
- [ ] SKILL.md complete with all stages
- [ ] Quality gates clearly defined and testable
- [ ] Output YAML matches decision-making criteria
- [ ] Dry run tested end-to-end

---

### P1 Testing: Integration Tests (8 hours)

**Create: `tests/test_parallel_pipeline.py` (NEW)**
- [ ] Test 3 strategies in parallel
- [ ] Verify no state collision
- [ ] Verify independent rejections
- [ ] Verify results aggregation

**Create: `tests/test_auto_retry.py` (NEW)**
- [ ] Test marginal strategy retry
- [ ] Verify parameter variation
- [ ] Verify max attempts enforced

**Create: `tests/test_learning_extraction.py` (NEW)**
- [ ] Test learning generated from rejection
- [ ] Test proactive injection to next hypothesis

**Create: `tests/test_paper_trading.py` (NEW)**
- [ ] Test 7-day paper trading run
- [ ] Verify metrics collection
- [ ] Verify quality gates applied

**Verification:**
- [ ] All 4 test files created
- [ ] Tests are runnable
- [ ] Tests verify integration (not just unit)

---

## PHASE 3: P2 Medium Priority (Week 4-5)

### P2.1: Data Schema Standardization (4 hours)

**Create: `config/data-schema.yaml` (NEW)**
- [ ] Define OHLCV schema (columns, types, validations)
- [ ] Define Funding Rate schema
- [ ] Define validation rules
- [ ] Include example CSV structures

**Update: `agents/data-collector.md`**
- [ ] Add section: "Data Validation Against Schema"
- [ ] Update procedure to validate all collected data
- [ ] Reference config/data-schema.yaml

**Update: `agents/backtester.md`**
- [ ] Add section: "Data Input Validation"
- [ ] Verify data matches schema before backtest

**Verification:**
- [ ] Schema file complete with all data types
- [ ] Both agents reference and validate against schema

---

### P2.2: Signal-Executor Interface (4 hours)

**Create: `config/signal-executor-interface.md` (NEW)**
- [ ] Define signal output format
- [ ] Define validation rules
- [ ] Define executor requirements
- [ ] Include example signal structure

**Update: `agents/signal-generator.md`**
- [ ] Add section: "Output Validation Against Interface"
- [ ] Verify generated code produces valid signals

**Update: `agents/order-executor.md` (or create)**
- [ ] Document signal input format expected
- [ ] Document validation logic

**Verification:**
- [ ] Interface document clear and unambiguous
- [ ] Both agents reference and validate

---

### P2.3: API Key Management Skill (6 hours)

**Create: `skills/api-key-management/SKILL.md` (NEW)**
- [ ] Create directory
- [ ] Document all supported APIs (Etherscan, Glassnode, etc)
- [ ] Key validation procedure
- [ ] Error recovery

**Create: `config/api-keys-template.env` (NEW)**
- [ ] Template with all supported API keys
- [ ] Instructions for obtaining each key
- [ ] Notes on free vs paid tiers

**Create: `scripts/validate-api-keys.py` (NEW)**
- [ ] Test each API key with minimal call
- [ ] Report valid/invalid/missing keys
- [ ] Provide setup instructions

**Update: `agents/external-scout.md`**
- [ ] Add section: "API Key Management"
- [ ] Link to api-key-management skill

**Verification:**
- [ ] Skill document complete
- [ ] Validation script runs successfully
- [ ] Template covers all API sources

---

## PHASE 4: End-to-End Testing (Week 5-6)

### E2E Test Suite (12 hours)

**Create: `tests/test_e2e_full_pipeline.py` (NEW)**
- [ ] Test complete pipeline: batch of 3 strategies
- [ ] Verify Phase 0: parallel Insight checks
- [ ] Verify Phase 1: parallel ideation
- [ ] Verify Phase 2: tiered validation
- [ ] Verify Phase 3: risk assessment
- [ ] Verify Phase 4: learning extraction
- [ ] Verify final approval/rejection decisions

**Create: `tests/test_e2e_parallel_execution.py` (NEW)**
- [ ] Run 5 strategies in parallel
- [ ] Monitor resource usage
- [ ] Verify no deadlocks
- [ ] Verify aggregate results correct

**Performance Benchmarking (4 hours)**
- [ ] Measure time for 1 strategy (baseline)
- [ ] Measure time for 3 parallel strategies
- [ ] Calculate speedup ratio (target: 2-3x)
- [ ] Measure memory usage

**Documentation Updates (4 hours)**
- [ ] Update README.md with new features
- [ ] Create user guide for parallel pipeline
- [ ] Create troubleshooting guide
- [ ] Document new commands

---

## Final Checklist: Pre-Release

**Code Quality**
- [ ] All Python files pass linting (flake8)
- [ ] All YAML files are valid syntax
- [ ] No hardcoded paths (use relative)
- [ ] All new features documented

**Testing**
- [ ] Unit tests pass (P0, P1, P2 features)
- [ ] Integration tests pass (interactions between agents)
- [ ] E2E tests pass (full pipeline workflows)
- [ ] Performance benchmarks meet targets

**Documentation**
- [ ] README.md updated with all new features
- [ ] All new agent specs complete and linked
- [ ] All new skills documented with examples
- [ ] Changelog updated

**Backup & Versioning**
- [ ] Git commit with P0 changes
- [ ] Git commit with P1 changes
- [ ] Git commit with P2 changes
- [ ] Tag version: v0.8.0 or v1.0.0

**Deploy**
- [ ] Test in staging environment
- [ ] Run never-end mode for 24 hours
- [ ] Verify no errors in logs
- [ ] Deploy to production
- [ ] Monitor for 1 week

---

## Time Tracking Template

Use this to track actual vs estimated hours:

| Phase | Component | Estimated | Actual | Status |
|-------|-----------|-----------|--------|--------|
| P0 | Python REPL (4 agents) | 2h | ___ | [ ] |
| P0 | LSP tools (3 agents) | 2h | ___ | [ ] |
| P0 | Create 6 agent specs | 8h | ___ | [ ] |
| P1 | Parallel pipeline | 8h | ___ | [ ] |
| P1 | Auto-retry | 6h | ___ | [ ] |
| P1 | Learning extraction | 4h | ___ | [ ] |
| P1 | Paper trading | 10h | ___ | [ ] |
| P1 | Integration tests | 8h | ___ | [ ] |
| P2 | Data schema | 4h | ___ | [ ] |
| P2 | Signal interface | 4h | ___ | [ ] |
| P2 | API key mgmt | 6h | ___ | [ ] |
| E2E | Full E2E tests | 12h | ___ | [ ] |
| E2E | Performance tuning | 4h | ___ | [ ] |
| E2E | Documentation | 4h | ___ | [ ] |
| **TOTAL** | | **110h** | **___** | |

---

## Success Criteria Checklist

After completing all phases:

**Operational Metrics**
- [ ] Can process 3+ strategies in parallel
- [ ] L0-L2 time reduced from 60+ min to 30+ min
- [ ] L0 rejection rate improved to 70%+
- [ ] Marginal strategies auto-retry instead of reject

**System Metrics**
- [ ] 6 undocumented agents now documented
- [ ] All agents have complete tool specs
- [ ] Quant agents can run Python code
- [ ] Code agents have LSP navigation

**Quality Metrics**
- [ ] Learning coverage: 60+ learnings extracted
- [ ] Paper trading validates execution quality
- [ ] Data schema prevents integration bugs
- [ ] No more API key setup friction

**Testing**
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All E2E tests pass
- [ ] Performance targets met (2-3x speedup)

---

## Rollback Plan

If any upgrade causes issues:

1. **P0 issues:** Remove tool additions, revert agent specs (git revert)
2. **P1 issues:** Disable new skills in commands, revert to single-threaded pipeline
3. **P2 issues:** Make schema/interface validation optional, keep old behavior

Keep master branch always deployable.

---

## Support Resources

**Questions?**
- See UPGRADE-PLAN.md Part 8-9 for detailed risk mitigation and success criteria
- See UPGRADE-SUMMARY.md for overview of all 11 gaps
- Each agent spec should document its integration points

**Testing issues?**
- Run `pytest tests/` for full test suite
- Run `pytest tests/test_parallel_pipeline.py -v` for specific tests
- Check logs in `.crypto/logs/` for agent errors

---

**Last Updated:** 2025-02-05
**Status:** Ready for implementation
**Next Step:** Start with P0.1 (add Python REPL) - 2 hours to unblock quantitative work
