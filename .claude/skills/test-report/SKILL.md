---
name: test-report
version: 1.0.0
description: Xem kết quả kiểm thử và thống kê từ lần chạy gần nhất hoặc tệp báo cáo cụ thể. Hiển thị số đạt/lỗi, thời gian, chi tiết lỗi và dữ liệu xu hướng. Dùng sau khi chạy kiểm thử để phân tích kết quả.
allowed-tools: Bash(ls *), Bash(cat *), Bash(node *), Bash(wc *), Read, Grep, Glob
user-invocable: true
argument-hint: [--last] [--file path] [--failures-only] [--suite name]
---

# Xem báo cáo kiểm thử

Parse and display test results from Playwright, WebdriverIO, or k6 runs.

## Tệp kết quả hiện có

!`node -e "const fs=require('fs');const path=require('path');const dirs=['test-results','playwright-report','reports'];for(const d of dirs){try{const files=fs.readdirSync(d).map(f=>({name:f,time:fs.statSync(path.join(d,f)).mtime})).sort((a,b)=>b.time-a.time).slice(0,10);if(files.length)files.forEach(f=>console.log(d+'/'+f.name+' '+f.time.toLocaleString()))}catch{}}if(!dirs.some(d=>{try{return fs.readdirSync(d).length>0}catch{return false}}))console.log('Không tìm thấy thư mục kết quả kiểm thử')"`

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

Also look for (tương thích đa nền tảng — dùng Node.js thay `find`):
```bash
node -e "const fs=require('fs');const path=require('path');function walk(dir,depth){if(depth>3)return[];let results=[];try{for(const f of fs.readdirSync(dir)){const fp=path.join(dir,f);const stat=fs.statSync(fp);if(stat.isDirectory()&&!f.startsWith('.'))results=results.concat(walk(fp,depth+1));else if(/results\.json$|report\.json$|junit.*\.xml$|test-results.*\.xml$/.test(f))results.push(fp)}}catch{}return results}const files=walk('.',0).slice(0,10);console.log(files.length?files.join('\\n'):'Không tìm thấy tệp kết quả')"
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

## Lưu ý tương thích đa nền tảng

- Các lệnh `ls -la ... 2>/dev/null` hoạt động trong Git Bash trên Windows. Trên PowerShell thuần, dùng `Get-ChildItem ... -ErrorAction SilentlyContinue` thay thế.
- Các script parse kết quả có sẵn cả phiên bản `.sh` (bash) và `.ps1` (PowerShell):
  - `scripts/parse-playwright-results.sh` / `scripts/parse-playwright-results.ps1`
  - `scripts/parse-k6-results.sh` / `scripts/parse-k6-results.ps1`
  - `scripts/parse-wdio-results.sh` / `scripts/parse-wdio-results.ps1`
  - `scripts/parse-cypress-results.sh` / `scripts/parse-cypress-results.ps1`
  - `scripts/parse-jest-results.sh` / `scripts/parse-jest-results.ps1`
  - `scripts/parse-api-results.sh` / `scripts/parse-api-results.ps1`
- Trên Windows PowerShell: `powershell -ExecutionPolicy Bypass -File scripts/parse-<type>-results.ps1 <results.json>`

## Error Recovery

- If no result files found anywhere: suggest running tests first with `/run-test` or `/mobile-test`.
- If JSON parse fails: try reading as plain text and extract what we can.
- If file path given but doesn't exist: search for similar files and suggest alternatives.
- If results directory is very large: only parse the most recent file.

## Related Skills

- Run web tests: `/run-test <file>`
- Run mobile tests: `/mobile-test <file>`
- Quick overview: `/monitor`
- Create tests: `/scaffold-test`
