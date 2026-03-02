# Test Automation Monitor

A Windows desktop application for monitoring and managing automation tests across **Web**, **Android**, **iOS**, and **WebView** platforms.

Built with **Tauri v2** (Rust) + **React** (TypeScript).

## Features

- **Realtime Dashboard** - Live monitoring of test execution with pass/fail charts
- **Multi-Platform Testing**
  - Web: Playwright
  - Android (.apk): Appium 2.0 + WebdriverIO
  - iOS (.ipa): Appium 2.0 + WebdriverIO
  - WebView (hybrid apps): Appium context switching
  - Performance: k6
- **Device Management** - Auto-detect connected Android/iOS devices
- **Test Case Management** - CRUD suites/cases with tags, priority, platform assignment
- **Scheduled Runs** - Cron-based automatic test execution
- **CI/CD Integration** - REST API + webhooks (GitHub Actions, GitLab CI, Jenkins)
- **Notifications** - Slack, Email, Discord, Microsoft Teams
- **Reports & Analytics** - Trend analysis, flaky test detection, export (HTML/PDF/JUnit XML)

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Desktop | Tauri v2 (Rust backend) |
| Frontend | React 18 + TypeScript + Vite |
| UI | Shadcn/ui + Tailwind CSS v4 |
| Charts | Recharts |
| State | Zustand |
| Database | SQLite (local) |
| Web Tests | Playwright |
| Mobile Tests | Appium 2.0 + WebdriverIO |
| Perf Tests | k6 |
| CI/CD API | Axum (embedded HTTP server) |

## Prerequisites

Before starting, make sure you have these installed:

### Required

```bash
# Node.js 20+
node --version   # v20.x or higher

# pnpm (recommended) or npm
pnpm --version

# Rust toolchain
rustc --version
cargo --version

# Java 11+ (required by Appium)
java --version
```

### For Android Testing

```bash
# Android SDK + ADB
# Option 1: Install Android Studio (includes SDK + ADB)
# Option 2: Install standalone command-line tools
adb --version

# Set environment variable
# ANDROID_HOME=C:\Users\<you>\AppData\Local\Android\Sdk

# Appium 2.0 + UiAutomator2 driver
npm install -g appium
appium driver install uiautomator2
```

### For iOS Testing (requires macOS)

```bash
# Xcode (from App Store)
xcode-select --install

# Appium XCUITest driver
appium driver install xcuitest

# Device tools
brew install ios-deploy libimobiledevice
```

> **Note**: iOS testing is NOT possible on Windows natively. Use a Mac or cloud services (BrowserStack, SauceLabs).

### For Performance Testing

```bash
# k6 - download from https://k6.io/docs/get-started/installation/
k6 version
```

## Getting Started

### 1. Clone & Install

```bash
git clone <repo-url>
cd test-automation-monitor

# Install frontend dependencies
pnpm install

# Rust dependencies are auto-installed on first build
```

### 2. Development

```bash
# Start dev server (Tauri + Vite HMR)
pnpm tauri dev
```

### 3. Build for Production

```bash
# Build Windows installer (.msi / .exe)
pnpm tauri build
```

## Project Structure

```
test-automation-monitor/
├── src-tauri/              # Rust backend
│   ├── src/
│   │   ├── commands/       # Tauri IPC commands
│   │   ├── services/       # Business logic
│   │   └── models/         # Data structures
│   ├── migrations/         # SQLite migrations
│   └── Cargo.toml
├── src/                    # React frontend
│   ├── routes/             # Page components
│   ├── components/         # UI components
│   ├── hooks/              # Custom React hooks
│   ├── stores/             # Zustand stores
│   └── lib/                # Utilities & types
├── tests/                  # Test scripts
│   ├── web/                # Playwright tests
│   ├── mobile/             # WebdriverIO + Appium tests
│   └── performance/        # k6 scripts
├── PLAN.md                 # Detailed implementation plan
└── README.md               # This file
```

## Usage

### Running Tests from UI

1. **Connect devices** - Plug in Android/iOS device or start emulator
2. **Add test suite** - Go to Test Suites → Create New
3. **Add test cases** - Link to your Playwright/WebdriverIO/k6 scripts
4. **Run** - Click Run button, watch results in realtime

### CI/CD Integration

The app runs an embedded REST API server (default port `9876`):

```bash
# Trigger a test suite
curl -X POST http://localhost:9876/api/trigger \
  -H "Content-Type: application/json" \
  -d '{"suite_id": "your-suite-id"}'

# Check status
curl http://localhost:9876/api/status/{run_id}

# Get results
curl http://localhost:9876/api/results/{run_id}
```

### CLI Headless Mode

```bash
# Run tests without GUI
test-monitor --headless --suite=smoke --output=junit.xml
```

### Example: WebdriverIO Mobile Test

```typescript
// tests/mobile/login.mobile.ts
describe('Login Flow', () => {
    it('should login on Android app', async () => {
        const username = await $('~usernameInput');
        await username.setValue('testuser');

        const password = await $('~passwordInput');
        await password.setValue('password123');

        const loginBtn = await $('~loginButton');
        await loginBtn.click();

        // Switch to WebView inside the app
        const contexts = await driver.getContexts();
        await driver.switchContext('WEBVIEW_com.example.app');

        // Now use web selectors
        const welcome = await $('h1');
        expect(await welcome.getText()).toBe('Welcome');
    });
});
```

### Example: GitHub Actions Integration

```yaml
name: Mobile Tests
on: [push]
jobs:
  test:
    runs-on: self-hosted  # needs device access
    steps:
      - uses: actions/checkout@v4

      - name: Trigger tests
        run: |
          RUN_ID=$(curl -s -X POST http://localhost:9876/api/trigger \
            -H "Content-Type: application/json" \
            -d '{"suite_id": "mobile-smoke"}' | jq -r '.run_id')
          echo "RUN_ID=$RUN_ID" >> $GITHUB_ENV

      - name: Wait for results
        run: |
          while true; do
            STATUS=$(curl -s http://localhost:9876/api/status/$RUN_ID | jq -r '.status')
            [ "$STATUS" = "passed" ] || [ "$STATUS" = "failed" ] && break
            sleep 10
          done
          curl -s http://localhost:9876/api/results/$RUN_ID > results.json

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: results.json
```

## Notification Setup

| Channel | What you need |
|---------|--------------|
| Slack | Incoming Webhook URL |
| Discord | Webhook URL |
| Teams | Webhook URL |
| Email | SMTP host, port, username, password |

Configure in **Settings → Notifications** within the app.

## Architecture

```
┌─────────────────────────────────────────────┐
│           TAURI v2 APPLICATION              │
│                                             │
│  ┌─────────────┐    ┌───────────────────┐   │
│  │   React UI  │◄──►│   Rust Backend    │   │
│  │  (WebView)  │IPC │                   │   │
│  └─────────────┘    │  ┌─────────────┐  │   │
│                     │  │ Orchestrator│  │   │
│                     │  └──────┬──────┘  │   │
│                     │         │         │   │
│                     │    ┌────┼────┐    │   │
│                     │    ▼    ▼    ▼    │   │
│                     │   PW  WDIO  k6   │   │
│                     │                   │   │
│                     │  ┌─────────────┐  │   │
│                     │  │   SQLite    │  │   │
│                     │  └─────────────┘  │   │
│                     │  ┌─────────────┐  │   │
│                     │  │ Axum (API)  │  │   │
│                     │  └─────────────┘  │   │
│                     └───────────────────┘   │
└─────────────────────────────────────────────┘
         │              │              │
    ┌────▼────┐    ┌────▼────┐    ┌───▼────┐
    │ Android │    │   iOS   │    │Browser │
    │ Device  │    │ Device  │    │        │
    └─────────┘    └─────────┘    └────────┘
```

## License

MIT

## Related Documentation

- [Tauri v2 Docs](https://v2.tauri.app)
- [Appium 2.0 Docs](https://appium.io/docs/en/latest/)
- [WebdriverIO Docs](https://webdriver.io)
- [Playwright Docs](https://playwright.dev)
- [k6 Docs](https://k6.io/docs/)
