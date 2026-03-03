---
name: test-report
description: View test results and statistics from the last test run or a specific report file. Shows pass/fail counts, duration, failure details, and trend data. Use after running tests to analyze results.
allowed-tools: Bash(ls *), Bash(cat *), Bash(find *), Bash(wc *), Read, Grep, Glob
user-invocable: true
argument-hint: [--last] [--file path] [--failures-only] [--suite name]
---

# View Test Report

Parse and display test results from Playwright, WebdriverIO, or k6 runs.

## Parse Arguments

- `--last` = show the most recent test results (default if no args)
- `--file <path>` = path to a specific report file (JSON, XML, or HTML)
- `--failures-only` = only show failed tests
- `--suite <name>` = filter by suite/file name

If no arguments provided, behave as `--last`.

## Steps

### 1. Find Report Files

Search for test result files in common locations:

```bash
ls -la test-results/ 2>/dev/null
ls -la playwright-report/ 2>/dev/null
ls -la reports/ 2>/dev/null
ls -la allure-results/ 2>/dev/null
```

Also look for:
```bash
find . -maxdepth 3 -name "*.json" -path "*/test-results/*" -o -name "results.json" -o -name "report.json" 2>/dev/null | head -10
find . -maxdepth 3 -name "junit*.xml" -o -name "test-results*.xml" 2>/dev/null | head -10
```

If `--file` specified, use that directly. If `--last`, use the most recently modified file.

### 2. Detect Format & Parse

**Playwright JSON report** (has `config`, `suites`, `stats` keys):
- Extract: suites → specs → tests → results
- Map status: passed/failed/skipped/timedOut

**WebdriverIO JSON report** (has `start`, `end`, `suites` keys):
- Extract: suites → tests → state (passed/failed)

**k6 JSON output** (has `metrics` key):
- Extract: http_req_duration, http_reqs, checks, iterations

**JUnit XML** (has `<testsuites>` or `<testsuite>` root):
- Extract: tests, failures, errors, time

Read the file and determine format by content inspection.

### 3. Display Results

**For Playwright / WebdriverIO:**

```
Test Report
══════════════════════════════════════════════════════════════
Source:   test-results/results.json
Date:     2026-03-03 14:30:00
Type:     Playwright

Results:
  ✓ auth.spec.ts › should display login form           1.2s
  ✓ auth.spec.ts › should login successfully            2.4s
  ✗ auth.spec.ts › should handle invalid password       1.8s
  ✓ dashboard.spec.ts › should load dashboard           1.5s
  ✓ dashboard.spec.ts › should show user name           0.8s
──────────────────────────────────────────────────────────────

Failures:
  ✗ auth.spec.ts:42 › should handle invalid password
    Error: expect(received).toBe(expected)
    Expected: "Invalid password"
    Received: "Something went wrong"

──────────────────────────────────────────────────────────────
Summary:
  Total:    5 tests
  Passed:   4 (80%)
  Failed:   1 (20%)
  Skipped:  0
  Duration: 7.7s
══════════════════════════════════════════════════════════════
```

**For k6:**

```
Performance Test Report
══════════════════════════════════════════════════════════════
Source:   results/k6-output.json
Script:   load-test.k6.js
Date:     2026-03-03 14:30:00

HTTP Requests:
  Total:        1,500 requests
  Rate:         150 req/s
  Failed:       35 (2.3%)

Response Times:
  Average:      120ms
  Median:       98ms
  p(90):        234ms
  p(95):        345ms
  p(99):        567ms
  Max:          890ms

Checks:
  ✓ status is 200 ................. 97.7% (1465/1500)
  ✓ response time < 500ms ......... 95.2% (1428/1500)
  ✗ response time < 200ms ......... 78.3% (1175/1500)
══════════════════════════════════════════════════════════════
```

### 4. Filter (if flags provided)

- `--failures-only`: only display ✗ entries
- `--suite <name>`: filter to tests matching the suite/file name

### 5. Suggestions

After showing results:
- If failures: "Run `/run-test <file> --debug` to debug the failing test"
- If performance issues: "Consider optimizing endpoints with p(95) > 500ms"
- If no results found: "No test results found. Run `/run-test` or `/mobile-test` first."
