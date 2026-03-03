/** @type {import('jest').Config} */
const config = {
  // Test file patterns
  testMatch: [
    '**/__tests__/**/*.{ts,tsx,js,jsx}',
    '**/*.{test,spec}.{ts,tsx,js,jsx}',
  ],

  // TypeScript support
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },

  // Module resolution
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },

  // Coverage
  collectCoverageFrom: [
    'src/**/*.{ts,tsx,js,jsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/types/**',
  ],
  coverageDirectory: 'test-results/coverage',
  coverageReporters: ['text', 'json', 'lcov'],
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 70,
      functions: 80,
      lines: 80,
    },
  },

  // Reporter
  reporters: [
    'default',
    ['jest-json-reporter', { outputDir: 'test-results', outputFile: 'jest-results.json' }],
  ],

  // Environment
  testEnvironment: 'node',

  // Timeouts
  testTimeout: 10000,

  // Clear mocks between tests
  clearMocks: true,
  restoreMocks: true,
};

module.exports = config;
