---
name: mobile-test
version: 1.0.0
description: Chạy kiểm thử WebdriverIO + Appium trên thiết bị Android hoặc iOS. Tự động khởi động Appium nếu cần, tự động phát hiện thiết bị. Hỗ trợ ứng dụng native, WebView hybrid và trình duyệt di động. Dùng cho kiểm thử ứng dụng di động.
allowed-tools: Bash(npx *), Bash(appium *), Bash(adb *), Bash(curl *), Bash(lsof *), Bash(netstat *), Bash(node *), Bash(cat *), Bash(ls *), Bash(kill *), Bash(taskkill *), Bash(sleep *), Read, Grep, Glob, Write
user-invocable: true
argument-hint: <test-file> [--device id] [--platform android|ios] [--app path.apk]
disable-model-invocation: true
---

# Chạy kiểm thử di động

Thực thi kiểm thử WebdriverIO + Appium trên thiết bị Android/iOS đã kết nối.

## Phân tích tham số

- `$0` = đường dẫn file kiểm thử (bắt buộc)
- `--device <id>` = ID thiết bị đích (tùy chọn, tự phát hiện nếu chỉ có một thiết bị)
- `--platform android|ios` = nền tảng đích (tùy chọn, mặc định: android)
- `--app <path>` = đường dẫn tới .apk hoặc .ipa để cài đặt trước khi kiểm thử

## Các bước

### 1. Kiểm tra tiền điều kiện

**Kiểm tra Appium server:**
```bash
curl -s http://localhost:4723/status 2>/dev/null
```
Nếu chưa chạy, khởi động nó:

**Trên macOS/Linux:**
```bash
APPIUM_LOG=$(node -e "console.log(require('path').join(require('os').tmpdir(),'appium.log'))") && nohup appium server --port 4723 --allow-cors > "$APPIUM_LOG" 2>&1 &
sleep 3
curl -s http://localhost:4723/status
```

**Trên Windows:**
```bash
node -e "const p=require('path').join(require('os').tmpdir(),'appium.log');const {spawn}=require('child_process');const fs=require('fs');const c=spawn('appium',['server','--port','4723','--allow-cors'],{detached:true,stdio:['ignore',fs.openSync(p,'w'),fs.openSync(p,'a')]});c.unref();console.log('Đã khởi động. Log:'+p)"
```
Đợi 3 giây rồi kiểm tra lại health check.

Nếu vẫn không khởi động được, báo lỗi và gợi ý `/appium start`.

**Kiểm tra thiết bị:**
```bash
adb devices -l
```
- Không có thiết bị → lỗi: "Không có thiết bị nào kết nối. Kết nối thiết bị hoặc khởi động trình giả lập."
- Một thiết bị → tự động sử dụng
- Nhiều thiết bị + không có `--device` → liệt kê và yêu cầu người dùng chỉ định
- Đã chỉ định `--device` → xác minh thiết bị có trong danh sách

**Kiểm tra file kiểm thử tồn tại:**
```bash
ls -la "$0" 2>/dev/null
```
Nếu không tìm thấy, tìm kiếm:
```bash
node -e "const fs=require('fs');const path=require('path');const target=process.argv[1]||'';function walk(d,depth,max){let r=[];if(depth>max)return r;try{for(const f of fs.readdirSync(d)){if(f.startsWith('.'))continue;const p=path.join(d,f);try{const s=fs.statSync(p);if(s.isDirectory()&&f!=='node_modules')r=r.concat(walk(p,depth+1,max));else if(f===path.basename(target))r.push(p)}catch{}}}catch{}return r}const files=walk('.',0,5);console.log(files.length?files.join('\n'):'Không tìm thấy')" "$0"
```

### 2. Tìm hoặc tạo cấu hình WDIO

**Tìm cấu hình hiện có:**
```bash
ls wdio.conf.ts wdio.conf.js .wdio.conf.ts 2>/dev/null
```

**Nếu không tìm thấy**, tạo cấu hình tối thiểu. Tạo `wdio.conf.ts` với:
- Runner: local
- Port: 4723 (Appium)
- Framework: mocha
- Capabilities: dựa trên `--platform` và `--device`
- Nếu có `--app`, đặt capability `appium:app`
- Reporter: spec + json

Sử dụng công cụ Write để tạo cấu hình tạm nếu cần.

### 3. Cài đặt ứng dụng (nếu có --app)

```bash
adb -s <device_id> install -r <app_path>
```
Xác minh cài đặt thành công.

### 4. Chạy kiểm thử

Xây dựng lệnh:
```bash
npx wdio run wdio.conf.ts --spec $0
```

Thực thi và truyền trực tiếp đầu ra. Ghi nhận mã thoát và đầu ra JSON reporter.

### 5. Phân tích & Hiển thị kết quả

Đọc đầu ra kiểm thử và hiển thị:

```
Kết quả kiểm thử di động (WebdriverIO + Appium)
══════════════════════════════════════════════════════════════
Thiết bị:   Pixel 7 (emulator-5554) - Android 14
Ứng dụng:   com.example.myapp
Appium:     2.5.1 (uiautomator2)
──────────────────────────────────────────────────────────────
  ✓ mở ứng dụng thành công                             3.1s
  ✓ đăng nhập với thông tin hợp lệ                     4.2s
  ✓ điều hướng đến trang chính                          2.1s
  ✓ chuyển sang WebView và xác minh nội dung            2.8s
  ✗ gửi biểu mẫu trong WebView                         5.3s
    Lỗi: element ("h1") vẫn chưa hiển thị sau 5000ms
    tại sample.mobile.ts:45:15

Ảnh chụp màn hình:
  ✗ gửi biểu mẫu → ./screenshots/failure_001.png
──────────────────────────────────────────────────────────────
Tổng kết: 4 đạt, 1 lỗi, 0 bỏ qua
Thời gian: 17.5s
══════════════════════════════════════════════════════════════
```

### 6. Sau khi chạy

- Hiển thị đường dẫn ảnh chụp cho các kiểm thử lỗi (nếu có)
- Gợi ý: "Sử dụng `/test-report` để phân tích chi tiết"
- Nếu kiểm thử WebView lỗi, gợi ý kiểm tra ngữ cảnh WebView có sẵn không
- Nếu phát hiện ứng dụng crash, gợi ý kiểm tra `adb logcat`

## Xử lý lỗi

- Nếu Appium không khởi động: hiển thị log lỗi và gợi ý `/appium install-drivers` hoặc kiểm tra cài đặt Java.
- Nếu không tìm thấy thiết bị: gợi ý `/devices` để xem thiết bị khả dụng, hoặc kiểm tra kết nối USB.
- Nếu không tìm thấy `wdio.conf.ts` và tạo tự động thất bại: hướng dẫn người dùng chạy `/scaffold-test mobile` trước.
- Nếu ngữ cảnh WebView không khả dụng: gợi ý đảm bảo ứng dụng đã bật debug WebView (`setWebContentsDebuggingEnabled(true)`).
- Nếu `ECONNREFUSED` trên cổng 4723: Appium chưa chạy, tự động khởi động hoặc gợi ý `/appium start`.
- Nếu tạo phiên thất bại: kiểm tra driver Appium đúng đã được cài cho nền tảng đích.
- Nếu kiểm thử iOS trên Windows: cảnh báo kiểm thử iOS yêu cầu macOS. Gợi ý dùng Android thay thế.
- Nếu lỗi timeout: gợi ý tăng `waitforTimeout` trong wdio.conf.ts hoặc kiểm tra thời gian tải ứng dụng.

## Kỹ năng liên quan

- Kiểm tra thiết bị: `/devices`
- Khởi động Appium: `/appium start`
- Cài đặt APK trước: `/install-apk <path.apk>`
- Xem kết quả: `/test-report --last`
- Tạo kiểm thử mẫu: `/scaffold-test mobile`
