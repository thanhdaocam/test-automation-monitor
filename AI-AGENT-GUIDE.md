# AI Agent Guide - Test Automation Skill Router

> **Purpose**: This document is a structured reference for AI agents. Given a user's test request, use this guide to determine the correct skill(s) to invoke, in what order, and with what parameters.

---

## Quick Decision Table

| User wants to... | Primary Skill | Pre-requisite Skills | Arguments |
|---|---|---|---|
| Check environment setup | `/setup-test-env` | None | (none) |
| See connected devices | `/devices` | None | (none) |
| Start Appium server | `/appium` | None | `start` |
| Stop Appium server | `/appium` | None | `stop` |
| Check Appium status | `/appium` | None | `status` |
| Install APK on device | `/install-apk` | `/devices` (verify target) | `<apk-path> [device-id]` |
| Run web test (Playwright) | `/run-test` | None | `<file.spec.ts> [--headed] [--grep] [--workers]` |
| Run performance test (k6) | `/run-test` | None | `<file.k6.js>` |
| Run mobile test (Appium) | `/mobile-test` | `/appium start`, `/devices` | `<file.mobile.ts> [--device] [--platform] [--app]` |
| See test results | `/test-report` | None | `[--last] [--failures-only] [--suite]` |
| View system dashboard | `/monitor` | None | (none) |
| Create new test project | `/scaffold-test` | None | `web \| mobile \| performance \| all [--dir]` |

---

## Skill Routing Logic

Use this decision tree to select the correct skill:

```
USER REQUEST
│
├── About environment/setup/install?
│   └── /setup-test-env
│
├── About devices (list, check, connect)?
│   └── /devices
│
├── About Appium server (start, stop, status)?
│   └── /appium <subcommand>
│
├── About installing an app (.apk)?
│   └── /install-apk <path> [device]
│
├── About running tests?
│   ├── Web/browser test? (.spec.ts, .test.ts, Playwright)
│   │   └── /run-test <file>
│   ├── Performance/load test? (.k6.js, k6)
│   │   └── /run-test <file>
│   └── Mobile/native/WebView test? (.mobile.ts, Appium, WDIO)
│       └── /mobile-test <file>
│
├── About test results/reports?
│   └── /test-report [flags]
│
├── About system status/overview?
│   └── /monitor
│
└── About creating/scaffolding tests?
    └── /scaffold-test <type>
```

---

## Detailed Skill Specifications

### 1. `/setup-test-env`

**When to use**:
- User says: "check my environment", "what's installed", "setup", "prerequisites", "is everything ready"
- First time using the toolkit
- Something is broken and tools may be missing

**What it checks**:
- Node.js (>= 20), Java (>= 11), ADB, Appium, Appium drivers (uiautomator2, xcuitest), Playwright, k6, ANDROID_HOME

**Outputs**: Table with status (installed/missing), version, and install instructions for missing tools.

**Follow-up skills**: `/devices`, `/appium start`, `/scaffold-test`

---

### 2. `/devices`

**When to use**:
- User says: "list devices", "what phones are connected", "show emulators", "check my device"
- Before running mobile tests (pre-check)
- User asks about device status (online/offline)

**What it does**: Runs `adb devices -l` and parses output into a formatted table showing Device ID, Platform, Model, OS Version, Status.

**Outputs**: Device table with count summary.

**Follow-up skills**: `/install-apk`, `/mobile-test`

**Key behavior**:
- Detects both physical devices and emulators
- Reports "No ADB found" if Android SDK not installed
- iOS detection only works on macOS

---

### 3. `/appium`

**When to use**:
- User says: "start appium", "stop appium", "is appium running", "appium status"
- Before mobile testing (if `/mobile-test` doesn't auto-start it)
- User wants to manage Appium manually

**Subcommands**:
| Subcommand | Trigger phrases |
|---|---|
| `start` | "start appium", "launch appium", "run appium" |
| `stop` | "stop appium", "kill appium", "shut down appium" |
| `status` | "appium status", "is appium running", "check appium" |
| `install-drivers` | "install appium drivers", "setup appium drivers" |

**Arguments**:
- `--port <n>`: Custom port (default: 4723)

**Follow-up skills**: `/mobile-test`, `/devices`

---

### 4. `/install-apk`

**When to use**:
- User says: "install apk", "deploy app", "push apk to device", "install app on phone/emulator"
- User provides a `.apk` file path
- Before mobile testing when app needs to be deployed

**Required**: APK file path
**Optional**: Device ID (auto-selects if only 1 device connected)

**Pre-check**: Run `/devices` first if unsure which device to target.

**Error scenarios**:
- No device connected → suggest `/devices` or connecting a device
- Multiple devices, no ID specified → list devices and ask user to choose
- APK path invalid → ask for correct path
- Install fails (INSTALL_FAILED_*) → report specific ADB error code

---

### 5. `/run-test`

**When to use**:
- User wants to run **web browser tests** (Playwright)
- User wants to run **performance/load tests** (k6)
- User says: "run test", "execute test", "test this", "run playwright", "run k6", "load test"

**DO NOT use for**: Mobile/native app tests → use `/mobile-test` instead

**Auto-detection rules**:
| File pattern | Framework | Command generated |
|---|---|---|
| `*.spec.ts`, `*.spec.js` | Playwright | `npx playwright test <file> --reporter=json` |
| `*.test.ts`, `*.test.js` | Playwright | `npx playwright test <file> --reporter=json` |
| `*.k6.js`, `*.k6.ts` | k6 | `k6 run <file> --out json=results.json` |
| No file specified | Playwright | `npx playwright test --reporter=json` (all tests) |

**Arguments**:
| Argument | When to use |
|---|---|
| `--headed` | User wants to see the browser during test |
| `--debug` | User wants step-by-step debugging |
| `--grep "pattern"` | User wants to filter tests by name |
| `--workers <n>` | User wants parallel execution control |

**Follow-up skills**: `/test-report`

---

### 6. `/mobile-test`

**When to use**:
- User wants to test a **mobile app** (Android/iOS native or hybrid)
- User wants to test **WebView** inside a mobile app
- User says: "mobile test", "test on phone", "test apk", "appium test", "test on device", "test on emulator"
- Test file has `.mobile.ts` extension

**DO NOT use for**: Web browser tests → use `/run-test` instead

**Pre-requisite chain** (auto-handled but good to verify):
1. Device connected? → if not, prompt user (`/devices`)
2. Appium running? → if not, auto-starts it
3. App installed? → if `--app` flag provided, installs first

**Arguments**:
| Argument | When to use |
|---|---|
| `<test-file>` | Always required |
| `--device <id>` | Multiple devices connected, user specifies which one |
| `--platform android\|ios` | Default is android; use ios if user specifies iPhone/iPad |
| `--app <apk/ipa>` | Install app before testing |

**Test type detection**:
| User describes... | What it means |
|---|---|
| "native app test" | Test using native selectors (accessibility id, xpath) |
| "WebView test" | Test with context switching (NATIVE_APP ↔ WEBVIEW) |
| "hybrid app test" | Same as WebView test |

**Follow-up skills**: `/test-report`

---

### 7. `/test-report`

**When to use**:
- After any test execution (`/run-test` or `/mobile-test`)
- User says: "show results", "test report", "what failed", "test summary", "show failures"
- User wants to analyze previous test runs

**Arguments**:
| Argument | When to use |
|---|---|
| `--last` | Default; shows most recent results |
| `--failures-only` | User only cares about what failed |
| `--file <path>` | User specifies a specific report file |
| `--suite <name>` | User wants to filter by test suite |

**Supported report formats** (auto-detected):
- Playwright JSON (`playwright-results.json`)
- WebdriverIO JSON (`wdio-results.json`)
- k6 JSON (`k6-results.json`)
- JUnit XML (`*.xml`)

**Outputs**: Pass/fail counts, duration, failure details (test name, error message, file:line), comparison with previous run if available.

---

### 8. `/monitor`

**When to use**:
- User says: "status", "dashboard", "overview", "what's running", "health check", "monitor"
- User wants a quick snapshot of everything at once
- Start of a testing session

**What it shows**:
- Services: Appium server status, ADB server status
- Devices: Connected count and details
- Environment: Tool versions (Node.js, Java, Appium, Playwright, k6)
- Last test run: Suite name, pass/fail, duration, time ago

**Follow-up skills**: Depends on what's missing/broken in the dashboard output.

---

### 9. `/scaffold-test`

**When to use**:
- User says: "create test project", "scaffold", "new test", "generate test template", "init test"
- User is starting from scratch with no existing test files
- User wants sample tests to learn from

**Type selection**:
| User says... | Type argument |
|---|---|
| "web test", "playwright test", "browser test" | `web` |
| "mobile test", "appium test", "phone test" | `mobile` |
| "performance test", "load test", "k6 test" | `performance` |
| "all tests", "everything", "full setup" | `all` |

**Arguments**:
- `--dir <path>`: Custom output directory (default: current directory)

**What it creates**:
| Type | Files created |
|---|---|
| `web` | `tests/web/*.spec.ts`, `playwright.config.ts` |
| `mobile` | `tests/mobile/*.mobile.ts`, `wdio.conf.ts` |
| `performance` | `tests/performance/*.k6.js` |
| `all` | All of the above |

**Follow-up skills**: `/run-test` (web), `/mobile-test` (mobile), `/run-test` (performance)

---

## Common Workflow Chains

### Workflow 1: First-time Setup
```
/setup-test-env → /scaffold-test all → /monitor
```
**Trigger**: User is new, mentions "first time", "getting started", "setup everything"

### Workflow 2: Web Testing
```
/run-test <file.spec.ts> → /test-report
```
**Trigger**: User mentions "web test", "playwright", "browser test", specific `.spec.ts` file

### Workflow 3: Mobile Testing (Full)
```
/devices → /appium start → /install-apk <path> → /mobile-test <file> → /test-report
```
**Trigger**: User mentions "mobile test", "test on phone", "test apk", specific `.mobile.ts` file

### Workflow 4: Mobile Testing (Quick)
```
/mobile-test <file> --app <apk> → /test-report
```
**Trigger**: Same as above but `/mobile-test` handles Appium start + device detection automatically

### Workflow 5: Performance Testing
```
/run-test <file.k6.js> → /test-report
```
**Trigger**: User mentions "load test", "performance test", "stress test", specific `.k6.js` file

### Workflow 6: Status Check
```
/monitor
```
**Trigger**: User mentions "status", "overview", "what's running", "check everything"

### Workflow 7: Debug Failing Tests
```
/test-report --failures-only → /run-test <failing-test> --debug
```
**Trigger**: User mentions "why did tests fail", "debug failure", "what's broken"

---

## Test Function → Skill Mapping

This section maps specific test functions/scenarios to the exact skill and approach.

### Web Application Functions

| Test Function | Skill | Test File Pattern | Key Approach |
|---|---|---|---|
| Login/Authentication | `/run-test` | `login.spec.ts` | Fill form, submit, assert redirect/session |
| Registration | `/run-test` | `register.spec.ts` | Fill multi-field form, verify account creation |
| Form Validation | `/run-test` | `form-validation.spec.ts` | Submit invalid data, assert error messages |
| Search | `/run-test` | `search.spec.ts` | Input query, verify filtered results |
| Navigation/Routing | `/run-test` | `navigation.spec.ts` | Click links, assert URL changes |
| CRUD Operations | `/run-test` | `crud.spec.ts` | Create→Read→Update→Delete, verify each step |
| File Upload | `/run-test` | `upload.spec.ts` | `setInputFiles()`, verify upload success |
| Responsive Design | `/run-test` | `responsive.spec.ts` | `setViewportSize()`, assert layout changes |
| API Integration | `/run-test` | `api.spec.ts` | `request.get/post()`, assert status+body |
| Accessibility | `/run-test` | `a11y.spec.ts` | Axe integration or manual aria checks |
| Cross-browser | `/run-test` | any `.spec.ts` | Config multiple browsers in `playwright.config.ts` |
| Visual Regression | `/run-test` | `visual.spec.ts` | `toHaveScreenshot()` for pixel comparison |
| Auth Flows (OAuth/SSO) | `/run-test` | `oauth.spec.ts` | Handle redirects, mock providers if needed |
| Shopping Cart / E-commerce | `/run-test` | `cart.spec.ts` | Add items, verify total, checkout flow |
| Multi-step Wizard | `/run-test` | `wizard.spec.ts` | Navigate steps, verify state persistence |

### Mobile Application Functions

| Test Function | Skill | Test File Pattern | Key Approach |
|---|---|---|---|
| App Launch | `/mobile-test` | `launch.mobile.ts` | Assert app activity/package loads |
| Mobile Login | `/mobile-test` | `login.mobile.ts` | Find elements by accessibility id, fill & submit |
| Mobile Navigation | `/mobile-test` | `nav.mobile.ts` | Tap tabs/hamburger menu, assert screens |
| Mobile Forms | `/mobile-test` | `form.mobile.ts` | Fill inputs, handle keyboard, submit |
| WebView Testing | `/mobile-test` | `webview.mobile.ts` | `driver.switchContext('WEBVIEW_*')`, then web selectors |
| Push Notifications | `/mobile-test` | `notifications.mobile.ts` | Open notification shade, verify and tap notification |
| Gestures: Swipe | `/mobile-test` | `swipe.mobile.ts` | `driver.action('pointer')` with move coordinates |
| Gestures: Scroll | `/mobile-test` | `scroll.mobile.ts` | UiScrollable or `driver.action('pointer')` |
| Gestures: Pinch/Zoom | `/mobile-test` | `zoom.mobile.ts` | Two-pointer action sequences |
| Gestures: Long Press | `/mobile-test` | `longpress.mobile.ts` | `action.pause(2000)` between down and up |
| Camera / Permissions | `/mobile-test` | `permissions.mobile.ts` | `autoGrantPermissions: true` in capabilities |
| Deep Links | `/mobile-test` | `deeplink.mobile.ts` | `driver.url('myapp://path')` |
| Offline Mode | `/mobile-test` | `offline.mobile.ts` | Toggle airplane mode via ADB, verify app behavior |
| App Update Flow | `/mobile-test` | `update.mobile.ts` | Install old → verify → install new → verify migration |
| Biometric Auth | `/mobile-test` | `biometric.mobile.ts` | Emulator fingerprint simulation via ADB |

### Performance Test Functions

| Test Function | Skill | Test File Pattern | Key Approach |
|---|---|---|---|
| Load Testing | `/run-test` | `load.k6.js` | Ramp up VUs, sustain, ramp down |
| Stress Testing | `/run-test` | `stress.k6.js` | Push beyond normal load to find breaking point |
| Spike Testing | `/run-test` | `spike.k6.js` | Sudden burst of traffic |
| Soak/Endurance Testing | `/run-test` | `soak.k6.js` | Extended duration at moderate load |
| API Endpoint Testing | `/run-test` | `api-perf.k6.js` | Target specific endpoints, check response times |
| Threshold Validation | `/run-test` | `*.k6.js` | Define thresholds in k6 options |
| Custom Metrics | `/run-test` | `*.k6.js` | Use `Counter`, `Trend`, `Rate`, `Gauge` |

### Cross-Platform Functions

| Test Function | Skills (in order) | Approach |
|---|---|---|
| Web + Mobile same feature | `/run-test` then `/mobile-test` | Test same functionality on both platforms |
| API + UI verification | `/run-test` (API) then `/run-test` (UI) | Verify API response matches UI display |
| Install + Test + Report | `/install-apk` → `/mobile-test` → `/test-report` | Full mobile test cycle |
| Full regression suite | `/run-test` (all web) → `/mobile-test` (all mobile) → `/test-report` | Comprehensive testing |

---

## Parameter Selection Guide

### How to determine `--platform`
| User mentions... | Value |
|---|---|
| Android, phone, Samsung, Pixel, emulator, APK | `android` |
| iOS, iPhone, iPad, simulator, IPA | `ios` |
| (not specified) | `android` (default) |

### How to determine `--headed`
| User mentions... | Use `--headed`? |
|---|---|
| "show browser", "watch test", "see what happens", "visual" | Yes |
| "debug", "step through" | Yes (also add `--debug`) |
| (not specified) | No (headless is faster) |

### How to determine `--workers`
| User mentions... | Value |
|---|---|
| "fast", "parallel", "speed up" | `--workers 4` or higher |
| "sequential", "one at a time", "debug" | `--workers 1` |
| (not specified) | Auto (Playwright decides) |

### How to determine `--grep`
| User mentions... | Value |
|---|---|
| "only login tests" | `--grep "login"` |
| "smoke tests" | `--grep "@smoke"` |
| "skip slow tests" | `--grep-invert "slow"` (Playwright flag) |

---

## Error Handling Decision Tree

```
Error occurred
│
├── "command not found" (node, java, adb, appium, k6)
│   └── Suggest: /setup-test-env
│
├── "no devices/emulators found"
│   └── Suggest: /devices → connect device or start emulator
│
├── "ECONNREFUSED :4723" (Appium not running)
│   └── Suggest: /appium start
│
├── "INSTALL_FAILED_*" (APK install error)
│   ├── INSTALL_FAILED_ALREADY_EXISTS → add -r flag (reinstall)
│   ├── INSTALL_FAILED_INSUFFICIENT_STORAGE → free space on device
│   ├── INSTALL_FAILED_INVALID_APK → verify APK file
│   └── Other → report exact error to user
│
├── "browser not found" (Playwright)
│   └── Run: npx playwright install
│
├── "no test files found"
│   └── Suggest: /scaffold-test <type>
│
├── "test failed" (assertion error)
│   └── Suggest: /test-report --failures-only → then /run-test <file> --debug
│
├── "timeout" (test or connection)
│   ├── Mobile test timeout → check device connection, increase timeout
│   ├── Web test timeout → check if site is accessible
│   └── Appium timeout → restart: /appium stop → /appium start
│
└── Unknown error
    └── Suggest: /monitor (check overall system health)
```

---

## Context Clues for Skill Selection

Use these keywords/patterns from user input to determine the correct skill:

### Keywords → Skill Mapping

```
"setup", "install", "prerequisites", "check env"     → /setup-test-env
"device", "phone", "emulator", "connected"            → /devices
"appium", "server"                                     → /appium
"apk", "deploy app", "install app"                     → /install-apk
"playwright", "web test", "browser", "spec.ts"         → /run-test
"k6", "load test", "performance", "stress", ".k6.js"   → /run-test
"mobile test", "native app", "wdio", ".mobile.ts"      → /mobile-test
"webview", "hybrid app", "web inside app"              → /mobile-test
"results", "report", "what failed", "pass/fail"         → /test-report
"status", "dashboard", "overview", "monitor"            → /monitor
"scaffold", "template", "new project", "create test"    → /scaffold-test
```

### File Extension → Skill Mapping

```
*.spec.ts, *.spec.js, *.test.ts, *.test.js  → /run-test (Playwright)
*.k6.js, *.k6.ts                             → /run-test (k6)
*.mobile.ts, *.mobile.js                     → /mobile-test (WDIO+Appium)
*.apk                                        → /install-apk
playwright.config.ts                         → /run-test context
wdio.conf.ts                                 → /mobile-test context
```

---

## Skill Capability Boundaries

Understanding what each skill CANNOT do prevents incorrect routing:

| Skill | Cannot do |
|---|---|
| `/run-test` | Cannot test native mobile apps, cannot manage Appium, cannot install APKs |
| `/mobile-test` | Cannot run web-only tests (use Playwright directly), cannot run k6 tests |
| `/devices` | Cannot install apps (use `/install-apk`), cannot start services |
| `/appium` | Cannot run tests (only manages the server) |
| `/install-apk` | Cannot run tests after install (use `/mobile-test`), iOS only via Xcode |
| `/test-report` | Cannot re-run tests, only reads existing result files |
| `/monitor` | Read-only dashboard, cannot fix issues (suggests other skills) |
| `/scaffold-test` | Creates files only, does not run tests |
| `/setup-test-env` | Checks and suggests installs, does not auto-install without user consent |

---

## Multi-Skill Orchestration Rules

1. **Always check prerequisites before execution**: If user requests a mobile test and you haven't verified the environment, consider running `/monitor` or `/devices` first.

2. **Minimize redundant checks**: `/mobile-test` auto-checks Appium and devices. Don't run `/appium status` + `/devices` before `/mobile-test` unless user explicitly asks.

3. **Chain results**: After any test execution skill (`/run-test`, `/mobile-test`), follow up with `/test-report` to show results — unless the test skill already displayed results inline.

4. **Error recovery chain**: On failure, use the error handling decision tree above to suggest the correct fix skill.

5. **Parallel execution**: `/run-test` (web) and `/mobile-test` (mobile) can run in parallel if user wants "test everything". They use different infrastructure.

6. **Order of operations for full mobile test cycle**:
   ```
   /setup-test-env (once, first time only)
   → /devices (verify device)
   → /appium start (if not running)
   → /install-apk (if app not installed)
   → /mobile-test (run tests)
   → /test-report (view results)
   → /appium stop (cleanup, optional)
   ```

---

## Response Format Guidelines

When reporting skill results to users, follow these patterns:

### Test Execution Results
```
Test Run: <suite-name>
Status: PASSED/FAILED
Total: X | Passed: X | Failed: X | Skipped: X
Duration: X.Xs

[If failures exist, list each with:]
FAILED: <test-name>
  Error: <error-message>
  File: <file-path>:<line>
```

### Device Listing
```
# | Device ID | Platform | Model | OS | Status
```

### Environment Check
```
Tool | Status (✓/✗) | Version | Notes
```

---

## Version Information

- **Skills version**: 0.1.0
- **Supported test frameworks**: Playwright, WebdriverIO + Appium 2.0, k6
- **Supported platforms**: Windows, macOS, Linux
- **Required**: Node.js 20+, Claude Code CLI
- **Optional**: Java 11+ (mobile), Android SDK (Android), Xcode (iOS), k6 (performance)
