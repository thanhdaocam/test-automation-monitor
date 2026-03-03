---
name: mobile-test
description: Run WebdriverIO + Appium tests on Android or iOS devices. Auto-starts Appium if needed, auto-detects devices. Supports native apps, WebView hybrid apps, and mobile browsers. Use for mobile app testing.
allowed-tools: Bash(npx *), Bash(appium *), Bash(adb *), Bash(curl *), Bash(lsof *), Bash(netstat *), Bash(cat *), Bash(ls *), Bash(kill *), Bash(sleep *), Read, Grep, Glob, Write
user-invocable: true
argument-hint: <test-file> [--device id] [--platform android|ios] [--app path.apk]
disable-model-invocation: true
---

# Run Mobile Tests

Execute WebdriverIO + Appium tests on connected Android/iOS devices.

## Parse Arguments

- `$0` = test file path (required)
- `--device <id>` = target device ID (optional, auto-detect if one device)
- `--platform android|ios` = target platform (optional, default: android)
- `--app <path>` = path to .apk or .ipa to install before testing

## Steps

### 1. Pre-flight Checks

**Check Appium server:**
```bash
curl -s http://localhost:4723/status 2>/dev/null
```
If not running, start it:
```bash
appium server --port 4723 --allow-cors > /tmp/appium.log 2>&1 &
sleep 3
curl -s http://localhost:4723/status
```
If still can't start, report error and suggest `/appium start`.

**Check devices:**
```bash
adb devices -l
```
- No devices → error: "No devices connected. Connect a device or start an emulator."
- One device → use automatically
- Multiple devices + no `--device` → list and ask user to specify
- `--device` specified → verify it exists in device list

**Check test file exists:**
```bash
ls -la "$0" 2>/dev/null
```
If not found, search for it:
```bash
find . -name "$(basename $0)" -type f 2>/dev/null
```

### 2. Locate or Generate WDIO Config

**Search for existing config:**
```bash
ls wdio.conf.ts wdio.conf.js .wdio.conf.ts 2>/dev/null
```

**If no config found**, generate a minimal one dynamically. Create `wdio.conf.ts` with:
- Runner: local
- Port: 4723 (Appium)
- Framework: mocha
- Capabilities: based on `--platform` and `--device`
- If `--app` provided, set `appium:app` capability
- Reporter: spec + json

Use the Write tool to create a temporary config if needed.

### 3. Install App (if --app specified)

```bash
adb -s <device_id> install -r <app_path>
```
Verify installation succeeded.

### 4. Run Tests

Build command:
```bash
npx wdio run wdio.conf.ts --spec $0
```

Execute and stream output. Capture exit code and any JSON reporter output.

### 5. Parse & Display Results

Read test output and display:

```
Mobile Test Results (WebdriverIO + Appium)
══════════════════════════════════════════════════════════════
Device:   Pixel 7 (emulator-5554) - Android 14
App:      com.example.myapp
Appium:   2.5.1 (uiautomator2)
──────────────────────────────────────────────────────────────
  ✓ should open the app                              3.1s
  ✓ should login with valid credentials              4.2s
  ✓ should navigate to dashboard                     2.1s
  ✓ should switch to WebView and verify content      2.8s
  ✗ should submit form in WebView                    5.3s
    Error: element ("h1") still not displayed after 5000ms
    at sample.mobile.ts:45:15

Screenshots:
  ✗ should submit form → ./screenshots/failure_001.png
──────────────────────────────────────────────────────────────
Summary: 4 passed, 1 failed, 0 skipped
Duration: 17.5s
══════════════════════════════════════════════════════════════
```

### 6. Post-Run

- Show screenshot paths for failed tests (if captured)
- Suggest: "Use `/test-report` for detailed analysis"
- If WebView tests failed, suggest checking WebView context availability
- If app crash detected, suggest checking `adb logcat` output

## Error Recovery

- If Appium fails to start: show error log and suggest `/appium install-drivers` or check Java installation.
- If device not found: suggest `/devices` to see what's available, or check USB connection.
- If `wdio.conf.ts` not found and generation fails: guide user to run `/scaffold-test mobile` first.
- If WebView context not available: suggest ensuring the app has WebView debugging enabled (`setWebContentsDebuggingEnabled(true)` in app code).
- If `ECONNREFUSED` on port 4723: Appium is not running, auto-start or suggest `/appium start`.
- If session creation fails: check that the correct Appium driver is installed for the target platform.
- If iOS test on Windows: warn that iOS testing requires macOS. Suggest using Android instead.
- On timeout errors: suggest increasing `waitforTimeout` in wdio.conf.ts or checking app loading time.

## Related Skills

- Check devices: `/devices`
- Start Appium: `/appium start`
- Install APK first: `/install-apk <path.apk>`
- View results: `/test-report --last`
- Create sample test: `/scaffold-test mobile`
