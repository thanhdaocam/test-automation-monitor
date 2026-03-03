# Test Automation Monitor - Implementation Plan

## Mục tiêu

Xây dựng bộ **Claude Code Skills** để monitor và quản lý automation test trên:
- **Web** (Playwright)
- **Android native** (.apk) via Appium 2.0 + WebdriverIO
- **iOS native** (.ipa) via Appium 2.0 + WebdriverIO
- **WebView** bên trong mobile app (Appium context switching)
- **Performance** (k6)

Người dùng chỉ cần cài Claude Code, copy skills vào project, gõ slash commands.

---

## Tại sao chọn Claude Code Skills (thay vì Desktop App)?

| | Desktop App (Tauri) | Claude Code Skills |
|---|---|---|
| Build time | 5-7 ngày | **3 ngày** |
| Complexity | Rust + React + SQLite | **Markdown + Bash** |
| Distribution | .exe installer | **Git clone** |
| Dependencies | Rust toolchain, Node.js | **Chỉ cần Claude Code** |
| UI | GUI dashboard | **Terminal (Claude AI format)** |
| Maintenance | Phức tạp | **Đơn giản** |
| AI-powered | Không | **Có - Claude xử lý logic** |
| Extensibility | Code mới | **Thêm .md file** |

---

## Tech Stack

| Layer | Technology | Vai trò |
|-------|-----------|---------|
| Skill Engine | **Claude Code** | Chạy skills, AI reasoning |
| Skill Format | **Markdown (SKILL.md)** | Định nghĩa commands |
| Web Testing | **Playwright** | Browser automation |
| Mobile Testing | **Appium 2.0 + WebdriverIO** | Android + iOS + WebView |
| Perf Testing | **k6** | Load & performance testing |
| Device Management | **ADB** (Android), **libimobiledevice** (iOS) | Detect & manage devices |
| Helper Scripts | **Bash** | Parse results, check env |

---

## Tại sao chọn Appium 2.0 + WebdriverIO cho Mobile?

| Tiêu chí | Appium 2.0 | Maestro | Detox |
|----------|-----------|---------|-------|
| Android native (.apk) | ✅ | ✅ | ❌ (React Native only) |
| iOS native (.ipa) | ✅ | ✅ | ❌ |
| **WebView bên trong app** | ✅ First-class | ❌ Limited | ❌ |
| TypeScript support | ✅ (via WebdriverIO) | ❌ (YAML only) | ✅ |
| Tích hợp với Playwright | ✅ Excellent | ❌ Poor | ❌ Poor |
| Maturity / ecosystem | ✅ Lớn nhất | ⚠️ Mới | ⚠️ Niche |

**Kết luận**: Appium 2.0 là framework duy nhất hỗ trợ đầy đủ native Android + native iOS + WebView context switching trong hybrid apps.

---

## Skills Architecture

### Cách hoạt động

```
User gõ:  /run-test login.spec.ts --headed
              │
              ▼
┌─────────────────────────────────┐
│  Claude Code loads SKILL.md     │
│  + parse $ARGUMENTS             │
│  + inject dynamic context       │
│    (!`cat package.json`)        │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  Claude AI reasons:             │
│  - Detect test type (Playwright)│
│  - Build command                │
│  - Execute via Bash tool        │
│  - Parse output                 │
│  - Format results               │
└──────────────┬──────────────────┘
               │
               ▼
        ┌──────┴──────┐
        │  Bash Tool  │
        └──────┬──────┘
               │
               ▼
  npx playwright test login.spec.ts
         --reporter=json --headed
```

### SKILL.md Format

```yaml
---
name: skill-name
description: When/how to use this skill
allowed-tools: Bash(...), Read, Grep
user-invocable: true
argument-hint: [args]
---

# Instructions in Markdown
Step-by-step instructions for Claude AI to follow.
Dynamic context: !`shell command` runs before Claude sees the prompt.
Arguments: $ARGUMENTS, $0, $1, etc.
```

---

## Skills Specification

### 1. `/setup-test-env` - Environment Setup

**Mục đích**: Kiểm tra tất cả prerequisites, hướng dẫn cài thiếu.

**Flow**:
1. Check Node.js version (>= 20)
2. Check Java version (>= 11)
3. Check ADB availability + ANDROID_HOME
4. Check Appium + installed drivers
5. Check Playwright
6. Check k6
7. Report missing tools + install commands

**Allowed tools**: `Bash(node *), Bash(java *), Bash(adb *), Bash(appium *), Bash(npx playwright *), Bash(k6 *)`

---

### 2. `/devices` - Device Discovery

**Mục đích**: List tất cả Android/iOS devices đang kết nối.

**Flow**:
1. Run `adb devices -l` → parse output
2. Cho mỗi device: get model (`ro.product.model`), OS version (`ro.build.version.release`)
3. Nếu macOS: run `idevice_id -l` cho iOS
4. Format thành bảng đẹp

**Dynamic context**: `!`adb devices -l 2>/dev/null``

**Allowed tools**: `Bash(adb *), Read`

---

### 3. `/appium` - Appium Server Control

**Mục đích**: Start/stop/check Appium server.

**Subcommands**:
- `/appium start` → `appium server --port 4723 --allow-cors`
- `/appium stop` → kill process on port 4723
- `/appium status` → check health endpoint
- `/appium install-drivers` → install uiautomator2, xcuitest

**Allowed tools**: `Bash(appium *), Bash(lsof *), Bash(curl *), Bash(kill *), Bash(netstat *)`

---

### 4. `/install-apk` - Install APK

**Mục đích**: Deploy APK lên Android device.

**Flow**:
1. Verify APK file exists
2. List available devices (nếu nhiều → hỏi chọn)
3. `adb -s <device> install -r <apk>`
4. Verify: `adb shell pm list packages | grep <package>`

**Arguments**: `$0` = APK path, `$1` = device ID (optional)

**Allowed tools**: `Bash(adb *), Read`

---

### 5. `/run-test` - Run Web/Performance Tests

**Mục đích**: Chạy Playwright hoặc k6 tests.

**Flow**:
1. Detect test type:
   - `.spec.ts` / `.test.ts` → Playwright
   - `.k6.js` / `.k6.ts` → k6
   - Fallback: check package.json scripts
2. Build command với arguments
3. Execute, capture output
4. Parse JSON results → format bảng pass/fail
5. Show summary: total, passed, failed, duration

**Arguments**: `$0` = test file/pattern, extra flags passed through

**Allowed tools**: `Bash(npx playwright *), Bash(k6 *), Read, Grep, Glob`

---

### 6. `/mobile-test` - Run Mobile Tests

**Mục đích**: Chạy WebdriverIO + Appium tests trên Android/iOS.

**Flow**:
1. Check Appium server → start nếu chưa chạy
2. Check devices → list nếu cần user chọn
3. Tìm hoặc generate wdio.conf.ts
4. `npx wdio run wdio.conf.ts --spec <file>`
5. Parse results → format output
6. Show screenshots nếu có failures

**Arguments**: `$0` = test file, `--device <id>`, `--platform android|ios`

**Allowed tools**: `Bash(npx wdio *), Bash(appium *), Bash(adb *), Read, Grep, Glob`

---

### 7. `/test-report` - View Test Results

**Mục đích**: Xem kết quả test runs, thống kê.

**Flow**:
1. Tìm result files: `test-results/`, `playwright-report/`, `*.json`
2. Parse format phù hợp (Playwright JSON, WDIO JSON, k6 JSON)
3. Hiển thị:
   - Summary: pass/fail/skip counts, duration, pass rate
   - Failed tests chi tiết: name, error, file:line
   - Nếu có screenshots → list paths
4. So sánh với lần trước (nếu có)

**Arguments**: `--last`, `--suite <name>`, `--failures-only`

**Allowed tools**: `Read, Grep, Glob, Bash(ls *), Bash(cat *)`

---

### 8. `/monitor` - System Dashboard

**Mục đích**: Tổng quan nhanh status toàn bộ system.

**Flow**:
1. Check services: Appium (port 4723), ADB
2. List devices + status
3. Last test run results (nếu có)
4. Environment info: Node, Java, tool versions
5. Disk space, port availability

**Dynamic context**:
- `!`adb devices 2>/dev/null``
- `!`curl -s http://localhost:4723/status 2>/dev/null``
- `!`ls test-results/ 2>/dev/null``

**Allowed tools**: `Bash(*), Read, Grep, Glob`

---

### 9. `/scaffold-test` - Create Test Project

**Mục đích**: Tạo test project mới từ template.

**Flow**:
1. Hỏi user: Web / Mobile / Performance / All?
2. Copy template files phù hợp
3. Install dependencies (`npm install`)
4. Verify setup
5. Hướng dẫn next steps

**Allowed tools**: `Bash(npm *), Bash(mkdir *), Bash(cp *), Write, Read`

---

## Template Files

### `templates/playwright.config.ts`
Base config cho Playwright: browsers, baseURL, reporter settings.

### `templates/wdio.conf.ts`
Base config cho WebdriverIO + Appium:
- UiAutomator2 cho Android
- XCUITest cho iOS
- chromedriverAutodownload cho WebView
- JSON reporter

### `templates/sample.spec.ts`
Sample Playwright test: navigate, fill form, assert.

### `templates/sample.mobile.ts`
Sample WebdriverIO test:
- Native app interaction
- WebView context switching
- Screenshot on failure

### `templates/sample.k6.js`
Sample k6 script: HTTP requests, checks, thresholds.

---

## Helper Scripts

### `scripts/check-env.sh`
Kiểm tra tất cả prerequisites, output JSON:
```json
{
  "node": {"installed": true, "version": "20.11.0"},
  "java": {"installed": true, "version": "17.0.2"},
  "adb": {"installed": true, "version": "34.0.5"},
  "appium": {"installed": true, "version": "2.5.1", "drivers": ["uiautomator2"]},
  "playwright": {"installed": true, "version": "1.42.0"},
  "k6": {"installed": true, "version": "0.49.0"}
}
```

### `scripts/parse-playwright-results.sh`
Parse Playwright JSON report → simplified output.

### `scripts/parse-wdio-results.sh`
Parse WebdriverIO JSON report → simplified output.

### `scripts/parse-k6-results.sh`
Parse k6 JSON output → extract key metrics.

---

## WebView Testing Guide

### Cách Appium xử lý WebView

```
App mở lên
    │
    ▼
NATIVE_APP context
    │ Click vào WebView area
    ▼
driver.getContexts()
→ ['NATIVE_APP', 'WEBVIEW_com.example.app']
    │
    ▼
driver.switchContext('WEBVIEW_com.example.app')
    │ Giờ dùng web selectors
    ▼
$('h1').getText()
$('#login-form').isDisplayed()
    │
    ▼
driver.switchContext('NATIVE_APP')
    │ Quay lại native
    ▼
$('~nativeButton').click()
```

### Sample WebView Test

```typescript
describe('Hybrid App', () => {
    it('should interact with WebView', async () => {
        // Native: mở app
        await $('~openWebView').click();

        // Đợi WebView load
        await driver.pause(2000);

        // Switch sang WebView
        const contexts = await driver.getContexts();
        const webview = contexts.find(c => c.includes('WEBVIEW'));
        await driver.switchContext(webview);

        // Web: tương tác HTML
        await $('#email').setValue('test@example.com');
        await $('button[type=submit]').click();
        expect(await $('h1').getText()).toBe('Welcome');

        // Switch lại native
        await driver.switchContext('NATIVE_APP');
        await $('~homeButton').click();
    });
});
```

---

## Appium 2.0 Setup Guide

### Android

```bash
# 1. Cài Java 11+
java --version

# 2. Cài Android SDK (hoặc Android Studio)
# Set ANDROID_HOME=C:\Users\<you>\AppData\Local\Android\Sdk
echo $ANDROID_HOME

# 3. Verify ADB
adb version
adb devices

# 4. Cài Appium 2.0
npm install -g appium

# 5. Cài UiAutomator2 driver
appium driver install uiautomator2

# 6. Verify
appium driver list --installed
```

### iOS (cần macOS)

```bash
# 1. Cài Xcode từ App Store
xcode-select --install

# 2. Cài XCUITest driver
appium driver install xcuitest

# 3. Cài device tools
brew install ios-deploy libimobiledevice

# 4. Verify
idevice_id -l
```

> **Lưu ý**: iOS testing KHÔNG chạy được trên Windows. Cần Mac hoặc cloud (BrowserStack, SauceLabs).

---

## Implementation Phases

### Phase 1: Core Skills (Day 1)
- `/setup-test-env` - environment check
- `/devices` - device discovery
- `/appium` - server management
- `/install-apk` - deploy APK
- `/run-test` - web & perf tests
- Template files

### Phase 2: Mobile + Reports (Day 2)
- `/mobile-test` - WebdriverIO + Appium
- `/test-report` - results viewer
- `/monitor` - system dashboard
- Helper scripts
- `CLAUDE.md` project config

### Phase 3: Polish + Publish (Day 3)
- `/scaffold-test` - project generator
- Error handling cải thiện
- Dynamic context injection
- Documentation: INSTALL.md, SKILLS.md
- Testing full flow
- GitHub release

---

## Notes

1. **Skills = Markdown**: Mỗi skill là file `.md`, dễ đọc, dễ sửa, dễ share
2. **Claude AI = Engine**: Claude xử lý logic phức tạp (detect test type, parse results, suggest fixes)
3. **No database needed**: Results nằm trong file system (JSON reports)
4. **No server needed**: Tất cả chạy local qua Claude Code
5. **Extensible**: Thêm skill mới = thêm 1 folder + SKILL.md
6. **iOS trên Windows**: Không hỗ trợ native. App hiện warning, suggest cloud testing.
