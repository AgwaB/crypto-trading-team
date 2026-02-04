---
name: trading-scheduled-discovery
description: "Continuously scan Twitter for trading ideas and arXiv for research breakthroughs on automated schedule. Daily Twitter scans at 06:00 UTC, weekly arXiv scans Friday 14:00 UTC. Auto-deduplicates findings and queues novel ideas for strategy meeting. Use 'run discovery', 'find ideas', or 'scan opportunities'."
user-invocable: true
argument-hint: "[--source twitter|arxiv|both | --dry-run]"
model: sonnet
---

# Scheduled Discovery

Automate the discovery of trading opportunities via Twitter sentiment and academic research via arXiv. Runs on a cron schedule to continuously feed novel ideas into the strategy pipeline.

## Trigger Patterns

- **Auto-trigger**: Daily 06:00 UTC (Twitter), Friday 14:00 UTC (arXiv)
- **Manual**: `/trading-scheduled-discovery --source twitter` or `--source arxiv`
- **Context keywords**: "run discovery", "find ideas", "scan for opportunities", "check twitter"

## Workflow Overview

```
SCHEDULED SCAN    EXTERNAL SCOUT    DEDUPLICATION    AUTO-QUEUE
┌──────────────┐  ┌──────────────┐   ┌─────────────┐   ┌──────────┐
│Check time    │──▶│Twitter scan  │──▶│Compare to   │──▶│Add novel │
│Is it 06:00?  │  │or            │   │registry &   │   │items to  │
│Is it Fri?    │  │arXiv scan    │   │existing     │   │queue &   │
└──────────────┘  └──────────────┘   │queue        │   │notify    │
                                      └─────────────┘   └──────────┘
```

## Detailed Steps

### 1. Scheduler Check

**Delegate to**: Orchestrator

- Read system time (UTC)
- Check `.crypto/config/discovery-schedule.yaml` for enabled schedules
- Decision tree:
  - If current time == 06:00 UTC AND twitter_scan enabled → RUN_TWITTER_SCAN
  - If current time == 14:00 UTC Friday AND arxiv_scan enabled → RUN_ARXIV_SCAN
  - Else: WAIT, return (cron will trigger again at next scheduled time)
- Read `.crypto/discovery/last-run.yaml` to prevent duplicate runs within 1 hour
- Update last_run timestamp

**Output**: RUN or WAIT decision

### 2. Twitter Scan (Daily, 06:00 UTC)

**Delegate to**: `trading-external-scout` agent

Input to Scout:
- Search parameters from `.crypto/config/discovery-schedule.yaml`:
  - Topics: crypto trading, defi, arbitrage, yield farming, market microstructure
  - Lookback: last 24 hours
  - Min engagement: 100 retweets + likes combined
  - Exclude keywords: shitcoin, rug pull, scam, "100x"
- Twitter API credentials from `.crypto/config/api-keys.yaml`

Scout task:
- Query Twitter API v2:
  - Search for trending crypto trading discussions
  - Filter: high-engagement tweets (>100 engagement)
  - Filter: from crypto analysts/traders (verified or >10k followers)
  - Extract: tweet text, author, engagement metrics, URL links
- Synthesize findings:
  - Group related tweets into themes
  - Identify novel approaches/strategies mentioned
  - Generate hypothesis drafts from key insights
  - Rate each finding: confidence 0.1-1.0
- Write results to `.crypto/discovery/twitter-scan-{DATE}.yaml`:
  ```yaml
  twitter_scan:
    date: "2025-02-05"
    lookback_hours: 24
    tweets_scanned: 2345
    themes_identified:
      - theme: "Luna 2.0 arbitrage"
        confidence: 0.8
        summary: "Multiple traders noting price divergence across CEX"
        hypothesis_sketch: "Statistical arbitrage on Luna pairs"
        source_tweets: [tweet_id_1, tweet_id_2, ...]
      - theme: "ETH staking yield optimizer"
        confidence: 0.6
        summary: "Discussion of optimal liquid staking pool selection"
        hypothesis_sketch: "Dynamic rebalancing across LST yields"
        source_tweets: [...]
  ```
- Return: List of themes with hypothesis sketches and confidence scores

**Output**: Twitter scan results in discovery/twitter-scan-{DATE}.yaml

### 3. arXiv Scan (Weekly, Friday 14:00 UTC)

**Delegate to**: `trading-external-scout` agent

Input to Scout:
- Search parameters from `.crypto/config/discovery-schedule.yaml`:
  - Categories: quant-ph, stat.AP, cs.LG (machine learning)
  - Search terms: arbitrage, market microstructure, signal processing, regime detection
  - Lookback: last 7 days
  - Filter: peer-reviewed or highly cited (>5 citations if preprint)
- arXiv API (public, no credentials needed)

Scout task:
- Query arXiv API:
  - Search papers in specified categories with keywords
  - Extract: title, authors, abstract, citation count, submission date
  - Filter: relevant to trading/finance (exclude pure physics)
- Synthesize findings:
  - Read abstracts of top papers
  - Identify novel methodologies applicable to trading
  - Generate hypothesis sketches from research insights
  - Rate each paper: relevance 0.1-1.0
- Write results to `.crypto/discovery/arxiv-scan-{DATE}.yaml`:
  ```yaml
  arxiv_scan:
    date: "2025-02-05"
    lookback_days: 7
    papers_reviewed: 156
    papers_selected: 4
    papers:
      - arxiv_id: "2502.01234"
        title: "Adaptive Signal Detection in Regime-Switching Markets"
        authors: ["Author A", "Author B"]
        abstract: "We propose a novel Bayesian approach to detect market regimes..."
        relevance: 0.9
        hypothesis_sketch: "Implement Bayesian regime detector for strategy entry/exit"
        key_insights:
          - "Regime switches detectable 2-3 bars ahead with lagged features"
          - "Bayes factor >10 indicates high confidence switch"
        source_arxiv: "https://arxiv.org/abs/2502.01234"
      - arxiv_id: "2502.05678"
        title: "Machine Learning for Order Flow Prediction"
        authors: ["Author C", "Author D"]
        relevance: 0.7
        ...
  ```
- Return: List of papers with hypothesis sketches and relevance scores

**Output**: arXiv scan results in discovery/arxiv-scan-{DATE}.yaml

### 4. Deduplication & Queueing

**Delegate to**: `trading-insight` agent

Input to Insight:
- New findings from Twitter scan and/or arXiv scan
- Existing registry: `.crypto/knowledge/registry.yaml` (all strategies ever attempted)
- Existing queue: `.crypto/discovery/queue.yaml` (pending ideas)

Insight task:
- For each new finding:
  - Extract: hypothesis sketch, key characteristics
  - Compare against registry: Does similar strategy exist?
    - If exact match (>0.95 similarity): DUPLICATE
    - If similar (0.75-0.95): SIMILAR (needs differentiation)
    - If unique (<0.75): NOVEL
  - Compare against existing queue:
    - If already queued: DUPLICATE (merge findings)
    - If not queued: Add to queue
- Generate scores:
  - Novelty score: 0-1 (how unique vs existing)
  - Confidence score: 0-1 (how likely to work, from source confidence)
  - Priority score: novelty × confidence (0-1)
- Write deduplication results to `.crypto/discovery/dedup-log-{DATE}.yaml`:
  ```yaml
  deduplication_results:
    date: "2025-02-05"
    total_findings: 6
    duplicates: 1
    similar: 1
    novel: 4
    results:
      - finding_id: "twitter_luna_arb"
        comparison:
          duplicate_of: null
          similarity: 0.4
          status: NOVEL
        scores:
          novelty: 0.85
          confidence: 0.8
          priority: 0.68
        recommendation: "Add to queue, high priority"
      - finding_id: "arxiv_regime_detector"
        comparison:
          duplicate_of: null
          similarity: 0.2
          status: NOVEL
        scores:
          novelty: 0.95
          confidence: 0.7
          priority: 0.665
        recommendation: "Add to queue, highest novelty"
  ```
- Return: Categorized findings (NOVEL, SIMILAR, DUPLICATE) with priority scores

**Output**: Deduplication results + recommendations

### 5. Update Queue & Trigger Meeting

**Delegate to**: Orchestrator

- Read current `.crypto/discovery/queue.yaml`
- Add NOVEL findings (skipping DUPLICATES):
  - Insert by priority score (highest first)
  - Track source (Twitter, arXiv, meeting, etc.)
  - Set status: PENDING
- Update `.crypto/discovery/queue.yaml`:
  ```yaml
  discovery_queue:
    last_updated: "2025-02-05T14:35:00Z"
    total_pending: 7
    items:
      - id: "arxiv_regime_detector"
        source: "arXiv 2502.05678"
        priority_score: 0.665
        hypothesis: "Bayesian regime detection..."
        status: PENDING
        added_date: "2025-02-05"
      - id: "twitter_luna_arb"
        source: "Twitter (multiple analysts)"
        priority_score: 0.68
        hypothesis: "Statistical arb on Luna pairs..."
        status: PENDING
        added_date: "2025-02-05"
      - [older items...]
  ```
- Check auto-meeting trigger:
  - If queue has items with priority_score > threshold (default: 0.7)
  - AND no strategy meeting scheduled
  - Then: Auto-schedule meeting for next available slot
  - Notify user: "X new high-priority opportunities found, scheduling meeting"
- Update `.crypto/BOOTSTRAP.md`:
  - Reflect new queue depth
  - Show discovery scan status: last Twitter scan, last arXiv scan
  - Show meeting scheduled: yes/no
- Log scan results: `.crypto/discovery/scan-stats.yaml`:
  ```yaml
  scan_statistics:
    month: "2025-02"
    twitter_scans_completed: 1
    arxiv_scans_completed: 0  # Week not over yet
    total_findings: 6
    novel_findings: 4
    avg_priority_score: 0.62
    highest_priority_item: "arxiv_regime_detector"
  ```

**Output**: Updated queue + meeting scheduled (if applicable)

### 6. Error Handling & Recovery

**Delegate to**: Orchestrator

If Twitter/arXiv API fails:
- Log error: `.crypto/discovery/discovery-errors.yaml`
  ```yaml
  errors:
    - timestamp: "2025-02-05T06:15:00Z"
      scan_type: "twitter"
      error_code: "API_TIMEOUT"
      retry_count: 0
      next_retry: "2025-02-06T06:00:00Z"
  ```
- Exponential backoff: 1 min, 5 min, 15 min, 1 hour, next day
- Max retries: 5 per scan
- After 5 failures: alert user, skip to next scheduled scan
- Don't propagate API failure to pipeline (autonomous operation)

If Scout crashes:
- Log: crash timestamp, error
- Alert user (non-critical, can retry manually)
- Next scheduled scan will attempt again

If network timeout:
- Implement timeout: 60 seconds per API call
- Retry up to 3 times with exponential backoff
- Fall back to cached data if available (last 7 days of scans)

**Output**: Error logged, retry scheduled (transparent to pipeline)

## Agents Involved

### Orchestrator
- Role: Scheduler and queueing coordinator
- Responsibilities:
  - Time-based trigger logic (cron)
  - Route to Twitter or arXiv scan
  - Update queue and trigger meeting
  - Error handling and retry logic

### External Scout
- Role: Discovery agent
- Responsibilities:
  - Query Twitter API for trending ideas
  - Review arXiv for research breakthroughs
  - Synthesize findings into hypothesis sketches
  - Rate confidence/relevance of findings

### Insight Agent
- Role: Deduplication and prioritization
- Responsibilities:
  - Compare findings against existing strategies
  - Score novelty and confidence
  - Categorize as NOVEL/SIMILAR/DUPLICATE
  - Recommend queue placement

## Tools & Capabilities Required

### New Tools Needed

```yaml
schedule_cron:
  signature: schedule_cron(agent_id, cron_expression, task_spec)
  inputs:
    agent_id: "trading-orchestrator"
    cron_expression: "0 6 * * *"         # 06:00 UTC daily
    task_spec:
      job_type: "twitter_scan"
      lookback_hours: 24
  outputs:
    job_id: "JOB-{UUID}"
    next_run: "ISO8601"

run_twitter_scan:
  signature: run_twitter_scan(keywords, lookback_hours, min_engagement)
  inputs:
    keywords: ["crypto trading", "arbitrage", "defi strategies"]
    lookback_hours: 24
    min_engagement: 100
  outputs:
    tweets_found: N
    themes_extracted: [{theme, confidence, hypothesis_sketch}]
    scan_results_path: "path/to/twitter-scan-{DATE}.yaml"

run_arxiv_scan:
  signature: run_arxiv_scan(categories, keywords, lookback_days)
  inputs:
    categories: ["quant-ph", "stat.AP", "cs.LG"]
    keywords: ["arbitrage", "market microstructure"]
    lookback_days: 7
  outputs:
    papers_found: N
    papers_selected: M
    papers: [{arxiv_id, title, hypothesis_sketch, relevance}]
    scan_results_path: "path/to/arxiv-scan-{DATE}.yaml"

deduplicate_findings:
  signature: deduplicate_findings(new_findings, registry, existing_queue)
  outputs:
    novel_count: N
    similar_count: M
    duplicate_count: K
    by_finding: [{finding_id, status, priority_score, recommendation}]

auto_queue_for_meeting:
  signature: auto_queue_for_meeting(findings, priority_threshold)
  outputs:
    items_added_to_queue: N
    meeting_scheduled: boolean
    next_meeting_time: "ISO8601" (if scheduled)
```

### Existing Tools Used

- **File I/O**: Read/write discovery files, queue, registry, bootstrap
- **Agent delegation**: external-scout, insight, orchestrator
- **External APIs**: Twitter API v2, arXiv API

### External APIs

**Twitter API v2**:
- Requires: API key, API secret (in `.crypto/config/api-keys.yaml`)
- Rate limit: 450 requests per 15 minutes
- Cost: Depends on tier (free/paid)

**arXiv API**:
- Public, no authentication required
- Rate limit: No explicit limit, but courteous to use <30k requests per day
- Cost: Free

### Resource Requirements

- **Frequency**: Daily Twitter scan (1 run), weekly arXiv scan (1 run)
- **Time per scan**: 5-10 minutes Twitter, 10-15 minutes arXiv
- **Storage**: ~50MB per month for all scan results
- **API costs**: Depends on Twitter API tier selection
- **Network**: Minimal (one-time API query per scan)

## Configuration

Add to `.crypto/config/discovery-schedule.yaml`:

```yaml
scheduled_discovery:
  # Twitter scan configuration
  twitter_scan:
    enabled: true
    schedule: "0 6 * * *"              # Daily 06:00 UTC (cron format)
    lookback_hours: 24
    min_engagement: 100

    topics:
      - crypto trading
      - defi strategies
      - arbitrage opportunities
      - yield farming innovation
      - market microstructure
      - quantitative trading

    exclude_keywords:
      - scam
      - rug pull
      - shitcoin
      - "100x"
      - DYOR
      - Not financial advice

    min_follower_count: 1000            # Only from established accounts
    required_verification: false         # Allow verified + high-follower accounts

  # arXiv scan configuration
  arxiv_scan:
    enabled: true
    schedule: "0 14 * * 5"             # Friday 14:00 UTC (weekly)
    lookback_days: 7

    categories:
      - quant-ph                        # Quantitative finance
      - stat.AP                         # Statistics applications
      - cs.LG                           # Machine learning

    search_terms:
      - arbitrage
      - market microstructure
      - signal processing
      - machine learning trading
      - regime detection
      - reinforcement learning

    min_relevance_score: 0.5
    min_citations: 0                    # Include new preprints

  # Queue management
  queue_management:
    max_queue_size: 100
    auto_meeting_trigger: true
    priority_threshold: 0.7             # Schedule meeting if item > 0.7 priority
    dedup_similarity_threshold: 0.8     # SIMILAR if >0.8 match with existing

    # Merge settings
    merge_similar_findings: true        # Combine related findings

  # Notifications
  notifications:
    slack_enabled: false
    email_enabled: true
    email_recipient: "user@example.com"
    notify_on_novel_finding: true
    notify_on_meeting_scheduled: true
    notify_on_scan_failure: true

  # API credentials
  api_keys_path: ".crypto/config/api-keys.yaml"
  api_key_twitter_bearer: "api_keys.twitter_bearer_token"
  api_key_twitter_api_key: "api_keys.twitter_api_key"
  api_key_twitter_api_secret: "api_keys.twitter_api_secret"

  # Error handling
  error_retry:
    max_retries: 5
    retry_backoff_seconds: [60, 300, 900, 3600, 86400]  # 1m, 5m, 15m, 1h, 1d
    fallback_to_cached: true
    cached_data_max_age_days: 7

  # Persistence
  scan_results_path: ".crypto/discovery/"
  error_log_path: ".crypto/discovery/discovery-errors.yaml"
  dedup_log_path: ".crypto/discovery/dedup-log.yaml"
  queue_path: ".crypto/discovery/queue.yaml"
  stats_path: ".crypto/discovery/scan-stats.yaml"
```

## Integration Points

### Triggers
- **Auto-trigger**: Cron schedule (06:00 UTC daily, Friday 14:00 UTC)
- **Manual**: `/trading-scheduled-discovery --source twitter`

### Upstream Dependencies
- Registry must exist (`.crypto/knowledge/registry.yaml`)
- API credentials must be configured
- Schedule config must be valid

### Downstream Integration
- Feeds to: Strategy meeting (auto-trigger if queue fills)
- Feeds to: `trading-pipeline` Phase 0 (strategy ideation)
- Updates: `.crypto/discovery/queue.yaml`, `.crypto/BOOTSTRAP.md`
- Notifies: User via email when novel findings detected

## Error Handling

### Twitter API Timeout (>60 seconds)
1. Catch timeout, log error
2. Retry up to 3 times with exponential backoff
3. If all 3 retries fail: Log to discovery-errors.yaml
4. Fall back to cached data (if <7 days old)
5. Schedule retry for next 6:00 UTC scan

### arXiv API Failure
1. Log error with timestamp
2. Retry up to 5 times (less critical than Twitter)
3. Fall back to last successful scan
4. Alert user (non-critical)

### Scout Agent Crashes
1. Log crash and error
2. Alert user (can manually retry)
3. Next scheduled scan will attempt again

### Scheduler Clock Skew
1. Add 5-minute grace window (trigger 05:55-06:05)
2. Check last_run timestamp to prevent duplicate runs within 1 hour
3. Log if clock detected as skewed

## Monitoring & Metrics

### Key Metrics

```yaml
discovery_scan_metrics:
  run_date: "2025-02-05"
  scan_type: "twitter"

  scan_stats:
    tweets_scanned: 2345
    themes_identified: 8
    confidence_avg: 0.72

  deduplication:
    total_findings: 8
    novel: 6
    similar: 1
    duplicate: 1
    avg_novelty_score: 0.68

  queue_impact:
    items_added: 6
    queue_size_before: 1
    queue_size_after: 7
    meeting_scheduled: true
    highest_priority_score: 0.85
```

### Alerts & Warnings

- **Alert**: Scan fails 3+ times in a week (API issue)
- **Alert**: Queue reaches max_queue_size (too many ideas)
- **Warning**: Queue depth >50 items (not processing ideas fast enough)
- **Info**: Novel finding with priority >0.85 (very high confidence)

### Dashboard Location

Track metrics in: `.crypto/live-monitoring/discovery-metrics.yaml`

Update after each scan, retain last 60 scans (2 months).

## Examples

### Example 1: Novel Twitter Idea

**Setup**:
- 2025-02-05 06:00 UTC arrives
- Twitter scan scheduled to run

**Execution**:
1. Orchestrator triggers: RUN_TWITTER_SCAN
2. External Scout queries Twitter for "arbitrage" in last 24h
3. Finds 2,345 tweets, filters to 127 high-engagement
4. Identifies 8 themes, generates hypothesis sketches
5. Results written to twitter-scan-2025-02-05.yaml:
   - Theme: "Curve 3pool arbitrage"
   - Confidence: 0.85
   - Hypothesis: "Exploit Curve 3pool fee optimization + MEV"
6. Insight Agent deduplicates:
   - Not in registry (NOVEL)
   - Novelty score: 0.82
   - Priority score: 0.85 × 0.85 = 0.72
7. Added to queue at position 2 (sorted by priority)
8. User notified: "Novel trading opportunity detected: Curve 3pool arbitrage (priority: 0.72)"
9. Meeting auto-scheduled for next available slot

**Output**: New idea queued, meeting triggered

### Example 2: Similar arXiv Paper

**Setup**:
- 2025-02-07 14:00 UTC (Friday) arrives
- arXiv scan scheduled

**Execution**:
1. Orchestrator triggers: RUN_ARXIV_SCAN
2. External Scout queries arXiv (last 7 days) for "regime detection"
3. Finds 156 papers, selects top 5 by relevance
4. One paper: "Adaptive Regime Detection with ML"
5. Hypothesis sketch: "Bayesian regime detector for entry/exit"
6. Results written to arxiv-scan-2025-02-07.yaml
7. Insight Agent deduplicates:
   - Similar to existing STR-078 (regime switching strategy)
   - Similarity score: 0.79 → SIMILAR status
   - Recommendation: "Differentiate by adding this ML technique"
8. Added to queue with note: "Extend STR-078 with arxiv paper technique"
9. User notified (lower priority): "Research paper found related to existing strategy"

**Output**: Similar idea tagged, queue updated with differentiation hint

### Example 3: Duplicate Finding

**Setup**:
- Two Twitter posts discuss the same arbitrage opportunity
- Both scanned and processed

**Execution**:
1. External Scout identifies both tweets with theme "Luna Luna-UST arbitrage"
2. Both written to twitter-scan results
3. Insight Agent deduplicates:
   - Theme already exists in queue (from yesterday's scan)
   - Similarity score: 0.96 → DUPLICATE
   - Action: Merge findings, increase confidence score
4. Queue updated:
   - Old Luna entry: confidence 0.70
   - Updated: confidence 0.82 (two sources confirm)
   - Not added twice
5. User not notified (duplicate handling silent)

**Output**: Duplicate merged, confidence increased

## Success Metrics

- **Scan uptime**: 99%+ (skip <1% of scheduled scans)
- **Novel findings per month**: >8 new ideas
- **Dedup accuracy**: >95% correct categorization
- **Queue processing**: Keep queue <50 items (ideas being consumed)
- **Meeting trigger timeliness**: <1 hour from scan to meeting scheduled
