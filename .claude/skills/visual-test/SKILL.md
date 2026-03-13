---
name: visual-test
version: 2.0.0
description: Chạy kiểm thử hồi quy giao diện để phát hiện thay đổi UI ngoài ý muốn. Dùng Playwright toHaveScreenshot() hoặc BackstopJS so sánh pixel-by-pixel. Dùng cho dự án UI quan trọng và design system.
allowed-tools: Bash(npx *), Bash(node *), Bash(cat *), Bash(ls *), Bash(mkdir *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file-or-url] [--update] [--threshold 0.1] [--browsers chrome,firefox] [--viewports 1280x720,375x667]
---

# Kiểm thử hồi quy giao diện

Compare screenshots of your UI against baseline images to detect visual changes.

## Current Project Context

Tệp kiểm thử hình ảnh:
!`node -e "const fs=require('fs');const path=require('path');function walk(d,depth,max){let r=[];if(depth>max)return r;try{for(const f of fs.readdirSync(d)){if(f.startsWith('.'))continue;const p=path.join(d,f);try{const s=fs.statSync(p);if(s.isDirectory()&&f!=='node_modules')r=r.concat(walk(p,depth+1,max));else if(/\.visual\.(ts|js)$/.test(f))r.push(p)}catch{}}}catch{}return r}const files=walk('.',0,4);console.log(files.length?files.join('\n'):'Không tìm thấy tệp kiểm thử hình ảnh')"`

Ảnh chụp hiện có:
!`node -e "const fs=require('fs');const dirs=['test-results','__screenshots__','backstop_data'];const found=dirs.filter(d=>{try{return fs.statSync(d).isDirectory()}catch{return false}});console.log(found.length?found.join('\\n'):'Không tìm thấy thư mục ảnh chụp')"`

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
