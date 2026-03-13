# Test Automation Monitor

![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)
![Skills](https://img.shields.io/badge/skills-25-green.svg)
![License](https://img.shields.io/badge/license-MIT-yellow.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Skills-purple.svg)

A comprehensive set of **25 Claude Code Skills** (slash commands) for automation testing across **Web**, **Mobile**, **API**, **Unit**, **Performance**, **Security**, **Visual**, and more — run directly inside Claude Code.

## What's New in v2.1

- **Documentation overhaul**: CHANGELOG.md, CONTRIBUTING.md, auto-generated skills table
- **Auto-docs script**: `node scripts/generate-docs.js` generates a skills reference table from SKILL.md frontmatter
- **Cross-platform fixes**: PowerShell scripts alongside Bash for Windows compatibility
- **Security hardening**: All skills use scoped `allowed-tools` (principle of least privilege)
- **Contributor guide**: Step-by-step guide for creating new skills

> See [CHANGELOG.md](CHANGELOG.md) for full version history.

## Features

**25 slash commands** covering the entire automation test workflow:

### Core Testing (v1.0)

| Command | Description |
|---------|-------------|
| `/setup-test-env` | Check & install Node.js, Java, ADB, Appium, Playwright, k6 |
| `/devices` | List connected Android/iOS devices and emulators |
| `/appium` | Start / stop / check status of Appium server |
| `/install-apk` | Install APK onto Android device or emulator |
| `/run-test` | Run Playwright web tests or k6 performance tests |
| `/mobile-test` | Run WebdriverIO + Appium tests on mobile devices |
| `/test-report` | View test results with pass/fail statistics |
| `/monitor` | System status dashboard: devices, services, tests |
| `/scaffold-test` | Create new test project from templates |

### Extended Testing (v2.0)

| Command | Description |
|---------|-------------|
| `/api-test` | Run API/REST tests (Playwright request or Supertest) |
| `/unit-test` | Run unit tests (Vitest or Jest) |
| `/db-test` | Run database integration tests |
| `/cypress-test` | Run Cypress E2E and component tests |
| `/flutter-test` | Run Flutter unit, widget, and integration tests |
| `/rn-test` | Run React Native tests (Jest + Detox) |
| `/visual-test` | Visual regression testing (screenshot comparison) |
| `/contract-test` | Consumer-driven contract tests (Pact) |
| `/smoke-test` | Quick post-deployment health checks |

### Quality & Security (v2.0)

| Command | Description |
|---------|-------------|
| `/security-test` | Dependency audit, code analysis, OWASP Top 10 |
| `/a11y-test` | Accessibility testing (WCAG 2.2, axe-core) |
| `/lighthouse` | Google Lighthouse audit (performance, SEO, a11y) |

### DevOps & Utilities (v2.0)

| Command | Description |
|---------|-------------|
| `/ci-gen` | Generate CI/CD pipelines (GitHub Actions, GitLab, Jenkins, Azure) |
| `/docker-test` | Manage Docker test environments |
| `/notify` | Send test results to Slack/Teams/Discord/Email |
| `/test-data` | Generate, seed, and manage test data (Faker.js) |

### Multi-Platform Support

- **Web**: Playwright, Cypress (Chrome, Firefox, Safari, Edge)
- **Android** (.apk): Appium 2.0 + WebdriverIO + UiAutomator2
- **iOS** (.ipa): Appium 2.0 + WebdriverIO + XCUITest
- **WebView**: Appium context switching (NATIVE ↔ WEBVIEW)
- **Flutter**: flutter test + patrol + flutter drive
- **React Native**: Jest + Detox
- **API**: Playwright request API, Supertest, Newman
- **Performance**: k6 load testing
- **Visual**: Playwright screenshots, BackstopJS
- **Security**: npm audit, Snyk, OWASP checks
- **Accessibility**: axe-core + Playwright
- **Contract**: Pact consumer-driven contracts

## Quick Start

### 1. Clone repo

```bash
git clone https://github.com/thanhdaocam/test-automation-monitor.git
```

### 2. Copy skills into your project

```bash
# Copy everything (skills + templates + scripts)
cp -r test-automation-monitor/.claude/ your-project/.claude/
cp -r test-automation-monitor/scripts/ your-project/scripts/
cp -r test-automation-monitor/templates/ your-project/templates/
```

### 3. Open Claude Code and use

```bash
cd your-project
claude

# Inside Claude Code:
> /setup-test-env          # Check environment
> /scaffold-test all       # Create sample tests
> /run-test                # Run web tests
> /unit-test               # Run unit tests
> /api-test                # Run API tests
> /security-test           # Security scan
> /lighthouse https://example.com  # Audit website
> /monitor                 # Status dashboard
```

## Prerequisites

### Required

```bash
claude --version     # Claude Code
node --version       # Node.js 20+
```

### Per test type

| Test Type | Requirements |
|-----------|-------------|
| Web (Playwright) | `npm install -D @playwright/test && npx playwright install` |
| Web (Cypress) | `npm install -D cypress` |
| Mobile (Android) | Java 11+, ADB, Appium 2.0, uiautomator2 driver |
| Mobile (iOS) | macOS, Xcode, Appium, xcuitest driver |
| Flutter | Flutter SDK |
| React Native | Detox |
| Performance | k6 |
| Unit | Vitest or Jest (auto-detected) |
| API | Playwright (built-in) or Supertest |
| Visual | `@playwright/test` or `backstopjs` |
| Contract | `@pact-foundation/pact` |
| Security | npm audit (built-in), optional Snyk |
| Accessibility | `@axe-core/playwright` |
| Docker | Docker Desktop |

Or run `/setup-test-env` to check everything automatically.

## Project Structure

```
test-automation-monitor/
├── .claude/skills/                    # 25 Claude Code Skills
│   ├── setup-test-env/SKILL.md       # Environment setup
│   ├── devices/SKILL.md              # Device management
│   ├── appium/SKILL.md               # Appium server
│   ├── install-apk/SKILL.md          # APK installation
│   ├── run-test/SKILL.md             # Web/perf tests
│   ├── mobile-test/SKILL.md          # Mobile tests
│   ├── test-report/SKILL.md          # Test results
│   ├── monitor/SKILL.md              # Status dashboard
│   ├── scaffold-test/SKILL.md        # Project scaffolding
│   ├── api-test/SKILL.md             # API testing
│   ├── unit-test/SKILL.md            # Unit testing
│   ├── db-test/SKILL.md              # Database testing
│   ├── cypress-test/SKILL.md         # Cypress testing
│   ├── flutter-test/SKILL.md         # Flutter testing
│   ├── rn-test/SKILL.md              # React Native testing
│   ├── visual-test/SKILL.md          # Visual regression
│   ├── contract-test/SKILL.md        # Contract testing
│   ├── smoke-test/SKILL.md           # Smoke testing
│   ├── security-test/SKILL.md        # Security scanning
│   ├── a11y-test/SKILL.md            # Accessibility
│   ├── lighthouse/SKILL.md           # Lighthouse audit
│   ├── ci-gen/SKILL.md               # CI/CD generator
│   ├── docker-test/SKILL.md          # Docker environments
│   ├── notify/SKILL.md               # Notifications
│   └── test-data/SKILL.md            # Test data management
│
├── scripts/                           # Helper scripts
│   ├── check-env.sh
│   ├── check-env.ps1                 # Windows PowerShell variant
│   ├── generate-docs.js              # Auto-generate skills table
│   ├── parse-playwright-results.sh
│   ├── parse-playwright-results.ps1  # Windows PowerShell variant
│   ├── parse-wdio-results.sh
│   ├── parse-k6-results.sh
│   ├── parse-api-results.sh
│   ├── parse-jest-results.sh
│   └── parse-cypress-results.sh
│
├── templates/                         # Test config templates
│   ├── ci/                           # CI/CD templates
│   │   ├── github-actions.yml
│   │   ├── gitlab-ci.yml
│   │   ├── jenkinsfile
│   │   └── azure-pipelines.yml
│   ├── playwright.config.ts
│   ├── wdio.conf.ts
│   ├── cypress.config.ts
│   ├── detox.config.ts
│   ├── backstop.config.js
│   ├── docker-compose.test.yml
│   ├── notification-config.json
│   ├── sample.spec.ts                # Playwright
│   ├── sample.mobile.ts              # WebdriverIO
│   ├── sample.k6.js                  # k6 performance
│   ├── sample.api.ts                 # API test
│   ├── sample.unit.test.ts           # Vitest unit
│   ├── sample.db.test.ts             # Database test
│   ├── sample.cy.ts                  # Cypress
│   ├── sample.e2e.ts                 # Detox (RN)
│   ├── sample.visual.ts              # Visual regression
│   ├── sample.pact.ts                # Contract test
│   ├── sample.a11y.ts                # Accessibility
│   ├── sample.smoke.ts               # Smoke test
│   ├── sample_flutter_test.dart      # Flutter
│   └── test-data-factory.ts          # Faker.js factory
│
├── CLAUDE.md                          # Project conventions
├── README.md                          # This file
├── CHANGELOG.md                       # Version history (Keep a Changelog)
├── CONTRIBUTING.md                    # Contributor guide
├── PLAN.md                            # Architecture decisions
├── TODO.md                            # Task tracking
├── INSTALL.md                         # Installation guide
├── SKILLS.md                          # Skills reference
├── SKILLS-TABLE.md                    # Auto-generated skills table
├── USER-GUIDE.md                      # Detailed user guide
└── AI-AGENT-GUIDE.md                  # AI agent routing guide
```

## Architecture

The system uses a **Skills-as-Markdown** architecture: each skill is a `SKILL.md` file with YAML frontmatter and Markdown instructions. Claude Code reads the file, reasons about the context, and executes commands via its built-in tools.

```
                           USER
                            |
                     /run-test login.spec.ts
                            |
                            v
+-----------------------------------------------------------+
|                      CLAUDE CODE                          |
|                                                           |
|   .claude/skills/run-test/SKILL.md                       |
|          |                                                |
|          v                                                |
|   +-------------+  +----------+  +--------+  +--------+  |
|   |    Bash     |  |   Read   |  |  Grep  |  |  Glob  |  |
|   |  (execute)  |  | (files)  |  |(search)|  | (find) |  |
|   +------+------+  +----------+  +--------+  +--------+  |
|          |                                                |
+----------+------------------------------------------------+
           |
           v
+-----------------------------------------------------------+
|                     TEST ENGINES                          |
|                                                           |
|  +----------+ +-------+ +------+ +------+ +--------+     |
|  |Playwright| |Cypress| |Vitest| | Jest | |   k6   |     |
|  +----+-----+ +---+---+ +--+---+ +--+---+ +---+----+     |
|       |            |        |        |         |          |
|  +----+---+  +----+---+    |   +----+----+    |          |
|  |Browser |  |Browser |    |   |  Detox  |    |          |
|  | + API  |  |  E2E   |    |   |React Nat|    |          |
|  +--------+  +--------+    |   +----+----+    |          |
|                             |        |         |          |
|  +-----------+ +---------+  |   +----+----+    |          |
|  |WebdriverIO| | Flutter |  |   | Appium  |    |          |
|  +-----+-----+ +----+----+  |   +----+----+    |          |
|        |             |       |        |         |          |
|  +-----+-------------+-------+--------+-+       |          |
|  |           Mobile Devices              |       |          |
|  |    Android  |  iOS  |  WebView       |       |          |
|  +---------------------------------------+       |          |
|                                                  |          |
|  +---------+ +-------+ +---------+ +------------+          |
|  |axe-core | | Pact  | |BackstopJ| | HTTP Load  |          |
|  |  A11y   | |Contract| | Visual | |  Testing   |          |
|  +---------+ +--------+ +--------+ +------------+          |
+-----------------------------------------------------------+
```

### How a Skill Executes

```
1. User types:     /run-test login.spec.ts --headed
2. Claude loads:   .claude/skills/run-test/SKILL.md
3. Dynamic context: !`commands` run to gather project info
4. Claude reasons:  Detects Playwright, builds npx command
5. Executes:        npx playwright test login.spec.ts --headed
6. Parses output:   JSON results -> formatted pass/fail table
7. Shows results:   Summary with counts, duration, failures
```

## Documentation

| File | Description |
|------|-------------|
| [CHANGELOG.md](CHANGELOG.md) | Version history (v1.0 -> v2.0 -> v2.1) |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to create skills, PR guidelines |
| [INSTALL.md](INSTALL.md) | Detailed installation guide |
| [SKILLS.md](SKILLS.md) | Complete skills reference with arguments |
| [SKILLS-TABLE.md](SKILLS-TABLE.md) | Auto-generated skills summary table |
| [USER-GUIDE.md](USER-GUIDE.md) | Detailed usage guide for each skill |
| [AI-AGENT-GUIDE.md](AI-AGENT-GUIDE.md) | Decision matrix for AI agent routing |
| [PLAN.md](PLAN.md) | Architecture and design decisions |
| [TODO.md](TODO.md) | Task tracking |

### Auto-Generate Documentation

```bash
# Print skills table to stdout
node scripts/generate-docs.js

# Write to SKILLS-TABLE.md
node scripts/generate-docs.js --output
```

## License

by ThanhDaoCam

## Related Documentation

- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code)
- [Playwright](https://playwright.dev) | [Cypress](https://www.cypress.io)
- [Appium 2.0](https://appium.io/docs/en/latest/) | [WebdriverIO](https://webdriver.io)
- [Vitest](https://vitest.dev) | [Jest](https://jestjs.io) | [Detox](https://wix.github.io/Detox/)
- [k6](https://k6.io/docs/) | [Pact](https://pact.io) | [axe-core](https://www.deque.com/axe/)
- [Lighthouse](https://developer.chrome.com/docs/lighthouse/) | [BackstopJS](https://github.com/garris/BackstopJS)
