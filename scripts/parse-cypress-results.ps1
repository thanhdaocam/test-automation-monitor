# parse-cypress-results.ps1 - Phan tich bao cao JSON cua Cypress
# Su dung: pwsh scripts/parse-cypress-results.ps1 [results.json]
# Hoac: powershell -ExecutionPolicy Bypass -File scripts/parse-cypress-results.ps1 [results.json]

param(
    [string]$ResultsFile = "test-results/cypress-results.json"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $ResultsFile)) {
    Write-Host "Khong tim thay tep ket qua: $ResultsFile" -ForegroundColor Red
    Write-Host "Chay kiem thu truoc: npx cypress run --reporter json"
    exit 1
}

# Kiem tra Node.js co san khong
$nodeExists = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeExists) {
    Write-Host "Loi: Can Node.js nhung chua duoc cai dat." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Ket qua kiem thu Cypress"
Write-Host "=============================================="

# Truyen duong dan file qua bien moi truong de tranh injection
$env:CYPRESS_RESULTS_FILE = (Resolve-Path $ResultsFile).Path

$nodeScript = @'
const fs = require('fs');
const filePath = process.env.CYPRESS_RESULTS_FILE;

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

// Dinh dang Cypress JSON reporter
const results = Array.isArray(data.results) ? data.results : [data];
let totalPassed = 0, totalFailed = 0, totalPending = 0, totalDuration = 0;

results.forEach(suite => {
    const fileName = (suite.file || suite.fullFile || 'unknown').replace(process.cwd() + '/', '').replace(process.cwd() + '\\', '');
    const suites = Array.isArray(suite.suites) ? suite.suites : [suite];

    suites.forEach(s => {
        const tests = Array.isArray(s.tests) ? s.tests : [];
        const hasFailure = tests.some(t => t.state === 'failed');
        console.log('  ' + (hasFailure ? '[LOI]' : '[DAT]') + ' ' + (s.title || fileName));

        tests.forEach(t => {
            const icon = t.state === 'passed' ? '[DAT]' : t.state === 'pending' ? '[CHO]' : '[LOI]';
            const duration = (typeof t.duration === 'number') ? (t.duration / 1000).toFixed(1) + 's' : '';

            if (t.state === 'passed') totalPassed++;
            else if (t.state === 'pending') totalPending++;
            else totalFailed++;
            totalDuration += (typeof t.duration === 'number' ? t.duration : 0);

            console.log('    ' + icon + ' ' + (t.title || 'untitled') + '  ' + duration);

            if (t.state === 'failed' && t.err) {
                const errMsg = (t.err.message || String(t.err)).split('\n')[0].substring(0, 120);
                console.log('      Loi: ' + errMsg);
            }
        });
    });
});

const total = totalPassed + totalFailed + totalPending;
console.log('----------------------------------------------');
console.log('Tong ket:');
console.log('  Tong:     ' + total);
console.log('  Dat:      ' + totalPassed);
console.log('  Loi:      ' + totalFailed);
console.log('  Cho:      ' + totalPending);
console.log('  Thoi gian: ' + (totalDuration / 1000).toFixed(1) + 's');
console.log('==============================================');
'@

# Ghi script tam va chay
$tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "parse-cypress-results-$(Get-Random).js"
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
    Remove-Item Env:\CYPRESS_RESULTS_FILE -ErrorAction SilentlyContinue
}
