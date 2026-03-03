import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const loginDuration = new Trend('login_duration');

// Test configuration
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Ramp up to 10 users
    { duration: '1m', target: 10 },   // Stay at 10 users
    { duration: '30s', target: 50 },  // Ramp up to 50 users
    { duration: '1m', target: 50 },   // Stay at 50 users
    { duration: '30s', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.05'],
    errors: ['rate<0.1'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  // GET homepage
  const homeRes = http.get(`${BASE_URL}/`);
  check(homeRes, {
    'homepage status 200': (r) => r.status === 200,
    'homepage loads < 500ms': (r) => r.timings.duration < 500,
  });

  // POST login
  const loginStart = Date.now();
  const loginRes = http.post(
    `${BASE_URL}/api/login`,
    JSON.stringify({
      email: 'user@example.com',
      password: 'password123',
    }),
    {
      headers: { 'Content-Type': 'application/json' },
    }
  );
  loginDuration.add(Date.now() - loginStart);

  const loginSuccess = check(loginRes, {
    'login status 200': (r) => r.status === 200,
    'login has token': (r) => {
      try {
        return JSON.parse(r.body as string).token !== undefined;
      } catch {
        return false;
      }
    },
  });

  errorRate.add(!loginSuccess);

  if (loginSuccess) {
    const token = JSON.parse(loginRes.body as string).token;

    // GET dashboard (authenticated)
    const dashRes = http.get(`${BASE_URL}/api/dashboard`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    check(dashRes, {
      'dashboard status 200': (r) => r.status === 200,
      'dashboard loads < 300ms': (r) => r.timings.duration < 300,
    });

    // GET user list
    const usersRes = http.get(`${BASE_URL}/api/users?page=1&limit=20`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    check(usersRes, {
      'users status 200': (r) => r.status === 200,
      'users response has data': (r) => {
        try {
          return JSON.parse(r.body as string).data.length > 0;
        } catch {
          return false;
        }
      },
    });
  }

  sleep(1);
}
