---
name: run-test
version: 1.0.0
description: Chạy kiểm thử Playwright web hoặc kiểm thử hiệu năng k6. Tự phát hiện framework kiểm thử từ phần mở rộng tệp hoặc package.json. Hiển thị kết quả đạt/lỗi. Dùng cho kiểm thử trình duyệt web và kiểm thử tải.
allowed-tools: Bash(npx *), Bash(k6 *), Bash(node *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file-or-pattern] [--headed] [--debug] [--grep pattern] [--workers n]
---

# Chạy kiểm thử

Thực thi kiểm thử Playwright web hoặc kiểm thử hiệu năng k6 và hiển thị kết quả có định dạng.

## Ngữ cảnh dự án hiện tại

Script kiểm thử trong package.json:
!`node -e "try{const p=require('./package.json');const s=Object.entries(p.scripts||{}).filter(([k])=>k.includes('test'));console.log(s.length?s.map(([k,v])=>k+': '+v).join('\n'):'Không tìm thấy script kiểm thử')}catch{console.log('Không tìm thấy package.json')}"`

Tệp kiểm thử tìm thấy:
!`node -e "const fs=require('fs');const path=require('path');function walk(d,depth,max){let r=[];if(depth>max)return r;try{for(const f of fs.readdirSync(d)){if(f.startsWith('.'))continue;const p=path.join(d,f);try{const s=fs.statSync(p);if(s.isDirectory()&&f!=='node_modules')r=r.concat(walk(p,depth+1,max));else if(/\.(spec|test)\.(ts|js)$/.test(f)||/\.k6\.js$/.test(f))r.push(p)}catch{}}}catch{}return r}const files=walk('.',0,4);console.log(files.length?files.join('\n'):'Không tìm thấy tệp kiểm thử')"`

## Phân tích tham số

- `$0` = tệp kiểm thử, mẫu, hoặc thư mục (tùy chọn, chạy tất cả nếu bỏ qua)
- `--headed` = chạy Playwright ở chế độ có giao diện (hiển thị trình duyệt)
- `--debug` = chạy ở chế độ gỡ lỗi
- `--grep <pattern>` = lọc kiểm thử theo tên
- `--workers <n>` = số worker song song (Playwright)
- Các cờ khác được truyền trực tiếp đến trình chạy kiểm thử.

## Các bước

### 1. Phát hiện framework kiểm thử

Determine which runner to use based on:

**By file extension:**
- `*.spec.ts`, `*.spec.js`, `*.test.ts`, `*.test.js` → **Playwright**
- `*.k6.js`, `*.k6.ts` → **k6**

**By directory:**
- `tests/web/`, `e2e/`, `playwright/` → **Playwright**
- `tests/performance/`, `perf/`, `k6/` → **k6**

**By package.json** (if no file specified):
```bash
node -e "try{const p=JSON.parse(require('fs').readFileSync('package.json','utf8'));if(JSON.stringify(p).includes('playwright'))console.log('Playwright detected');else console.log('Not found')}catch{console.log('No package.json')}"
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

Build the command (sử dụng đường dẫn tạm tương thích đa nền tảng):

**Trên mọi nền tảng (dùng Node.js để xác định thư mục tạm):**
```bash
node -e "console.log(require('path').join(require('os').tmpdir(),'k6-results.json'))"
```
Sau đó chạy k6 với đường dẫn đầu ra tương ứng:
```bash
k6 run $test_file --out json=<TEMP_PATH>/k6-results.json --summary-trend-stats="avg,min,med,max,p(90),p(95),p(99)"
```

Ví dụ:
- **Windows:** `k6 run script.k6.js --out json=%TEMP%\k6-results.json`
- **macOS/Linux:** `k6 run script.k6.js --out json=/tmp/k6-results.json`

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
