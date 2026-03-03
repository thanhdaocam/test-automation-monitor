#!/usr/bin/env bash
# parse-playwright-results.sh - Parse Playwright JSON report
# Usage: bash scripts/parse-playwright-results.sh [results.json]

RESULTS_FILE="${1:-test-results/playwright-results.json}"

if [ ! -f "$RESULTS_FILE" ]; then
    echo "Results file not found: $RESULTS_FILE"
    echo "Run tests first: npx playwright test --reporter=json"
    exit 1
fi

echo ""
echo "Playwright Test Results"
echo "══════════════════════════════════════════════"

# Extract stats using node (since jq may not be available)
node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$RESULTS_FILE', 'utf8'));

const stats = data.stats || {};
const suites = data.suites || [];

// Print test results
function printTests(suite, indent) {
    const prefix = '  '.repeat(indent);
    if (suite.title) {
        console.log(prefix + suite.title);
    }
    for (const spec of (suite.specs || [])) {
        for (const test of (spec.tests || [])) {
            for (const result of (test.results || [])) {
                const icon = result.status === 'passed' ? '✓' :
                             result.status === 'failed' ? '✗' :
                             result.status === 'skipped' ? '○' : '?';
                const duration = (result.duration / 1000).toFixed(1);
                console.log(prefix + '  ' + icon + ' ' + spec.title + '  (' + duration + 's)');
                if (result.status === 'failed' && result.error) {
                    console.log(prefix + '    Error: ' + (result.error.message || '').split('\n')[0]);
                    if (spec.file && spec.line) {
                        console.log(prefix + '    at ' + spec.file + ':' + spec.line);
                    }
                }
            }
        }
    }
    for (const child of (suite.suites || [])) {
        printTests(child, indent + 1);
    }
}

for (const suite of suites) {
    printTests(suite, 0);
}

console.log('──────────────────────────────────────────────');
console.log('Summary:');
console.log('  Total:    ' + (stats.expected + stats.unexpected + stats.skipped || 0));
console.log('  Passed:   ' + (stats.expected || 0));
console.log('  Failed:   ' + (stats.unexpected || 0));
console.log('  Skipped:  ' + (stats.skipped || 0));
console.log('  Duration: ' + ((stats.duration || 0) / 1000).toFixed(1) + 's');
console.log('══════════════════════════════════════════════');
" 2>/dev/null || echo "Error parsing results. Ensure Node.js is installed."
