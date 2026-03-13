# parse-k6-results.ps1 - Phan tich bao cao JSON cua k6
# Su dung: pwsh scripts/parse-k6-results.ps1 [results.json]
# Hoac: powershell -ExecutionPolicy Bypass -File scripts/parse-k6-results.ps1 [results.json]

param(
    [string]$ResultsFile = "test-results/k6-results.json"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $ResultsFile)) {
    Write-Host "Khong tim thay tep ket qua: $ResultsFile" -ForegroundColor Red
    Write-Host "Chay kiem thu truoc: k6 run --out json=test-results/k6-results.json script.k6.js"
    exit 1
}

# Kiem tra Node.js co san khong
$nodeExists = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeExists) {
    Write-Host "Loi: Can Node.js nhung chua duoc cai dat." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "k6 Performance Test Results"
Write-Host "=============================================="

# Truyen duong dan file qua bien moi truong de tranh injection
$env:K6_RESULTS_FILE = (Resolve-Path $ResultsFile).Path

$nodeScript = @'
const fs = require('fs');
const filePath = process.env.K6_RESULTS_FILE;

let raw;
try {
    raw = fs.readFileSync(filePath, 'utf8');
} catch (err) {
    console.error('Loi: Khong doc duoc tep: ' + filePath);
    console.error(err.message);
    process.exit(1);
}

const lines = raw.trim().split('\n');

if (lines.length === 0 || (lines.length === 1 && lines[0] === '')) {
    console.error('Loi: Tep ket qua khong co du lieu.');
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
    console.log('  (khong tim thay diem du lieu metric trong ket qua)');
    if (parseErrors > 0) {
        console.log('  (' + parseErrors + ' dong khong the phan tich JSON)');
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

console.log('----------------------------------------------');
console.log('Tong diem du lieu da xu ly: ' + points);
console.log('==============================================');
'@

# Ghi script tam va chay
$tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "parse-k6-results-$(Get-Random).js"
try {
    $nodeScript | Out-File -FilePath $tempScript -Encoding UTF8
    node $tempScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Loi khi phan tich ket qua." -ForegroundColor Red
    }
} finally {
    # Don dep tep tam
    if (Test-Path $tempScript) {
        Remove-Item $tempScript -Force
    }
    Remove-Item Env:\K6_RESULTS_FILE -ErrorAction SilentlyContinue
}
