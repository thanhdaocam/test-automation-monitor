# TODO - Test Automation Monitor (Claude Code Skills)

> **Approach**: Bộ Claude Code Skills - slash commands cho automation testing
> **Timeline: 3 ngày** | Share qua Git repo, ai cài Claude Code là dùng được

---

## Tổng quan

Thay vì build desktop app phức tạp (Tauri + Rust + React), ta build **bộ Claude Code Skills**:
- Người dùng chỉ cần clone repo + copy `.claude/skills/` vào project
- Gõ `/run-test`, `/devices`, v.v. trong Claude Code
- Claude AI xử lý logic, parse output, hiển thị kết quả đẹp
- Không cần GUI, không cần compile, chạy ở đâu cũng được

### Skills cần tạo

| Skill | Slash Command | Mô tả |
|-------|--------------|-------|
| Run Test | `/run-test` | Chạy Playwright / WebdriverIO / k6 tests |
| Devices | `/devices` | List Android/iOS devices đang kết nối |
| Install APK | `/install-apk` | Cài APK lên Android device |
| Appium | `/appium` | Start/stop Appium server |
| Test Report | `/test-report` | Xem kết quả test, thống kê pass/fail |
| Monitor | `/monitor` | Tổng quan status: devices, services, tests |
| Setup | `/setup-test-env` | Kiểm tra & cài đặt prerequisites |
| Mobile Test | `/mobile-test` | Chạy test trên mobile (WDIO + Appium) |

---

## Day 1: Core Skills + Setup

### Sáng (4h)

- [ ] **T1.1** Tạo project structure
  - [ ] Tạo thư mục `.claude/skills/` với subdirectories cho mỗi skill
  - [ ] Tạo `scripts/` cho helper scripts (bash)
  - [ ] Tạo `templates/` cho sample test configs
  - [ ] Tạo `examples/` cho sample test files

- [ ] **T1.2** Skill: `/setup-test-env`
  - [ ] SKILL.md: kiểm tra Node.js, Java, ADB, Appium, Playwright, k6
  - [ ] Auto-detect đường dẫn từ PATH / env vars
  - [ ] Hướng dẫn cài missing dependencies
  - [ ] Verify tất cả đã sẵn sàng
  - [ ] Script: `scripts/check-env.sh` - verify prerequisites

- [ ] **T1.3** Skill: `/devices`
  - [ ] SKILL.md: chạy `adb devices`, parse output
  - [ ] Hiển thị bảng: Device ID, Model, OS Version, Status
  - [ ] Detect cả emulators và physical devices
  - [ ] Cảnh báo nếu ADB không tìm thấy

- [ ] **T1.4** Skill: `/appium`
  - [ ] SKILL.md: `start` / `stop` / `status` subcommands
  - [ ] Start: `appium server --port 4723 --allow-cors`
  - [ ] Stop: tìm và kill Appium process
  - [ ] Status: check port 4723 + health endpoint
  - [ ] Auto-install drivers nếu chưa có

### Chiều (4h)

- [ ] **T1.5** Skill: `/install-apk`
  - [ ] SKILL.md: nhận path APK + optional device ID
  - [ ] Nếu nhiều devices → hỏi user chọn device
  - [ ] `adb -s <device> install -r <apk>`
  - [ ] Verify installation thành công
  - [ ] Hiển thị package name đã cài

- [ ] **T1.6** Skill: `/run-test`
  - [ ] SKILL.md: detect loại test từ file extension / package.json
  - [ ] Playwright: `npx playwright test <pattern> --reporter=json`
  - [ ] k6: `k6 run <script> --out json=results.json`
  - [ ] Parse JSON output → hiển thị bảng pass/fail
  - [ ] Hỗ trợ args: `--headed`, `--debug`, `--grep <pattern>`
  - [ ] Hiển thị summary: total, passed, failed, skipped, duration

- [ ] **T1.7** Template files
  - [ ] `templates/playwright.config.ts` - base Playwright config
  - [ ] `templates/wdio.conf.ts` - base WebdriverIO + Appium config
  - [ ] `templates/sample.spec.ts` - sample Playwright test
  - [ ] `templates/sample.mobile.ts` - sample WebdriverIO test
  - [ ] `templates/sample.k6.js` - sample k6 performance test

**Day 1 Checkpoint**: `/setup-test-env`, `/devices`, `/appium`, `/install-apk`, `/run-test` hoạt động. ✅

---

## Day 2: Mobile Testing + Reports

### Sáng (4h)

- [ ] **T2.1** Skill: `/mobile-test`
  - [ ] SKILL.md: chạy WebdriverIO test trên mobile
  - [ ] Auto-check: Appium running? → nếu chưa, start
  - [ ] Auto-check: Device connected? → nếu chưa, list devices
  - [ ] Generate WDIO config on-the-fly nếu chưa có
  - [ ] Chạy: `npx wdio run wdio.conf.ts --spec <file>`
  - [ ] Parse results → hiển thị bảng
  - [ ] Capture screenshots on failure
  - [ ] Hỗ trợ args: `--device <id>`, `--platform android|ios`

- [ ] **T2.2** Skill: `/test-report`
  - [ ] SKILL.md: tìm test results (JSON, JUnit XML, HTML reports)
  - [ ] Parse nhiều formats: Playwright JSON, WDIO JSON, k6 JSON
  - [ ] Hiển thị summary: pass/fail counts, duration, coverage
  - [ ] Chi tiết failures: test name, error message, file:line
  - [ ] So sánh với lần chạy trước (nếu có history)
  - [ ] Hỗ trợ args: `--last`, `--suite <name>`, `--failures-only`

- [ ] **T2.3** Helper scripts
  - [ ] `scripts/parse-playwright-results.sh` - extract từ JSON
  - [ ] `scripts/parse-wdio-results.sh` - extract từ JSON
  - [ ] `scripts/parse-k6-results.sh` - extract metrics

### Chiều (4h)

- [ ] **T2.4** Skill: `/monitor`
  - [ ] SKILL.md: tổng quan status toàn bộ hệ thống
  - [ ] Check: Node.js version, Java version
  - [ ] Check: ADB running + devices connected
  - [ ] Check: Appium server status
  - [ ] Check: last test run results (nếu có)
  - [ ] Check: disk space, ports in use
  - [ ] Output dạng dashboard text-based đẹp

- [ ] **T2.5** Cải thiện `/run-test` cho parallel execution
  - [ ] Hỗ trợ chạy nhiều test files cùng lúc
  - [ ] Flag `--parallel` / `--workers <n>`
  - [ ] Aggregate results từ multiple runs

- [ ] **T2.6** Tạo `CLAUDE.md` project config
  - [ ] Hướng dẫn Claude Code cách dùng bộ skills
  - [ ] Conventions cho test files
  - [ ] Default settings / paths

**Day 2 Checkpoint**: `/mobile-test` chạy WDIO trên Android, `/test-report` hiển thị kết quả, `/monitor` dashboard. ✅

---

## Day 3: Polish + Documentation + Publish

### Sáng (4h)

- [ ] **T3.1** Skill mở rộng: `/scaffold-test`
  - [ ] SKILL.md: tạo test project từ template
  - [ ] Hỏi user: Web / Mobile / Performance?
  - [ ] Copy template files phù hợp
  - [ ] Cài dependencies tự động
  - [ ] Tạo folder structure chuẩn

- [ ] **T3.2** Cải thiện error handling cho tất cả skills
  - [ ] Mỗi skill xử lý case: tool not found, device not connected, server not running
  - [ ] Gợi ý fix: "Run `/setup-test-env` to install missing tools"
  - [ ] Gợi ý fix: "Run `/appium start` before running mobile tests"
  - [ ] Fallback graceful khi lỗi

- [ ] **T3.3** Dynamic context injection
  - [ ] `/run-test`: inject !`cat package.json | jq '.scripts'` để detect test scripts
  - [ ] `/devices`: inject !`adb devices` vào prompt
  - [ ] `/monitor`: inject !`ps aux | grep -E "appium|node"` vào prompt
  - [ ] `/test-report`: inject !`ls test-results/ 2>/dev/null` vào prompt

### Chiều (4h)

- [ ] **T3.4** Documentation hoàn chỉnh
  - [ ] Update README.md: hướng dẫn cài đặt skills
  - [ ] Update PLAN.md: reflect Skills approach
  - [ ] Tạo `INSTALL.md`: step-by-step installation guide
  - [ ] Tạo `SKILLS.md`: reference cho tất cả skills + examples

- [ ] **T3.5** Test toàn bộ flow
  - [ ] `/setup-test-env` → verify all tools
  - [ ] `/scaffold-test` → tạo sample project
  - [ ] `/devices` → list connected devices
  - [ ] `/appium start` → start server
  - [ ] `/run-test sample.spec.ts` → chạy web test
  - [ ] `/mobile-test sample.mobile.ts` → chạy mobile test
  - [ ] `/test-report --last` → xem kết quả
  - [ ] `/monitor` → overview status

- [ ] **T3.6** Commit & Push
  - [ ] Review tất cả skill files
  - [ ] Commit: "feat: complete automation testing skills suite"
  - [ ] Push to GitHub
  - [ ] Tag release v0.1.0
  - [ ] Update repo description trên GitHub

**Day 3 Checkpoint**: Bộ skills hoàn chỉnh, documentation đầy đủ, published trên GitHub. ✅

---

## File Structure

```
test-automation-monitor/
├── .claude/
│   └── skills/
│       ├── setup-test-env/
│       │   └── SKILL.md           # Kiểm tra & cài đặt environment
│       ├── devices/
│       │   └── SKILL.md           # List Android/iOS devices
│       ├── appium/
│       │   └── SKILL.md           # Start/stop Appium server
│       ├── install-apk/
│       │   └── SKILL.md           # Install APK lên device
│       ├── run-test/
│       │   └── SKILL.md           # Chạy Playwright/k6 tests
│       ├── mobile-test/
│       │   └── SKILL.md           # Chạy WebdriverIO mobile tests
│       ├── test-report/
│       │   └── SKILL.md           # Xem test results & reports
│       ├── monitor/
│       │   └── SKILL.md           # System status dashboard
│       └── scaffold-test/
│           └── SKILL.md           # Tạo test project từ template
│
├── scripts/
│   ├── check-env.sh               # Verify prerequisites
│   ├── parse-playwright-results.sh
│   ├── parse-wdio-results.sh
│   └── parse-k6-results.sh
│
├── templates/
│   ├── playwright.config.ts        # Base Playwright config
│   ├── wdio.conf.ts                # Base WDIO + Appium config
│   ├── sample.spec.ts              # Sample web test
│   ├── sample.mobile.ts            # Sample mobile test
│   └── sample.k6.js               # Sample k6 test
│
├── examples/
│   ├── web-test-example/           # Complete web testing example
│   ├── mobile-test-example/        # Complete mobile testing example
│   └── perf-test-example/          # Complete k6 example
│
├── CLAUDE.md                       # Project conventions for Claude
├── PLAN.md                         # Architecture & decisions
├── README.md                       # Quick start & overview
├── INSTALL.md                      # Detailed installation guide
├── SKILLS.md                       # Skills reference documentation
├── TODO.md                         # This file
└── .gitignore
```

---

## Summary: 3-Day Sprint

| Day | Focus | Key Deliverable |
|-----|-------|----------------|
| **1** | Core Skills | `/setup-test-env`, `/devices`, `/appium`, `/install-apk`, `/run-test` + templates |
| **2** | Mobile + Reports | `/mobile-test`, `/test-report`, `/monitor` + helper scripts |
| **3** | Polish + Publish | `/scaffold-test`, error handling, docs, testing, release |

## So sánh với Tauri App approach

| | Tauri Desktop App | Claude Code Skills |
|---|---|---|
| Build time | 5-7 ngày | **3 ngày** |
| Complexity | Rust + React + SQLite | **Markdown + Bash** |
| Distribution | .exe installer | **Git clone** |
| Dependencies | Rust toolchain, Node.js | **Chỉ cần Claude Code** |
| UI | GUI dashboard | **Terminal (Claude AI format)** |
| Maintenance | Phức tạp | **Đơn giản** |
| AI-powered | Không | **Có - Claude xử lý logic** |
| Extensibility | Code mới | **Thêm .md file** |

## Priority nếu thiếu thời gian

**Must have** (Day 1):
- [ ] `/setup-test-env`
- [ ] `/devices`
- [ ] `/appium`
- [ ] `/run-test`
- [ ] Templates

**Should have** (Day 2):
- [ ] `/mobile-test`
- [ ] `/test-report`
- [ ] `/monitor`
- [ ] `/install-apk`

**Nice to have** (Day 3):
- [ ] `/scaffold-test`
- [ ] Dynamic context injection
- [ ] Full documentation
- [ ] Examples
