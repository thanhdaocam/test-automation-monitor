---
name: db-test
description: Run database tests to validate schemas, migrations, queries, and data integrity. Supports SQL databases (PostgreSQL, MySQL, SQLite) and NoSQL (MongoDB). Use for projects with database operations.
allowed-tools: Bash(npx *), Bash(node *), Bash(psql *), Bash(mysql *), Bash(sqlite3 *), Bash(mongosh *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: <test-file> [--db-url connection-string] [--reset] [--seed]
---

# Database Testing

Execute database tests: schema validation, migration testing, query performance, and data integrity checks.

## Current Project Context

Database config files:
!`find . -maxdepth 3 -type f \( -name "*.db.test.ts" -o -name "*.migration.test.ts" -o -name "knexfile.*" -o -name "prisma" -o -name "drizzle.config.*" -o -name ".env" \) 2>/dev/null | head -10 || echo "No DB config found"`

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

## Related Skills

- Generate test data: `/test-data generate --schema users`
- Create DB test templates: `/scaffold-test database`
- Run unit tests: `/unit-test`
- View results: `/test-report --last`
