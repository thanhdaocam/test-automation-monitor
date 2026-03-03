import { by, device, element, expect } from 'detox';

/**
 * Sample React Native E2E Test (Detox)
 * File pattern: *.e2e.ts
 * Run with: /rn-test sample.e2e.ts --e2e
 */

describe('Login Flow', () => {
  beforeAll(async () => {
    await device.launchApp({ newInstance: true });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should show login screen on launch', async () => {
    await expect(element(by.id('login-screen'))).toBeVisible();
    await expect(element(by.id('email-input'))).toBeVisible();
    await expect(element(by.id('password-input'))).toBeVisible();
    await expect(element(by.id('login-button'))).toBeVisible();
  });

  it('should show error for empty fields', async () => {
    await element(by.id('login-button')).tap();
    await expect(element(by.text('Email is required'))).toBeVisible();
  });

  it('should login successfully', async () => {
    await element(by.id('email-input')).typeText('user@example.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();

    await expect(element(by.id('home-screen'))).toBeVisible();
    await expect(element(by.text('Welcome'))).toBeVisible();
  });

  it('should show error for wrong password', async () => {
    await element(by.id('email-input')).typeText('user@example.com');
    await element(by.id('password-input')).typeText('wrong');
    await element(by.id('login-button')).tap();

    await expect(element(by.text('Invalid credentials'))).toBeVisible();
  });
});

describe('Navigation', () => {
  beforeAll(async () => {
    await device.launchApp({ newInstance: true });
    // Login first
    await element(by.id('email-input')).typeText('user@example.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();
  });

  it('should navigate to profile', async () => {
    await element(by.id('tab-profile')).tap();
    await expect(element(by.id('profile-screen'))).toBeVisible();
  });

  it('should navigate to settings', async () => {
    await element(by.id('tab-settings')).tap();
    await expect(element(by.id('settings-screen'))).toBeVisible();
  });

  it('should handle back navigation', async () => {
    await element(by.id('tab-profile')).tap();
    await element(by.id('edit-profile-button')).tap();
    await expect(element(by.id('edit-profile-screen'))).toBeVisible();

    await device.pressBack();
    await expect(element(by.id('profile-screen'))).toBeVisible();
  });

  it('should scroll long list', async () => {
    await element(by.id('tab-home')).tap();
    await element(by.id('items-list')).scrollTo('bottom');
    await expect(element(by.text('Load more'))).toBeVisible();
  });
});
