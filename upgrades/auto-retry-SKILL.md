---
name: trading-auto-retry
description: "Automatically detect and fix validation failures at L1/L2 tiers. Use when a strategy fails validation and the failure is fixable (parameter bounds, signal thresholds). Auto-triggers when backtester detects a categorized fixable error. Up to 3 retry attempts."
user-invocable: true
argument-hint: "[STR-NNN | --tier L1 | --attempt 1-3]"
model: opus
---

# Auto-Retry with Intelligent Fixing

Detect fixable failures during L1/L2 validation and automatically generate targeted fix attempts up to 3 times before rejecting a strategy. Uses learnings from the feedback agent to inform parameter adjustments.

## Trigger Patterns

- **Auto-trigger**: When `trading-backtester` fails L1/L2 with failure reason matching `.crypto/config/fixable-errors.yaml`
- **Manual**: `/trading-auto-retry STR-{NNN} --tier L1` or `/trading-auto-retry --latest`
- **Context keywords**: "retry that", "fix and rerun", "auto-fix errors", "one more time"

## Workflow Overview

```
FAILURE ANALYSIS     CATEGORIZE           GENERATE FIX      RE-VALIDATE        VERDICT
┌──────────────┐    ┌────────────────┐    ┌───────────────┐   ┌─────────────┐   ┌────────┐
│Read results  │───▶│Check fixable   │───▶│Retry 1: ML    │──▶│Run L1/L2    │──▶│PASS ✓  │
│Parse error   │    │error patterns  │    │Engineer fix   │   │with new     │   │or FAIL │
│Lookup fixes  │    │               │    │              │   │params       │   │(3 max) │
└──────────────┘    └────────────────┘    └───────────────┘   └─────────────┘   └────────┘
                                           Retry 2: Signal Gen
                                           Retry 3: Quant Analyst
```

## Detailed Steps

### 1. Failure Analysis & Categorization

**Delegate to**: Orchestrator

- Read backtest results from `.crypto/knowledge/strategies/STR-{NNN}/backtest-results/`
  - Extract: failure reason (signal_frequency, Sharpe, parameter_bounds, etc.)
  - Extract: tier that failed (L1 or L2)
  - Extract: actual vs threshold values
- Read `.crypto/config/fixable-errors.yaml`
  - Check if failure reason matches a FIXABLE pattern
  - Extract: recommended fixing agent, action
- Read `.crypto/knowledge/learnings.md`
  - Look for historical patterns for this error type
  - Extract: what fixes worked before?

**Categorize failure**:
- **SIGNAL_ISSUE**: signal_frequency too low → adjust thresholds/windows
- **PARAMETER_BOUNDS**: parameters outside valid range → clip to bounds
- **DATA_QUALITY**: anomalies detected → use alternate data source
- **TIMEOUT**: execution exceeded limits → reduce data window
- **FATAL**: fundamental flaw → skip auto-retry

- If **FATAL**: skip to rejection, update learnings, STOP
- If **FIXABLE**: proceed to Step 2

**Output**: Failure category + recommended fix strategy

### 2. Generate Retry Attempt 1: ML Engineer Fix

**Delegate to**: `trading-ml-engineer` agent

Input to ML Engineer:
- Strategy hypothesis + parameters
- Failure info: "Sharpe=0.3 (target: 0.5)"
- Historical learnings: what parameter adjustments worked before?
- Current data spec + feature set

ML Engineer task:
- Analyze: Why did parameters underperform?
- Generate: New parameter values
  - Adjust hyperparameters (window sizes, thresholds, alphas)
  - Apply learnings from feedback agent
  - Stay within bounds: review `.crypto/config/parameter-bounds.yaml`
- Write: `.crypto/knowledge/strategies/STR-{NNN}/fix-attempt-1.yaml`
  - Include: reasoning, parameter changes, expected improvement
- Return: Fixed parameters

**If ML Engineer cannot suggest fix**: Log reason, move to Retry 2

**Output**: Fixed hypothesis + parameters in fix-attempt-1.yaml

### 3. Re-Validate Attempt 1

**Delegate to**: `trading-backtester` agent

Input to Backtester:
- Strategy with updated parameters from Retry 1
- Same tier as original failure (L1 or L2)
- Same data as original failure

Backtester task:
- Run validation with fixed parameters
- Write results to `.crypto/knowledge/strategies/STR-{NNN}/backtest-results/L1_retry1.yaml`
- Return: PASS or FAIL + metrics

**Decision**:
- If **PASS**: Move to Step 5 (Learning Extraction)
- If **FAIL**: Log result, move to Retry 2 (Step 4)

**Output**: Retry 1 validation results

### 4. Retry Attempts 2 & 3

If Retry 1 FAILED, continue:

**Retry 2: Signal Generator Fix**

Delegate to: `trading-signal-generator` agent

Input:
- Original hypothesis + failed Retry 1 results
- Failure analysis: signal issues vs parameter issues?
- Historical learnings: signal adjustments that worked?

Task:
- Review signal logic (entry/exit conditions)
- Adjust: thresholds, window sizes, confirmation rules
- Generate alternative signal approach (if applicable)
- Write: `.crypto/knowledge/strategies/STR-{NNN}/fix-attempt-2.yaml`

Re-validate with backtester:
- Run L1/L2 with new signal logic
- Write: `.crypto/knowledge/strategies/STR-{NNN}/backtest-results/L1_retry2.yaml`
- Decision: PASS → Learning Extraction, FAIL → Retry 3

**Retry 3: Quantitative Analyst Review**

Delegate to: `trading-quant-analyst` agent

Input:
- Original hypothesis + failed Retry 1 & 2 results
- Cumulative failure analysis
- Question: Is this strategy fundamentally flawed?

Task:
- Deep review of hypothesis feasibility
- Check: Are premises sound? Is market regime suitable?
- Options:
  - **Pivot**: Recommend different approach/parameters → fix-attempt-3.yaml
  - **Reject**: Hypothesis is not viable → mark for rejection
- Write: `.crypto/knowledge/strategies/STR-{NNN}/fix-attempt-3.yaml`

If pivot suggested, re-validate one final time:
- Run L1/L2 with Quant Analyst recommendation
- Write: `.crypto/knowledge/strategies/STR-{NNN}/backtest-results/L1_retry3.yaml`
- Decision: PASS → Learning Extraction, FAIL → Mark as REJECTED

**Output**: Up to 3 retry attempts with results + reasoning

### 5. Learning Extraction & Logging

**Delegate to**: `trading-feedback` agent

Whether final result is PASS or REJECTED:
- Extract learnings:
  - "What kind of fixes worked?" (if PASS)
  - "Why did all fixes fail?" (if REJECTED)
  - "Pattern: {error_type} responds well to {fix_type}"
  - "Pattern: {error_type} is unfixable when {condition}"
- Update: `.crypto/knowledge/learnings.md`
  - Add entry: "STR-{NNN} auto-retry success: {fix_type}"
  - Or: "STR-{NNN} auto-retry failed: root cause was {reason}"
- Update: `.crypto/knowledge/failure-taxonomy.yaml`
  - Increment counter for error type
  - Increment counter for fix success rate
  - Record: Success rate by fix agent (ML Engineer, Signal Gen, Quant)
- Update: `.crypto/knowledge/registry.yaml`
  - Mark strategy as PASSED_L1 (if retry succeeded)
  - Or mark as REJECTED_L1 (if all retries failed)
- Log: `.crypto/pipeline/auto-retry-log.yaml`
  - Record: STR, tier, failure, attempts, result, learnings extracted

**Output**: Strategy marked passed/rejected + learnings updated

### 6. Status Update

**Delegate to**: Orchestrator

- Update `.crypto/pipeline/queue.yaml`:
  - If PASSED: mark as "L1_PASSED" → ready for next tier
  - If REJECTED: mark as "REJECTED_AUTO_RETRY" → log reason
- Update `.crypto/BOOTSTRAP.md`:
  - Reflect new queue state
  - Show auto-retry stats: "3 attempted, 2 succeeded (67%)"
- If PASSED: continue pipeline normally (move to L2 or next validation)
- If REJECTED: extract learnings and try next strategy in queue

**Output**: Updated queue and bootstrap state

## Agents Involved

### Orchestrator
- Role: Coordinator and decider
- Responsibilities:
  - Analyze failure and categorize
  - Route to appropriate fixing agent per attempt
  - Trigger backtester re-validation
  - Track retry count and cumulative results

### ML Engineer (Retry 1)
- Role: Parameter optimizer
- Responsibilities:
  - Adjust model hyperparameters
  - Apply learned parameter bounds
  - Suggest optimizations based on failure metrics

### Signal Generator (Retry 2)
- Role: Signal logic refiner
- Responsibilities:
  - Review and adjust signal thresholds
  - Refine entry/exit logic
  - Propose alternative signal approaches

### Quantitative Analyst (Retry 3)
- Role: Fundamental reviewer
- Responsibilities:
  - Deep review of hypothesis viability
  - Assess if strategy is fundamentally sound
  - Recommend pivots or rejection

### Backtester (per retry)
- Role: Re-validator
- Responsibilities:
  - Run L1/L2 with fixed parameters
  - Write retry results to isolated files
  - Report pass/fail + metrics

### Feedback Agent (final)
- Role: Learning extractor
- Responsibilities:
  - Extract what worked/didn't
  - Update learnings and failure taxonomy
  - Inform future auto-retry decisions

## Tools & Capabilities Required

### New Tools Needed

```yaml
analyze_failure_reason:
  signature: analyze_failure_reason(backtest_result)
  outputs:
    category: "SIGNAL_ISSUE | PARAMETER_BOUNDS | DATA_QUALITY | TIMEOUT | FATAL"
    metrics:
      actual_value: N
      threshold_value: N
      gap: N
    fixable: boolean
    recommended_agents: [agent1, agent2, agent3]

generate_parameter_fix:
  signature: generate_parameter_fix(failure_category, hypothesis, learnings)
  outputs:
    fixed_parameters: {yaml}
    reasoning: string
    expected_improvement: "Sharpe: 0.3 → 0.45"

apply_fix_to_strategy:
  signature: apply_fix_to_strategy(strategy_id, fix_spec)
  outputs:
    updated_hypothesis: {yaml}
    updated_parameters: {yaml}
    backup_created_at: path

track_retry_attempt:
  signature: track_retry_attempt(strategy_id, attempt_num, agent_used, result)
  outputs:
    attempt_record: {yaml}
    cumulative_status: "N_PASSED_M_FAILED"
```

### Existing Tools Used

- **File I/O**: Read/write strategy folders, learnings, failure taxonomy, logs
- **Agent delegation**: backtester, ml-engineer, signal-generator, quant-analyst, feedback
- **Status tracking**: Update queue, registry, bootstrap

### Resource Requirements

- **Max retries**: 3 per strategy
- **Time per retry**: 5-30 min depending on tier
  - L1 retry: ~7 minutes
  - L2 retry: ~30 minutes
- **Total wall-clock**: Max ~90 minutes per strategy (3 L2 retries)
- **Storage**: ~10MB per strategy for 3 fix attempts + results

## Configuration

Add to `.crypto/config/auto-retry.yaml`:

```yaml
auto_retry:
  # Enable/disable per tier
  enabled_tiers:
    L0: false              # Don't retry L0 (fast tier, not worth complexity)
    L1: true
    L2: true
    L3: false              # Don't retry L3 (already expensive)

  max_attempts_per_strategy: 3
  attempt_timeout_seconds: 1800  # 30 min per attempt

  # Fixable error categories
  fixable_errors:
    signal_frequency_low:
      fix_agent: signal-generator
      action: reduce_threshold
      backoff_factor: 0.9  # Lower threshold by 10%
      retry: true

    signal_frequency_high:
      fix_agent: signal-generator
      action: increase_threshold
      backoff_factor: 1.1
      retry: true

    sharpe_below_threshold:
      fix_agent: ml-engineer
      action: optimize_params
      retry: true

    parameter_out_of_bounds:
      fix_agent: ml-engineer
      action: clip_to_bounds
      retry: true

    win_rate_suspicious:
      fix_agent: signal-generator
      action: verify_signal_logic
      retry: true

    data_quality_warning:
      fix_agent: data-collector
      action: use_alternate_source
      retry: true

    max_drawdown_extreme:
      fix_agent: ml-engineer
      action: reduce_leverage
      retry: true

    timeout:
      fix_agent: orchestrator
      action: reduce_data_window
      retry: true

  # Non-fixable errors (auto-reject)
  fatal_errors:
    - fundamental_strategy_flaw
    - data_unavailable
    - unsupported_asset_type
    - hypothesis_contradiction
    - asset_delisted

  # Learning injection
  learning_injection:
    feedback_agent_enabled: true
    update_learnings_on_success: true
    update_failure_taxonomy_on_final_fail: true
    track_agent_success_rates: true    # Per-agent (ML vs Signal vs Quant)

  # Escalation
  escalate_on_all_fail: true
    escalation_recipients: [user]      # Notify user if all 3 retries fail
    include_learnings: true

  # Metrics
  track_metrics: true
  log_path: ".crypto/pipeline/auto-retry-log.yaml"
```

## Integration Points

### Triggers
- **Auto-trigger**: When `trading-backtester` returns FAILED with categorized error
- **Manual**: `/trading-auto-retry STR-{NNN} --tier L1`

### Upstream Dependencies
- `trading-backtester` (must detect and categorize failure)
- Strategy hypothesis + data must be in `.crypto/knowledge/strategies/`
- Learnings database must exist at `.crypto/knowledge/learnings.md`

### Downstream Integration
- Feeds to: `trading-pipeline` Phase 2 (continue if PASS)
- Feeds to: `trading-evaluate` skill (for post-pass review)
- Updates: `.crypto/pipeline/queue.yaml`, registry, learnings
- If rejected: Try next strategy in queue

## Error Handling

### Retry Agent Crashes (e.g., ML Engineer fails)
1. Catch exception, log error
2. Move to next retry agent (attempt 2)
3. If all 3 agents crash: escalate to user, mark strategy as ERROR

### Backtester Timeout (Retry takes >1800s)
1. Kill hanging backtester
2. Log: "Retry {N} timeout, moving to next attempt"
3. After 3 timeouts: mark as TIMEOUT_FAILED, reject

### Learning Extraction Failure
1. Log error but don't halt
2. Strategy is still marked passed/rejected correctly
3. Learnings will be extracted next time same error occurs

### No Fixable Pattern Found
1. Log: "Unknown failure category"
2. Route to Quant Analyst for manual review
3. Treat as Retry 3 decision

## Monitoring & Metrics

### Key Metrics

```yaml
auto_retry_metrics:
  run_period: "2025-02-01 to 2025-02-28"
  total_auto_retries_triggered: 12
  successful_retries: 8
  success_rate_percent: 66.7

  by_tier:
    L1:
      triggered: 8
      successful: 6
      success_rate: 75%
    L2:
      triggered: 4
      successful: 2
      success_rate: 50%

  by_agent:
    ml_engineer:
      triggered: 8
      successful: 6
      success_rate: 75%
    signal_generator:
      triggered: 3
      successful: 2
      success_rate: 67%
    quant_analyst:
      triggered: 1
      successful: 0
      success_rate: 0%

  by_error_type:
    signal_frequency_low: {triggered: 4, successful: 3, rate: 75%}
    sharpe_below_threshold: {triggered: 5, successful: 4, rate: 80%}
    parameter_out_of_bounds: {triggered: 3, successful: 1, rate: 33%}
```

### Alerts & Warnings

- **Alert**: If success rate drops below 50% (algo adjustment needed)
- **Alert**: If retry takes >3× median time (system slowdown)
- **Warning**: If same error repeats >3× per week (pattern to fix)

### Dashboard Location

Track metrics in: `.crypto/live-monitoring/auto-retry-metrics.yaml`

Update after each retry, retain last 100 runs.

## Examples

### Example 1: Sharpe Fix Success (ML Engineer)

**Setup**:
- STR-150 fails L1 with "Sharpe=0.3 (target: 0.5)"
- Auto-retry triggered automatically

**Execution**:
1. Orchestrator analyzes: category = SHARPE_BELOW_THRESHOLD
2. Delegates to ML Engineer: "Optimize parameters to improve Sharpe"
3. ML Engineer adjusts window sizes, alpha values
4. Writes fix-attempt-1.yaml: "Adjusted lookback 20→15, alpha 0.3→0.25"
5. Backtester re-runs L1 with new params
6. Results: Sharpe=0.51 → **PASS**
7. Feedback Agent logs learning: "STR-150: ML Engineer fix worked, shorter lookback improved Sharpe"
8. Strategy marked L1_PASSED, moves to L2

**Output**: Strategy recovered and promoted

### Example 2: Signal Fix Success (Signal Generator)

**Setup**:
- STR-151 fails L2 with "signal_frequency=5 (minimum: 10)"
- Auto-retry triggered

**Execution**:
1. Orchestrator analyzes: category = SIGNAL_FREQUENCY_LOW
2. Retry 1: ML Engineer tries param adjustment
   - Backtester re-runs: signal_frequency=7 (still fails)
3. Retry 2: Signal Generator adjusts signal thresholds
   - Lowers entry threshold 0.5→0.3 (more signals)
   - Writes fix-attempt-2.yaml
   - Backtester re-runs: signal_frequency=12 → **PASS**
4. Feedback Agent logs: "STR-151: Signal gen fix worked, threshold reduction doubled signals"
5. Strategy marked L2_PASSED, ready for L3

**Output**: Strategy advanced via Signal Generator fix

### Example 3: All Retries Failed → Rejection

**Setup**:
- STR-152 fails L1 with "Sharpe=-0.1 (target: 0.5)"
- Auto-retry triggered

**Execution**:
1. Orchestrator analyzes: category = SHARPE_BELOW_THRESHOLD
2. Retry 1: ML Engineer attempts parameter optimization
   - Backtester re-runs: Sharpe=0.0 (failed)
3. Retry 2: Signal Generator attempts signal logic revision
   - Backtester re-runs: Sharpe=-0.2 (worse!)
4. Retry 3: Quant Analyst reviews
   - Analysis: "Hypothesis fundamentally flawed for current regime"
   - Recommendation: Reject and move on
5. Feedback Agent logs learnings:
   - "STR-152: All retries failed, root cause = poor regime fit"
   - Updates failure-taxonomy: "regime_unfitness" count += 1
6. Strategy marked REJECTED_AUTO_RETRY
7. Queue moves to next strategy

**Output**: Strategy rejected with learnings extracted for future guidance

## Success Metrics

- **Auto-fix success rate**: Target >60% (2 of 3 fixable strategies recovered)
- **Average retry count**: <1.5 per strategy (most fixed on first try)
- **Total time saved**: 20-30% reduction vs manual debugging
- **Learning quality**: >80% of extractions actionable for future strategies
