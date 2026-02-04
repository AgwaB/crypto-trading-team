# Crypto Trading Team - Plugin Upgrades

This directory contains comprehensive specifications for 5 new skills to enhance the crypto-trading-team plugin. These upgrades address identified gaps in pipeline efficiency, discovery, monitoring, and portfolio management.

## Quick Navigation

| Skill | Purpose | Priority | Status |
|-------|---------|----------|--------|
| [parallel-validation](./parallel-validation-SKILL.md) | Run L0 validations concurrently (4× speedup) | **HIGH** | Spec Complete |
| [auto-retry](./auto-retry-SKILL.md) | Auto-fix L1/L2 failures (3 retry attempts) | **HIGH** | Spec Complete |
| [scheduled-discovery](./scheduled-discovery-SKILL.md) | Daily Twitter, weekly arXiv scans | **MEDIUM** | Spec Complete |
| [live-monitoring](./live-monitoring-SKILL.md) | Real-time streaming + drawdown alerts | **MEDIUM** | Spec Complete |
| [portfolio-rebalance](./portfolio-rebalance-SKILL.md) | Auto-balance allocations, reduce correlation | **MEDIUM** | Spec Complete |

## Documents

### Main Specification
- **[new-skills-spec.md](./new-skills-spec.md)** - Complete overview of all 5 skills with:
  - Gap analysis and design rationale
  - Cross-skill dependencies
  - Implementation roadmap (3 phases)
  - Success metrics
  - SKILL.md template

### Individual Skill Specifications
Each skill has a detailed `SKILL.md` following the plugin's established format:

1. **parallel-validation-SKILL.md**
   - Spawn 2-4 concurrent backtester agents
   - Reduce 5-minute validations from N×5min to ~5min
   - Aggregate results and update queue
   - New tools: spawn_parallel_worker, poll_worker_result, merge_validation_results

2. **auto-retry-SKILL.md**
   - Categorize fixable vs fatal failures
   - Retry 1: ML Engineer parameter optimization
   - Retry 2: Signal Generator threshold adjustment
   - Retry 3: Quantitative Analyst fundamental review
   - Max 3 attempts, extract learnings on all outcomes

3. **scheduled-discovery-SKILL.md**
   - Cron: Daily 06:00 UTC Twitter scan
   - Cron: Friday 14:00 UTC arXiv scan
   - Deduplication vs registry
   - Auto-queue novel findings
   - Auto-schedule meeting when queue fills

4. **live-monitoring-SKILL.md**
   - WebSocket connections: Binance, Kraken (extensible)
   - Real-time P&L calculation (per-trade)
   - Alert escalation: YELLOW (warning) → RED (halt) → BLACK (emergency)
   - Connection recovery with exponential backoff
   - Crash-resistant snapshots for recovery

5. **portfolio-rebalance-SKILL.md**
   - Daily drift analysis at 02:00 UTC
   - Correlation-aware, performance-weighted, risk-adjusted modes
   - Circuit breaker validation (60% total, 30% correlated, 40% individual)
   - Impact simulation before execution
   - Post-execution monitoring + learning feedback

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
**Highest ROI - Multiplies validation throughput**
1. Implement `parallel-validation` skill
   - Spawn infrastructure
   - Worker polling and result aggregation
   - Queue status updates
2. Implement `auto-retry` skill
   - Failure categorization
   - Multi-agent retry routing
   - Learning extraction

**Expected outcome**: 3-4× faster strategy validation pipeline

### Phase 2: Discovery & Monitoring (Weeks 3-4)
**Enable continuous opportunity flow + protect deployed strategies**
3. Implement `scheduled-discovery` skill
   - Cron scheduler integration
   - Twitter API client
   - arXiv API client
   - Deduplication and queueing
4. Implement `live-monitoring` skill
   - WebSocket connection management
   - Real-time P&L calculation
   - Alert detection and escalation
   - Risk Manager integration

**Expected outcome**: New opportunities discovered daily, live protection for deployed strategies

### Phase 3: Portfolio Optimization (Week 5)
**Mature system after above stabilized**
5. Implement `portfolio-rebalance` skill
   - Correlation analysis
   - Rebalancing algorithm (4 modes)
   - Circuit breaker enforcement
   - Impact simulation

**Expected outcome**: Reduced correlation risk, optimized capital allocation

## Architecture & Integration

### Skill Dependencies

```
trading-pipeline (existing)
├─ Phase 1: Strategy Ideation
│  └─ Feeds to: Phase 2 (L0 validation)
│
├─ Phase 2: Tiered Validation
│  ├─ Uses: parallel-validation (NEW) for L0
│  │  └─ On fail: auto-retry (NEW) for L1/L2
│  │
│  └─ On success: Phase 3 (Risk & Deployment)
│
├─ Phase 3: Risk & Deployment
│  └─ On deploy: live-monitoring (NEW) starts
│
└─ Continuous:
   ├─ scheduled-discovery (NEW) feeds strategy ideas
   ├─ live-monitoring (NEW) protects deployed strategies
   └─ portfolio-rebalance (NEW) optimizes allocations
```

### New Tools Introduced

| Tool Category | Tools | Purpose |
|---|---|---|
| **Parallelization** | spawn_parallel_worker, poll_worker_result, merge_validation_results | Enable concurrent validation |
| **Failure Handling** | analyze_failure_reason, generate_parameter_fix, apply_fix_to_strategy | Auto-retry system |
| **Discovery** | schedule_cron, run_twitter_scan, run_arxiv_scan, deduplicate_findings | Opportunity sourcing |
| **Monitoring** | websocket_connect, websocket_buffer, calculate_live_pnl, escalate_alert | Real-time tracking |
| **Portfolio** | calculate_correlation_matrix, generate_rebalance_proposal, simulate_rebalance_impact | Rebalancing engine |

### Agent Involvement

**New role assignments**:
- Monitor Agent: Owns live-monitoring skill (24/7 operation)
- Order Executor: Handles rebalancing trades and live halts
- Risk Manager: Escalates RED/BLACK alerts from live-monitoring
- Feedback Agent: Extracts learnings from auto-retry and rebalancing

**Existing agents unchanged**: Continue in pipeline roles (backtester, strategy-researcher, etc.)

## Configuration Changes

Each skill requires configuration additions:

| Skill | Config File | Key Settings |
|-------|---|---|
| parallel-validation | `.crypto/config/parallel-validation.yaml` | max_workers, timeouts, resource limits |
| auto-retry | `.crypto/config/auto-retry.yaml` | fixable error patterns, agent routing, learning injection |
| scheduled-discovery | `.crypto/config/discovery-schedule.yaml` | cron schedules, API credentials, dedup thresholds |
| live-monitoring | `.crypto/config/live-monitoring.yaml` | exchange connections, alert thresholds, API keys |
| portfolio-rebalance | `.crypto/config/portfolio-rebalance.yaml` | circuit breakers, modes, simulation, learning |

Example configuration for one skill:
```yaml
parallel_validation:
  max_workers: 4
  worker_timeout_seconds: 600
  l0_timeout_multiplier: 1.0
  polling_interval_seconds: 5
  fail_fast: false
  auto_escalate_threshold: 0.5
  resource_limits:
    memory_per_worker_mb: 200
    cpu_percent_per_worker: 30
```

## Success Metrics & Goals

### By Skill

| Skill | Metric | Target | Current (Est.) |
|-------|--------|--------|---|
| **parallel-validation** | Validation speedup | 4× | 1× (sequential) |
| | Wall-clock time for N strategies | ~5 min | N×5 min |
| | Worker completion rate | 99%+ | N/A |
| **auto-retry** | Fix success rate | >60% | N/A |
| | Avg retry attempts | <1.5 | N/A |
| | Learning extraction rate | 100% | N/A |
| **scheduled-discovery** | Scan uptime | 99%+ | N/A |
| | Novel findings/month | >8 | N/A |
| | Queue processing speed | <50 items | N/A |
| **live-monitoring** | Connection uptime | 99%+ | N/A |
| | Alert latency | <5s | N/A |
| | Connection recovery | <30s | N/A |
| | Data accuracy | >99.9% | N/A |
| **portfolio-rebalance** | Rebalance frequency | 1-2 per week | N/A |
| | Circuit breaker compliance | 100% | N/A |
| | Performance improvement | >3% Sharpe | N/A |
| | Limit adherence | 100% | N/A |

### Portfolio-Level Improvements

After all 5 skills deployed:
- **Pipeline throughput**: 3-4× faster strategy evaluation
- **Risk management**: Real-time alerts + auto-halt on drawdown
- **Portfolio optimization**: 5-15% average Sharpe improvement
- **Opportunity discovery**: Continuous stream of vetted ideas
- **System reliability**: 24/7 monitoring with graceful degradation

## Files in This Directory

```
upgrades/
├── README.md (this file)
├── new-skills-spec.md (comprehensive specification)
├── parallel-validation-SKILL.md
├── auto-retry-SKILL.md
├── scheduled-discovery-SKILL.md
├── live-monitoring-SKILL.md
└── portfolio-rebalance-SKILL.md
```

## Next Steps

### For Immediate Implementation (Phase 1)

1. **Parallel Validation**
   - [ ] Create `/skills/parallel-validation/` directory
   - [ ] Copy `parallel-validation-SKILL.md` → `SKILL.md`
   - [ ] Implement spawn_parallel_worker tool
   - [ ] Implement poll_worker_result tool
   - [ ] Test with 2-4 concurrent backtester agents

2. **Auto-Retry**
   - [ ] Create `/skills/auto-retry/` directory
   - [ ] Copy `auto-retry-SKILL.md` → `SKILL.md`
   - [ ] Implement failure categorization
   - [ ] Implement agent routing (ML Engineer, Signal Gen, Quant)
   - [ ] Test with known fixable failures

### For Phase 2 (Weeks 3-4)

3. **Scheduled Discovery**
   - [ ] Create `/skills/scheduled-discovery/` directory
   - [ ] Implement cron scheduler
   - [ ] Connect Twitter API v2
   - [ ] Connect arXiv API
   - [ ] Implement deduplication logic

4. **Live Monitoring**
   - [ ] Create `/skills/live-monitoring/` directory
   - [ ] Establish WebSocket connections
   - [ ] Implement real-time P&L calculation
   - [ ] Implement alert escalation
   - [ ] Test with deployed strategy

### For Phase 3 (Week 5)

5. **Portfolio Rebalance**
   - [ ] Create `/skills/portfolio-rebalance/` directory
   - [ ] Implement correlation analysis
   - [ ] Implement 4 rebalancing modes
   - [ ] Implement circuit breaker validation
   - [ ] Test with simulation before execution

## Testing Strategy

### Unit Testing
- Test each skill independently
- Mock external APIs (Twitter, arXiv, exchanges)
- Verify data transformations and calculations

### Integration Testing
- Test within pipeline context
- Verify queue updates and status flows
- Test cross-skill dependencies

### Live Testing
- Start with `--dry-run` flags (no execution)
- Gradual rollout with monitoring
- Measure against success metrics

## Migration & Backward Compatibility

**Important**: All new skills are additive
- Existing pipeline continues unchanged
- New skills are opt-in (enable via BOOTSTRAP.md)
- Graceful degradation if skill fails
- No breaking changes to agent APIs

Example BOOTSTRAP.md updates:
```yaml
active_skills:
  trading-pipeline: true      # Existing
  trading-parallel-validation: true    # NEW Phase 1
  trading-auto-retry: true             # NEW Phase 1
  trading-scheduled-discovery: true    # NEW Phase 2
  trading-live-monitoring: true        # NEW Phase 2
  trading-portfolio-rebalance: true    # NEW Phase 3
```

## Maintenance & Tuning

### Configuration Tuning
- Adjust alert thresholds based on strategy behavior
- Tune parallelism (max_workers) based on system resources
- Refine rebalancing modes as strategies mature

### Monitoring & Alerts
- Dashboard in `.crypto/live-monitoring/` tracks all metrics
- Alert thresholds documented in each skill spec
- Learning extraction informs algorithm improvements

### Version Control
- Track all changes in git
- Document breaking changes (none expected)
- Maintain backward compatibility

## Questions & Troubleshooting

### Common Issues

**Q: Why 4 workers max for parallel-validation?**
A: Empirical testing shows 4 concurrent backtester agents maximizes throughput while respecting resource constraints (~200MB per worker). Diminishing returns beyond 4.

**Q: When is portfolio-rebalance triggered?**
A: Daily at 02:00 UTC, or manually. Automatic rebalancing only if drift >10% AND improvement >5% projected (conservative by default).

**Q: Can I disable individual skills?**
A: Yes. Set `enabled: false` in respective config file (e.g., `parallel-validation.yaml`). Pipeline adapts to sequential validation if disabled.

**Q: What if live-monitoring detects catastrophic error?**
A: BLACK alert triggers immediate halt of ALL trading. User must manually review and approve resume via `/trading-live-monitor --resume`.

## References

- **Original plugin**: `/Users/toby/.claude/plugins/marketplaces/crypto-trading-team/`
- **Existing skills**: `/skills/{pipeline,evaluate,risk-check,meeting,init}/`
- **Agent documentation**: `/agents/*.md`
- **Plugin config**: `/hooks/`, `/commands/`

## Author Notes

These specifications were created to address specific gaps:
1. **Validation bottleneck**: Sequential L0 checks (5 min each) → parallel (5 min total)
2. **Brittle validation**: Single-shot checks → intelligent retry with learned fixes
3. **Stagnant opportunity flow**: Manual scans → continuous automated discovery
4. **Blind deployment**: No real-time monitoring → 24/7 WebSocket monitoring + alerts
5. **Portfolio risk drift**: Static allocations → dynamic rebalancing

Each skill is designed for:
- **Reliability**: Error handling, recovery, graceful degradation
- **Observability**: Metrics, logs, alerts, dashboards
- **Testability**: Dry-run modes, simulation, validation
- **Extensibility**: New exchanges (live-monitoring), new modes (rebalancing), new sources (discovery)

See [new-skills-spec.md](./new-skills-spec.md) for complete design rationale and architecture.
