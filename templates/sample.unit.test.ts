import { describe, test, expect } from 'vitest';

/**
 * Sample Unit Test
 * File pattern: *.unit.test.ts or *.test.ts
 * Run with: /unit-test sample.unit.test.ts
 */

// --- Example utility functions to test ---
function formatCurrency(amount: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(amount);
}

function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function slugify(text: string): string {
  return text.toLowerCase().replace(/\s+/g, '-').replace(/[^\w-]+/g, '');
}

function truncate(str: string, maxLength: number): string {
  if (str.length <= maxLength) return str;
  return str.slice(0, maxLength - 3) + '...';
}

// --- Tests ---

describe('formatCurrency', () => {
  test('formats USD correctly', () => {
    expect(formatCurrency(1234.56)).toBe('$1,234.56');
  });

  test('handles zero', () => {
    expect(formatCurrency(0)).toBe('$0.00');
  });

  test('handles negative amounts', () => {
    expect(formatCurrency(-50)).toBe('-$50.00');
  });
});

describe('validateEmail', () => {
  test('accepts valid email', () => {
    expect(validateEmail('user@example.com')).toBe(true);
  });

  test('accepts email with subdomain', () => {
    expect(validateEmail('user@mail.example.com')).toBe(true);
  });

  test('rejects email without @', () => {
    expect(validateEmail('userexample.com')).toBe(false);
  });

  test('rejects email without domain', () => {
    expect(validateEmail('user@')).toBe(false);
  });

  test('rejects empty string', () => {
    expect(validateEmail('')).toBe(false);
  });
});

describe('slugify', () => {
  test('converts to lowercase', () => {
    expect(slugify('Hello World')).toBe('hello-world');
  });

  test('replaces spaces with hyphens', () => {
    expect(slugify('my blog post')).toBe('my-blog-post');
  });

  test('removes special characters', () => {
    expect(slugify('Hello! World?')).toBe('hello-world');
  });
});

describe('truncate', () => {
  test('returns full string if under limit', () => {
    expect(truncate('Hello', 10)).toBe('Hello');
  });

  test('truncates with ellipsis', () => {
    expect(truncate('Hello World, this is long', 10)).toBe('Hello W...');
  });

  test('handles exact length', () => {
    expect(truncate('12345', 5)).toBe('12345');
  });
});
