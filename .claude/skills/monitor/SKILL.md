---
name: monitor
description: Display a real-time system status dashboard showing Appium server, connected devices, environment info, and last test results. Use for a quick overview of your testing setup.
allowed-tools: Bash(adb *), Bash(curl *), Bash(node *), Bash(java *), Bash(appium *), Bash(k6 *), Bash(npx *), Bash(lsof *), Bash(netstat *), Bash(ls *), Bash(cat *), Bash(df *), Bash(ps *), Bash(tasklist *), Read, Grep, Glob
user-invocable: true
---

# Test Automation Monitor Dashboard

Display a comprehensive status overview of the entire testing environment.

## Steps

Run ALL of the following checks and compile results into a single dashboard view. Run checks in logical groups.

### 1. Services Status

**Appium Server:**
```bash
curl -s http://localhost:4723/status 2>/dev/null
```
Report: running (with version) or stopped.

**ADB Server:**
```bash
adb version 2>/dev/null
```
Report: running or not found.

### 2. Connected Devices

```bash
adb devices -l 2>/dev/null
```
For each device, get model:
```bash
adb -s <id> shell getprop ro.product.model 2>/dev/null
```

### 3. Environment Versions

Check all tools (run all, don't stop on error):
```bash
node --version 2>/dev/null
java --version 2>&1 | head -1
appium --version 2>/dev/null
npx playwright --version 2>/dev/null
k6 version 2>/dev/null
```

### 4. Last Test Results

Look for the most recent test result:
```bash
ls -lt test-results/ playwright-report/ reports/ 2>/dev/null | head -5
```
If found, read the most recent file and extract summary (pass/fail counts).

### 5. Display Dashboard

Compile everything into a formatted dashboard:

```
═══════════════════════════════════════════════════════
          TEST AUTOMATION MONITOR
═══════════════════════════════════════════════════════

SERVICES
  Appium Server    ✓ running  (v2.5.1, port 4723)
  ADB Server       ✓ running  (v34.0.5)

DEVICES
  emulator-5554    ✓ online   Pixel 7 (Android 14)
  R5CT32XXXXX      ✓ online   Galaxy S23 (Android 13)
  (2 devices connected)

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
Quick Actions:
  /run-test          Run web tests
  /mobile-test       Run mobile tests
  /devices           Manage devices
  /appium start      Start Appium server
  /test-report       View detailed report
═══════════════════════════════════════════════════════
```

### 6. Warnings

Show warnings for any issues detected:
- Appium not running: "⚠ Appium is not running. Use `/appium start`"
- No devices: "⚠ No devices connected. Connect a device or start an emulator."
- Missing tools: "⚠ <tool> not found. Run `/setup-test-env`"
- No test results: "⚠ No test results found. Run `/run-test` to get started."
