# check-env.ps1 - Kiểm tra tiền điều kiện môi trường kiểm thử tự động
# Sử dụng: pwsh scripts/check-env.ps1
# Hoặc: powershell -ExecutionPolicy Bypass -File scripts/check-env.ps1
# Kết quả: Hiển thị trạng thái của từng công cụ

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'SilentlyContinue'

$Pass = 0
$Fail = 0
$Warn = 0

function Test-Tool {
    param(
        [string]$Name,
        [string]$Command,
        [string]$Required = "required"
    )

    try {
        $result = Invoke-Expression $Command 2>&1
        if ($LASTEXITCODE -eq 0 -or $null -ne $result) {
            $version = ($result | Select-Object -First 1).ToString().Trim()
            if ($version -ne "") {
                Write-Host "  [DAT] $Name : $version" -ForegroundColor Green
                $script:Pass++
                return
            }
        }
    } catch {
        # Lệnh thất bại
    }

    if ($Required -eq "required") {
        Write-Host "  [LOI] $Name : khong tim thay" -ForegroundColor Red
        $script:Fail++
    } else {
        Write-Host "  [--]  $Name : khong tim thay (tuy chon)" -ForegroundColor Yellow
        $script:Warn++
    }
}

Write-Host ""
Write-Host "==========================================="
Write-Host "  Kiem tra moi truong kiem thu tu dong"
Write-Host "==========================================="
Write-Host ""

Write-Host "Cong cu co ban:"
Test-Tool -Name "Node.js" -Command "node --version" -Required "required"
Test-Tool -Name "npm" -Command "npm --version" -Required "required"
Test-Tool -Name "Java" -Command "java --version 2>&1 | Select-Object -First 1" -Required "required"

Write-Host ""
Write-Host "Cong cu Android:"
Test-Tool -Name "ADB" -Command "adb version | Select-Object -First 1" -Required "required"

$androidHome = $env:ANDROID_HOME
if ($androidHome -and (Test-Path $androidHome)) {
    Write-Host "  [DAT] ANDROID_HOME: $androidHome" -ForegroundColor Green
    $Pass++
} elseif ($androidHome) {
    Write-Host "  [CN]  ANDROID_HOME: $androidHome (duong dan khong ton tai)" -ForegroundColor Yellow
    $Warn++
} else {
    Write-Host "  [LOI] ANDROID_HOME: chua dat" -ForegroundColor Red
    $Fail++
}

Write-Host ""
Write-Host "Framework kiem thu:"
Test-Tool -Name "Appium" -Command "appium --version" -Required "required"

# Kiểm tra Appium drivers
try {
    $drivers = appium driver list --installed 2>&1
    if ($LASTEXITCODE -eq 0) {
        $installedCount = ($drivers | Select-String -Pattern "installed" -AllMatches).Matches.Count
        if ($installedCount -gt 0) {
            Write-Host "  [DAT] Appium Drivers: $installedCount da cai dat" -ForegroundColor Green
            $Pass++
        } else {
            Write-Host "  [LOI] Appium Drivers: chua cai dat driver nao" -ForegroundColor Red
            $Fail++
        }
    } else {
        Write-Host "  [LOI] Appium Drivers: khong kiem tra duoc" -ForegroundColor Red
        $Fail++
    }
} catch {
    Write-Host "  [LOI] Appium Drivers: Appium chua duoc cai dat" -ForegroundColor Red
    $Fail++
}

Test-Tool -Name "Playwright" -Command "npx playwright --version 2>&1" -Required "required"
Test-Tool -Name "k6" -Command "k6 version" -Required "optional"

Write-Host ""
Write-Host "Cong cu iOS (chi macOS):"
if ($IsMacOS) {
    Test-Tool -Name "Xcode" -Command "xcodebuild -version | Select-Object -First 1" -Required "optional"
    Test-Tool -Name "ios-deploy" -Command "ios-deploy --version" -Required "optional"
    Test-Tool -Name "idevice_id" -Command "idevice_id --version 2>&1 | Select-Object -First 1" -Required "optional"
} else {
    Write-Host "  [--]  Bo qua (khong phai macOS)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================="
Write-Host "  Ket qua: $Pass dat, $Fail loi, $Warn tuy chon" -ForegroundColor $(if ($Fail -eq 0) { "Green" } else { "Red" })

if ($Fail -eq 0) {
    Write-Host "  Moi truong san sang!" -ForegroundColor Green
} else {
    Write-Host "  $Fail cong cu bat buoc con thieu." -ForegroundColor Red
    Write-Host ""
    Write-Host "Cai dat cong cu con thieu:"
    Write-Host "  Appium:     npm install -g appium"
    Write-Host "  Drivers:    appium driver install uiautomator2"
    Write-Host "  Playwright: npm install -D @playwright/test; npx playwright install"
    Write-Host "  k6:         winget install k6  (hoac choco install k6)"
    Write-Host "  Java:       winget install Microsoft.OpenJDK.17"
}
Write-Host "==========================================="
Write-Host ""

exit $Fail
