---
name: monitor
version: 1.0.0
description: Hiển thị bảng điều khiển trạng thái hệ thống gồm Appium server, thiết bị kết nối, thông tin môi trường và kết quả kiểm thử gần nhất. Dùng để xem tổng quan nhanh về cấu hình kiểm thử.
allowed-tools: Bash(adb *), Bash(curl *), Bash(node *), Bash(java *), Bash(appium *), Bash(k6 *), Bash(npx *), Bash(lsof *), Bash(netstat *), Bash(ls *), Bash(cat *), Bash(df *), Bash(ps *), Bash(tasklist *), Read, Grep, Glob
user-invocable: true
---

# Bảng điều khiển giám sát kiểm thử tự động

Hiển thị tổng quan trạng thái toàn diện của môi trường kiểm thử.

## Ảnh chụp trạng thái nhanh

Appium: !`node -e "const http=require('http');const r=http.get('http://localhost:4723/status',res=>{let d='';res.on('data',c=>d+=c);res.on('end',()=>{try{const j=JSON.parse(d);console.log('đang chạy v'+j.value.build.version)}catch{console.log('không chạy')}})});r.on('error',()=>console.log('không chạy'));r.setTimeout(3000,()=>{r.destroy();console.log('không chạy')})"`
Thiết bị: !`node -e "const {execSync}=require('child_process');try{const r=execSync('adb devices',{encoding:'utf8',timeout:5000});const lines=r.trim().split('\\n').filter(l=>l.includes('\\tdevice'));console.log(lines.length)}catch{console.log('0')}"` đã kết nối
Kết quả gần nhất: !`node -e "const fs=require('fs');const dirs=['test-results','playwright-report','reports'];let found=false;for(const d of dirs){try{const files=fs.readdirSync(d);if(files.length){console.log(d+'/'+files[0]);found=true;break}}catch{}}if(!found)console.log('không tìm thấy')"`

## Các bước

Chạy TẤT CẢ các kiểm tra bên dưới và tổng hợp kết quả vào một bảng điều khiển. Chạy theo nhóm logic.

### 1. Trạng thái dịch vụ

**Appium Server:**
```bash
curl -s http://localhost:4723/status 2>/dev/null
```
Báo cáo: đang chạy (kèm phiên bản) hoặc đã dừng.

**ADB Server:**
```bash
adb version 2>/dev/null
```
Báo cáo: đang chạy hoặc không tìm thấy.

### 2. Thiết bị kết nối

```bash
adb devices -l 2>/dev/null
```
Cho mỗi thiết bị, lấy model:
```bash
adb -s <id> shell getprop ro.product.model 2>/dev/null
```

### 3. Phiên bản môi trường

Kiểm tra tất cả công cụ (chạy hết, không dừng khi gặp lỗi):
```bash
node --version 2>/dev/null
java --version 2>&1
appium --version 2>/dev/null
npx playwright --version 2>/dev/null
k6 version 2>/dev/null
```

> **Lưu ý Windows:** Lệnh `java --version 2>&1 | head -1` sử dụng `head` (Unix). Trên Windows thuần CMD, dùng `java --version 2>&1` rồi lấy dòng đầu từ kết quả. Git Bash hỗ trợ `head`.

### 4. Kết quả kiểm thử gần nhất

Tìm file kết quả kiểm thử mới nhất:

**Tương thích đa nền tảng (dùng Node.js):**
```bash
node -e "const fs=require('fs');const path=require('path');const dirs=['test-results','playwright-report','reports'];for(const d of dirs){try{const files=fs.readdirSync(d).map(f=>({name:f,time:fs.statSync(path.join(d,f)).mtime})).sort((a,b)=>b.time-a.time).slice(0,5);files.forEach(f=>console.log(d+'/'+f.name+' - '+f.time.toLocaleString()))}catch{}}"
```
Nếu tìm thấy, đọc file mới nhất và trích xuất tổng kết (số đạt/lỗi).

### 5. Hiển thị bảng điều khiển

Tổng hợp tất cả vào bảng điều khiển có định dạng:

```
═══════════════════════════════════════════════════════
          TEST AUTOMATION MONITOR
═══════════════════════════════════════════════════════

SERVICES
  Appium Server    ✓ running  (v2.5.1, port 4723)
  ADB Server       ✓ running  (v34.0.5)

DEVICES
  emulator-5554    ✓ online   Pixel 7 (Android 14)
  R5CT32XXXXX      ✓ online   Galaxy S23 (Android 13)
  (2 devices connected)

ENVIRONMENT
  Node.js          ✓ v20.11.0
  Java             ✓ 17.0.2
  Appium           ✓ 2.5.1
  Playwright       ✓ 1.42.0
  k6               ✓ 0.49.0

LAST TEST RUN
  Suite:     smoke-tests
  Status:    PASSED (12/12 tests)
  Duration:  45.2s
  Time:      5 minutes ago

═══════════════════════════════════════════════════════
Quick Actions:
  /run-test          Run web tests
  /mobile-test       Run mobile tests
  /devices           Manage devices
  /appium start      Start Appium server
  /test-report       View detailed report
═══════════════════════════════════════════════════════
```

### 6. Cảnh báo

Hiển thị cảnh báo cho các vấn đề phát hiện được:
- Appium không chạy: "⚠ Appium chưa chạy. Dùng `/appium start`"
- Không có thiết bị: "⚠ Không có thiết bị nào kết nối. Kết nối thiết bị hoặc khởi động trình giả lập."
- Thiếu công cụ: "⚠ Không tìm thấy <tool>. Chạy `/setup-test-env`"
- Không có kết quả kiểm thử: "⚠ Không tìm thấy kết quả kiểm thử. Chạy `/run-test` để bắt đầu."

## Xử lý lỗi

- Nếu bất kỳ lệnh kiểm tra nào thất bại hoặc timeout: đánh dấu mục đó là "không xác định" và tiếp tục kiểm tra khác.
- Nếu ADB chưa cài: bỏ qua phần thiết bị, hiện cảnh báo.
- Nếu thư mục kết quả kiểm thử không tồn tại: hiện "Chưa có kiểm thử nào được chạy" thay vì lỗi.
- Chạy tất cả kiểm tra bất kể lỗi cá nhân - không bao giờ dừng sớm.

## Kỹ năng liên quan

Tất cả kỹ năng khả dụng được hiển thị trong phần Thao tác nhanh của bảng điều khiển.
