# Skills Reference

Complete reference for all Claude Code Skills in this project.

---

## `/setup-test-env` - Environment Setup

**What it does**: Checks all prerequisites (Node.js, Java, ADB, Appium, Playwright, k6) and reports their status. Offers to install missing npm-based tools.

**Arguments**: None

**Example**:
```
> /setup-test-env
```

**Output**:
```
Test Automation Environment Check
══════════════════════════════════════════════
Tool          Status    Version     Notes
──────────────────────────────────────────────
Node.js       ✓         v20.11.0
Java          ✓         17.0.2
ADB           ✓         34.0.5
Appium        ✓         2.5.1
  uiautomator2  ✓       2.34.0
  xcuitest      ✗       -          macOS only
Playwright    ✓         1.42.0
k6            ✓         0.49.0
ANDROID_HOME  ✓         C:\Android\Sdk
══════════════════════════════════════════════
Ready: 7/8 tools configured
```

**When to use**: First time setup, or when something isn't working.

---

## `/devices` - List Connected Devices

**What it does**: Discovers all connected Android devices, emulators, and iOS devices. Shows device ID, model, OS version, and status.

**Arguments**: None

**Example**:
```
> /devices
```

**Output**:
```
Connected Devices
══════════════════════════════════════════════════════════════
#  Device ID         Platform    Model         OS       Status
──────────────────────────────────────────────────────────────
1  emulator-5554     Android     Pixel 7       14       online
2  R5CT32XXXXX       Android     Galaxy S23    13       online
══════════════════════════════════════════════════════════════
Total: 2 devices (2 online, 0 offline)
```

**When to use**: Before running mobile tests, to see what's available.

---

## `/appium` - Appium Server Control

**What it does**: Start, stop, or check the Appium 2.0 server used for mobile testing.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `start` | Start Appium server | - |
| `stop` | Stop Appium server | - |
| `status` | Check if running | (default) |
| `install-drivers` | Install Appium drivers | - |
| `--port <n>` | Port number | 4723 |

**Examples**:
```
> /appium                     # Check status
> /appium start               # Start server
> /appium stop                # Stop server
> /appium start --port 4724   # Start on custom port
> /appium install-drivers     # Install uiautomator2/xcuitest
```

**When to use**: Before running `/mobile-test`. The mobile-test skill auto-starts Appium, but you can also manage it manually.

---

## `/install-apk` - Install APK on Device

**What it does**: Installs an APK file onto a connected Android device or emulator.

**Arguments**:
| Argument | Description | Required |
|----------|-------------|----------|
| `<apk-path>` | Path to .apk file | Yes |
| `<device-id>` | Target device ID | No (auto if 1 device) |

**Examples**:
```
> /install-apk ./app/app-debug.apk
> /install-apk ./app/app-debug.apk emulator-5554
> /install-apk builds/release.apk R5CT32XXXXX
```

**When to use**: Before running mobile tests, to deploy your app to the device.

---

## `/run-test` - Run Web & Performance Tests

**What it does**: Runs Playwright web tests or k6 performance tests. Auto-detects the framework from file extension. Parses results and shows formatted pass/fail summary.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/pattern>` | Test file or glob pattern | All tests |
| `--headed` | Show browser (Playwright) | Headless |
| `--debug` | Debug mode | Off |
| `--grep <pattern>` | Filter by test name | All |
| `--workers <n>` | Parallel workers | Auto |

**Examples**:
```
> /run-test                                    # Run all tests
> /run-test tests/web/login.spec.ts            # Run specific file
> /run-test tests/web/ --headed                # Run with browser visible
> /run-test --grep "login"                     # Filter by name
> /run-test tests/performance/load.k6.js       # Run k6 perf test
> /run-test login.spec.ts --debug              # Step-by-step debug
```

**Auto-detection**:
- `*.spec.ts`, `*.test.ts`, `*.spec.js`, `*.test.js` → Playwright
- `*.k6.js`, `*.k6.ts` → k6

**When to use**: For web browser testing and performance/load testing. For mobile tests, use `/mobile-test` instead.

---

## `/mobile-test` - Run Mobile Tests

**What it does**: Runs WebdriverIO + Appium tests on Android/iOS devices. Auto-starts Appium if needed, auto-detects devices, handles WebView context switching.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<test-file>` | Test file path | Required |
| `--device <id>` | Target device | Auto (if 1 device) |
| `--platform <p>` | `android` or `ios` | `android` |
| `--app <path>` | APK/IPA to install first | - |

**Examples**:
```
> /mobile-test tests/mobile/login.mobile.ts
> /mobile-test tests/mobile/login.mobile.ts --device emulator-5554
> /mobile-test tests/mobile/app.mobile.ts --app ./app-debug.apk
> /mobile-test tests/mobile/ios-test.mobile.ts --platform ios
```

**What it handles automatically**:
1. Checks if Appium is running → starts it if not
2. Checks if device is connected → lists available if not specified
3. Finds or generates `wdio.conf.ts`
4. Runs tests and parses results
5. Captures screenshots on failure

**When to use**: For testing native Android/iOS apps and hybrid WebView apps.

---

## `/test-report` - View Test Results

**What it does**: Finds and parses test result files (Playwright JSON, WDIO JSON, k6 JSON, JUnit XML). Shows pass/fail counts, duration, failure details.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `--last` | Most recent results | (default) |
| `--file <path>` | Specific report file | - |
| `--failures-only` | Only show failures | All |
| `--suite <name>` | Filter by suite name | All |

**Examples**:
```
> /test-report                         # Show last results
> /test-report --last                  # Same as above
> /test-report --failures-only         # Only failed tests
> /test-report --file test-results/playwright-results.json
> /test-report --suite login           # Filter by suite
```

**Supported formats**:
- Playwright JSON report
- WebdriverIO JSON report
- k6 JSON output
- JUnit XML

**When to use**: After running tests with `/run-test` or `/mobile-test`.

---

## `/monitor` - Status Dashboard

**What it does**: Displays a comprehensive overview of your entire testing environment: services, devices, tool versions, and last test results.

**Arguments**: None

**Example**:
```
> /monitor
```

**Output**:
```
═══════════════════════════════════════════════════════
          TEST AUTOMATION MONITOR
═══════════════════════════════════════════════════════

SERVICES
  Appium Server    ✓ running  (v2.5.1, port 4723)
  ADB Server       ✓ running  (v34.0.5)

DEVICES
  emulator-5554    ✓ online   Pixel 7 (Android 14)
  (1 device connected)

ENVIRONMENT
  Node.js          ✓ v20.11.0
  Java             ✓ 17.0.2
  Appium           ✓ 2.5.1
  Playwright       ✓ 1.42.0
  k6               ✓ 0.49.0

LAST TEST RUN
  Suite:     smoke-tests
  Status:    PASSED (12/12 tests)
  Duration:  45.2s
  Time:      5 minutes ago

═══════════════════════════════════════════════════════
```

**When to use**: Quick health check of your entire setup. Great to run at the start of a testing session.

---

## `/scaffold-test` - Create Test Project

**What it does**: Creates a new test project with proper structure, config files, sample tests, and installs dependencies.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `web` | Playwright web tests | - |
| `mobile` | WebdriverIO mobile tests | - |
| `performance` | k6 perf tests | - |
| `all` | All three types | - |
| `--dir <path>` | Target directory | Current dir |

**Examples**:
```
> /scaffold-test web                   # Create Playwright project
> /scaffold-test mobile                # Create WDIO + Appium project
> /scaffold-test performance           # Create k6 project
> /scaffold-test all                   # Create all three
> /scaffold-test web --dir ./my-tests  # Custom directory
```

**What it creates** (for `web`):
```
tests/web/login.spec.ts
tests/web/dashboard.spec.ts
playwright.config.ts
```

**When to use**: Starting a new test project from scratch. Gives you working sample tests immediately.

---

## Workflow Cheatsheet

### First Time Setup
```
/setup-test-env        → Check everything is installed
/scaffold-test all     → Create sample tests for all platforms
```

### Web Testing Session
```
/run-test tests/web/login.spec.ts --headed    → Run with browser
/test-report --last                            → Check results
```

### Mobile Testing Session
```
/devices                                       → Check device connected
/appium start                                  → Start Appium
/install-apk app-debug.apk                    → Deploy app
/mobile-test tests/mobile/app.mobile.ts        → Run tests
/test-report --last                            → Check results
/appium stop                                   → Stop Appium when done
```

### Performance Testing Session
```
/run-test tests/performance/load.k6.js         → Run load test
/test-report --last                            → Analyze results
```

### Quick Status Check
```
/monitor                                       → Everything at a glance
```
