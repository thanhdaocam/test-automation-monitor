/**
 * BackstopJS Configuration
 * Docs: https://github.com/garris/BackstopJS
 * Run with: /visual-test (auto-detects this config)
 */
module.exports = {
  id: 'visual-regression',
  viewports: [
    { label: 'phone', width: 375, height: 667 },
    { label: 'tablet', width: 768, height: 1024 },
    { label: 'desktop', width: 1280, height: 720 },
  ],
  scenarios: [
    {
      label: 'Homepage',
      url: 'http://localhost:3000',
      delay: 1000,
      misMatchThreshold: 0.1,
      requireSameDimensions: true,
    },
    {
      label: 'Login Page',
      url: 'http://localhost:3000/login',
      delay: 500,
      misMatchThreshold: 0.1,
    },
    {
      label: 'Dashboard',
      url: 'http://localhost:3000/dashboard',
      delay: 2000,
      // Hide dynamic content
      removeSelectors: ['.timestamp', '.live-counter'],
      misMatchThreshold: 0.2,
    },
  ],
  paths: {
    bitmaps_reference: 'backstop_data/bitmaps_reference',
    bitmaps_test: 'backstop_data/bitmaps_test',
    html_report: 'backstop_data/html_report',
    ci_report: 'backstop_data/ci_report',
  },
  engine: 'playwright',
  engineOptions: {
    browser: 'chromium',
    args: ['--no-sandbox'],
  },
  asyncCaptureLimit: 5,
  asyncCompareLimit: 50,
  debug: false,
  debugWindow: false,
};
