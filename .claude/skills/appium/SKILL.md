---
name: appium
version: 1.0.0
description: Khởi động, dừng hoặc kiểm tra trạng thái Appium 2.0 server cho kiểm thử di động. Lệnh phụ - start, stop, status, install-drivers. Sử dụng trước khi chạy kiểm thử di động.
allowed-tools: Bash(appium *), Bash(curl *), Bash(lsof *), Bash(netstat *), Bash(tasklist *), Bash(taskkill *), Bash(kill *), Bash(npm *), Bash(npx *), Bash(node *), Bash(mkdir *)
user-invocable: true
argument-hint: [start|stop|status|install-drivers] [--port 4723]
disable-model-invocation: true
---

# Quản lý Appium Server

Điều khiển Appium 2.0 server cho kiểm thử tự động trên thiết bị di động.

## Xác định đường dẫn tạm (Cross-platform)

Trước khi thực hiện bất kỳ lệnh nào cần ghi log, hãy xác định đường dẫn tạm phù hợp với hệ điều hành:

```bash
node -e "const os=require('os');const path=require('path');const tmpDir=os.tmpdir();console.log(path.join(tmpDir,'appium.log'))"
```

Lưu kết quả vào biến `APPIUM_LOG_PATH` để sử dụng trong các lệnh bên dưới. Ví dụ:
- **Windows:** `C:\Users\<user>\AppData\Local\Temp\appium.log`
- **macOS:** `/var/folders/.../appium.log` hoặc `/tmp/appium.log`
- **Linux:** `/tmp/appium.log`

## Phân tích tham số

- `$0` = lệnh phụ: `start`, `stop`, `status`, hoặc `install-drivers`. Mặc định là `status` nếu không chỉ định.
- `--port <number>` = cổng sử dụng. Mặc định: `4723`.

## Các lệnh phụ

### `status` (mặc định)

Kiểm tra Appium server có đang chạy không:

**Trên Windows:**
```bash
netstat -ano | findstr :<port>
```
Nếu không có kết quả, server chưa chạy.

**Trên macOS/Linux:**
```bash
lsof -i :<port> 2>/dev/null || echo "KHÔNG_CHẠY"
```

**Kiểm tra sức khỏe (Health check) — mọi nền tảng:**
```bash
curl -s http://localhost:<port>/status 2>/dev/null
```

Hiển thị kết quả:
- Nếu đang chạy: "Appium server đang **chạy** trên cổng <port>" + hiển thị phiên bản từ kết quả health check
- Nếu không chạy: "Appium server **không chạy**. Sử dụng `/appium start` để khởi động."

Kiểm tra driver đã cài đặt:
```bash
appium driver list --installed 2>/dev/null
```

### `start`

1. Kiểm tra server đã chạy chưa (giống kiểm tra `status`). Nếu đang chạy, báo "Đã chạy trên cổng <port>" và dừng.

2. Kiểm tra Appium đã cài đặt:
   ```bash
   appium --version
   ```
   Nếu không tìm thấy: "Appium chưa được cài đặt. Chạy `/appium install-drivers` hoặc `npm install -g appium`."

3. Xác định đường dẫn log tạm:
   ```bash
   node -e "const os=require('os');const path=require('path');console.log(path.join(os.tmpdir(),'appium.log'))"
   ```

4. Tạo thư mục tạm nếu chưa tồn tại, rồi khởi động Appium server trong nền:

   **Trên Windows (CMD/Git Bash):**
   ```bash
   node -e "const os=require('os');const path=require('path');const {execSync}=require('child_process');const logPath=path.join(os.tmpdir(),'appium.log');const {spawn}=require('child_process');const child=spawn('appium',['server','--port','<port>','--allow-cors'],{detached:true,stdio:['ignore',require('fs').openSync(logPath,'w'),require('fs').openSync(logPath,'a')]});child.unref();console.log('PID:'+child.pid+' LOG:'+logPath)"
   ```

   **Trên macOS/Linux:**
   ```bash
   APPIUM_LOG=$(node -e "console.log(require('path').join(require('os').tmpdir(),'appium.log'))") && nohup appium server --port <port> --allow-cors > "$APPIUM_LOG" 2>&1 &
   ```

5. Đợi 3 giây, sau đó xác minh server đã khởi động:
   ```bash
   sleep 3 && curl -s http://localhost:<port>/status
   ```

6. Báo cáo kết quả:
   - Thành công: "Appium server đã khởi động trên cổng <port>. Log tại: <APPIUM_LOG_PATH>"
   - Thất bại: Hiển thị 20 dòng cuối của file log để gỡ lỗi:
     **Trên Windows:**
     ```bash
     node -e "const fs=require('fs');const p=require('path').join(require('os').tmpdir(),'appium.log');try{const lines=fs.readFileSync(p,'utf8').split('\n').slice(-20);console.log(lines.join('\n'))}catch(e){console.log('Không đọc được log: '+e.message)}"
     ```
     **Trên macOS/Linux:**
     ```bash
     tail -20 "$(node -e "console.log(require('path').join(require('os').tmpdir(),'appium.log'))")"
     ```

### `stop`

1. Tìm tiến trình Appium:

   **Trên Windows:**
   ```bash
   netstat -ano | findstr :<port>
   ```
   Trích xuất PID từ cột cuối cùng, sau đó:
   ```bash
   taskkill /PID <pid> /F
   ```

   **Trên macOS/Linux:**
   ```bash
   lsof -t -i :<port>
   ```
   Sau đó:
   ```bash
   kill -9 $(lsof -t -i :<port>)
   ```

2. Xác minh đã dừng:
   ```bash
   curl -s http://localhost:<port>/status 2>/dev/null
   ```

3. Báo cáo: "Appium server đã dừng." hoặc "Không có Appium server nào đang chạy trên cổng <port>."

### `install-drivers`

1. Kiểm tra Appium đã cài đặt:
   ```bash
   appium --version
   ```
   Nếu chưa: cài đặt trước với `npm install -g appium`.

2. Liệt kê driver hiện tại:
   ```bash
   appium driver list --installed
   ```

3. Cài đặt driver còn thiếu:
   ```bash
   appium driver install uiautomator2 2>/dev/null || echo "uiautomator2 đã được cài đặt"
   appium driver install xcuitest 2>/dev/null || echo "xcuitest đã được cài đặt hoặc không chạy trên macOS"
   ```

4. Xác minh:
   ```bash
   appium driver list --installed
   ```

5. Báo cáo danh sách driver đã cài đặt kèm phiên bản.

## Xử lý lỗi

- Nếu không tìm thấy `appium`: gợi ý `npm install -g appium` hoặc chạy `/setup-test-env`.
- Nếu cổng đã bị chiếm bởi tiến trình khác: cảnh báo người dùng và gợi ý cổng khác với `--port`.
- Nếu Appium không khởi động được: hiển thị 20 dòng cuối file log để chẩn đoán.
  - **Windows:** dùng `node -e` để đọc file log từ `os.tmpdir()`
  - **macOS/Linux:** dùng `tail -20` trên file log
- Nếu `curl` không có trên Windows: sử dụng `node -e "const http=require('http');http.get('http://localhost:<port>/status',r=>{let d='';r.on('data',c=>d+=c);r.on('end',()=>console.log(d))}).on('error',e=>console.log('Không kết nối được'))"` để kiểm tra thay thế.
- **Windows:** luôn dùng `netstat -ano | findstr :<port>` và `taskkill /PID <pid> /F` thay vì `lsof`/`kill`.
- **macOS/Linux:** dùng `lsof -i :<port>` và `kill -9 <pid>`.

## Kỹ năng liên quan

- Kiểm tra thiết bị sau khi khởi động: `/devices`
- Chạy kiểm thử di động: `/mobile-test <file>`
- Kiểm tra toàn bộ môi trường: `/setup-test-env`
