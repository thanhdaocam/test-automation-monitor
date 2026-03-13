# Installation Guide

Step-by-step guide to install the Test Automation Monitor skills.

## Prerequisites

### 1. Claude Code

You need Claude Code installed and configured.

```bash
# Verify Claude Code is working
claude --version
```

### 2. Node.js 20+

```bash
# Check version
node --version   # Should be v20.x or higher

# Install (if missing):
# Windows: winget install OpenJS.NodeJS.LTS
# macOS:   brew install node@20
# Linux:   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs
```

### 3. Java 11+ (for Appium / mobile testing)

```bash
# Check version
java --version

# Install (if missing):
# Windows: winget install Microsoft.OpenJDK.17
# macOS:   brew install openjdk@17
# Linux:   sudo apt install openjdk-17-jdk
```

### 4. Android SDK + ADB (for Android testing)

**Option A: Android Studio (recommended)**
1. Download Android Studio from https://developer.android.com/studio
2. Install and open Android Studio
3. Go to SDK Manager → install "Android SDK Platform-Tools"
4. ADB is included automatically

**Option B: Standalone command-line tools**
1. Download from https://developer.android.com/tools/releases/platform-tools
2. Extract and add to PATH

```bash
# Verify
adb version

# Set ANDROID_HOME environment variable
# Windows (PowerShell):
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", "User")

# macOS/Linux (add to ~/.bashrc or ~/.zshrc):
export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
export ANDROID_HOME=$HOME/Android/Sdk           # Linux
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### 5. Appium 2.0 (for mobile testing)

```bash
# Install Appium globally
npm install -g appium

# Install Android driver
appium driver install uiautomator2

# Install iOS driver (macOS only)
appium driver install xcuitest

# Verify
appium --version
appium driver list --installed
```

### 6. Playwright (for web testing)

```bash
# Install in your project
npm install -D @playwright/test

# Install browsers
npx playwright install

# Or install specific browser only
npx playwright install chromium

# Verify
npx playwright --version
```

### 7. k6 (for performance testing - optional)

```bash
# Windows
winget install k6
# or: choco install k6

# macOS
brew install k6

# Linux (Debian/Ubuntu)
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D68
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Verify
k6 version
```

## Install Skills

### Option A: Clone entire repo (recommended)

```bash
git clone https://github.com/thanhdaocam/test-automation-monitor.git
cd test-automation-monitor
```

Skills are automatically discovered by Claude Code from `.claude/skills/`.

### Option B: Copy skills into existing project

**macOS/Linux:**
```bash
# Clone the repo
git clone https://github.com/thanhdaocam/test-automation-monitor.git

# Copy skills to your project
cp -r test-automation-monitor/.claude/skills/ /path/to/your-project/.claude/skills/

# Optionally copy helper scripts and templates
cp -r test-automation-monitor/scripts/ /path/to/your-project/scripts/
cp -r test-automation-monitor/templates/ /path/to/your-project/templates/
```

**Windows (CMD):**
```cmd
:: Clone the repo
git clone https://github.com/thanhdaocam/test-automation-monitor.git

:: Copy skills to your project
xcopy /E /I test-automation-monitor\.claude\skills your-project\.claude\skills

:: Optionally copy helper scripts and templates
xcopy /E /I test-automation-monitor\scripts your-project\scripts
xcopy /E /I test-automation-monitor\templates your-project\templates
```

**Windows (PowerShell):**
```powershell
# Clone the repo
git clone https://github.com/thanhdaocam/test-automation-monitor.git

# Copy skills to your project
Copy-Item -Recurse -Force test-automation-monitor\.claude\skills\ your-project\.claude\skills\

# Optionally copy helper scripts and templates
Copy-Item -Recurse -Force test-automation-monitor\scripts\ your-project\scripts\
Copy-Item -Recurse -Force test-automation-monitor\templates\ your-project\templates\
```

### Option C: Git submodule

```bash
cd your-project
git submodule add https://github.com/thanhdaocam/test-automation-monitor.git .test-tools
```

**macOS/Linux:** Tạo symlink:
```bash
ln -s .test-tools/.claude/skills .claude/skills
```

**Windows (CMD với quyền Admin):** Tạo symlink:
```cmd
mklink /D .claude\skills .test-tools\.claude\skills
```

**Windows (PowerShell với quyền Admin):**
```powershell
New-Item -ItemType SymbolicLink -Path .claude\skills -Target .test-tools\.claude\skills
```

> **Lưu ý Windows:** Tạo symlink trên Windows yêu cầu quyền Administrator hoặc bật Developer Mode (Cài đặt > Cập nhật & Bảo mật > Dành cho nhà phát triển).

## Verify Installation

Open Claude Code in the project directory and run:

```
> /setup-test-env
```

This will check all prerequisites and report what's installed and what's missing.

Then try:

```
> /monitor
```

This shows a full status dashboard of your testing environment.

## Android Device Setup

### Physical Device

1. Enable **Developer Options** on your phone:
   - Go to Settings → About Phone → tap "Build Number" 7 times
2. Enable **USB Debugging**:
   - Settings → Developer Options → USB Debugging → ON
3. Connect via USB cable
4. Accept the "Allow USB debugging?" prompt on your phone
5. Verify: `adb devices` should show your device

### Android Emulator

1. Open Android Studio → Virtual Device Manager
2. Create a new virtual device (e.g., Pixel 7, API 34)
3. Start the emulator
4. Verify: `adb devices` should show `emulator-5554`

## iOS Device Setup (macOS only)

### Physical Device

1. Install Xcode from the App Store
2. Install command-line tools: `xcode-select --install`
3. Install device tools: `brew install ios-deploy libimobiledevice`
4. Connect iPhone via USB and "Trust" the computer
5. Verify: `idevice_id -l`

### iOS Simulator

1. Open Xcode → Window → Devices and Simulators
2. Or from command line:
   ```bash
   xcrun simctl list devices available
   xcrun simctl boot "iPhone 15"
   ```

> **Important**: iOS testing is NOT possible on Windows. You need a Mac.

## Troubleshooting

### "ADB not found"
- Make sure Android SDK Platform-Tools is installed
- Add `$ANDROID_HOME/platform-tools` to your PATH
- Run `/setup-test-env` to verify

### "Appium driver not found"
```bash
appium driver install uiautomator2
appium driver list --installed
```

### "Device unauthorized"
- Check USB debugging prompt on the device screen
- Tap "Allow" and check "Always allow from this computer"
- If no prompt: `adb kill-server && adb start-server`

### "ECONNREFUSED on port 4723"
- Appium server is not running
- Start it: `/appium start`

### "Playwright browser not found"
```bash
npx playwright install chromium
# Or install all browsers:
npx playwright install
```

### "Java not found" (Appium needs it)
- Install Java 11+: `winget install Microsoft.OpenJDK.17`
- Make sure `JAVA_HOME` is set and Java is in PATH

## Hướng dẫn dành riêng cho Windows

### Script PowerShell thay thế

Dự án bao gồm các script PowerShell tương đương cho Windows:

| Script Bash (macOS/Linux) | Script PowerShell (Windows) | Mô tả |
|---|---|---|
| `scripts/check-env.sh` | `scripts/check-env.ps1` | Kiểm tra môi trường |
| `scripts/parse-playwright-results.sh` | `scripts/parse-playwright-results.ps1` | Phân tích kết quả Playwright |

**Chạy script PowerShell:**
```powershell
# Cho phép chạy script (chỉ cần 1 lần)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Kiểm tra môi trường
pwsh scripts/check-env.ps1

# Phân tích kết quả Playwright
pwsh scripts/parse-playwright-results.ps1 test-results/playwright-results.json
```

### Yêu cầu Git Bash cho script .sh

Các script `.sh` khác yêu cầu **Git Bash** (được cài sẵn với Git for Windows):

```bash
# Chạy bằng Git Bash
bash scripts/parse-k6-results.sh test-results/k6-output.json
bash scripts/parse-wdio-results.sh test-results/wdio-results.json
```

### Bảng tương đương lệnh Windows

| Lệnh Unix | Windows CMD | PowerShell | Git Bash |
|---|---|---|---|
| `which node` | `where node` | `Get-Command node` | `which node` |
| `lsof -i :4723` | `netstat -ano \| findstr :4723` | `Get-NetTCPConnection -LocalPort 4723` | `lsof -i :4723` |
| `kill -9 <PID>` | `taskkill /PID <PID> /F` | `Stop-Process -Id <PID> -Force` | `kill -9 <PID>` |
| `grep pattern file` | `findstr "pattern" file` | `Select-String -Pattern "pattern" file` | `grep pattern file` |
| `/tmp/file.log` | `%TEMP%\file.log` | `$env:TEMP\file.log` | `/tmp/file.log` |
| `$HOME` | `%USERPROFILE%` | `$env:USERPROFILE` | `$HOME` |
| `echo $ANDROID_HOME` | `echo %ANDROID_HOME%` | `$env:ANDROID_HOME` | `echo $ANDROID_HOME` |
| `find . -name "*.ts"` | `dir /s /b *.ts` | `Get-ChildItem -Recurse -Filter *.ts` | `find . -name "*.ts"` |

### Cách chạy khuyên dùng trên Windows

**Ưu tiên 1 — Git Bash:** Nếu đã cài Git for Windows, mở **Git Bash** và mọi lệnh Unix trong tài liệu đều hoạt động trực tiếp.

**Ưu tiên 2 — PowerShell 7+ (pwsh):** Dùng cho các script `.ps1` có sẵn. Cài đặt: `winget install Microsoft.PowerShell`.

**Ưu tiên 3 — Windows CMD:** Sử dụng bảng tương đương ở trên để chuyển đổi lệnh.

> **Lưu ý quan trọng:** Kiểm thử iOS (iPhone/iPad) **không khả dụng trên Windows**. Chỉ có thể kiểm thử iOS trên macOS.

