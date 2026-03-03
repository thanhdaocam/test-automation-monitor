import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

/**
 * Sample Accessibility Test (WCAG 2.2 AA)
 * File pattern: *.a11y.ts
 * Run with: /a11y-test sample.a11y.ts
 *
 * Prerequisites: npm install -D @axe-core/playwright
 */

const BASE_URL = process.env.BASE_URL || 'https://example.com';

test.describe('Accessibility - Homepage', () => {

  test('should have no critical a11y violations', async ({ page }) => {
    await page.goto(BASE_URL);
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();

    expect(results.violations.filter(v => v.impact === 'critical')).toEqual([]);
  });

  test('should have no serious a11y violations', async ({ page }) => {
    await page.goto(BASE_URL);
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();

    const serious = results.violations.filter(v =>
      v.impact === 'critical' || v.impact === 'serious'
    );
    expect(serious).toEqual([]);
  });

  test('all images should have alt text', async ({ page }) => {
    await page.goto(BASE_URL);
    const images = page.locator('img');
    const count = await images.count();

    for (let i = 0; i < count; i++) {
      const alt = await images.nth(i).getAttribute('alt');
      expect(alt, `Image ${i + 1} missing alt text`).toBeTruthy();
    }
  });

  test('all form inputs should have labels', async ({ page }) => {
    await page.goto(BASE_URL);
    const inputs = page.locator('input:not([type="hidden"]), select, textarea');
    const count = await inputs.count();

    for (let i = 0; i < count; i++) {
      const input = inputs.nth(i);
      const id = await input.getAttribute('id');
      const ariaLabel = await input.getAttribute('aria-label');
      const ariaLabelledBy = await input.getAttribute('aria-labelledby');

      const hasLabel = id
        ? await page.locator(`label[for="${id}"]`).count() > 0
        : false;

      expect(
        hasLabel || !!ariaLabel || !!ariaLabelledBy,
        `Input ${i + 1} (id="${id}") has no label`
      ).toBe(true);
    }
  });

  test('color contrast should meet WCAG AA requirements', async ({ page }) => {
    await page.goto(BASE_URL);
    const results = await new AxeBuilder({ page })
      .withRules(['color-contrast'])
      .analyze();

    expect(results.violations).toEqual([]);
  });

  test('page should be navigable by keyboard', async ({ page }) => {
    await page.goto(BASE_URL);

    // Tab through focusable elements
    await page.keyboard.press('Tab');
    const firstFocused = await page.evaluate(() => document.activeElement?.tagName);
    expect(firstFocused).toBeTruthy();

    // Check skip link exists
    const skipLink = page.locator('a[href="#main"], a[href="#content"], .skip-link');
    const hasSkipLink = await skipLink.count() > 0;
    // Skip links are recommended but not strictly required
    if (!hasSkipLink) {
      console.log('Note: No skip-to-content link found (recommended for keyboard users)');
    }
  });
});

test.describe('Accessibility - Login Page', () => {

  test('login form should be accessible', async ({ page }) => {
    await page.goto(`${BASE_URL}/login`);
    const results = await new AxeBuilder({ page })
      .include('form')
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();

    expect(results.violations).toEqual([]);
  });

  test('error messages should be associated with inputs', async ({ page }) => {
    await page.goto(`${BASE_URL}/login`);

    // Submit empty form to trigger errors
    await page.locator('button[type="submit"]').click();

    // Check aria-describedby or aria-errormessage on invalid inputs
    const invalidInputs = page.locator('[aria-invalid="true"]');
    const count = await invalidInputs.count();

    for (let i = 0; i < count; i++) {
      const describedBy = await invalidInputs.nth(i).getAttribute('aria-describedby');
      const errorMessage = await invalidInputs.nth(i).getAttribute('aria-errormessage');
      expect(
        describedBy || errorMessage,
        `Invalid input ${i + 1} has no error association`
      ).toBeTruthy();
    }
  });
});
