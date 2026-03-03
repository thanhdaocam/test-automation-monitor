#!/usr/bin/env bash
# Parse Jest/Vitest JSON results
# Usage: bash scripts/parse-jest-results.sh <results-file>

RESULTS_FILE="${1:-test-results/jest-results.json}"

if [ ! -f "$RESULTS_FILE" ]; then
  echo "No results file found at: $RESULTS_FILE"
  exit 1
fi

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$RESULTS_FILE', 'utf8'));

// Works with both Jest and Vitest JSON output
const results = data.testResults || data.results || [];
let totalPassed = 0, totalFailed = 0, totalSkipped = 0;

console.log('Unit Test Results');
console.log('══════════════════════════════════════════════════════════════');

results.forEach(suite => {
  const suiteName = (suite.name || suite.testFilePath || 'unknown').replace(process.cwd() + '/', '').replace(process.cwd() + '\\\\', '');
  const suiteStatus = suite.status === 'passed' ? '✓' : '✗';
  console.log('  ' + suiteStatus + ' ' + suiteName);

  const tests = suite.assertionResults || suite.testResults || [];
  tests.forEach(t => {
    const icon = t.status === 'passed' ? '✓' : t.status === 'pending' ? '○' : '✗';
    const duration = t.duration ? t.duration + 'ms' : '';
    const name = t.ancestorTitles ? [...t.ancestorTitles, t.title].join(' › ') : t.title;

    if (t.status === 'passed') totalPassed++;
    else if (t.status === 'pending') totalSkipped++;
    else totalFailed++;

    console.log('    ' + icon + ' ' + name + '  ' + duration);

    if (t.status === 'failed' && t.failureMessages) {
      t.failureMessages.forEach(msg => {
        const firstLine = msg.split('\\n')[0].substring(0, 120);
        console.log('      Error: ' + firstLine);
      });
    }
  });
});

const total = totalPassed + totalFailed + totalSkipped;
const duration = data.testResults ? (data.testResults.reduce((s, r) => s + (r.perfStats ? r.perfStats.end - r.perfStats.start : 0), 0) / 1000).toFixed(1) + 's' : '';

console.log('──────────────────────────────────────────────────────────────');
console.log('Tests:  ' + totalPassed + ' passed, ' + totalFailed + ' failed, ' + totalSkipped + ' skipped, ' + total + ' total');
console.log('Suites: ' + results.filter(r => r.status === 'passed').length + ' passed, ' + results.filter(r => r.status === 'failed').length + ' failed, ' + results.length + ' total');
if (duration) console.log('Time:   ' + duration);

if (data.coverageMap || data.coverage) {
  console.log('');
  console.log('Coverage: (use --coverage for detailed report)');
}

console.log('══════════════════════════════════════════════════════════════');
"
