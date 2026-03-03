#!/usr/bin/env bash
# Parse API test results (Playwright API or Newman JSON output)
# Usage: bash scripts/parse-api-results.sh <results-file>

RESULTS_FILE="${1:-test-results/api-results.json}"

if [ ! -f "$RESULTS_FILE" ]; then
  echo "No results file found at: $RESULTS_FILE"
  exit 1
fi

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$RESULTS_FILE', 'utf8'));

// Detect format: Newman or Playwright
if (data.run) {
  // Newman format
  const run = data.run;
  const stats = run.stats;
  console.log('API Test Results (Newman/Postman)');
  console.log('══════════════════════════════════════════════════════════════');

  run.executions.forEach(exec => {
    const name = exec.item.name;
    const method = exec.request.method;
    const url = exec.request.url.toString();
    const status = exec.response ? exec.response.code : 'N/A';
    const time = exec.response ? exec.response.responseTime + 'ms' : 'timeout';
    const assertions = exec.assertions || [];
    const failed = assertions.filter(a => a.error);
    const icon = failed.length ? '✗' : '✓';

    console.log('  ' + icon + ' ' + method + ' ' + name + ' [' + status + '] ' + time);
    failed.forEach(a => {
      console.log('    Error: ' + a.error.message);
    });
  });

  console.log('──────────────────────────────────────────────────────────────');
  console.log('Requests: ' + stats.requests.total + ' | Assertions: ' + stats.assertions.total + ' passed, ' + (stats.assertions.failed || 0) + ' failed');
  console.log('Duration: ' + run.timings.completed + 'ms');
  console.log('══════════════════════════════════════════════════════════════');

} else if (data.suites) {
  // Playwright format
  let passed = 0, failed = 0, total = 0;

  console.log('API Test Results (Playwright)');
  console.log('══════════════════════════════════════════════════════════════');

  function walkSuites(suites, indent) {
    suites.forEach(suite => {
      if (suite.specs) {
        suite.specs.forEach(spec => {
          spec.tests.forEach(test => {
            total++;
            const result = test.results[test.results.length - 1];
            const status = result.status;
            const duration = result.duration + 'ms';
            const icon = status === 'passed' ? '✓' : '✗';

            if (status === 'passed') passed++;
            else failed++;

            console.log(indent + icon + ' ' + spec.title + '  ' + duration);

            if (status !== 'passed' && result.error) {
              console.log(indent + '  Error: ' + result.error.message.split('\\n')[0]);
            }
          });
        });
      }
      if (suite.suites) walkSuites(suite.suites, indent + '  ');
    });
  }

  walkSuites(data.suites, '  ');

  console.log('──────────────────────────────────────────────────────────────');
  console.log('Summary: ' + passed + ' passed, ' + failed + ' failed, ' + total + ' total');
  console.log('══════════════════════════════════════════════════════════════');
}
"
