---
name: lighthouse
description: Run Google Lighthouse audits for performance, accessibility, SEO, and best practices. Generates scores and actionable recommendations. Use for any web project to check Core Web Vitals and quality.
allowed-tools: Bash(npx *), Bash(node *), Bash(cat *), Bash(ls *), Bash(mkdir *), Read, Grep, Glob
user-invocable: true
argument-hint: <url> [--category performance|accessibility|seo|best-practices|pwa] [--device mobile|desktop] [--budget budget.json]
---

# Lighthouse Web Quality Audit

Run Google Lighthouse to audit web page performance, accessibility, SEO, and best practices.

## Current Project Context

Lighthouse config:
!`ls lighthouserc.json lighthouserc.js .lighthouserc.json .lighthouserc.js 2>/dev/null || echo "No Lighthouse config found"`

## Parse Arguments

- `$0` = URL to audit (required)
- `--category <cat>` = specific category: `performance`, `accessibility`, `seo`, `best-practices`, `pwa` (default: all)
- `--device <d>` = `mobile` (default) or `desktop`
- `--budget <file>` = performance budget JSON file
- `--runs <n>` = number of runs for median (default: 1, recommended: 3)
- `--output <format>` = `json`, `html`, `csv` (default: json)

## Steps

### 1. Check Lighthouse Installation

```bash
npx lighthouse --version 2>/dev/null
```

If using Lighthouse CI:
```bash
npx lhci --version 2>/dev/null
```

### 2. Run Lighthouse Audit

**Single URL audit:**
```bash
npx lighthouse "$URL" --output=json --output-path=test-results/lighthouse-results.json --chrome-flags="--headless --no-sandbox" --preset=$device
```

With specific category:
```bash
npx lighthouse "$URL" --output=json --output-path=test-results/lighthouse-results.json --chrome-flags="--headless --no-sandbox" --only-categories=$category
```

**Multiple runs (for stable scores):**
```bash
for i in $(seq 1 $runs); do
  npx lighthouse "$URL" --output=json --output-path=test-results/lighthouse-run-$i.json --chrome-flags="--headless --no-sandbox"
done
```

**Using Lighthouse CI (if config exists):**
```bash
npx lhci autorun
```

### 3. Parse and Display Results

Parse the JSON output and display:

```
Lighthouse Audit Results
══════════════════════════════════════════════════════════════
URL:    https://example.com
Device: Mobile | Runs: 3 (median)

SCORES
  Performance:     92 ████████████████████░░
  Accessibility:   98 ████████████████████████░
  Best Practices:  95 ███████████████████████░░
  SEO:             100 █████████████████████████
  PWA:             67 ████████████████░░░░░░░░░

CORE WEB VITALS
  LCP  (Largest Contentful Paint):    1.2s  ✓ Good (<2.5s)
  FID  (First Input Delay):           45ms  ✓ Good (<100ms)
  CLS  (Cumulative Layout Shift):     0.05  ✓ Good (<0.1)
  FCP  (First Contentful Paint):      0.8s  ✓ Good
  TTFB (Time to First Byte):         230ms  ✓ Good
  TBT  (Total Blocking Time):        120ms  ✓ Good

OPPORTUNITIES (potential savings)
  ✗ Serve images in next-gen formats     -320ms
  ✗ Eliminate render-blocking resources  -210ms
  ✗ Reduce unused JavaScript             -180ms

DIAGNOSTICS
  ⚠ Largest Contentful Paint element: <img class="hero">
  ⚠ 12 DOM elements contribute to layout shifts
  ✓ No long main-thread tasks detected

──────────────────────────────────────────────────────────────
Overall: GOOD (avg score: 94)
Full report: test-results/lighthouse-results.html
══════════════════════════════════════════════════════════════
```

### 4. Performance Budget Check (if --budget)

Compare against budget:
```
BUDGET CHECK
  Resource     Budget    Actual    Status
  JavaScript   200KB     185KB     ✓ Under budget
  CSS          50KB      62KB      ✗ Over by 12KB
  Images       500KB     320KB     ✓ Under budget
  Total        1MB       892KB     ✓ Under budget
  LCP          2.5s      1.2s      ✓ Under budget
```

### 5. Post-Run

- Show scores for each category
- Highlight Core Web Vitals (pass/fail)
- List top opportunities for improvement
- If HTML output generated, show path to report
- Suggest: "Run with `--runs 3` for more stable scores"

## Error Recovery

- If `lighthouse` not found: auto-run via `npx lighthouse` (no install needed)
- If Chrome not found: suggest installing Chrome or use `--chrome-flags="--headless"`
- If URL unreachable: check URL and ensure server is running
- If timeout: suggest simpler page or increase timeout
- For authentication-required pages: suggest using Lighthouse with authenticated sessions via `--extra-headers`

## Related Skills

- Accessibility deep-dive: `/a11y-test`
- Visual regression: `/visual-test`
- Performance load testing: `/run-test <file.k6.js>`
- Security audit: `/security-test`
- View results: `/test-report --last`
