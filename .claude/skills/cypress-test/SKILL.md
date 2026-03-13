---
name: cypress-test
version: 2.0.0
description: Chạy kiểm thử E2E và component Cypress. Tự phát hiện cấu hình Cypress và chạy kiểm thử với kết quả có định dạng. Dùng cho dự án sử dụng Cypress thay vì Playwright.
allowed-tools: Bash(npx *), Bash(node *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file-or-pattern] [--headed] [--browser chrome|firefox|edge] [--component] [--spec pattern]
---

# Kiểm thử Cypress

Execute Cypress E2E or component tests and display formatted results.

## Current Project Context

Cypress config:
!`ls cypress.config.ts cypress.config.js cypress.config.mjs 2>/dev/null || echo "No Cypress config found"`

Tệp kiểm thử Cypress:
!`node -e "const fs=require('fs');const path=require('path');function walk(d,depth,max){let r=[];if(depth>max)return r;try{for(const f of fs.readdirSync(d)){if(f.startsWith('.'))continue;const p=path.join(d,f);try{const s=fs.statSync(p);if(s.isDirectory()&&f!=='node_modules')r=r.concat(walk(p,depth+1,max));else if(/\.cy\.(ts|js|tsx|jsx)$/.test(f))r.push(p)}catch{}}}catch{}return r}const files=walk('.',0,5);console.log(files.length?files.join('\n'):'Không tìm thấy tệp kiểm thử Cypress')"`

## Parse Arguments

- `$0` = test file or pattern (optional, runs all if omitted)
- `--headed` = run in headed mode (show browser)
- `--browser <name>` = browser: `chrome`, `firefox`, `edge`, `electron` (default: electron)
- `--component` = run component tests instead of E2E
- `--spec <pattern>` = spec file pattern (glob)
- `--env <key=value>` = set environment variable

## Steps

### 1. Verify Cypress Installation

```bash
npx cypress --version 2>/dev/null
```

If not installed:
```bash
npm install -D cypress
```

Check if browsers are available:
```bash
npx cypress info 2>/dev/null | head -20
```

### 2. Build Command

**E2E tests (default):**
```bash
npx cypress run --reporter json --reporter-options "output=test-results/cypress-results.json"
```

**With specific spec:**
```bash
npx cypress run --spec "$spec_pattern" --reporter json --reporter-options "output=test-results/cypress-results.json"
```

**Headed mode:**
```bash
npx cypress run --headed --browser $browser --spec "$spec_pattern"
```

**Component tests:**
```bash
npx cypress run --component --reporter json --reporter-options "output=test-results/cypress-results.json"
```

**Interactive mode (for debugging):**
```bash
npx cypress open
```

### 3. Execute and Parse Results

Run the command and capture output. Parse JSON results:

**macOS/Linux/Git Bash:**
```bash
bash scripts/parse-cypress-results.sh test-results/cypress-results.json
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/parse-cypress-results.ps1 test-results/cypress-results.json
```

**Đa nền tảng (Node.js — khuyên dùng):**
```bash
node scripts/parse-cypress-results.sh test-results/cypress-results.json
```
> Lưu ý: Các script parse-*.sh đều sử dụng Node.js bên trong nên cũng tương thích khi chạy qua Git Bash trên Windows.

### 4. Display Results

```
Cypress E2E Test Results
══════════════════════════════════════════════════════════════
Browser: Chrome 120 | Viewport: 1280x720

  ✓ login.cy.ts
    ✓ should display login form                    1.2s
    ✓ should login with valid credentials          2.3s
    ✓ should show error for invalid password       1.8s

  ✗ dashboard.cy.ts
    ✓ should load dashboard after login            3.1s
    ✗ should display charts                        5.0s (timeout)
      Error: Timed out retrying: expected '.chart' to exist
      Screenshot: cypress/screenshots/dashboard.cy.ts/charts.png

──────────────────────────────────────────────────────────────
Tests:    4 passed, 1 failed, 5 total
Duration: 13.4s
Video:    cypress/videos/dashboard.cy.ts.mp4
══════════════════════════════════════════════════════════════
```

### 5. Post-Run

- Show pass/fail summary
- List screenshots for failed tests (auto-captured)
- List video recordings (if enabled)
- Suggest: "Use `--headed` to watch tests run in the browser"

## Error Recovery

- If Cypress not installed: "Run `npm install -D cypress` or use `/setup-test-env`"
- If no cypress.config found: suggest `/scaffold-test cypress` to create one
- If browser not found: suggest `--browser electron` (bundled with Cypress)
- If tests timeout: suggest increasing `defaultCommandTimeout` in cypress.config
- If video recording is too large: suggest disabling in config with `video: false`
- For CI environments: ensure `--headless` flag (default in `cypress run`)

## Related Skills

- Create Cypress project: `/scaffold-test cypress`
- View results: `/test-report --last`
- Run Playwright tests instead: `/run-test`
- Visual regression: `/visual-test`
- Accessibility: `/a11y-test`
