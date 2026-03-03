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

```bash
# Clone the repo
git clone https://github.com/thanhdaocam/test-automation-monitor.git

# Copy skills to your project
cp -r test-automation-monitor/.claude/skills/ /path/to/your-project/.claude/skills/

# Optionally copy helper scripts and templates
cp -r test-automation-monitor/scripts/ /path/to/your-project/scripts/
cp -r test-automation-monitor/templates/ /path/to/your-project/templates/
```

### Option C: Git submodule

```bash
cd your-project
git submodule add https://github.com/thanhdaocam/test-automation-monitor.git .test-tools

# Symlink skills
ln -s .test-tools/.claude/skills .claude/skills
```

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
