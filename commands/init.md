---
description: Initialize crypto trading workspace in current directory
---

# Initialize Trading Workspace

Set up `.crypto/` directory with all required files for the enhanced trading team (12 agents).

## Steps

1. Check if `.crypto/BOOTSTRAP.md` exists. If yes, inform user "Already initialized" and stop.

2. Create directories:
   - `.crypto/knowledge/strategies/`
   - `.crypto/knowledge/decisions/`
   - `.crypto/knowledge/data-catalog/datasets/`
   - `.crypto/knowledge/weekly-insights/`
   - `.crypto/pipeline/`
   - `.crypto/config/`
   - `.crypto/config/agents/`
   - `.crypto/scripts/`
   - `.crypto/data/`

3. Create all template files as specified in `skills/init/SKILL.md`:
   - `.crypto/BOOTSTRAP.md` (session entry point)
   - `.crypto/knowledge/registry.yaml`
   - `.crypto/knowledge/session-log.yaml`
   - `.crypto/knowledge/learnings.md`
   - `.crypto/knowledge/risk-parameters.yaml`
   - `.crypto/knowledge/search-space-map.yaml`
   - `.crypto/knowledge/failure-taxonomy.yaml`
   - `.crypto/knowledge/learning-violations.yaml`
   - `.crypto/knowledge/data-catalog/sources.yaml`
   - `.crypto/config/thresholds.yaml`
   - `.crypto/config/portfolio-thresholds.yaml`
   - `.crypto/config/tiered-validation-protocol.yaml`
   - `.crypto/config/self-diagnostic-catalog.yaml`
   - `.crypto/config/strategy-meeting-protocol.yaml`
   - `.crypto/pipeline/current-run.yaml`

4. Output confirmation:
```
Trading team workspace initialized.

Created:
- .crypto/BOOTSTRAP.md (session entry point)
- .crypto/knowledge/ (registry, learnings, risk params, search-space, failure taxonomy)
- .crypto/config/ (thresholds, portfolio-thresholds, tiered-validation, self-diagnostics, meeting protocol)
- .crypto/pipeline/current-run.yaml (pipeline state)

Team: 12 agents (Orchestrator, Insight, Feedback, Researcher, Maverick, DataCurious, Quant, Data, Backtester, Critic, Risk, ML Engineer)
Pipeline: Insight -> Feedback -> L0 -> L1 -> L2 -> Critic -> L3 -> Risk -> [HUMAN]

Next: /crypto:pipeline to start developing strategies.
Next: /crypto:meeting to run a strategy brainstorming session.
```

Replace `{current_date}` with actual ISO date.
