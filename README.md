# Test Automation Monitor

Bộ **Claude Code Skills** để monitor và quản lý automation test trên **Web**, **Android**, **iOS**, và **WebView** - chạy trực tiếp trong Claude Code bằng slash commands.

## Features

9 slash commands cho toàn bộ automation test workflow:

| Command | Mô tả |
|---------|-------|
| `/setup-test-env` | Kiểm tra & cài đặt Node.js, Java, ADB, Appium, Playwright, k6 |
| `/devices` | List Android/iOS devices đang kết nối |
| `/appium` | Start / stop / check status Appium server |
| `/install-apk` | Cài APK lên Android device |
| `/run-test` | Chạy Playwright hoặc k6 tests |
| `/mobile-test` | Chạy WebdriverIO + Appium tests trên mobile |
| `/test-report` | Xem kết quả test, thống kê pass/fail |
| `/monitor` | Tổng quan status: devices, services, tests |
| `/scaffold-test` | Tạo test project mới từ template |

### Multi-Platform Support

- **Web**: Playwright (Chrome, Firefox, Safari)
- **Android** (.apk): Appium 2.0 + WebdriverIO + UiAutomator2
- **iOS** (.ipa): Appium 2.0 + WebdriverIO + XCUITest
- **WebView**: Appium context switching (NATIVE ↔ WEBVIEW)
- **Performance**: k6 load testing

## Quick Start

### 1. Clone repo

```bash
git clone https://github.com/thanhdaocam/test-automation-monitor.git
```

### 2. Copy skills vào project của bạn

```bash
# Copy thư mục .claude/skills/ vào project bạn muốn test
cp -r test-automation-monitor/.claude/skills/ your-project/.claude/skills/

# Hoặc copy toàn bộ (skills + templates + scripts)
cp -r test-automation-monitor/.claude/ your-project/.claude/
cp -r test-automation-monitor/scripts/ your-project/scripts/
cp -r test-automation-monitor/templates/ your-project/templates/
```

### 3. Mở Claude Code và dùng

```bash
cd your-project
claude

# Trong Claude Code:
> /setup-test-env          # Kiểm tra environment
> /devices                  # Xem devices
> /run-test login.spec.ts   # Chạy web test
> /mobile-test app.mobile.ts --device emulator-5554   # Chạy mobile test
> /test-report --last       # Xem kết quả
```

## Prerequisites

### Bắt buộc

```bash
# Claude Code
claude --version

# Node.js 20+
node --version
```

### Cho Web Testing

```bash
# Playwright
npm install -D @playwright/test
npx playwright install
```

### Cho Android Testing

```bash
# Java 11+
java --version

# Android SDK + ADB
adb --version
# Set ANDROID_HOME environment variable

# Appium 2.0
npm install -g appium
appium driver install uiautomator2
```

### Cho iOS Testing (cần macOS)

```bash
# Xcode
xcode-select --install

# Appium XCUITest driver
appium driver install xcuitest

# Device tools
brew install ios-deploy libimobiledevice
```

> **Note**: iOS testing không chạy được trên Windows. Cần Mac hoặc cloud service.

### Cho Performance Testing

```bash
# k6
# Windows: choco install k6 / winget install k6
# macOS: brew install k6
k6 version
```

Hoặc chạy `/setup-test-env` để tự động kiểm tra tất cả.

## Project Structure

```
test-automation-monitor/
├── .claude/
│   └── skills/                     # Claude Code Skills
│       ├── setup-test-env/SKILL.md # Kiểm tra environment
│       ├── devices/SKILL.md        # List devices
│       ├── appium/SKILL.md         # Appium server control
│       ├── install-apk/SKILL.md    # Install APK
│       ├── run-test/SKILL.md       # Chạy web/perf tests
│       ├── mobile-test/SKILL.md    # Chạy mobile tests
│       ├── test-report/SKILL.md    # Xem test results
│       ├── monitor/SKILL.md        # Status dashboard
│       └── scaffold-test/SKILL.md  # Tạo project từ template
│
├── scripts/                        # Helper scripts
│   ├── check-env.sh
│   ├── parse-playwright-results.sh
│   ├── parse-wdio-results.sh
│   └── parse-k6-results.sh
│
├── templates/                      # Test config templates
│   ├── playwright.config.ts
│   ├── wdio.conf.ts
│   ├── sample.spec.ts
│   ├── sample.mobile.ts
│   └── sample.k6.js
│
├── examples/                       # Complete examples
│   ├── web-test-example/
│   ├── mobile-test-example/
│   └── perf-test-example/
│
├── CLAUDE.md                       # Project conventions
├── PLAN.md                         # Architecture & decisions
├── TODO.md                         # Task tracking
├── INSTALL.md                      # Detailed installation
├── SKILLS.md                       # Skills reference
└── README.md                       # This file
```

## Usage Examples

### Kiểm tra environment

```
> /setup-test-env

✓ Node.js      v20.11.0
✓ Java         17.0.2
✓ ADB          34.0.5
✓ Appium       2.5.1
  - uiautomator2  2.34.0
✓ Playwright   1.42.0
✓ k6           0.49.0
```

### List devices

```
> /devices

Connected Devices:
┌──────────────────┬─────────────┬────────────┬──────────┐
│ Device ID        │ Model       │ OS         │ Status   │
├──────────────────┼─────────────┼────────────┼──────────┤
│ emulator-5554    │ Pixel 7     │ Android 14 │ online   │
│ R5CT32XXXXX      │ Galaxy S23  │ Android 13 │ online   │
└──────────────────┴─────────────┴────────────┴──────────┘
```

### Chạy web test

```
> /run-test tests/login.spec.ts

Running Playwright tests...

Results:
  ✓ should display login form          (1.2s)
  ✓ should login with valid creds      (2.4s)
  ✗ should show error on invalid pass  (1.8s)
    Error: Expected "Invalid password" but got "Error occurred"
    at login.spec.ts:42

Summary: 2 passed, 1 failed, 0 skipped (5.4s)
```

### Chạy mobile test

```
> /mobile-test tests/app-login.mobile.ts --device emulator-5554

Starting Appium server... ✓ (port 4723)
Connecting to emulator-5554... ✓

Running WebdriverIO tests...

Results:
  ✓ should open app                    (3.1s)
  ✓ should login on native screen      (4.2s)
  ✓ should switch to WebView           (2.8s)
  ✓ should interact with web content   (1.5s)

Summary: 4 passed, 0 failed (11.6s)
```

### Xem báo cáo

```
> /test-report --last

Last Run: 2026-03-03 14:30:00
Suite: login-tests
Platform: Android (emulator-5554)

Results: 6 passed, 1 failed, 0 skipped
Duration: 17.0s
Pass Rate: 85.7%

Failed Tests:
  ✗ login.spec.ts:42 - should show error on invalid pass
    Error: Expected "Invalid password" but got "Error occurred"
```

### System monitor

```
> /monitor

═══ Test Automation Monitor ═══

Services:
  Appium Server    ✓ running (port 4723)
  ADB Server       ✓ running

Devices:
  emulator-5554    ✓ online  (Pixel 7, Android 14)
  R5CT32XXXXX      ✓ online  (Galaxy S23, Android 13)

Last Test Run:
  Suite: smoke-tests
  Status: PASSED (6/6)
  Time: 5 minutes ago

Environment:
  Node.js: v20.11.0
  Appium: 2.5.1
  Playwright: 1.42.0
  k6: 0.49.0
```

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    CLAUDE CODE                           │
│                                                          │
│  User: /run-test login.spec.ts                          │
│       │                                                  │
│       ▼                                                  │
│  ┌─────────────┐                                        │
│  │  SKILL.md   │  ← Prompt instructions                │
│  └──────┬──────┘                                        │
│         │                                                │
│         ▼                                                │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │    Bash     │    │    Read     │    │    Grep     │  │
│  │  (execute)  │    │  (results)  │    │  (search)   │  │
│  └──────┬──────┘    └─────────────┘    └─────────────┘  │
│         │                                                │
└─────────┼────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────┐
│            TEST ENGINES                  │
│                                          │
│  ┌──────────┐  ┌──────────┐  ┌───────┐  │
│  │Playwright│  │WebdriverIO│  │  k6   │  │
│  └────┬─────┘  └────┬─────┘  └───┬───┘  │
│       │              │            │       │
│       ▼              ▼            ▼       │
│   Browser        Appium       HTTP       │
│                  Server       Load       │
│                     │                     │
│              ┌──────┴──────┐              │
│              ▼             ▼              │
│          Android         iOS             │
│          Device         Device           │
└─────────────────────────────────────────┘
```

## License

by ThanhDaoCam

## Related Documentation

- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code)
- [Appium 2.0 Docs](https://appium.io/docs/en/latest/)
- [WebdriverIO Docs](https://webdriver.io)
- [Playwright Docs](https://playwright.dev)
- [k6 Docs](https://k6.io/docs/)
