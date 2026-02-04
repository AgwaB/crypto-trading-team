---
name: trading-parallel-validation
description: "Accelerate L0 validation by running multiple backtests concurrently. Use when the strategy queue has multiple pending validations, or say 'validate faster', 'parallel checks', or 'speed up validation'. Auto-triggers when trading-pipeline reaches Phase 2 with queue depth >1."
user-invocable: true
argument-hint: "[--queue-size N | --workers 2-4 | --dry-run]"
model: sonnet
---

# Parallel Validation

Run multiple L0 validation checks concurrently across different strategies to accelerate the tiered validation pipeline. Instead of validating sequentially (N×5 minutes), validate in parallel (5 minutes).

## Trigger Patterns

- **Auto-trigger**: When `trading-pipeline` reaches Phase 2 with 2+ pending strategies
- **Manual**: `/trading-parallel-validation --workers 3` or `/trading-parallel-validation --queue-size 5`
- **Context keywords**: "validate faster", "parallel checks", "speed up", "concurrent"

## Workflow Overview

```
PRE-FLIGHT          SPAWN WORKERS        MONITOR            MERGE & GATE
┌─────────────┐     ┌──────────────┐    ┌──────────────┐    ┌────────────┐
│Read queue   │────▶│Worker 1: STR │────▶│Poll results  │────▶│Aggregate   │
│Count items  │     │Worker 2: STR │    │every 5s      │    │results     │
│Compute max  │     │Worker 3: STR │    │              │    │Update queue│
│parallelism  │     │Worker 4: STR │    └──────────────┘    └────────────┘
└─────────────┘     └──────────────┘
```

## Detailed Steps

### 1. Pre-Flight Check

**Delegate to**: Orchestrator

- Read `.crypto/pipeline/queue.yaml`
  - Count pending strategies (N)
  - Identify which are awaiting L0 validation
- Determine max parallelism: `min(N, 4)` workers
  - Never exceed 4 concurrent backtester agents
  - Respect system resource limits
- Read `.crypto/config/parallel-validation.yaml` for settings
- Validate configuration is sensible
- Write execution plan to `.crypto/pipeline/parallel-validation-{DATE}.yaml`

**Output**: Execution plan with worker count and strategy assignments

### 2. Spawn Parallel Validators

**Delegate to**: Orchestrator + Backtester (×N)

For each strategy in queue (up to 4 concurrent):
- Spawn `trading-backtester` agent with:
  - `--tier L0`
  - `--strategy-id STR-{NNN}`
  - `--config-override {"timeout_seconds": 600, "workers": 1}`
  - `--output-dir .crypto/knowledge/strategies/STR-{NNN}/backtest-results/`
- Each backtester runs independently with isolated data/config
- Record worker spawn time and assignment
- Update `.crypto/pipeline/queue.yaml` with "L0_VALIDATING" status per strategy

**Output**: 2-4 concurrent backtester processes running

### 3. Monitor Workers

**Delegate to**: Orchestrator (polling loop)

While any worker is running:
- Poll each worker's result file every 5 seconds
  - Check for completion flag in `.crypto/knowledge/strategies/STR-{NNN}/backtest-results/L0_complete.yaml`
  - Record actual completion time vs estimated
  - Detect timeouts (>600 seconds) and escalate
- Track wall-clock time elapsed
- If worker crashes: log error, mark strategy as FAILED_TIMEOUT
- Keep running poll until all workers done

**Output**: Per-worker completion status with timing

### 4. Merge Results

**Delegate to**: Orchestrator

Once all workers complete:
- Collect results from all strategy folders
  - Read `.crypto/knowledge/strategies/STR-{NNN}/backtest-results/L0_results.yaml`
  - Extract: pass/fail + metrics (signal_frequency, hit_rate, IC, etc.)
- Deduplicate: ensure no strategy processed twice
- Categorize:
  - **PASS**: Met all L0 gates → proceed to L1
  - **FAIL**: Failed gate → auto-reject or queue for auto-retry
  - **TIMEOUT**: No result after 600s → retry once
- Sort results by execution time (identify slow strategies)
- Calculate compute savings: `(N-1) × 5 min` saved vs sequential

**Output**: Merged results summary + per-strategy status updates

### 5. Gate Determination & Queue Update

**Delegate to**: Orchestrator

Based on merged results:

**If all strategies PASS**:
- Update `.crypto/pipeline/queue.yaml`: mark all as "L0_PASSED"
- If auto-escalating to L1: invoke `trading-parallel-validation --tier L1` automatically
- Log success: "All N strategies passed L0 in ~5 min"
- Update `.crypto/BOOTSTRAP.md` with new queue state

**If mixed PASS/FAIL**:
- Segregate into two groups:
  - **PASSED**: mark "L0_PASSED" → ready for L1
  - **FAILED**: mark "L0_FAILED" → check for auto-retry eligibility
- If failed >50%: escalate to user with options:
  - Retry with relaxed thresholds?
  - Run strategy meeting to generate new ideas?
  - Continue with remaining PASSED strategies?
- Update queue and BOOTSTRAP

**If all strategies FAIL**:
- Mark all as "L0_FAILED"
- Aggregate failure reasons into `.crypto/pipeline/parallel-validation-failures-{DATE}.yaml`
- Check if failures are fixable:
  - If yes: queue for `trading-auto-retry` skill
  - If no: escalate to user, suggest new ideas
- Update queue

**Output**: Updated `.crypto/pipeline/queue.yaml` + user notification

## Agents Involved

### Orchestrator
- Role: Coordinator and decider
- Responsibilities:
  - Pre-flight: validate queue state, compute parallelism
  - Worker spawning: launch 2-4 backtester agents
  - Monitoring: poll results, detect timeouts
  - Merging: aggregate and categorize results
  - Gate logic: decide next steps based on pass/fail distribution

### Backtester (×2-4 concurrent)
- Role: L0 validator
- Responsibilities:
  - Load strategy hypothesis + parameters
  - Load data (6 months, 1 asset, default params)
  - Run backtest with L0 config (fast, 30-second target)
  - Check gates: signal_frequency > 10, hit_rate ≠ 50%, IC > 0.01
  - Write results to isolated output file
  - Signal completion with `L0_complete.yaml` flag

## Tools & Capabilities Required

### New Tools Needed

```yaml
spawn_parallel_worker:
  signature: spawn_parallel_worker(agent_id, task_spec, timeout_seconds)
  inputs:
    agent_id: "oh-my-claudecode:backtester"
    task_spec:
      strategy_id: "STR-{NNN}"
      tier: "L0"
      output_dir: "path/to/output"
    timeout_seconds: 600
  outputs:
    worker_id: "WORKER-{UUID}"
    spawn_time: "ISO8601"

poll_worker_result:
  signature: poll_worker_result(worker_id, max_polls=120, interval_seconds=5)
  inputs:
    worker_id: "WORKER-{UUID}"
    result_file: "path/to/L0_complete.yaml"
  outputs:
    status: "RUNNING | COMPLETED | TIMEOUT | ERROR"
    result: {backtest metrics}
    elapsed_seconds: N

merge_validation_results:
  signature: merge_validation_results(results_list)
  inputs:
    results_list:
      - {strategy_id, pass/fail, metrics}
      - ...
  outputs:
    pass_count: N
    fail_count: M
    savings_minutes: (N-1)*5
    by_strategy: {STR-NNN: status}

update_queue_status:
  signature: update_queue_status(strategy_id, tier, status)
  inputs:
    strategy_id: "STR-{NNN}"
    tier: "L0"
    status: "VALIDATING | PASSED | FAILED | TIMEOUT"
  outputs:
    updated_queue_entry: {yaml}
```

### Existing Tools Used

- **File I/O**: Read/write `.crypto/pipeline/queue.yaml`, strategy folders, results
- **Agent delegation**: Backtester agent spawning and management
- **Status updates**: Update `.crypto/BOOTSTRAP.md`, `.crypto/pipeline/parallel-validation-{DATE}.yaml`

### Resource Requirements

- **Parallelism**: 2-4 concurrent backtester agents
- **Memory**: ~200MB per backtester worker (limited data set, 6 months)
- **CPU**: 1 core per worker (non-blocking I/O dominated)
- **Wall-clock time**: ~5 minutes for N strategies (vs N×5 minutes sequential)
- **Timeout per worker**: 600 seconds (10 minutes, 2× typical L0 time)

## Configuration

Add to `.crypto/config/parallel-validation.yaml`:

```yaml
parallel_validation:
  # Parallelism limits
  max_workers: 4
  min_queue_depth_for_parallel: 2     # Only parallelize if 2+ pending

  # Timeouts & retry
  worker_timeout_seconds: 600          # 10 min timeout per worker
  l0_timeout_multiplier: 1.0           # L0 is quick, no padding
  l1_timeout_multiplier: 1.5           # L1 could timeout, add buffer
  polling_interval_seconds: 5          # Check results every 5s
  max_polling_attempts: 120            # 120 × 5s = 10 min total

  # Failure handling
  fail_fast: false                      # Don't halt on first failure
  auto_escalate_threshold: 0.5          # If >50% fail, escalate to user
  auto_retry_fixable: true              # Queue failed strategies for auto-retry

  # Resource limits
  resource_limits:
    memory_per_worker_mb: 200
    cpu_percent_per_worker: 30

  # Metrics & monitoring
  track_worker_performance: true
  log_worker_times: true
  alert_on_outliers: true               # Alert if worker takes >2× median
```

## Integration Points

### Triggers
- **Auto-trigger**: `trading-pipeline` Phase 2, queue depth ≥2
- **Manual trigger**: `/trading-parallel-validation --workers 3`

### Upstream Dependencies
- `trading-pipeline` (Phase 1) must complete before L0 validation
- Strategy data + hypothesis must be ready in `.crypto/knowledge/strategies/`

### Downstream Integration
- Feeds to: `trading-parallel-validation` (L1 tier) if all L0 pass
- Feeds to: `trading-auto-retry` if fixable failures detected
- Feeds to: `trading-evaluate` for post-validation review
- Updates: `.crypto/pipeline/queue.yaml`, `.crypto/BOOTSTRAP.md`

## Error Handling

### Timeout (Worker exceeds 600 seconds)
1. Mark worker as TIMEOUT
2. Log: `{strategy_id} L0 validation timed out after 600s`
3. Retry once with fresh backtester
4. If retry also times out: mark as FAILED, check if fixable
5. Escalate if 3+ workers timeout in single run

### Worker Crash (Unexpected exit)
1. Detect: Polling detects no result file after timeout
2. Log: `Worker crashed: {worker_id}`
3. Attempt recovery: Spawn new backtester for same strategy
4. If 3 recovery attempts fail: mark strategy as ERROR, escalate

### API/Data Failure (Backtester can't fetch data)
1. Backtester writes error to result file
2. Orchestrator reads and categorizes: DATA_UNAVAILABLE
3. Mark strategy as FAILED (non-fixable)
4. Log learning: "Data unavailable for {asset}" in failure taxonomy

### Partial Failure (Some workers complete, others timeout)
1. Wait for all running workers (don't kill early)
2. Merge available results
3. Categorize timeouts as TIMEOUT status (distinct from FAILED)
4. Decide: Retry timeouts? Escalate? Continue with others?
5. Update queue with mixed status

## Monitoring & Metrics

### Key Metrics

```yaml
parallel_validation_metrics:
  run_date: "2025-02-05T14:30:00Z"
  workers_spawned: 3
  workers_completed: 3
  workers_timeout: 0
  strategies_passed: 3
  strategies_failed: 0
  wall_clock_minutes: 5.2
  sequential_equivalent_minutes: 15     # 3 × 5 min
  compute_saved_minutes: 9.8
  compute_saved_percent: 65.3
  average_worker_time_seconds: 312
  max_worker_time_seconds: 325
  min_worker_time_seconds: 295
```

### Alerts & Warnings

- **Alert**: Any worker takes >2× median time (slow worker detection)
- **Alert**: >50% of strategies fail L0 (quality issue)
- **Alert**: Timeout rate >20% (system overload)
- **Warning**: Queue depth grows while validating (throughput < incoming)

### Dashboard Location

Track metrics in: `.crypto/live-monitoring/parallel-validation-metrics.yaml`

Update every run, retain last 30 runs.

## Examples

### Example 1: All Pass

**Setup**:
- Queue has 3 pending strategies: STR-201, STR-202, STR-203
- User invokes: `/trading-parallel-validation --workers 3`

**Execution**:
1. Orchestrator reads queue, spawns 3 workers
2. Worker 1 validates STR-201 (completes in 312s, PASS)
3. Worker 2 validates STR-202 (completes in 305s, PASS)
4. Worker 3 validates STR-203 (completes in 318s, PASS)
5. Orchestrator merges results: all PASS
6. Updates queue: all marked "L0_PASSED"
7. User notified: "All 3 strategies passed L0 validation in 5.3 minutes (saved 9.7 min vs sequential)"

**Output**: Queue ready for L1 parallel validation

### Example 2: Mixed Pass/Fail

**Setup**:
- Queue has 4 pending strategies
- User runs parallel validation

**Execution**:
1. Orchestrator spawns 4 workers
2. STR-204: PASS (298s)
3. STR-205: FAIL (signal_frequency=8 < 10 threshold) (187s)
4. STR-206: PASS (334s)
5. STR-207: FAIL (hit_rate=49.8%, too close to 50%) (201s)
6. Orchestrator segregates: 2 PASS, 2 FAIL
7. Checks fixable errors: both are parameter-related → queue for auto-retry
8. Updates queue: STR-204, STR-206 → "L0_PASSED", STR-205, STR-207 → "FIXABLE_FAILURE"
9. User notified: "2 passed, 2 found fixable issues (auto-retry enabled)"

**Output**: PASSED strategies proceed to L1, FAILED strategies queue for auto-retry skill

### Example 3: Timeout Handling

**Setup**:
- Queue has 2 pending strategies
- One strategy has unexpectedly large dataset

**Execution**:
1. Orchestrator spawns 2 workers
2. Worker 1 (STR-208): Completes normally in 315s, PASS
3. Worker 2 (STR-209): No result after 600s → TIMEOUT
4. Orchestrator retries STR-209 with fresh worker
5. Retry completes in 425s (slower dataset confirmed) → PASS
6. Merges final results: 2 PASS (1 retry needed)
7. Updates queue, logs: "STR-209 required retry due to data size"
8. Updates learnings: "Large datasets may need >600s for L0"

**Output**: Both strategies PASSED, learnings updated

## Success Metrics

- **Speedup**: Achieve 3-4× wall-clock reduction vs sequential
- **Reliability**: 99%+ worker completion rate (timeouts rare)
- **Resource efficiency**: <200MB per worker, <30% CPU utilization
- **Queue throughput**: Process 8+ strategies per hour in parallel
