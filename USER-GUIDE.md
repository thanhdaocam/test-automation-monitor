# User Guide - Hướng dẫn chi tiết Test Automation Monitor

> Tài liệu này hướng dẫn **từng bước** cách dùng bộ skills để test các chức năng cụ thể.
> Mỗi chức năng đều có ví dụ thực tế, lệnh cần chạy, và kết quả mong đợi.

---

## Mục lục

1. [Chuẩn bị môi trường](#1-chuẩn-bị-môi-trường)
2. [Test chức năng Web - Login/Register](#2-test-chức-năng-web---loginregister)
3. [Test chức năng Web - Form nhập liệu & Validation](#3-test-chức-năng-web---form-nhập-liệu--validation)
4. [Test chức năng Web - Navigation & Routing](#4-test-chức-năng-web---navigation--routing)
5. [Test chức năng Web - Search & Filter](#5-test-chức-năng-web---search--filter)
6. [Test chức năng Web - CRUD (Tạo/Đọc/Sửa/Xóa)](#6-test-chức-năng-web---crud-tạođọcsửaxóa)
7. [Test chức năng Web - Upload File](#7-test-chức-năng-web---upload-file)
8. [Test chức năng Web - Responsive & Multi-browser](#8-test-chức-năng-web---responsive--multi-browser)
9. [Test chức năng Mobile - Cài đặt & Mở app](#9-test-chức-năng-mobile---cài-đặt--mở-app)
10. [Test chức năng Mobile - Login trên app](#10-test-chức-năng-mobile---login-trên-app)
11. [Test chức năng Mobile - Navigation trong app](#11-test-chức-năng-mobile---navigation-trong-app)
12. [Test chức năng Mobile - Form trên app](#12-test-chức-năng-mobile---form-trên-app)
13. [Test chức năng Mobile - WebView bên trong app](#13-test-chức-năng-mobile---webview-bên-trong-app)
14. [Test chức năng Mobile - Push Notification](#14-test-chức-năng-mobile---push-notification)
15. [Test chức năng Mobile - Gesture (Swipe, Scroll, Pinch)](#15-test-chức-năng-mobile---gesture-swipe-scroll-pinch)
16. [Test chức năng Mobile - Camera & Permissions](#16-test-chức-năng-mobile---camera--permissions)
17. [Test Performance - Load Testing API](#17-test-performance---load-testing-api)
18. [Test Performance - Stress Testing](#18-test-performance---stress-testing)
19. [Test Performance - Spike Testing](#19-test-performance---spike-testing)
20. [Test End-to-End - Cross-platform Flow](#20-test-end-to-end---cross-platform-flow)
21. [Xem kết quả & Debug lỗi](#21-xem-kết-quả--debug-lỗi)
22. [CI/CD Integration](#22-cicd-integration)

---

## 1. Chuẩn bị môi trường

### Bước 1: Kiểm tra prerequisites

```
> /setup-test-env
```

Skill sẽ kiểm tra từng tool và hiển thị bảng:

```
Tool          Status    Version
──────────────────────────────────
Node.js       ✓         v20.11.0     ← cần >= 20
Java          ✓         17.0.2       ← cần >= 11 (cho Appium)
ADB           ✓         34.0.5       ← cần cho Android testing
Appium        ✓         2.5.1        ← cần cho mobile testing
Playwright    ✓         1.42.0       ← cần cho web testing
k6            ✓         0.49.0       ← cần cho performance testing
```

Nếu thiếu tool nào, skill sẽ hiển thị lệnh cài đặt cụ thể.

### Bước 2: Tạo project test (nếu chưa có)

```
> /scaffold-test all
```

Tạo cấu trúc hoàn chỉnh:
```
tests/
├── web/                    ← Playwright tests
│   ├── login.spec.ts
│   └── dashboard.spec.ts
├── mobile/                 ← WebdriverIO tests
│   ├── app-login.mobile.ts
│   └── webview.mobile.ts
└── performance/            ← k6 scripts
    └── load-test.k6.js
```

Hoặc tạo riêng từng loại:
```
> /scaffold-test web           ← chỉ web tests
> /scaffold-test mobile        ← chỉ mobile tests
> /scaffold-test performance   ← chỉ performance tests
```

### Bước 3: Kết nối device (cho mobile testing)

**Cách 1: Android Emulator**
1. Mở Android Studio → Virtual Device Manager → Start emulator

**Cách 2: Điện thoại thật**
1. Bật Developer Options → USB Debugging → cắm USB

Kiểm tra:
```
> /devices
```

Kết quả:
```
#  Device ID         Platform    Model         OS       Status
1  emulator-5554     Android     Pixel 7       14       online
```

---

## 2. Test chức năng Web - Login/Register

### Mục đích
Kiểm tra flow đăng nhập/đăng ký hoạt động đúng trên web browser.

### Tạo file test

Tạo file `tests/web/auth.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Login', () => {
  test('hiển thị form đăng nhập', async ({ page }) => {
    await page.goto('/login');

    // Kiểm tra các field hiển thị
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('đăng nhập thành công', async ({ page }) => {
    await page.goto('/login');

    // Nhập thông tin
    await page.fill('input[name="email"]', 'admin@example.com');
    await page.fill('input[name="password"]', 'Admin@123');
    await page.click('button[type="submit"]');

    // Kiểm tra chuyển trang sau login
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('.welcome-message')).toContainText('Xin chào');
  });

  test('đăng nhập thất bại - sai mật khẩu', async ({ page }) => {
    await page.goto('/login');

    await page.fill('input[name="email"]', 'admin@example.com');
    await page.fill('input[name="password"]', 'sai_mat_khau');
    await page.click('button[type="submit"]');

    // Kiểm tra thông báo lỗi
    await expect(page.locator('.error-message')).toBeVisible();
    await expect(page.locator('.error-message')).toContainText('Sai email hoặc mật khẩu');

    // Vẫn ở trang login
    await expect(page).toHaveURL('/login');
  });

  test('đăng nhập thất bại - để trống email', async ({ page }) => {
    await page.goto('/login');

    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // Browser validation hoặc custom validation
    await expect(page.locator('input[name="email"]:invalid')).toBeVisible();
  });

  test('chức năng "Remember me"', async ({ page }) => {
    await page.goto('/login');

    await page.fill('input[name="email"]', 'admin@example.com');
    await page.fill('input[name="password"]', 'Admin@123');
    await page.check('input[name="remember"]');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('/dashboard');

    // Mở tab mới, vẫn logged in
    const newPage = await page.context().newPage();
    await newPage.goto('/dashboard');
    await expect(newPage).toHaveURL('/dashboard'); // không redirect về login
  });

  test('chức năng Logout', async ({ page }) => {
    // Login trước
    await page.goto('/login');
    await page.fill('input[name="email"]', 'admin@example.com');
    await page.fill('input[name="password"]', 'Admin@123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');

    // Logout
    await page.click('#logout-button');

    // Redirect về login
    await expect(page).toHaveURL('/login');

    // Không thể vào dashboard nữa
    await page.goto('/dashboard');
    await expect(page).toHaveURL('/login');
  });
});

test.describe('Register', () => {
  test('đăng ký tài khoản mới', async ({ page }) => {
    await page.goto('/register');

    await page.fill('input[name="fullname"]', 'Nguyen Van A');
    await page.fill('input[name="email"]', `test_${Date.now()}@example.com`);
    await page.fill('input[name="password"]', 'StrongPass@123');
    await page.fill('input[name="confirm_password"]', 'StrongPass@123');
    await page.click('button[type="submit"]');

    // Kiểm tra đăng ký thành công
    await expect(page.locator('.success-message')).toBeVisible();
  });

  test('đăng ký thất bại - email đã tồn tại', async ({ page }) => {
    await page.goto('/register');

    await page.fill('input[name="email"]', 'admin@example.com'); // email đã có
    await page.fill('input[name="password"]', 'StrongPass@123');
    await page.fill('input[name="confirm_password"]', 'StrongPass@123');
    await page.click('button[type="submit"]');

    await expect(page.locator('.error-message')).toContainText('Email đã tồn tại');
  });

  test('đăng ký thất bại - password không khớp', async ({ page }) => {
    await page.goto('/register');

    await page.fill('input[name="password"]', 'Password@123');
    await page.fill('input[name="confirm_password"]', 'KhacNhau@456');
    await page.click('button[type="submit"]');

    await expect(page.locator('.error-message')).toContainText('Mật khẩu không khớp');
  });
});
```

### Chạy test

```
> /run-test tests/web/auth.spec.ts
```

Xem với browser mở lên (debug trực quan):
```
> /run-test tests/web/auth.spec.ts --headed
```

Chạy chỉ 1 test cụ thể:
```
> /run-test tests/web/auth.spec.ts --grep "đăng nhập thành công"
```

Debug step-by-step:
```
> /run-test tests/web/auth.spec.ts --debug
```

### Kết quả mong đợi

```
  ✓ hiển thị form đăng nhập                    0.8s
  ✓ đăng nhập thành công                       2.1s
  ✓ đăng nhập thất bại - sai mật khẩu         1.5s
  ✓ đăng nhập thất bại - để trống email        0.6s
  ✓ chức năng "Remember me"                    3.2s
  ✓ chức năng Logout                           2.8s
  ✓ đăng ký tài khoản mới                      2.5s
  ✓ đăng ký thất bại - email đã tồn tại       1.8s
  ✓ đăng ký thất bại - password không khớp     1.2s

Summary: 9 passed, 0 failed | Duration: 16.5s
```

---

## 3. Test chức năng Web - Form nhập liệu & Validation

### Mục đích
Kiểm tra form xử lý đúng dữ liệu đầu vào, validation, error messages.

### Tạo file test

Tạo file `tests/web/form-validation.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Form Validation - Tạo sản phẩm', () => {
  test.beforeEach(async ({ page }) => {
    // Login trước (giả sử cần auth)
    await page.goto('/login');
    await page.fill('input[name="email"]', 'admin@example.com');
    await page.fill('input[name="password"]', 'Admin@123');
    await page.click('button[type="submit"]');
    await page.goto('/products/new');
  });

  test('submit form với đầy đủ dữ liệu hợp lệ', async ({ page }) => {
    await page.fill('input[name="name"]', 'Sản phẩm test ABC');
    await page.fill('input[name="price"]', '150000');
    await page.fill('textarea[name="description"]', 'Mô tả sản phẩm chi tiết');
    await page.selectOption('select[name="category"]', 'electronics');
    await page.check('input[name="in_stock"]');
    await page.click('button[type="submit"]');

    await expect(page.locator('.toast-success')).toContainText('Tạo sản phẩm thành công');
  });

  test('validation - tên sản phẩm trống', async ({ page }) => {
    // Bỏ trống tên
    await page.fill('input[name="price"]', '150000');
    await page.click('button[type="submit"]');

    await expect(page.locator('.field-error[data-field="name"]')).toContainText('Tên là bắt buộc');
  });

  test('validation - giá phải là số dương', async ({ page }) => {
    await page.fill('input[name="name"]', 'Test');
    await page.fill('input[name="price"]', '-5000');
    await page.click('button[type="submit"]');

    await expect(page.locator('.field-error[data-field="price"]')).toContainText('Giá phải lớn hơn 0');
  });

  test('validation - giá nhập chữ', async ({ page }) => {
    await page.fill('input[name="name"]', 'Test');
    await page.fill('input[name="price"]', 'abc');
    await page.click('button[type="submit"]');

    await expect(page.locator('.field-error[data-field="price"]')).toBeVisible();
  });

  test('validation - mô tả quá dài (>1000 ký tự)', async ({ page }) => {
    await page.fill('input[name="name"]', 'Test');
    await page.fill('input[name="price"]', '100000');
    await page.fill('textarea[name="description"]', 'A'.repeat(1001));
    await page.click('button[type="submit"]');

    await expect(page.locator('.field-error[data-field="description"]')).toContainText('tối đa 1000');
  });

  test('validation - email format sai', async ({ page }) => {
    await page.fill('input[name="contact_email"]', 'khong-phai-email');
    await page.click('button[type="submit"]');

    await expect(page.locator('.field-error[data-field="contact_email"]')).toContainText('Email không hợp lệ');
  });

  test('validation - số điện thoại format sai', async ({ page }) => {
    await page.fill('input[name="phone"]', '123');  // quá ngắn
    await page.click('button[type="submit"]');

    await expect(page.locator('.field-error[data-field="phone"]')).toContainText('Số điện thoại không hợp lệ');
  });

  test('validation hiển thị nhiều lỗi cùng lúc', async ({ page }) => {
    // Submit form hoàn toàn trống
    await page.click('button[type="submit"]');

    const errors = page.locator('.field-error');
    await expect(errors).toHaveCount(3);  // ít nhất 3 field bắt buộc
  });

  test('validation - XSS injection', async ({ page }) => {
    await page.fill('input[name="name"]', '<script>alert("xss")</script>');
    await page.fill('input[name="price"]', '100000');
    await page.click('button[type="submit"]');

    // Nếu app xử lý đúng: escape HTML hoặc reject input
    const pageContent = await page.content();
    expect(pageContent).not.toContain('<script>alert');
  });

  test('validation - SQL injection', async ({ page }) => {
    await page.fill('input[name="name"]', "'; DROP TABLE products; --");
    await page.fill('input[name="price"]', '100000');
    await page.click('button[type="submit"]');

    // App phải xử lý đúng, không crash
    await expect(page.locator('body')).not.toContainText('SQL');
    // Trang vẫn hoạt động bình thường
    await page.goto('/products');
    await expect(page.locator('h1')).toBeVisible();
  });
});
```

### Chạy test

```
> /run-test tests/web/form-validation.spec.ts
```

---

## 4. Test chức năng Web - Navigation & Routing

### Tạo file test

Tạo file `tests/web/navigation.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Navigation & Routing', () => {
  test('menu chính hiển thị đúng các mục', async ({ page }) => {
    await page.goto('/');

    await expect(page.locator('nav')).toBeVisible();
    await expect(page.locator('nav a[href="/"]')).toBeVisible();
    await expect(page.locator('nav a[href="/products"]')).toBeVisible();
    await expect(page.locator('nav a[href="/about"]')).toBeVisible();
    await expect(page.locator('nav a[href="/contact"]')).toBeVisible();
  });

  test('click menu chuyển đúng trang', async ({ page }) => {
    await page.goto('/');

    await page.click('nav a[href="/products"]');
    await expect(page).toHaveURL('/products');
    await expect(page.locator('h1')).toContainText('Sản phẩm');

    await page.click('nav a[href="/about"]');
    await expect(page).toHaveURL('/about');
    await expect(page.locator('h1')).toContainText('Giới thiệu');
  });

  test('breadcrumb hiển thị đúng', async ({ page }) => {
    await page.goto('/products/electronics/laptop');

    const breadcrumb = page.locator('.breadcrumb');
    await expect(breadcrumb).toContainText('Trang chủ');
    await expect(breadcrumb).toContainText('Sản phẩm');
    await expect(breadcrumb).toContainText('Electronics');
    await expect(breadcrumb).toContainText('Laptop');
  });

  test('nút Back hoạt động đúng', async ({ page }) => {
    await page.goto('/');
    await page.click('nav a[href="/products"]');
    await expect(page).toHaveURL('/products');

    await page.goBack();
    await expect(page).toHaveURL('/');
  });

  test('404 page cho URL không tồn tại', async ({ page }) => {
    await page.goto('/trang-khong-ton-tai-xyz');

    await expect(page.locator('h1')).toContainText('404');
    await expect(page.locator('a[href="/"]')).toBeVisible(); // link về trang chủ
  });

  test('redirect khi chưa đăng nhập', async ({ page }) => {
    // Truy cập trang cần auth mà chưa login
    await page.goto('/admin/dashboard');

    // Phải redirect về login
    await expect(page).toHaveURL(/\/login/);
  });

  test('deep link hoạt động đúng', async ({ page }) => {
    // Truy cập trực tiếp URL sâu
    await page.goto('/products/123/reviews');

    await expect(page.locator('h1')).not.toContainText('404');
    // Trang phải load đúng nội dung
  });

  test('pagination - chuyển trang', async ({ page }) => {
    await page.goto('/products');

    // Click trang 2
    await page.click('.pagination a[data-page="2"]');
    await expect(page).toHaveURL(/page=2/);

    // Nội dung phải thay đổi
    const firstItem = await page.locator('.product-item:first-child').textContent();
    await page.click('.pagination a[data-page="1"]');
    const firstItemPage1 = await page.locator('.product-item:first-child').textContent();
    expect(firstItem).not.toBe(firstItemPage1);
  });
});
```

### Chạy test

```
> /run-test tests/web/navigation.spec.ts
```

---

## 5. Test chức năng Web - Search & Filter

### Tạo file test

Tạo file `tests/web/search-filter.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Search & Filter', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/products');
  });

  test('tìm kiếm theo từ khóa', async ({ page }) => {
    await page.fill('input[name="search"]', 'laptop');
    await page.click('button.search-btn');

    // Chờ kết quả load
    await page.waitForSelector('.product-list');

    // Tất cả kết quả phải chứa "laptop"
    const items = page.locator('.product-item');
    const count = await items.count();
    expect(count).toBeGreaterThan(0);

    for (let i = 0; i < count; i++) {
      const text = await items.nth(i).textContent();
      expect(text?.toLowerCase()).toContain('laptop');
    }
  });

  test('tìm kiếm không có kết quả', async ({ page }) => {
    await page.fill('input[name="search"]', 'xyzkhongtontai12345');
    await page.click('button.search-btn');

    await expect(page.locator('.no-results')).toBeVisible();
    await expect(page.locator('.no-results')).toContainText('Không tìm thấy');
  });

  test('filter theo danh mục', async ({ page }) => {
    await page.selectOption('select[name="category"]', 'electronics');
    await page.waitForSelector('.product-list');

    const items = page.locator('.product-item .category-badge');
    const count = await items.count();
    for (let i = 0; i < count; i++) {
      await expect(items.nth(i)).toContainText('Electronics');
    }
  });

  test('filter theo khoảng giá', async ({ page }) => {
    await page.fill('input[name="price_min"]', '100000');
    await page.fill('input[name="price_max"]', '500000');
    await page.click('button.apply-filter');

    await page.waitForSelector('.product-list');

    const prices = page.locator('.product-item .price');
    const count = await prices.count();
    for (let i = 0; i < count; i++) {
      const priceText = await prices.nth(i).textContent();
      const price = parseInt(priceText!.replace(/[^\d]/g, ''));
      expect(price).toBeGreaterThanOrEqual(100000);
      expect(price).toBeLessThanOrEqual(500000);
    }
  });

  test('sort theo giá tăng dần', async ({ page }) => {
    await page.selectOption('select[name="sort"]', 'price_asc');
    await page.waitForSelector('.product-list');

    const prices = page.locator('.product-item .price');
    const count = await prices.count();
    const priceValues: number[] = [];

    for (let i = 0; i < count; i++) {
      const text = await prices.nth(i).textContent();
      priceValues.push(parseInt(text!.replace(/[^\d]/g, '')));
    }

    // Verify sorted ascending
    for (let i = 1; i < priceValues.length; i++) {
      expect(priceValues[i]).toBeGreaterThanOrEqual(priceValues[i - 1]);
    }
  });

  test('kết hợp search + filter + sort', async ({ page }) => {
    await page.fill('input[name="search"]', 'phone');
    await page.selectOption('select[name="category"]', 'electronics');
    await page.selectOption('select[name="sort"]', 'price_desc');
    await page.click('button.apply-filter');

    await page.waitForSelector('.product-list');
    const count = await page.locator('.product-item').count();
    expect(count).toBeGreaterThan(0);
  });

  test('clear filter reset về trạng thái ban đầu', async ({ page }) => {
    // Apply filters
    await page.fill('input[name="search"]', 'test');
    await page.selectOption('select[name="category"]', 'electronics');
    await page.click('button.apply-filter');

    // Clear
    await page.click('button.clear-filter');
    await page.waitForSelector('.product-list');

    // Verify reset
    await expect(page.locator('input[name="search"]')).toHaveValue('');
    await expect(page.locator('select[name="category"]')).toHaveValue('');
  });

  test('search realtime (debounce)', async ({ page }) => {
    // Giả sử search có auto-suggest
    await page.fill('input[name="search"]', 'lap');
    await page.waitForTimeout(500); // debounce

    const suggestions = page.locator('.search-suggestions li');
    if (await suggestions.count() > 0) {
      await suggestions.first().click();
      await expect(page.locator('input[name="search"]')).not.toHaveValue('lap');
    }
  });
});
```

### Chạy test

```
> /run-test tests/web/search-filter.spec.ts
```

---

## 6. Test chức năng Web - CRUD (Tạo/Đọc/Sửa/Xóa)

### Tạo file test

Tạo file `tests/web/crud-products.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test.describe('CRUD - Quản lý sản phẩm', () => {
  const uniqueName = `Test Product ${Date.now()}`;

  test.beforeEach(async ({ page }) => {
    // Login as admin
    await page.goto('/login');
    await page.fill('input[name="email"]', 'admin@example.com');
    await page.fill('input[name="password"]', 'Admin@123');
    await page.click('button[type="submit"]');
  });

  test('CREATE - tạo sản phẩm mới', async ({ page }) => {
    await page.goto('/products/new');

    await page.fill('input[name="name"]', uniqueName);
    await page.fill('input[name="price"]', '299000');
    await page.fill('textarea[name="description"]', 'Mô tả sản phẩm test');
    await page.selectOption('select[name="category"]', 'electronics');
    await page.click('button[type="submit"]');

    // Verify tạo thành công
    await expect(page.locator('.toast-success')).toBeVisible();
    // Redirect đến trang chi tiết hoặc danh sách
    await expect(page.locator('.product-name')).toContainText(uniqueName);
  });

  test('READ - xem chi tiết sản phẩm', async ({ page }) => {
    await page.goto('/products');

    // Tìm sản phẩm vừa tạo
    await page.fill('input[name="search"]', uniqueName);
    await page.click('button.search-btn');
    await page.click(`.product-item:has-text("${uniqueName}") a`);

    // Verify thông tin hiển thị đúng
    await expect(page.locator('.product-name')).toContainText(uniqueName);
    await expect(page.locator('.product-price')).toContainText('299,000');
    await expect(page.locator('.product-description')).toContainText('Mô tả sản phẩm test');
  });

  test('UPDATE - sửa sản phẩm', async ({ page }) => {
    await page.goto('/products');

    await page.fill('input[name="search"]', uniqueName);
    await page.click('button.search-btn');
    await page.click(`.product-item:has-text("${uniqueName}") .edit-btn`);

    // Sửa thông tin
    await page.fill('input[name="price"]', '399000');
    await page.fill('textarea[name="description"]', 'Mô tả đã cập nhật');
    await page.click('button[type="submit"]');

    await expect(page.locator('.toast-success')).toContainText('Cập nhật thành công');

    // Verify đã thay đổi
    await expect(page.locator('.product-price')).toContainText('399,000');
  });

  test('DELETE - xóa sản phẩm', async ({ page }) => {
    await page.goto('/products');

    await page.fill('input[name="search"]', uniqueName);
    await page.click('button.search-btn');
    await page.click(`.product-item:has-text("${uniqueName}") .delete-btn`);

    // Confirm dialog
    await page.click('.confirm-dialog .confirm-btn');

    await expect(page.locator('.toast-success')).toContainText('Xóa thành công');

    // Verify đã xóa - tìm lại không thấy
    await page.fill('input[name="search"]', uniqueName);
    await page.click('button.search-btn');
    await expect(page.locator('.no-results')).toBeVisible();
  });

  test('DELETE - hủy xóa', async ({ page }) => {
    await page.goto('/products');

    await page.click('.product-item:first-child .delete-btn');

    // Click Cancel
    await page.click('.confirm-dialog .cancel-btn');

    // Sản phẩm vẫn còn
    const countBefore = await page.locator('.product-item').count();
    expect(countBefore).toBeGreaterThan(0);
  });
});
```

### Chạy test

```
> /run-test tests/web/crud-products.spec.ts
```

---

## 7. Test chức năng Web - Upload File

### Tạo file test

Tạo file `tests/web/upload.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';
import path from 'path';

test.describe('Upload File', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/upload');
  });

  test('upload ảnh thành công', async ({ page }) => {
    // Chọn file
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles(path.join(__dirname, 'fixtures', 'test-image.jpg'));

    // Verify preview hiển thị
    await expect(page.locator('.preview-image')).toBeVisible();

    // Submit upload
    await page.click('button.upload-btn');

    await expect(page.locator('.upload-success')).toBeVisible();
    await expect(page.locator('.uploaded-file-name')).toContainText('test-image.jpg');
  });

  test('reject file quá lớn (>5MB)', async ({ page }) => {
    const fileInput = page.locator('input[type="file"]');
    // Tạo buffer lớn giả lập file 6MB
    await fileInput.setInputFiles({
      name: 'large-file.jpg',
      mimeType: 'image/jpeg',
      buffer: Buffer.alloc(6 * 1024 * 1024),
    });

    await expect(page.locator('.file-error')).toContainText('File quá lớn');
  });

  test('reject file type không hợp lệ', async ({ page }) => {
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles({
      name: 'malware.exe',
      mimeType: 'application/x-msdownload',
      buffer: Buffer.alloc(1024),
    });

    await expect(page.locator('.file-error')).toContainText('Loại file không được hỗ trợ');
  });

  test('upload nhiều file cùng lúc', async ({ page }) => {
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles([
      path.join(__dirname, 'fixtures', 'image1.jpg'),
      path.join(__dirname, 'fixtures', 'image2.png'),
    ]);

    await page.click('button.upload-btn');

    const uploadedFiles = page.locator('.uploaded-file-name');
    await expect(uploadedFiles).toHaveCount(2);
  });

  test('drag and drop upload', async ({ page }) => {
    // Simulate drag-and-drop
    const dropZone = page.locator('.drop-zone');
    const dataTransfer = await page.evaluateHandle(() => new DataTransfer());

    await dropZone.dispatchEvent('dragenter', { dataTransfer });
    await dropZone.dispatchEvent('drop', { dataTransfer });

    // Verify drop zone reacts
    await expect(dropZone).toHaveClass(/drag-active/);
  });
});
```

### Chạy test

```
> /run-test tests/web/upload.spec.ts
```

---

## 8. Test chức năng Web - Responsive & Multi-browser

### Mục đích
Kiểm tra giao diện hiển thị đúng trên các kích thước màn hình và browsers khác nhau.

### Tạo file test

Tạo file `tests/web/responsive.spec.ts`:

```typescript
import { test, expect, devices } from '@playwright/test';

// Test trên Mobile viewport
test.describe('Responsive - Mobile', () => {
  test.use({ viewport: { width: 375, height: 812 } }); // iPhone X size

  test('menu hamburger hiển thị trên mobile', async ({ page }) => {
    await page.goto('/');

    // Desktop menu ẩn
    await expect(page.locator('nav.desktop-menu')).not.toBeVisible();

    // Hamburger button hiển thị
    await expect(page.locator('button.hamburger')).toBeVisible();

    // Click hamburger → menu mở
    await page.click('button.hamburger');
    await expect(page.locator('nav.mobile-menu')).toBeVisible();
  });

  test('layout 1 cột trên mobile', async ({ page }) => {
    await page.goto('/products');

    const productGrid = page.locator('.product-grid');
    const gridStyle = await productGrid.evaluate(el =>
      window.getComputedStyle(el).gridTemplateColumns
    );

    // Mobile: 1 cột
    expect(gridStyle).toMatch(/^[0-9.]+px$/); // single column
  });

  test('table scroll ngang trên mobile', async ({ page }) => {
    await page.goto('/admin/users');

    const tableContainer = page.locator('.table-container');
    const isScrollable = await tableContainer.evaluate(el =>
      el.scrollWidth > el.clientWidth
    );

    // Table phải scrollable ngang trên mobile
    expect(isScrollable).toBe(true);
  });
});

// Test trên Tablet viewport
test.describe('Responsive - Tablet', () => {
  test.use({ viewport: { width: 768, height: 1024 } }); // iPad size

  test('layout 2 cột trên tablet', async ({ page }) => {
    await page.goto('/products');

    const productGrid = page.locator('.product-grid');
    const gridStyle = await productGrid.evaluate(el =>
      window.getComputedStyle(el).gridTemplateColumns
    );

    // Tablet: 2 cột
    const columns = gridStyle.split(' ').length;
    expect(columns).toBe(2);
  });
});

// Test trên Desktop viewport
test.describe('Responsive - Desktop', () => {
  test.use({ viewport: { width: 1920, height: 1080 } });

  test('layout đầy đủ trên desktop', async ({ page }) => {
    await page.goto('/');

    await expect(page.locator('nav.desktop-menu')).toBeVisible();
    await expect(page.locator('button.hamburger')).not.toBeVisible();
    await expect(page.locator('.sidebar')).toBeVisible();
  });
});
```

### Chạy test multi-browser

Playwright tự động chạy trên nhiều browser theo `playwright.config.ts`:

```
> /run-test tests/web/responsive.spec.ts
```

Chạy chỉ trên 1 browser:
```
> /run-test tests/web/responsive.spec.ts --project=chromium
> /run-test tests/web/responsive.spec.ts --project=firefox
> /run-test tests/web/responsive.spec.ts --project=webkit
> /run-test tests/web/responsive.spec.ts --project=mobile-chrome
```

---

## 9. Test chức năng Mobile - Cài đặt & Mở app

### Mục đích
Kiểm tra APK cài đặt và mở được trên Android device.

### Bước 1: Kiểm tra device

```
> /devices
```

### Bước 2: Cài APK

```
> /install-apk ./app/app-debug.apk
```

Nếu có nhiều device:
```
> /install-apk ./app/app-debug.apk emulator-5554
```

### Bước 3: Tạo test mở app

Tạo file `tests/mobile/app-launch.mobile.ts`:

```typescript
describe('App Launch', () => {
  it('app mở và hiển thị splash screen', async () => {
    // App tự động mở bởi Appium (cấu hình trong wdio.conf.ts)

    // Chờ splash screen
    const splash = await $('~splashScreen');
    await splash.waitForDisplayed({ timeout: 10000 });
  });

  it('splash screen biến mất sau 2-3 giây', async () => {
    const splash = await $('~splashScreen');
    await splash.waitForDisplayed({ timeout: 10000 });

    // Chờ splash biến mất
    await splash.waitForDisplayed({ timeout: 5000, reverse: true });
  });

  it('màn hình chính hiển thị sau splash', async () => {
    // Chờ màn hình chính load
    const mainScreen = await $('~mainScreen');
    await mainScreen.waitForDisplayed({ timeout: 15000 });

    // Verify các element chính
    const header = await $('~appHeader');
    expect(await header.isDisplayed()).toBe(true);
  });

  it('app không crash khi xoay màn hình', async () => {
    // Landscape
    await driver.setOrientation('LANDSCAPE');
    await driver.pause(1000);

    const mainScreen = await $('~mainScreen');
    expect(await mainScreen.isDisplayed()).toBe(true);

    // Portrait lại
    await driver.setOrientation('PORTRAIT');
    await driver.pause(1000);

    expect(await mainScreen.isDisplayed()).toBe(true);
  });

  it('app hoạt động sau khi minimize và mở lại', async () => {
    // Đưa app xuống background
    await driver.background(3); // 3 giây

    // App tự quay lại foreground
    const mainScreen = await $('~mainScreen');
    await mainScreen.waitForDisplayed({ timeout: 10000 });
    expect(await mainScreen.isDisplayed()).toBe(true);
  });
});
```

### Chạy test

```
> /appium start
> /mobile-test tests/mobile/app-launch.mobile.ts
```

---

## 10. Test chức năng Mobile - Login trên app

### Tạo file test

Tạo file `tests/mobile/app-auth.mobile.ts`:

```typescript
describe('Mobile App - Login', () => {
  it('hiển thị form đăng nhập', async () => {
    const emailInput = await $('~emailInput');
    const passwordInput = await $('~passwordInput');
    const loginButton = await $('~loginButton');

    expect(await emailInput.isDisplayed()).toBe(true);
    expect(await passwordInput.isDisplayed()).toBe(true);
    expect(await loginButton.isDisplayed()).toBe(true);
  });

  it('đăng nhập thành công', async () => {
    const emailInput = await $('~emailInput');
    const passwordInput = await $('~passwordInput');
    const loginButton = await $('~loginButton');

    await emailInput.setValue('user@example.com');
    await passwordInput.setValue('password123');
    await loginButton.click();

    // Chờ dashboard load
    const dashboard = await $('~dashboardScreen');
    await dashboard.waitForDisplayed({ timeout: 10000 });

    expect(await dashboard.isDisplayed()).toBe(true);
  });

  it('đăng nhập thất bại - sai mật khẩu', async () => {
    const emailInput = await $('~emailInput');
    const passwordInput = await $('~passwordInput');
    const loginButton = await $('~loginButton');

    await emailInput.setValue('user@example.com');
    await passwordInput.setValue('wrong_password');
    await loginButton.click();

    // Kiểm tra error message
    const errorMsg = await $('~errorMessage');
    await errorMsg.waitForDisplayed({ timeout: 5000 });
    expect(await errorMsg.getText()).toContain('Sai');
  });

  it('hiển thị/ẩn mật khẩu', async () => {
    const passwordInput = await $('~passwordInput');
    const togglePassword = await $('~togglePassword');

    await passwordInput.setValue('mypassword');

    // Mặc định: ẩn (type=password)
    const typeBefore = await passwordInput.getAttribute('password');

    // Click toggle
    await togglePassword.click();

    // Giờ phải hiển thị
    const typeAfter = await passwordInput.getAttribute('password');
    expect(typeBefore).not.toBe(typeAfter);
  });

  it('bàn phím ẩn khi tap ngoài input', async () => {
    const emailInput = await $('~emailInput');
    await emailInput.click(); // mở keyboard

    // Tap vùng trống
    const screenSize = await driver.getWindowRect();
    await driver.touchAction({
      action: 'tap',
      x: screenSize.width / 2,
      y: screenSize.height - 50,
    });

    // Keyboard phải ẩn (app vẫn hiển thị đúng)
    expect(await emailInput.isDisplayed()).toBe(true);
  });

  it('login bằng biometric (nếu hỗ trợ)', async () => {
    const biometricButton = await $('~biometricLogin');

    if (await biometricButton.isExisting()) {
      await biometricButton.click();

      // Trên emulator: simulate fingerprint
      await driver.fingerPrint(1); // finger ID 1

      const dashboard = await $('~dashboardScreen');
      await dashboard.waitForDisplayed({ timeout: 10000 });
    }
  });
});
```

### Chạy test

```
> /mobile-test tests/mobile/app-auth.mobile.ts
```

Trên device cụ thể:
```
> /mobile-test tests/mobile/app-auth.mobile.ts --device emulator-5554
```

---

## 11. Test chức năng Mobile - Navigation trong app

### Tạo file test

Tạo file `tests/mobile/app-navigation.mobile.ts`:

```typescript
describe('Mobile App - Navigation', () => {
  // Login trước khi test
  before(async () => {
    const emailInput = await $('~emailInput');
    await emailInput.setValue('user@example.com');
    const passwordInput = await $('~passwordInput');
    await passwordInput.setValue('password123');
    const loginButton = await $('~loginButton');
    await loginButton.click();
    const dashboard = await $('~dashboardScreen');
    await dashboard.waitForDisplayed({ timeout: 10000 });
  });

  it('bottom tab navigation hoạt động', async () => {
    // Tab Home
    const homeTab = await $('~tabHome');
    await homeTab.click();
    expect(await $('~homeScreen').isDisplayed()).toBe(true);

    // Tab Search
    const searchTab = await $('~tabSearch');
    await searchTab.click();
    expect(await $('~searchScreen').isDisplayed()).toBe(true);

    // Tab Profile
    const profileTab = await $('~tabProfile');
    await profileTab.click();
    expect(await $('~profileScreen').isDisplayed()).toBe(true);
  });

  it('pull-to-refresh hoạt động', async () => {
    const homeTab = await $('~tabHome');
    await homeTab.click();

    // Pull down to refresh
    const listView = await $('~contentList');
    await driver.touchAction([
      { action: 'press', element: listView, x: 0, y: 100 },
      { action: 'wait', ms: 500 },
      { action: 'moveTo', element: listView, x: 0, y: 500 },
      { action: 'release' },
    ]);

    // Chờ refresh indicator
    await driver.pause(2000);

    // Content vẫn hiển thị
    expect(await listView.isDisplayed()).toBe(true);
  });

  it('nút Back quay về màn hình trước', async () => {
    // Vào chi tiết
    const firstItem = await $('~listItem_0');
    await firstItem.click();
    expect(await $('~detailScreen').isDisplayed()).toBe(true);

    // Nhấn Back
    await driver.back();
    expect(await $('~homeScreen').isDisplayed()).toBe(true);
  });

  it('drawer menu (menu trượt) hoạt động', async () => {
    const menuButton = await $('~menuButton');

    if (await menuButton.isExisting()) {
      await menuButton.click();

      const drawer = await $('~drawerMenu');
      await drawer.waitForDisplayed({ timeout: 3000 });
      expect(await drawer.isDisplayed()).toBe(true);

      // Click menu item
      const settingsItem = await $('~menuSettings');
      await settingsItem.click();
      expect(await $('~settingsScreen').isDisplayed()).toBe(true);
    }
  });
});
```

### Chạy test

```
> /mobile-test tests/mobile/app-navigation.mobile.ts
```

---

## 12. Test chức năng Mobile - Form trên app

### Tạo file test

Tạo file `tests/mobile/app-form.mobile.ts`:

```typescript
describe('Mobile App - Form', () => {
  before(async () => {
    // Navigate đến form screen
    const formTab = await $('~tabForm');
    await formTab.click();
  });

  it('hiển thị tất cả fields', async () => {
    expect(await $('~inputName').isDisplayed()).toBe(true);
    expect(await $('~inputEmail').isDisplayed()).toBe(true);
    expect(await $('~inputPhone').isDisplayed()).toBe(true);
    expect(await $('~submitButton').isDisplayed()).toBe(true);
  });

  it('nhập dữ liệu và submit thành công', async () => {
    await $('~inputName').setValue('Nguyen Van A');
    await $('~inputEmail').setValue('test@example.com');
    await $('~inputPhone').setValue('0901234567');

    // Scroll xuống nếu cần
    await $('~submitButton').scrollIntoView();
    await $('~submitButton').click();

    const successMsg = await $('~successMessage');
    await successMsg.waitForDisplayed({ timeout: 5000 });
    expect(await successMsg.getText()).toContain('Thành công');
  });

  it('validation trên mobile - field bắt buộc', async () => {
    // Clear fields
    await $('~inputName').clearValue();
    await $('~inputEmail').clearValue();

    await $('~submitButton').scrollIntoView();
    await $('~submitButton').click();

    const errorName = await $('~errorName');
    await errorName.waitForDisplayed({ timeout: 3000 });
    expect(await errorName.getText()).toContain('bắt buộc');
  });

  it('picker/dropdown chọn giá trị', async () => {
    const categoryPicker = await $('~categoryPicker');
    await categoryPicker.click();

    // Chọn option từ native picker
    const option = await $('~pickerOption_electronics');
    await option.click();

    // Verify đã chọn
    expect(await categoryPicker.getText()).toContain('Electronics');
  });

  it('date picker chọn ngày', async () => {
    const datePicker = await $('~datePicker');
    await datePicker.click();

    // Native date picker dialog
    // Set date (Android)
    await $('android=new UiSelector().text("15")').click();
    await $('~datePickerOK').click();

    expect(await datePicker.getText()).toMatch(/\d{2}\/\d{2}\/\d{4}/);
  });

  it('checkbox và radio button', async () => {
    const checkbox = await $('~agreeCheckbox');
    await checkbox.click();
    expect(await checkbox.getAttribute('checked')).toBe('true');

    // Toggle off
    await checkbox.click();
    expect(await checkbox.getAttribute('checked')).toBe('false');
  });

  it('scroll form dài', async () => {
    // Scroll xuống cuối form
    const submitButton = await $('~submitButton');
    await submitButton.scrollIntoView();

    expect(await submitButton.isDisplayed()).toBe(true);

    // Scroll lại lên đầu
    const firstField = await $('~inputName');
    await firstField.scrollIntoView();

    expect(await firstField.isDisplayed()).toBe(true);
  });
});
```

### Chạy test

```
> /mobile-test tests/mobile/app-form.mobile.ts
```

---

## 13. Test chức năng Mobile - WebView bên trong app

### Mục đích
Test nội dung web được nhúng bên trong native app (hybrid app).

### Tạo file test

Tạo file `tests/mobile/webview.mobile.ts`:

```typescript
describe('Mobile App - WebView', () => {
  it('chuyển sang WebView context', async () => {
    // Mở trang có WebView
    const webViewButton = await $('~openWebView');
    await webViewButton.click();

    // Đợi WebView load
    await driver.pause(3000);

    // Lấy danh sách contexts
    const contexts = await driver.getContexts();
    console.log('Available contexts:', contexts);

    // Phải có ít nhất: NATIVE_APP và WEBVIEW_xxx
    expect(contexts.length).toBeGreaterThanOrEqual(2);

    // Switch sang WebView
    const webviewContext = contexts.find((c: string) =>
      c.toString().includes('WEBVIEW')
    );
    expect(webviewContext).toBeDefined();
    await driver.switchContext(webviewContext!);
  });

  it('tương tác với HTML trong WebView', async () => {
    // Bây giờ dùng CSS selectors như Playwright
    const heading = await $('h1');
    await heading.waitForDisplayed({ timeout: 5000 });
    const text = await heading.getText();
    expect(text).toBeTruthy();
    console.log('WebView heading:', text);
  });

  it('điền form web trong WebView', async () => {
    const emailInput = await $('input[type="email"]');
    if (await emailInput.isExisting()) {
      await emailInput.setValue('user@example.com');

      const passwordInput = await $('input[type="password"]');
      await passwordInput.setValue('password123');

      const submitBtn = await $('button[type="submit"]');
      await submitBtn.click();

      // Chờ response
      await driver.pause(2000);

      // Verify kết quả
      const result = await $('.result-message');
      if (await result.isExisting()) {
        const resultText = await result.getText();
        console.log('Form result:', resultText);
      }
    }
  });

  it('click link trong WebView', async () => {
    const link = await $('a[href*="detail"]');
    if (await link.isExisting()) {
      await link.click();
      await driver.pause(2000);

      // Verify navigation trong WebView
      const url = await driver.getUrl();
      expect(url).toContain('detail');
    }
  });

  it('quay lại Native context', async () => {
    // Switch về native
    await driver.switchContext('NATIVE_APP');

    // Verify native elements hoạt động
    const nativeButton = await $('~backButton');
    if (await nativeButton.isExisting()) {
      expect(await nativeButton.isDisplayed()).toBe(true);
      await nativeButton.click();
    } else {
      await driver.back();
    }
  });

  it('data truyền giữa Native và WebView', async () => {
    // Ví dụ: native gửi user token cho WebView
    const webViewButton = await $('~openAuthWebView');
    if (await webViewButton.isExisting()) {
      await webViewButton.click();
      await driver.pause(3000);

      // Switch sang WebView
      const contexts = await driver.getContexts();
      const wv = contexts.find((c: string) => c.toString().includes('WEBVIEW'));
      await driver.switchContext(wv!);

      // Kiểm tra WebView đã nhận token (user đã logged in trong web)
      const userInfo = await $('.user-info');
      if (await userInfo.isExisting()) {
        const text = await userInfo.getText();
        expect(text).not.toContain('Please login');
      }

      // Quay lại native
      await driver.switchContext('NATIVE_APP');
    }
  });
});
```

### Chạy test

```
> /mobile-test tests/mobile/webview.mobile.ts
```

**Lưu ý quan trọng**: Để WebView debugging hoạt động, app phải bật `WebView.setWebContentsDebuggingEnabled(true)` trong code Android. Nếu không switch context sẽ thất bại.

---

## 14. Test chức năng Mobile - Push Notification

### Tạo file test

Tạo file `tests/mobile/notification.mobile.ts`:

```typescript
describe('Mobile App - Push Notification', () => {
  it('app yêu cầu quyền notification', async () => {
    // Với Appium autoGrantPermissions: true trong config,
    // quyền được tự động cấp.

    // Nếu không, xử lý permission dialog:
    const allowBtn = await $('~com.android.permissioncontroller:id/permission_allow_button');
    if (await allowBtn.isExisting()) {
      await allowBtn.click();
    }
  });

  it('nhận và hiển thị notification', async () => {
    // Trigger notification từ app (ví dụ: click nút test)
    const testNotifBtn = await $('~testNotification');
    if (await testNotifBtn.isExisting()) {
      await testNotifBtn.click();
      await driver.pause(3000);

      // Mở notification shade
      await driver.openNotifications();
      await driver.pause(1000);

      // Tìm notification
      const notification = await $('android=new UiSelector().textContains("Test notification")');
      expect(await notification.isDisplayed()).toBe(true);

      // Click notification → mở app
      await notification.click();
      await driver.pause(2000);

      // Verify app mở đúng screen
      const targetScreen = await $('~notificationDetail');
      if (await targetScreen.isExisting()) {
        expect(await targetScreen.isDisplayed()).toBe(true);
      }
    }
  });

  it('notification badge hiển thị', async () => {
    // Kiểm tra badge count trên tab/icon
    const badge = await $('~notificationBadge');
    if (await badge.isExisting()) {
      const badgeText = await badge.getText();
      expect(parseInt(badgeText)).toBeGreaterThan(0);
    }
  });
});
```

### Chạy test

```
> /mobile-test tests/mobile/notification.mobile.ts
```

---

## 15. Test chức năng Mobile - Gesture (Swipe, Scroll, Pinch)

### Tạo file test

Tạo file `tests/mobile/gestures.mobile.ts`:

```typescript
describe('Mobile App - Gestures', () => {
  it('swipe left/right (carousel, tabs)', async () => {
    const carousel = await $('~carousel');
    await carousel.waitForDisplayed();

    const { width, height } = await driver.getWindowRect();

    // Swipe left
    await driver.touchAction([
      { action: 'press', x: width * 0.8, y: height * 0.5 },
      { action: 'wait', ms: 300 },
      { action: 'moveTo', x: width * 0.2, y: height * 0.5 },
      { action: 'release' },
    ]);
    await driver.pause(500);

    // Verify slide đã chuyển
    const indicator = await $('~carouselIndicator_1');
    expect(await indicator.getAttribute('selected')).toBe('true');

    // Swipe right (quay lại)
    await driver.touchAction([
      { action: 'press', x: width * 0.2, y: height * 0.5 },
      { action: 'wait', ms: 300 },
      { action: 'moveTo', x: width * 0.8, y: height * 0.5 },
      { action: 'release' },
    ]);
    await driver.pause(500);

    const indicator0 = await $('~carouselIndicator_0');
    expect(await indicator0.getAttribute('selected')).toBe('true');
  });

  it('scroll danh sách dài', async () => {
    const list = await $('~contentList');
    await list.waitForDisplayed();

    // Lấy text item đầu
    const firstItem = await $('~listItem_0');
    const firstText = await firstItem.getText();

    // Scroll xuống
    const { width, height } = await driver.getWindowRect();
    await driver.touchAction([
      { action: 'press', x: width / 2, y: height * 0.8 },
      { action: 'wait', ms: 300 },
      { action: 'moveTo', x: width / 2, y: height * 0.2 },
      { action: 'release' },
    ]);
    await driver.pause(500);

    // Phải thấy items mới
    // (first item có thể đã bị scroll ẩn)
  });

  it('scroll đến element cụ thể (Android UiScrollable)', async () => {
    // Android-specific: scroll đến text
    const element = await $(
      'android=new UiScrollable(new UiSelector().scrollable(true))' +
      '.scrollIntoView(new UiSelector().text("Item cuối cùng"))'
    );

    expect(await element.isDisplayed()).toBe(true);
  });

  it('long press (nhấn giữ)', async () => {
    const item = await $('~listItem_0');

    // Long press 2 giây
    await driver.touchAction([
      { action: 'press', element: item },
      { action: 'wait', ms: 2000 },
      { action: 'release' },
    ]);

    // Context menu hoặc action mode xuất hiện
    const contextMenu = await $('~contextMenu');
    await contextMenu.waitForDisplayed({ timeout: 3000 });
    expect(await contextMenu.isDisplayed()).toBe(true);
  });

  it('pinch to zoom (nếu có map hoặc ảnh)', async () => {
    const imageView = await $('~zoomableImage');

    if (await imageView.isExisting()) {
      const { width, height } = await driver.getWindowRect();
      const centerX = width / 2;
      const centerY = height / 2;

      // Zoom in: 2 ngón tay ra xa nhau
      await driver.performActions([
        {
          type: 'pointer',
          id: 'finger1',
          parameters: { pointerType: 'touch' },
          actions: [
            { type: 'pointerMove', duration: 0, x: centerX - 50, y: centerY },
            { type: 'pointerDown', button: 0 },
            { type: 'pause', duration: 300 },
            { type: 'pointerMove', duration: 500, x: centerX - 150, y: centerY },
            { type: 'pointerUp', button: 0 },
          ],
        },
        {
          type: 'pointer',
          id: 'finger2',
          parameters: { pointerType: 'touch' },
          actions: [
            { type: 'pointerMove', duration: 0, x: centerX + 50, y: centerY },
            { type: 'pointerDown', button: 0 },
            { type: 'pause', duration: 300 },
            { type: 'pointerMove', duration: 500, x: centerX + 150, y: centerY },
            { type: 'pointerUp', button: 0 },
          ],
        },
      ]);

      await driver.pause(500);
    }
  });

  it('swipe to delete (vuốt để xóa)', async () => {
    const item = await $('~listItem_0');
    const itemText = await item.getText();

    const location = await item.getLocation();
    const size = await item.getSize();

    // Swipe left trên item
    await driver.touchAction([
      { action: 'press', x: location.x + size.width - 10, y: location.y + size.height / 2 },
      { action: 'wait', ms: 300 },
      { action: 'moveTo', x: location.x + 10, y: location.y + size.height / 2 },
      { action: 'release' },
    ]);

    await driver.pause(500);

    // Delete button xuất hiện
    const deleteBtn = await $('~swipeDeleteButton');
    if (await deleteBtn.isExisting()) {
      await deleteBtn.click();

      // Verify item đã bị xóa
      await driver.pause(500);
      const items = await $$('~listItem_0');
      if (items.length > 0) {
        const newText = await items[0].getText();
        expect(newText).not.toBe(itemText);
      }
    }
  });
});
```

### Chạy test

```
> /mobile-test tests/mobile/gestures.mobile.ts
```

---

## 16. Test chức năng Mobile - Camera & Permissions

### Tạo file test

Tạo file `tests/mobile/permissions.mobile.ts`:

```typescript
describe('Mobile App - Camera & Permissions', () => {
  it('yêu cầu quyền camera', async () => {
    const cameraBtn = await $('~openCamera');
    await cameraBtn.click();

    // Permission dialog (nếu autoGrantPermissions = false)
    const allowBtn = await $('android=new UiSelector().text("Allow")');
    if (await allowBtn.isExisting()) {
      await allowBtn.click();
    }

    // Camera view mở
    const cameraView = await $('~cameraView');
    await cameraView.waitForDisplayed({ timeout: 5000 });
    expect(await cameraView.isDisplayed()).toBe(true);
  });

  it('chụp ảnh từ camera', async () => {
    // Trên emulator: Appium inject ảnh giả
    const captureBtn = await $('~captureButton');
    await captureBtn.click();

    await driver.pause(2000);

    // Preview ảnh hiển thị
    const preview = await $('~photoPreview');
    await preview.waitForDisplayed({ timeout: 5000 });
    expect(await preview.isDisplayed()).toBe(true);
  });

  it('chọn ảnh từ gallery', async () => {
    const galleryBtn = await $('~openGallery');
    await galleryBtn.click();

    await driver.pause(2000);

    // Chọn ảnh đầu tiên trong gallery
    const firstImage = await $('android=new UiSelector().className("android.widget.ImageView").instance(0)');
    if (await firstImage.isExisting()) {
      await firstImage.click();

      await driver.pause(2000);

      // Ảnh đã chọn hiển thị trong app
      const selectedImage = await $('~selectedImage');
      if (await selectedImage.isExisting()) {
        expect(await selectedImage.isDisplayed()).toBe(true);
      }
    }
  });

  it('yêu cầu quyền vị trí (GPS)', async () => {
    const locationBtn = await $('~requestLocation');
    if (await locationBtn.isExisting()) {
      await locationBtn.click();

      // Auto-grant hoặc handle dialog
      const allowBtn = await $('android=new UiSelector().text("Allow")');
      if (await allowBtn.isExisting()) {
        await allowBtn.click();
      }

      // Verify location được lấy
      const locationText = await $('~locationResult');
      await locationText.waitForDisplayed({ timeout: 10000 });
      const text = await locationText.getText();
      expect(text).toMatch(/\d+\.\d+/); // lat/lng format
    }
  });

  it('từ chối quyền → hiển thị thông báo', async () => {
    // Reset permissions
    await driver.execute('mobile: clearApp', { appId: 'com.example.app' });
    await driver.execute('mobile: activateApp', { appId: 'com.example.app' });

    // Nếu autoGrantPermissions = false trong config:
    const cameraBtn = await $('~openCamera');
    if (await cameraBtn.isExisting()) {
      await cameraBtn.click();

      const denyBtn = await $('android=new UiSelector().text("Deny")');
      if (await denyBtn.isExisting()) {
        await denyBtn.click();

        // App phải xử lý gracefully
        const deniedMsg = await $('~permissionDenied');
        if (await deniedMsg.isExisting()) {
          expect(await deniedMsg.getText()).toContain('cần quyền');
        }
      }
    }
  });
});
```

### Chạy test

```
> /mobile-test tests/mobile/permissions.mobile.ts
```

**Lưu ý**: Test camera và GPS trên emulator sẽ dùng dữ liệu giả. Để test chính xác cần device thật.

---

## 17. Test Performance - Load Testing API

### Mục đích
Kiểm tra API chịu được bao nhiêu requests đồng thời.

### Tạo file test

Tạo file `tests/performance/api-load.k6.js`:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const loginDuration = new Trend('login_duration');

export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Tăng dần lên 10 users
    { duration: '1m',  target: 10 },   // Giữ 10 users trong 1 phút
    { duration: '30s', target: 0 },    // Giảm về 0
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],   // 95% requests < 500ms
    http_req_failed: ['rate<0.05'],     // < 5% failed
    errors: ['rate<0.1'],               // < 10% errors
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  // 1. GET trang chủ
  const homeRes = http.get(`${BASE_URL}/`);
  check(homeRes, {
    'Trang chủ status 200': (r) => r.status === 200,
    'Trang chủ load < 500ms': (r) => r.timings.duration < 500,
  });

  // 2. POST login
  const loginStart = Date.now();
  const loginRes = http.post(
    `${BASE_URL}/api/auth/login`,
    JSON.stringify({ email: 'user@example.com', password: 'password123' }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  loginDuration.add(Date.now() - loginStart);

  const loginOK = check(loginRes, {
    'Login status 200': (r) => r.status === 200,
    'Login có token': (r) => {
      try { return JSON.parse(r.body).token !== undefined; }
      catch { return false; }
    },
    'Login < 1s': (r) => r.timings.duration < 1000,
  });
  errorRate.add(!loginOK);

  if (loginOK) {
    const token = JSON.parse(loginRes.body).token;
    const headers = { Authorization: `Bearer ${token}` };

    // 3. GET danh sách sản phẩm
    const productsRes = http.get(`${BASE_URL}/api/products?page=1&limit=20`, { headers });
    check(productsRes, {
      'Products status 200': (r) => r.status === 200,
      'Products có data': (r) => JSON.parse(r.body).data.length > 0,
      'Products < 300ms': (r) => r.timings.duration < 300,
    });

    // 4. GET chi tiết sản phẩm
    const detailRes = http.get(`${BASE_URL}/api/products/1`, { headers });
    check(detailRes, {
      'Detail status 200': (r) => r.status === 200,
      'Detail < 200ms': (r) => r.timings.duration < 200,
    });

    // 5. POST tạo đơn hàng
    const orderRes = http.post(
      `${BASE_URL}/api/orders`,
      JSON.stringify({ product_id: 1, quantity: 2 }),
      { headers: { ...headers, 'Content-Type': 'application/json' } }
    );
    check(orderRes, {
      'Order status 201': (r) => r.status === 201,
      'Order < 500ms': (r) => r.timings.duration < 500,
    });
  }

  sleep(1); // Mỗi user nghỉ 1 giây giữa các iteration
}
```

### Chạy test

```
> /run-test tests/performance/api-load.k6.js
```

### Đọc kết quả

```
> /test-report --last
```

Kết quả sẽ hiển thị:
```
HTTP Request Duration:
  Average:  120ms
  p(90):    234ms
  p(95):    345ms    ← nếu > 500ms → FAIL
  p(99):    567ms

Failures: 35/1500 (2.3%)   ← nếu > 5% → FAIL
```

---

## 18. Test Performance - Stress Testing

### Mục đích
Tìm giới hạn chịu tải tối đa của hệ thống.

### Tạo file test

Tạo file `tests/performance/stress-test.k6.js`:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m',  target: 50 },   // Tăng lên 50 users
    { duration: '5m',  target: 50 },   // Giữ 50 users
    { duration: '2m',  target: 100 },  // Tăng lên 100 users
    { duration: '5m',  target: 100 },  // Giữ 100 users
    { duration: '2m',  target: 200 },  // Tăng lên 200 users!
    { duration: '5m',  target: 200 },  // Giữ 200 users
    { duration: '5m',  target: 0 },    // Giảm về 0
  ],
  thresholds: {
    http_req_duration: ['p(99)<2000'],   // 99% < 2 giây (nới lỏng hơn load test)
    http_req_failed: ['rate<0.10'],      // < 10% failed
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  const res = http.get(`${BASE_URL}/api/products`);

  check(res, {
    'status 200': (r) => r.status === 200,
    'response < 2s': (r) => r.timings.duration < 2000,
  });

  sleep(0.5);
}
```

### Chạy test

```
> /run-test tests/performance/stress-test.k6.js
```

---

## 19. Test Performance - Spike Testing

### Mục đích
Kiểm tra hệ thống phản ứng thế nào khi traffic đột ngột tăng vọt.

### Tạo file test

Tạo file `tests/performance/spike-test.k6.js`:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 5 },     // Traffic bình thường
    { duration: '1m',  target: 5 },
    { duration: '10s', target: 500 },   // SPIKE! 500 users đột ngột
    { duration: '3m',  target: 500 },   // Giữ spike
    { duration: '10s', target: 5 },     // Giảm đột ngột
    { duration: '3m',  target: 5 },     // Recovery period
    { duration: '10s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<3000'],   // Chấp nhận chậm hơn lúc spike
    http_req_failed: ['rate<0.15'],      // Chấp nhận 15% fail lúc spike
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  const res = http.get(`${BASE_URL}/`);
  check(res, {
    'status not 5xx': (r) => r.status < 500,
    'responded': (r) => r.timings.duration > 0,
  });
  sleep(0.1);
}
```

### Chạy test

```
> /run-test tests/performance/spike-test.k6.js
```

---

## 20. Test End-to-End - Cross-platform Flow

### Mục đích
Test một flow hoàn chỉnh xuyên suốt: web + mobile + API.

### Ví dụ: Flow "Đặt hàng"

**Bước 1**: Admin tạo sản phẩm trên web
```
> /run-test tests/web/admin-create-product.spec.ts
```

**Bước 2**: Verify API trả về sản phẩm
```
> /run-test tests/performance/verify-product-api.k6.js
```

**Bước 3**: User mua hàng trên mobile app
```
> /mobile-test tests/mobile/purchase-flow.mobile.ts
```

**Bước 4**: Xem tất cả kết quả
```
> /test-report --last
```

**Bước 5**: Tổng quan hệ thống
```
> /monitor
```

---

## 21. Xem kết quả & Debug lỗi

### Xem kết quả gần nhất

```
> /test-report
```

### Chỉ xem test thất bại

```
> /test-report --failures-only
```

### Xem kết quả của 1 suite cụ thể

```
> /test-report --suite login
```

### Debug test web thất bại

```
# Chạy lại với browser mở
> /run-test tests/web/auth.spec.ts --headed

# Chạy step-by-step
> /run-test tests/web/auth.spec.ts --debug

# Chạy chỉ 1 test
> /run-test tests/web/auth.spec.ts --grep "đăng nhập thành công"
```

### Debug test mobile thất bại

```
# Xem screenshots lỗi
> /test-report --failures-only
# → Screenshots saved at: ./screenshots/failure_2026-03-03T14-30-00.png

# Xem logcat Android
# (tự chạy lệnh ADB)
adb logcat -d | grep -i "error\|crash\|exception" | tail -50
```

### Xem tổng quan nhanh

```
> /monitor
```

---

## 22. CI/CD Integration

### GitHub Actions

Tạo file `.github/workflows/test.yml`:

```yaml
name: Automation Tests
on:
  push:
    branches: [main]
  pull_request:

jobs:
  web-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/

  mobile-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - uses: actions/setup-java@v4
        with:
          java-version: 17
          distribution: temurin
      - name: Setup Android Emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          script: |
            npm ci
            npm install -g appium
            appium driver install uiautomator2
            appium &
            sleep 5
            npx wdio run wdio.conf.ts

  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: grafana/setup-k6-action@v1
      - run: k6 run tests/performance/api-load.k6.js
```

### Dùng với Claude Code trong CI

```bash
# Chạy headless trong CI
claude -p "run /setup-test-env && /run-test && /test-report"
```

---

## Cheat Sheet - Skill nào cho chức năng nào?

| Tôi muốn test... | Dùng skill | Lệnh ví dụ |
|---|---|---|
| Login web | `/run-test` | `/run-test tests/web/auth.spec.ts` |
| Form validation web | `/run-test` | `/run-test tests/web/form-validation.spec.ts` |
| Responsive web | `/run-test` | `/run-test tests/web/responsive.spec.ts --project=mobile-chrome` |
| Cài APK lên phone | `/install-apk` | `/install-apk app-debug.apk` |
| Login trên app mobile | `/mobile-test` | `/mobile-test tests/mobile/app-auth.mobile.ts` |
| WebView trong app | `/mobile-test` | `/mobile-test tests/mobile/webview.mobile.ts` |
| Swipe/scroll trên app | `/mobile-test` | `/mobile-test tests/mobile/gestures.mobile.ts` |
| Load test API | `/run-test` | `/run-test tests/performance/api-load.k6.js` |
| Xem device nào available | `/devices` | `/devices` |
| Start Appium server | `/appium` | `/appium start` |
| Xem kết quả test | `/test-report` | `/test-report --failures-only` |
| Tổng quan hệ thống | `/monitor` | `/monitor` |
| Tạo project test mới | `/scaffold-test` | `/scaffold-test all` |
| Kiểm tra môi trường | `/setup-test-env` | `/setup-test-env` |
