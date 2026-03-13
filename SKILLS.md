# Skills Reference

Complete reference for all 25 Claude Code Skills in this project.

---

## Core Testing Skills (v1.0)

---

## `/setup-test-env` - Environment Setup

**What it does**: Checks all prerequisites (Node.js, Java, ADB, Appium, Playwright, k6) and reports their status. Offers to install missing npm-based tools.

**Arguments**: None

**Example**:
```
> /setup-test-env
```

**Output**:
```
Test Automation Environment Check
══════════════════════════════════════════════
Tool          Status    Version     Notes
──────────────────────────────────────────────
Node.js       ✓         v20.11.0
Java          ✓         17.0.2
ADB           ✓         34.0.5
Appium        ✓         2.5.1
  uiautomator2  ✓       2.34.0
  xcuitest      ✗       -          macOS only
Playwright    ✓         1.42.0
k6            ✓         0.49.0
ANDROID_HOME  ✓         C:\Android\Sdk
══════════════════════════════════════════════
Ready: 7/8 tools configured
```

**When to use**: First time setup, or when something isn't working.

---

## `/devices` - List Connected Devices

**What it does**: Discovers all connected Android devices, emulators, and iOS devices. Shows device ID, model, OS version, and status.

**Arguments**: None

**Example**:
```
> /devices
```

**Output**:
```
Connected Devices
══════════════════════════════════════════════════════════════
#  Device ID         Platform    Model         OS       Status
──────────────────────────────────────────────────────────────
1  emulator-5554     Android     Pixel 7       14       online
2  R5CT32XXXXX       Android     Galaxy S23    13       online
══════════════════════════════════════════════════════════════
Total: 2 devices (2 online, 0 offline)
```

**When to use**: Before running mobile tests, to see what's available.

---

## `/appium` - Appium Server Control

**What it does**: Start, stop, or check the Appium 2.0 server used for mobile testing.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `start` | Start Appium server | - |
| `stop` | Stop Appium server | - |
| `status` | Check if running | (default) |
| `install-drivers` | Install Appium drivers | - |
| `--port <n>` | Port number | 4723 |

**Examples**:
```
> /appium                     # Check status
> /appium start               # Start server
> /appium stop                # Stop server
> /appium start --port 4724   # Start on custom port
> /appium install-drivers     # Install uiautomator2/xcuitest
```

**When to use**: Before running `/mobile-test`. The mobile-test skill auto-starts Appium, but you can also manage it manually.

---

## `/install-apk` - Install APK on Device

**What it does**: Installs an APK file onto a connected Android device or emulator.

**Arguments**:
| Argument | Description | Required |
|----------|-------------|----------|
| `<apk-path>` | Path to .apk file | Yes |
| `<device-id>` | Target device ID | No (auto if 1 device) |

**Examples**:
```
> /install-apk ./app/app-debug.apk
> /install-apk ./app/app-debug.apk emulator-5554
> /install-apk builds/release.apk R5CT32XXXXX
```

**When to use**: Before running mobile tests, to deploy your app to the device.

---

## `/run-test` - Run Web & Performance Tests

**What it does**: Runs Playwright web tests or k6 performance tests. Auto-detects the framework from file extension. Parses results and shows formatted pass/fail summary.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/pattern>` | Test file or glob pattern | All tests |
| `--headed` | Show browser (Playwright) | Headless |
| `--debug` | Debug mode | Off |
| `--grep <pattern>` | Filter by test name | All |
| `--workers <n>` | Parallel workers | Auto |

**Examples**:
```
> /run-test                                    # Run all tests
> /run-test tests/web/login.spec.ts            # Run specific file
> /run-test tests/web/ --headed                # Run with browser visible
> /run-test --grep "login"                     # Filter by name
> /run-test tests/performance/load.k6.js       # Run k6 perf test
```

**Auto-detection**:
- `*.spec.ts`, `*.test.ts`, `*.spec.js`, `*.test.js` → Playwright
- `*.k6.js`, `*.k6.ts` → k6

**When to use**: For web browser testing and performance/load testing. For mobile tests, use `/mobile-test` instead.

---

## `/mobile-test` - Run Mobile Tests

**What it does**: Runs WebdriverIO + Appium tests on Android/iOS devices. Auto-starts Appium if needed, auto-detects devices, handles WebView context switching.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<test-file>` | Test file path | Required |
| `--device <id>` | Target device | Auto (if 1 device) |
| `--platform <p>` | `android` or `ios` | `android` |
| `--app <path>` | APK/IPA to install first | - |

**Examples**:
```
> /mobile-test tests/mobile/login.mobile.ts
> /mobile-test tests/mobile/login.mobile.ts --device emulator-5554
> /mobile-test tests/mobile/app.mobile.ts --app ./app-debug.apk
> /mobile-test tests/mobile/ios-test.mobile.ts --platform ios
```

**When to use**: For testing native Android/iOS apps and hybrid WebView apps.

---

## `/test-report` - View Test Results

**What it does**: Finds and parses test result files (Playwright JSON, WDIO JSON, k6 JSON, JUnit XML). Shows pass/fail counts, duration, failure details.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `--last` | Most recent results | (default) |
| `--file <path>` | Specific report file | - |
| `--failures-only` | Only show failures | All |
| `--suite <name>` | Filter by suite name | All |

**Examples**:
```
> /test-report                         # Show last results
> /test-report --failures-only         # Only failed tests
> /test-report --file test-results/playwright-results.json
> /test-report --suite login           # Filter by suite
```

**Supported formats**: Playwright JSON, WebdriverIO JSON, k6 JSON, JUnit XML, Jest JSON, Cypress JSON

**When to use**: After running any tests.

---

## `/monitor` - Status Dashboard

**What it does**: Displays a comprehensive overview of your entire testing environment: services, devices, tool versions, and last test results.

**Arguments**: None

**Example**:
```
> /monitor
```

**When to use**: Quick health check of your entire setup. Great to run at the start of a testing session.

---

## `/scaffold-test` - Create Test Project

**What it does**: Creates a new test project with proper structure, config files, sample tests, and installs dependencies.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `web` | Playwright web tests | - |
| `mobile` | WebdriverIO mobile tests | - |
| `performance` | k6 perf tests | - |
| `all` | All three types | - |
| `--dir <path>` | Target directory | Current dir |

**Examples**:
```
> /scaffold-test web                   # Create Playwright project
> /scaffold-test mobile                # Create WDIO + Appium project
> /scaffold-test performance           # Create k6 project
> /scaffold-test all                   # Create all three
```

**When to use**: Starting a new test project from scratch.

---

## Extended Testing Skills (v2.0)

---

## `/api-test` - API / REST Testing

**What it does**: Run API tests using Playwright request API, Supertest, or Newman (Postman collections). Auto-detects the framework from project dependencies.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/collection>` | Test file or Postman collection | All API tests |
| `--base-url <url>` | API base URL | From config/env |
| `--env <name>` | Environment (local/staging/prod) | local |
| `--headers <json>` | Extra headers | - |
| `--verbose` | Show request/response details | Off |

**Examples**:
```
> /api-test                                    # Run all API tests
> /api-test tests/api/users.api.ts             # Specific file
> /api-test --base-url https://staging.api.com # Custom URL
> /api-test collection.postman.json            # Postman collection
> /api-test --env staging --verbose            # Staging with details
```

**Auto-detection**: `*.api.ts` → Playwright, `*.postman.json` → Newman, Supertest if in deps

**When to use**: Testing REST/GraphQL APIs, backend endpoints, microservices.

---

## `/unit-test` - Unit Testing

**What it does**: Run unit tests with Vitest or Jest. Auto-detects the test framework from project config.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/pattern>` | Test file or pattern | All unit tests |
| `--coverage` | Generate coverage report | Off |
| `--watch` | Watch mode | Off |
| `--bail` | Stop on first failure | Off |
| `--update-snapshots` | Update snapshots | Off |

**Examples**:
```
> /unit-test                                   # Run all unit tests
> /unit-test src/utils/math.test.ts            # Specific file
> /unit-test --coverage                        # With coverage report
> /unit-test --watch                           # Watch mode
> /unit-test src/ --bail                       # Stop on first failure
```

**Auto-detection**: Vitest (vitest.config), Jest (jest.config), or from package.json scripts

**When to use**: Testing individual functions, classes, and modules in isolation.

---

## `/db-test` - Database Integration Testing

**What it does**: Run database integration tests. Supports Prisma, Knex, TypeORM, and raw SQL. Handles test database setup/teardown.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/pattern>` | Test file | All DB tests |
| `--reset` | Reset test database before run | Off |
| `--seed` | Seed test data before run | Off |
| `--db-url <url>` | Database connection URL | From env |

**Examples**:
```
> /db-test                                     # Run all DB tests
> /db-test tests/db/users.db.test.ts           # Specific file
> /db-test --reset --seed                      # Reset + seed first
> /db-test --db-url postgresql://localhost/test # Custom DB
```

**When to use**: Testing database queries, migrations, data integrity, ORM operations.

---

## `/cypress-test` - Cypress E2E & Component Testing

**What it does**: Run Cypress E2E or component tests. Supports headed mode, multiple browsers, and video recording.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/pattern>` | Spec file or pattern | All specs |
| `--headed` | Show browser | Headless |
| `--browser <name>` | chrome, firefox, edge, electron | electron |
| `--component` | Run component tests | E2E |
| `--spec <pattern>` | Spec file pattern | All |

**Examples**:
```
> /cypress-test                                # Run all E2E tests
> /cypress-test login.cy.ts                    # Specific test
> /cypress-test --headed --browser chrome      # With browser visible
> /cypress-test --component                    # Component tests
```

**When to use**: Projects using Cypress instead of Playwright for browser testing.

---

## `/flutter-test` - Flutter Testing

**What it does**: Run Flutter unit, widget, and integration tests. Supports flutter test, flutter drive, and patrol.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/dir>` | Test file or directory | All tests |
| `--integration` | Run integration tests | Unit/widget |
| `--device <id>` | Target device (integration) | Auto |
| `--coverage` | Generate coverage report | Off |
| `--update-goldens` | Update golden image files | Off |

**Examples**:
```
> /flutter-test                                # All unit/widget tests
> /flutter-test test/unit/user_test.dart       # Specific file
> /flutter-test --integration                  # Integration tests
> /flutter-test --coverage                     # With coverage
> /flutter-test --update-goldens               # Update golden files
```

**When to use**: Flutter mobile and web projects.

---

## `/rn-test` - React Native Testing

**What it does**: Run React Native unit tests (Jest) and E2E tests (Detox) on real devices and emulators.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file>` | Test file or pattern | All tests |
| `--e2e` | Run Detox E2E tests | Jest unit |
| `--device <name>` | Detox device name | From config |
| `--platform <p>` | android or ios | android |
| `--build` | Build app before E2E | Off |
| `--configuration <c>` | debug or release | debug |

**Examples**:
```
> /rn-test                                     # Run Jest unit tests
> /rn-test --e2e                               # Run Detox E2E
> /rn-test --e2e --build --platform android    # Build + E2E
> /rn-test login.e2e.ts --e2e                  # Specific E2E test
```

**When to use**: React Native mobile projects.

---

## `/visual-test` - Visual Regression Testing

**What it does**: Compare screenshots of your UI against baseline images to detect visual changes. Uses Playwright `toHaveScreenshot()` or BackstopJS.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/url>` | Test file or URL | All visual tests |
| `--update` | Update baseline screenshots | Off |
| `--threshold <n>` | Pixel diff threshold (0-1) | 0.1 |
| `--browsers <list>` | Browsers | chromium |
| `--viewports <list>` | Viewport sizes | 1280x720 |

**Examples**:
```
> /visual-test                                 # Compare against baseline
> /visual-test --update                        # Accept changes as baseline
> /visual-test homepage.visual.ts              # Specific test
> /visual-test --threshold 0.05               # Strict comparison (5%)
```

**When to use**: Design systems, UI-critical pages, after CSS changes.

---

## `/contract-test` - Contract Testing

**What it does**: Run consumer-driven contract tests using Pact. Validates API compatibility between services.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file>` | Test file | All contract tests |
| `--provider` | Run provider verification | Consumer |
| `--consumer` | Run consumer tests | (default) |
| `--publish` | Publish pacts to broker | Off |
| `--broker-url <url>` | Pact Broker URL | - |

**Examples**:
```
> /contract-test                               # Run consumer tests
> /contract-test --provider                    # Provider verification
> /contract-test --publish --broker-url https://pact.example.com
```

**When to use**: Microservices, API-first projects, verifying service compatibility.

---

## `/smoke-test` - Smoke Testing

**What it does**: Run quick critical-path tests to verify a deployment is working. Executes tagged @smoke tests or basic HTTP health checks.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `--env <name>` | local, staging, production | local |
| `--url <base-url>` | Base URL to test | From env |
| `--timeout <duration>` | Per-test timeout | 30s |
| `--tag <tag>` | Test tag to filter | @smoke |

**Examples**:
```
> /smoke-test                                  # Local smoke test
> /smoke-test --env staging                    # Test staging
> /smoke-test --url https://prod.example.com   # Test production
> /smoke-test --env production --notify slack  # Test + notify
```

**When to use**: After deployments, post-release verification, health monitoring.

---

## Quality & Security Skills (v2.0)

---

## `/security-test` - Security Scanning

**What it does**: Run security audits: dependency vulnerability scan (npm audit), static code analysis, and OWASP Top 10 checks.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<scan-type>` | `deps`, `code`, `owasp`, `full` | full |
| `--fix` | Auto-fix vulnerabilities | Off |
| `--severity <level>` | Minimum severity | moderate |
| `--ignore <ids>` | CVE IDs to ignore | - |

**Examples**:
```
> /security-test                               # Full scan
> /security-test deps                          # Dependencies only
> /security-test deps --fix                    # Auto-fix vulnerabilities
> /security-test code                          # Code analysis (XSS, SQL injection)
> /security-test --severity high               # Only high/critical
```

**When to use**: Before releases, in CI/CD pipeline, after adding new dependencies.

---

## `/a11y-test` - Accessibility Testing

**What it does**: Run accessibility tests based on WCAG 2.2 guidelines using axe-core integrated with Playwright.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<file/url>` | Test file or URL | All a11y tests |
| `--standard <std>` | wcag2a, wcag2aa, wcag2aaa | wcag2aa |
| `--include <selector>` | Only scan this element | Full page |
| `--exclude <selector>` | Skip this element | - |

**Examples**:
```
> /a11y-test                                   # Run all a11y tests
> /a11y-test https://localhost:3000            # Scan URL
> /a11y-test login.a11y.ts                     # Specific test
> /a11y-test --standard wcag2aaa               # Strict AAA level
```

**When to use**: Ensuring WCAG compliance, inclusive design, legal requirements.

---

## `/lighthouse` - Lighthouse Web Audit

**What it does**: Run Google Lighthouse to audit web page performance, accessibility, SEO, and best practices. Shows Core Web Vitals.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<url>` | URL to audit | Required |
| `--category <cat>` | performance, accessibility, seo, best-practices, pwa | All |
| `--device <d>` | mobile or desktop | mobile |
| `--runs <n>` | Number of runs (median) | 1 |
| `--budget <file>` | Performance budget JSON | - |

**Examples**:
```
> /lighthouse https://example.com              # Full audit
> /lighthouse https://example.com --device desktop
> /lighthouse https://example.com --category performance
> /lighthouse https://example.com --runs 3     # Stable scores
```

**When to use**: Performance optimization, SEO checks, quality audits.

---

## DevOps & Utility Skills (v2.0)

---

## `/ci-gen` - CI/CD Pipeline Generator

**What it does**: Generate CI/CD pipeline configuration files. Auto-detects project type, test frameworks, and generates appropriate pipeline.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<platform>` | github, gitlab, jenkins, azure | (ask) |
| `--features <list>` | test, lint, build, deploy, docker | test,lint,build |
| `--node-version <v>` | Node.js version | 20 |

**Examples**:
```
> /ci-gen github                               # GitHub Actions
> /ci-gen gitlab                               # GitLab CI
> /ci-gen jenkins                              # Jenkinsfile
> /ci-gen azure                                # Azure Pipelines
> /ci-gen github --features test,lint,build,deploy
```

**When to use**: Setting up automated testing in CI/CD, adding pipelines to existing projects.

---

## `/docker-test` - Docker Test Environment

**What it does**: Manage Docker containers for isolated test environments. Start/stop databases, services, and run tests in containers.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<action>` | up, down, status, run | Required |
| `--file <path>` | Docker compose file | docker-compose.test.yml |
| `--service <name>` | Specific service | All |
| `--build` | Rebuild images | Off |

**Examples**:
```
> /docker-test up                              # Start test environment
> /docker-test up --build                      # Rebuild and start
> /docker-test status                          # Check running services
> /docker-test run                             # Run tests in container
> /docker-test down                            # Stop everything
```

**When to use**: Integration testing with real databases, microservice testing, isolated environments.

---

## `/notify` - Send Notifications

**What it does**: Send test results and alerts to Slack, Microsoft Teams, Discord, or Email.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<platform>` | slack, teams, discord, email | (ask) |
| `--webhook <url>` | Webhook URL | From config |
| `--results <file>` | Test results file | Latest |
| `--message <text>` | Custom message | Auto-generated |

**Examples**:
```
> /notify slack                                # Send to Slack
> /notify teams --webhook https://...          # Send to Teams
> /notify discord --results test-results.json  # Custom results
> /notify email --message "Deploy complete"    # Custom message
```

**When to use**: After test runs, deployment status, alerting team members.

---

## `/test-data` - Test Data Management

**What it does**: Generate, seed, and clean up test data using Faker.js factories. Supports user, product, order, post schemas.

**Arguments**:
| Argument | Description | Default |
|----------|-------------|---------|
| `<action>` | generate, seed, cleanup | Required |
| `--schema <name>` | user, product, order, post, custom | user |
| `--count <N>` | Number of records | 10 |
| `--output <file>` | Output file path | test-data/<schema>.json |
| `--format <fmt>` | json, csv, sql | json |

**Examples**:
```
> /test-data generate --schema user --count 50
> /test-data generate --schema product --count 100 --format csv
> /test-data seed                              # Seed database
> /test-data cleanup                           # Remove test data
```

**When to use**: Before running tests that need consistent test data, database seeding.

---

## Workflow Cheatsheets

### First Time Setup
```
/setup-test-env        → Check everything is installed
/scaffold-test all     → Create sample tests for all platforms
```

### Web Testing Session
```
/run-test tests/web/login.spec.ts --headed    → Run with browser
/test-report --last                            → Check results
```

### Mobile Testing Session
```
/devices                                       → Check device connected
/appium start                                  → Start Appium
/install-apk app-debug.apk                    → Deploy app
/mobile-test tests/mobile/app.mobile.ts        → Run tests
/test-report --last                            → Check results
/appium stop                                   → Stop Appium when done
```

### API Testing Session
```
/api-test tests/api/users.api.ts               → Run API tests
/test-report --failures-only                   → Check failures
```

### Unit Testing Session
```
/unit-test --coverage                          → Run with coverage
/test-report --last                            → View coverage report
```

### Performance Testing Session
```
/run-test tests/performance/load.k6.js         → Run load test
/test-report --last                            → Analyze results
```

### Security & Quality Audit
```
/security-test                                 → Full security scan
/a11y-test https://localhost:3000              → Accessibility check
/lighthouse https://localhost:3000             → Performance audit
```

### CI/CD Setup
```
/ci-gen github                                 → Generate GitHub Actions
/docker-test up                                → Start test infrastructure
/smoke-test --env staging                      → Post-deploy verification
/notify slack                                  → Send results to team
```

### Visual Regression
```
/visual-test --update                          → Create baseline
/visual-test                                   → Compare against baseline
/test-report --last                            → View diff results
```

### Full Regression Suite
```
/unit-test                                     → Unit tests
/api-test                                      → API tests
/run-test                                      → Web E2E tests
/mobile-test tests/mobile/                     → Mobile tests
/security-test                                 → Security scan
/test-report --last                            → Final report
/notify slack                                  → Notify team
```

### Quick Status Check
```
/monitor                                       → Everything at a glance
```
