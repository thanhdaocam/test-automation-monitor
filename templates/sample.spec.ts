import { test, expect } from '@playwright/test';

test.describe('Login Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('should display login form', async ({ page }) => {
    await expect(page.locator('form')).toBeVisible();
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('should login with valid credentials', async ({ page }) => {
    await page.locator('input[name="email"]').fill('user@example.com');
    await page.locator('input[name="password"]').fill('password123');
    await page.locator('button[type="submit"]').click();

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Dashboard');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.locator('input[name="email"]').fill('wrong@example.com');
    await page.locator('input[name="password"]').fill('wrongpass');
    await page.locator('button[type="submit"]').click();

    await expect(page.locator('.error-message')).toBeVisible();
    await expect(page.locator('.error-message')).toContainText(
      'Invalid email or password'
    );
  });

  test('should validate required fields', async ({ page }) => {
    await page.locator('button[type="submit"]').click();

    await expect(page.locator('input[name="email"]:invalid')).toBeVisible();
  });

  test('should navigate to register page', async ({ page }) => {
    await page.locator('a[href="/register"]').click();
    await expect(page).toHaveURL('/register');
  });
});
