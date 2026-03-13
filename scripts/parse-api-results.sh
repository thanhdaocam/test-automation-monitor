#!/usr/bin/env bash
# Parse API test results (Playwright API or Newman JSON output)
# Usage: bash scripts/parse-api-results.sh <results-file>

set -euo pipefail

RESULTS_FILE="${1:-test-results/api-results.json}"

# Validate input file exists and is readable
if [ ! -f "$RESULTS_FILE" ]; then
  echo "Error: No results file found at: $RESULTS_FILE" >&2
  exit 1
fi

if [ ! -r "$RESULTS_FILE" ]; then
  echo "Error: Results file is not readable: $RESULTS_FILE" >&2
  exit 1
fi

# Validate file is not empty
if [ ! -s "$RESULTS_FILE" ]; then
  echo "Error: Results file is empty: $RESULTS_FILE" >&2
  exit 1
fi

# Check that node is available
if ! command -v node &>/dev/null; then
  echo "Error: Node.js is required but not installed." >&2
  exit 1
fi

# Pass file path as argument to node (process.argv[2]) to prevent path injection.
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

// Detect format: Newman or Playwright
if (data.run) {
  // Newman format
  const run = data.run;
  const stats = run.stats || {};
  console.log('API Test Results (Newman/Postman)');
  console.log('══════════════════════════════════════════════════════════════');

  const executions = run.executions || [];
  executions.forEach(exec => {
    const name = (exec.item && exec.item.name) || 'unknown';
    const method = (exec.request && exec.request.method) || 'GET';
    const url = (exec.request && exec.request.url) ? exec.request.url.toString() : '';
    const status = exec.response ? exec.response.code : 'N/A';
    const time = exec.response ? exec.response.responseTime + 'ms' : 'timeout';
    const assertions = exec.assertions || [];
    const failed = assertions.filter(a => a.error);
    const icon = failed.length ? '✗' : '✓';

    console.log('  ' + icon + ' ' + method + ' ' + name + ' [' + status + '] ' + time);
    failed.forEach(a => {
      console.log('    Error: ' + (a.error && a.error.message ? a.error.message : 'unknown error'));
    });
  });

  const reqStats = stats.requests || { total: 0 };
  const assertStats = stats.assertions || { total: 0, failed: 0 };
  const timings = run.timings || { completed: 0 };

  console.log('──────────────────────────────────────────────────────────────');
  console.log('Requests: ' + reqStats.total + ' | Assertions: ' + assertStats.total + ' passed, ' + (assertStats.failed || 0) + ' failed');
  console.log('Duration: ' + timings.completed + 'ms');
  console.log('══════════════════════════════════════════════════════════════');

} else if (data.suites) {
  // Playwright format
  let passed = 0, failed = 0, total = 0;

  console.log('API Test Results (Playwright)');
  console.log('══════════════════════════════════════════════════════════════');

  function walkSuites(suites, indent) {
    if (!Array.isArray(suites)) return;
    suites.forEach(suite => {
      if (Array.isArray(suite.specs)) {
        suite.specs.forEach(spec => {
          const tests = spec.tests || [];
          tests.forEach(test => {
            total++;
            const results = test.results || [];
            if (results.length === 0) {
              failed++;
              console.log(indent + '? ' + (spec.title || 'untitled') + '  (no results)');
              return;
            }
            const result = results[results.length - 1];
            const status = result.status || 'unknown';
            const duration = (typeof result.duration === 'number') ? result.duration + 'ms' : '';
            const icon = status === 'passed' ? '✓' : '✗';

            if (status === 'passed') passed++;
            else failed++;

            console.log(indent + icon + ' ' + (spec.title || 'untitled') + '  ' + duration);

            if (status !== 'passed' && result.error) {
              const errMsg = (result.error.message || '').split('\n')[0].substring(0, 200);
              console.log(indent + '  Error: ' + errMsg);
            }
          });
        });
      }
      if (Array.isArray(suite.suites)) walkSuites(suite.suites, indent + '  ');
    });
  }

  walkSuites(data.suites, '  ');

  console.log('──────────────────────────────────────────────────────────────');
  console.log('Summary: ' + passed + ' passed, ' + failed + ' failed, ' + total + ' total');
  console.log('══════════════════════════════════════════════════════════════');

} else {
  console.error('Warning: Unrecognized results format. Expected Newman (.run) or Playwright (.suites) JSON.');
  process.exit(1);
}
NODESCRIPT
