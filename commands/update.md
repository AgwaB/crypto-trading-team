---
description: "Update crypto plugin to latest version"
---

# Crypto Plugin Update

Update the crypto-trading-team plugin to the latest version.

## Steps

Execute these commands in sequence:

### Step 1: Pull latest from GitHub
```bash
cd ~/.claude/plugins/marketplaces/crypto-trading-team 2>/dev/null && git fetch origin && git pull origin main && echo "✅ Pulled latest from GitHub" || echo "⚠️ Local marketplace not found"
```

### Step 2: Read version and rebuild cache
```bash
SOURCE_DIR="$HOME/.claude/plugins/marketplaces/crypto-trading-team"
VERSION=$(cat "$SOURCE_DIR/.claude-plugin/plugin.json" 2>/dev/null | grep '"version"' | sed 's/.*"\([0-9][^"]*\)".*/\1/' || echo "unknown")
CACHE_DIR="$HOME/.claude/plugins/cache/crypto-trading-team/crypto/$VERSION"

# Create cache directory if needed
mkdir -p "$CACHE_DIR"

# Sync source to cache (preserving cache-specific files like tests, docs)
rsync -av --delete --exclude='.git' --exclude='.git/' "$SOURCE_DIR/" "$CACHE_DIR/"

echo ""
echo "✅ Cache rebuilt: $CACHE_DIR"
echo "   Version: $VERSION"
```

### Step 3: Clean stale state files
```bash
# Remove stale OMC autopilot state (global)
rm -f "$HOME/.omc/state/autopilot-state.json" 2>/dev/null
rm -f "$HOME/.omc/state/ralph-state.json" 2>/dev/null
rm -f "$HOME/.omc/state/ultrawork-state.json" 2>/dev/null
rm -f "$HOME/.omc/state/ecomode-state.json" 2>/dev/null

# Remove stale OMC autopilot state (project-local)
rm -f .omc/state/autopilot-state.json 2>/dev/null
rm -f .omc/state/ralph-state.json 2>/dev/null
rm -f .omc/state/ultrawork-state.json 2>/dev/null
rm -f .omc/state/ecomode-state.json 2>/dev/null

echo "✅ Stale state files cleaned"
```

### Step 4: Show update summary
```bash
echo ""
echo "═══════════════════════════════════════════"
echo " CRYPTO TRADING TEAM — UPDATE COMPLETE"
echo "═══════════════════════════════════════════"
echo ""
SOURCE_DIR="$HOME/.claude/plugins/marketplaces/crypto-trading-team"
VERSION=$(cat "$SOURCE_DIR/.claude-plugin/plugin.json" 2>/dev/null | grep '"version"' | sed 's/.*"\([0-9][^"]*\)".*/\1/' || echo "unknown")
COMMIT=$(cd "$SOURCE_DIR" 2>/dev/null && git log --oneline -1 2>/dev/null || echo "unknown")
echo "  Version: $VERSION"
echo "  Commit:  $COMMIT"
echo ""
echo "  ✅ Changes are live — NO restart needed"
echo ""
echo "═══════════════════════════════════════════"
```

## What This Does

1. **Pulls latest**: Updates from GitHub repo
2. **Rebuilds cache**: rsync copies source → cache immediately
3. **Cleans state**: Removes stale OMC/autopilot state files
4. **No restart needed**: Changes take effect immediately

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Git pull fails | Run `cd ~/.claude/plugins/marketplaces/crypto-trading-team && git status` |
| Cache rebuild fails | Check permissions on `~/.claude/plugins/cache/` |
| Plugin not found | Run `/plugins` → look for "crypto" |
| Hooks still stale | Hooks are loaded at session start — start a new session |
