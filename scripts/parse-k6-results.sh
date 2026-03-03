#!/usr/bin/env bash
# parse-k6-results.sh - Parse k6 JSON summary output
# Usage: bash scripts/parse-k6-results.sh [results.json]

RESULTS_FILE="${1:-test-results/k6-results.json}"

if [ ! -f "$RESULTS_FILE" ]; then
    echo "Results file not found: $RESULTS_FILE"
    echo "Run tests first: k6 run --out json=test-results/k6-results.json script.k6.js"
    exit 1
fi

echo ""
echo "k6 Performance Test Results"
echo "══════════════════════════════════════════════"

node -e "
const fs = require('fs');
const lines = fs.readFileSync('$RESULTS_FILE', 'utf8').trim().split('\n');

const metrics = {};
const checks = {};
let points = 0;

for (const line of lines) {
    try {
        const data = JSON.parse(line);
        if (data.type === 'Point' && data.metric) {
            if (!metrics[data.metric]) {
                metrics[data.metric] = { values: [], count: 0 };
            }
            metrics[data.metric].values.push(data.data.value);
            metrics[data.metric].count++;
            points++;
        }
    } catch {}
}

function calcStats(values) {
    if (!values.length) return {};
    values.sort((a, b) => a - b);
    const sum = values.reduce((a, b) => a + b, 0);
    return {
        avg: (sum / values.length).toFixed(1),
        min: values[0].toFixed(1),
        med: values[Math.floor(values.length * 0.5)].toFixed(1),
        max: values[values.length - 1].toFixed(1),
        p90: values[Math.floor(values.length * 0.9)].toFixed(1),
        p95: values[Math.floor(values.length * 0.95)].toFixed(1),
        p99: values[Math.floor(values.length * 0.99)].toFixed(1),
        count: values.length,
    };
}

if (metrics['http_req_duration']) {
    const stats = calcStats(metrics['http_req_duration'].values);
    console.log('HTTP Request Duration:');
    console.log('  Average:  ' + stats.avg + 'ms');
    console.log('  Median:   ' + stats.med + 'ms');
    console.log('  Min:      ' + stats.min + 'ms');
    console.log('  Max:      ' + stats.max + 'ms');
    console.log('  p(90):    ' + stats.p90 + 'ms');
    console.log('  p(95):    ' + stats.p95 + 'ms');
    console.log('  p(99):    ' + stats.p99 + 'ms');
    console.log('  Requests: ' + stats.count);
}

if (metrics['http_req_failed']) {
    const vals = metrics['http_req_failed'].values;
    const failCount = vals.filter(v => v > 0).length;
    const total = vals.length;
    const rate = total > 0 ? ((failCount / total) * 100).toFixed(1) : 0;
    console.log('');
    console.log('Failures:');
    console.log('  Failed:   ' + failCount + '/' + total + ' (' + rate + '%)');
}

if (metrics['checks']) {
    const vals = metrics['checks'].values;
    const passCount = vals.filter(v => v > 0).length;
    const total = vals.length;
    const rate = total > 0 ? ((passCount / total) * 100).toFixed(1) : 0;
    console.log('');
    console.log('Checks:');
    console.log('  Passed:   ' + passCount + '/' + total + ' (' + rate + '%)');
}

console.log('──────────────────────────────────────────────');
console.log('Total data points processed: ' + points);
console.log('══════════════════════════════════════════════');
" 2>/dev/null || echo "Error parsing results. Ensure Node.js is installed."
