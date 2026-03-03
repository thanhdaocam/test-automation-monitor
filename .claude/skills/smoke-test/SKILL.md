---
name: smoke-test
description: Run quick smoke tests to verify critical functionality after deployment. Executes a subset of critical tests across all frameworks. Use for post-deployment health checks and production verification.
allowed-tools: Bash(npx *), Bash(node *), Bash(curl *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [--env staging|production|local] [--url base-url] [--timeout 30s] [--tag @smoke]
---

# Smoke Testing

Run quick critical-path tests to verify a deployment is working.

## Current Project Context

Smoke-tagged tests:
!`grep -rn --include="*.{ts,js}" -l "@smoke\|\.tag.*smoke\|describe.*smoke\|test.*smoke" tests/ test/ e2e/ cypress/ 2>/dev/null | head -10 || echo "No smoke-tagged tests found"`

Test config:
!`node -e "try{const p=require('./package.json');if(p.scripts&&p.scripts['test:smoke'])console.log('Smoke script: '+p.scripts['test:smoke']);else console.log('No smoke test script in package.json')}catch{}" 2>/dev/null`

## Parse Arguments

- `--env <name>` = environment: `local` (default), `staging`, `production`
- `--url <base-url>` = base URL to test against (overrides env)
- `--timeout <duration>` = per-test timeout (default: 30s)
- `--tag <tag>` = test tag to filter (default: `@smoke`)
- `--notify <platform>` = send results to slack/teams/discord after completion

## Steps

### 1. Determine Target Environment

Map environment to base URL:
```
local      → http://localhost:3000 (or from config)
staging    → $STAGING_URL (from env var or ask user)
production → $PRODUCTION_URL (from env var or ask user)
```

If `--url` provided, use that directly.

### 2. Health Check First

Quick HTTP health check before running tests:
```bash
curl -sf --max-time 10 "$BASE_URL/health" || curl -sf --max-time 10 "$BASE_URL" || echo "UNREACHABLE"
```

If unreachable, stop and report immediately.

### 3. Run Smoke Tests

**Strategy: detect and run from available frameworks**

**a) Playwright smoke tests:**
```bash
npx playwright test --grep "@smoke" --timeout=$timeout --reporter=json,line
```

Or if specific smoke config exists:
```bash
npx playwright test --config=playwright.smoke.config.ts --reporter=json,line
```

**b) Cypress smoke tests:**
```bash
npx cypress run --spec "cypress/e2e/smoke/**/*.cy.ts" --reporter json
```

**c) Jest/Vitest smoke tests:**
```bash
npx vitest run --grep "smoke" --reporter=json
```

**d) Custom npm script:**
```bash
npm run test:smoke
```

**e) Fallback: curl-based smoke tests**

If no test framework found, run basic HTTP checks:
```bash
# Check critical endpoints
curl -sf -o /dev/null -w "%{http_code} %{time_total}s" "$BASE_URL/"
curl -sf -o /dev/null -w "%{http_code} %{time_total}s" "$BASE_URL/login"
curl -sf -o /dev/null -w "%{http_code} %{time_total}s" "$BASE_URL/api/health"
```

### 4. Display Results

```
Smoke Test Results
══════════════════════════════════════════════════════════════
Environment: staging
URL:         https://staging.example.com
Time:        2024-03-15 10:30:00 UTC

CRITICAL PATH CHECKS
  ✓ Homepage loads                        0.8s   200
  ✓ Login page accessible                 0.5s   200
  ✓ Login with valid credentials          2.1s   OK
  ✓ Dashboard renders after login         1.2s   OK
  ✓ API /health endpoint                  0.1s   200
  ✗ API /users endpoint                   5.0s   TIMEOUT
    Error: Request timed out after 5000ms

──────────────────────────────────────────────────────────────
Result: DEGRADED (5/6 passed)
Duration: 9.7s
Action: /users endpoint needs investigation
══════════════════════════════════════════════════════════════
```

### 5. Post-Run

- Show pass/fail summary with response times
- Overall verdict: `HEALTHY`, `DEGRADED`, or `DOWN`
- If `--notify` specified, send results via `/notify` skill
- Suggest: "Run full test suite with `/run-test` for detailed coverage"

## Error Recovery

- If no test framework and no test files: run curl-based HTTP checks as fallback
- If target URL unreachable: report immediately without running tests
- If all tests timeout: likely a network issue, check VPN/firewall
- If authentication required: suggest setting up auth tokens in environment variables
- For production: warn that tests should be read-only (no data mutation)

## Related Skills

- Full web test suite: `/run-test`
- Full API test suite: `/api-test`
- Send notification: `/notify`
- Monitor dashboard: `/monitor`
- CI/CD integration: `/ci-gen`
