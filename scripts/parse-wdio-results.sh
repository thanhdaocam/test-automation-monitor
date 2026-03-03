#!/usr/bin/env bash
# parse-wdio-results.sh - Parse WebdriverIO JSON report
# Usage: bash scripts/parse-wdio-results.sh [results.json]

RESULTS_FILE="${1:-test-results/wdio-results.json}"

if [ ! -f "$RESULTS_FILE" ]; then
    echo "Results file not found: $RESULTS_FILE"
    echo "Run tests first: npx wdio run wdio.conf.ts"
    exit 1
fi

echo ""
echo "WebdriverIO Test Results"
echo "══════════════════════════════════════════════"

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$RESULTS_FILE', 'utf8'));

let passed = 0, failed = 0, skipped = 0;
let totalDuration = 0;
const failures = [];

const suites = data.suites || data.results || [];

function processSuite(suite) {
    if (suite.title) {
        console.log('  ' + suite.title);
    }
    for (const test of (suite.tests || [])) {
        const duration = ((test.duration || 0) / 1000).toFixed(1);
        if (test.state === 'passed' || test.passed) {
            console.log('    ✓ ' + test.title + '  (' + duration + 's)');
            passed++;
        } else if (test.state === 'failed' || test.error) {
            console.log('    ✗ ' + test.title + '  (' + duration + 's)');
            if (test.error) {
                const msg = typeof test.error === 'string' ? test.error : (test.error.message || '');
                console.log('      Error: ' + msg.split('\n')[0]);
            }
            failed++;
            failures.push(test);
        } else {
            console.log('    ○ ' + test.title + '  (skipped)');
            skipped++;
        }
        totalDuration += test.duration || 0;
    }
    for (const child of (suite.suites || [])) {
        processSuite(child);
    }
}

for (const suite of suites) {
    processSuite(suite);
}

const total = passed + failed + skipped;
const passRate = total > 0 ? ((passed / total) * 100).toFixed(1) : 0;

console.log('──────────────────────────────────────────────');
console.log('Summary:');
console.log('  Total:     ' + total);
console.log('  Passed:    ' + passed + ' (' + passRate + '%)');
console.log('  Failed:    ' + failed);
console.log('  Skipped:   ' + skipped);
console.log('  Duration:  ' + (totalDuration / 1000).toFixed(1) + 's');
console.log('══════════════════════════════════════════════');
" 2>/dev/null || echo "Error parsing results. Ensure Node.js is installed."
