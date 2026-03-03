---
name: a11y-test
description: Run accessibility tests to check WCAG 2.2 compliance. Uses axe-core with Playwright for automated a11y scanning. Reports violations with severity, impact, and fix suggestions. Use for any web project.
allowed-tools: Bash(npx *), Bash(node *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: <url-or-test-file> [--standard wcag2a|wcag2aa|wcag2aaa] [--include selector] [--exclude selector]
---

# Accessibility Testing (WCAG)

Scan web pages for accessibility violations using axe-core integrated with Playwright.

## Current Project Context

Accessibility test files:
!`find . -maxdepth 4 -type f \( -name "*.a11y.ts" -o -name "*.a11y.js" -o -name "*.accessibility.*" \) 2>/dev/null | head -10 || echo "No a11y test files found"`

axe-core availability:
!`node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};if(d['@axe-core/playwright']||d['axe-core']||d['pa11y'])console.log('axe-core: installed');else console.log('axe-core: not installed')}catch{console.log('No package.json')}" 2>/dev/null`

## Parse Arguments

- `$0` = URL to scan OR test file path (required)
- `--standard <level>` = WCAG standard: `wcag2a`, `wcag2aa` (default), `wcag2aaa`
- `--include <selector>` = only scan specific area (CSS selector)
- `--exclude <selector>` = exclude area from scan
- `--tags <tags>` = specific axe rule tags (comma-separated)

## Steps

### 1. Determine Scan Mode

**URL provided** (starts with http/https):
- Run Playwright + axe-core against the URL directly

**Test file provided** (*.a11y.ts):
- Execute as Playwright test with axe-core assertions

**No argument**:
- Search for existing a11y test files
- If none found, ask for URL to scan

### 2. Install Dependencies (if needed)

Check if axe-core is available:
```bash
node -e "require('@axe-core/playwright')" 2>/dev/null
```

If not installed:
```bash
npm install -D @axe-core/playwright
```

### 3. Run Accessibility Scan on URL

Create and execute a temporary scan script:

```typescript
// The skill should build and run this via Playwright
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('accessibility scan', async ({ page }) => {
  await page.goto('TARGET_URL');
  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa'])
    .analyze();

  // Output results as JSON for parsing
  console.log(JSON.stringify(results, null, 2));
});
```

Execute:
```bash
npx playwright test a11y-scan.ts --reporter=json
```

### 4. Run Accessibility Test File

```bash
npx playwright test $test_file --reporter=json,line
```

### 5. Display Results

Parse axe-core results and display:

```
Accessibility Scan Results (WCAG 2.2 AA)
══════════════════════════════════════════════════════════════
URL: https://example.com
Scanned: 142 elements

VIOLATIONS (4 issues)

  ✗ [Critical] color-contrast
    Elements with insufficient color contrast ratio
    Impact: serious | WCAG: 1.4.3
    Affected: 3 elements
    - div.header > h1  (ratio: 2.1:1, needs 4.5:1)
    - p.subtitle       (ratio: 3.2:1, needs 4.5:1)
    Fix: Increase text color contrast

  ✗ [Serious] image-alt
    Images must have alternate text
    Impact: critical | WCAG: 1.1.1
    Affected: 2 elements
    - img.hero-image
    - img.profile-photo
    Fix: Add alt attribute to <img> elements

  ✗ [Moderate] label
    Form elements must have labels
    Impact: serious | WCAG: 1.3.1
    Affected: 1 element
    - input#search
    Fix: Add <label> or aria-label

  ✗ [Minor] link-name
    Links must have discernible text
    Impact: minor | WCAG: 2.4.4
    Affected: 1 element
    - a.icon-link
    Fix: Add aria-label to icon-only links

SUMMARY
  Critical:  1
  Serious:   2
  Moderate:  1
  Minor:     1

PASSES: 45 rules passed
──────────────────────────────────────────────────────────────
WCAG 2.2 AA Compliance: FAIL (4 violations)
══════════════════════════════════════════════════════════════
```

## Error Recovery

- If `@axe-core/playwright` not installed: auto-install with `npm install -D @axe-core/playwright`
- If Playwright not installed: suggest `/setup-test-env` or `npm install -D @playwright/test`
- If URL unreachable: check URL is correct and server is running
- If scan times out: try with `--include` to scan specific section
- For single-page apps: ensure page is fully loaded before scanning (wait for network idle)

## Related Skills

- Create a11y test templates: `/scaffold-test web` (includes a11y sample)
- Run web tests: `/run-test`
- View results: `/test-report --last`
- Web quality audit: `/lighthouse`
- Visual regression: `/visual-test`
