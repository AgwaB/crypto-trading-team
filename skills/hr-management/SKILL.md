---
name: crypto:hr
description: "HR Management - hire, fire, promote, review agents"
argument-hint: "[hire|fire|promote|review] [agent-type|agent-name]"
---

# HR Management

Manage the agent workforce: hire new specialists, fire underperformers, promote high performers, and conduct performance reviews.

## Commands

| Command | Purpose |
|---------|---------|
| `/crypto:hr hire [type]` | Hire new agent from template |
| `/crypto:hr fire [agent]` | Terminate underperformer |
| `/crypto:hr promote [agent]` | Promote to team lead |
| `/crypto:hr review` | Manual performance review (every 10 runs) |
| `/crypto:hr status` | Show workforce status |

## Hiring Protocol

### When to Hire

Hire when:
1. **New capability needed**: "We need an options data specialist"
2. **Capacity shortage**: Team consistently overloaded
3. **Black swan potential**: New junior for creative ideas
4. **Replacement**: After firing an underperformer

### Hiring Process

1. **Identify Need**: What role and why?
2. **Select Template**: From `config/agent-templates/`
3. **Customize**: Adjust for specific requirements
4. **Create Agent**: Generate `agents/{new-agent}.md`
5. **Assign Team**: Add to appropriate team lead
6. **Onboard**: Add to performance schema with probation status
7. **Monitor**: Track closely for first 5 strategies

### Agent Templates

Located at `.crypto/config/agent-templates/`:

**specialist-template.yaml**
```yaml
name: "trading-{domain}-specialist"
description: "{Domain} specialist for {purpose}"
model: "sonnet"  # Default tier
team: null  # Assign during creation
tools:
  - Read
  - Grep
  - Glob
  - Bash
role: "Specialist"
status: "probation"
probation_period: 5  # strategies
```

**junior-template.yaml**
```yaml
name: "trading-junior-{name}"
description: "Junior agent for {purpose}"
model: "haiku"  # Always haiku
team: "research"  # Juniors go to research
tools:
  - Read
  - Grep
  - Glob
role: "Junior"
status: "probation"
probation_period: 10  # strategies (longer for juniors)
special_instructions: |
  - Encouraged to propose wild ideas
  - Not penalized for rejected ideas
  - Evaluated on novelty, not success rate
```

**team-lead-template.yaml**
```yaml
name: "trading-{team}-lead"
description: "{Team} team lead"
model: "opus"  # Always opus
team: "{team}"
tools:
  - Read
  - Grep
  - Glob
  - Task
role: "Team Lead"
status: "active"
manages: []  # Fill during creation
```

## Firing Protocol

### When to Fire

Fire when:
1. **Consistent underperformance**: Score < 0.3 for 3+ cycles
2. **Probation failure**: Score < 0.2 while on probation
3. **Severe violations**: Multiple learning violations
4. **Role elimination**: Capability no longer needed

### Firing Process

1. **Verify Criteria**: Check performance history
2. **Document Reason**: Record why firing
3. **Archive Agent**: Move to `.crypto/archives/agents/`
4. **Update Schema**: Set status to "retired"
5. **Reassign Work**: Redistribute to remaining agents
6. **Update Team Lead**: Notify managing lead
7. **Log Action**: Record in HR log

### Archive Format

`.crypto/archives/agents/{agent-name}.md`:
```markdown
# Archived Agent: trading-junior-example

**Retired**: 2026-02-05
**Reason**: Consistent underperformance (score 0.22 for 3 cycles)
**Last Team**: research
**Last Lead**: trading-research-lead

## Performance History
- Cycle 3: 0.28
- Cycle 4: 0.25
- Cycle 5: 0.22

## Final Metrics
- Ideas proposed: 12
- L0 pass rate: 8%
- Learning violations: 3

## Notes
Agent struggled with understanding market context.
Consider different onboarding for future similar hires.

---
[Original agent spec preserved below]
...
```

## Promotion Protocol

### When to Promote

Promote when:
1. **Consistent excellence**: Score > 0.85 for 3+ cycles
2. **Leadership potential**: Good at coordination
3. **Team need**: New team lead position available

### Promotion Process

1. **Verify Criteria**: Check performance history
2. **Assess Fit**: Leadership qualities?
3. **Create Lead Role**: Use team-lead-template
4. **Transfer Agent**: Upgrade existing agent
5. **Update Hierarchy**: Assign team members
6. **Announce**: Notify team of new structure

## Performance Review Protocol

### Triggers

- **Automatic**: Every 10 pipeline runs (via hook)
- **Manual**: `/crypto:hr review`

### Review Process

1. **Gather Data**: Read performance schema and log
2. **Calculate Scores**: Update composite scores
3. **Identify Actions**: Flag hire/fire/promote needs
4. **Generate Report**: `.crypto/reports/reviews/REVIEW-{NNN}.md`
5. **Signal Actions**: Write to `.crypto/signals/hr-actions.yaml`

### Review Report Format

```markdown
# Performance Review - Cycle {NNN}

**Date**: {timestamp}
**Review Period**: Pipeline runs {X} to {Y}

## Workforce Summary

| Status | Count |
|--------|-------|
| Active | 17 |
| Probation | 2 |
| Promoted | 1 |
| Terminated | 0 |

## Performance Distribution

| Range | Agents |
|-------|--------|
| 0.85+ (Excellent) | signal-generator, quant-analyst |
| 0.60-0.84 (Good) | backtester, researcher, ... |
| 0.30-0.59 (Needs Improvement) | junior-maverick |
| <0.30 (Critical) | - |

## Required Actions

### Immediate
- [ ] Put {agent} on probation (score: 0.28)

### Recommended
- [ ] Consider promoting {agent} (score: 0.87, 3rd excellent cycle)
- [ ] Hire {role} specialist (capacity gap identified)

## Team Health

### Research Team
- Lead: trading-research-lead
- Capacity: 7/8 (1 on probation)
- Avg Score: 0.62

### Validation Team
- Lead: trading-validation-lead
- Capacity: 5/5
- Avg Score: 0.71

### Execution Team
- Lead: trading-execution-lead
- Capacity: 4/4
- Avg Score: 0.68
```

## Integration

### With Retrospectives
- Retrospective provides per-cycle metrics
- HR Review aggregates across cycles
- Retrospective signals immediate issues
- HR Review makes structural decisions

### With Team Leads
- Leads recommend hiring/firing
- HR executes after verification
- Leads onboard new hires
- Leads manage day-to-day performance

### With Orchestrator
- Major HR decisions require CEO approval
- Orchestrator can override recommendations
- Budget constraints flow from Orchestrator

## Files

| File | Purpose |
|------|---------|
| `.crypto/config/agent-performance-schema.yaml` | Current scores |
| `.crypto/config/agent-templates/` | Templates for hiring |
| `.crypto/archives/agents/` | Retired agents |
| `.crypto/reports/reviews/` | Review reports |
| `.crypto/signals/hr-actions.yaml` | Pending actions |
| `.crypto/knowledge/hr-log.yaml` | Action history |
