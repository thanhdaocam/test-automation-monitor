# AI Agent Guide - Test Automation Skill Router

> **Purpose**: This document is a structured reference for AI agents. Given a user's test request, use this guide to determine the correct skill(s) to invoke, in what order, and with what parameters.
> **Version**: 2.0 | **Total Skills**: 24

---

## Quick Decision Table

| User wants to... | Primary Skill | Pre-requisite Skills | Arguments |
|---|---|---|---|
| Check environment setup | `/setup-test-env` | None | (none) |
| See connected devices | `/devices` | None | (none) |
| Start/stop Appium server | `/appium` | None | `start \| stop \| status` |
| Install APK on device | `/install-apk` | `/devices` | `<apk-path> [device-id]` |
| Run web test (Playwright) | `/run-test` | None | `<file.spec.ts> [--headed]` |
| Run performance test (k6) | `/run-test` | None | `<file.k6.js>` |
| Run mobile test (Appium) | `/mobile-test` | `/appium start`, `/devices` | `<file.mobile.ts> [--device] [--platform]` |
| Run API test | `/api-test` | None | `<file.api.ts> [--base-url] [--env]` |
| Run unit test | `/unit-test` | None | `[file] [--coverage] [--watch]` |
| Run database test | `/db-test` | None | `[file] [--reset] [--seed]` |
| Run Cypress test | `/cypress-test` | None | `[file] [--headed] [--browser]` |
| Run Flutter test | `/flutter-test` | Flutter SDK | `[file] [--integration] [--coverage]` |
| Run React Native test | `/rn-test` | None | `[file] [--e2e] [--platform]` |
| Run visual regression | `/visual-test` | None | `[file] [--update] [--threshold]` |
| Run contract test | `/contract-test` | None | `[file] [--provider] [--publish]` |
| Run smoke test | `/smoke-test` | None | `[--env] [--url]` |
| Security scan | `/security-test` | None | `[deps\|code\|owasp\|full] [--fix]` |
| Accessibility test | `/a11y-test` | None | `[file\|url] [--standard]` |
| Lighthouse audit | `/lighthouse` | None | `<url> [--category] [--device]` |
| Generate CI/CD pipeline | `/ci-gen` | None | `github \| gitlab \| jenkins \| azure` |
| Manage Docker test env | `/docker-test` | Docker | `up \| down \| status \| run` |
| Send notifications | `/notify` | None | `slack \| teams \| discord \| email` |
| Generate test data | `/test-data` | None | `generate \| seed \| cleanup` |
| See test results | `/test-report` | None | `[--last] [--failures-only]` |
| View system dashboard | `/monitor` | None | (none) |
| Create test project | `/scaffold-test` | None | `web \| mobile \| performance \| all` |

---

## Skill Routing Logic

```
USER REQUEST
│
├── About environment/setup/install?
│   └── /setup-test-env
│
├── About devices (list, check, connect)?
│   └── /devices
│
├── About Appium server?
│   └── /appium <subcommand>
│
├── About installing an app (.apk)?
│   └── /install-apk <path> [device]
│
├── About running tests?
│   ├── Web E2E (Playwright)? → /run-test
│   ├── Web E2E (Cypress)? → /cypress-test
│   ├── Mobile native/hybrid? → /mobile-test
│   ├── Flutter? → /flutter-test
│   ├── React Native? → /rn-test
│   ├── API/REST? → /api-test
│   ├── Unit/component? → /unit-test
│   ├── Database? → /db-test
│   ├── Performance/load (k6)? → /run-test
│   ├── Visual regression? → /visual-test
│   ├── Contract (Pact)? → /contract-test
│   └── Smoke/health check? → /smoke-test
│
├── About quality/security?
│   ├── Security vulnerabilities? → /security-test
│   ├── Accessibility WCAG? → /a11y-test
│   └── Performance/SEO audit? → /lighthouse
│
├── About test results/reports?
│   └── /test-report [flags]
│
├── About CI/CD pipeline?
│   └── /ci-gen <platform>
│
├── About Docker test environment?
│   └── /docker-test <action>
│
├── About notifications?
│   └── /notify <platform>
│
├── About test data?
│   └── /test-data <action>
│
├── About system status?
│   └── /monitor
│
└── About creating/scaffolding tests?
    └── /scaffold-test <type>
```

---

## Detailed Skill Specifications

### Core Skills (v1.0)

#### 1. `/setup-test-env`
**Trigger**: "check my environment", "what's installed", "setup", "prerequisites"
**Checks**: Node.js, Java, ADB, Appium, drivers, Playwright, k6, ANDROID_HOME
**Follow-up**: `/devices`, `/appium start`, `/scaffold-test`

#### 2. `/devices`
**Trigger**: "list devices", "what phones connected", "show emulators"
**Does**: `adb devices -l` → formatted table
**Follow-up**: `/install-apk`, `/mobile-test`

#### 3. `/appium`
**Trigger**: "start appium", "stop appium", "appium status"
**Subcommands**: `start`, `stop`, `status`, `install-drivers`
**Args**: `--port <n>` (default 4723)

#### 4. `/install-apk`
**Trigger**: "install apk", "deploy app", `.apk` file path
**Required**: APK path. **Optional**: device-id
**Follow-up**: `/mobile-test`

#### 5. `/run-test`
**Trigger**: "run test", "playwright", "web test", "k6", "load test", "performance"
**Auto-detect**: `*.spec.ts` → Playwright, `*.k6.js` → k6
**Args**: `--headed`, `--debug`, `--grep`, `--workers`
**DO NOT use for**: mobile → `/mobile-test`, API-only → `/api-test`, Cypress → `/cypress-test`

#### 6. `/mobile-test`
**Trigger**: "mobile test", "test on phone", "appium test", `.mobile.ts`
**Auto-handles**: Appium start, device detection, wdio.conf generation
**Args**: `--device`, `--platform android|ios`, `--app`

#### 7. `/test-report`
**Trigger**: "show results", "test report", "what failed"
**Reads**: Playwright JSON, WDIO JSON, k6 JSON, Jest JSON, Cypress JSON, JUnit XML
**Args**: `--last`, `--failures-only`, `--file`, `--suite`

#### 8. `/monitor`
**Trigger**: "status", "dashboard", "overview", "health check"
**Shows**: services, devices, environment, last test run

#### 9. `/scaffold-test`
**Trigger**: "create test", "scaffold", "new project", "generate template"
**Types**: `web`, `mobile`, `performance`, `all`
**Args**: `--dir <path>`

---

### Extended Testing Skills (v2.0)

#### 10. `/api-test`
**Trigger**: "API test", "REST test", "test endpoint", "Postman", "Supertest"
**Auto-detect**: `*.api.ts` → Playwright, `*.postman.json` → Newman
**Args**: `--base-url`, `--env`, `--headers`, `--verbose`
**DO NOT use for**: web browser UI → `/run-test`, performance → `/run-test`

#### 11. `/unit-test`
**Trigger**: "unit test", "test function", "Vitest", "Jest", "coverage"
**Auto-detect**: Vitest (vitest.config), Jest (jest.config), or package.json scripts
**Args**: `--coverage`, `--watch`, `--bail`, `--update-snapshots`
**DO NOT use for**: E2E → `/run-test`, API → `/api-test`

#### 12. `/db-test`
**Trigger**: "database test", "DB test", "migration test", "Prisma test"
**Handles**: Prisma, Knex, TypeORM, raw SQL. Test DB setup/teardown
**Args**: `--reset`, `--seed`, `--db-url`
**DO NOT use for**: API tests that happen to use DB → `/api-test`

#### 13. `/cypress-test`
**Trigger**: "Cypress", "cypress test", `.cy.ts` file
**Args**: `--headed`, `--browser`, `--component`, `--spec`
**DO NOT use for**: Playwright projects → `/run-test`

#### 14. `/flutter-test`
**Trigger**: "Flutter test", "widget test", "dart test", `_test.dart` file
**Args**: `--integration`, `--device`, `--coverage`, `--update-goldens`
**DO NOT use for**: non-Flutter mobile → `/mobile-test` or `/rn-test`

#### 15. `/rn-test`
**Trigger**: "React Native test", "Detox", "RN test", `.e2e.ts` file
**Args**: `--e2e`, `--device`, `--platform`, `--build`, `--configuration`
**DO NOT use for**: non-RN mobile → `/mobile-test` or `/flutter-test`

#### 16. `/visual-test`
**Trigger**: "visual test", "screenshot comparison", "visual regression", "pixel diff"
**Methods**: Playwright `toHaveScreenshot()` or BackstopJS
**Args**: `--update` (baseline), `--threshold`, `--browsers`, `--viewports`

#### 17. `/contract-test`
**Trigger**: "contract test", "Pact", "API compatibility", "consumer-driven"
**Args**: `--provider`, `--consumer`, `--publish`, `--broker-url`

#### 18. `/smoke-test`
**Trigger**: "smoke test", "health check", "post-deploy verify", "is site working"
**Fallback**: If no test framework, runs curl-based HTTP checks
**Args**: `--env`, `--url`, `--timeout`, `--tag`, `--notify`

---

### Quality & Security Skills (v2.0)

#### 19. `/security-test`
**Trigger**: "security scan", "vulnerability", "OWASP", "npm audit", "dependency check"
**Scan types**: `deps` (npm audit), `code` (XSS/SQLi analysis), `owasp` (Top 10), `full` (all)
**Args**: `--fix`, `--severity`, `--ignore`

#### 20. `/a11y-test`
**Trigger**: "accessibility", "a11y", "WCAG", "screen reader", "aria"
**Uses**: axe-core + Playwright
**Args**: `--standard wcag2a|wcag2aa|wcag2aaa`, `--include`, `--exclude`

#### 21. `/lighthouse`
**Trigger**: "Lighthouse", "page speed", "Core Web Vitals", "SEO audit", "website performance"
**Args**: `<url>`, `--category`, `--device mobile|desktop`, `--runs`, `--budget`
**DO NOT use for**: load testing → `/run-test` with k6

---

### DevOps & Utility Skills (v2.0)

#### 22. `/ci-gen`
**Trigger**: "CI/CD", "GitHub Actions", "GitLab CI", "Jenkins", "Azure pipeline", "generate pipeline"
**Platforms**: `github`, `gitlab`, `jenkins`, `azure`
**Args**: `--features`, `--node-version`

#### 23. `/docker-test`
**Trigger**: "Docker test", "start database", "docker compose", "test environment"
**Actions**: `up`, `down`, `status`, `run`
**Args**: `--file`, `--service`, `--build`

#### 24. `/notify`
**Trigger**: "send results", "notify team", "Slack message", "Teams notification"
**Platforms**: `slack`, `teams`, `discord`, `email`
**Args**: `--webhook`, `--results`, `--message`

#### 25. `/test-data`
**Trigger**: "generate data", "test data", "seed database", "fake data", "mock data"
**Actions**: `generate`, `seed`, `cleanup`
**Schemas**: user, product, order, post, custom
**Args**: `--schema`, `--count`, `--output`, `--format json|csv|sql`

---

## Test Function → Skill Mapping (Complete)

### Web Application Functions

| Test Function | Skill | File Pattern |
|---|---|---|
| Login/Authentication | `/run-test` or `/cypress-test` | `login.spec.ts` / `login.cy.ts` |
| Registration | `/run-test` or `/cypress-test` | `register.spec.ts` |
| Form Validation | `/run-test` or `/cypress-test` | `form-validation.spec.ts` |
| Search | `/run-test` | `search.spec.ts` |
| Navigation/Routing | `/run-test` | `navigation.spec.ts` |
| CRUD Operations | `/run-test` | `crud.spec.ts` |
| File Upload | `/run-test` | `upload.spec.ts` |
| Responsive Design | `/run-test` | `responsive.spec.ts` |
| Visual Regression | `/visual-test` | `homepage.visual.ts` |
| Accessibility | `/a11y-test` | `login.a11y.ts` |
| Performance Audit | `/lighthouse` | (URL-based) |
| Cross-browser | `/run-test` or `/cypress-test` | Multiple browsers in config |

### API Functions

| Test Function | Skill | File Pattern |
|---|---|---|
| REST Endpoint Testing | `/api-test` | `users.api.ts` |
| GraphQL Testing | `/api-test` | `graphql.api.ts` |
| Auth Token Flow | `/api-test` | `auth.api.ts` |
| Postman Collection | `/api-test` | `collection.postman.json` |
| API Contract | `/contract-test` | `users.pact.ts` |
| API Load Testing | `/run-test` | `api-load.k6.js` |

### Unit/Component Functions

| Test Function | Skill | File Pattern |
|---|---|---|
| Function/Class Testing | `/unit-test` | `math.test.ts` |
| React Component | `/unit-test` | `Button.test.tsx` |
| Hook Testing | `/unit-test` | `useAuth.test.ts` |
| Snapshot Testing | `/unit-test` | any `--update-snapshots` |
| Database Operations | `/db-test` | `users.db.test.ts` |

### Mobile Application Functions

| Test Function | Skill | File Pattern |
|---|---|---|
| Android Native App | `/mobile-test` | `app.mobile.ts` |
| iOS Native App | `/mobile-test` | `ios.mobile.ts` (+ `--platform ios`) |
| WebView/Hybrid App | `/mobile-test` | `webview.mobile.ts` |
| Flutter App | `/flutter-test` | `widget_test.dart` |
| React Native App (unit) | `/rn-test` | `App.test.tsx` |
| React Native App (E2E) | `/rn-test` | `login.e2e.ts` (+ `--e2e`) |
| Gestures (swipe/scroll) | `/mobile-test` | `gestures.mobile.ts` |
| Push Notifications | `/mobile-test` | `notifications.mobile.ts` |
| Deep Links | `/mobile-test` | `deeplink.mobile.ts` |

### Performance Functions

| Test Function | Skill | File Pattern |
|---|---|---|
| Load Testing | `/run-test` | `load.k6.js` |
| Stress Testing | `/run-test` | `stress.k6.js` |
| Spike Testing | `/run-test` | `spike.k6.js` |
| Soak/Endurance | `/run-test` | `soak.k6.js` |
| Website Speed | `/lighthouse` | (URL-based) |
| Core Web Vitals | `/lighthouse` | (URL-based, `--category performance`) |

### Security & Quality Functions

| Test Function | Skill | Arguments |
|---|---|---|
| Dependency Vulnerabilities | `/security-test` | `deps` |
| Code Security (XSS/SQLi) | `/security-test` | `code` |
| OWASP Top 10 | `/security-test` | `owasp` |
| WCAG Compliance | `/a11y-test` | `--standard wcag2aa` |
| SEO Check | `/lighthouse` | `--category seo` |
| Best Practices | `/lighthouse` | `--category best-practices` |

### DevOps Functions

| Test Function | Skill | Arguments |
|---|---|---|
| Setup CI Pipeline | `/ci-gen` | `github \| gitlab \| jenkins \| azure` |
| Start Test DB/Services | `/docker-test` | `up` |
| Post-Deploy Verify | `/smoke-test` | `--env staging` |
| Notify Team | `/notify` | `slack \| teams \| discord` |
| Generate Test Data | `/test-data` | `generate --schema user --count 50` |
| Seed Database | `/test-data` | `seed` |

---

## Keywords → Skill Mapping

```
"setup", "install", "prerequisites", "check env"          → /setup-test-env
"device", "phone", "emulator", "connected"                → /devices
"appium", "server"                                         → /appium
"apk", "deploy app", "install app"                         → /install-apk
"playwright", "web test", "browser test", "spec.ts"        → /run-test
"cypress", "cy.ts"                                         → /cypress-test
"k6", "load test", "performance", "stress", ".k6.js"      → /run-test
"mobile test", "native app", "wdio", ".mobile.ts"         → /mobile-test
"flutter", "dart", "widget test", "_test.dart"             → /flutter-test
"react native", "detox", "RN test", ".e2e.ts"             → /rn-test
"API test", "REST", "endpoint", "Postman", ".api.ts"      → /api-test
"unit test", "jest", "vitest", "coverage"                  → /unit-test
"database test", "DB", "migration", "prisma"               → /db-test
"visual test", "screenshot", "pixel diff", "regression"    → /visual-test
"contract", "pact", "API compatibility"                    → /contract-test
"smoke test", "health check", "post-deploy"                → /smoke-test
"security", "vulnerability", "OWASP", "audit"              → /security-test
"accessibility", "a11y", "WCAG", "aria"                    → /a11y-test
"lighthouse", "page speed", "Core Web Vitals", "SEO"      → /lighthouse
"CI/CD", "GitHub Actions", "GitLab", "Jenkins", "Azure"   → /ci-gen
"docker", "container", "compose", "test env"               → /docker-test
"notify", "slack", "teams", "discord", "email"             → /notify
"test data", "fake data", "seed", "faker"                  → /test-data
"results", "report", "what failed", "pass/fail"            → /test-report
"status", "dashboard", "overview", "monitor"               → /monitor
"scaffold", "template", "new project", "create test"       → /scaffold-test
```

## File Extension → Skill Mapping

```
*.spec.ts, *.spec.js, *.test.ts, *.test.js  → /run-test (Playwright)
*.cy.ts, *.cy.js                             → /cypress-test (Cypress)
*.k6.js, *.k6.ts                             → /run-test (k6)
*.mobile.ts, *.mobile.js                     → /mobile-test (WDIO+Appium)
*.api.ts, *.api.js                           → /api-test
*.unit.test.ts                               → /unit-test
*.db.test.ts                                 → /db-test
*.visual.ts                                  → /visual-test
*.pact.ts                                    → /contract-test
*.a11y.ts                                    → /a11y-test
*.smoke.ts                                   → /smoke-test
*.e2e.ts (in e2e/ dir)                       → /rn-test (Detox)
*_test.dart                                  → /flutter-test
*.apk                                        → /install-apk
*.postman.json, *.postman_collection.json    → /api-test (Newman)
```

---

## Skill Capability Boundaries

| Skill | CAN do | CANNOT do |
|---|---|---|
| `/run-test` | Web browser tests (Playwright), k6 perf tests | Mobile, API-only, Cypress, unit tests |
| `/cypress-test` | Cypress E2E and component tests | Playwright, mobile tests |
| `/mobile-test` | Native Android/iOS, WebView via Appium | Web-only, Flutter, React Native |
| `/flutter-test` | Flutter unit/widget/integration | Non-Flutter mobile |
| `/rn-test` | React Native Jest + Detox | Non-RN mobile |
| `/api-test` | REST/GraphQL API tests, Postman | Browser UI tests, load tests |
| `/unit-test` | Unit/component tests (Vitest/Jest) | E2E, integration tests |
| `/db-test` | Database operations, migrations | API tests, unit tests |
| `/visual-test` | Screenshot comparison, baseline management | Functional tests |
| `/contract-test` | Pact consumer/provider contracts | API functional tests |
| `/smoke-test` | Quick health checks, critical paths | Full regression |
| `/security-test` | Dependency audit, code analysis, OWASP | Penetration testing |
| `/a11y-test` | WCAG compliance, axe-core scans | UX/usability testing |
| `/lighthouse` | Performance/SEO/a11y scores, Core Web Vitals | Load testing, API testing |
| `/ci-gen` | Generate pipeline config files | Run pipelines, deploy |
| `/docker-test` | Manage Docker containers for testing | Build production images |
| `/notify` | Send results to Slack/Teams/Discord/Email | Monitor continuously |
| `/test-data` | Generate/seed/cleanup fake data | Write test logic |
| `/devices` | List connected devices | Install apps, run tests |
| `/appium` | Manage Appium server | Run tests |
| `/install-apk` | Deploy APK to device | Run tests, manage iOS apps |
| `/test-report` | Parse and display results | Re-run tests |
| `/monitor` | Read-only dashboard | Fix issues |
| `/scaffold-test` | Create file templates | Run tests |
| `/setup-test-env` | Check/suggest installs | Auto-install without consent |

---

## Common Workflow Chains

### First-time Setup
```
/setup-test-env → /scaffold-test all → /monitor
```

### Web Testing
```
/run-test <file.spec.ts> → /test-report
```

### API Testing
```
/api-test tests/api/ → /test-report
```

### Unit + Coverage
```
/unit-test --coverage → /test-report
```

### Mobile Testing (Full)
```
/devices → /appium start → /install-apk <path> → /mobile-test <file> → /test-report
```

### Flutter Testing
```
/flutter-test → /test-report
/flutter-test --integration --device emulator-5554
```

### React Native Testing
```
/rn-test                           # Jest unit tests
/rn-test --e2e --build --platform android   # Detox E2E
```

### Security & Quality Audit
```
/security-test → /a11y-test <url> → /lighthouse <url> → /notify slack
```

### Visual Regression
```
/visual-test --update     # Create baseline (first time)
/visual-test              # Compare against baseline
```

### Docker Integration Testing
```
/docker-test up → /db-test --seed → /api-test → /docker-test down
```

### CI/CD Setup
```
/ci-gen github → /smoke-test --env staging → /notify teams
```

### Full Regression Suite
```
/unit-test → /api-test → /run-test → /mobile-test → /visual-test → /security-test → /test-report → /notify slack
```

### Post-Deployment
```
/smoke-test --env production → /lighthouse <prod-url> → /notify slack
```

---

## Error Handling Decision Tree

```
Error occurred
│
├── "command not found" (node, java, adb, appium, k6, flutter, docker)
│   └── /setup-test-env
│
├── "no devices/emulators found"
│   └── /devices → connect device or start emulator
│
├── "ECONNREFUSED :4723" (Appium not running)
│   └── /appium start
│
├── "INSTALL_FAILED_*" (APK install error)
│   └── Report specific ADB error code
│
├── "browser not found" (Playwright/Cypress)
│   └── npx playwright install / npx cypress install
│
├── "no test files found"
│   └── /scaffold-test <type>
│
├── "test failed" (assertion error)
│   └── /test-report --failures-only → then rerun with --debug
│
├── "vulnerability found" (security)
│   └── /security-test deps --fix
│
├── "Docker daemon not running"
│   └── Start Docker Desktop or systemctl start docker
│
├── "webhook failed" (notification)
│   └── Check webhook URL, network, /notify --webhook <correct-url>
│
├── "no baseline found" (visual test)
│   └── /visual-test --update (create baseline first)
│
├── "Pact broker unreachable" (contract test)
│   └── Check broker URL, use --broker-url
│
├── "timeout"
│   ├── Mobile test → check device, increase timeout
│   ├── Web test → check if site is accessible
│   └── Appium → /appium stop → /appium start
│
└── Unknown error
    └── /monitor (check overall system health)
```

---

## Multi-Skill Orchestration Rules

1. **Minimize redundant checks**: `/mobile-test` auto-checks Appium and devices. Don't pre-run `/appium status` + `/devices` unless user explicitly asks.

2. **Chain results**: After any test execution skill, follow up with `/test-report` unless results were already shown inline.

3. **Framework detection priority**:
   - Check file extension first (`.spec.ts` → Playwright, `.cy.ts` → Cypress)
   - Check project config (vitest.config vs jest.config)
   - Check package.json dependencies
   - Ask user if ambiguous

4. **Parallel-safe skills**: These can run simultaneously:
   - `/unit-test` + `/api-test` (different layers)
   - `/run-test` + `/mobile-test` (different infrastructure)
   - `/security-test` + `/a11y-test` (different scans)
   - `/lighthouse` + `/visual-test` (different tools)

5. **Sequential-only skills**: These depend on prior steps:
   - `/install-apk` requires device connected
   - `/mobile-test` requires Appium running
   - `/test-report` requires tests to have been run
   - `/docker-test run` requires `/docker-test up`
   - `/smoke-test --env staging` requires deployment complete

---

## Version Information

- **Skills version**: 2.0.0
- **Total skills**: 24
- **Supported frameworks**: Playwright, Cypress, Vitest, Jest, WebdriverIO, Appium, k6, Flutter, Detox, Pact, BackstopJS, axe-core, Lighthouse
- **Supported platforms**: Windows, macOS, Linux
- **Required**: Node.js 20+, Claude Code CLI
- **Optional**: Java 11+, Android SDK, Xcode, Flutter SDK, Docker, k6
