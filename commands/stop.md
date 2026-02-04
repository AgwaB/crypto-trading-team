---
description: "Stop the running never-end loop gracefully. Use when the user says 'stop', 'crypto stop', or wants to halt the 24/7 autonomous discovery."
argument-hint: "[--force] [--summary]"
---

# Stop Never-End Loop

Gracefully stops the `crypto:never-end` 24/7 autonomous strategy discovery loop.

## Steps

### Step 1: Create Stop Signal

Write the stop signal file to `.crypto/never-end-stop-signal`:

```yaml
requested_at: {current_timestamp}
requested_by: user
reason: "Manual stop requested"
```

### Step 2: Check Session State

Read `.crypto/never-end-state.md` to get session stats:
- Iteration count
- Strategies found (validated)
- Strategies rejected
- Scout runs
- Mutator runs
- Session start time

If the file doesn't exist, output: "No active never-end session found."

### Step 3: Output Summary

```
## Never-End Session Stop Requested

Stop signal created. The loop will terminate at the end of the current iteration.

**Session Stats** (so far):
- Iterations: N
- Strategies Validated: N
- Strategies Rejected: N
- External Scout Runs: N
- Strategy Mutator Runs: N

The session state is preserved. You can resume with `/crypto:never-end` at any time.
```

### Step 4: Handle Flags

If `--force` flag provided:
- Delete `.crypto/never-end-state.md`
- Delete `.crypto/never-end-stop-signal`
- Output: "Session state cleared. Starting fresh next time."

If `--summary` flag provided:
- Also display recent entries from `.crypto/knowledge/registry.yaml`

## Notes

- This is a **graceful** stop - current iteration completes before stopping
- All progress is saved to knowledge files
- The hook (`hooks/never-end-stop.sh`) detects the signal file and terminates
