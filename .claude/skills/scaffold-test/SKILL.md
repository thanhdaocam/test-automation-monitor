---
name: scaffold-test
description: Create a new test project with proper structure, config files, and sample tests. Supports Playwright (web), WebdriverIO+Appium (mobile), and k6 (performance) templates. Use to quickly set up a new test project.
allowed-tools: Bash(npm *), Bash(npx *), Bash(mkdir *), Bash(cp *), Bash(ls *), Bash(cat *), Write, Read, Glob
user-invocable: true
argument-hint: [web|mobile|performance|all] [--dir path]
disable-model-invocation: true
---

# Scaffold Test Project

Create a new test project from templates with proper structure and configurations.

## Parse Arguments

- `$0` = project type: `web`, `mobile`, `performance`, or `all`. If not specified, ask the user.
- `--dir <path>` = directory to create project in. Default: current directory.

## Project Types

### `web` - Playwright Web Testing

Create structure:
```
tests/
├── web/
│   ├── login.spec.ts           # Sample login test
│   ├── dashboard.spec.ts       # Sample dashboard test
│   └── helpers/
│       └── test-utils.ts       # Shared utilities
├── playwright.config.ts         # Playwright configuration
└── package.json                 # Dependencies
```

**Files to create:**

`playwright.config.ts` - Copy from templates/playwright.config.ts (read it and write to target dir).

`tests/web/login.spec.ts` - Sample test:
```typescript
import { test, expect } from '@playwright/test';

test.describe('Login Page', () => {
    test('should display login form', async ({ page }) => {
        await page.goto('/login');
        await expect(page.locator('form')).toBeVisible();
        await expect(page.locator('input[name="email"]')).toBeVisible();
        await expect(page.locator('input[name="password"]')).toBeVisible();
    });

    test('should login with valid credentials', async ({ page }) => {
        await page.goto('/login');
        await page.fill('input[name="email"]', 'user@example.com');
        await page.fill('input[name="password"]', 'password123');
        await page.click('button[type="submit"]');
        await expect(page).toHaveURL('/dashboard');
    });
});
```

Install dependencies:
```bash
npm install -D @playwright/test typescript
npx playwright install chromium
```

### `mobile` - WebdriverIO + Appium Mobile Testing

Create structure:
```
tests/
├── mobile/
│   ├── app-login.mobile.ts      # Sample native test
│   ├── webview.mobile.ts        # Sample WebView test
│   └── helpers/
│       └── mobile-utils.ts      # Shared utilities
├── wdio.conf.ts                  # WDIO configuration
└── package.json                  # Dependencies
```

**Files to create:**

`wdio.conf.ts` - Copy from templates/wdio.conf.ts.

`tests/mobile/app-login.mobile.ts` - Sample native test.

`tests/mobile/webview.mobile.ts` - Sample WebView context switching test.

Install dependencies:
```bash
npm install -D webdriverio @wdio/cli @wdio/local-runner @wdio/mocha-framework @wdio/spec-reporter typescript ts-node
```

### `performance` - k6 Load Testing

Create structure:
```
tests/
├── performance/
│   ├── load-test.k6.js           # Sample load test
│   ├── stress-test.k6.js         # Sample stress test
│   └── helpers/
│       └── config.js             # Shared config (base URL, thresholds)
└── package.json                   # (optional, for k6 extensions)
```

**Files to create:**

`tests/performance/load-test.k6.js` - Copy from templates/sample.k6.js.

### `all` - Full Setup

Create all three project types in one go. Run web, mobile, and performance scaffolding sequentially.

## Steps

1. Determine project type from arguments (or ask user).
2. Create directory structure using mkdir.
3. Read template files from the `templates/` directory in this repo.
4. Write configuration and sample test files to the target directory.
5. Install dependencies with npm.
6. Verify setup by listing created files.
7. Display summary:
   ```
   Project scaffolded successfully!
   ═══════════════════════════════════
   Type:     web (Playwright)
   Location: ./tests/web/
   Files:    3 created
   Deps:     @playwright/test, typescript

   Next steps:
     1. Update playwright.config.ts with your baseURL
     2. Run: /run-test tests/web/login.spec.ts
   ═══════════════════════════════════
   ```
