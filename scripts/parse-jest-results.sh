#!/usr/bin/env bash
# Parse Jest/Vitest JSON results
# Usage: bash scripts/parse-jest-results.sh <results-file>

set -euo pipefail

RESULTS_FILE="${1:-test-results/jest-results.json}"

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

// Works with both Jest and Vitest JSON output
const results = Array.isArray(data.testResults) ? data.testResults :
                Array.isArray(data.results) ? data.results : [];
let totalPassed = 0, totalFailed = 0, totalSkipped = 0;

console.log('Unit Test Results');
console.log('══════════════════════════════════════════════════════════════');

if (results.length === 0) {
  console.log('  (no test suites found in results)');
}

results.forEach(suite => {
  const suiteName = (suite.name || suite.testFilePath || 'unknown')
    .replace(process.cwd() + '/', '')
    .replace(process.cwd() + '\\', '');
  const suiteStatus = suite.status === 'passed' ? '✓' : '✗';
  console.log('  ' + suiteStatus + ' ' + suiteName);

  const tests = Array.isArray(suite.assertionResults) ? suite.assertionResults :
                Array.isArray(suite.testResults) ? suite.testResults : [];
  tests.forEach(t => {
    const icon = t.status === 'passed' ? '✓' : t.status === 'pending' ? '○' : '✗';
    const duration = (typeof t.duration === 'number') ? t.duration + 'ms' : '';
    const name = (Array.isArray(t.ancestorTitles) && t.ancestorTitles.length > 0)
      ? [...t.ancestorTitles, t.title].join(' › ')
      : (t.title || 'untitled');

    if (t.status === 'passed') totalPassed++;
    else if (t.status === 'pending') totalSkipped++;
    else totalFailed++;

    console.log('    ' + icon + ' ' + name + '  ' + duration);

    if (t.status === 'failed' && Array.isArray(t.failureMessages)) {
      t.failureMessages.forEach(msg => {
        const firstLine = String(msg).split('\n')[0].substring(0, 120);
        console.log('      Error: ' + firstLine);
      });
    }
  });
});

const total = totalPassed + totalFailed + totalSkipped;
let duration = '';
if (Array.isArray(data.testResults)) {
  const ms = data.testResults.reduce((s, r) => {
    if (r.perfStats && typeof r.perfStats.end === 'number' && typeof r.perfStats.start === 'number') {
      return s + (r.perfStats.end - r.perfStats.start);
    }
    return s;
  }, 0);
  if (ms > 0) duration = (ms / 1000).toFixed(1) + 's';
}

console.log('──────────────────────────────────────────────────────────────');
console.log('Tests:  ' + totalPassed + ' passed, ' + totalFailed + ' failed, ' + totalSkipped + ' skipped, ' + total + ' total');
console.log('Suites: ' + results.filter(r => r.status === 'passed').length + ' passed, ' + results.filter(r => r.status === 'failed').length + ' failed, ' + results.length + ' total');
if (duration) console.log('Time:   ' + duration);

if (data.coverageMap || data.coverage) {
  console.log('');
  console.log('Coverage: (use --coverage for detailed report)');
}

console.log('══════════════════════════════════════════════════════════════');
NODESCRIPT
