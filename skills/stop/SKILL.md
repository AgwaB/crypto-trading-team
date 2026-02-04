---
name: trading-stop
description: "Stop the running never-end loop gracefully. Use when the user says 'stop', 'crypto stop', or wants to halt the 24/7 autonomous discovery."
user-invocable: true
argument-hint: "[--force] [--summary]"
model: haiku
---

# Crypto Trading Stop Command

This skill gracefully stops the `crypto:never-end` 24/7 autonomous strategy discovery loop.

## How It Works

The never-end loop checks for a stop signal file at the start of each iteration. This command creates that signal file and provides a session summary.

## Execution Steps

### Step 1: Create Stop Signal

Write the stop signal file:

```
Write to .crypto/never-end-stop-signal:
---
requested_at: [current timestamp]
requested_by: user
reason: "Manual stop requested"
---
```

### Step 2: Read Session State

Read `.crypto/never-end-state.md` to get:
- Total iterations completed
- Strategies found (validated)
- Strategies rejected
- Scout runs
- Mutator runs
- Session duration

If the file doesn't exist, the loop wasn't running.

### Step 3: Generate Summary

Output a summary to the user:

```
## Never-End Session Stopped

**Session Duration**: [start time] to [now]
**Iterations Completed**: N

### Results
- Strategies Validated: N
- Strategies Rejected: N
- External Scout Runs: N
- Strategy Mutator Runs: N

### Registry Updates
[List any strategies added to registry during this session]

The session state has been preserved. You can resume with `/crypto:never-end` at any time.
```

### Step 4: Cleanup (Optional)

If `--force` flag is provided:
- Delete `.crypto/never-end-state.md`
- Delete `.crypto/never-end-stop-signal`
- Clear any in-progress strategy folders

If `--summary` flag is provided:
- Also read and display `.crypto/knowledge/registry.yaml` changes from this session

## Detection by Never-End Loop

The never-end loop should check at the start of each iteration:

```python
if exists('.crypto/never-end-stop-signal'):
    # Read signal file
    # Output final summary
    # Clean up signal file
    # Exit gracefully
```

## Important Notes

1. This is a **graceful** stop - the current iteration will complete before stopping
2. All progress is saved to the knowledge files
3. The session can be resumed anytime with `/crypto:never-end`
4. Use `--force` only if you want to clear all state and start fresh

## Error Handling

If never-end is not running:
- Check if `.crypto/never-end-state.md` exists
- If not: "No active never-end session found."
- If yes but stale (>1 hour since last update): "Session appears stale. Use --force to clear state."
