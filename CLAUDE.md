# Test Automation Monitor - Project Conventions

## What is this?

A set of Claude Code Skills (slash commands) for automation testing across Web, Mobile (Android/iOS), and Performance.

## Available Skills

- `/setup-test-env` - Check & install prerequisites
- `/devices` - List connected Android/iOS devices
- `/appium` - Start/stop/status Appium server (args: `start`, `stop`, `status`, `install-drivers`)
- `/install-apk` - Install APK on Android device (args: `<apk-path> [device-id]`)
- `/run-test` - Run Playwright or k6 tests (args: `[test-file] [--headed] [--debug]`)
- `/mobile-test` - Run WebdriverIO+Appium mobile tests (args: `<test-file> [--device id] [--platform android|ios]`)
- `/test-report` - View test results (args: `[--last] [--failures-only]`)
- `/monitor` - System status dashboard
- `/scaffold-test` - Create test project from template (args: `[web|mobile|performance|all]`)

## Test File Conventions

- Web tests: `*.spec.ts` or `*.test.ts` in `tests/web/`
- Mobile tests: `*.mobile.ts` in `tests/mobile/`
- Performance tests: `*.k6.js` in `tests/performance/`

## Directory Structure

- `templates/` - Config templates for Playwright, WDIO, k6
- `scripts/` - Helper bash scripts for parsing results
- `.claude/skills/` - Skill definitions (SKILL.md files)

## Workflow

1. `/setup-test-env` to verify environment
2. `/scaffold-test web` to create test files (or write your own)
3. `/devices` to check available devices (for mobile)
4. `/appium start` before mobile tests
5. `/run-test` for web/perf tests, `/mobile-test` for mobile tests
6. `/test-report` to view results
7. `/monitor` for overall status
