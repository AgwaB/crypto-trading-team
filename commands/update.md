---
description: "Update crypto plugin to latest version"
---

# Crypto Plugin Update

Update the crypto-trading-team plugin to the latest version from GitHub.

## Steps

1. **Clear the plugin cache:**
```bash
rm -rf ~/.claude/plugins/cache/crypto-trading-team/
```

2. **Pull latest from GitHub** (if local marketplace exists):
```bash
cd ~/.claude/plugins/marketplaces/crypto-trading-team && git pull origin main 2>/dev/null || echo "Marketplace will fetch from GitHub on restart"
```

3. **Show current and latest version:**
```bash
echo "=== Update Complete ===" && \
echo "" && \
echo "Local version:" && \
cat ~/.claude/plugins/marketplaces/crypto-trading-team/.claude-plugin/plugin.json 2>/dev/null | grep '"version"' | head -1 || echo "Will be fetched on restart" && \
echo "" && \
echo "Restart Claude Code to apply the update." && \
echo "" && \
echo "After restart, verify with:" && \
echo "  /crypto:status"
```

## What This Does

- Clears cached plugin files so Claude Code fetches fresh version
- Pulls latest code from `AgwaB/crypto-trading-team` GitHub repo
- On next Claude Code restart, the new version loads automatically

## Manual Alternative

If you prefer manual steps:
```bash
# 1. Clear cache
rm -rf ~/.claude/plugins/cache/crypto-trading-team/

# 2. Restart Claude Code

# 3. Verify
/crypto:status
```

## Troubleshooting

If update doesn't apply:
1. Check GitHub repo: https://github.com/AgwaB/crypto-trading-team
2. Ensure plugin is installed: `/plugins` → look for "crypto"
3. Force reinstall: `/plugins` → Remove → Add again
