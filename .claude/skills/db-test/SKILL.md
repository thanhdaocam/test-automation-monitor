---
name: db-test
version: 2.0.0
description: Chạy kiểm thử cơ sở dữ liệu để xác minh schema, migration, truy vấn và toàn vẹn dữ liệu. Hỗ trợ SQL (PostgreSQL, MySQL, SQLite) và NoSQL (MongoDB). Dùng cho dự án có thao tác cơ sở dữ liệu.
allowed-tools: Bash(npx *), Bash(node *), Bash(psql *), Bash(mysql *), Bash(sqlite3 *), Bash(mongosh *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: <test-file> [--db-url connection-string] [--reset] [--seed]
---

# Kiểm thử cơ sở dữ liệu

Execute database tests: schema validation, migration testing, query performance, and data integrity checks.

## Current Project Context

Tệp cấu hình cơ sở dữ liệu:
!`node -e "const fs=require('fs');const path=require('path');function walk(d,depth,max){let r=[];if(depth>max)return r;try{for(const f of fs.readdirSync(d)){if(f.startsWith('.')&&f!=='.env')continue;const p=path.join(d,f);try{const s=fs.statSync(p);if(s.isDirectory()&&f!=='node_modules')r=r.concat(walk(p,depth+1,max));else if(/\.(db\.test\.ts|migration\.test\.ts)$/.test(f)||/^(knexfile\..+|drizzle\.config\..+|\.env)$/.test(f))r.push(p)}catch{}}}catch{}return r}const files=walk('.',0,3);console.log(files.length?files.join('\n'):'Không tìm thấy cấu hình DB')"`

ORM detection:
!`node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};const orm=[];if(d.prisma||d['@prisma/client'])orm.push('prisma');if(d.knex)orm.push('knex');if(d.sequelize)orm.push('sequelize');if(d.typeorm)orm.push('typeorm');if(d.drizzle||d['drizzle-orm'])orm.push('drizzle');if(d.mongoose)orm.push('mongoose');console.log(orm.length?'ORMs: '+orm.join(', '):'No ORM found')}catch{}" 2>/dev/null`

## Parse Arguments

- `$0` = test file or pattern (required)
- `--db-url <url>` = database connection string (overrides .env)
- `--reset` = reset database before tests (drop + recreate)
- `--seed` = run seed data before tests
- `--migrations` = run pending migrations before tests

## Steps

### 1. Detect Database Type

Check project for ORM/database client:

```bash
# Prisma
ls prisma/schema.prisma 2>/dev/null

# Knex
ls knexfile.ts knexfile.js 2>/dev/null

# Drizzle
ls drizzle.config.ts drizzle.config.js 2>/dev/null

# TypeORM
ls ormconfig.ts ormconfig.json 2>/dev/null

# Raw SQL
ls migrations/ 2>/dev/null
```

### 2. Pre-Test Setup

If `--reset`:
```bash
# Prisma
npx prisma db push --force-reset

# Knex
npx knex migrate:rollback --all && npx knex migrate:latest

# Drizzle
npx drizzle-kit push:pg --force
```

If `--migrations`:
```bash
# Prisma
npx prisma migrate deploy

# Knex
npx knex migrate:latest
```

If `--seed`:
```bash
# Prisma
npx prisma db seed

# Knex
npx knex seed:run
```

### 3. Run Database Tests

Execute tests using the project's test runner (Jest/Vitest):
```bash
npx vitest run $test_file --reporter=json --outputFile=test-results/db-test-results.json
# or
npx jest $test_file --json --outputFile=test-results/db-test-results.json
```

### 4. Display Results

```
Database Test Results
══════════════════════════════════════════════════════════════
Database: PostgreSQL (via Prisma)
  ✓ Schema validation
    ✓ Users table has correct columns            12ms
    ✓ Foreign keys are properly defined           8ms
    ✓ Indexes exist on frequently queried cols    5ms
  ✓ Migration tests
    ✓ Migration 001 creates users table          45ms
    ✓ Migration 002 adds email index             23ms
  ✗ Query tests
    ✓ findUserById returns correct user           6ms
    ✗ findUsersByRole handles pagination         34ms
      Error: Expected 10 results, got 15
      at queries.db.test.ts:67
  ✓ Data integrity
    ✓ Unique constraint prevents duplicate email  8ms
    ✓ Cascade delete removes related records     12ms
──────────────────────────────────────────────────────────────
Tests: 8 passed, 1 failed | Duration: 153ms
══════════════════════════════════════════════════════════════
```

## Error Recovery

- If database connection fails: check `--db-url` or `.env` file for DATABASE_URL
- If migrations fail: suggest running `/db-test --reset` to start fresh
- If ORM not found: suggest installing Prisma (`npm install -D prisma`) or Knex (`npm install knex`)
- If test database doesn't exist: suggest creating it manually or using `--reset`
- For timeout errors: check database server is running and accessible

## Security Best Practices

> **⚠ CRITICAL: Never hardcode database connection strings with real credentials in code or config files.**

- **Use environment variables** for all database credentials:
  - Set `DATABASE_URL` in `.env` (gitignored), not in test files or config
  - Use `--db-url` argument for one-off overrides, but do not save it to shell history with real passwords
- **Never use production database credentials** for testing — always create separate test databases with isolated credentials.
- **Use test-specific databases** that can be safely reset and seeded without affecting real data.
- **For CI/CD pipelines**: use pipeline secrets for `DATABASE_URL` and other connection strings. Never commit connection strings to YAML configs.
- **Sanitize seed data** — do not use real user data (names, emails, PII) in test seeds. Use `/test-data generate` with Faker.js for realistic but synthetic data.
- **Rotate database passwords** periodically, especially for shared test environments accessible by multiple developers.
- **Limit database user permissions** — test users should only have access to test schemas, not `SUPERUSER` or `DBA` roles.
- **Clean up after tests** — use `--reset` flag to prevent stale test data from accumulating.

## Related Skills

- Generate test data: `/test-data generate --schema users`
- Create DB test templates: `/scaffold-test database`
- Run unit tests: `/unit-test`
- View results: `/test-report --last`
