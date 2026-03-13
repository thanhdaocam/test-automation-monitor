#!/usr/bin/env bash
# parse-k6-results.sh - Parse k6 JSON summary output
# Usage: bash scripts/parse-k6-results.sh [results.json]

set -euo pipefail

RESULTS_FILE="${1:-test-results/k6-results.json}"

# Validate input file exists and is readable
if [ ! -f "$RESULTS_FILE" ]; then
    echo "Error: Results file not found: $RESULTS_FILE" >&2
    echo "Run tests first: k6 run --out json=test-results/k6-results.json script.k6.js" >&2
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
echo "k6 Performance Test Results"
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

const lines = raw.trim().split('\n');

if (lines.length === 0 || (lines.length === 1 && lines[0] === '')) {
  console.error('Error: Results file contains no data.');
  process.exit(1);
}

const metrics = {};
let points = 0;
let parseErrors = 0;

for (const line of lines) {
    if (!line.trim()) continue;
    try {
        const data = JSON.parse(line);
        if (data && data.type === 'Point' && data.metric) {
            if (!metrics[data.metric]) {
                metrics[data.metric] = { values: [], count: 0 };
            }
            const value = (data.data && typeof data.data.value === 'number') ? data.data.value : null;
            if (value !== null) {
                metrics[data.metric].values.push(value);
                metrics[data.metric].count++;
                points++;
            }
        }
    } catch {
        parseErrors++;
    }
}

if (points === 0) {
  console.log('  (no metric data points found in results)');
  if (parseErrors > 0) {
    console.log('  (' + parseErrors + ' lines could not be parsed as JSON)');
  }
}

function calcStats(values) {
    if (!values || values.length === 0) return null;
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
    if (stats) {
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
}

if (metrics['http_req_failed']) {
    const vals = metrics['http_req_failed'].values;
    if (vals.length > 0) {
        const failCount = vals.filter(v => v > 0).length;
        const total = vals.length;
        const rate = total > 0 ? ((failCount / total) * 100).toFixed(1) : '0';
        console.log('');
        console.log('Failures:');
        console.log('  Failed:   ' + failCount + '/' + total + ' (' + rate + '%)');
    }
}

if (metrics['checks']) {
    const vals = metrics['checks'].values;
    if (vals.length > 0) {
        const passCount = vals.filter(v => v > 0).length;
        const total = vals.length;
        const rate = total > 0 ? ((passCount / total) * 100).toFixed(1) : '0';
        console.log('');
        console.log('Checks:');
        console.log('  Passed:   ' + passCount + '/' + total + ' (' + rate + '%)');
    }
}

console.log('──────────────────────────────────────────────');
console.log('Total data points processed: ' + points);
console.log('══════════════════════════════════════════════');
NODESCRIPT
