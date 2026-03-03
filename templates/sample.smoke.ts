import { test, expect } from '@playwright/test';

/**
 * Sample Smoke Test
 * File pattern: *.smoke.ts or tagged @smoke
 * Run with: /smoke-test --env local
 *
 * Smoke tests verify critical user paths are working.
 * They should be fast (<30s total) and non-destructive.
 */

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

test.describe('@smoke Critical Path', () => {
  // Fast timeout for smoke tests
  test.setTimeout(15000);

  test('Homepage loads successfully', async ({ page }) => {
    const response = await page.goto(BASE_URL);
    expect(response?.status()).toBe(200);
    await expect(page).toHaveTitle(/.+/); // Any non-empty title
  });

  test('Login page accessible', async ({ page }) => {
    const response = await page.goto(`${BASE_URL}/login`);
    expect(response?.status()).toBe(200);
    await expect(page.locator('form')).toBeVisible();
  });

  test('Login flow works', async ({ page }) => {
    await page.goto(`${BASE_URL}/login`);
    await page.fill('[data-testid="email"], #email, [name="email"]', 'user@example.com');
    await page.fill('[data-testid="password"], #password, [name="password"]', 'password123');
    await page.click('[type="submit"]');

    // Should redirect to dashboard or home
    await page.waitForURL(/\/(dashboard|home|$)/, { timeout: 10000 });
  });

  test('API health endpoint responds', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/api/health`);
    expect(response.status()).toBe(200);
  });

  test('Static assets load (CSS/JS)', async ({ page }) => {
    await page.goto(BASE_URL);

    // Check no failed resource loads
    const failedRequests: string[] = [];
    page.on('requestfailed', request => {
      failedRequests.push(request.url());
    });

    await page.waitForLoadState('networkidle');
    expect(failedRequests).toEqual([]);
  });

  test('Navigation works', async ({ page }) => {
    await page.goto(BASE_URL);
    const links = page.locator('nav a, header a');
    const count = await links.count();

    // Verify at least one nav link exists and is clickable
    expect(count).toBeGreaterThan(0);
    const firstLink = links.first();
    await expect(firstLink).toBeVisible();
  });
});

test.describe('@smoke API Endpoints', () => {
  test.setTimeout(10000);

  test('GET /api/users returns data', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/api/users`);
    expect(response.status()).toBeLessThan(500);
  });

  test('GET /api/products returns data', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/api/products`);
    expect(response.status()).toBeLessThan(500);
  });
});
