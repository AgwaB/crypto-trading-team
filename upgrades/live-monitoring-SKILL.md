---
name: trading-live-monitoring
description: "Stream real-time market data from crypto exchanges via WebSocket. Monitor deployed strategies for live performance, detect drawdown alerts, and escalate critical risk events immediately. Auto-activates when strategy deployed to paper/live trading. Use 'monitor live', 'watch position', or 'real-time alerts'."
user-invocable: true
argument-hint: "[--strategy STR-NNN | --exchanges binance,kraken | --alerts-only]"
model: opus
---

# Live Monitoring

Integrate real-time streaming data from crypto exchanges via persistent WebSocket connections. Monitor deployed strategy performance, calculate mark-to-market P&L, and escalate risk alerts with circuit breaker integration.

## Trigger Patterns

- **Auto-trigger**: When strategy deployed to paper or live trading
- **Manual**: `/trading-live-monitor --strategy STR-NNN --exchanges binance,kraken`
- **Context keywords**: "monitor live", "watch position", "real-time alerts", "stream prices"

## Workflow Overview

```
BOOTSTRAP      STREAM INGESTION    LIVE P&L           ALERTS             RISK MANAGER
┌──────────┐   ┌──────────────┐    ┌────────────┐     ┌──────────┐      ┌────────────┐
│Load dep   │──▶│WebSocket     │───▶│Calculate   │────▶│Check     │──┬───▶│Review &    │
│strategies │   │connections   │    │mark-to-   │     │thresholds│  │    │escalate   │
│& assets   │   │to exchanges  │    │market P&L │     │(Y/R/B)   │  │    │if needed  │
└──────────┘   └──────────────┘    └────────────┘     └──────────┘  │    └────────────┘
                                                                      │
                                                          [Alert]─────┴─→ Notify user
```

## Detailed Steps

### 1. Bootstrap & Connection Initialization

**Delegate to**: Orchestrator + Monitor Agent

On strategy deployment or manual invocation:
- Read `.crypto/BOOTSTRAP.md` for deployed strategies
  - Extract: list of active strategies (STR-{NNN})
  - Extract: current allocations, positions
- Read `.crypto/knowledge/registry.yaml`
  - For each strategy: identify assets (BTC, ETH, ALT coins, etc.)
  - Extract: exchange assignments (where strategy trades)
- Read `.crypto/config/exchanges.yaml`
  - WS URLs, channel subscriptions per exchange
  - API keys for authenticated endpoints (balance, fills)
- For each strategy + exchange pair:
  - Validate exchange is configured
  - Establish persistent WebSocket connection (TCP keep-alive)
  - Subscribe to channels: ticker, klines (1m), trades
  - Log connection state: `{exchange: connected | pending | failed}`
- Write connection state to `.crypto/live-monitoring/connections.yaml`:
  ```yaml
  connections:
    binance:
      status: "connected"
      connected_at: "2025-02-05T14:30:00Z"
      channels: ["ticker@1s", "klines@1m", "trades"]
      assets: ["BTC", "ETH", "SOL"]
    kraken:
      status: "connected"
      connected_at: "2025-02-05T14:30:15Z"
      channels: ["ticker", "ohlc", "trade"]
      assets: ["BTC", "ETH"]
  ```
- Log startup to `.crypto/live-monitoring/monitor.log`

**Output**: Persistent WebSocket connections established

### 2. Stream Ingestion (Continuous, Non-Blocking)

**Delegate to**: Monitor Agent (dedicated streaming thread)

Continuously receive and buffer market data:

**Binance WebSocket**:
- Subscribe to: `{symbol}@ticker@1s`, `{symbol}@klines@1m`, `{symbol}@trades`
- Buffer incoming ticks in rolling window (100-item per asset)
- Parse JSON, extract: price, volume, bid/ask, trade size/direction
- Timestamp all events (UTC, nanosecond precision if possible)
- Detect gaps: if tick timestamp >5s behind local time, alert

**Kraken WebSocket**:
- Subscribe to: ticker, ohlc (1m), spread, trade
- Same buffering + parsing
- Convert Kraken format to internal schema

**Data Buffering**:
- Per-asset ring buffer: 100 ticks (rolling window, newest at head)
- Timestamp each: `{asset: BTC, price: 42500.50, time: 1738770600123, bid: 42500, ask: 42501}`
- Drop oldest if buffer full
- Keep in-memory for fast access

**Update Live Prices**:
- Every 1 second: update `.crypto/live-monitoring/current-prices.yaml`
  ```yaml
  current_prices:
    timestamp: "2025-02-05T14:35:42.123Z"
    BTC: {price: 42500.50, bid: 42500, ask: 42501, volume_24h: 15.2B}
    ETH: {price: 2450.25, bid: 2450, ask: 2451, volume_24h: 8.3B}
    SOL: {price: 185.75, bid: 185.74, ask: 185.76, volume_24h: 1.2B}
  ```

**Monitor Connection Health**:
- Send WebSocket ping every 30 seconds
- If no pong within 10 seconds: log warning, prepare reconnect
- Detect out-of-order ticks (price going backwards): flag data quality issue

**Output**: Continuous stream of market data, updated live prices every 1s

### 3. Live Performance Tracking

**Delegate to**: Monitor Agent (calculation thread)

Every 60 seconds, calculate and update strategy performance:

For each deployed strategy:
- Read current position state:
  - From `.crypto/knowledge/strategies/STR-{NNN}/live-performance/positions.yaml`
  - Or from exchange API (fallback if file missing)
  - Extract: quantity per asset, entry price, fees
- Fetch live prices (from current-prices.yaml)
- Calculate P&L per position:
  - mark_to_market = (current_price - avg_entry_price) × quantity - fees
  - For BTC position: 0.5 BTC @ 41000, now 42500
    - P&L = (42500 - 41000) × 0.5 = 750 USD
- Aggregate to strategy level:
  - Total strategy P&L = sum of all position P&L
  - Return = P&L / initial_capital
- Calculate running metrics (60-minute window):
  - Sharpe = mean_return / std_return (hourly)
  - Win rate = profitable_intervals / total_intervals
  - Max drawdown = lowest cumulative return so far
- Write hourly snapshot to `.crypto/live-monitoring/live-performance/STR-{NNN}.yaml`:
  ```yaml
  live_performance:
    strategy: "STR-001"
    as_of: "2025-02-05T14:35:00Z"

    current_positions:
      BTC: {qty: 0.5, entry_price: 41000, current_price: 42500, pnl: 750}
      ETH: {qty: 10, entry_price: 2400, current_price: 2450, pnl: 500}

    aggregated:
      total_pnl_usd: 1250
      total_return_percent: 1.25
      sharpe_60min: 0.35
      win_rate_60min: 0.67
      max_drawdown_60min: -2.1
      num_trades_60min: 3

    lookback_windows:
      window_1h:
        pnl: 1250
        return: 1.25%
        sharpe: 0.35
        dd: -2.1%
      window_4h:
        pnl: 3200
        return: 3.2%
        sharpe: 0.42
        dd: -5.3%
      window_1d:
        pnl: 5500
        return: 5.5%
        sharpe: 0.38
        dd: -8.7%
  ```
- Update `.crypto/BOOTSTRAP.md` with live metrics (every 60 seconds):
  - Current P&L per strategy
  - Portfolio-level P&L
  - Alert status (GREEN/YELLOW/RED/BLACK)

**Output**: Hourly performance snapshots + live metrics in BOOTSTRAP

### 4. Alert Thresholds & Escalation

**Delegate to**: Monitor Agent + Risk Manager

Continuously check alert thresholds (every calculation cycle, ~60s):

**YELLOW Alerts (WARNING)**:
- Individual strategy drawdown > 5%
- Correlation spike with other strategies > 0.9
- Signal drought (no trades for 240 minutes)
- Action:
  1. Log warning to `.crypto/live-monitoring/alerts.yaml`
  2. Update alert status in BOOTSTRAP to YELLOW
  3. Send notification email to user (non-urgent)
  4. No trading halt
  5. User can dismiss or escalate

**RED Alerts (CRITICAL)**:
- Individual strategy drawdown > 10% (hard circuit breaker)
- Losing trade streak > 3 consecutive losses
- Exchange connection lost > 30 seconds
- Detected data gap or out-of-order ticks
- Action:
  1. Log critical alert
  2. **Pause new trades** for affected strategy only
  3. Update alert status to RED
  4. Send **immediate notification** (Slack + email, high priority)
  5. Delegate to `trading-risk-manager` for urgent review
  6. Await manual override before resuming trades
  7. Record alert to `.crypto/live-monitoring/RED-alerts-{DATE}.yaml`

**BLACK Alerts (EMERGENCY)**:
- Portfolio-level drawdown > 20% (catastrophic)
- Multiple strategies correlated crash (3+ in RED simultaneously)
- Catastrophic exchange error (e.g., double-fills, API returning wrong data)
- Action:
  1. **HALT ALL TRADING IMMEDIATELY**
  2. Stop WebSocket streams (graceful close)
  3. Write emergency log to `.crypto/live-monitoring/EMERGENCY.yaml`:
     ```yaml
     emergency_halt:
       timestamp: "2025-02-05T15:00:00Z"
       trigger: "Portfolio drawdown 22% > 20% limit"
       portfolio_pnl: -22000
       affected_strategies: [STR-001, STR-003, STR-007]
       action: "HALT_ALL_TRADING"
       resumption: "Manual override required"
     ```
  4. Send **emergency alert** (Slack + email + SMS if configured)
  5. Await explicit user command: `/trading-live-monitor --resume` (after review)

**Alert Thresholds Config** (from `.crypto/config/live-monitoring.yaml`):
```yaml
alert_thresholds:
  yellow:
    strategy_drawdown_percent: 5.0
    correlation_spike_threshold: 0.9
    signal_drought_minutes: 240
  red:
    strategy_drawdown_percent: 10.0
    losing_streak_count: 3
    connection_loss_seconds: 30
    data_gap_seconds: 5
  black:
    portfolio_drawdown_percent: 20.0
    multi_strategy_correlation: 0.95
```

**Output**: Real-time alert detection + escalation decisions

### 5. Risk Manager Integration (On Alert Escalation)

**Delegate to**: Orchestrator + `trading-risk-manager` agent (on RED/BLACK)

When RED alert triggered:
1. Orchestrator spawns Risk Manager agent with:
   - Alert details (strategy, metric, threshold breach)
   - Live performance data (last 60 minutes)
   - Current positions + exposures
   - Question: "Halt trading or continue with caution?"

2. Risk Manager reviews:
   - Is drawdown due to normal volatility or systemic issue?
   - Are other strategies still healthy?
   - Can we hedge the exposure?
   - Recommendation: HALT or CONTINUE

3. Based on recommendation:
   - If HALT: confirm the pause, await user override
   - If CONTINUE: unpause, continue monitoring
   - Log decision to `.crypto/live-monitoring/risk-decisions-{DATE}.yaml`

When BLACK alert triggered:
- Do NOT delegate to Risk Manager
- Do NOT wait for response
- Halt immediately, alert user, await manual override

**Output**: Risk Manager decision on RED alert severity

### 6. Connection Health & Recovery

**Delegate to**: Monitor Agent (connection recovery thread)

Monitor WebSocket health continuously:

**Ping/Pong Heartbeat** (every 30 seconds):
- Send: `{"type": "ping"}`
- Wait: 10 seconds for pong response
- If timeout: mark connection as unhealthy

**Reconnection Protocol** (if connection dies):
1. Log disconnect event with timestamp
2. Alert: "Lost connection to {exchange}, attempting reconnect"
3. Exponential backoff retry:
   - Attempt 1: 1 second
   - Attempt 2: 2 seconds
   - Attempt 3: 5 seconds
   - Attempt 4: 15 seconds
   - Attempt 5+: 30 seconds (max backoff)
4. Buffer local data up to 5 minutes (fallback if reconnect slow)
5. On successful reconnect:
   - Fetch recent fills + balance updates from REST API
   - Sync position state
   - Resume streaming
   - Log recovery: `"Reconnected to {exchange} after Xs"`

**Data Gap Detection**:
- Compare stream timestamp to local clock
- If gap > 5 seconds: log data quality warning
- If gap > 30 seconds: escalate as RED alert (possible data corruption)
- Fetch missing data from REST API (backfill)

**Sustained Issues** (>10 min no data):
1. Escalate: trigger emergency recovery protocol
2. Log: `"Sustained connectivity loss for 10+ minutes"`
3. Alert user: "Critical data loss, halting monitoring"
4. Pause strategy trading (safety measure)
5. Await user intervention

**Output**: Connection recovery with data sync

### 7. Persistence & Resume Protocol

**Delegate to**: Monitor Agent (snapshot thread)

Persist state every 60 seconds for crash recovery:

**Snapshot Contents** (`.crypto/live-monitoring/snapshot-{TIMESTAMP}.yaml`):
```yaml
monitoring_snapshot:
  timestamp: "2025-02-05T15:36:00Z"
  connections:
    binance: "connected"
    kraken: "connected"
  current_prices: {BTC: 42500, ETH: 2450, ...}
  live_performance:
    STR-001: {total_pnl: 1250, return: 1.25%, sharpe: 0.35, dd: -2.1%}
    STR-003: {total_pnl: 2100, return: 2.1%, sharpe: 0.52, dd: -1.8%}
  alert_status: "GREEN"
  active_alerts: []
  positions:
    STR-001:
      BTC: {qty: 0.5, entry: 41000, current: 42500, pnl: 750}
```

**On Crash/Restart**:
1. Check if monitoring was active (in BOOTSTRAP.md or lock file)
2. Read latest snapshot file
3. Sync with exchange REST API:
   - Fetch current balances
   - Fetch recent fills (last 100 trades)
   - Reconcile positions vs. snapshot (detect any fills during outage)
4. Resume WebSocket streaming
5. Backfill any missing performance data
6. Log recovery: `"Resumed monitoring after {duration} downtime"`
7. Update BOOTSTRAP.md: monitoring status = RESUMED

**Snapshot Retention** (rolling window):
- Keep last 1440 snapshots (1 day at 1/min)
- Older snapshots archived to `.crypto/live-monitoring/archive/`
- Total storage: ~100MB for 1 month of snapshots

**Output**: Crash-resistant monitoring with full state recovery

## Agents Involved

### Monitor Agent
- Role: Core streaming and monitoring engine
- Responsibilities:
  - Manage WebSocket connections
  - Ingest and buffer market data
  - Calculate live P&L
  - Detect alert thresholds
  - Handle connection recovery
  - Persist snapshots for recovery

### Risk Manager (on escalation)
- Role: Alert validator and severity reviewer
- Responsibilities:
  - Review RED alerts for actual severity
  - Recommend halt or continue
  - Assess portfolio-level risk
  - Make override decisions

### Orchestrator
- Role: Coordinator and decision router
- Responsibilities:
  - Bootstrap connections
  - Route alerts to Risk Manager
  - Manage alert status in BOOTSTRAP
  - Coordinate emergency halts

## Tools & Capabilities Required

### New Tools Needed

```yaml
websocket_connect:
  signature: websocket_connect(exchange, channels, credentials)
  inputs:
    exchange: "binance" | "kraken"
    channels: ["ticker@1s", "klines@1m", "trades"]
    credentials: {api_key, api_secret}  # if authenticated
  outputs:
    connection_id: "WS-{UUID}"
    status: "connected | failed"

websocket_buffer:
  signature: websocket_buffer(asset, tick_data)
  inputs:
    asset: "BTC"
    tick_data: {price, bid, ask, volume, timestamp}
  outputs:
    buffer_size: N
    oldest_tick_age_seconds: N

calculate_live_pnl:
  signature: calculate_live_pnl(strategy_id, positions, prices)
  inputs:
    strategy_id: "STR-001"
    positions: [{asset, qty, entry_price}, ...]
    prices: {BTC: 42500, ETH: 2450}
  outputs:
    total_pnl: 1250
    return_percent: 1.25
    per_position_pnl: {BTC: 750, ETH: 500}

escalate_alert:
  signature: escalate_alert(severity, message, strategy_ids)
  inputs:
    severity: "YELLOW | RED | BLACK"
    message: "Drawdown exceeded 10%"
    strategy_ids: ["STR-001"]
  outputs:
    alert_id: "ALERT-{UUID}"
    notification_sent: boolean
    escalation_time: ISO8601

halt_strategy:
  signature: halt_strategy(strategy_id, reason)
  outputs:
    halted: boolean
    halt_time: ISO8601
    halt_log_entry: {yaml}

snapshot_state:
  signature: snapshot_state()
  outputs:
    snapshot_path: "path/to/snapshot-{TIMESTAMP}.yaml"
    snapshot_size_bytes: N
```

### Existing Tools Used

- **File I/O**: Read/write monitoring files, BOOTSTRAP, snapshots
- **Agent delegation**: risk-manager, monitor agent
- **Status updates**: `.crypto/BOOTSTRAP.md`, live-monitoring directory

### External Connections

- **WebSocket**: Binance (wss://stream.binance.com:9443/ws), Kraken (wss://ws.kraken.com/)
- **REST API** (fallback/sync): Binance REST, Kraken REST

### Resource Requirements

- **Memory**: 500MB-1GB for streaming buffers (100 ticks × 100+ assets)
- **CPU**: 1-2 cores dedicated to streaming + calculations
- **Network**: Minimal (WebSocket is efficient, ~1-10 KB/s typical)
- **Uptime**: 24/7 persistent connection (designed for reliability)
- **Storage**: 1GB/month for snapshots + logs

## Configuration

Add to `.crypto/config/live-monitoring.yaml`:

```yaml
live_monitoring:
  enabled: true

  # Exchange WebSocket connections
  exchanges:
    binance:
      enabled: true
      ws_url: "wss://stream.binance.com:9443/ws"
      channels:
        - ticker@1s
        - klines@1m
        - trades
      rest_url: "https://api.binance.com/api/v3"
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
      rest_url: "https://api.kraken.com"
      api_key_path: ".crypto/config/api-keys.yaml:kraken_api_key"
      api_secret_path: ".crypto/config/api-keys.yaml:kraken_api_secret"

  # Alert thresholds
  alert_thresholds:
    yellow:
      strategy_drawdown_percent: 5.0
      correlation_spike_threshold: 0.9
      signal_drought_minutes: 240

    red:
      strategy_drawdown_percent: 10.0
      losing_streak_count: 3
      connection_loss_seconds: 30
      data_gap_seconds: 5

    black:
      portfolio_drawdown_percent: 20.0
      multi_strategy_correlation: 0.95
      consecutive_red_alerts: 3

  # P&L tracking
  pnl_tracking:
    snapshot_interval_seconds: 60
    performance_report_interval_minutes: 60
    lookback_windows: [1h, 4h, 1d]
    track_sharpe: true
    track_win_rate: true
    track_max_drawdown: true

  # Connection health
  connection_health:
    ping_interval_seconds: 30
    pong_timeout_seconds: 10
    reconnect_max_backoff_seconds: 30
    buffer_duration_minutes: 5
    sync_on_reconnect: true
    detect_data_gaps: true

  # Alert notification
  alert_notifications:
    yellow:
      method: "email"
      urgency: "low"
    red:
      method: "slack | email"
      urgency: "high"
    black:
      method: "slack | email | sms"
      urgency: "critical"

  # Emergency handling
  emergency:
    halt_all_on_black_alert: true
    halt_all_on_multi_red: true
    max_red_alerts_before_halt: 3
    slack_webhook: "{slack_url}"
    email_recipients: ["user@example.com"]
    sms_recipients: ["+1234567890"]

  # Persistence
  persistence:
    snapshot_path: ".crypto/live-monitoring/snapshots/"
    snapshot_interval_seconds: 60
    max_snapshots_retained: 1440        # 1 day at 1/min
    recovery_log_path: ".crypto/live-monitoring/recovery.log"
    archive_after_days: 7               # Move old snapshots to archive
```

## Integration Points

### Triggers
- **Auto-trigger**: Strategy deployed to paper/live trading
- **Manual**: `/trading-live-monitor --strategy STR-NNN --exchanges binance,kraken`

### Upstream Dependencies
- Strategies must be deployed (in BOOTSTRAP.md)
- Exchange configs must exist (`.crypto/config/exchanges.yaml`)
- API credentials must be configured (`.crypto/config/api-keys.yaml`)

### Downstream Integration
- Feeds to: `trading-risk-check` (alert escalation)
- Feeds to: `trading-portfolio-rebalance` (correlation data)
- Updates: `.crypto/BOOTSTRAP.md`, live-monitoring directory
- Notifies: User via Slack/email/SMS on alerts

## Error Handling

### WebSocket Disconnection (>30 seconds)
1. Log disconnect event
2. Escalate as RED alert
3. Attempt reconnect with exponential backoff
4. Pause strategy trading (temporary halt)
5. Resume on successful reconnect

### Data Gap Detected (>5 seconds)
1. Log warning
2. If gap >30s: escalate as RED alert
3. Backfill from REST API if possible
4. Resume streaming

### Ping/Pong Timeout
1. Log connection health issue
2. If repeated: trigger reconnect
3. After 3 consecutive timeouts: escalate

### Market Data Corruption
1. Detect: Price going backwards, extreme spreads
2. Log anomaly
3. Alert: "Possible data corruption"
4. Fetch fresh data from REST API to verify

### Snapshot Corruption
1. Detect on read (invalid YAML)
2. Fall back to previous snapshot
3. Log error, alert user
4. Continue with fallback state

## Monitoring & Metrics

### Key Metrics

```yaml
live_monitoring_metrics:
  run_date: "2025-02-05"
  uptime_percent: 99.8
  connection_health:
    binance_connected_percent: 100.0
    kraken_connected_percent: 99.9
    reconnects_today: 1
  data_quality:
    data_gaps: 0
    out_of_order_ticks: 0
    corrupted_ticks: 0
  alerts:
    yellow_alerts: 2
    red_alerts: 0
    black_alerts: 0
  performance_tracking:
    strategies_monitored: 3
    avg_calculation_latency_ms: 145
    snapshot_size_mb: 2.3
```

### Alerts & Warnings

- **Alert**: Connection uptime <99.5% (link instability)
- **Alert**: Data gap >30 seconds (data quality issue)
- **Alert**: RED alert triggered (critical)
- **Alert**: BLACK alert triggered (emergency)

### Dashboard Location

Track metrics in: `.crypto/live-monitoring/monitoring-metrics.yaml`

Update every 60 seconds, retain rolling 7-day window.

## Examples

### Example 1: Normal YELLOW Alert

**Setup**:
- STR-001 has 2% drawdown in normal range
- Sudden price movement causes -5.2% drawdown

**Execution**:
1. Monitor Agent calculates: current_dd = -5.2%
2. Checks threshold: -5.2% > -5.0% (YELLOW) → trigger
3. Logs to alerts.yaml with timestamp
4. Updates BOOTSTRAP.md: alert_status = YELLOW
5. Sends email: "STR-001 reached 5.2% drawdown (warning threshold)"
6. User notified, can dismiss (no trading halt)
7. Monitoring continues, watches for RED threshold

**Output**: Alert logged, user informed, monitoring continues

### Example 2: Critical RED Alert & Risk Manager Escalation

**Setup**:
- STR-003 experiencing sustained losses
- Reaches -10.5% drawdown

**Execution**:
1. Monitor Agent calculates: current_dd = -10.5%
2. Checks threshold: -10.5% > -10.0% (RED) → trigger
3. **Pauses new trades** for STR-003
4. Logs critical alert, updates BOOTSTRAP to RED
5. Sends Slack message + email: "CRITICAL: STR-003 drawdown 10.5%"
6. Spawns Risk Manager agent:
   - Input: "STR-003 losing money, -10.5% DD, 3 consecutive losing trades"
   - Risk Manager reviews: Losing streak likely due to regime change
   - Recommendation: HALT trading, don't resume until user confirms
7. Updates RED-alerts log
8. Awaits user action: dismiss alert or override manually

**Output**: Trading halted, Risk Manager engaged, awaiting user override

### Example 3: Emergency BLACK Alert & Automatic Halt

**Setup**:
- Exchange API returns corrupted data (double-fills detected)
- Multiple strategies show artificial profit spikes
- Portfolio drawdown calculation shows -22%

**Execution**:
1. Monitor Agent detects data corruption
2. Triggers BLACK alert: "Portfolio drawdown 22% > 20%"
3. **Halts ALL trading immediately** (no Risk Manager delay)
4. Closes WebSocket connections gracefully
5. Writes emergency log with full context
6. Sends emergency notification: Slack + email + SMS
7. Writes EMERGENCY.yaml with halt reason
8. Halts all strategies, awaits manual user intervention
9. User reviews emergency log, confirms root cause
10. User runs: `/trading-live-monitor --resume` after fix
11. Monitor Agent resumes with fresh data sync

**Output**: Emergency halt enforced, user intervention required

### Example 4: Connection Recovery

**Setup**:
- Binance WebSocket drops unexpectedly (ISP issue)
- Monitor was running, loses connection

**Execution**:
1. Monitor Agent sends ping, gets no pong
2. Logs: "Binance connection lost at 2025-02-05T15:45:30Z"
3. Pauses STR-001, STR-003 (safety measure)
4. Attempts reconnect:
   - Attempt 1: retry after 1s → fails
   - Attempt 2: retry after 2s → fails
   - Attempt 3: retry after 5s → succeeds
5. On reconnect:
   - Fetches recent fills from REST API
   - Reconciles positions (no fills during 7s outage)
   - Resumes WebSocket streaming
6. Unpauses strategies
7. Logs recovery: "Reconnected to Binance after 7s, no fills during outage"
8. Continues normal monitoring

**Output**: Automatic recovery with state sync

## Success Metrics

- **Uptime**: 99%+ (max 15 min downtime per week)
- **Alert latency**: <5 seconds from threshold breach to user notification
- **Connection recovery**: <30 seconds average recovery time
- **Data accuracy**: >99.9% (no gaps, no corruption)
- **P&L calculation accuracy**: Within 0.1% of actual fills
