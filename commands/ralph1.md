---
description: "Autonomous strategy discovery loop (Phase 1-2)"
argument-hint: "[--max-iterations N] [FOCUS_AREA]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph1.sh:*)"]
---

# Crypto Ralph1 — Autonomous Strategy Discovery

Execute the setup script to initialize the ralph1 loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph1.sh" $ARGUMENTS
```

You are now in an autonomous strategy discovery loop. Each iteration runs the full Phase 1-2 pipeline to find and validate a trading strategy.

## Important

- Read `.crypto/BOOTSTRAP.md` and `.crypto/knowledge/registry.yaml` FIRST to know current state.
- Read `.crypto/knowledge/learnings.md` to avoid repeating past mistakes.
- NEVER propose a strategy that was already rejected (check registry).
- NEVER fabricate backtest results. Run actual quantitative analysis.
- ALWAYS update registry, BOOTSTRAP.md, and learnings.md after each iteration.
- Each iteration = one complete strategy evaluation (validated or rejected).

## Pipeline Per Iteration

1. **Ideation** → hypothesis.md + parameters.yaml
2. **Quant Review** → quant-review.md (reject if not feasible)
3. **Data Check** → data-spec.yaml (reject if unavailable)
4. **Backtest** → BT-{NNN}.yaml with 4 robustness tests
5. **Critic** → critic-review.md (reject/conditional/pass)
6. **Risk** → risk-assessment.yaml (reject if limits exceeded)
7. **Record** → update registry + BOOTSTRAP + learnings

When the stop hook fires, it feeds this prompt back. Your previous work is saved in `.crypto/` files. Pick up where you left off and evaluate the next strategy.
