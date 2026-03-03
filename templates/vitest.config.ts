import { defineConfig } from 'vitest/config';

/**
 * Vitest Configuration
 * Docs: https://vitest.dev/config/
 * Run with: /unit-test
 */
export default defineConfig({
  test: {
    // Test file patterns
    include: ['**/*.{test,spec}.{ts,tsx,js,jsx}'],
    exclude: ['**/node_modules/**', '**/dist/**', '**/.{idea,git,cache,output,temp}/**'],

    // Environment: 'node' for backend, 'jsdom' for frontend components
    environment: 'node',

    // Coverage configuration
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      reportsDirectory: 'test-results/coverage',
      include: ['src/**/*.{ts,tsx,js,jsx}'],
      exclude: ['**/*.test.*', '**/*.spec.*', '**/types/**'],
      thresholds: {
        statements: 80,
        branches: 70,
        functions: 80,
        lines: 80,
      },
    },

    // Reporter
    reporters: ['default', 'json'],
    outputFile: 'test-results/vitest-results.json',

    // Globals
    globals: true,

    // Timeouts
    testTimeout: 10000,
    hookTimeout: 10000,
  },
});
