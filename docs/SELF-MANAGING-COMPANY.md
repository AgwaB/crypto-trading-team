# Self-Managing Company Architecture

## Overview

The crypto-trading-team operates as a **self-managing company** that runs autonomously 24/7. Rather than a static set of agents executing predefined tasks, the system functions like a real organization with performance reviews, hiring/firing, team hierarchy, and continuous improvement cycles.

### Core Vision

Agents operate with corporate discipline:
- **Performance accountability**: Every agent is measured and ranked
- **Dynamic scaling**: Teams grow with specialized roles, shrink underperformers
- **Data-driven decisions**: All hiring, firing, and promotion decisions based on quantifiable metrics
- **Continuous learning**: Retrospectives and feedback loops embedded in operations
- **Autonomous self-management**: No human intervention required for HR decisions

### Key Principles (Translated from Korean Philosophy)

1. **Scale teams strategically** - Add middle managers and specialists as complexity grows
2. **Prevent chaos through structure** - Don't scale recklessly; maintain clear hierarchies and processes
3. **Conduct retrospectives** - Regularly analyze what works and what doesn't
4. **Provide feedback for improvement** - Every agent gets quantitative performance signals
5. **Hire specialists** - When new capabilities needed, add agents with specific expertise
6. **Hire juniors** - Assign repetitive tasks and black swan discovery to junior agents
7. **Fire underperformers** - After probation, remove agents below performance thresholds
8. **Think quantitatively** - All decisions backed by metrics (quant mentality)

---

## Architecture Diagram

```
                     Orchestrator (CEO)
                      (claude-opus)
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
    Research Lead     Validation Lead   Execution Lead
    (idea pipeline)   (quality gates)   (code & deploy)
         │                 │                 │
    ┌────┼────┬────┐  ┌────┼────┐     ┌────┼────┬────┐
    │    │    │    │  │    │    │     │    │    │    │
    ▼    ▼    ▼    ▼  ▼    ▼    ▼     ▼    ▼    ▼    ▼
researcher  junior- junior- external quant- backtester critic signal- order-  monitor
            maverick datacurious scout analyst          generator executor

    [Performance Scoring System]
         Every agent tracked with:
         - tasks_completed
         - approval_rate
         - false_positive_rate
         - learning_violations
         - composite_score
         - status (active/probation/retired)

    [Retrospective Engine]
         Every 5 pipeline runs:
         - Gather agent metrics
         - Identify patterns
         - Generate improvement recommendations

    [Performance Reviews]
         Every 10 pipeline runs:
         - Calculate composite scores
         - Identify underperformers
         - Recommend hiring/firing actions
```

---

## Key Components

### 1. Agent Performance Scoring System

**Location:** `.crypto/config/agent-performance-schema.yaml`

Every agent is continuously measured against quantitative metrics:

```yaml
agent_performance:
  schema_version: "1.0"

  metrics:
    tasks_completed:
      description: "Total number of tasks executed"
      weight: 0.15
      min_threshold: 1

    approval_rate:
      description: "Ratio of downstream approvals (strategy passed L1-L3)"
      weight: 0.35
      min_threshold: 0.40
      benchmark: 0.65

    false_positive_rate:
      description: "Strategies flagged as good but failed in next tier"
      weight: 0.25
      max_threshold: 0.20

    learning_violations:
      description: "Number of times agent violates existing learnings"
      weight: 0.15
      max_threshold: 3

    speed_efficiency:
      description: "Median execution time compared to peer group"
      weight: 0.10
      target: 1.0x (mean peer time)

  composite_score_formula: |
    score = (
      (tasks_completed / mean_peer_tasks) * 0.15 +
      (approval_rate / 0.65) * 0.35 +
      max(0, 1 - (false_positive_rate / 0.20)) * 0.25 +
      max(0, 1 - (learning_violations / 3)) * 0.15 +
      (mean_peer_speed / median_execution_time) * 0.10
    )

    # Clamped between 0.0 (worst) and 1.0 (best)
    final_score = min(max(score, 0.0), 1.0)

  status_levels:
    active:
      score_range: [0.50, 1.00]
      description: "Performing well, can be assigned new tasks"

    probation:
      score_range: [0.30, 0.50)
      description: "Below expected performance, monitoring period"
      duration: "3 reviews (30 pipeline runs)"
      escalation: "If still below 0.40 after probation → termination"

    retired:
      score_range: [0.0, 0.30)
      description: "Archived - no longer assigned tasks"
      recovery: "Can be reinstated if bottleneck detected in domain"
```

**Performance Log Location:** `.crypto/knowledge/agent-performance-log.yaml`

Append-only log tracking all agent actions:

```yaml
performance_log:
  - timestamp: "2025-02-05T14:32:00Z"
    agent: "strategy-researcher"
    action: "created_hypothesis"
    strategy_id: "STR-042"
    outcome: "approved_L1"
    execution_time_sec: 245

  - timestamp: "2025-02-05T14:45:00Z"
    agent: "backtester"
    action: "backtest_complete"
    strategy_id: "STR-042"
    sharpe_ratio: 0.68
    outcome: "approved_L2"
    execution_time_sec: 1823
```

**Status Dashboard:** `.crypto/reports/agent-status.yaml`

Current status of all agents (updated after each performance review):

```yaml
agent_status:
  active:
    - name: "strategy-researcher"
      score: 0.78
      tasks_completed: 127
      approval_rate: 0.71
      false_positive_rate: 0.08
      learning_violations: 0

    - name: "backtester"
      score: 0.82
      tasks_completed: 156
      approval_rate: 0.79
      false_positive_rate: 0.05
      learning_violations: 0

  probation:
    - name: "junior-maverick"
      score: 0.35
      tasks_completed: 8
      approval_rate: 0.25
      false_positive_rate: 0.50
      learning_violations: 2
      probation_expires: "2025-02-25"

  retired:
    - name: "strategy-mutator"
      score: 0.22
      retired_date: "2025-01-28"
      reason: "false_positive_rate exceeded 0.35"
      recovery_possible: true
```

---

### 2. Automated Retrospectives (Every 5 Pipeline Runs)

**Trigger Mechanism:**
- PostToolUse hook counts pipeline runs in `.crypto/state/pipeline-counter.yaml`
- When `pipeline_runs % 5 == 0`, retrospective triggered automatically

**Process:**

1. **Gather Data** (Agent: orchestrator)
   - Read agent performance log
   - Collect metrics for all agents from last 5 runs
   - Gather strategy data (approval rates, rejection reasons)

2. **Calculate Metrics** (Agent: backtester + quantitative-analyst)
   - Tier rejection rates (L0, L1, L2, L3)
   - Agent approval rates
   - Strategy quality trends
   - Execution time trends

3. **Identify Patterns** (Agent: critic)
   - Which rejection types dominate?
   - Which agents flagging issues correctly vs falsely?
   - Are learnings being applied effectively?
   - Bottlenecks in pipeline?

4. **Generate Report** (Agent: feedback)
   - Produce human-readable summary
   - Recommend process improvements
   - Flag anomalies
   - Suggest new learnings to extract

**Output:**
- File: `.crypto/reports/retrospectives/RETRO-{NNN}.md`
- Example: `.crypto/reports/retrospectives/RETRO-001.md`

```markdown
# Retrospective #1 (Runs 1-5)
**Generated:** 2025-02-05T15:30:00Z
**Runs Analyzed:** 5

## Key Metrics
- Total strategies processed: 12
- L0 approval rate: 42% (target: 70%)
- L1 approval rate: 68%
- L2 approval rate: 75%
- L3 approval rate: 82%

## Agent Performance Highlights
- **strategy-researcher**: 0.78 score, 100% approval rate in this period
- **junior-maverick**: 0.35 score, only 25% approval rate (3 false positives)
- **backtester**: 0.82 score, 79% approval rate

## Issues Identified
1. junior-maverick producing high-risk ideas with poor fundamentals
2. External scout not validating social sentiment properly
3. Learning L-042 about momentum thresholds not being applied

## Recommendations
1. Decrease junior-maverick temperature from 0.9 to 0.8
2. Add stricter validation for social sentiment signals
3. Update feedback agent to proactively check against L-042

## Action Items
- [ ] Update junior-maverick config
- [ ] Add validation rule to external-scout
- [ ] Verify learning injection in next 5 runs
```

---

### 3. Performance Reviews (Every 10 Pipeline Runs)

**Trigger Mechanism:**
- PreToolUse hook detects `pipeline_runs % 10 == 0`
- Automatic performance review initiated

**Process:**

1. **Calculate Composite Scores** (Agent: quantitative-analyst)
   - Use performance scoring formula
   - Compare against historical benchmarks
   - Identify trends (improving vs degrading)

2. **Identify Underperformers** (Agent: critic)
   - Agents with score < 0.50
   - Agents with approval_rate < 0.40
   - Agents with false_positive_rate > 0.20
   - Agents violating learnings consistently

3. **Recommend Actions** (Agent: feedback + orchestrator)
   - **Score 0.70+**: Excellent, consider for lead role or specialization
   - **Score 0.50-0.70**: Satisfactory, maintain current assignment
   - **Score 0.30-0.50**: Probation, monitor closely, retrain if needed
   - **Score < 0.30**: Termination recommended, archive agent

**Termination Criteria:**
- Score below 0.30 for 2 consecutive reviews, OR
- Score 0.30-0.50 for 3 consecutive reviews with no improvement, OR
- Critical failure (learning violation >5, false positive rate >0.50)

**Output:**
- File: `.crypto/reports/performance-reviews/REVIEW-{NNN}.md`
- Archive file: `.crypto/archives/agent-reviews/REVIEW-{NNN}-archive.md` (after 30 days)

```markdown
# Performance Review #2 (Runs 6-10)
**Generated:** 2025-02-05T16:45:00Z
**Review Period:** 10 pipeline runs

## Executive Summary
- 5 agents active, 1 on probation, 0 retired
- Overall system approval rate: 68.5% (up from 67.2%)
- Key bottleneck: L0 filtering too lenient

## Individual Agent Reviews

### ★★★★★ strategy-researcher (Score: 0.78)
**Status:** EXCELLENT - Recommend for Research Lead role
- Tasks completed: 127
- Approval rate: 71% (↑ from 68%)
- False positive rate: 0.08 (↓ from 0.10)
- Recommendation: Promote to Research Lead, mentor junior-maverick

### ★★★★☆ backtester (Score: 0.82)
**Status:** EXCELLENT
- Tasks completed: 156
- Approval rate: 79% (stable)
- False positive rate: 0.05 (stable)
- Recommendation: Maintain current assignment

### ★★☆☆☆ junior-maverick (Score: 0.35)
**Status:** PROBATION (Month 1 of 3)
- Tasks completed: 8
- Approval rate: 25% (↓ from 25%)
- False positive rate: 0.50 (stable)
- Learning violations: 2
- Recommendation: Temperature reduction (0.9 → 0.8), increase oversight

### ★★★☆☆ external-scout (Score: 0.62)
**Status:** SATISFACTORY
- Tasks completed: 34
- Approval rate: 58% (↑ from 52%)
- False positive rate: 0.18 (↓ from 0.22%)
- Recommendation: Add stricter validation rules, maintain assignment

## System-Level Insights
- L0 approval too lenient: 42% passing (target: 70%) - suggests weak filtering
- L1-L3 approval rates improving: 68% → 75% → 82% (good funnel)
- Bottleneck: junior-maverick high false positive rate impacting L0

## Immediate Actions
1. **junior-maverick**: Reduce temperature to 0.8, add manual override requirement
2. **external-scout**: Add stricter social sentiment validation
3. **orchestrator**: Consider team restructuring - move junior-maverick to validation tier

## Next Review Targets
- Get junior-maverick to 0.50+ score by Review #3
- Maintain L1-L3 approval trend
- Reduce L0 false positives by 20%
```

---

### 4. Dynamic Hiring/Firing

**Hiring Process:**

When a capability gap is detected during retrospectives:

1. **Identify Need** (via retrospective or orchestrator decision)
   - Example: "Need better social sentiment analysis"

2. **Create Agent from Template** (Agent: orchestrator)
   - Select template from `config/agent-templates/`
   - Customize: role, model, tools, description
   - Write to `agents/{new-agent-name}.md`

3. **Onboard** (Agent: feedback)
   - Add to orchestrator delegation list
   - Set initial score to 0.50 (probation)
   - Add learning injection for domain knowledge

4. **Train & Verify** (Agent: critic + orchestrator)
   - Run agent on test strategies first
   - Validate output quality
   - Gradually increase assignment volume

**Firing Process:**

When performance review identifies persistent underperformers:

1. **Archive Agent** (Agent: orchestrator)
   - Move spec to `.crypto/archives/agents/{name}.md`
   - Add archive timestamp and reason
   - Remove from active delegation list

2. **Document Reason** (Agent: feedback)
   - Update agent status file with termination reason
   - Store performance trend data
   - Document lessons learned

3. **Potential Reinstatement**
   - Archived agents can be reinstated if bottleneck detected
   - Example: If L0 approval rate drops to 30%, reinstate junior-maverick

**Agent Templates:**

Location: `config/agent-templates/`

```yaml
# config/agent-templates/researcher-template.md
---
name: trading-{specialist}-researcher
description: "Specialized research agent for {domain}"
model: opus
temperature: 0.5
tools: Read, Write, Bash, WebSearch, WebFetch
---

# {Specialist} Research Agent

## Role & Responsibilities
- Develop research hypotheses in {domain}
- Validate ideas against existing learnings
- Document findings and constraints

## Workflow
1. Input: Problem statement or market signal
2. Process: Research, hypothesis generation, validation
3. Output: structured hypothesis.md + parameters.yaml

## Integration Points
- Receives signals from {upstream_agent}
- Outputs to backtester via strategy repository
- Learning injection: Check latest L-*.yaml in relevant domain

## Performance Metrics
- Approval rate target: 65%
- False positive rate max: 15%
- Learning violation threshold: 3
```

---

### 5. Hook Automation

**Hook Locations:** `hooks/`

**Available Hooks:**

#### PostToolUse:Task
**Trigger:** After any Task tool creates/updates a task

**Action:** Log agent action to performance log

```yaml
# hooks/post-task.yaml
trigger: PostToolUse:Task
condition: task.type == "strategy_processing"
actions:
  - log_agent_action:
      timestamp: $now
      agent: $task.assigned_agent
      action: $task.action_type
      strategy_id: $task.strategy_id
      target: ".crypto/knowledge/agent-performance-log.yaml"
```

#### PreToolUse:Write (Registry % 5)
**Trigger:** Before Write operation when `pipeline_runs % 5 == 0`

**Action:** Trigger retrospective

```yaml
# hooks/pre-retrospective.yaml
trigger: PreToolUse:Write
condition: |
  (registry.pipeline_runs % 5 == 0) &&
  ($write_file contains ".crypto/reports/")
actions:
  - skill: retrospective
    params:
      scope: "last_5_runs"
      generate_report: true
      output: ".crypto/reports/retrospectives/RETRO-{next_id}.md"
```

#### PreToolUse:Write (Registry % 10)
**Trigger:** Before Write operation when `pipeline_runs % 10 == 0`

**Action:** Trigger performance review

```yaml
# hooks/pre-performance-review.yaml
trigger: PreToolUse:Write
condition: |
  (registry.pipeline_runs % 10 == 0) &&
  ($write_file contains ".crypto/reports/")
actions:
  - skill: performance-review
    params:
      scope: "last_10_runs"
      generate_recommendations: true
      evaluate_hiring_firing: true
      output: ".crypto/reports/performance-reviews/REVIEW-{next_id}.md"
  - conditional: score < 0.30
    then:
      - skill: fire-agent
        params:
          reason: "performance_threshold"
```

#### Stop Hook
**Trigger:** Before process stops (session end, cancel)

**Action:** Check for pending HR actions

```yaml
# hooks/pre-stop.yaml
trigger: Stop
actions:
  - check_pending_hr_actions:
      location: ".crypto/state/pending-actions.yaml"
      if_pending:
        - log_warning: "Pending HR actions at session stop"
        - save_context: ".crypto/state/resume-context.yaml"
```

---

### 6. File Structure

```
.crypto/
├── config/
│   ├── agent-performance-schema.yaml      # Performance metrics definition
│   ├── agent-templates/                   # Templates for new agents
│   │   ├── researcher-template.md
│   │   ├── validator-template.md
│   │   └── executor-template.md
│   ├── thresholds.yaml                    # Customizable performance thresholds
│   └── hiring-policy.yaml                 # Rules for auto-hiring

├── knowledge/
│   ├── agent-performance-log.yaml         # Append-only action log
│   ├── strategies/
│   └── learnings/

├── reports/
│   ├── retrospectives/
│   │   ├── RETRO-001.md
│   │   ├── RETRO-002.md
│   │   └── ...
│   ├── performance-reviews/
│   │   ├── REVIEW-001.md
│   │   ├── REVIEW-002.md
│   │   └── ...
│   ├── agent-status.yaml                  # Current status of all agents
│   └── system-health.yaml                 # Pipeline metrics

├── state/
│   ├── pipeline-counter.yaml              # Track runs for retrospectives
│   ├── pending-actions.yaml               # Pending HR decisions
│   └── resume-context.yaml                # Session continuation context

└── archives/
    └── agents/
        ├── {retired-agent-name}.md        # Archived agent specs
        └── agent-reviews/
            └── REVIEW-{NNN}-archive.md
```

---

## Quick Start

### 1. Initialize Workspace

```bash
/crypto:init
```

This creates:
- Initial agent performance schema
- Empty retrospective/review history
- Pipeline counter (set to 0)
- Agent status tracker

### 2. Run Pipeline

```bash
/crypto:pipeline meeting
```

Each run:
- Processes 1-3 strategies through tiers
- Logs agent actions
- Increments pipeline counter
- Auto-triggers retrospective at run 5, 10, 15, ...
- Auto-triggers performance review at run 10, 20, 30, ...

### 3. Monitor Status

```bash
/crypto:status
```

Shows:
- Current agent team composition
- Performance scores
- Probation status
- System health metrics
- Next retrospective/review

### 4. View Reports

```bash
# Latest retrospective
cat .crypto/reports/retrospectives/RETRO-$(ls .crypto/reports/retrospectives | tail -1)

# Latest performance review
cat .crypto/reports/performance-reviews/REVIEW-$(ls .crypto/reports/performance-reviews | tail -1)

# Agent status dashboard
cat .crypto/reports/agent-status.yaml
```

---

## Commands Reference

| Command | Purpose | Frequency |
|---------|---------|-----------|
| `/crypto:init` | Initialize self-managing system | Once (setup) |
| `/crypto:pipeline meeting` | Run strategy pipeline with auto-triggering | Every 1-2 hours |
| `/crypto:retrospective` | Manual retrospective (auto-runs every 5) | Manual override |
| `/crypto:hr-review` | Manual performance review (auto-runs every 10) | Manual override |
| `/crypto:hire [type]` | Hire new agent | When needed |
| `/crypto:fire [agent]` | Fire underperformer (if not auto-terminated) | Manual override |
| `/crypto:status` | View company status dashboard | On-demand |
| `/crypto:performance-log` | View raw agent action log | Debugging |
| `/crypto:promote [agent]` | Promote agent to lead role | When merited |
| `/crypto:team-hierarchy` | View team structure and reporting lines | On-demand |

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)

**Goal:** Build performance tracking infrastructure

- [ ] Create `agent-performance-schema.yaml`
- [ ] Implement performance log (`agent-performance-log.yaml`)
- [ ] Create agent status tracker (`agent-status.yaml`)
- [ ] Build basic `/crypto:status` command
- [ ] Write agent performance docs

**Deliverables:**
- Performance scoring system fully defined
- Initial dashboard showing all agent metrics
- Integration with existing pipeline

**Verification:**
- Run 10 strategies through pipeline
- Verify all agent actions logged
- Verify scores calculated correctly

---

### Phase 2: Automation (Week 2-3)

**Goal:** Implement automated retrospectives and reviews

- [ ] Create retrospective skill
- [ ] Create performance review skill
- [ ] Implement hook-based triggering
- [ ] Build report generation
- [ ] Create recommendation engine

**Deliverables:**
- Retrospective auto-triggers every 5 runs
- Performance review auto-triggers every 10 runs
- Reports identify underperformers
- Recommendations for improvements

**Verification:**
- Run 20 strategies (2 reviews, 4 retrospectives)
- Verify reports generate correctly
- Verify recommendations are actionable

---

### Phase 3: Organization (Week 3-4)

**Goal:** Implement hiring/firing and team hierarchy

- [ ] Create agent templates
- [ ] Implement hiring skill
- [ ] Implement firing skill
- [ ] Create team lead structure
- [ ] Build team hierarchy views

**Deliverables:**
- Can hire new agents from templates
- Can fire underperformers automatically
- Team leads assigned to manage groups
- Hierarchy visible in status dashboard

**Verification:**
- Hire a new agent mid-pipeline
- Fire an underperforming agent
- Verify team structure reorganizes
- Verify new agent integrated smoothly

---

## Team Hierarchy Details

### CEO (Orchestrator)
- **Model:** claude-opus
- **Responsibility:** Overall coordination, delegation, strategy approval
- **Reports:** None (top-level)
- **Manages:** 3 leads (Research, Validation, Execution)

### Research Lead (strategy-researcher or designated agent)
- **Model:** opus
- **Responsibility:** Hypothesis generation, idea validation, learning injection
- **Reports:** Orchestrator
- **Manages:** junior-maverick, junior-datacurious, external-scout, strategy-mutator
- **Performance Target:** 65%+ approval rate

### Validation Lead (backtester or designated agent)
- **Model:** sonnet
- **Responsibility:** Backtest execution, quality gates, risk assessment
- **Reports:** Orchestrator
- **Manages:** quantitative-analyst, critic, backtester
- **Performance Target:** 75%+ approval rate

### Execution Lead (signal-generator or designated agent)
- **Model:** sonnet
- **Responsibility:** Code generation, order execution, monitoring
- **Reports:** Orchestrator
- **Manages:** order-executor, monitor, ml-engineer
- **Performance Target:** 80%+ approval rate

---

## Performance Thresholds (Customizable)

Edit `.crypto/config/thresholds.yaml`:

```yaml
thresholds:
  # Approval rate thresholds
  excellent_approval: 0.75
  good_approval: 0.65
  satisfactory_approval: 0.50
  poor_approval: 0.40

  # False positive rate thresholds
  excellent_false_positive: 0.05
  good_false_positive: 0.10
  satisfactory_false_positive: 0.20
  poor_false_positive: 0.35

  # Composite score thresholds
  active_min_score: 0.50
  probation_max_score: 0.50
  probation_min_score: 0.30
  retired_max_score: 0.30

  # Probation duration
  probation_duration_reviews: 3  # 30 pipeline runs

  # Retrospective triggers
  retrospective_interval: 5  # every 5 runs
  performance_review_interval: 10  # every 10 runs

  # Hiring policy
  auto_hire_when_throughput_drops: true
  auto_hire_bottleneck_threshold: 0.65  # if L0 approval < 65%

  # Firing policy
  auto_fire_below_threshold: true
  fire_after_probation_failures: 2  # 2 consecutive poor reviews in probation
```

---

## FAQ

### Q: How often do retrospectives run?

**A:** Automatically every 5 pipeline runs. You can also run manually with `/crypto:retrospective` at any time.

Retrospectives analyze the last 5 runs and identify patterns:
- Which agent types are most effective?
- Are learnings being applied?
- Where are bottlenecks?
- What improvements needed?

### Q: What happens to fired agents?

**A:** Archived agents are stored in `.crypto/archives/agents/{name}.md` and can be:
- **Reviewed later**: Read their performance history and reasons for termination
- **Reinstated**: If a bottleneck is detected in their domain, bring them back
- **Analyzed**: Study why they failed and what improvements could help

Example: If junior-maverick is fired but L0 approval rate drops to 30%, reinstate with modifications (e.g., lower temperature, stricter validation).

### Q: Can I customize thresholds?

**A:** Yes! Edit `.crypto/config/thresholds.yaml` to adjust:
- Approval rate requirements
- False positive rate limits
- Probation duration
- Retrospective/review frequency
- Auto-hiring/firing policies

**Warning:** Changing thresholds mid-cycle affects ongoing reviews. Recommended to wait until next review boundary.

### Q: How are team leads chosen?

**A:** Leads are designated by the Orchestrator based on:
1. **Highest composite score** in category
2. **Stability** (consistently good, not trending down)
3. **Domain expertise** (experience in the category)

Example: If strategy-researcher has score 0.82 and external-scout has 0.62, strategy-researcher becomes Research Lead.

### Q: What if multiple agents have the same score?

**A:** Tiebreaker order:
1. Approval rate (higher wins)
2. Tasks completed (more experience wins)
3. Time in service (longer tenure wins)

### Q: Can agents be promoted mid-pipeline?

**A:** Yes. Promotion happens when:
- Performance review identifies excellent performer
- Orchestrator promotes to lead role
- Lead role duties assigned alongside peer work
- Monitor closely for capacity (may need to reduce peer assignments)

### Q: How does learning injection work?

**A:** Before each agent task:
1. Read recent learnings (L-*.yaml)
2. Filter to agent's domain
3. Inject as context: "Previous failures in this area..."
4. Agent considers learnings before acting
5. If agent violates known learning → flag as violation

This prevents repeated mistakes.

### Q: What if the system fires all agents?

**A:** Technically possible but unlikely due to:
- Diverse agent pool (agents excel at different tasks)
- Probation buffer (3 reviews before termination)
- Auto-hiring trigger (if approval rate drops too low, auto-hire specialists)

If bottleneck detected, system auto-triggers hiring of new agents from templates.

### Q: Can I see agent performance trends?

**A:** Yes. Compare reports:
- `RETRO-001` vs `RETRO-002` (5-run trends)
- `REVIEW-001` vs `REVIEW-002` (10-run trends)

Or query the append-only log:
```bash
grep "strategy-researcher" .crypto/knowledge/agent-performance-log.yaml | tail -20
```

### Q: What's the impact of hiring/firing on pipeline?

**A:**

**Hiring:**
- New agent starts in probation (score 0.50)
- Assigned lower-risk tasks initially
- Gradually increased responsibility
- Takes ~2 reviews (20 runs) to stabilize

**Firing:**
- Workload redistributed to team
- May reduce throughput temporarily (1-2 runs)
- Usually improves overall quality (removing false positives)
- Frees capacity for new specialists if needed

### Q: How does this compare to static agent teams?

**A:** Key differences:

| Aspect | Static Team | Self-Managing |
|--------|------------|---------------|
| **Performance tracking** | None | Continuous scoring |
| **Underperformers** | Stay indefinitely | Fired after probation |
| **New capabilities** | Manual hiring | Auto-hired on need |
| **Retrospectives** | Optional/manual | Automatic every 5 runs |
| **Improvements** | Slow, ad-hoc | Data-driven cycles |
| **Efficiency** | Degrades over time | Self-correcting |
| **Learning** | Not enforced | Injected proactively |
| **24/7 autonomy** | Limited | Full autonomy |

---

## Integration with Existing Pipeline

The self-managing system **integrates seamlessly** with existing pipeline:

### No Breaking Changes

- All existing agents continue working unchanged
- Performance metrics added (non-disruptive)
- Retrospectives are informational (no forced actions)
- Hiring/firing optional (can be disabled)

### Opt-In Activation

To enable:
1. Run `/crypto:init` to set up performance tracking
2. Run `/crypto:pipeline meeting` as usual
3. Reports auto-generate, review as desired
4. Enable auto-hiring/firing in `.crypto/config/thresholds.yaml`

### Monitoring

Monitor at your own pace:
- After each pipeline run: Check agent performance log
- Every 5 runs: Read retrospective report
- Every 10 runs: Review performance recommendations
- Monthly: Analyze trends and adjust thresholds

---

## Advanced Topics

### Running Multiple Teams in Parallel

If managing 3 concurrent trading strategies:

```bash
# Create isolated state directories
mkdir .crypto/team-1 .crypto/team-2 .crypto/team-3

# Each team has separate:
# - agent-performance-log.yaml
# - agent-status.yaml
# - retrospectives/
# - performance-reviews/

# Run each pipeline independently
/crypto:pipeline meeting --team team-1
/crypto:pipeline meeting --team team-2
/crypto:pipeline meeting --team team-3
```

Each team maintains separate metrics and can have different thresholds.

### Custom Performance Metrics

Add domain-specific metrics to `agent-performance-schema.yaml`:

```yaml
custom_metrics:
  sharpe_ratio_accuracy:
    description: "How accurate agent predictions vs actual backtest results"
    weight: 0.10
    applicable_agents: ["backtester", "quantitative-analyst"]

  learning_extraction_quality:
    description: "Learnings extracted vs total opportunities"
    weight: 0.10
    applicable_agents: ["feedback"]
```

### Integration with External Systems

Hook into performance reviews to trigger external actions:

```yaml
# Example: Alert Slack when agent fired
hooks/on-agent-fired.yaml:
  trigger: "agent_terminated"
  actions:
    - slack:
        channel: "#trading-ops"
        message: "Agent {{agent.name}} terminated. Reason: {{termination_reason}}"
        include_performance_data: true
```

---

## Success Metrics

After implementing self-managing company architecture, expect:

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Pipeline autonomy** | 100% | Zero manual HR decisions |
| **Underperformer detection** | < 1 review | Identify poor performers immediately |
| **Performance stability** | +5% per cycle | Gradual approval rate improvement |
| **Retrospective quality** | Actionable | Implement 80% of recommendations |
| **Learning injection** | 90%+ | Prevent repeated mistakes |
| **System uptime** | 99.9% | 24/7 self-managing operation |
| **Throughput** | +30% | More strategies processed per day |

---

## Troubleshooting

### "All agents on probation"
**Cause:** Thresholds too strict or learning violations excessive

**Solution:**
1. Review retrospective for systemic issues
2. Increase thresholds temporarily (`.crypto/config/thresholds.yaml`)
3. Inject new learnings to guide agents better
4. Check if external data source changed

### "Pipeline throughput degrading"
**Cause:** Too many agents fired, remaining team overloaded

**Solution:**
1. Hire new specialist agents
2. Reduce probation duration
3. Check learning violations - may need domain retraining
4. Review if strategy type changed (need different expertise)

### "Retrospectives not auto-triggering"
**Cause:** Hook not configured or pipeline counter not incrementing

**Solution:**
1. Verify `pipeline-counter.yaml` exists in `.crypto/state/`
2. Check hook files in `hooks/` directory
3. Run `/crypto:retrospective` manually to test
4. Review hook logs for errors

### "Agent keeps violating same learning"
**Cause:** Learning not properly injected or agent ignoring context

**Solution:**
1. Increase learning injection visibility (add to task description)
2. Add explicit validation check before agent action
3. Reduce agent temperature (making it more deterministic)
4. Consider if learning is actually valid for that agent's domain

---

## See Also

- [Agent Specifications](../agents/) - Details on each agent
- [Pipeline Workflow](PIPELINE-WORKFLOW.md) - How strategies flow through tiers
- [Learning Extraction](LEARNING-EXTRACTION.md) - How to extract and apply learnings
- [Market Wisdom](MARKET_WISDOM.md) - Collected trading insights
- [Upgrade Plan](../UPGRADE-PLAN.md) - Future improvements

---

**Last Updated:** February 5, 2025
**Version:** 1.0
**Status:** Production Ready

For questions or improvements, create an issue or submit a PR.
