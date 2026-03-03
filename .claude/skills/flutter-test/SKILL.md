---
name: flutter-test
description: Run Flutter unit, widget, and integration tests. Supports flutter test, flutter drive, and patrol. Use for Flutter mobile and web projects.
allowed-tools: Bash(flutter *), Bash(dart *), Bash(patrol *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file-or-dir] [--integration] [--device device-id] [--coverage] [--update-goldens]
---

# Flutter Testing

Execute Flutter unit, widget, and integration tests.

## Current Project Context

Flutter project detection:
!`ls pubspec.yaml 2>/dev/null && echo "Flutter project found" || echo "No Flutter project (no pubspec.yaml)"`

Flutter test files:
!`find . -maxdepth 5 -type f -name "*_test.dart" 2>/dev/null | head -15 || echo "No Flutter test files found"`

Integration test files:
!`find . -maxdepth 5 -path "*/integration_test/*" -name "*_test.dart" 2>/dev/null | head -10 || echo "No integration tests found"`

## Parse Arguments

- `$0` = test file, directory, or pattern (optional, runs all if omitted)
- `--integration` = run integration tests (flutter drive / patrol)
- `--device <id>` = target device for integration tests
- `--coverage` = generate code coverage report
- `--update-goldens` = update golden image files (visual tests)
- `--platform <p>` = target platform: `android`, `ios`, `web`, `linux`, `windows`, `macos`

## Steps

### 1. Verify Flutter Installation

```bash
flutter --version 2>/dev/null
```

If not installed, inform user:
- Windows: `winget install Flutter.Flutter`
- macOS: `brew install flutter`
- Or download from https://flutter.dev/docs/get-started/install

Check connected devices for integration tests:
```bash
flutter devices 2>/dev/null
```

### 2. Run Unit & Widget Tests

**All tests:**
```bash
flutter test --reporter json 2>&1
```

**Specific file:**
```bash
flutter test $test_file --reporter json 2>&1
```

**With coverage:**
```bash
flutter test --coverage --reporter json 2>&1
```

**Update golden files:**
```bash
flutter test --update-goldens $test_file 2>&1
```

### 3. Run Integration Tests

**Using flutter test integration_test:**
```bash
flutter test integration_test/ --reporter json 2>&1
```

**Using flutter drive (legacy):**
```bash
flutter drive --target=test_driver/app.dart --driver=test_driver/app_test.dart -d $device_id 2>&1
```

**Using Patrol (modern):**
```bash
patrol test -d $device_id 2>&1
```

### 4. Parse and Display Results

Parse JSON reporter output:

```
Flutter Test Results
══════════════════════════════════════════════════════════════
Flutter 3.19.0 | Dart 3.3.0

  ✓ test/unit/models/user_test.dart
    ✓ User model › creates from JSON              2ms
    ✓ User model › serializes to JSON              1ms
    ✓ User model › validates email                 1ms

  ✓ test/widget/login_screen_test.dart
    ✓ LoginScreen › renders form fields           45ms
    ✓ LoginScreen › shows error on invalid        38ms
    ✓ LoginScreen › navigates on success          52ms

  ✗ test/widget/dashboard_test.dart
    ✓ Dashboard › shows loading state             30ms
    ✗ Dashboard › displays chart data             67ms
      Expected: exactly one matching node
      Actual: zero matching nodes
      at dashboard_test.dart:42

──────────────────────────────────────────────────────────────
Tests:   7 passed, 1 failed, 8 total
Duration: 3.2s
Coverage: 72.3% lines (use --coverage for details)
══════════════════════════════════════════════════════════════
```

### 5. Post-Run

- Show pass/fail summary
- If `--coverage`, show coverage percentage and suggest `genhtml` for HTML report
- For golden test failures, suggest `--update-goldens` if intentional
- For integration test failures, note device/emulator logs

## Error Recovery

- If `flutter` not found: provide installation instructions for the user's OS
- If `pubspec.yaml` not found: this is not a Flutter project, suggest other skills
- If no test files found: suggest creating tests in `test/` directory
- If device not found (integration tests): suggest `flutter devices` to check
- If golden test fails: ask if UI change was intentional → `--update-goldens`
- If pub dependencies not resolved: suggest `flutter pub get`

## Related Skills

- Check devices: `/devices`
- Install APK (if Flutter Android): `/install-apk`
- Run native mobile tests: `/mobile-test`
- View results: `/test-report --last`
- Setup environment: `/setup-test-env`
