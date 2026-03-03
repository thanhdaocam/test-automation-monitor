---
name: devices
description: List all connected Android and iOS devices and emulators. Shows device ID, model, OS version, and connection status. Use this to see what devices are available for mobile testing.
allowed-tools: Bash(adb *), Bash(idevice_id *), Bash(ideviceinfo *), Bash(xcrun *)
user-invocable: true
---

# List Connected Devices

Discover and display all connected Android and iOS devices/emulators.

## Current Device Status

!`adb devices -l 2>/dev/null || echo "ADB not available"`

## Steps

1. **Check ADB is available**:
   ```bash
   adb version 2>/dev/null
   ```
   If not found, tell the user: "ADB not found. Run `/setup-test-env` to install prerequisites."

2. **Start ADB server** (if not running):
   ```bash
   adb start-server 2>/dev/null
   ```

3. **List Android devices**:
   ```bash
   adb devices -l
   ```
   For each device found, get details:
   ```bash
   adb -s <device_id> shell getprop ro.product.model
   adb -s <device_id> shell getprop ro.build.version.release
   adb -s <device_id> shell getprop ro.product.brand
   ```

4. **List iOS devices** (only on macOS, skip on Windows/Linux without error):
   ```bash
   idevice_id -l 2>/dev/null
   ```
   If found, get details:
   ```bash
   ideviceinfo -u <udid> -k DeviceName 2>/dev/null
   ideviceinfo -u <udid> -k ProductVersion 2>/dev/null
   ideviceinfo -u <udid> -k ProductType 2>/dev/null
   ```

5. **Also check for iOS simulators** (macOS only):
   ```bash
   xcrun simctl list devices available 2>/dev/null | grep -E "Booted|Shutdown"
   ```

6. **Display results** as a formatted table:
   ```
   Connected Devices
   ══════════════════════════════════════════════════════════════
   #  Device ID         Platform    Model         OS       Status
   ──────────────────────────────────────────────────────────────
   1  emulator-5554     Android     Pixel 7       14       online
   2  R5CT32XXXXX       Android     Galaxy S23    13       online
   3  00008101-XXXX     iOS         iPhone 15     17.4     online
   ══════════════════════════════════════════════════════════════
   Total: 3 devices (3 online, 0 offline)
   ```

7. **If no devices found**, provide helpful guidance:
   - Android: "Connect a device via USB with USB Debugging enabled, or start an emulator from Android Studio."
   - iOS: "Connect an iPhone via USB and trust the computer, or boot a simulator with `xcrun simctl boot <device>`."

8. **Tip**: Mention that the user can use a specific device with `/mobile-test --device <id>` or `/install-apk <apk> <device_id>`.

## Error Recovery

- If `adb` not found: suggest running `/setup-test-env` first.
- If `adb devices` returns "daemon not running": ADB will auto-start, wait and retry.
- If device shows "unauthorized": tell user to check the USB debugging prompt on the device screen.
- If device shows "offline": suggest `adb kill-server && adb start-server`.

## Related Skills

- Install an app: `/install-apk <path.apk> <device_id>`
- Run mobile test: `/mobile-test <file> --device <device_id>`
- Start Appium: `/appium start`
