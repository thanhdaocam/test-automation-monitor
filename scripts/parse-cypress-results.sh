#!/usr/bin/env bash
# Parse Cypress JSON results
# Usage: bash scripts/parse-cypress-results.sh <results-file>

set -euo pipefail

RESULTS_FILE="${1:-test-results/cypress-results.json}"

# Validate input file exists and is readable
if [ ! -f "$RESULTS_FILE" ]; then
  echo "Error: No results file found at: $RESULTS_FILE" >&2
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

// Cypress JSON reporter format
const results = Array.isArray(data.results) ? data.results : [data];
let totalPassed = 0, totalFailed = 0, totalPending = 0, totalDuration = 0;

console.log('Cypress Test Results');
console.log('══════════════════════════════════════════════════════════════');

results.forEach(suite => {
  const fileName = (suite.file || suite.fullFile || 'unknown').replace(process.cwd() + '/', '');
  const suites = Array.isArray(suite.suites) ? suite.suites : [suite];

  suites.forEach(s => {
    const tests = Array.isArray(s.tests) ? s.tests : [];
    const hasFailure = tests.some(t => t.state === 'failed');
    console.log('  ' + (hasFailure ? '✗' : '✓') + ' ' + (s.title || fileName));

    tests.forEach(t => {
      const icon = t.state === 'passed' ? '✓' : t.state === 'pending' ? '○' : '✗';
      const duration = (typeof t.duration === 'number') ? (t.duration / 1000).toFixed(1) + 's' : '';

      if (t.state === 'passed') totalPassed++;
      else if (t.state === 'pending') totalPending++;
      else totalFailed++;
      totalDuration += (typeof t.duration === 'number' ? t.duration : 0);

      console.log('    ' + icon + ' ' + (t.title || 'untitled') + '  ' + duration);

      if (t.state === 'failed' && t.err) {
        const errMsg = (t.err.message || String(t.err)).split('\n')[0].substring(0, 120);
        console.log('      Error: ' + errMsg);
      }
    });
  });
});

console.log('──────────────────────────────────────────────────────────────');
console.log('Tests:    ' + totalPassed + ' passed, ' + totalFailed + ' failed, ' + totalPending + ' pending, ' + (totalPassed + totalFailed + totalPending) + ' total');
console.log('Duration: ' + (totalDuration / 1000).toFixed(1) + 's');
console.log('══════════════════════════════════════════════════════════════');
NODESCRIPT
