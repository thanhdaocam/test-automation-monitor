---
name: devices
version: 1.0.0
description: Liệt kê tất cả thiết bị Android và iOS đã kết nối cùng trình giả lập. Hiển thị ID thiết bị, model, phiên bản OS và trạng thái kết nối. Dùng để xem thiết bị nào khả dụng cho kiểm thử di động.
allowed-tools: Bash(adb *), Bash(idevice_id *), Bash(ideviceinfo *), Bash(xcrun *), Bash(node *)
user-invocable: true
---

# Liệt kê thiết bị kết nối

Phát hiện và hiển thị tất cả thiết bị/trình giả lập Android và iOS đã kết nối.

## Trạng thái thiết bị hiện tại

!`adb devices -l 2>/dev/null || echo "ADB không khả dụng"`

## Các bước

1. **Kiểm tra ADB có sẵn**:
   ```bash
   adb version 2>/dev/null
   ```
   Nếu không tìm thấy, báo người dùng: "Không tìm thấy ADB. Chạy `/setup-test-env` để cài đặt tiền điều kiện."

2. **Khởi động ADB server** (nếu chưa chạy):
   ```bash
   adb start-server 2>/dev/null
   ```

3. **Liệt kê thiết bị Android**:
   ```bash
   adb devices -l
   ```
   Cho mỗi thiết bị tìm thấy, lấy thông tin chi tiết:
   ```bash
   adb -s <device_id> shell getprop ro.product.model
   adb -s <device_id> shell getprop ro.build.version.release
   adb -s <device_id> shell getprop ro.product.brand
   ```

4. **Liệt kê thiết bị iOS** (chỉ trên macOS, bỏ qua trên Windows/Linux mà không báo lỗi):
   ```bash
   idevice_id -l 2>/dev/null
   ```
   Nếu tìm thấy, lấy thông tin chi tiết:
   ```bash
   ideviceinfo -u <udid> -k DeviceName 2>/dev/null
   ideviceinfo -u <udid> -k ProductVersion 2>/dev/null
   ideviceinfo -u <udid> -k ProductType 2>/dev/null
   ```

5. **Kiểm tra trình giả lập iOS** (chỉ macOS, bỏ qua trên Windows):
   ```bash
   xcrun simctl list devices available 2>/dev/null
   ```
   Lọc kết quả hiển thị trạng thái "Booted" hoặc "Shutdown" từ đầu ra.

   > **Lưu ý Windows:** Các lệnh iOS (`idevice_id`, `xcrun simctl`) không khả dụng trên Windows. Bỏ qua phần iOS mà không báo lỗi.

6. **Hiển thị kết quả** dưới dạng bảng có định dạng:
   ```
   Thiết bị kết nối
   ══════════════════════════════════════════════════════════════
   #  ID thiết bị       Nền tảng    Model         OS       Trạng thái
   ──────────────────────────────────────────────────────────────
   1  emulator-5554     Android     Pixel 7       14       trực tuyến
   2  R5CT32XXXXX       Android     Galaxy S23    13       trực tuyến
   3  00008101-XXXX     iOS         iPhone 15     17.4     trực tuyến
   ══════════════════════════════════════════════════════════════
   Tổng cộng: 3 thiết bị (3 trực tuyến, 0 ngoại tuyến)
   ```

7. **Nếu không tìm thấy thiết bị**, cung cấp hướng dẫn:
   - Android: "Kết nối thiết bị qua USB với USB Debugging đã bật, hoặc khởi động trình giả lập từ Android Studio."
   - iOS: "Kết nối iPhone qua USB và tin cậy máy tính, hoặc khởi động simulator với `xcrun simctl boot <device>`."

8. **Mẹo**: Gợi ý người dùng có thể chỉ định thiết bị cụ thể với `/mobile-test --device <id>` hoặc `/install-apk <apk> <device_id>`.

## Xử lý lỗi

- Nếu không tìm thấy `adb`: gợi ý chạy `/setup-test-env` trước.
- Nếu `adb devices` trả về "daemon not running": ADB sẽ tự khởi động, đợi và thử lại.
- Nếu thiết bị hiện "unauthorized": báo người dùng kiểm tra thông báo USB debugging trên màn hình thiết bị.
- Nếu thiết bị hiện "offline": gợi ý `adb kill-server && adb start-server`.

## Kỹ năng liên quan

- Cài đặt ứng dụng: `/install-apk <path.apk> <device_id>`
- Chạy kiểm thử di động: `/mobile-test <file> --device <device_id>`
- Khởi động Appium: `/appium start`
