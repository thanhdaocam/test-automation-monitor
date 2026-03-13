# parse-api-results.ps1 - Phan tich bao cao JSON cua API test (Newman hoac Playwright)
# Su dung: pwsh scripts/parse-api-results.ps1 [results.json]
# Hoac: powershell -ExecutionPolicy Bypass -File scripts/parse-api-results.ps1 [results.json]

param(
    [string]$ResultsFile = "test-results/api-results.json"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $ResultsFile)) {
    Write-Host "Khong tim thay tep ket qua: $ResultsFile" -ForegroundColor Red
    Write-Host "Chay kiem thu truoc: npx playwright test --reporter=json tests/api/"
    exit 1
}

# Kiem tra Node.js co san khong
$nodeExists = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeExists) {
    Write-Host "Loi: Can Node.js nhung chua duoc cai dat." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Ket qua kiem thu API"
Write-Host "=============================================="

# Truyen duong dan file qua bien moi truong de tranh injection
$env:API_RESULTS_FILE = (Resolve-Path $ResultsFile).Path

$nodeScript = @'
const fs = require('fs');
const filePath = process.env.API_RESULTS_FILE;

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

// Phat hien dinh dang: Newman hoac Playwright
if (data.run) {
    // Dinh dang Newman
    const run = data.run;
    const stats = run.stats || {};
    console.log('Dinh dang: Newman/Postman');
    console.log('');

    const executions = run.executions || [];
    executions.forEach(exec => {
        const name = (exec.item && exec.item.name) || 'unknown';
        const method = (exec.request && exec.request.method) || 'GET';
        const url = (exec.request && exec.request.url) ? exec.request.url.toString() : '';
        const status = exec.response ? exec.response.code : 'N/A';
        const time = exec.response ? exec.response.responseTime + 'ms' : 'timeout';
        const assertions = exec.assertions || [];
        const failed = assertions.filter(a => a.error);
        const icon = failed.length ? '[LOI]' : '[DAT]';

        console.log('  ' + icon + ' ' + method + ' ' + name + ' [' + status + '] ' + time);
        failed.forEach(a => {
            console.log('    Loi: ' + (a.error && a.error.message ? a.error.message : 'loi khong xac dinh'));
        });
    });

    const reqStats = stats.requests || { total: 0 };
    const assertStats = stats.assertions || { total: 0, failed: 0 };
    const timings = run.timings || { completed: 0 };

    console.log('----------------------------------------------');
    console.log('Tong ket:');
    console.log('  Yeu cau:    ' + reqStats.total);
    console.log('  Kiem tra:   ' + assertStats.total + ' dat, ' + (assertStats.failed || 0) + ' loi');
    console.log('  Thoi gian:  ' + timings.completed + 'ms');
    console.log('==============================================');

} else if (data.suites) {
    // Dinh dang Playwright
    let passed = 0, failed = 0, total = 0;
    console.log('Dinh dang: Playwright');
    console.log('');

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
                            console.log(indent + '[?] ' + (spec.title || 'untitled') + '  (khong co ket qua)');
                            return;
                        }
                        const result = results[results.length - 1];
                        const status = result.status || 'unknown';
                        const duration = (typeof result.duration === 'number') ? result.duration + 'ms' : '';
                        const icon = status === 'passed' ? '[DAT]' : '[LOI]';

                        if (status === 'passed') passed++;
                        else failed++;

                        console.log(indent + icon + ' ' + (spec.title || 'untitled') + '  ' + duration);

                        if (status !== 'passed' && result.error) {
                            const errMsg = (result.error.message || '').split('\n')[0].substring(0, 200);
                            console.log(indent + '  Loi: ' + errMsg);
                        }
                    });
                });
            }
            if (Array.isArray(suite.suites)) walkSuites(suite.suites, indent + '  ');
        });
    }

    walkSuites(data.suites, '  ');

    console.log('----------------------------------------------');
    console.log('Tong ket:');
    console.log('  Tong:     ' + total);
    console.log('  Dat:      ' + passed);
    console.log('  Loi:      ' + failed);
    console.log('==============================================');

} else {
    console.error('Canh bao: Dinh dang ket qua khong nhan dang. Can JSON Newman (.run) hoac Playwright (.suites).');
    process.exit(1);
}
'@

# Ghi script tam va chay
$tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "parse-api-results-$(Get-Random).js"
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
    Remove-Item Env:\API_RESULTS_FILE -ErrorAction SilentlyContinue
}
