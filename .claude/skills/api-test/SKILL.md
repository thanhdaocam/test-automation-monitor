---
name: api-test
version: 2.0.0
description: Chạy kiểm thử API cho endpoint REST và GraphQL. Hỗ trợ Playwright API testing và Postman/Newman collection. Tự phát hiện định dạng từ phần mở rộng tệp. Dùng cho backend, microservices và serverless.
allowed-tools: Bash(npx *), Bash(newman *), Bash(node *), Bash(curl *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: <test-file-or-collection> [--base-url url] [--env environment] [--headers key:value]
---

# Kiểm thử API

Execute REST API or GraphQL tests and display formatted results.

## Current Project Context

Tệp kiểm thử API tìm thấy:
!`node -e "const fs=require('fs');const path=require('path');function walk(d,depth,max){let r=[];if(depth>max)return r;try{for(const f of fs.readdirSync(d)){if(f.startsWith('.'))continue;const p=path.join(d,f);try{const s=fs.statSync(p);if(s.isDirectory()&&f!=='node_modules')r=r.concat(walk(p,depth+1,max));else if(/\.(api\.(ts|js)|postman\.json|postman_collection\.json)$/.test(f))r.push(p)}catch{}}}catch{}return r}const files=walk('.',0,4);console.log(files.length?files.join('\n'):'Không tìm thấy tệp kiểm thử API')"`

API-related config:
!`node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};const api=Object.keys(d).filter(k=>/(playwright|newman|supertest|axios|got)/.test(k));console.log(api.length?'API libs: '+api.join(', '):'No API test libs found')}catch{console.log('No package.json')}" 2>/dev/null`

## Parse Arguments

- `$0` = test file path or Postman collection (required)
- `--base-url <url>` = API base URL (overrides config)
- `--env <name>` = environment name (dev/staging/prod)
- `--headers <key:value>` = extra headers (repeatable)
- `--verbose` = show full request/response bodies

## Steps

### 1. Detect Test Format

**By file extension:**
- `*.api.ts`, `*.api.js` → **Playwright API Testing** (uses `request` context)
- `*.postman.json`, `*.postman_collection.json` → **Newman (Postman CLI)**
- `*.http`, `*.rest` → **REST Client format** (parse and execute with curl)

**By project config:**
```bash
ls -la postman/ 2>/dev/null
ls -la *.postman_collection.json 2>/dev/null
```

If no file specified, search for API test files and ask user to choose.

### 2. Run Playwright API Tests

Build the command:
```bash
npx playwright test $test_file --reporter=json,line
```

If `--base-url` provided, set environment:
```bash
BASE_URL=$base_url npx playwright test $test_file --reporter=json,line
```

**Parse results** and display:

```
API Test Results
══════════════════════════════════════════════════════════════
  ✓ GET /api/users ── returns user list              120ms
  ✓ POST /api/users ── creates new user               89ms
  ✓ GET /api/users/:id ── returns single user          45ms
  ✗ PUT /api/users/:id ── update user                 234ms
    Status: 403 Forbidden (expected 200)
    Response: {"error": "Insufficient permissions"}
    at users.api.ts:42
  ✓ DELETE /api/users/:id ── soft delete               67ms
──────────────────────────────────────────────────────────────
Summary: 4 passed, 1 failed | Duration: 555ms
Avg response time: 111ms
══════════════════════════════════════════════════════════════
```

### 3. Run Newman (Postman) Tests

Build the command:
```bash
newman run $collection_file --reporters cli,json --reporter-json-export test-results/api-results.json
```

If `--env` provided:
```bash
newman run $collection_file -e $env_file --reporters cli,json --reporter-json-export test-results/api-results.json
```

**Parse results** from Newman JSON and display:
- Request name, method, URL
- Status code and response time
- Assertion results (pass/fail)
- Summary: total requests, passed assertions, failed assertions

### 4. Run curl-based Tests (for .http files)

Parse `.http` files and execute each request:
```bash
curl -s -w "\n%{http_code} %{time_total}" -X $METHOD $URL -H "$HEADERS" -d "$BODY"
```

Display results with status codes and response times.

### 5. Post-Run

- If all tests passed: "All API tests passed!"
- If any failed: show failure details with status codes, response bodies
- Note: "Use `/test-report` for detailed analysis"
- Suggest: "Use `--verbose` to see full request/response bodies"

## Error Recovery

- If `newman` not found: "Install Newman: `npm install -g newman` or use Playwright API testing instead."
- If `playwright` not found: "Run `npm install -D @playwright/test` or use `/setup-test-env`."
- If base URL unreachable: suggest checking if the API server is running.
- If authentication error (401/403): suggest checking API keys or auth tokens.
- If CORS error: note that API tests run server-side and should not have CORS issues.
- For GraphQL errors: check query syntax and schema compatibility.

## Lưu ý tương thích đa nền tảng

- Các lệnh `ls ... 2>/dev/null` hoạt động trong Git Bash trên Windows. Trên PowerShell thuần, dùng `Get-ChildItem -ErrorAction SilentlyContinue`.
- Script phân tích kết quả API có sẵn cả hai phiên bản:
  - **macOS/Linux/Git Bash:** `bash scripts/parse-api-results.sh test-results/api-results.json`
  - **Windows (PowerShell):** `powershell -ExecutionPolicy Bypass -File scripts/parse-api-results.ps1 test-results/api-results.json`
- Lệnh `curl` có sẵn trên Windows 10+ và Git Bash. Trên Windows cũ hơn, dùng `Invoke-WebRequest` hoặc cài curl.

## Security Best Practices

> **⚠ CRITICAL: Never hardcode API keys, auth tokens, or credentials in test files or command-line arguments.**

- **Use environment variables** for all API credentials:
  - `API_AUTH_TOKEN`, `API_KEY`, `API_SECRET` — set in `.env` (gitignored), not in test source code
  - `BASE_URL` — use env vars to switch between environments without code changes
- **Never commit `.env` files** or Postman environment files containing real tokens — use `.env.example` as a template.
- **Use short-lived tokens** for testing — generate test-specific API tokens with limited scope and expiration.
- **Mask sensitive data in logs** — when using `--verbose`, be aware that request/response bodies may contain auth tokens. Do not share verbose output in public channels.
- **For CI/CD pipelines**: store API tokens as encrypted pipeline secrets, not in environment files or collection variables committed to the repo.
- **Postman collections**: export collections without environment variables that contain secrets. Use Postman environment files only locally and gitignore them.
- **Rotate API keys** after test runs in shared environments, or use disposable keys scoped to the test session.
- **Headers with secrets**: when using `--headers Authorization:Bearer <token>`, prefer reading the token from an env var: `--headers "Authorization:Bearer $API_AUTH_TOKEN"`.

## Related Skills

- Create API test templates: `/scaffold-test api`
- View results: `/test-report --last`
- Generate test data: `/test-data generate`
- Security scan: `/security-test`
- Performance test API: `/run-test <file.k6.js>` with API endpoints
