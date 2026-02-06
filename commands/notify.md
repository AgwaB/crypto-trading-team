---
description: "Send notification to Telegram (meeting results, HR actions, risk alerts)"
argument-hint: "[message]"
---

# Telegram Notification

Send a notification message to the configured Telegram chat.

## Prerequisites

Telegram notifications are **optional**. To enable:

1. Create a bot via [@BotFather](https://t.me/BotFather) on Telegram:
   - Send `/newbot` to @BotFather
   - Follow the prompts to create your bot
   - Copy the bot token (looks like `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)

2. Get your chat ID:
   - Message [@userinfobot](https://t.me/userinfobot) on Telegram
   - It will reply with your user ID

3. Configure credentials (choose one):

   **Option A: Project-level** (recommended for per-project configs)
   ```bash
   # In your trading project root
   cp .crypto/.env.example .crypto/.env
   # Edit .crypto/.env with your bot token and chat ID
   ```

   **Option B: Plugin-level** (global default)
   ```bash
   # Edit the plugin's .env file
   vim ~/.claude/plugins/marketplaces/crypto-trading-team/.env
   # Set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID
   ```

## Usage

This command is called automatically by other skills, but you can also use it manually:

```
/crypto:notify "Pipeline STR-089 completed: L3 passed, Sharpe 1.82"
```

## How It Works

1. **Run notification script**: Executes `.crypto/scripts/send_telegram.sh` with the message
2. **Script reads credentials**: From `.crypto/.env` (project) → plugin `.env` (fallback) → environment variables
3. **Send via Bot API**: Uses curl to POST to `https://api.telegram.org/bot{TOKEN}/sendMessage`
4. **Silent skip if not configured**: If credentials are empty, the script exits silently without error

## Notification Protocol

When sending notifications from skills:

1. Format message with context:
   ```
   📊 **Crypto Trading Team**
   ━━━━━━━━━━━━━━━━━━━━━━
   {event_type}: {summary}

   {details}

   🕐 {timestamp}
   ```

2. Run the notification script:
   ```bash
   .crypto/scripts/send_telegram.sh "formatted_message"
   ```

3. Script handles everything:
   - Loads credentials from appropriate .env file
   - Silently skips if not configured
   - Sends via curl to Telegram Bot API
   - Never blocks or errors on failure

## Event Types & Formats

### Pipeline Complete
```
📊 **Pipeline Result**
━━━━━━━━━━━━━━━━━━━━━━
Strategy: STR-089 (BTC Momentum Breakout)
Result: ✅ VALIDATED
Tiers Passed: L0 → L1 → L2 → L3
Key Metrics:
  • Sharpe: 1.82
  • Profit Factor: 2.1
  • Win Rate: 58%
  • Max Drawdown: 6.2%
🕐 2026-02-06 14:30 UTC
```

### Pipeline Rejected
```
📊 **Pipeline Result**
━━━━━━━━━━━━━━━━━━━━━━
Strategy: STR-090 (ETH Mean Reversion)
Result: ❌ REJECTED at L2
Reason: Sharpe 0.38 < threshold 0.5
🕐 2026-02-06 15:45 UTC
```

### Meeting Result
```
🤝 **Strategy Meeting**
━━━━━━━━━━━━━━━━━━━━━━
Ideas Proposed: 8
L0 Passed: 3
Rejected (Duplicate): 2
Rejected (Infeasible): 3

Top Ideas:
1. BTC Volatility Clustering (researcher)
2. ETH Gas Fee Arbitrage (junior-datacurious)
3. Cross-Exchange Spread (external-scout)
🕐 2026-02-06 10:00 UTC
```

### Retrospective
```
📋 **Team Retrospective - Cycle 5**
━━━━━━━━━━━━━━━━━━━━━━
Strategies Analyzed: 12
Approved: 7 (58%)
Rejected: 5

Top Performer: signal-generator (0.82)
Needs Attention: junior-maverick (0.31)

Key Finding: L1 rejection rate too high (40%)
Action: Improve pre-screening in meetings
🕐 2026-02-06 12:00 UTC
```

### HR Action - Hire
```
👤 **New Hire**
━━━━━━━━━━━━━━━━━━━━━━
Agent: trading-options-analyst
Role: Specialist
Team: Research (under Research Lead)
Model: sonnet
Status: Probation (5 strategies)
Reason: Options data analysis capability needed
🕐 2026-02-06 09:00 UTC
```

### HR Action - Fire
```
🚪 **Agent Terminated**
━━━━━━━━━━━━━━━━━━━━━━
Agent: trading-junior-example
Last Team: Research
Reason: Score 0.22 for 3 consecutive cycles
Performance History:
  • Cycle 3: 0.28
  • Cycle 4: 0.25
  • Cycle 5: 0.22
Replacement: Under consideration
🕐 2026-02-06 16:00 UTC
```

### Risk Alert
```
🚨 **Risk Alert**
━━━━━━━━━━━━━━━━━━━━━━
Type: Portfolio Drawdown Warning
Current Drawdown: 8.5%
Threshold: 10%
Action: Monitor closely
Circuit Breaker: STANDBY

Active Strategies:
  • STR-085: -2.1%
  • STR-087: -4.3%
  • STR-088: -2.1%
🕐 2026-02-06 11:30 UTC
```

## Integration Notes

- Notifications are **fire-and-forget**: failure to send does NOT block pipeline
- The script checks for `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` in .env files
- If credentials are not set, notification step is silently skipped
- No MCP server required - uses standard Telegram Bot API via curl
