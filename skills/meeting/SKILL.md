---
name: trading-meeting
description: "Run a strategy brainstorming meeting with senior researcher + junior creative agents. Use when the user says 'strategy meeting', 'brainstorm', 'new ideas', or wants continuous strategy discovery."
user-invocable: true
argument-hint: "[theme or 'continuous']"
model: opus
---

# Strategy Brainstorming Meeting

Run a structured strategy meeting with cognitively diverse participants to generate novel hypotheses.

## Meeting Setup

1. **Read context**:
   - `.crypto/BOOTSTRAP.md` (current state)
   - `.crypto/knowledge/registry.yaml` (what's been tried)
   - `.crypto/knowledge/search-space-map.yaml` (tested vs untested)
   - `.crypto/knowledge/failure-taxonomy.yaml` (common failures)
   - `.crypto/config/strategy-meeting-protocol.yaml` (meeting rules)

2. **Set theme** (optional):
   - If user provided a theme: use it (e.g., "altcoin strategies", "volatility plays")
   - If 'continuous': run in loop mode
   - If neither: open brainstorming

## Phase 1: DIVERGE

Spawn 3 agents in parallel:

1. **Senior Strategist** (`trading-strategy-researcher`):
   - Prompt: "Given our registry of {N} strategies and search space map, propose 2-3 novel strategy hypotheses. Focus on untested areas. Theme: {theme}"

2. **Junior Maverick** (`trading-junior-maverick`):
   - Prompt: "We're brainstorming crypto trading strategies. Theme: {theme}. Propose your wildest ideas. Check search-space-map.yaml to avoid tested areas, but don't let that limit you."

3. **Junior DataCurious** (`trading-junior-datacurious`):
   - Prompt: "We're looking for new trading signals. Theme: {theme}. What anomalies or patterns would you investigate? What derived features would you create?"

Collect all proposals.

## Phase 2: COLLECT

Merge all proposals into a single list:
- Remove exact duplicates
- Combine similar ideas (note original proposer)
- Tag each with: archetype, signal source, timeframe, novelty estimate

## Phase 3: FILTER

Delegate to `trading-insight`:
- Prompt: "Check these {N} proposals against registry and learnings. For each, verdict: NOVEL / SIMILAR_WITH_TWIST / DUPLICATE. Include novelty score 0-10."

Auto-reject any DUPLICATE proposals.

## Phase 4: SELECT

Rank remaining proposals by: novelty_score * feasibility_estimate
Select top 3 for L0 validation.

For each selected proposal:
- Create `.crypto/knowledge/strategies/STR-{NNN}/hypothesis.md`
- Queue for L0 in `.crypto/pipeline/current-run.yaml`
- Note which agent proposed it (for performance tracking)

## Phase 5: LEARN

Record meeting results:
```yaml
meeting_log:
  date: {date}
  theme: {theme}
  proposals_total: N
  proposals_novel: N
  proposals_duplicate: N
  selected_for_l0: [STR-XXX, STR-YYY, STR-ZZZ]
  agent_stats:
    senior_strategist: { proposed: N, selected: N }
    junior_maverick: { proposed: N, selected: N }
    junior_datacurious: { proposed: N, selected: N }
    insight_twists: { proposed: N, selected: N }
```

## Continuous Mode

If argument is 'continuous':
1. Run meeting
2. Send selected hypotheses through L0
3. Report L0 results
4. Run next meeting (incorporating L0 results as context)
5. Repeat until user stops or anti-stagnation triggers

### Anti-Stagnation
After 5 meetings with 0 L0 survivors:
- Rotate junior agent prompts (add new domain analogies)
- Change theme constraint
- Request new data source investigation

## Output

After each meeting, present:
```
STRATEGY MEETING RESULTS
========================
Theme: {theme}
Proposals: {total} ({novel} novel, {duplicate} rejected as duplicate)

Selected for L0 validation:
1. STR-XXX: {name} (proposed by: {agent}, novelty: X/10)
2. STR-YYY: {name} (proposed by: {agent}, novelty: X/10)
3. STR-ZZZ: {name} (proposed by: {agent}, novelty: X/10)

Proceed with L0 validation? [auto-proceed in continuous mode]
```
