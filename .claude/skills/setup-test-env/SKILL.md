---
name: setup-test-env
description: Check and setup the test automation environment. Verifies Node.js, Java, ADB, Appium, Playwright, k6 are installed and configured correctly. Use this before running any tests for the first time.
allowed-tools: Bash(node *), Bash(java *), Bash(adb *), Bash(appium *), Bash(npx *), Bash(k6 *), Bash(which *), Bash(where *), Bash(echo *), Bash(npm *)
user-invocable: true
---

# Setup Test Environment

Check all prerequisites for the test automation toolkit and guide the user to install anything missing.

## Steps

1. **Check each tool** by running the commands below. For each tool, report its status as ✓ (installed with version) or ✗ (missing with install instructions).

2. **Tools to check** (run all checks, do not stop on first failure):

   **Node.js** (required, >= 20):
   ```bash
   node --version
   ```
   If missing: "Install Node.js 20+ from https://nodejs.org"

   **Java** (required for Appium, >= 11):
   ```bash
   java --version
   ```
   If missing: "Install Java 11+ (e.g. `winget install Microsoft.OpenJDK.17`)"

   **ADB** (required for Android testing):
   ```bash
   adb version
   ```
   If missing: "Install Android SDK Platform-Tools or Android Studio. Set ANDROID_HOME env variable."

   **Appium** (required for mobile testing):
   ```bash
   appium --version
   ```
   If missing: "Run `npm install -g appium`"

   **Appium Drivers** (required for mobile testing):
   ```bash
   appium driver list --installed 2>/dev/null
   ```
   If uiautomator2 missing: "Run `appium driver install uiautomator2`"
   If xcuitest missing (macOS only): "Run `appium driver install xcuitest`"

   **Playwright** (required for web testing):
   ```bash
   npx playwright --version 2>/dev/null
   ```
   If missing: "Run `npm install -D @playwright/test && npx playwright install`"

   **k6** (required for performance testing):
   ```bash
   k6 version 2>/dev/null
   ```
   If missing: "Install k6 from https://k6.io/docs/get-started/installation/"

3. **Check ANDROID_HOME** environment variable:
   ```bash
   echo $ANDROID_HOME
   ```
   If empty: warn that ANDROID_HOME should be set.

4. **Summary**: Display a clean table with all results:
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

5. If anything is missing, offer to install it automatically (only for npm-based tools like Appium, Playwright). Ask before running install commands.

6. If everything is ready, confirm: "Environment is ready! You can now use `/devices`, `/run-test`, `/mobile-test`."

## Error Recovery

- If a command hangs or times out, skip it and mark as "unknown".
- If the user is on Windows and `which` doesn't work, use `where` instead.
- If running in CI (detect via `$CI` env var), skip interactive install prompts.

## Related Skills

- After setup: use `/devices` to check connected devices
- To start Appium: use `/appium start`
- To create test files: use `/scaffold-test`
- Quick status check: use `/monitor`
