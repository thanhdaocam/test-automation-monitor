# Test Automation Monitor

Bộ **Claude Code Skills** toàn diện để monitor và quản lý automation test trên **Web**, **Mobile**, **API**, **Unit**, **Performance**, **Security**, **Visual** và nhiều hơn nữa — chạy trực tiếp trong Claude Code bằng slash commands.

## Features

**24 slash commands** cho toàn bộ automation test workflow:

### Core Testing (v1.0)

| Command | Mô tả |
|---------|-------|
| `/setup-test-env` | Kiểm tra & cài đặt Node.js, Java, ADB, Appium, Playwright, k6 |
| `/devices` | List Android/iOS devices đang kết nối |
| `/appium` | Start / stop / check status Appium server |
| `/install-apk` | Cài APK lên Android device |
| `/run-test` | Chạy Playwright hoặc k6 tests |
| `/mobile-test` | Chạy WebdriverIO + Appium tests trên mobile |
| `/test-report` | Xem kết quả test, thống kê pass/fail |
| `/monitor` | Tổng quan status: devices, services, tests |
| `/scaffold-test` | Tạo test project mới từ template |

### Extended Testing (v2.0 - NEW)

| Command | Mô tả |
|---------|-------|
| `/api-test` | Chạy API/REST tests (Playwright request hoặc Supertest) |
| `/unit-test` | Chạy unit tests (Vitest hoặc Jest) |
| `/db-test` | Chạy database integration tests |
| `/cypress-test` | Chạy Cypress E2E và component tests |
| `/flutter-test` | Chạy Flutter unit, widget, integration tests |
| `/rn-test` | Chạy React Native tests (Jest + Detox) |
| `/visual-test` | Visual regression testing (screenshots comparison) |
| `/contract-test` | Consumer-driven contract tests (Pact) |
| `/smoke-test` | Quick post-deployment health checks |

### Quality & Security (v2.0 - NEW)

| Command | Mô tả |
|---------|-------|
| `/security-test` | Dependency audit, code analysis, OWASP Top 10 |
| `/a11y-test` | Accessibility testing (WCAG 2.2, axe-core) |
| `/lighthouse` | Google Lighthouse audit (performance, SEO, a11y) |

### DevOps & Utilities (v2.0 - NEW)

| Command | Mô tả |
|---------|-------|
| `/ci-gen` | Generate CI/CD pipelines (GitHub Actions, GitLab, Jenkins, Azure) |
| `/docker-test` | Quản lý Docker test environments |
| `/notify` | Gửi test results tới Slack/Teams/Discord/Email |
| `/test-data` | Generate, seed, manage test data (Faker.js) |

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

### 2. Copy skills vào project của bạn

```bash
# Copy toàn bộ (skills + templates + scripts)
cp -r test-automation-monitor/.claude/ your-project/.claude/
cp -r test-automation-monitor/scripts/ your-project/scripts/
cp -r test-automation-monitor/templates/ your-project/templates/
```

### 3. Mở Claude Code và dùng

```bash
cd your-project
claude

# Trong Claude Code:
> /setup-test-env          # Kiểm tra environment
> /scaffold-test all       # Tạo sample tests
> /run-test                # Chạy web tests
> /unit-test               # Chạy unit tests
> /api-test                # Chạy API tests
> /security-test           # Scan bảo mật
> /lighthouse https://example.com  # Audit website
> /monitor                 # Dashboard tổng quan
```

## Prerequisites

### Bắt buộc

```bash
claude --version     # Claude Code
node --version       # Node.js 20+
```

### Tuỳ theo loại test

| Loại test | Cần cài |
|-----------|---------|
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

Hoặc chạy `/setup-test-env` để tự động kiểm tra tất cả.

## Project Structure

```
test-automation-monitor/
├── .claude/skills/                    # 24 Claude Code Skills
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
│   ├── parse-playwright-results.sh
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
├── PLAN.md                            # Architecture decisions
├── TODO.md                            # Task tracking
├── INSTALL.md                         # Installation guide
├── SKILLS.md                          # Skills reference
├── USER-GUIDE.md                      # Detailed user guide
└── AI-AGENT-GUIDE.md                  # AI agent routing guide
```

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    CLAUDE CODE                           │
│                                                          │
│  User: /run-test login.spec.ts                          │
│       │                                                  │
│       ▼                                                  │
│  ┌─────────────┐                                        │
│  │  SKILL.md   │  ← Prompt instructions                │
│  └──────┬──────┘                                        │
│         │                                                │
│         ▼                                                │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │    Bash     │    │    Read     │    │    Grep     │  │
│  │  (execute)  │    │  (results)  │    │  (search)   │  │
│  └──────┬──────┘    └─────────────┘    └─────────────┘  │
│         │                                                │
└─────────┼────────────────────────────────────────────────┘
          │
          ▼
┌──────────────────────────────────────────────────────────┐
│                    TEST ENGINES                           │
│                                                          │
│  ┌──────────┐ ┌───────┐ ┌──────┐ ┌───────┐ ┌────────┐  │
│  │Playwright│ │Cypress│ │Vitest│ │ Jest  │ │  k6    │  │
│  └────┬─────┘ └───┬───┘ └──┬───┘ └───┬───┘ └───┬────┘  │
│       │           │        │         │         │         │
│  ┌────┴───┐  ┌────┴───┐   │    ┌────┴────┐    │         │
│  │Browser │  │Browser │   │    │  Detox  │    │         │
│  │ + API  │  │  E2E   │   │    │React Nat│    │         │
│  └────────┘  └────────┘   │    └────┬────┘    │         │
│                            │         │         │         │
│  ┌──────────┐  ┌──────────┤    ┌────┴────┐    │         │
│  │WebdriverIO│ │ Flutter  │    │ Appium  │    │         │
│  └────┬─────┘  └────┬────┘    └────┬────┘    │         │
│       │              │              │         │         │
│  ┌────┴──────────────┴──────────────┴────┐    │         │
│  │         Mobile Devices                │    │         │
│  │    Android  |  iOS  |  WebView       │    │         │
│  └───────────────────────────────────────┘    │         │
│                                               │         │
│  ┌─────────┐ ┌────────┐ ┌─────────┐ ┌───────┴──┐      │
│  │axe-core │ │  Pact  │ │BackstopJS│ │HTTP Load│      │
│  │  A11y   │ │Contract│ │ Visual  │ │ Testing │      │
│  └─────────┘ └────────┘ └─────────┘ └──────────┘      │
└──────────────────────────────────────────────────────────┘
```

## Documentation

| File | Nội dung |
|------|----------|
| [INSTALL.md](INSTALL.md) | Hướng dẫn cài đặt chi tiết |
| [SKILLS.md](SKILLS.md) | Reference tất cả skills + arguments |
| [USER-GUIDE.md](USER-GUIDE.md) | Hướng dẫn chi tiết từng test function |
| [AI-AGENT-GUIDE.md](AI-AGENT-GUIDE.md) | Decision matrix cho AI agents |
| [PLAN.md](PLAN.md) | Architecture & design decisions |
| [TODO.md](TODO.md) | Task tracking |

## License

by ThanhDaoCam

## Related Documentation

- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code)
- [Playwright](https://playwright.dev) | [Cypress](https://www.cypress.io)
- [Appium 2.0](https://appium.io/docs/en/latest/) | [WebdriverIO](https://webdriver.io)
- [Vitest](https://vitest.dev) | [Jest](https://jestjs.io) | [Detox](https://wix.github.io/Detox/)
- [k6](https://k6.io/docs/) | [Pact](https://pact.io) | [axe-core](https://www.deque.com/axe/)
- [Lighthouse](https://developer.chrome.com/docs/lighthouse/) | [BackstopJS](https://github.com/garris/BackstopJS)
