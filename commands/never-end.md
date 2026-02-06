---
description: "24/7 autonomous strategy discovery with External Scout + Strategy Mutator. Never stops until you say so."
argument-hint: "[--max-iterations N] [--fresh] [FOCUS_AREA]"
---

# Crypto Never-End — 24/7 Autonomous Strategy Discovery

<!-- NEVER-END-SESSION-ACTIVE -->

You are now in a **24/7 autonomous strategy discovery loop**. This loop NEVER stops on its own — it continuously generates new strategy hypotheses using External Scout and Strategy Mutator when the search space seems exhausted.

## Session Initialization

### Step 0: Check for Existing Session

First, check if `.crypto/never-end-state.md` exists.

**If the file exists AND `--fresh` flag is NOT provided:**

1. Read the existing state file and parse the frontmatter:
   - iteration, max_iterations, strategies_found, strategies_rejected
   - scout_runs, mutator_runs, started

2. Display the previous session info:
   ```
   ## Previous Never-End Session Found

   - Started: {started}
   - Iterations completed: {iteration}
   - Strategies: {strategies_found} validated / {strategies_rejected} rejected
   - Scout runs: {scout_runs} | Mutator runs: {mutator_runs}
   ```

3. **ASK the user using AskUserQuestion tool:**
   - Question: "Previous session found. How would you like to proceed?"
   - Options:
     - **Resume**: Continue from iteration {iteration + 1} with existing counters preserved
     - **Reset Counters**: Start from iteration 1 (counters only - all strategies and learnings are preserved)

4. Based on user choice:
   - **Resume**: Keep the existing state file, increment iteration by 1, proceed to Critical Rules
   - **Reset Counters**: Create new state file with fresh counters (see below) - all knowledge files remain intact

**If the file does NOT exist OR `--fresh` flag is provided:**

Create the state file to track this session:

```
Write to .crypto/never-end-state.md:
---
iteration: 1
max_iterations: 0
strategies_found: 0
strategies_rejected: 0
scout_runs: 0
mutator_runs: 0
started: [current timestamp]
---

[Full prompt content will be preserved here by the stop hook]
```

### Step 1: Parse Arguments

Parse arguments from: $ARGUMENTS
- If `--max-iterations N` is present, set max_iterations to N (0 = unlimited)
- If `--fresh` is present, skip the resume prompt and start fresh
- If FOCUS_AREA is provided, focus all agents on that area

## Critical Rules

1. **Read Bootstrap First**: Always start by reading:
   - `.crypto/BOOTSTRAP.md` (current state)
   - `.crypto/knowledge/registry.yaml` (all strategies)
   - `.crypto/knowledge/learnings.md` (past failures)
   - `.crypto/config/tiered-validation-protocol.yaml` (L0-L3 gates)

2. **NEVER Stop on "Exhaustion"**: When you think you've run out of ideas:
   - Run `trading-external-scout` to fetch new ideas from arxiv/twitter/onchain
   - Run `trading-strategy-mutator` to transform existing strategies
   - Only then continue with fresh hypotheses

3. **NEVER Fabricate Results**: Run actual backtests, never make up numbers

4. **ALWAYS Update State**: After each iteration, update registry, BOOTSTRAP.md, and learnings.md

5. **CONTEXT MANAGEMENT (CRITICAL)**: This loop runs for hundreds of iterations. You MUST prevent context overflow:
   - At the END of every iteration, after recording results, type `/compact` to compress the conversation
   - Keep agent result summaries to 2-3 lines max — never paste full agent outputs into context
   - Only retain the iteration summary, not intermediate reasoning
   - If you notice the conversation growing large, compact IMMEDIATELY before starting the next iteration
   - **This is mandatory — failing to compact will crash the session**

## Pipeline Per Iteration

### Phase 0: Pre-Pipeline (Ideation + Screening)

1. **Strategy Meeting** (parallel agents):
   - Spawn `trading-strategy-researcher` (temp 0.5): 2-3 hypotheses based on registry gaps
   - Spawn `trading-junior-maverick` (temp 0.95): 2+ wild ideas from cross-domain analogies
   - Spawn `trading-junior-datacurious` (temp 0.8): anomalies + derived features
   - If FOCUS_AREA provided, all agents focus on that area

2. **Insight Agent** (`trading-insight`):
   - Deduplicate proposals against registry
   - Check search-space-map.yaml for tested archetypes
   - Verdict: DUPLICATE (reject) / SIMILAR (needs twist) / NOVEL (proceed)
   - Select top 1-3 NOVEL ideas

3. **Feedback Agent** (`trading-feedback`):
   - Pre-flight check: match keywords to relevant learnings
   - Generate injection report: CRITICAL / WARNING / INFO
   - BLOCK if unaddressed CRITICAL learnings

4. **Hypothesis Formalization**:
   - Write `.crypto/knowledge/strategies/STR-{NNN}/hypothesis.md` + `parameters.yaml`

### Phase 1: Quant + Data

5. **Quant Review** (`trading-quant-analyst`):
   - Statistical feasibility check
   - If NOT FEASIBLE → reject, try next idea from meeting

6. **Data Check** (`trading-data-collector`):
   - Verify data availability
   - If unavailable → reject, try next idea

### Phase 2: Tiered Validation

7. **L0: Sanity Check** (30 seconds):
   - 6 months, 1 asset, default parameters
   - Gate: signal frequency > 10, hit_rate != 50%, IC > 0.01
   - FAIL → reject immediately, try next idea

8. **L1: Quick Validation** (5 minutes):
   - 1 year, primary asset, default + 2 variants
   - Gate: Sharpe > 0.5, PF > 1.0, trades > 30
   - FAIL → reject, extract learning

9. **L2: Full Backtest** (30 minutes):
   - 3 years, full universe, parameter sweep
   - 4 robustness tests: parameter sensitivity, fee stress, Monte Carlo, regime
   - Gate: `.crypto/config/thresholds.yaml`
   - hard_fail → reject, marginal → Critic

10. **Critic Review** (`trading-critic`):
    - Adversarial review with failure taxonomy
    - REJECT → stop, CONDITIONAL → max 3 revision cycles

11. **L3: Extended Validation** (60 minutes):
    - 5 years, walk-forward (5 windows), Monte Carlo (1000 sims), regime analysis
    - FAIL → reject with detailed analysis

12. **Risk Assessment** (`trading-risk-manager`):
    - Portfolio fit: alpha_corr < 0.7 with existing portfolio
    - Limits exceeded → reject

### Record & Loop

13. **Record Results**:
    - Update `.crypto/knowledge/registry.yaml`
    - Update `.crypto/BOOTSTRAP.md`
    - Extract learnings → `.crypto/knowledge/learnings.md`
    - Update failure-taxonomy.yaml and search-space-map.yaml

14. **Loop Decision**:
    - Strategy VALIDATED: record and continue
    - ALL meeting ideas rejected: run new meeting
    - Some ideas remain: try next idea (skip to step 3)

## 24/7 Expansion Protocol

When the meeting produces no NOVEL ideas (all DUPLICATE or SIMILAR):

### Step A: External Scout
```
Spawn trading-external-scout with prompt:
"Scan external sources for new strategy ideas. Focus on:
1. Recent arxiv papers (quant-ph, stat.ML, q-fin)
2. Crypto Twitter alpha (whale alerts, funding rates)
3. On-chain anomalies (DEX flows, staking patterns)
4. Exchange updates (new listings, fee changes)
Return 3-5 novel hypotheses not in our registry."
```

### Step B: Strategy Mutator
```
Spawn trading-strategy-mutator with prompt:
"Transform existing strategies using mutation operators:
1. Pick 2 VALIDATED strategies from registry
2. Pick 2 REJECTED strategies with interesting signals
3. Apply mutations: parameter shift, asset swap, timeframe shift,
   logic inversion, hybrid combination, regime specialization
Return 3-5 mutated hypotheses."
```

### Step C: Continue
- Feed Scout + Mutator outputs to Insight Agent
- Proceed with any NOVEL hypotheses
- If still no NOVEL → wait 1 hour, then retry Scout

## End of Iteration Report

```
Iteration N complete.
Strategy: STR-{NNN} {name}
Result: VALIDATED / REJECTED (tier: L0/L1/L2/L3/Critic/Risk, reason)
Meeting ideas used: X/Y (remaining: Z)
Learning: {one-line takeaway}
Running total: {validated}/{rejected}/{total}
Scout runs: {count} | Mutator runs: {count}
```

## Manual Stop

To stop this loop, the user must explicitly type "stop" or `/crypto:stop` or press Ctrl+C. Do NOT stop on your own — keep running indefinitely.

### Stop Signal Detection

At the START of each iteration, check for stop signal:

```
if exists('.crypto/never-end-stop-signal'):
    1. Read signal file for reason
    2. Read .crypto/never-end-state.md for session stats
    3. Output final summary:
       - Session duration
       - Iterations completed
       - Strategies validated/rejected
       - Scout/Mutator run counts
    4. Delete .crypto/never-end-stop-signal
    5. Output: "Never-end session stopped gracefully."
    6. EXIT (do not continue loop)
```

The `/crypto:stop` command creates this signal file.

When YOU determine there are truly no more viable strategies (all data exhausted, all approaches tested, search space fully covered), output `<never-end-complete>` and the loop will cleanly terminate with a summary. But this should be VERY rare — External Scout and Mutator should always find new angles.
