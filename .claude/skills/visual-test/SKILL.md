---
name: visual-test
description: Run visual regression tests to detect unintended UI changes. Uses Playwright toHaveScreenshot() or BackstopJS for pixel-by-pixel comparison. Use for UI-critical projects and design systems.
allowed-tools: Bash(npx *), Bash(node *), Bash(cat *), Bash(ls *), Bash(mkdir *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file-or-url] [--update] [--threshold 0.1] [--browsers chrome,firefox] [--viewports 1280x720,375x667]
---

# Visual Regression Testing

Compare screenshots of your UI against baseline images to detect visual changes.

## Current Project Context

Visual test files:
!`find . -maxdepth 4 -type f \( -name "*.visual.ts" -o -name "*.visual.js" \) 2>/dev/null | head -10 || echo "No visual test files found"`

Existing snapshots:
!`ls -d test-results/*-snapshots/ __screenshots__/ backstop_data/ 2>/dev/null | head -5 || echo "No snapshot directories found"`

## Parse Arguments

- `$0` = test file or URL to capture (optional)
- `--update` = update baseline screenshots (accept current as new baseline)
- `--threshold <n>` = pixel difference threshold 0-1 (default: 0.1 = 10%)
- `--browsers <list>` = comma-separated browsers (default: chromium)
- `--viewports <list>` = comma-separated viewports (default: 1280x720)
- `--full-page` = capture full page screenshot (not just viewport)

## Steps

### 1. Detect Visual Testing Approach

**Playwright visual comparisons** (preferred):
- Check for `*.visual.ts` files → run with `npx playwright test`
- Uses built-in `toHaveScreenshot()` and `toMatchSnapshot()`

**BackstopJS** (alternative):
- Check for `backstop.config.js` or `backstop.json`
- Run with `npx backstop test`

### 2. Run Playwright Visual Tests

```bash
npx playwright test $test_file --reporter=json,line --update-snapshots
```

Without `--update` (compare mode):
```bash
npx playwright test $test_file --reporter=json,line
```

For a URL scan (generate temp test):
The skill should create a temporary visual test that navigates to the URL and captures screenshots at different viewports.

### 3. Run BackstopJS Tests

**Compare against baseline:**
```bash
npx backstop test --config=backstop.config.js
```

**Update baseline:**
```bash
npx backstop approve --config=backstop.config.js
```

**Generate reference screenshots:**
```bash
npx backstop reference --config=backstop.config.js
```

### 4. Display Results

```
Visual Regression Results
══════════════════════════════════════════════════════════════
Mode: Compare | Threshold: 0.1 (10%)

  ✓ Homepage (1280x720)
    Diff: 0.0% ── no changes detected

  ✗ Login Page (1280x720)
    Diff: 12.3% ── EXCEEDS THRESHOLD
    Changed regions:
    - Header area (logo shifted 5px right)
    - Button color changed (#333 → #555)
    Diff image: test-results/login-diff.png

  ✓ Dashboard (1280x720)
    Diff: 0.8% ── within threshold

  ✓ Homepage (375x667 mobile)
    Diff: 0.0% ── no changes detected

  ✗ Login Page (375x667 mobile)
    Diff: 8.5% ── EXCEEDS THRESHOLD
    Diff image: test-results/login-mobile-diff.png

──────────────────────────────────────────────────────────────
Pages:  3 passed, 2 failed, 5 total
Viewports: 1280x720, 375x667
Tip: Run with --update to accept changes as new baseline
══════════════════════════════════════════════════════════════
```

### 5. Post-Run

- If differences found: show diff image paths
- If `--update`: confirm baselines were updated
- Suggest: "Review diff images before accepting with `--update`"

## Error Recovery

- If no baseline screenshots exist: suggest running with `--update` first to create baselines
- If Playwright not installed: "Run `npm install -D @playwright/test`"
- If BackstopJS not installed: "Run `npm install -D backstopjs`"
- If screenshots differ due to font rendering: suggest setting `--threshold 0.2` or using Docker for consistent rendering
- For dynamic content (timestamps, ads): suggest using CSS to hide dynamic elements before capture

## Related Skills

- Create visual test templates: `/scaffold-test web`
- Run full E2E tests: `/run-test`
- Accessibility check: `/a11y-test`
- Lighthouse audit: `/lighthouse`
- View results: `/test-report --last`
