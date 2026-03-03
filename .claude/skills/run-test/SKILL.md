---
name: run-test
description: Run Playwright web tests or k6 performance tests. Auto-detects the test framework from file extension or package.json. Shows results with pass/fail summary. Use for web browser testing and load testing.
allowed-tools: Bash(npx *), Bash(k6 *), Bash(node *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file-or-pattern] [--headed] [--debug] [--grep pattern] [--workers n]
---

# Run Tests

Execute Playwright web tests or k6 performance tests and display formatted results.

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
