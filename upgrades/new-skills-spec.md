# New Skills Specifications - Crypto Trading Team Plugin

This document specifies 5 new skills to address identified gaps in the crypto-trading-team plugin. Each skill includes purpose, triggers, workflow, agents involved, and requirements.

---

## Skill 1: parallel-validation

### Purpose
Run multiple L0 validations concurrently to accelerate the tiered validation pipeline. Instead of running L0 checks sequentially, spawn parallel backtester agents to validate multiple aspects simultaneously, then merge results before proceeding to L1.

### Trigger Patterns
- Auto-trigger: When `trading-pipeline` skill reaches Phase 2 with multiple strategies in queue
- Manual: `/trading-parallel-validation --queue-size 3`
- Context: When user says "speed up validation", "parallel checks", or "validate faster"

### Workflow Steps

```
1. PRE-FLIGHT
   └─ Read .crypto/pipeline/queue.yaml
   └─ Count pending strategies (N)
   └─ Determine max parallelism (min(N, 4))

2. SPAWN PARALLEL VALIDATORS (concurrent)
   ├─ Worker 1: L0 check on STR-{NNN} (backtester agent)
   ├─ Worker 2: L0 check on STR-{NNN+1}
   ├─ Worker 3: L0 check on STR-{NNN+2}
   ├─ Worker 4: L0 check on STR-{NNN+3}
   └─ MAX: 4 concurrent backtester agents

3. MONITORING (parallel loop)
   └─ Poll each worker's result file (5s intervals)
   └─ Record completion time, resource usage

4. MERGE RESULTS
   ├─ Collect all pass/fail decisions
   ├─ Update .crypto/pipeline/queue.yaml with L0 status
   ├─ Calculate total compute time saved (vs sequential)
   └─ Flag any errors or timeouts

5. GATE DETERMINATION
   ├─ If all PASS → update queue, proceed to parallel L1
   ├─ If mixed → segregate into PASS/FAIL queues
   ├─ If all FAIL → escalate to strategy meeting
   └─ Update .crypto/BOOTSTRAP.md with parallelism stats
```

### Agents Involved
- **Orchestrator** (primary coordinator)
  - Spawns and monitors parallel workers
  - Manages result aggregation
  - Handles timeouts and failures

- **Backtester** (×N, 2-4 concurrent instances)
  - Executes L0 validation with isolated data/config
  - Writes results to isolated output paths
  - Reports back with pass/fail + metrics

### Tools & Capabilities Required

**New Tools:**
- `spawn-parallel-worker(agent_id, task_spec, timeout=600s)` - Spawn isolated agent worker
- `poll-worker-result(worker_id, poll_interval=5s)` - Check worker completion
- `merge-validation-results(results_list)` - Aggregate and deduplicate results
- `update-queue-status(strategy_id, tier, status)` - Update pipeline queue atomically

**Existing Tools Used:**
- File I/O: Read/write `.crypto/pipeline/queue.yaml`, strategy folders
- LSP Diagnostics: Check for errors in backtester outputs

**Resource Requirements:**
- Parallel slots: 2-4 concurrent backtester agents
- Memory: ~200MB per backtester worker
- Wall-clock time: Reduced from N×5min to ~5min for N strategies

### Configuration Additions

Add to `.crypto/config/parallel-validation.yaml`:
```yaml
parallel_validation:
  max_workers: 4
  worker_timeout_seconds: 600
  l0_timeout_multiplier: 1.0    # L0 is quick, no padding needed
  l1_timeout_multiplier: 1.5    # L1 gets 7.5 min per worker
  polling_interval_seconds: 5
  fail_fast: false              # Continue even if one fails
  auto_escalate_threshold: 0.5  # If >50% fail, escalate to meeting
  resource_limits:
    memory_per_worker_mb: 200
    cpu_percent_per_worker: 30
```

---

## Skill 2: auto-retry

### Purpose
Detect fixable failures at L1/L2 tiers and automatically generate and attempt fixes up to 3 times before marking a strategy as rejected. Applies learnings from the feedback agent to fix parameter issues, signal logic errors, or data quality problems.

### Trigger Patterns
- Auto-trigger: When `trading-backtester` fails L1/L2 and failure reason is "fixable"
- Manual: `/trading-auto-retry STR-{NNN} --tier L1`
- Context: When user says "retry that", "fix and rerun", or "auto-fix errors"

### Workflow Steps

```
1. FAILURE ANALYSIS
   └─ Read backtest results from .crypto/knowledge/strategies/STR-{NNN}/
   └─ Parse failure reason (signal frequency, Sharpe, parameter bounds, etc.)
   └─ Check .crypto/config/fixable-errors.yaml for fix patterns
   └─ Determine if failure is FIXABLE vs FATAL

2. CATEGORIZE FAILURE
   ├─ SIGNAL_ISSUE → adjust signal thresholds or window sizes
   ├─ PARAMETER_BOUNDS → clip parameters to valid ranges
   ├─ DATA_QUALITY → flag and retry with alternate data source
   ├─ TIMEOUT → retry with reduced data window
   └─ FATAL → skip auto-retry, mark rejected

3. GENERATE FIX ATTEMPT (×3 max)
   ├─ Retry 1: Delegate to `trading-ml-engineer`
   │           Read hypothesis + feedback learnings
   │           Auto-generate parameter adjustment
   │           Write .crypto/knowledge/strategies/STR-{NNN}/fix-attempt-1.yaml
   │
   ├─ Retry 2: If Retry 1 still fails
   │           Delegate to `trading-signal-generator`
   │           Adjust signal logic or thresholds
   │           Write fix-attempt-2.yaml
   │
   └─ Retry 3: If Retry 2 still fails
               Delegate to `trading-quant-analyst`
               Review hypothesis feasibility
               Recommend pivot or reject
               Write fix-attempt-3.yaml

4. RE-VALIDATE (post-fix)
   ├─ Spawn backtester with same tier as original failure
   ├─ Use fixed parameters/hypothesis
   ├─ Compare results to original failure
   ├─ If PASS → proceed normally (log success)
   ├─ If FAIL → move to next retry (up to 3)
   └─ After 3 fails → mark as rejected, extract learnings

5. LEARNING EXTRACTION & LOGGING
   ├─ Delegate to `trading-feedback` agent
   ├─ Extract: What kind of fix worked? What didn't?
   ├─ Update .crypto/knowledge/learnings.md
   ├─ Record in .crypto/knowledge/failure-taxonomy.yaml
   └─ Update success rate stats for auto-retry skill
```

### Agents Involved
- **Orchestrator** (coordinator & decider)
  - Analyzes failure reason
  - Routes to appropriate fixing agent
  - Tracks retry count & results

- **ML Engineer** (retry 1)
  - Adjusts model parameters and hyperparameters
  - Applies learned parameter bounds

- **Signal Generator** (retry 2)
  - Refines signal logic
  - Adjusts thresholds and window sizes

- **Quantitative Analyst** (retry 3)
  - Reviews fundamental hypothesis
  - Recommends pivots or rejection

- **Feedback Agent** (learning extraction)
  - Captures what fixes worked
  - Updates learnings database

### Tools & Capabilities Required

**New Tools:**
- `analyze-failure-reason(backtest_result)` - Parse failure message and categorize
- `generate-parameter-fix(failure_category, hypothesis, learnings)` - Auto-suggest fixes
- `apply-fix-to-strategy(strategy_id, fix_spec)` - Update hypothesis/parameters
- `track-retry-attempt(strategy_id, attempt_num, result)` - Log retry metrics

**Existing Tools Used:**
- File I/O: Read/write strategy folders, learnings, failure taxonomy
- Agent delegation: backtester, ml-engineer, signal-generator, quant-analyst, feedback

**Resource Requirements:**
- Max retries: 3 per strategy
- Time per retry: 5-30 min depending on tier
- Storage: ~10MB per strategy for fix attempts + results

### Configuration Additions

Add to `.crypto/config/auto-retry.yaml`:
```yaml
auto_retry:
  max_attempts: 3
  enabled_tiers: [L1, L2]        # Don't retry L0 (fast) or L3 (expensive)

  fixable_errors:
    - signal_frequency_low:
        fix_agent: signal-generator
        action: reduce_threshold
        retry: true
    - parameter_out_of_bounds:
        fix_agent: ml-engineer
        action: clip_to_bounds
        retry: true
    - sharpe_below_threshold:
        fix_agent: ml-engineer
        action: optimize_params
        retry: true
    - data_quality_warning:
        fix_agent: data-collector
        action: use_alternate_source
        retry: true
    - timeout:
        fix_agent: orchestrator
        action: reduce_data_window
        retry: true

  fatal_errors:
    - fundamental_strategy_flaw
    - data_unavailable
    - unsupported_asset_type

  learning_injection:
    feedback_agent_enabled: true
    update_learnings_on_success: true
    update_failure_taxonomy_on_final_fail: true
```

---

## Skill 3: scheduled-discovery

### Purpose
Implement cron-like scheduling for the External Scout agent to run daily Twitter scans and weekly arXiv scans automatically, queueing discovered findings for the strategy meeting.

### Trigger Patterns
- Auto-trigger: Scheduled via cron (daily 06:00 UTC, weekly 14:00 UTC Friday)
- Manual: `/trading-scheduled-discovery --source twitter` or `--source arxiv`
- Context: When user says "run discovery", "find ideas", or "scan for opportunities"

### Workflow Steps

```
1. SCHEDULER CHECK (cron/background)
   ├─ Is it 06:00 UTC? → RUN_TWITTER_SCAN
   ├─ Is it Friday 14:00 UTC? → RUN_ARXIV_SCAN
   └─ Update .crypto/config/discovery-schedule.yaml with last run time

2. TWITTER SCAN (daily)
   ├─ Delegate to `trading-external-scout`
   ├─ Query parameters:
   │  ├─ Topics: crypto trading, defi, arbitrage, yield farming, etc.
   │  ├─ Lookback: last 24 hours
   │  ├─ Minimum engagement: 100 retweets + likes combined
   │  └─ Exclude: shitcoin shills, obvious scams
   ├─ Scout collects tweets → hypothesis drafts
   ├─ Write results to .crypto/discovery/twitter-scan-{DATE}.yaml
   └─ Update .crypto/discovery/queue.yaml with findings

3. ARXIV SCAN (weekly)
   ├─ Delegate to `trading-external-scout`
   ├─ Query parameters:
   │  ├─ Categories: quant-ph, stat.AP, cs.LG (machine learning applications)
   │  ├─ Search terms: arbitrage, market microstructure, signal processing, etc.
   │  ├─ Lookback: last 7 days
   │  └─ Filter: peer-reviewed or highly cited preprints
   ├─ Scout reviews papers → hypothesis drafts
   ├─ Write results to .crypto/discovery/arxiv-scan-{DATE}.yaml
   └─ Update .crypto/discovery/queue.yaml with findings

4. DEDUPLICATION & QUEUEING
   ├─ Read existing .crypto/discovery/queue.yaml
   ├─ Delegate to `trading-insight` agent
   ├─ Compare new findings against known strategies (registry)
   ├─ DUPLICATE → discard, log in dedup-log.yaml
   ├─ SIMILAR → flag for differentiation in strategy meeting
   ├─ NOVEL → add to queue with priority score
   └─ Update .crypto/discovery/queue.yaml (sorted by priority)

5. MEETING AUTO-QUEUE
   ├─ If queue has NOVEL items with priority > threshold
   ├─ Auto-schedule strategy meeting (if not already scheduled)
   ├─ Send notification to user: "X new opportunities found"
   ├─ Update .crypto/BOOTSTRAP.md discovery status
   └─ Record scan stats in .crypto/discovery/scan-stats.yaml

6. ERROR HANDLING
   ├─ If Twitter/arXiv API fails → log error, retry on next schedule
   ├─ If Scout crashes → alert user, re-run manual scan
   ├─ If network timeout → exponential backoff, max 5 retries
   └─ Update .crypto/discovery/discovery-errors.yaml
```

### Agents Involved
- **External Scout** (primary agent)
  - Scans Twitter for trading ideas
  - Reviews arXiv papers for novel approaches
  - Generates hypothesis drafts from findings

- **Insight Agent** (deduplication)
  - Compares findings against registry
  - Scores novelty and priority

- **Orchestrator** (scheduling & queueing)
  - Manages cron schedule
  - Routes scans to Scout
  - Updates queues and notifies user

### Tools & Capabilities Required

**New Tools:**
- `schedule-cron(agent_id, expression, task_spec)` - Register cron job
- `run-twitter-scan(keywords, lookback_hours, min_engagement)` - Query Twitter API
- `run-arxiv-scan(categories, keywords, lookback_days)` - Query arXiv API
- `deduplicate-findings(new_findings, registry)` - Compare and score findings
- `auto-queue-for-meeting(findings, priority_threshold)` - Add to meeting queue

**Existing Tools Used:**
- File I/O: Read/write discovery files and queues
- Agent delegation: external-scout, insight, orchestrator
- Status updates: .crypto/BOOTSTRAP.md, .crypto/discovery/

**External APIs:**
- Twitter API v2 (requires credentials in `.crypto/config/api-keys.yaml`)
- arXiv API (public, no auth required)

**Resource Requirements:**
- Frequency: Daily (Twitter) + Weekly (arXiv)
- Time per scan: 5-10 minutes (Twitter), 10-15 minutes (arXiv)
- Storage: ~50MB per month for scan results
- API rate limits: Twitter (450 req/15min), arXiv (≤30k/day)

### Configuration Additions

Add to `.crypto/config/discovery-schedule.yaml`:
```yaml
scheduled_discovery:
  twitter_scan:
    enabled: true
    schedule: "0 6 * * *"              # Daily 06:00 UTC
    lookback_hours: 24
    topics:
      - crypto trading
      - defi strategies
      - arbitrage opportunities
      - yield farming innovation
      - market microstructure
    min_engagement: 100
    exclude_keywords:
      - scam
      - rug pull
      - shitcoin
      - "100x"

  arxiv_scan:
    enabled: true
    schedule: "0 14 * * 5"             # Friday 14:00 UTC
    lookback_days: 7
    categories:
      - quant-ph
      - stat.AP
      - cs.LG
    search_terms:
      - arbitrage
      - market microstructure
      - signal processing
      - machine learning trading
    min_citations: 0                   # Include preprints

  queue_management:
    max_queue_size: 100
    auto_meeting_trigger: true
    priority_threshold: 0.7            # Novel items with score >0.7
    dedup_similarity_threshold: 0.8    # SIMILAR if >0.8 match

  notifications:
    slack_enabled: false
    email_enabled: true
    notify_on_novel_finding: true
    notify_on_meeting_scheduled: true

  api_keys_path: ".crypto/config/api-keys.yaml"
  error_retry_max: 5
  error_retry_backoff_seconds: 300    # 5 min initial
```

---

## Skill 4: live-monitoring

### Purpose
Integrate real-time streaming data from crypto exchanges via WebSocket connections. Monitor deployed strategies for live price action, detect drawdown alerts, and escalate critical risk events immediately.

### Trigger Patterns
- Auto-trigger: When strategy deployed to paper/live trading
- Manual: `/trading-live-monitor --strategy STR-NNN --exchanges binance,kraken`
- Context: When user says "monitor live", "watch position", or "real-time alerts"

### Workflow Steps

```
1. BOOTSTRAP CONNECTION (startup)
   ├─ Read .crypto/BOOTSTRAP.md for deployed strategies
   ├─ Read .crypto/knowledge/registry.yaml for asset lists
   ├─ For each deployed strategy:
   │  ├─ Identify assets (BTC, ETH, etc.)
   │  ├─ Read exchange configs from .crypto/config/exchanges.yaml
   │  └─ Establish WebSocket connections (persistent)
   ├─ Write connection state to .crypto/live-monitoring/connections.yaml
   └─ Log startup status to .crypto/live-monitoring/monitor.log

2. STREAM INGESTION (continuous, non-blocking)
   ├─ Binance WS: Subscribe to ticker@1s, klines@1m, trades
   ├─ Kraken WS: Subscribe to ticker, ohlc, spread, trade
   ├─ Other: (configurable per exchange)
   ├─ Buffer incoming messages (100-item rolling window per asset)
   ├─ Timestamp all events (UTC with nanosecond precision)
   └─ Update .crypto/live-monitoring/current-prices.yaml (1/sec)

3. LIVE PERFORMANCE TRACKING
   ├─ For each deployed strategy:
   │  ├─ Read current allocation (cash + position)
   │  ├─ Calculate mark-to-market P&L per trade
   │  ├─ Aggregate to strategy P&L (hourly snapshots)
   │  ├─ Calculate running Sharpe, win rate, max DD
   │  └─ Write to .crypto/live-monitoring/live-performance/STR-{NNN}.yaml
   │
   └─ Update .crypto/BOOTSTRAP.md with live metrics every 60 seconds

4. ALERT THRESHOLDS & ESCALATION
   ├─ YELLOW (WARNING):
   │  ├─ Drawdown > 5% (for strategy)
   │  ├─ Correlation spike > 0.9 with other strategies
   │  ├─ Signal drought (no trades in 4+ hours)
   │  └─ Action: Log warning, notify user via slack/email
   │
   ├─ RED (CRITICAL):
   │  ├─ Drawdown > 10% (hard circuit breaker)
   │  ├─ Losing trade streak >3
   │  ├─ Exchange connection lost >30 seconds
   │  ├─ Detected data gap or out-of-order ticks
   │  └─ Action: Immediate escalation + auto-trigger trading-risk-check
   │
   └─ BLACK (EMERGENCY):
       ├─ Drawdown > 20% (portfolio level)
       ├─ Multiple strategies correlated crash
       ├─ Catastrophic exchange error
       └─ Action: HALT ALL TRADING, max alert, escalate to risk-manager

5. RISK MANAGER INTEGRATION
   ├─ When YELLOW threshold hit:
   │  └─ Log event, check if user override needed
   │
   ├─ When RED threshold hit:
   │  ├─ Pause new trades for affected strategy
   │  ├─ Notify user immediately
   │  ├─ Delegate to `trading-risk-manager` for review
   │  └─ Await manual override before resuming
   │
   └─ When BLACK threshold hit:
       ├─ Halt ALL strategies immediately
       ├─ Send emergency alert (Slack + email + SMS)
       ├─ Write emergency log to .crypto/live-monitoring/EMERGENCY.yaml
       └─ Await explicit user command to resume

6. CONNECTION HEALTH & RECOVERY
   ├─ Monitor WebSocket ping/pong (every 30 seconds)
   ├─ If connection dies:
   │  ├─ Log disconnect event
   │  ├─ Attempt reconnect with exponential backoff (1s → 30s max)
   │  ├─ Buffer up to 5 minutes of local data
   │  └─ On reconnect: sync recent fills & balances
   │
   ├─ Detect data gaps (missing ticks):
   │  ├─ Compare stream clock to local clock
   │  ├─ If gap > 5 seconds: log warning
   │  └─ Fetch missing data from REST API to fill gaps
   │
   └─ Alert on sustained issues (>10 min no data):
       └─ Trigger emergency recovery protocol

7. PERSISTENCE & RESUME
   ├─ Every 60 seconds: snapshot to .crypto/live-monitoring/snapshot-{TIMESTAMP}.yaml
   ├─ On crash/restart:
   │  ├─ Read latest snapshot
   │  ├─ Sync with exchange to get account state
   │  ├─ Resume streaming from last checkpoint
   │  └─ Backfill any missing performance data
   └─ Log recovery to .crypto/live-monitoring/recovery.log
```

### Agents Involved
- **Monitor Agent** (primary, always-on)
  - Manages WebSocket connections
  - Ingests and buffers market data
  - Calculates live P&L and alerts

- **Risk Manager** (on alert escalation)
  - Reviews RED/BLACK alerts
  - Makes trading halt decisions
  - Triggers recovery protocols

- **Orchestrator** (coordination)
  - Coordinates multi-strategy monitoring
  - Routes alerts to appropriate handlers
  - Manages state persistence

### Tools & Capabilities Required

**New Tools:**
- `websocket-connect(exchange, channels)` - Establish persistent WS connection
- `websocket-buffer(asset, tick_data)` - Buffer incoming ticks
- `calculate-live-pnl(strategy_id, positions, prices)` - Real-time P&L
- `escalate-alert(severity, message, strategy_ids)` - Alert routing
- `halt-strategy(strategy_id, reason)` - Emergency trading halt
- `snapshot-state()` - Persist state for recovery

**Existing Tools Used:**
- File I/O: Read/write live-monitoring directory, snapshots
- Agent delegation: risk-manager, monitor agent
- Status updates: .crypto/BOOTSTRAP.md, .crypto/knowledge/

**External Connections:**
- WebSocket: Binance, Kraken (configurable)
- REST API: For backfill/sync (fallback)

**Resource Requirements:**
- Memory: ~500MB-1GB for streaming buffers
- CPU: 1-2 cores dedicated to streaming/calculations
- Network: Minimal (WebSocket is efficient)
- Uptime: 24/7 persistent connection required
- Storage: ~1GB/month for snapshots and logs

### Configuration Additions

Add to `.crypto/config/live-monitoring.yaml`:
```yaml
live_monitoring:
  enabled: true
  exchanges:
    binance:
      enabled: true
      ws_url: "wss://stream.binance.com:9443/ws"
      channels:
        - ticker@1s
        - klines@1m
        - trades
      api_key_path: ".crypto/config/api-keys.yaml:binance_api_key"
      api_secret_path: ".crypto/config/api-keys.yaml:binance_api_secret"

    kraken:
      enabled: true
      ws_url: "wss://ws.kraken.com/"
      channels:
        - ticker
        - ohlc
        - spread
        - trade
      api_key_path: ".crypto/config/api-keys.yaml:kraken_api_key"
      api_secret_path: ".crypto/config/api-keys.yaml:kraken_api_secret"

  alert_thresholds:
    yellow:
      strategy_drawdown_percent: 5.0
      correlation_spike: 0.9
      signal_drought_minutes: 240

    red:
      strategy_drawdown_percent: 10.0
      losing_streak: 3
      connection_loss_seconds: 30
      data_gap_seconds: 5

    black:
      portfolio_drawdown_percent: 20.0
      multi_strategy_correlation: 0.95

  pnl_tracking:
    snapshot_interval_seconds: 60
    performance_report_interval_minutes: 60
    lookback_windows: [1h, 4h, 1d]

  connection_health:
    ping_interval_seconds: 30
    reconnect_max_backoff_seconds: 30
    buffer_duration_minutes: 5
    sync_on_reconnect: true

  emergency:
    halt_all_on_black_alert: true
    slack_enabled: true
    email_enabled: true
    sms_enabled: false
    log_path: ".crypto/live-monitoring/EMERGENCY.yaml"

  persistence:
    snapshot_path: ".crypto/live-monitoring/snapshots/"
    recovery_log_path: ".crypto/live-monitoring/recovery.log"
    max_snapshots_retained: 1440        # 1 day at 1/min
```

---

## Skill 5: portfolio-rebalance

### Purpose
Automatically rebalance portfolio positions based on correlation analysis and performance drift. Adjust allocations to maintain target exposures, reduce correlated risk, and respect circuit breaker limits while integrating with live monitoring.

### Trigger Patterns
- Auto-trigger: When allocation drift exceeds threshold (daily check)
- Manual: `/trading-portfolio-rebalance --mode correlation-aware --dry-run`
- Context: When user says "rebalance", "adjust positions", or "reduce correlation"

### Workflow Steps

```
1. BOOTSTRAP & CURRENT STATE
   ├─ Read .crypto/BOOTSTRAP.md for deployed strategies
   ├─ Read .crypto/knowledge/registry.yaml for strategy metadata
   ├─ Read .crypto/live-monitoring/live-performance/ for current P&L
   ├─ Read .crypto/knowledge/risk-parameters.yaml for limits
   ├─ Calculate current allocations (% of total capital)
   └─ Write assessment to .crypto/portfolio-rebalance/assessment-{DATE}.yaml

2. DRIFT ANALYSIS
   ├─ For each strategy:
   │  ├─ Compare current allocation vs target allocation (from deployment)
   │  ├─ Calculate drift percentage: |current - target| / target
   │  ├─ If drift > 5%: flag for rebalancing
   │  └─ Record in assessment.yaml
   │
   └─ Portfolio-level:
       ├─ Total deployed vs 60% limit
       ├─ Correlated exposure vs 30% limit
       └─ Flag if any limit >80% of threshold

3. CORRELATION ANALYSIS
   ├─ Calculate correlation matrix for all deployed strategies
   ├─ Lookback window: 30-day performance data
   ├─ If correlation(STR-A, STR-B) > 0.7:
   │  ├─ Flag as CORRELATED pair
   │  ├─ Calculate redundancy score
   │  └─ Recommend allocation adjustment
   │
   └─ Aggregate correlated exposure:
       ├─ Sum allocations of correlated clusters
       ├─ If total > 30% limit: flag for reduction
       └─ Record exposure breakdown

4. REBALANCE DECISION (DRY-RUN)
   ├─ Read .crypto/config/rebalance-policy.yaml
   ├─ Apply rebalancing algorithm:
   │  ├─ Mode 1: PROPORTIONAL (scale all strategies)
   │  ├─ Mode 2: CORRELATION_AWARE (reduce correlated pairs)
   │  ├─ Mode 3: PERFORMANCE_WEIGHTED (increase winners, decrease losers)
   │  └─ Mode 4: RISK_ADJUSTED (account for individual strategy volatility)
   │
   ├─ Generate proposed allocation changes:
   │  ├─ STR-001: 34% → 30% (-4%)
   │  ├─ STR-003: 20% → 25% (+5%)
   │  └─ STR-007: 6% → 5% (-1%)
   │
   ├─ Check circuit breakers:
   │  ├─ Total deployed stays ≤ 60%
   │  ├─ Correlated exposure ≤ 30%
   │  ├─ Individual strategy ≤ 40%
   │  └─ If any violated: adjust proposals
   │
   └─ Write proposed rebalancing to
       .crypto/portfolio-rebalance/proposal-{DATE}.yaml

5. IMPACT SIMULATION
   ├─ Simulate rebalancing impact:
   │  ├─ Projected portfolio Sharpe (post-rebalance)
   │  ├─ Projected max drawdown (post-rebalance)
   │  ├─ Trading costs (slippage + commissions)
   │  ├─ Tax implications (if applicable)
   │  └─ Projected new correlation matrix
   │
   └─ Compare to current state:
       ├─ If improvement > 5% → RECOMMEND
       ├─ If neutral (±5%) → OPTIONAL
       └─ If worse → DO NOT REBALANCE

6. APPROVAL & EXECUTION
   ├─ If DRY_RUN mode: stop here, show proposal to user
   │
   ├─ If AUTO_EXECUTE mode with pre-approval:
   │  ├─ Delegate to `trading-order-executor`
   │  ├─ Execute rebalancing trades in batch:
   │  │  ├─ Sell: STR-001 by 4% of portfolio
   │  │  ├─ Buy: STR-003 by 5% of portfolio
   │  │  └─ Sell: STR-007 by 1% of portfolio
   │  ├─ Monitor execution for slippage
   │  ├─ Await all fills before continuing
   │  └─ Record execution to rebalance-execution-{DATE}.yaml
   │
   └─ Await user approval:
       ├─ Present proposal + impact simulation
       ├─ Allow modification before execution
       └─ Execute once approved

7. POST-REBALANCE VERIFICATION
   ├─ Confirm all orders filled (or partial fills logged)
   ├─ Recalculate allocations from new positions
   ├─ Verify limits still respected:
   │  ├─ Total deployed ≤ 60%
   │  ├─ Correlated exposure ≤ 30%
   │  └─ No individual strategy > 40%
   ├─ Calculate actual trading costs incurred
   ├─ Update .crypto/knowledge/registry.yaml with new allocations
   ├─ Update .crypto/BOOTSTRAP.md with new portfolio state
   └─ Write summary to .crypto/portfolio-rebalance/execution-summary-{DATE}.yaml

8. MONITORING & FEEDBACK
   ├─ Monitor new allocations vs targets for next 7 days
   ├─ Compare actual post-rebalance performance to simulation
   ├─ If performance diverges > 10% from prediction:
   │  ├─ Log discrepancy in .crypto/portfolio-rebalance/feedback.yaml
   │  ├─ Delegate to `trading-feedback` for learning extraction
   │  └─ Refine rebalancing algorithm
   └─ Update rebalance algorithm success rate stats
```

### Agents Involved
- **Orchestrator** (primary coordinator)
  - Analyzes drift and correlations
  - Routes to appropriate rebalancing mode
  - Manages execution flow

- **Risk Manager** (validator)
  - Reviews proposed allocations
  - Confirms circuit breaker compliance
  - Approves or modifies proposal

- **Order Executor** (execution)
  - Executes rebalancing trades
  - Monitors for slippage
  - Confirms fills

- **Feedback Agent** (learning)
  - Extracts learnings from rebalancing decisions
  - Updates algorithm performance metrics

### Tools & Capabilities Required

**New Tools:**
- `calculate-correlation-matrix(strategy_ids, lookback_days)` - Compute correlations
- `generate-rebalance-proposal(current_allocation, algorithm_mode)` - Suggest changes
- `simulate-rebalance-impact(proposal)` - Project post-rebalance metrics
- `execute-rebalance-trades(orders)` - Place rebalancing trades
- `verify-allocation-compliance(allocations, limits)` - Check circuit breakers

**Existing Tools Used:**
- File I/O: Read/write rebalance files, registry, bootstrap
- Agent delegation: order-executor, risk-manager, feedback
- Live data: Performance data from live-monitoring

**Resource Requirements:**
- Frequency: Daily check (5-10 min), rebalancing as needed (10-30 min)
- Computation: Correlation matrix for N strategies (O(N²) operations)
- Storage: ~50MB/month for rebalancing records

### Configuration Additions

Add to `.crypto/config/portfolio-rebalance.yaml`:
```yaml
portfolio_rebalance:
  enabled: true
  schedule: "0 2 * * *"                 # Daily 02:00 UTC

  drift_thresholds:
    individual_drift_percent: 5.0       # Flag if drift > 5%
    portfolio_drift_percent: 2.0        # Portfolio-level drift
    auto_rebalance_threshold: 10.0      # Auto-rebalance if >10%

  correlation_analysis:
    lookback_days: 30
    high_correlation_threshold: 0.7     # Flag if >0.7
    correlated_cluster_max_allocation: 0.30  # 30% limit
    redundancy_score_min: 0.5           # Minimum to consider redundant

  rebalancing_modes:
    default: correlation_aware
    available:
      - proportional                    # Scale all equally
      - correlation_aware               # Reduce correlated pairs
      - performance_weighted            # Increase winners
      - risk_adjusted                   # Account for volatility

  circuit_breakers:
    max_total_deployed_percent: 60
    max_correlated_exposure_percent: 30
    max_individual_allocation_percent: 40
    min_allocation_percent: 1.0         # Don't allocate <1%

  execution:
    mode: dry_run_default               # or auto_execute (requires pre-approval)
    approval_required: true
    batch_execution: true               # Execute all trades together
    slippage_tolerance_bps: 50          # 0.5% max slippage
    max_trades_per_rebalance: 10

  impact_simulation:
    estimate_slippage: true
    estimate_commissions: true
    simulate_drawdown: true
    lookback_windows: [1h, 4h, 1d]
    improvement_threshold_percent: 5.0  # Rebalance if >5% improvement

  monitoring:
    post_rebalance_days: 7
    tracking_interval_hours: 1
    divergence_alert_threshold_percent: 10.0

  learning:
    extract_learnings: true
    update_algorithm_on_divergence: true
    feedback_agent_enabled: true
```

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
1. **parallel-validation** - Highest ROI, multiplies validation throughput
2. **auto-retry** - Low risk, catches fixable failures immediately
3. Create `/skills/{skill-name}/SKILL.md` for each (using template below)

### Phase 2: Discovery & Monitoring (Weeks 3-4)
4. **scheduled-discovery** - Enables continuous opportunity flow
5. **live-monitoring** - Critical for deployed strategies

### Phase 3: Portfolio Optimization (Week 5)
6. **portfolio-rebalance** - Mature after above are stable

---

## SKILL.md Template

Each new skill will follow this template in `/skills/{skill-name}/SKILL.md`:

```markdown
---
name: trading-{skill-name}
description: "{User-facing description. Use when...}"
user-invocable: true
argument-hint: "[argument options]"
model: {sonnet or opus}
---

# {Skill Title}

{One-paragraph overview}

## Trigger Patterns

- Auto-trigger: When...
- Manual: `/trading-{skill-name}` with options
- Context keywords: "...", "...", "..."

## Workflow Overview

[ASCII flowchart of main steps]

## Detailed Steps

1. **Step Name**: Description
   - Sub-step
   - Sub-step

2. **Step Name**: Description

[Continue for each workflow step]

## Agents Involved

- **Agent Name** (role)
  - Responsibility 1
  - Responsibility 2

## Configuration

Add to `.crypto/config/{skill-name}.yaml`:
[YAML config block]

## Integration Points

- **Triggers**: Skill X, event Y
- **Outputs**: File Z, queue W
- **Dependencies**: Skill A, tool B

## Error Handling

- **Timeout**: Retry up to N times with backoff
- **API Failure**: Log and continue with fallback
- **Data Gap**: Use cached data, escalate if >X hours

## Monitoring & Metrics

- Track: {metric 1}, {metric 2}
- Alert on: {condition 1}, {condition 2}
- Dashboard: `.crypto/live-monitoring/{skill-name}`

## Examples

### Example 1: {Scenario}
[Step-by-step example with file paths and expected outputs]

### Example 2: {Scenario}
[Another example]
```

---

## Cross-Skill Dependencies

```
parallel-validation
├─ Requires: backtester agent (×4 instances)
├─ Feeds to: auto-retry (if failures detected)
└─ Integrates: trading-pipeline (Phase 2)

auto-retry
├─ Triggered by: parallel-validation failures
├─ Uses: ml-engineer, signal-generator, quant-analyst
└─ Feeds to: trading-evaluate (if pass)

scheduled-discovery
├─ Runs independently (cron schedule)
├─ Feeds to: strategy-meeting queue
└─ Integrates: trading-pipeline (Phase 0)

live-monitoring
├─ Starts after: strategy deployment
├─ Integrates: trading-risk-check (alert escalation)
└─ Feeds to: portfolio-rebalance (correlation data)

portfolio-rebalance
├─ Uses: live-monitoring data (correlations, P&L)
├─ Delegates to: order-executor, risk-manager
└─ Integrates: trading-pipeline (post-deployment)
```

---

## Success Metrics

### parallel-validation
- Validation throughput: 4× speedup vs sequential
- Wall-clock time: Reduce from N×5min to ~5min for N strategies
- Resource utilization: 4 concurrent workers, ~200MB each

### auto-retry
- Fix success rate: Target >60% of fixable failures
- Retry attempts: Average 1.2 attempts per strategy
- Learnings extracted: 100% of auto-retry cycles

### scheduled-discovery
- Scan frequency: 1 daily Twitter, 1 weekly arXiv
- Novel findings per week: >2 new ideas
- Queueing latency: <5 min from discovery to queue

### live-monitoring
- Data coverage: 99%+ uptime for WebSocket streams
- Alert latency: <5 seconds from threshold breach to notification
- Connection recovery: <30 seconds average

### portfolio-rebalance
- Rebalancing frequency: 1-2 times per week
- Allocation compliance: 100% adherence to circuit breakers
- Performance improvement: Average >3% Sharpe post-rebalance

---

## Migration Notes

- **Backward compatibility**: All new skills are additive; existing pipeline continues unchanged
- **Gradual rollout**: Enable skills individually, monitor before enabling next
- **Configuration**: All defaults are conservative (dry-run, alerts, low parallelism)
- **Opt-in**: Users can enable/disable each skill independently via BOOTSTRAP.md
