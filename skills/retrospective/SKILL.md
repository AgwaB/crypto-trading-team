---
name: crypto:retrospective
description: "Team retrospective - analyze performance, identify patterns, generate report"
argument-hint: "[--force] [--cycle N]"
---

# Team Retrospective

Automated team retrospective that analyzes the last cycle of strategies, calculates per-agent metrics, identifies patterns, and generates actionable recommendations.

## Triggers

- **Automatic**: When `pipeline_runs % 5 == 0` (via hook)
- **Manual**: `/crypto:retrospective`
- **Force**: `/crypto:retrospective --force` (run even if not due)

## Arguments

- `--force`: Run retrospective regardless of cycle count
- `--cycle N`: Analyze specific cycle number instead of latest

## Protocol

### Phase 1: Data Gathering

1. **Read Bootstrap**: `.crypto/BOOTSTRAP.md` for context
2. **Read Registry**: `.crypto/knowledge/registry.yaml` for strategy outcomes
3. **Read Performance Log**: `.crypto/knowledge/agent-performance-log.yaml` for actions
4. **Read Previous Retrospective**: `.crypto/reports/retrospectives/` for comparison
5. **Identify Cycle Range**: Determine which strategies belong to current cycle (last 5 pipeline runs)

### Phase 2: Calculate Metrics

For each agent, calculate:

| Metric | Formula |
|--------|---------|
| `approval_rate` | approved / total_reviewed |
| `false_positive_rate` | (approved but later failed) / approved |
| `false_negative_rate` | (rejected but retry succeeded) / rejected |
| `efficiency` | tasks_completed / time_taken |
| `violation_rate` | learning_violations / total_actions |

### Phase 3: Pattern Analysis

Identify:
1. **Top Performers**: Agents with highest composite scores
2. **Underperformers**: Agents below 0.3 threshold
3. **Trends**: Improving or declining performance vs last cycle
4. **Bottlenecks**: Which phase causes most rejections?
5. **Learning Gaps**: Most common violation types

### Phase 4: Generate Report

Create `.crypto/reports/retrospectives/RETRO-{NNN}.md`:

```markdown
# Retrospective Report - Cycle {NNN}

**Date**: {timestamp}
**Pipeline Runs**: {X} to {Y}
**Strategies Analyzed**: {count}

## Summary

- Strategies Approved: X (Y%)
- Strategies Rejected: Z
- Average Time to Validation: N hours

## Team Performance

### Research Team
| Agent | Score | Trend | Status |
|-------|-------|-------|--------|
| strategy-researcher | 0.72 | ↑ +0.05 | active |
| junior-maverick | 0.45 | ↓ -0.10 | active |
| ... | ... | ... | ... |

### Validation Team
| Agent | Score | Trend | Status |
|-------|-------|-------|--------|
| quant-analyst | 0.68 | → 0.00 | active |
| ... | ... | ... | ... |

### Execution Team
| Agent | Score | Trend | Status |
|-------|-------|-------|--------|
| signal-generator | 0.75 | ↑ +0.08 | active |
| ... | ... | ... | ... |

## Key Findings

### What Went Well
- {positive pattern 1}
- {positive pattern 2}

### What Needs Improvement
- {negative pattern 1}
- {negative pattern 2}

### Learning Violations
- Agent X ignored learning Y (Z times)

## Recommendations

### Immediate Actions
1. [ ] {action 1}
2. [ ] {action 2}

### Consider for Next Cycle
- {suggestion 1}
- {suggestion 2}

### HR Considerations
- **Probation Warning**: {agent} (score: 0.28, 2nd consecutive low)
- **Promotion Candidate**: {agent} (score: 0.87, 3rd consecutive high)
```

### Phase 5: Update Performance Schema

1. Write calculated scores to `.crypto/config/agent-performance-schema.yaml`
2. Update `last_review` timestamps
3. Increment `review_cycle` counter
4. Set `status: probation` for underperformers (if applicable)

### Phase 6: Signal HR Actions (if needed)

If any agent:
- Score < 0.3 for 2+ cycles → Signal for probation
- Score < 0.2 on probation → Signal for termination
- Score > 0.85 for 3+ cycles → Signal for promotion consideration

Write signals to `.crypto/signals/hr-actions.yaml`:
```yaml
pending_actions:
  - agent: trading-junior-maverick
    action: probation
    reason: "Score 0.25 for 2 consecutive cycles"
    recommended_by: RETRO-005
```

## Output Files

| File | Purpose |
|------|---------|
| `.crypto/reports/retrospectives/RETRO-{NNN}.md` | Human-readable report |
| `.crypto/config/agent-performance-schema.yaml` | Updated scores |
| `.crypto/signals/hr-actions.yaml` | Pending HR actions (if any) |

## Integration with Never-End Loop

When running in never-end mode:
1. Check `pipeline_runs` in `.crypto/never-end-state.md`
2. If divisible by 5, auto-run retrospective
3. Continue loop after retrospective completes

## Example Usage

```
User: /crypto:retrospective

Agent: Running team retrospective for cycle 5...

[Phase 1] Gathering data from last 5 pipeline runs...
[Phase 2] Calculating agent metrics...
[Phase 3] Analyzing patterns...
[Phase 4] Generating report...
[Phase 5] Updating performance scores...
[Phase 6] Checking for HR actions...

✅ Retrospective complete!

Key Findings:
- 12 strategies analyzed (7 approved, 5 rejected)
- Top performer: trading-signal-generator (0.82)
- Needs attention: trading-junior-maverick (0.31)

Report saved to: .crypto/reports/retrospectives/RETRO-005.md
```
