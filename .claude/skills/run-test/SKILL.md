---
name: run-test
description: Run Playwright web tests or k6 performance tests. Auto-detects the test framework from file extension or package.json. Shows results with pass/fail summary. Use for web browser testing and load testing.
allowed-tools: Bash(npx *), Bash(k6 *), Bash(node *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file-or-pattern] [--headed] [--debug] [--grep pattern] [--workers n]
---

# Run Tests

Execute Playwright web tests or k6 performance tests and display formatted results.

## Current Project Context

Available test scripts in package.json:
!`cat package.json 2>/dev/null | node -e "try{const p=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));console.log(Object.entries(p.scripts||{}).filter(([k])=>k.includes('test')).map(([k,v])=>k+': '+v).join('\n')||'No test scripts found')}catch{console.log('No package.json found')}" 2>/dev/null`

Test files found:
!`find . -maxdepth 4 -type f \( -name "*.spec.ts" -o -name "*.test.ts" -o -name "*.k6.js" -o -name "*.spec.js" -o -name "*.test.js" \) 2>/dev/null | head -15 || echo "No test files found"`

## Parse Arguments

- `$0` = test file, pattern, or directory (optional, runs all if omitted)
- `--headed` = run Playwright in headed mode (show browser)
- `--debug` = run in debug mode
- `--grep <pattern>` = filter tests by name
- `--workers <n>` = number of parallel workers (Playwright)
- All other flags are passed through to the test runner.

## Steps

### 1. Detect Test Framework

Determine which runner to use based on:

**By file extension:**
- `*.spec.ts`, `*.spec.js`, `*.test.ts`, `*.test.js` → **Playwright**
- `*.k6.js`, `*.k6.ts` → **k6**

**By directory:**
- `tests/web/`, `e2e/`, `playwright/` → **Playwright**
- `tests/performance/`, `perf/`, `k6/` → **k6**

**By package.json** (if no file specified):
```bash
cat package.json 2>/dev/null | grep -E "playwright|@playwright/test"
```
If Playwright found, run Playwright. If neither detected, ask the user.

### 2. Run Playwright Tests

Build the command:
```bash
npx playwright test $test_pattern --reporter=json,line
```

Add optional flags:
- If `--headed`: add `--headed`
- If `--debug`: add `--debug`
- If `--grep <pattern>`: add `--grep "<pattern>"`
- If `--workers <n>`: add `--workers <n>`

Execute and capture output. The JSON reporter writes to stdout.

**Parse results** from Playwright JSON output and display:

```
Playwright Test Results
══════════════════════════════════════════════════════════════
  ✓ login.spec.ts › should display login form           1.2s
  ✓ login.spec.ts › should login with valid creds       2.4s
  ✗ login.spec.ts › should show error for invalid pass  1.8s
    Error: expect(received).toBe(expected)
    Expected: "Invalid password"
    Received: "Error occurred"
    at login.spec.ts:42:28
──────────────────────────────────────────────────────────────
Summary: 2 passed, 1 failed, 0 skipped
Duration: 5.4s
══════════════════════════════════════════════════════════════
```

If tests fail, show:
- Error message
- File and line number (clickable format: `file.ts:line`)
- Suggest: "Run with `--debug` flag for step-by-step debugging"

### 3. Run k6 Performance Tests

Build the command:
```bash
k6 run $test_file --out json=/tmp/k6-results.json --summary-trend-stats="avg,min,med,max,p(90),p(95),p(99)"
```

Execute and capture output.

**Parse results** and display:

```
k6 Performance Test Results
══════════════════════════════════════════════════════════════
Script: load-test.k6.js
Status: completed

Metrics:
  http_req_duration .... avg=120ms  min=45ms  med=98ms  max=890ms
                         p(90)=234ms  p(95)=345ms  p(99)=567ms
  http_reqs ........... 1500 (150/s)
  http_req_failed ..... 2.3% (35/1500)

Checks:
  ✓ status is 200 ................ 97.7%
  ✓ response time < 500ms ........ 95.2%
  ✗ response time < 200ms ........ 78.3%

Thresholds:
  ✓ http_req_duration p(95) < 500ms
  ✗ http_req_failed < 1%
──────────────────────────────────────────────────────────────
Result: FAILED (1 threshold breached)
══════════════════════════════════════════════════════════════
```

### 4. Post-Run

- If all tests passed: "All tests passed!"
- If any failed: show failure details + suggest next steps
- Mention: "Use `/test-report` for detailed analysis of results"
- If test result files exist, note their location for later reference

## Error Recovery

- If `npx playwright` not found: "Playwright not installed. Run `npm install -D @playwright/test && npx playwright install` or use `/setup-test-env`."
- If `k6` not found: "k6 not installed. See https://k6.io/docs/get-started/installation/ or run `/setup-test-env`."
- If no test files match the pattern: search the project and suggest matching files.
- If Playwright browser not installed: suggest `npx playwright install chromium`.
- If tests timeout: suggest increasing timeout or checking if the target server is running.
- For mobile/app tests: redirect to `/mobile-test` instead - this skill is for web and performance only.

## Related Skills

- For mobile tests: `/mobile-test <file>`
- View detailed report: `/test-report --last`
- Create sample tests: `/scaffold-test web` or `/scaffold-test performance`
- Status overview: `/monitor`
