#!/usr/bin/env bash
# Parse Cypress JSON results
# Usage: bash scripts/parse-cypress-results.sh <results-file>

RESULTS_FILE="${1:-test-results/cypress-results.json}"

if [ ! -f "$RESULTS_FILE" ]; then
  echo "No results file found at: $RESULTS_FILE"
  exit 1
fi

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$RESULTS_FILE', 'utf8'));

// Cypress JSON reporter format
const results = data.results || [data];
let totalPassed = 0, totalFailed = 0, totalPending = 0, totalDuration = 0;

console.log('Cypress Test Results');
console.log('══════════════════════════════════════════════════════════════');

results.forEach(suite => {
  const fileName = (suite.file || suite.fullFile || 'unknown').replace(process.cwd() + '/', '');
  const suites = suite.suites || [suite];

  suites.forEach(s => {
    const tests = s.tests || [];
    const hasFailure = tests.some(t => t.state === 'failed');
    console.log('  ' + (hasFailure ? '✗' : '✓') + ' ' + (s.title || fileName));

    tests.forEach(t => {
      const icon = t.state === 'passed' ? '✓' : t.state === 'pending' ? '○' : '✗';
      const duration = t.duration ? (t.duration / 1000).toFixed(1) + 's' : '';

      if (t.state === 'passed') totalPassed++;
      else if (t.state === 'pending') totalPending++;
      else totalFailed++;
      totalDuration += (t.duration || 0);

      console.log('    ' + icon + ' ' + t.title + '  ' + duration);

      if (t.state === 'failed' && t.err) {
        const errMsg = (t.err.message || t.err.toString()).split('\\n')[0].substring(0, 120);
        console.log('      Error: ' + errMsg);
      }
    });
  });
});

console.log('──────────────────────────────────────────────────────────────');
console.log('Tests:    ' + totalPassed + ' passed, ' + totalFailed + ' failed, ' + totalPending + ' pending, ' + (totalPassed + totalFailed + totalPending) + ' total');
console.log('Duration: ' + (totalDuration / 1000).toFixed(1) + 's');
console.log('══════════════════════════════════════════════════════════════');
"
