# Agent Templates

Templates for hiring new agents into the crypto trading team.

## Available Templates

| Template | Model | Use Case |
|----------|-------|----------|
| `specialist-template.yaml` | sonnet | Domain experts for specific capabilities |
| `junior-template.yaml` | haiku | Black swan generators, creative experimenters |
| `team-lead-template.yaml` | opus | Team coordination and management |

## Quick Start

### Hiring a Specialist

```bash
# 1. Copy template
cp specialist-template.yaml ../../../agents/trading-new-specialist.md

# 2. Customize fields
# - Replace {domain} with specialty (e.g., "options", "sentiment")
# - Replace {purpose} with function
# - Set team assignment
# - Adjust tools if needed

# 3. Add to performance schema
# Add entry to agent-performance-schema.yaml with status: "probation"

# 4. Assign to team lead
# Add agent name to team lead's "manages" list
```

### Hiring a Junior

```bash
# 1. Copy template
cp junior-template.yaml ../../../agents/trading-junior-newname.md

# 2. Customize fields
# - Replace {name} with unique identifier
# - Replace {purpose} with creative focus
# - Always keep team: "research" and model: "haiku"

# 3. Add to performance schema
# Use junior-specific evaluation criteria

# 4. Assign mentor
# Pair with senior specialist for guidance
```

### Promoting to Team Lead

```bash
# 1. Verify promotion criteria
# - Score >0.85 for 3+ cycles
# - Leadership potential demonstrated

# 2. Copy template
cp team-lead-template.yaml ../../../agents/trading-team-lead.md

# 3. Customize fields
# - Set team name
# - Add initial team members to "manages" list
# - Keep model: "opus"

# 4. Update team structure
# - Update managed agents to reference new lead
# - Announce to team
```

## Template Structure

All templates include:

- **Basic Info**: name, description, model tier
- **Assignment**: team, role, status
- **Tools**: Required tool access
- **Instructions**: Role-specific guidance
- **Performance Expectations**: Evaluation criteria
- **Usage Examples**: How to customize

## Probation Periods

| Role | Duration | Pass Criteria |
|------|----------|---------------|
| Specialist | 5 strategies | Score >0.4 avg |
| Junior | 10 strategies | Novelty >0.5 OR 1 major insight |
| Team Lead | None | Promoted from proven performers |

## Performance Metrics

### Specialist Scoring
- L0 pass rate: >30% during probation
- L1 improvement: >15% from baseline
- Learning compliance: <2 violations per cycle
- Response time: <5min average

### Junior Scoring (Different!)
- Novel ideas per cycle: >3
- Idea adoption rate: >10%
- Learning compliance: <3 violations
- Risk-taking: Expected high (not penalized)

### Team Lead Scoring
- Team average score: >0.60
- Team L0 pass rate: >40%
- Member development: >80% probation pass rate
- Escalation quality: <10% unnecessary

## File Locations

```
.crypto/
├── config/
│   ├── agent-templates/          # This directory
│   │   ├── specialist-template.yaml
│   │   ├── junior-template.yaml
│   │   └── team-lead-template.yaml
│   └── agent-performance-schema.yaml  # Add new hires here
├── archives/
│   └── agents/                   # Retired agents go here
└── reports/
    └── reviews/                  # Performance reviews
```

## Best Practices

### When to Hire

1. **Specialist**: New capability gap identified
2. **Junior**: Need creative/unconventional thinking
3. **Team Lead**: Team size >5 without lead

### When NOT to Hire

1. Temporary capacity issue (wait for current agents to clear workload)
2. Capability overlap (train existing agent instead)
3. During major system changes (wait for stability)

### Onboarding Checklist

- [ ] Create agent file from template
- [ ] Add to performance schema with probation status
- [ ] Assign to team and team lead
- [ ] Configure tool access
- [ ] Set up monitoring for probation period
- [ ] Schedule first review checkpoint

### Firing Checklist

- [ ] Verify performance criteria met
- [ ] Document reason for termination
- [ ] Archive agent file to `.crypto/archives/agents/`
- [ ] Update performance schema (status: "retired")
- [ ] Reassign work to remaining agents
- [ ] Notify team lead
- [ ] Log action in hr-log.yaml

## Integration with HR Skill

These templates are used by `/crypto:hr` commands:

```bash
/crypto:hr hire specialist    # Uses specialist-template.yaml
/crypto:hr hire junior        # Uses junior-template.yaml
/crypto:hr promote {agent}    # Uses team-lead-template.yaml
```

The HR skill handles the full workflow including:
- Template customization prompts
- File creation in correct locations
- Performance schema updates
- Team assignments
- Onboarding setup
