import { PactV3, MatchersV3 } from '@pact-foundation/pact';
import { resolve } from 'path';

/**
 * Sample Consumer Contract Test (Pact)
 * File pattern: *.pact.ts
 * Run with: /contract-test sample.pact.ts
 *
 * Prerequisites: npm install -D @pact-foundation/pact
 */

const { like, eachLike, string, integer, iso8601DateTimeWithMillis } = MatchersV3;

const provider = new PactV3({
  consumer: 'Frontend',
  provider: 'UserService',
  dir: resolve(process.cwd(), 'pacts'),
});

describe('User Service Contract', () => {

  describe('GET /api/users', () => {
    it('returns a list of users', async () => {
      // Arrange: define expected interaction
      provider
        .given('users exist')
        .uponReceiving('a request for all users')
        .withRequest({
          method: 'GET',
          path: '/api/users',
          headers: { Accept: 'application/json' },
        })
        .willRespondWith({
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: eachLike({
            id: integer(1),
            name: string('Alice'),
            email: string('alice@example.com'),
            createdAt: iso8601DateTimeWithMillis('2024-01-01T00:00:00.000Z'),
          }),
        });

      // Act & Assert
      await provider.executeTest(async (mockServer) => {
        const response = await fetch(`${mockServer.url}/api/users`, {
          headers: { Accept: 'application/json' },
        });

        expect(response.status).toBe(200);
        const users = await response.json();
        expect(Array.isArray(users)).toBe(true);
        expect(users[0]).toHaveProperty('id');
        expect(users[0]).toHaveProperty('email');
      });
    });
  });

  describe('GET /api/users/:id', () => {
    it('returns a single user', async () => {
      provider
        .given('user with id 1 exists')
        .uponReceiving('a request for user 1')
        .withRequest({
          method: 'GET',
          path: '/api/users/1',
          headers: { Accept: 'application/json' },
        })
        .willRespondWith({
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: like({
            id: integer(1),
            name: string('Alice'),
            email: string('alice@example.com'),
            role: string('admin'),
          }),
        });

      await provider.executeTest(async (mockServer) => {
        const response = await fetch(`${mockServer.url}/api/users/1`, {
          headers: { Accept: 'application/json' },
        });

        expect(response.status).toBe(200);
        const user = await response.json();
        expect(user.id).toBe(1);
      });
    });

    it('returns 404 for non-existent user', async () => {
      provider
        .given('user with id 999 does not exist')
        .uponReceiving('a request for non-existent user')
        .withRequest({
          method: 'GET',
          path: '/api/users/999',
          headers: { Accept: 'application/json' },
        })
        .willRespondWith({
          status: 404,
          body: like({ error: string('User not found') }),
        });

      await provider.executeTest(async (mockServer) => {
        const response = await fetch(`${mockServer.url}/api/users/999`, {
          headers: { Accept: 'application/json' },
        });
        expect(response.status).toBe(404);
      });
    });
  });

  describe('POST /api/users', () => {
    it('creates a new user', async () => {
      const newUser = { name: 'Bob', email: 'bob@example.com' };

      provider
        .uponReceiving('a request to create a user')
        .withRequest({
          method: 'POST',
          path: '/api/users',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
          },
          body: newUser,
        })
        .willRespondWith({
          status: 201,
          headers: { 'Content-Type': 'application/json' },
          body: like({
            id: integer(2),
            name: string('Bob'),
            email: string('bob@example.com'),
          }),
        });

      await provider.executeTest(async (mockServer) => {
        const response = await fetch(`${mockServer.url}/api/users`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
          },
          body: JSON.stringify(newUser),
        });

        expect(response.status).toBe(201);
        const created = await response.json();
        expect(created.name).toBe('Bob');
      });
    });
  });
});
