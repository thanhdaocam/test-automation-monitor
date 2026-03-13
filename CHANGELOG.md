# Changelog

All notable changes to the **Test Automation Monitor** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-03-13

### Added
- `CHANGELOG.md` following Keep a Changelog format
- `CONTRIBUTING.md` with skill creation guide, PR guidelines, and code of conduct
- `scripts/generate-docs.js` to auto-generate skills reference table from SKILL.md frontmatter
- Badges in README.md for version, license, and skills count
- Improved architecture diagram in README.md
- v2.1 features section in README.md

### Changed
- Updated README.md with enhanced documentation structure and English developer docs
- Updated CLAUDE.md to reference v2.1 improvements

### Fixed
- Cross-platform compatibility improvements (Windows PowerShell scripts alongside Bash)
- Script consistency across `check-env.sh` / `check-env.ps1` and `parse-playwright-results.sh` / `parse-playwright-results.ps1`

### Security
- All skills use scoped `allowed-tools` to restrict tool access (principle of least privilege)
- No secrets or credentials stored in repository

## [2.0.0] - 2026-03-12

### Added

#### Extended Testing Skills (9 new skills)
- `/api-test` — Run API/REST tests with Playwright request API, Supertest, or Newman (Postman collections)
- `/unit-test` — Run unit tests with Vitest or Jest, with coverage and watch mode support
- `/db-test` — Run database integration tests with Prisma, Knex, TypeORM, or raw SQL
- `/cypress-test` — Run Cypress E2E and component tests with multi-browser support
- `/flutter-test` — Run Flutter unit, widget, and integration tests with coverage and golden file support
- `/rn-test` — Run React Native tests: Jest unit tests and Detox E2E on real devices/emulators
- `/visual-test` — Visual regression testing using Playwright `toHaveScreenshot()` or BackstopJS
- `/contract-test` — Consumer-driven contract tests using Pact with broker publishing support
- `/smoke-test` — Quick post-deployment health checks across all test frameworks

#### Quality & Security Skills (3 new skills)
- `/security-test` — Dependency audit (npm audit, Snyk), static code analysis, OWASP Top 10 checks
- `/a11y-test` — Accessibility testing against WCAG 2.2 guidelines using axe-core + Playwright
- `/lighthouse` — Google Lighthouse audit for performance, accessibility, SEO, and best practices

#### DevOps & Utilities Skills (4 new skills)
- `/ci-gen` — Generate CI/CD pipeline configs for GitHub Actions, GitLab CI, Jenkins, and Azure Pipelines
- `/docker-test` — Manage Docker test environments: start/stop containers, run tests in isolation
- `/notify` — Send test results to Slack, Microsoft Teams, Discord, or Email via webhooks
- `/test-data` — Generate, seed, and manage test data with Faker.js factories

#### Templates (15 new templates)
- `templates/sample.api.ts` — Playwright API test sample
- `templates/sample.unit.test.ts` — Vitest unit test sample
- `templates/sample.db.test.ts` — Database integration test sample
- `templates/sample.cy.ts` — Cypress E2E test sample
- `templates/sample_flutter_test.dart` — Flutter test sample
- `templates/sample.e2e.ts` — Detox (React Native) E2E test sample
- `templates/sample.visual.ts` — Visual regression test sample
- `templates/sample.pact.ts` — Pact contract test sample
- `templates/sample.smoke.ts` — Smoke test sample
- `templates/sample.a11y.ts` — Accessibility test sample
- `templates/test-data-factory.ts` — Faker.js data factory
- `templates/cypress.config.ts` — Cypress configuration
- `templates/detox.config.ts` — Detox configuration
- `templates/backstop.config.js` — BackstopJS configuration
- `templates/docker-compose.test.yml` — Docker Compose for test environments
- `templates/notification-config.json` — Notification webhook configuration

#### CI/CD Templates
- `templates/ci/github-actions.yml` — GitHub Actions workflow
- `templates/ci/gitlab-ci.yml` — GitLab CI pipeline
- `templates/ci/jenkinsfile` — Jenkins pipeline
- `templates/ci/azure-pipelines.yml` — Azure Pipelines

#### Scripts (3 new scripts)
- `scripts/parse-api-results.sh` — Parse API test results
- `scripts/parse-jest-results.sh` — Parse Jest/Vitest test results
- `scripts/parse-cypress-results.sh` — Parse Cypress test results

#### Documentation (3 new docs)
- `USER-GUIDE.md` — Detailed user guide with workflow examples for every skill
- `AI-AGENT-GUIDE.md` — Decision matrix for AI agents to route to the correct skill
- `SKILLS.md` — Complete skills reference with arguments, examples, and output samples

### Changed
- Updated `README.md` with full v2.0 feature list and multi-platform support table
- Updated `CLAUDE.md` with all 25 skills and updated workflow
- Updated `TODO.md` to track all v2.0 phases

## [1.0.0] - 2026-03-09

### Added

#### Core Testing Skills (9 skills)
- `/setup-test-env` — Check and install prerequisites (Node.js, Java, ADB, Appium, Playwright, k6)
- `/devices` — List connected Android/iOS devices with model, OS version, and status
- `/appium` — Start, stop, and check status of Appium 2.0 server; install drivers
- `/install-apk` — Install APK files onto Android devices or emulators
- `/run-test` — Run Playwright web tests or k6 performance tests with auto-detection
- `/mobile-test` — Run WebdriverIO + Appium tests on Android/iOS with WebView support
- `/test-report` — View test results from Playwright, WDIO, k6 (JSON, JUnit XML)
- `/monitor` — System status dashboard: services, devices, tool versions, last test results
- `/scaffold-test` — Create test project from templates with dependency installation

#### Templates (5 templates)
- `templates/playwright.config.ts` — Playwright base configuration
- `templates/wdio.conf.ts` — WebdriverIO + Appium base configuration
- `templates/sample.spec.ts` — Sample Playwright test
- `templates/sample.mobile.ts` — Sample WebdriverIO mobile test
- `templates/sample.k6.js` — Sample k6 performance test

#### Scripts (4 scripts)
- `scripts/check-env.sh` — Environment prerequisite checker (outputs JSON)
- `scripts/parse-playwright-results.sh` — Parse Playwright JSON reports
- `scripts/parse-wdio-results.sh` — Parse WebdriverIO JSON reports
- `scripts/parse-k6-results.sh` — Parse k6 JSON output

#### Documentation
- `CLAUDE.md` — Project conventions for Claude Code
- `README.md` — Project overview and quick start guide
- `PLAN.md` — Architecture decisions and implementation plan
- `INSTALL.md` — Detailed installation guide
- `TODO.md` — Task tracking

#### Architecture
- Skills-as-Markdown architecture: each skill is a `SKILL.md` with YAML frontmatter
- Claude AI as the reasoning engine: auto-detects frameworks, builds commands, parses output
- No database required: results stored as JSON files in the filesystem
- No server required: everything runs locally through Claude Code
- Extensible: add a new skill by creating a folder with a `SKILL.md` file

### Supported Platforms
- **Web**: Playwright (Chrome, Firefox, Safari, Edge)
- **Android**: Appium 2.0 + WebdriverIO + UiAutomator2
- **iOS**: Appium 2.0 + WebdriverIO + XCUITest (macOS only)
- **WebView**: Appium context switching (NATIVE ↔ WEBVIEW)
- **Performance**: k6 load testing

[2.1.0]: https://github.com/thanhdaocam/test-automation-monitor/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/thanhdaocam/test-automation-monitor/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/thanhdaocam/test-automation-monitor/releases/tag/v1.0.0
