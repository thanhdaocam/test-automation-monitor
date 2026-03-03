# Test Automation Monitor - Project Conventions

## What is this?

A comprehensive set of **24 Claude Code Skills** (slash commands) for automation testing across Web, Mobile, API, Unit, Performance, Security, Visual, and more.

## Available Skills

### Core Testing (v1.0)
- `/setup-test-env` - Check & install prerequisites
- `/devices` - List connected Android/iOS devices
- `/appium` - Start/stop/status Appium server (args: `start`, `stop`, `status`, `install-drivers`)
- `/install-apk` - Install APK on Android device (args: `<apk-path> [device-id]`)
- `/run-test` - Run Playwright or k6 tests (args: `[test-file] [--headed] [--debug]`)
- `/mobile-test` - Run WebdriverIO+Appium mobile tests (args: `<test-file> [--device id] [--platform android|ios]`)
- `/test-report` - View test results (args: `[--last] [--failures-only]`)
- `/monitor` - System status dashboard
- `/scaffold-test` - Create test project from template (args: `[web|mobile|performance|all]`)

### Extended Testing (v2.0)
- `/api-test` - Run API/REST tests with Playwright request or Supertest
- `/unit-test` - Run unit tests with Vitest or Jest
- `/db-test` - Run database integration tests
- `/cypress-test` - Run Cypress E2E and component tests
- `/flutter-test` - Run Flutter unit, widget, and integration tests
- `/rn-test` - Run React Native tests (Jest + Detox)
- `/visual-test` - Visual regression testing (Playwright screenshots or BackstopJS)
- `/contract-test` - Consumer-driven contract tests (Pact)
- `/smoke-test` - Quick post-deployment health checks

### Quality & Security (v2.0)
- `/security-test` - Dependency audit, code analysis, OWASP checks
- `/a11y-test` - Accessibility testing (WCAG 2.2 with axe-core)
- `/lighthouse` - Performance, a11y, SEO, best practices audit

### DevOps & Utilities (v2.0)
- `/ci-gen` - Generate CI/CD pipeline configs (GitHub Actions, GitLab, Jenkins, Azure)
- `/docker-test` - Manage Docker test environments
- `/notify` - Send test results to Slack/Teams/Discord/Email
- `/test-data` - Generate, seed, and manage test data with Faker.js

## Test File Conventions

- Web tests: `*.spec.ts` or `*.test.ts` in `tests/web/`
- Mobile tests: `*.mobile.ts` in `tests/mobile/`
- Performance tests: `*.k6.js` in `tests/performance/`
- API tests: `*.api.ts` in `tests/api/`
- Unit tests: `*.unit.test.ts` or `*.test.ts`
- DB tests: `*.db.test.ts` in `tests/db/`
- Cypress tests: `*.cy.ts` in `cypress/e2e/`
- Visual tests: `*.visual.ts`
- Contract tests: `*.pact.ts`
- Smoke tests: `*.smoke.ts` (or tagged `@smoke`)
- A11y tests: `*.a11y.ts`
- Flutter tests: `*_test.dart` in `test/`
- React Native E2E: `*.e2e.ts` in `e2e/`
- Detox config: `.detoxrc.js`

## Directory Structure

- `templates/` - Config templates and sample tests for all frameworks
- `templates/ci/` - CI/CD pipeline templates (GitHub Actions, GitLab, Jenkins, Azure)
- `scripts/` - Helper bash scripts for parsing results
- `.claude/skills/` - Skill definitions (SKILL.md files)

## Workflow

1. `/setup-test-env` to verify environment
2. `/scaffold-test all` to create test files (or write your own)
3. `/devices` to check available devices (for mobile)
4. `/appium start` before mobile tests
5. `/run-test` for web/perf, `/mobile-test` for mobile, `/api-test` for API, `/unit-test` for unit
6. `/test-report` to view results
7. `/monitor` for overall status
8. `/ci-gen github` to generate CI/CD pipeline
9. `/notify slack` to send results to team
