# parse-wdio-results.ps1 - Phan tich bao cao JSON cua WebdriverIO
# Su dung: pwsh scripts/parse-wdio-results.ps1 [results.json]
# Hoac: powershell -ExecutionPolicy Bypass -File scripts/parse-wdio-results.ps1 [results.json]

param(
    [string]$ResultsFile = "test-results/wdio-results.json"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $ResultsFile)) {
    Write-Host "Khong tim thay tep ket qua: $ResultsFile" -ForegroundColor Red
    Write-Host "Chay kiem thu truoc: npx wdio run wdio.conf.ts"
    exit 1
}

# Kiem tra Node.js co san khong
$nodeExists = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeExists) {
    Write-Host "Loi: Can Node.js nhung chua duoc cai dat." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Ket qua kiem thu WebdriverIO"
Write-Host "=============================================="

# Truyen duong dan file qua bien moi truong de tranh injection
$env:WDIO_RESULTS_FILE = (Resolve-Path $ResultsFile).Path

$nodeScript = @'
const fs = require('fs');
const filePath = process.env.WDIO_RESULTS_FILE;

let raw;
try {
    raw = fs.readFileSync(filePath, 'utf8');
} catch (err) {
    console.error('Loi: Khong doc duoc tep: ' + filePath);
    console.error(err.message);
    process.exit(1);
}

let data;
try {
    data = JSON.parse(raw);
} catch (err) {
    console.error('Loi: JSON khong hop le trong tep: ' + filePath);
    console.error(err.message);
    process.exit(1);
}

if (!data || typeof data !== 'object') {
    console.error('Loi: JSON goc phai la object trong: ' + filePath);
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
            console.log('    [DAT] ' + (test.title || 'untitled') + '  (' + duration + 's)');
            passed++;
        } else if (test.state === 'failed' || test.error) {
            console.log('    [LOI] ' + (test.title || 'untitled') + '  (' + duration + 's)');
            if (test.error) {
                const msg = typeof test.error === 'string' ? test.error : (test.error.message || '');
                console.log('      Loi: ' + msg.split('\n')[0].substring(0, 200));
            }
            failed++;
            failures.push(test);
        } else {
            console.log('    [BO]  ' + (test.title || 'untitled') + '  (bo qua)');
            skipped++;
        }
        totalDuration += (typeof test.duration === 'number' ? test.duration : 0);
    }
    for (const child of (Array.isArray(suite.suites) ? suite.suites : [])) {
        processSuite(child);
    }
}

if (suites.length === 0) {
    console.log('  (khong tim thay bo kiem thu trong ket qua)');
}

for (const suite of suites) {
    processSuite(suite);
}

const total = passed + failed + skipped;
const passRate = total > 0 ? ((passed / total) * 100).toFixed(1) : '0.0';

console.log('----------------------------------------------');
console.log('Tong ket:');
console.log('  Tong:     ' + total);
console.log('  Dat:      ' + passed + ' (' + passRate + '%)');
console.log('  Loi:      ' + failed);
console.log('  Bo qua:   ' + skipped);
console.log('  Thoi gian: ' + (totalDuration / 1000).toFixed(1) + 's');
console.log('==============================================');
'@

# Ghi script tam va chay
$tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "parse-wdio-results-$(Get-Random).js"
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
    Remove-Item Env:\WDIO_RESULTS_FILE -ErrorAction SilentlyContinue
}
