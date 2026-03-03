---
name: notify
description: Send test results as notifications to Slack, Microsoft Teams, Discord, or Email. Configure webhook URLs and send pass/fail summaries after test runs.
allowed-tools: Bash(curl *), Bash(node *), Bash(npx *), Bash(cat *), Bash(ls *), Read, Write, Grep, Glob
user-invocable: true
argument-hint: <slack|teams|discord|email> [--webhook-url url] [--results-file path] [--channel name]
disable-model-invocation: true
---

# Test Result Notifications

Send test results to team communication channels.

## Current Project Context

Notification config:
!`cat notification-config.json 2>/dev/null || echo "No notification config found. Run /notify with --webhook-url to configure."`

Latest test results:
!`ls -t test-results/*.json 2>/dev/null | head -3 || echo "No test results found"`

## Parse Arguments

- `$0` = platform: `slack`, `teams`, `discord`, `email` (required)
- `--webhook-url <url>` = webhook URL (saves to config for reuse)
- `--results-file <path>` = specific results file (default: latest in test-results/)
- `--channel <name>` = channel/room name (for display purposes)
- `--save-config` = save webhook URL to notification-config.json
- `--on-fail-only` = only notify if tests failed

## Steps

### 1. Load Configuration

Check for saved config:
```bash
cat notification-config.json 2>/dev/null
```

If `--webhook-url` provided, optionally save to config:
```json
{
  "slack": { "webhookUrl": "https://hooks.slack.com/..." },
  "teams": { "webhookUrl": "https://outlook.office.com/..." },
  "discord": { "webhookUrl": "https://discord.com/api/webhooks/..." },
  "email": { "smtp": "smtp://...", "to": "team@example.com" }
}
```

### 2. Parse Test Results

Find and parse the latest test result file:
```bash
ls -t test-results/*.json | head -1
```

Extract summary: total tests, passed, failed, skipped, duration, suite name.

### 3. Send to Slack

```bash
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "blocks": [
      {
        "type": "header",
        "text": { "type": "plain_text", "text": "Test Results: SUITE_NAME" }
      },
      {
        "type": "section",
        "fields": [
          { "type": "mrkdwn", "text": "*Status:* PASSED/FAILED" },
          { "type": "mrkdwn", "text": "*Tests:* X passed, Y failed" },
          { "type": "mrkdwn", "text": "*Duration:* Xs" },
          { "type": "mrkdwn", "text": "*Time:* TIMESTAMP" }
        ]
      }
    ]
  }'
```

### 4. Send to Microsoft Teams

```bash
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "@type": "MessageCard",
    "summary": "Test Results",
    "themeColor": "00FF00 or FF0000",
    "title": "Test Results: SUITE_NAME",
    "sections": [{
      "facts": [
        { "name": "Status", "value": "PASSED/FAILED" },
        { "name": "Tests", "value": "X passed, Y failed" },
        { "name": "Duration", "value": "Xs" }
      ]
    }]
  }'
```

### 5. Send to Discord

```bash
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "embeds": [{
      "title": "Test Results: SUITE_NAME",
      "color": 65280 or 16711680,
      "fields": [
        { "name": "Status", "value": "PASSED/FAILED", "inline": true },
        { "name": "Tests", "value": "X/Y passed", "inline": true },
        { "name": "Duration", "value": "Xs", "inline": true }
      ],
      "timestamp": "ISO_TIMESTAMP"
    }]
  }'
```

### 6. Send Email (via Node.js)

```bash
node -e "
const nodemailer = require('nodemailer');
// Build and send email with results summary
"
```

### 7. Display Confirmation

```
Notification Sent
══════════════════════════════════════════════════════════════
Platform:  Slack (#testing-results)
Status:    ✓ Delivered
Content:   Test Results: smoke-tests
           12 passed, 0 failed | Duration: 45s
══════════════════════════════════════════════════════════════
```

## Error Recovery

- If webhook URL not configured: ask user to provide `--webhook-url`
- If webhook returns error: show HTTP status and response body
- If no test results found: suggest running tests first with `/run-test`
- If nodemailer not installed (email): suggest `npm install nodemailer`
- For rate limiting: suggest reducing notification frequency

## Related Skills

- Run tests first: `/run-test`, `/unit-test`, `/api-test`
- View results: `/test-report --last`
- Generate CI/CD with notifications: `/ci-gen github`
- Status overview: `/monitor`
