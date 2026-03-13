---
name: rn-test
version: 2.0.0
description: Chạy kiểm thử React Native. Hỗ trợ Jest cho kiểm thử đơn vị và Detox cho kiểm thử E2E trên thiết bị thật và trình giả lập. Dùng cho dự án di động React Native.
allowed-tools: Bash(npx *), Bash(node *), Bash(detox *), Bash(adb *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file] [--e2e] [--device device-name] [--platform android|ios] [--configuration debug|release]
---

# Kiểm thử React Native

Thực thi kiểm thử đơn vị React Native (Jest) và kiểm thử E2E (Detox).

## Ngữ cảnh dự án hiện tại

Phát hiện React Native:
!`node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};if(d['react-native'])console.log('React Native: '+d['react-native']);else console.log('Không phải dự án React Native')}catch{console.log('Không có package.json')}" 2>/dev/null`

Phát hiện framework kiểm thử:
!`node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};const fw=[];if(d.detox)fw.push('detox@'+d.detox);if(d.jest||d['@jest/core'])fw.push('jest');if(d['@testing-library/react-native'])fw.push('testing-library/react-native');console.log(fw.length?fw.join(', '):'Không tìm thấy framework kiểm thử')}catch{}" 2>/dev/null`

Cấu hình Detox:
!`ls .detoxrc.js .detoxrc.json detox.config.js detox.config.json package.json 2>/dev/null | head -3`

## Parse Arguments

- `$0` = test file or pattern (optional)
- `--e2e` = run Detox E2E tests (instead of Jest unit tests)
- `--device <name>` = Detox device name (from config)
- `--platform <p>` = `android` (default) or `ios`
- `--configuration <c>` = `debug` (default) or `release`
- `--build` = build the app before running E2E tests
- `--reuse` = reuse existing app build (skip rebuild)

## Steps

### 1. Detect Test Type

- If `--e2e` flag → **Detox E2E tests**
- If file matches `*.e2e.ts`, `*.e2e.js` → **Detox E2E tests**
- Otherwise → **Jest unit/component tests**

### 2. Run Jest Unit Tests

```bash
npx jest $test_pattern --json --outputFile=test-results/rn-jest-results.json
```

With specific test:
```bash
npx jest $test_file --json --outputFile=test-results/rn-jest-results.json
```

With coverage:
```bash
npx jest --coverage --json --outputFile=test-results/rn-jest-results.json
```

### 3. Run Detox E2E Tests

**Build first (if `--build`):**
```bash
npx detox build --configuration $platform.$configuration
```

For example:
```bash
npx detox build --configuration android.emu.debug
# or
npx detox build --configuration ios.sim.debug
```

**Run E2E tests:**
```bash
npx detox test --configuration $platform.$configuration --reporter jest-json --json-output-file test-results/detox-results.json
```

With specific test file:
```bash
npx detox test $test_file --configuration $platform.$configuration
```

**Reuse build (skip rebuild):**
```bash
npx detox test --configuration $platform.$configuration --reuse
```

### 4. Parse and Display Results

```
React Native Test Results
══════════════════════════════════════════════════════════════
Mode: Detox E2E | Platform: Android | Device: Pixel_7_API_34

  ✓ e2e/login.e2e.ts
    ✓ should show login screen                   1.2s
    ✓ should login successfully                  3.4s
    ✓ should show error for wrong password       2.1s

  ✗ e2e/profile.e2e.ts
    ✓ should navigate to profile                 1.8s
    ✗ should update avatar                       5.0s
      Error: Cannot find element by testID: "avatar-picker"
      Screenshot: artifacts/profile.e2e/update-avatar.png

──────────────────────────────────────────────────────────────
Tests:   4 passed, 1 failed, 5 total
Duration: 13.5s
Artifacts: artifacts/
══════════════════════════════════════════════════════════════
```

### 5. Post-Run

- Show pass/fail summary
- List screenshots/artifacts for failures (Detox auto-captures)
- For E2E: note device logs location
- Suggest: "Use `--build` flag to rebuild before testing"

## Error Recovery

- If not a React Native project: suggest using `/unit-test` or `/run-test` instead
- If Detox not installed: "Run `npm install -D detox` and configure `.detoxrc.js`"
- If build fails: check metro bundler, clean build with `cd android && ./gradlew clean`
- Nếu không tìm thấy thiết bị/trình giả lập: gợi ý khởi động trình giả lập hoặc chạy `/devices` để kiểm tra
- If app crash during test: check device logs with `adb logcat`
- For iOS (macOS only): check Xcode installation and simulator setup

## Related Skills

- Check devices: `/devices`
- Start Appium (alternative): `/appium start`
- Run Appium-based mobile tests: `/mobile-test`
- View results: `/test-report --last`
- Unit tests only: `/unit-test`
