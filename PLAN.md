# Test Automation Monitor - Implementation Plan

## Mục tiêu

Xây dựng ứng dụng Windows desktop để **monitor và quản lý automation test** trên:
- **Web** (Playwright)
- **Android native** (.apk)
- **iOS native** (.ipa)
- **WebView** bên trong mobile app
- **Performance** (k6)

Ứng dụng này là trung tâm điều khiển toàn bộ automation test pipeline, tích hợp CI/CD, notifications, scheduling, và reporting.

---

## Tech Stack

| Layer | Technology | Lý do |
|-------|-----------|-------|
| Desktop Framework | **Tauri v2** | Lightweight (~10MB), Rust backend, bảo mật cao |
| Frontend | **React 18 + TypeScript + Vite** | Modern, fast HMR |
| UI Library | **Shadcn/ui + Tailwind CSS v4** | Professional UI, customizable |
| Charts | **Recharts** | Realtime charts, dễ dùng với React |
| State Management | **Zustand** | Nhẹ, đơn giản, đủ mạnh |
| Database | **SQLite** (via Tauri plugin) | Local, zero-config, nhanh |
| Web Testing | **Playwright** (giữ nguyên) | Đã có experience |
| Performance Testing | **k6** (giữ nguyên) | Đã có experience |
| Mobile Testing | **Appium 2.0 + WebdriverIO** | Best cho Android + iOS + WebView |
| Realtime | **Tauri Events** | Push updates từ Rust → React |
| CI/CD API | **Embedded HTTP server** (Rust Axum) | REST API + Webhooks |

---

## Tại sao chọn Appium 2.0 + WebdriverIO cho Mobile?

| Tiêu chí | Appium 2.0 | Maestro | Detox |
|----------|-----------|---------|-------|
| Android native (.apk) | ✅ | ✅ | ❌ (React Native only) |
| iOS native (.ipa) | ✅ | ✅ | ❌ |
| **WebView bên trong app** | ✅ First-class | ❌ Limited | ❌ |
| TypeScript support | ✅ (via WebdriverIO) | ❌ (YAML only) | ✅ |
| Tích hợp với Playwright | ✅ Excellent | ❌ Poor | ❌ Poor |
| Maturity / ecosystem | ✅ Lớn nhất | ⚠️ Mới | ⚠️ Niche |

**Kết luận**: Appium 2.0 là framework duy nhất hỗ trợ đầy đủ native Android + native iOS + WebView context switching trong hybrid apps.

---

## Project Structure

```
test-automation-monitor/
│
├── src-tauri/                        # Rust backend (Tauri v2)
│   ├── src/
│   │   ├── main.rs                   # Entry point
│   │   ├── lib.rs                    # Tauri commands registry
│   │   │
│   │   ├── commands/                 # Tauri IPC commands (frontend gọi vào)
│   │   │   ├── mod.rs
│   │   │   ├── test_runner.rs        # Start/stop/monitor tests
│   │   │   ├── device.rs             # Device management (ADB, iOS)
│   │   │   ├── appium.rs             # Appium server lifecycle
│   │   │   ├── reports.rs            # Query test results từ DB
│   │   │   ├── scheduler.rs          # Cron-like test scheduling
│   │   │   └── settings.rs           # App configuration
│   │   │
│   │   ├── services/                 # Business logic
│   │   │   ├── mod.rs
│   │   │   ├── appium_manager.rs     # Start/stop Appium server process
│   │   │   ├── device_detector.rs    # ADB + libimobiledevice detection
│   │   │   ├── test_orchestrator.rs  # Parallel test execution engine
│   │   │   ├── notification.rs       # Slack/Email/Discord/Teams
│   │   │   ├── ci_server.rs          # Embedded Axum REST API
│   │   │   └── db.rs                 # SQLite operations
│   │   │
│   │   └── models/                   # Data structures
│   │       ├── mod.rs
│   │       ├── test_case.rs
│   │       ├── test_run.rs
│   │       ├── device.rs
│   │       └── schedule.rs
│   │
│   ├── migrations/                   # SQLite migrations
│   │   └── 001_initial.sql
│   ├── Cargo.toml
│   └── tauri.conf.json
│
├── src/                              # React frontend
│   ├── main.tsx                      # React entry
│   ├── App.tsx                       # Root component + Router
│   │
│   ├── routes/                       # Pages
│   │   ├── Dashboard.tsx             # Main monitoring dashboard
│   │   ├── TestSuites.tsx            # Test case management
│   │   ├── TestRunner.tsx            # Live test execution view
│   │   ├── Devices.tsx               # Connected devices panel
│   │   ├── Reports.tsx               # Historical reports & trends
│   │   ├── Scheduler.tsx             # Scheduled test runs
│   │   ├── Settings.tsx              # CI/CD, notifications config
│   │   └── CICDIntegration.tsx       # Pipeline management
│   │
│   ├── components/
│   │   ├── ui/                       # Shadcn/ui components (auto-generated)
│   │   ├── layout/
│   │   │   ├── Sidebar.tsx           # Navigation sidebar
│   │   │   └── Header.tsx            # Top bar
│   │   ├── dashboard/
│   │   │   ├── RealtimeChart.tsx     # Live updating chart
│   │   │   ├── TestStatusCard.tsx    # Pass/fail/running counts
│   │   │   ├── DeviceGrid.tsx        # Device status overview
│   │   │   └── RecentRuns.tsx        # Latest test runs table
│   │   ├── test-runner/
│   │   │   ├── LiveLog.tsx           # Streaming test output (xterm.js)
│   │   │   ├── StepViewer.tsx        # Test step visualization
│   │   │   └── ScreenCapture.tsx     # Mobile screenshot viewer
│   │   └── reports/
│   │       ├── TrendChart.tsx        # Pass rate over time
│   │       ├── PassFailPie.tsx       # Pie chart
│   │       └── DurationHeatmap.tsx   # Duration per test heatmap
│   │
│   ├── hooks/
│   │   ├── useTauriEvent.ts          # Listen to Tauri events
│   │   ├── useDevices.ts             # Device state hook
│   │   └── useTestRun.ts             # Test run state hook
│   │
│   ├── stores/
│   │   ├── testStore.ts              # Zustand: test state
│   │   ├── deviceStore.ts            # Zustand: device state
│   │   └── settingsStore.ts          # Zustand: settings state
│   │
│   └── lib/
│       ├── tauri-api.ts              # Typed Tauri invoke wrappers
│       └── types.ts                  # Shared TypeScript types
│
├── tests/                            # Test scripts (user tạo)
│   ├── web/                          # Playwright test files
│   │   └── example.spec.ts
│   ├── mobile/                       # WebdriverIO + Appium test files
│   │   └── example.mobile.ts
│   └── performance/                  # k6 scripts
│       └── example.k6.js
│
├── package.json
├── pnpm-lock.yaml
├── vite.config.ts
├── tailwind.config.ts
├── tsconfig.json
├── PLAN.md                           # (file này)
└── README.md
```

---

## Database Schema (SQLite)

```sql
-- Test Suites: nhóm các test cases
CREATE TABLE test_suites (
    id TEXT PRIMARY KEY,           -- UUID
    name TEXT NOT NULL,
    description TEXT,
    type TEXT CHECK(type IN ('web', 'mobile', 'performance')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Test Cases: từng test case
CREATE TABLE test_cases (
    id TEXT PRIMARY KEY,
    suite_id TEXT REFERENCES test_suites(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    file_path TEXT NOT NULL,       -- đường dẫn đến file test script
    target_platform TEXT,          -- 'web', 'android', 'ios', 'webview'
    tags TEXT,                     -- JSON array: ["smoke", "regression"]
    priority TEXT CHECK(priority IN ('low', 'medium', 'high', 'critical')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Test Runs: mỗi lần chạy test suite
CREATE TABLE test_runs (
    id TEXT PRIMARY KEY,
    suite_id TEXT REFERENCES test_suites(id),
    status TEXT CHECK(status IN ('queued', 'running', 'passed', 'failed', 'cancelled')),
    trigger_source TEXT,           -- 'manual', 'scheduled', 'ci', 'webhook'
    total_tests INTEGER DEFAULT 0,
    passed_tests INTEGER DEFAULT 0,
    failed_tests INTEGER DEFAULT 0,
    skipped_tests INTEGER DEFAULT 0,
    started_at DATETIME,
    finished_at DATETIME,
    duration_ms INTEGER,
    device_info TEXT,              -- JSON: {name, platform, udid}
    environment TEXT               -- JSON: {browser, os, appium_version}
);

-- Test Results: kết quả từng test case trong 1 run
CREATE TABLE test_results (
    id TEXT PRIMARY KEY,
    run_id TEXT REFERENCES test_runs(id) ON DELETE CASCADE,
    case_id TEXT REFERENCES test_cases(id),
    status TEXT CHECK(status IN ('passed', 'failed', 'skipped', 'error')),
    duration_ms INTEGER,
    error_message TEXT,
    stack_trace TEXT,
    screenshot_path TEXT,          -- path đến screenshot khi fail
    video_path TEXT,               -- path đến video recording
    log TEXT,                      -- full log output
    retry_count INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Schedules: lịch chạy tự động
CREATE TABLE schedules (
    id TEXT PRIMARY KEY,
    suite_id TEXT REFERENCES test_suites(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    cron_expression TEXT NOT NULL,  -- "0 */2 * * *" = mỗi 2 giờ
    enabled BOOLEAN DEFAULT 1,
    last_run_at DATETIME,
    next_run_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Devices: thiết bị đã kết nối
CREATE TABLE devices (
    id TEXT PRIMARY KEY,
    name TEXT,
    platform TEXT,                 -- 'android', 'ios'
    udid TEXT UNIQUE,              -- device unique ID
    os_version TEXT,
    model TEXT,
    status TEXT CHECK(status IN ('online', 'offline', 'busy')),
    last_seen_at DATETIME
);

-- Notification Channels: cấu hình thông báo
CREATE TABLE notification_channels (
    id TEXT PRIMARY KEY,
    type TEXT CHECK(type IN ('slack', 'email', 'discord', 'teams')),
    name TEXT NOT NULL,
    config TEXT NOT NULL,           -- JSON: webhook URL, SMTP settings, etc.
    enabled BOOLEAN DEFAULT 1,
    trigger_on TEXT,                -- JSON array: ["on_fail", "on_complete"]
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## Core Features Chi Tiết

### 1. Dashboard Realtime Monitoring

**Flow**: Rust backend emit events → React frontend listen via `@tauri-apps/api/event`

Hiển thị:
- Số test đang chạy / queued / completed
- Pass/fail rate (pie chart)
- Thời gian trung bình per test
- Device status grid (online/offline/busy)
- Recent runs table (last 20 runs)
- Live updating trend chart

### 2. Device Management

```
┌─ Device Detection Flow ─────────────────────────┐
│                                                   │
│  [Rust Service]                                   │
│     │                                             │
│     ├─→ adb devices          → Android devices    │
│     ├─→ idevice_id -l        → iOS devices        │
│     └─→ Poll every 5 seconds → Update SQLite      │
│                                                   │
│  [React UI]                                       │
│     └─→ Listen "device-changed" event             │
│         └─→ Update DeviceGrid component           │
└───────────────────────────────────────────────────┘
```

- **Android**: `adb devices`, `adb install app.apk`, `adb shell getprop`
- **iOS**: `idevice_id`, `ios-deploy --install`, `ideviceinfo`
- **WebView**: Appium auto switch context NATIVE_APP ↔ WEBVIEW_*

### 3. Test Orchestrator

```
┌─ Test Execution Flow ────────────────────────────────────┐
│                                                           │
│  User clicks "Run" in UI                                  │
│     │                                                     │
│     ▼                                                     │
│  [Tauri Command] → test_runner::start_run                 │
│     │                                                     │
│     ▼                                                     │
│  [Test Orchestrator Service]                              │
│     │                                                     │
│     ├─→ Web tests?   → spawn: npx playwright test ...     │
│     ├─→ Mobile tests? → spawn: npx wdio run ...           │
│     └─→ Perf tests?  → spawn: k6 run --out json ...      │
│                                                           │
│  Mỗi process output JSON results qua stdout               │
│     │                                                     │
│     ▼                                                     │
│  [Rust] Parse JSON → Save to SQLite → Emit Tauri Event    │
│     │                                                     │
│     ▼                                                     │
│  [React] Receive event → Update UI realtime               │
└───────────────────────────────────────────────────────────┘
```

**Parallel execution**: Rust dùng `tokio::spawn` để chạy nhiều test processes cùng lúc.

**Custom JSON Reporter** cho mỗi engine:
- Playwright: dùng `--reporter=json` built-in
- WebdriverIO: custom WDIO reporter output JSON per test
- k6: `--out json` flag

### 4. Test Case Management

- CRUD test suites / test cases trong SQLite
- Mỗi test case link đến file script thật (.spec.ts, .mobile.ts, .k6.js)
- UI cho phép:
  - Tạo/sửa/xoá suite và case
  - Assign platform (web/android/ios/webview)
  - Gắn tags: smoke, regression, critical
  - Set priority: low/medium/high/critical
  - Import/export suites (JSON)

### 5. Scheduled Test Runs

- **Backend**: Rust crate `tokio-cron-scheduler`
- **Cron syntax**: `"0 */2 * * *"` = chạy mỗi 2 giờ
- **Queue**: Nếu device đang busy → queue lại, chạy khi device free
- **UI**: Bảng quản lý schedules, toggle enable/disable, xem next run time

### 6. CI/CD Integration

**Embedded Axum HTTP Server** chạy port 9876 (configurable):

```
REST API Endpoints:
───────────────────────────────────────────────────
POST   /api/trigger              Trigger test suite
  Body: { "suite_id": "...", "device_id": "..." }
  Response: { "run_id": "..." }

GET    /api/status/:runId        Check run status
  Response: { "status": "running", "progress": 75 }

GET    /api/results/:runId       Get full results
  Response: { "passed": 10, "failed": 2, "results": [...] }

POST   /api/webhook/github       GitHub Actions webhook
POST   /api/webhook/gitlab       GitLab CI webhook
POST   /api/webhook/jenkins      Jenkins webhook

GET    /api/devices              List connected devices
GET    /api/suites               List test suites
───────────────────────────────────────────────────
```

**CLI headless mode**:
```bash
test-monitor --headless --suite=smoke --device=emulator-5554 --output=junit.xml
```

**GitHub Actions example**:
```yaml
- name: Trigger mobile tests
  run: |
    RUN_ID=$(curl -s -X POST http://localhost:9876/api/trigger \
      -H "Content-Type: application/json" \
      -d '{"suite_id": "mobile-smoke"}' | jq -r '.run_id')

    # Poll until complete
    while true; do
      STATUS=$(curl -s http://localhost:9876/api/status/$RUN_ID | jq -r '.status')
      if [ "$STATUS" = "passed" ] || [ "$STATUS" = "failed" ]; then break; fi
      sleep 10
    done

    curl -s http://localhost:9876/api/results/$RUN_ID > test-results.json
```

### 7. Notifications

| Channel | Config cần thiết | Gửi qua |
|---------|-----------------|---------|
| Slack | Webhook URL | HTTP POST |
| Email | SMTP host, port, user, pass | Rust crate `lettre` |
| Discord | Webhook URL | HTTP POST |
| Teams | Webhook URL | HTTP POST |

**Trigger rules** (configurable per channel):
- `on_fail` - Gửi khi có test fail
- `on_complete` - Gửi khi run hoàn tất
- `on_threshold` - Gửi khi pass rate < X%
- `on_flaky` - Gửi khi detect flaky test

### 8. Reports & Analytics

- **History**: Lọc theo date range, suite, device, status
- **Trend charts**: Pass rate over time, duration trends
- **Flaky detection**: Auto-flag test case flip pass↔fail trong 3 runs liên tiếp
- **Compare**: So sánh 2 runs side-by-side
- **Export**: HTML report, PDF, JUnit XML (cho CI/CD)

---

## Key Dependencies

### Rust (src-tauri/Cargo.toml)

```toml
[dependencies]
tauri = { version = "2", features = ["tray-icon"] }
tauri-plugin-sql = { version = "2", features = ["sqlite"] }
tauri-plugin-shell = "2"
tauri-plugin-notification = "2"
tauri-plugin-fs = "2"
tauri-plugin-dialog = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tokio = { version = "1", features = ["full"] }
tokio-cron-scheduler = "0.11"
axum = "0.7"
tower-http = { version = "0.5", features = ["cors"] }
reqwest = { version = "0.12", features = ["json"] }
lettre = { version = "0.11", features = ["tokio1-native-tls"] }
uuid = { version = "1", features = ["v4"] }
chrono = { version = "0.4", features = ["serde"] }
rusqlite = { version = "0.31", features = ["bundled"] }
log = "0.4"
env_logger = "0.11"
```

### Node.js (package.json)

```json
{
  "dependencies": {
    "@tauri-apps/api": "^2.0.0",
    "@tauri-apps/plugin-sql": "^2.0.0",
    "@tauri-apps/plugin-shell": "^2.0.0",
    "@tauri-apps/plugin-fs": "^2.0.0",
    "@tauri-apps/plugin-dialog": "^2.0.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "react-router-dom": "^7.0.0",
    "@tanstack/react-query": "^5.0.0",
    "zustand": "^5.0.0",
    "recharts": "^2.12.0",
    "@xterm/xterm": "^5.5.0",
    "date-fns": "^3.6.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.3.0"
  },
  "devDependencies": {
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "typescript": "^5.5.0",
    "vite": "^6.0.0",
    "@vitejs/plugin-react": "^4.3.0",
    "tailwindcss": "^4.0.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0"
  }
}
```

### Test Frameworks (riêng, global hoặc project-level)

```bash
# Playwright (đã có)
pnpm add -D @playwright/test

# WebdriverIO + Appium cho mobile
pnpm add -D webdriverio @wdio/cli @wdio/local-runner @wdio/mocha-framework
pnpm add -D @wdio/appium-service @wdio/json-reporter
npm install -g appium
appium driver install uiautomator2    # Android
appium driver install xcuitest         # iOS

# k6 (đã có, binary install)
```

---

## Implementation Phases

### Phase 1: Foundation (1-2 tuần)

**Mục tiêu**: Project chạy được, có UI cơ bản, database ready.

| # | Task | Output |
|---|------|--------|
| 1 | Scaffold Tauri v2 + React + Vite | Project build & run thành công |
| 2 | Setup Tailwind CSS v4 + Shadcn/ui | UI components sẵn sàng |
| 3 | SQLite database + migrations | Tất cả tables created |
| 4 | Basic layout: Sidebar + Header + Content area | Navigation hoạt động |
| 5 | Settings page | Configure paths (Appium, ADB, etc.) |
| 6 | Zustand stores + Tauri API wrappers | State management ready |

**Verification**: App khởi động, navigate giữa các trang, lưu settings vào SQLite.

### Phase 2: Device Management + Appium (1-2 tuần)

**Mục tiêu**: Detect devices, quản lý Appium server.

| # | Task | Output |
|---|------|--------|
| 1 | Rust: ADB device detection service | Detect Android devices/emulators |
| 2 | Rust: iOS device detection (libimobiledevice) | Detect iOS devices |
| 3 | Rust: Appium server lifecycle (start/stop) | Appium start/stop từ app |
| 4 | Devices page UI: device grid + status | Real-time device list |
| 5 | Install .apk / .ipa lên device | Deploy app từ UI |

**Verification**: Kết nối Android phone/emulator, hiện trong device grid, install .apk thành công.

### Phase 3: Test Runner Engine (2-3 tuần)

**Mục tiêu**: Chạy tests trên cả 3 platform, xem kết quả realtime.

| # | Task | Output |
|---|------|--------|
| 1 | Test orchestrator service (Rust) | Spawn & manage test processes |
| 2 | Playwright runner integration | Web tests chạy & report |
| 3 | WebdriverIO + Appium runner integration | Mobile tests chạy & report |
| 4 | k6 runner integration | Performance tests chạy & report |
| 5 | JSON result parser → SQLite | Results lưu vào DB |
| 6 | Realtime event streaming → React | UI update live |
| 7 | TestRunner page: live log + step viewer | Xem test đang chạy |
| 8 | Screenshot/video capture on failure | Evidence khi test fail |

**Verification**: Chạy Playwright web test + WebdriverIO mobile test cùng lúc, thấy kết quả realtime trong UI.

### Phase 4: Test Management + Dashboard (1-2 tuần)

**Mục tiêu**: Dashboard overview, quản lý test cases.

| # | Task | Output |
|---|------|--------|
| 1 | TestSuites page: CRUD suites & cases | Tạo/sửa/xoá test suites |
| 2 | Dashboard: TestStatusCard + RecentRuns | Tổng quan nhanh |
| 3 | Dashboard: RealtimeChart (pass/fail trend) | Chart realtime |
| 4 | Dashboard: DeviceGrid summary | Device overview |
| 5 | Tags, priority, platform assignment | Organize test cases |

**Verification**: Tạo suite, thêm test cases, chạy, xem kết quả trên dashboard.

### Phase 5: Scheduling + CI/CD (1-2 tuần)

**Mục tiêu**: Tự động hoá chạy test, tích hợp CI/CD.

| # | Task | Output |
|---|------|--------|
| 1 | Cron scheduler backend (tokio-cron) | Schedule chạy tự động |
| 2 | Scheduler page UI | Quản lý schedules |
| 3 | Axum REST API server (embedded) | API sẵn sàng |
| 4 | Webhook receivers (GitHub/GitLab/Jenkins) | Trigger từ CI |
| 5 | CLI headless mode | Chạy không cần GUI |
| 6 | CICDIntegration page | Quản lý pipeline config |

**Verification**: Schedule chạy mỗi giờ, trigger qua curl, nhận webhook từ GitHub Actions.

### Phase 6: Reports + Notifications (1 tuần)

**Mục tiêu**: Báo cáo chi tiết, thông báo tự động.

| # | Task | Output |
|---|------|--------|
| 1 | Reports page: history + filters | Xem lịch sử test runs |
| 2 | Trend analysis charts | Biểu đồ xu hướng |
| 3 | Flaky test detection | Auto-flag flaky tests |
| 4 | Export: HTML, PDF, JUnit XML | Download reports |
| 5 | Notification channels config UI | Setup Slack/Email/etc |
| 6 | Notification service (Rust) | Gửi thông báo tự động |
| 7 | Compare runs side-by-side | So sánh 2 runs |

**Verification**: Xem report 30 ngày, export PDF, nhận Slack notification khi test fail.

---

## Architecture Diagrams

### Overall System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                     TAURI v2 APPLICATION                         │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │              REACT FRONTEND (WebView)                    │     │
│  │                                                          │     │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │     │
│  │  │Dashboard │ │TestSuites│ │TestRunner│ │ Devices  │   │     │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │     │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐               │     │
│  │  │ Reports  │ │Scheduler │ │ Settings │               │     │
│  │  └──────────┘ └──────────┘ └──────────┘               │     │
│  │                                                          │     │
│  │  [Zustand Stores] ←──── [Tauri Events] ←────────────┐  │     │
│  └──────────────────────────────────────────────────────┼──┘     │
│                          │ invoke()                      │        │
│                          ▼                               │        │
│  ┌──────────────────────────────────────────────────────┼──┐     │
│  │              RUST BACKEND                             │  │     │
│  │                                                       │  │     │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │  │     │
│  │  │   Commands   │  │   Services   │  │   Models   │  │  │     │
│  │  │  (IPC API)   │  │  (Business)  │  │   (Data)   │  │  │     │
│  │  └──────┬───────┘  └──────┬───────┘  └────────────┘  │  │     │
│  │         │                  │                           │  │     │
│  │         ▼                  ▼                           │  │     │
│  │  ┌─────────────────────────────────────────────────┐  │  │     │
│  │  │            Test Orchestrator                     │  │  │     │
│  │  │                                                  │──┘  │     │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐        │     │     │
│  │  │  │Playwright│ │WebdriverIO│ │    k6    │        │     │     │
│  │  │  │ Process  │ │ Process  │ │ Process  │        │     │     │
│  │  │  └────┬─────┘ └────┬─────┘ └────┬─────┘        │     │     │
│  │  │       │stdout JSON  │stdout JSON  │stdout JSON   │     │     │
│  │  │       └──────────┬──┴─────────────┘              │     │     │
│  │  │                  ▼                               │     │     │
│  │  │         ┌──────────────┐                         │     │     │
│  │  │         │  SQLite DB   │                         │     │     │
│  │  │         └──────────────┘                         │     │     │
│  │  └──────────────────────────────────────────────────┘     │     │
│  │                                                           │     │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │     │
│  │  │ Axum Server  │  │  Scheduler   │  │ Notification │    │     │
│  │  │ (CI/CD API)  │  │  (Cron jobs) │  │  (Webhooks)  │    │     │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │     │
│  └───────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼──────────────┐
                ▼             ▼              ▼
         ┌──────────┐  ┌──────────┐  ┌──────────────┐
         │ Android  │  │   iOS    │  │   Browser    │
         │ Device/  │  │  Device  │  │  (Chromium/  │
         │ Emulator │  │          │  │   Firefox)   │
         └──────────┘  └──────────┘  └──────────────┘
```

### Data Flow cho Realtime Updates

```
[Test Process stdout]
    → [Rust: parse JSON line]
    → [Rust: INSERT INTO test_results]
    → [Rust: app.emit("test-result", data)]
    → [React: listen("test-result")]
    → [Zustand: update store]
    → [React: re-render LiveLog + Charts]
```

---

## Appium 2.0 Setup Guide

### Android Setup
```bash
# 1. Install Android SDK (hoặc Android Studio)
# Set ANDROID_HOME environment variable

# 2. Install Appium 2.0
npm install -g appium

# 3. Install UiAutomator2 driver
appium driver install uiautomator2

# 4. Verify
appium driver list --installed
adb devices
```

### iOS Setup (cần macOS)
```bash
# 1. Install Xcode từ App Store
# 2. Install command line tools
xcode-select --install

# 3. Install XCUITest driver
appium driver install xcuitest

# 4. Install ios-deploy
brew install ios-deploy
brew install libimobiledevice

# 5. Verify
idevice_id -l
```

### WebdriverIO Config Example (wdio.conf.ts)
```typescript
export const config: WebdriverIO.Config = {
    runner: 'local',
    port: 4723,
    specs: ['./tests/mobile/**/*.ts'],
    capabilities: [{
        platformName: 'Android',
        'appium:automationName': 'UiAutomator2',
        'appium:app': './app/test.apk',
        'appium:deviceName': 'emulator-5554',
        // WebView support:
        'appium:autoWebview': false,  // start in native context
        'appium:chromedriverAutodownload': true,
    }],
    framework: 'mocha',
    reporters: ['json'],
};
```

### WebView Context Switching Example
```typescript
// Trong test script:
// Switch từ native sang WebView
const contexts = await driver.getContexts();
// contexts = ['NATIVE_APP', 'WEBVIEW_com.example.app']
await driver.switchContext('WEBVIEW_com.example.app');
// Giờ có thể dùng web selectors
await $('h1').getText();
// Switch lại native
await driver.switchContext('NATIVE_APP');
await $('~loginButton').click();
```

---

## Notes & Tips

1. **Tauri v2 vs v1**: Dùng v2 vì có plugin system mới, multi-window support, tray icon built-in
2. **SQLite vs Server DB**: Chọn SQLite vì app chạy local, không cần server, backup = copy 1 file
3. **Axum embedded**: Chạy HTTP server trong cùng process Tauri, port 9876, cho CI/CD gọi vào
4. **Appium lifecycle**: App tự start/stop Appium server, user không cần manage manually
5. **k6 integration**: k6 là Go binary, chạy qua shell command, parse JSON output
6. **iOS trên Windows**: Không thể test iOS native trên Windows. Cần Mac hoặc cloud service (BrowserStack/SauceLabs). App sẽ hiện warning nếu detect Windows + iOS test.
