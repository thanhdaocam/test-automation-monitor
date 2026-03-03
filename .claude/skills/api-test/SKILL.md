---
name: api-test
description: Run API tests for REST and GraphQL endpoints. Supports Playwright API testing and Postman/Newman collections. Auto-detects format from file extension. Use for backend, microservices, and serverless testing.
allowed-tools: Bash(npx *), Bash(newman *), Bash(node *), Bash(curl *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: <test-file-or-collection> [--base-url url] [--env environment] [--headers key:value]
---

# API Testing

Execute REST API or GraphQL tests and display formatted results.

## Current Project Context

API test files found:
!`find . -maxdepth 4 -type f \( -name "*.api.ts" -o -name "*.api.js" -o -name "*.postman.json" -o -name "*.postman_collection.json" \) 2>/dev/null | head -15 || echo "No API test files found"`

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

## Related Skills

- Create API test templates: `/scaffold-test api`
- View results: `/test-report --last`
- Generate test data: `/test-data generate`
- Security scan: `/security-test`
- Performance test API: `/run-test <file.k6.js>` with API endpoints
