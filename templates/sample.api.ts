import { test, expect } from '@playwright/test';

/**
 * API Test Sample - REST endpoints
 * File pattern: *.api.ts
 * Run with: /api-test sample.api.ts
 */

const BASE_URL = process.env.BASE_URL || 'https://jsonplaceholder.typicode.com';

test.describe('Users API', () => {

  test('GET /users - should return user list', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/users`);
    expect(response.status()).toBe(200);

    const users = await response.json();
    expect(Array.isArray(users)).toBe(true);
    expect(users.length).toBeGreaterThan(0);
    expect(users[0]).toHaveProperty('id');
    expect(users[0]).toHaveProperty('email');
  });

  test('GET /users/:id - should return single user', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/users/1`);
    expect(response.status()).toBe(200);

    const user = await response.json();
    expect(user.id).toBe(1);
    expect(user.name).toBeTruthy();
  });

  test('POST /users - should create new user', async ({ request }) => {
    const newUser = {
      name: 'Test User',
      username: 'testuser',
      email: 'test@example.com',
    };

    const response = await request.post(`${BASE_URL}/users`, { data: newUser });
    expect(response.status()).toBe(201);

    const created = await response.json();
    expect(created.name).toBe(newUser.name);
    expect(created.email).toBe(newUser.email);
  });

  test('PUT /users/:id - should update user', async ({ request }) => {
    const updates = { name: 'Updated Name' };
    const response = await request.put(`${BASE_URL}/users/1`, { data: updates });
    expect(response.status()).toBe(200);

    const updated = await response.json();
    expect(updated.name).toBe('Updated Name');
  });

  test('DELETE /users/:id - should delete user', async ({ request }) => {
    const response = await request.delete(`${BASE_URL}/users/1`);
    expect(response.status()).toBe(200);
  });

  test('GET /users/:id - should return 404 for non-existent', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/users/99999`);
    expect(response.status()).toBe(404);
  });
});

test.describe('Posts API - GraphQL style', () => {

  test('GET /posts - should support pagination', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/posts?_limit=5&_page=1`);
    expect(response.status()).toBe(200);

    const posts = await response.json();
    expect(posts.length).toBeLessThanOrEqual(5);
  });

  test('GET /posts - should filter by userId', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/posts?userId=1`);
    expect(response.status()).toBe(200);

    const posts = await response.json();
    posts.forEach((post: any) => {
      expect(post.userId).toBe(1);
    });
  });
});
