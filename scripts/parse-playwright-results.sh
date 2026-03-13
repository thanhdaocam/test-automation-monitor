#!/usr/bin/env bash
# parse-playwright-results.sh - Parse Playwright JSON report
# Usage: bash scripts/parse-playwright-results.sh [results.json]

set -euo pipefail

RESULTS_FILE="${1:-test-results/playwright-results.json}"

# Validate input file exists and is readable
if [ ! -f "$RESULTS_FILE" ]; then
    echo "Error: Results file not found: $RESULTS_FILE" >&2
    echo "Run tests first: npx playwright test --reporter=json" >&2
    exit 1
fi

if [ ! -r "$RESULTS_FILE" ]; then
    echo "Error: Results file is not readable: $RESULTS_FILE" >&2
    exit 1
fi

if [ ! -s "$RESULTS_FILE" ]; then
    echo "Error: Results file is empty: $RESULTS_FILE" >&2
    exit 1
fi

# Check that node is available
if ! command -v node &>/dev/null; then
    echo "Error: Node.js is required but not installed." >&2
    exit 1
fi

echo ""
echo "Playwright Test Results"
echo "══════════════════════════════════════════════"

# Pass file path as argument to node (process.argv[1]) to prevent path injection.
# SECURITY: Never interpolate file paths directly into inline JS strings.
node - "$RESULTS_FILE" <<'NODESCRIPT'
const fs = require('fs');
const filePath = process.argv[2];

let raw;
try {
  raw = fs.readFileSync(filePath, 'utf8');
} catch (err) {
  console.error('Error: Could not read file: ' + filePath);
  console.error(err.message);
  process.exit(1);
}

let data;
try {
  data = JSON.parse(raw);
} catch (err) {
  console.error('Error: Invalid JSON in file: ' + filePath);
  console.error(err.message);
  process.exit(1);
}

if (!data || typeof data !== 'object') {
  console.error('Error: JSON root must be an object in: ' + filePath);
  process.exit(1);
}

const stats = data.stats || {};
const suites = Array.isArray(data.suites) ? data.suites : [];

// Print test results
function printTests(suite, indent) {
    const prefix = '  '.repeat(indent);
    if (suite.title) {
        console.log(prefix + suite.title);
    }
    for (const spec of (Array.isArray(suite.specs) ? suite.specs : [])) {
        for (const test of (Array.isArray(spec.tests) ? spec.tests : [])) {
            for (const result of (Array.isArray(test.results) ? test.results : [])) {
                const icon = result.status === 'passed' ? '✓' :
                             result.status === 'failed' ? '✗' :
                             result.status === 'skipped' ? '○' : '?';
                const duration = (typeof result.duration === 'number')
                    ? (result.duration / 1000).toFixed(1) : '?';
                console.log(prefix + '  ' + icon + ' ' + (spec.title || 'untitled') + '  (' + duration + 's)');
                if (result.status === 'failed' && result.error) {
                    const errMsg = (result.error.message || '').split('\n')[0].substring(0, 200);
                    console.log(prefix + '    Error: ' + errMsg);
                    if (spec.file && spec.line) {
                        console.log(prefix + '    at ' + spec.file + ':' + spec.line);
                    }
                }
            }
        }
    }
    for (const child of (Array.isArray(suite.suites) ? suite.suites : [])) {
        printTests(child, indent + 1);
    }
}

if (suites.length === 0) {
    console.log('  (no test suites found in results)');
}

for (const suite of suites) {
    printTests(suite, 0);
}

const expectedCount = (typeof stats.expected === 'number') ? stats.expected : 0;
const unexpectedCount = (typeof stats.unexpected === 'number') ? stats.unexpected : 0;
const skippedCount = (typeof stats.skipped === 'number') ? stats.skipped : 0;
const totalDuration = (typeof stats.duration === 'number') ? stats.duration : 0;

console.log('──────────────────────────────────────────────');
console.log('Summary:');
console.log('  Total:    ' + (expectedCount + unexpectedCount + skippedCount));
console.log('  Passed:   ' + expectedCount);
console.log('  Failed:   ' + unexpectedCount);
console.log('  Skipped:  ' + skippedCount);
console.log('  Duration: ' + (totalDuration / 1000).toFixed(1) + 's');
console.log('══════════════════════════════════════════════');
NODESCRIPT
