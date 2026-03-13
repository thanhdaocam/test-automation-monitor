# parse-jest-results.ps1 - Phan tich bao cao JSON cua Jest/Vitest
# Su dung: pwsh scripts/parse-jest-results.ps1 [results.json]
# Hoac: powershell -ExecutionPolicy Bypass -File scripts/parse-jest-results.ps1 [results.json]

param(
    [string]$ResultsFile = "test-results/jest-results.json"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $ResultsFile)) {
    Write-Host "Khong tim thay tep ket qua: $ResultsFile" -ForegroundColor Red
    Write-Host "Chay kiem thu truoc: npx jest --json --outputFile=test-results/jest-results.json"
    exit 1
}

# Kiem tra Node.js co san khong
$nodeExists = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeExists) {
    Write-Host "Loi: Can Node.js nhung chua duoc cai dat." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Ket qua kiem thu don vi (Jest/Vitest)"
Write-Host "=============================================="

# Truyen duong dan file qua bien moi truong de tranh injection
$env:JEST_RESULTS_FILE = (Resolve-Path $ResultsFile).Path

$nodeScript = @'
const fs = require('fs');
const filePath = process.env.JEST_RESULTS_FILE;

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

// Tuong thich ca Jest va Vitest JSON output
const results = Array.isArray(data.testResults) ? data.testResults :
                Array.isArray(data.results) ? data.results : [];
let totalPassed = 0, totalFailed = 0, totalSkipped = 0;

if (results.length === 0) {
    console.log('  (khong tim thay bo kiem thu trong ket qua)');
}

results.forEach(suite => {
    const suiteName = (suite.name || suite.testFilePath || 'unknown')
        .replace(process.cwd() + '/', '')
        .replace(process.cwd() + '\\', '');
    const suiteStatus = suite.status === 'passed' ? '[DAT]' : '[LOI]';
    console.log('  ' + suiteStatus + ' ' + suiteName);

    const tests = Array.isArray(suite.assertionResults) ? suite.assertionResults :
                  Array.isArray(suite.testResults) ? suite.testResults : [];
    tests.forEach(t => {
        const icon = t.status === 'passed' ? '[DAT]' : t.status === 'pending' ? '[BO]' : '[LOI]';
        const duration = (typeof t.duration === 'number') ? t.duration + 'ms' : '';
        const name = (Array.isArray(t.ancestorTitles) && t.ancestorTitles.length > 0)
            ? [...t.ancestorTitles, t.title].join(' > ')
            : (t.title || 'untitled');

        if (t.status === 'passed') totalPassed++;
        else if (t.status === 'pending') totalSkipped++;
        else totalFailed++;

        console.log('    ' + icon + ' ' + name + '  ' + duration);

        if (t.status === 'failed' && Array.isArray(t.failureMessages)) {
            t.failureMessages.forEach(msg => {
                const firstLine = String(msg).split('\n')[0].substring(0, 120);
                console.log('      Loi: ' + firstLine);
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

console.log('----------------------------------------------');
console.log('Tong ket:');
console.log('  Tong:     ' + total);
console.log('  Dat:      ' + totalPassed);
console.log('  Loi:      ' + totalFailed);
console.log('  Bo qua:   ' + totalSkipped);
console.log('  Bo kiem thu: ' + results.filter(r => r.status === 'passed').length + ' dat, ' + results.filter(r => r.status === 'failed').length + ' loi, ' + results.length + ' tong');
if (duration) console.log('  Thoi gian: ' + duration);

if (data.coverageMap || data.coverage) {
    console.log('');
    console.log('  Do phu: (dung --coverage de xem bao cao chi tiet)');
}

console.log('==============================================');
'@

# Ghi script tam va chay
$tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "parse-jest-results-$(Get-Random).js"
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
    Remove-Item Env:\JEST_RESULTS_FILE -ErrorAction SilentlyContinue
}
