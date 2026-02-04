---
description: "Update crypto plugin to latest version"
---

# Crypto Plugin Update

Update the crypto-trading-team plugin to the latest version.

## Steps

Execute these commands in sequence:

### Step 1: Clear plugin cache
```bash
rm -rf ~/.claude/plugins/cache/crypto-trading-team/
echo "✅ Plugin cache cleared"
```

### Step 2: Pull latest from GitHub
```bash
cd ~/.claude/plugins/marketplaces/crypto-trading-team 2>/dev/null && git fetch origin && git pull origin main && echo "✅ Pulled latest from GitHub" || echo "⚠️ Local marketplace not found - will fetch from GitHub on restart"
```

### Step 3: Show version info
```bash
echo ""
echo "═══════════════════════════════════════════"
echo " CRYPTO TRADING TEAM — UPDATE STATUS"
echo "═══════════════════════════════════════════"
echo ""
LOCAL_VERSION=$(cat ~/.claude/plugins/marketplaces/crypto-trading-team/.claude-plugin/plugin.json 2>/dev/null | grep '"version"' | sed 's/.*"version".*"\([^"]*\)".*/\1/' || echo "unknown")
echo "  Version: $LOCAL_VERSION"
echo ""
echo "═══════════════════════════════════════════"
echo ""
echo "🔄 Restart Claude Code to apply the update."
echo ""
echo "After restart, verify with:"
echo "  /crypto:status"
```

## What This Does

1. **Clears cache**: Removes cached plugin files so Claude Code fetches fresh version
2. **Pulls latest**: Updates from `AgwaB/crypto-trading-team` GitHub repo
3. **Shows version**: Displays the installed version

## Changelog

### v0.9.0 (Latest)
- Self-managing company architecture
- 20 agents (3 team leads + 17 specialists)
- Automated retrospectives every 5 pipeline runs
- Performance scoring and dynamic HR

### v0.8.0
- 17 specialized agents
- Organized folder structure
- 24/7 never-end mode

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Update doesn't apply | Restart Claude Code |
| Version unchanged | Check `~/.claude/plugins/cache/` is empty |
| Git pull fails | Run `cd ~/.claude/plugins/marketplaces/crypto-trading-team && git status` |
| Plugin not found | Run `/plugins` → look for "crypto" |

## Manual Update

```bash
# 1. Clear cache
rm -rf ~/.claude/plugins/cache/crypto-trading-team/

# 2. Update marketplace (if local)
cd ~/.claude/plugins/marketplaces/crypto-trading-team && git pull

# 3. Restart Claude Code

# 4. Verify
/crypto:status
```
