describe('App Login Flow', () => {
  it('should open the app and see login screen', async () => {
    // Wait for app to load
    const loginTitle = await $('~loginTitle');
    await loginTitle.waitForDisplayed({ timeout: 10000 });
    expect(await loginTitle.getText()).toBe('Sign In');
  });

  it('should login with valid credentials', async () => {
    // Fill native form
    const emailInput = await $('~emailInput');
    await emailInput.setValue('user@example.com');

    const passwordInput = await $('~passwordInput');
    await passwordInput.setValue('password123');

    const loginButton = await $('~loginButton');
    await loginButton.click();

    // Wait for dashboard to load
    const dashboard = await $('~dashboardTitle');
    await dashboard.waitForDisplayed({ timeout: 10000 });
    expect(await dashboard.getText()).toBe('Dashboard');
  });

  it('should switch to WebView and interact with web content', async () => {
    // Navigate to a screen with WebView
    const webViewTab = await $('~webViewTab');
    await webViewTab.click();

    // Wait for WebView to load
    await driver.pause(3000);

    // Get available contexts
    const contexts = await driver.getContexts();
    console.log('Available contexts:', contexts);

    // Find and switch to WebView context
    const webviewContext = contexts.find((c: string) =>
      c.toString().includes('WEBVIEW')
    );

    if (webviewContext) {
      await driver.switchContext(webviewContext);

      // Now use web selectors (CSS/XPath)
      const heading = await $('h1');
      await heading.waitForDisplayed({ timeout: 5000 });
      const text = await heading.getText();
      console.log('WebView heading:', text);
      expect(text).toBeTruthy();

      // Interact with a web form inside the app
      const searchInput = await $('input[type="search"]');
      if (await searchInput.isExisting()) {
        await searchInput.setValue('test query');
      }

      // Switch back to native context
      await driver.switchContext('NATIVE_APP');
    } else {
      console.log('No WebView context available, skipping WebView test');
    }
  });

  it('should logout', async () => {
    // Back in native context
    const menuButton = await $('~menuButton');
    await menuButton.click();

    const logoutButton = await $('~logoutButton');
    await logoutButton.click();

    // Verify back on login screen
    const loginTitle = await $('~loginTitle');
    await loginTitle.waitForDisplayed({ timeout: 5000 });
    expect(await loginTitle.getText()).toBe('Sign In');
  });
});
