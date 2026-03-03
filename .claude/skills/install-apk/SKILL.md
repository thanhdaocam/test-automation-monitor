---
name: install-apk
description: Install an APK file onto a connected Android device or emulator. Specify the APK path and optionally a device ID. Use this to deploy your app before running mobile tests.
allowed-tools: Bash(adb *), Bash(ls *), Read
user-invocable: true
argument-hint: <apk-path> [device-id]
disable-model-invocation: true
---

# Install APK on Android Device

Deploy an APK file to a connected Android device or emulator.

## Parse Arguments

- `$0` = path to the APK file (required)
- `$1` = device ID (optional, if multiple devices connected)

## Steps

1. **Validate APK file exists**:
   ```bash
   ls -la "$0" 2>/dev/null
   ```
   If not found, report: "APK file not found: $0. Please provide a valid path."
   Also verify it has `.apk` extension.

2. **List connected devices**:
   ```bash
   adb devices -l
   ```
   - If **no devices**: "No Android devices connected. Connect a device or start an emulator first."
   - If **one device**: use it automatically.
   - If **multiple devices** and no `$1` specified: list them and ask the user to specify: "Multiple devices found. Please specify: `/install-apk <apk> <device_id>`"
   - If `$1` specified: use that device.

3. **Get device info** for confirmation:
   ```bash
   adb -s <device_id> shell getprop ro.product.model
   adb -s <device_id> shell getprop ro.build.version.release
   ```

4. **Install the APK**:
   ```bash
   adb -s <device_id> install -r "$0"
   ```
   The `-r` flag reinstalls if already installed, keeping data.

5. **Verify installation**:
   Extract package name from install output, then:
   ```bash
   adb -s <device_id> shell pm list packages | grep <partial_package_name>
   ```

6. **Report result**:
   - Success:
     ```
     APK installed successfully!
     ─────────────────────────────────
     File:    app-debug.apk
     Device:  Pixel 7 (emulator-5554)
     Package: com.example.myapp
     ─────────────────────────────────
     Tip: Run `/mobile-test <test-file> --device emulator-5554` to test it.
     ```
   - Failure: Show the error from adb and suggest fixes:
     - "INSTALL_FAILED_ALREADY_EXISTS" → try `adb install -r`
     - "INSTALL_FAILED_INSUFFICIENT_STORAGE" → free up device storage
     - "device unauthorized" → enable USB debugging and accept the prompt on device
