#!/usr/bin/env bash
# parse-wdio-results.sh - Parse WebdriverIO JSON report
# Usage: bash scripts/parse-wdio-results.sh [results.json]

set -euo pipefail

RESULTS_FILE="${1:-test-results/wdio-results.json}"

# Validate input file exists and is readable
if [ ! -f "$RESULTS_FILE" ]; then
    echo "Error: Results file not found: $RESULTS_FILE" >&2
    echo "Run tests first: npx wdio run wdio.conf.ts" >&2
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
echo "WebdriverIO Test Results"
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

let passed = 0, failed = 0, skipped = 0;
let totalDuration = 0;
const failures = [];

const suites = Array.isArray(data.suites) ? data.suites :
               Array.isArray(data.results) ? data.results : [];

function processSuite(suite) {
    if (suite.title) {
        console.log('  ' + suite.title);
    }
    for (const test of (Array.isArray(suite.tests) ? suite.tests : [])) {
        const duration = ((typeof test.duration === 'number' ? test.duration : 0) / 1000).toFixed(1);
        if (test.state === 'passed' || test.passed) {
            console.log('    ✓ ' + (test.title || 'untitled') + '  (' + duration + 's)');
            passed++;
        } else if (test.state === 'failed' || test.error) {
            console.log('    ✗ ' + (test.title || 'untitled') + '  (' + duration + 's)');
            if (test.error) {
                const msg = typeof test.error === 'string' ? test.error : (test.error.message || '');
                console.log('      Error: ' + msg.split('\n')[0].substring(0, 200));
            }
            failed++;
            failures.push(test);
        } else {
            console.log('    ○ ' + (test.title || 'untitled') + '  (skipped)');
            skipped++;
        }
        totalDuration += (typeof test.duration === 'number' ? test.duration : 0);
    }
    for (const child of (Array.isArray(suite.suites) ? suite.suites : [])) {
        processSuite(child);
    }
}

if (suites.length === 0) {
    console.log('  (no test suites found in results)');
}

for (const suite of suites) {
    processSuite(suite);
}

const total = passed + failed + skipped;
const passRate = total > 0 ? ((passed / total) * 100).toFixed(1) : '0.0';

console.log('──────────────────────────────────────────────');
console.log('Summary:');
console.log('  Total:     ' + total);
console.log('  Passed:    ' + passed + ' (' + passRate + '%)');
console.log('  Failed:    ' + failed);
console.log('  Skipped:   ' + skipped);
console.log('  Duration:  ' + (totalDuration / 1000).toFixed(1) + 's');
console.log('══════════════════════════════════════════════');
NODESCRIPT
