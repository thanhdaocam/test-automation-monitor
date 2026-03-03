# TODO - Test Automation Monitor (Claude Code Skills)

> **Approach**: Bộ Claude Code Skills - slash commands cho automation testing
> **Status: COMPLETED** ✅ | Share qua Git repo, ai cài Claude Code là dùng được

---

## Tổng quan

Thay vì build desktop app phức tạp (Tauri + Rust + React), ta build **bộ Claude Code Skills**:
- Người dùng chỉ cần clone repo + copy `.claude/skills/` vào project
- Gõ `/run-test`, `/devices`, v.v. trong Claude Code
- Claude AI xử lý logic, parse output, hiển thị kết quả đẹp
- Không cần GUI, không cần compile, chạy ở đâu cũng được

### Skills đã tạo

| Skill | Slash Command | Mô tả | Status |
|-------|--------------|-------|--------|
| Run Test | `/run-test` | Chạy Playwright / k6 tests | ✅ Done |
| Devices | `/devices` | List Android/iOS devices đang kết nối | ✅ Done |
| Install APK | `/install-apk` | Cài APK lên Android device | ✅ Done |
| Appium | `/appium` | Start/stop Appium server | ✅ Done |
| Test Report | `/test-report` | Xem kết quả test, thống kê pass/fail | ✅ Done |
| Monitor | `/monitor` | Tổng quan status: devices, services, tests | ✅ Done |
| Setup | `/setup-test-env` | Kiểm tra & cài đặt prerequisites | ✅ Done |
| Mobile Test | `/mobile-test` | Chạy test trên mobile (WDIO + Appium) | ✅ Done |
| Scaffold | `/scaffold-test` | Tạo test project từ template | ✅ Done |

---

## Day 1: Core Skills + Setup ✅ COMPLETED

### Sáng (4h)

- [x] **T1.1** Tạo project structure
  - [x] Tạo thư mục `.claude/skills/` với subdirectories cho mỗi skill
  - [x] Tạo `scripts/` cho helper scripts (bash)
  - [x] Tạo `templates/` cho sample test configs
  - [x] Tạo `examples/` cho sample test files

- [x] **T1.2** Skill: `/setup-test-env`
  - [x] SKILL.md: kiểm tra Node.js, Java, ADB, Appium, Playwright, k6
  - [x] Auto-detect đường dẫn từ PATH / env vars
  - [x] Hướng dẫn cài missing dependencies
  - [x] Verify tất cả đã sẵn sàng
  - [x] Script: `scripts/check-env.sh` - verify prerequisites

- [x] **T1.3** Skill: `/devices`
  - [x] SKILL.md: chạy `adb devices`, parse output
  - [x] Hiển thị bảng: Device ID, Model, OS Version, Status
  - [x] Detect cả emulators và physical devices
  - [x] Cảnh báo nếu ADB không tìm thấy

- [x] **T1.4** Skill: `/appium`
  - [x] SKILL.md: `start` / `stop` / `status` subcommands
  - [x] Start: `appium server --port 4723 --allow-cors`
  - [x] Stop: tìm và kill Appium process
  - [x] Status: check port 4723 + health endpoint
  - [x] Auto-install drivers nếu chưa có

### Chiều (4h)

- [x] **T1.5** Skill: `/install-apk`
  - [x] SKILL.md: nhận path APK + optional device ID
  - [x] Nếu nhiều devices → hỏi user chọn device
  - [x] `adb -s <device> install -r <apk>`
  - [x] Verify installation thành công
  - [x] Hiển thị package name đã cài

- [x] **T1.6** Skill: `/run-test`
  - [x] SKILL.md: detect loại test từ file extension / package.json
  - [x] Playwright: `npx playwright test <pattern> --reporter=json`
  - [x] k6: `k6 run <script> --out json=results.json`
  - [x] Parse JSON output → hiển thị bảng pass/fail
  - [x] Hỗ trợ args: `--headed`, `--debug`, `--grep <pattern>`
  - [x] Hiển thị summary: total, passed, failed, skipped, duration

- [x] **T1.7** Template files
  - [x] `templates/playwright.config.ts` - base Playwright config
  - [x] `templates/wdio.conf.ts` - base WebdriverIO + Appium config
  - [x] `templates/sample.spec.ts` - sample Playwright test
  - [x] `templates/sample.mobile.ts` - sample WebdriverIO test
  - [x] `templates/sample.k6.js` - sample k6 performance test

**Day 1 Checkpoint**: ✅ DONE

---

## Day 2: Mobile Testing + Reports ✅ COMPLETED

### Sáng (4h)

- [x] **T2.1** Skill: `/mobile-test`
  - [x] SKILL.md: chạy WebdriverIO test trên mobile
  - [x] Auto-check: Appium running? → nếu chưa, start
  - [x] Auto-check: Device connected? → nếu chưa, list devices
  - [x] Generate WDIO config on-the-fly nếu chưa có
  - [x] Chạy: `npx wdio run wdio.conf.ts --spec <file>`
  - [x] Parse results → hiển thị bảng
  - [x] Capture screenshots on failure
  - [x] Hỗ trợ args: `--device <id>`, `--platform android|ios`

- [x] **T2.2** Skill: `/test-report`
  - [x] SKILL.md: tìm test results (JSON, JUnit XML, HTML reports)
  - [x] Parse nhiều formats: Playwright JSON, WDIO JSON, k6 JSON
  - [x] Hiển thị summary: pass/fail counts, duration, coverage
  - [x] Chi tiết failures: test name, error message, file:line
  - [x] So sánh với lần chạy trước (nếu có history)
  - [x] Hỗ trợ args: `--last`, `--suite <name>`, `--failures-only`

- [x] **T2.3** Helper scripts
  - [x] `scripts/parse-playwright-results.sh` - extract từ JSON
  - [x] `scripts/parse-wdio-results.sh` - extract từ JSON
  - [x] `scripts/parse-k6-results.sh` - extract metrics

### Chiều (4h)

- [x] **T2.4** Skill: `/monitor`
  - [x] SKILL.md: tổng quan status toàn bộ hệ thống
  - [x] Check: Node.js version, Java version
  - [x] Check: ADB running + devices connected
  - [x] Check: Appium server status
  - [x] Check: last test run results (nếu có)
  - [x] Check: disk space, ports in use
  - [x] Output dạng dashboard text-based đẹp

- [x] **T2.5** Cải thiện `/run-test` cho parallel execution
  - [x] Hỗ trợ chạy nhiều test files cùng lúc
  - [x] Flag `--workers <n>`
  - [x] Dynamic context injection: auto-detect test scripts

- [x] **T2.6** Tạo `CLAUDE.md` project config
  - [x] Hướng dẫn Claude Code cách dùng bộ skills
  - [x] Conventions cho test files
  - [x] Default settings / paths

**Day 2 Checkpoint**: ✅ DONE

---

## Day 3: Polish + Documentation + Publish ✅ COMPLETED

### Sáng (4h)

- [x] **T3.1** Skill mở rộng: `/scaffold-test`
  - [x] SKILL.md: tạo test project từ template
  - [x] Hỏi user: Web / Mobile / Performance?
  - [x] Copy template files phù hợp
  - [x] Cài dependencies tự động
  - [x] Tạo folder structure chuẩn

- [x] **T3.2** Cải thiện error handling cho tất cả skills
  - [x] Mỗi skill có Error Recovery section
  - [x] Gợi ý fix: "Run `/setup-test-env` to install missing tools"
  - [x] Gợi ý fix: "Run `/appium start` before running mobile tests"
  - [x] Cross-references giữa skills (Related Skills section)

- [x] **T3.3** Dynamic context injection
  - [x] `/run-test`: inject `!cat package.json` để detect test scripts + find test files
  - [x] `/devices`: inject `!adb devices -l` vào prompt
  - [x] `/monitor`: inject Appium status + device count + last results
  - [x] `/test-report`: inject `!ls test-results/` vào prompt

### Chiều (4h)

- [x] **T3.4** Documentation hoàn chỉnh
  - [x] README.md: hướng dẫn cài đặt skills + usage examples
  - [x] PLAN.md: reflect Skills approach + architecture
  - [x] `INSTALL.md`: step-by-step installation guide
  - [x] `SKILLS.md`: reference cho tất cả skills + examples + workflow cheatsheet

- [x] **T3.5** Commit & Push
  - [x] Review tất cả skill files
  - [x] Commit & push to GitHub
  - [x] Tag release v0.1.0

**Day 3 Checkpoint**: ✅ DONE

---

## File Structure (Final)

```
test-automation-monitor/
├── .claude/
│   └── skills/
│       ├── setup-test-env/SKILL.md    ✅
│       ├── devices/SKILL.md           ✅
│       ├── appium/SKILL.md            ✅
│       ├── install-apk/SKILL.md       ✅
│       ├── run-test/SKILL.md          ✅
│       ├── mobile-test/SKILL.md       ✅
│       ├── test-report/SKILL.md       ✅
│       ├── monitor/SKILL.md           ✅
│       └── scaffold-test/SKILL.md     ✅
│
├── scripts/
│   ├── check-env.sh                   ✅
│   ├── parse-playwright-results.sh    ✅
│   ├── parse-wdio-results.sh          ✅
│   └── parse-k6-results.sh            ✅
│
├── templates/
│   ├── playwright.config.ts           ✅
│   ├── wdio.conf.ts                   ✅
│   ├── sample.spec.ts                 ✅
│   ├── sample.mobile.ts              ✅
│   └── sample.k6.js                   ✅
│
├── CLAUDE.md                          ✅
├── PLAN.md                            ✅
├── README.md                          ✅
├── INSTALL.md                         ✅
├── SKILLS.md                          ✅
├── TODO.md                            ✅ (this file)
└── .gitignore                         ✅
```

---

## Summary

| Day | Focus | Status |
|-----|-------|--------|
| **1** | Core Skills + Templates | ✅ COMPLETED |
| **2** | Mobile + Reports + Monitor | ✅ COMPLETED |
| **3** | Polish + Docs + Release | ✅ COMPLETED |

**Total: 9 skills, 5 templates, 4 scripts, 5 docs** — all shipped.
