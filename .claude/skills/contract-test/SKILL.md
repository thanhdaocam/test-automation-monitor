---
name: contract-test
version: 2.0.0
description: Chạy kiểm thử hợp đồng API bằng Pact theo mô hình consumer-driven. Xác minh nhà cung cấp và người tiêu dùng API đồng ý về định dạng request/response. Dùng cho microservices và dự án API-first.
allowed-tools: Bash(npx *), Bash(node *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file] [--provider] [--consumer] [--publish] [--broker-url url]
---

# Kiểm thử hợp đồng (Contract Testing)

Run consumer-driven contract tests using Pact to ensure API compatibility between services.

## Current Project Context

Tệp kiểm thử contract:
!`node -e "const fs=require('fs');const path=require('path');function walk(d,depth,max){let r=[];if(depth>max)return r;try{for(const f of fs.readdirSync(d)){if(f.startsWith('.'))continue;const p=path.join(d,f);try{const s=fs.statSync(p);if(s.isDirectory()&&f!=='node_modules')r=r.concat(walk(p,depth+1,max));else if(/\.(pact|contract)\.(ts|js)$/.test(f))r.push(p)}catch{}}}catch{}return r}const files=walk('.',0,4);console.log(files.length?files.join('\n'):'Không tìm thấy tệp kiểm thử contract')"`

Tệp Pact (contract hiện có):
!`node -e "const fs=require('fs');const path=require('path');function walk(d,depth,max){let r=[];if(depth>max)return r;try{for(const f of fs.readdirSync(d)){if(f.startsWith('.'))continue;const p=path.join(d,f);try{const s=fs.statSync(p);if(s.isDirectory()&&f!=='node_modules')r=r.concat(walk(p,depth+1,max));else if(f.endsWith('.json')&&p.includes('pacts'))r.push(p)}catch{}}}catch{}return r}const files=walk('.',0,4);console.log(files.length?files.join('\n'):'Không tìm thấy tệp pact')"`

Pact installation:
!`node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};if(d['@pact-foundation/pact'])console.log('Pact: '+d['@pact-foundation/pact']);else console.log('Pact: not installed')}catch{}" 2>/dev/null`

## Parse Arguments

- `$0` = test file or pattern (optional, runs all contract tests if omitted)
- `--provider` = run provider verification tests
- `--consumer` = run consumer contract tests (default)
- `--publish` = publish pacts to Pact Broker
- `--broker-url <url>` = Pact Broker URL
- `--provider-url <url>` = Provider base URL for verification

## Steps

### 1. Detect Contract Test Type

- If `--provider` → run provider verification
- If `--consumer` or default → run consumer contract generation
- Auto-detect from file content if neither specified

### 2. Run Consumer Contract Tests

Consumer tests generate pact files (JSON contracts):

```bash
npx jest $test_file --json --outputFile=test-results/contract-results.json
# or
npx vitest run $test_file --reporter=json --outputFile=test-results/contract-results.json
```

This creates pact files in `pacts/` directory.

### 3. Run Provider Verification

Verify that the provider API matches the contract:

```bash
npx jest $test_file --json --outputFile=test-results/provider-verification.json
```

Or using Pact CLI:
```bash
npx pact-provider-verifier --provider-base-url=$provider_url --pact-urls=pacts/*.json
```

### 4. Publish Pacts (Optional)

If `--publish` and `--broker-url`:
```bash
npx pact-broker publish pacts/ --broker-base-url=$broker_url --consumer-app-version=$(node -e "console.log(require('./package.json').version)") --tag=$(git rev-parse --abbrev-ref HEAD)
```

### 5. Display Results

```
Contract Test Results
══════════════════════════════════════════════════════════════
Mode: Consumer | Service: user-service

  ✓ User API Contract
    ✓ GET /api/users ── returns user list
      Status: 200 | Content-Type: application/json
      Body matches schema: ✓
    ✓ POST /api/users ── creates user
      Status: 201 | Content-Type: application/json
      Body matches schema: ✓
    ✗ GET /api/users/:id ── returns single user
      Expected field "avatar" (string) not in response
      Contract: pacts/consumer-provider.json:45

  Pact file generated: pacts/frontend-userservice.json

──────────────────────────────────────────────────────────────
Interactions: 2 passed, 1 failed, 3 total
Pact files: 1 generated
══════════════════════════════════════════════════════════════
```

## Error Recovery

- If Pact not installed: "Run `npm install -D @pact-foundation/pact`"
- If provider URL not reachable: check if service is running
- If contract mismatch: show exact field differences between expected and actual
- If Pact Broker connection fails: verify `--broker-url` and authentication
- For version conflicts: ensure consumer and provider use compatible pact spec versions

## Related Skills

- Run API tests: `/api-test`
- Run unit tests: `/unit-test`
- View results: `/test-report --last`
- Generate CI pipeline: `/ci-gen`
- Security scan: `/security-test`
