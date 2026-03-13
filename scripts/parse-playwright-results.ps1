# parse-playwright-results.ps1 - Phan tich bao cao JSON cua Playwright
# Su dung: pwsh scripts/parse-playwright-results.ps1 [results.json]
# Hoac: powershell -ExecutionPolicy Bypass -File scripts/parse-playwright-results.ps1 [results.json]

param(
    [string]$ResultsFile = "test-results/playwright-results.json"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $ResultsFile)) {
    Write-Host "Khong tim thay tep ket qua: $ResultsFile" -ForegroundColor Red
    Write-Host "Chay kiem thu truoc: npx playwright test --reporter=json"
    exit 1
}

# Kiểm tra Node.js có sẵn không
$nodeExists = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeExists) {
    Write-Host "Loi: Can Node.js nhung chua duoc cai dat." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Ket qua kiem thu Playwright"
Write-Host "=============================================="

# Sử dụng Node.js để parse JSON (tương thích với bản bash)
# Truyền đường dẫn file qua biến môi trường để tránh injection
$env:PW_RESULTS_FILE = (Resolve-Path $ResultsFile).Path

$nodeScript = @'
const fs = require('fs');
const filePath = process.env.PW_RESULTS_FILE;

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

const stats = data.stats || {};
const suites = data.suites || [];

function printTests(suite, indent) {
    const prefix = '  '.repeat(indent);
    if (suite.title) {
        console.log(prefix + suite.title);
    }
    for (const spec of (suite.specs || [])) {
        for (const test of (spec.tests || [])) {
            for (const result of (test.results || [])) {
                const icon = result.status === 'passed' ? '[DAT]' :
                             result.status === 'failed' ? '[LOI]' :
                             result.status === 'skipped' ? '[BO]' : '[?]';
                const duration = (result.duration / 1000).toFixed(1);
                console.log(prefix + '  ' + icon + ' ' + spec.title + '  (' + duration + 's)');
                if (result.status === 'failed' && result.error) {
                    console.log(prefix + '    Loi: ' + (result.error.message || '').split('\n')[0]);
                    if (spec.file && spec.line) {
                        console.log(prefix + '    tai ' + spec.file + ':' + spec.line);
                    }
                }
            }
        }
    }
    for (const child of (suite.suites || [])) {
        printTests(child, indent + 1);
    }
}

for (const suite of suites) {
    printTests(suite, 0);
}

const total = (stats.expected || 0) + (stats.unexpected || 0) + (stats.skipped || 0);
console.log('----------------------------------------------');
console.log('Tong ket:');
console.log('  Tong:     ' + total);
console.log('  Dat:      ' + (stats.expected || 0));
console.log('  Loi:      ' + (stats.unexpected || 0));
console.log('  Bo qua:   ' + (stats.skipped || 0));
console.log('  Thoi gian: ' + ((stats.duration || 0) / 1000).toFixed(1) + 's');
console.log('==============================================');
'@

# Ghi script tạm và chạy
$tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "parse-pw-results-$(Get-Random).js"
try {
    $nodeScript | Out-File -FilePath $tempScript -Encoding UTF8
    node $tempScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Loi khi phan tich ket qua." -ForegroundColor Red
    }
} finally {
    # Dọn dẹp tệp tạm
    if (Test-Path $tempScript) {
        Remove-Item $tempScript -Force
    }
    Remove-Item Env:\PW_RESULTS_FILE -ErrorAction SilentlyContinue
}
