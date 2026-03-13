import { test, expect } from '@playwright/test';

/**
 * Sample Visual Regression Test
 * File pattern: *.visual.ts
 * Run with: /visual-test sample.visual.ts
 *
 * First run creates baseline screenshots.
 * Subsequent runs compare against baseline.
 * Use --update to accept changes as new baseline.
 */

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

test.describe('Visual Regression - Desktop', () => {

  test('Homepage', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('homepage-desktop.png', {
      maxDiffPixelRatio: 0.1,
      fullPage: true,
    });
  });

  test('Login Page', async ({ page }) => {
    await page.goto(`${BASE_URL}/login`);
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('login-desktop.png', {
      maxDiffPixelRatio: 0.1,
    });
  });

  test('Dashboard', async ({ page }) => {
    // Login first
    await page.goto(`${BASE_URL}/login`);
    await page.locator('[data-testid="email"]').fill('user@example.com');
    await page.locator('[data-testid="password"]').fill('password123');
    await page.locator('[data-testid="submit"]').click();
    await page.waitForURL('**/dashboard');

    // Hide dynamic content before screenshot
    await page.evaluate(() => {
      document.querySelectorAll('[data-testid="timestamp"]').forEach(el => {
        (el as HTMLElement).style.visibility = 'hidden';
      });
    });

    await expect(page).toHaveScreenshot('dashboard-desktop.png', {
      maxDiffPixelRatio: 0.1,
    });
  });
});

test.describe('Visual Regression - Mobile', () => {
  test.use({ viewport: { width: 375, height: 667 } });

  test('Homepage mobile', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('homepage-mobile.png', {
      maxDiffPixelRatio: 0.1,
      fullPage: true,
    });
  });

  test('Login Page mobile', async ({ page }) => {
    await page.goto(`${BASE_URL}/login`);
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('login-mobile.png', {
      maxDiffPixelRatio: 0.1,
    });
  });
});

test.describe('Visual Regression - Components', () => {

  test('Button variants', async ({ page }) => {
    await page.goto(`${BASE_URL}/storybook/buttons`);
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.button-grid')).toHaveScreenshot('buttons.png');
  });

  test('Form elements', async ({ page }) => {
    await page.goto(`${BASE_URL}/storybook/forms`);
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.form-showcase')).toHaveScreenshot('forms.png');
  });
});
