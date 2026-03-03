import type { Options } from '@wdio/types';

export const config: Options.Testrunner = {
  runner: 'local',
  port: 4723,
  tsConfigPath: './tsconfig.json',

  specs: ['./tests/mobile/**/*.mobile.ts'],
  exclude: [],

  maxInstances: 1,

  capabilities: [
    {
      platformName: 'Android',
      'appium:automationName': 'UiAutomator2',
      'appium:deviceName': process.env.DEVICE_NAME || 'emulator-5554',
      'appium:app': process.env.APP_PATH || './app/app-debug.apk',
      'appium:autoGrantPermissions': true,
      'appium:newCommandTimeout': 240,
      // WebView support
      'appium:autoWebview': false,
      'appium:chromedriverAutodownload': true,
      'appium:nativeWebScreenshot': true,
    },
  ],

  logLevel: 'warn',
  bail: 0,
  waitforTimeout: 10000,
  connectionRetryTimeout: 120000,
  connectionRetryCount: 3,

  services: ['appium'],

  framework: 'mocha',
  mochaOpts: {
    ui: 'bdd',
    timeout: 120000,
  },

  reporters: [
    'spec',
    [
      'json',
      {
        outputDir: './test-results',
        outputFileFormat: () => 'wdio-results.json',
      },
    ],
  ],

  // Take screenshot on failure
  afterTest: async function (test, _context, { error, passed }) {
    if (!passed) {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      await browser.saveScreenshot(
        `./screenshots/failure_${timestamp}.png`
      );
    }
  },
};
