---
name: unit-test
description: Run unit and component tests. Auto-detects framework (Jest, Vitest, pytest, go test, PHPUnit) from project config. Shows pass/fail results with coverage. Use for any project with unit tests.
allowed-tools: Bash(npx *), Bash(node *), Bash(pytest *), Bash(python *), Bash(go *), Bash(php *), Bash(cat *), Bash(ls *), Read, Grep, Glob
user-invocable: true
argument-hint: [test-file-or-pattern] [--coverage] [--watch] [--filter pattern]
---

# Unit Testing

Execute unit and component tests with auto-framework detection.

## Current Project Context

Project type detection:
!`node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};const fw=[];if(d.vitest)fw.push('vitest');if(d.jest||d['@jest/core'])fw.push('jest');if(d.mocha)fw.push('mocha');if(d['@testing-library/react'])fw.push('testing-library');console.log(fw.length?'Frameworks: '+fw.join(', '):'No JS test framework found')}catch{}" 2>/dev/null`
!`ls pyproject.toml pytest.ini setup.cfg 2>/dev/null | head -3`
!`ls go.mod go.sum 2>/dev/null | head -2`

## Parse Arguments

- `$0` = test file, pattern, or directory (optional, runs all if omitted)
- `--coverage` = generate code coverage report
- `--watch` = watch mode (re-run on file changes)
- `--filter <pattern>` = filter tests by name
- `--update-snapshots` = update snapshot tests (Jest/Vitest)

## Steps

### 1. Detect Test Framework

**Auto-detection order:**

1. Check `vitest.config.*` → **Vitest**
2. Check `jest.config.*` or `package.json` has `jest` key → **Jest**
3. Check `pyproject.toml` / `pytest.ini` / `setup.cfg` has pytest → **pytest**
4. Check `go.mod` exists → **go test**
5. Check `phpunit.xml` → **PHPUnit**
6. Check `package.json` scripts for `test` command → use that

```bash
# Detection commands
ls vitest.config.* 2>/dev/null
ls jest.config.* 2>/dev/null
node -e "try{const p=require('./package.json');if(p.jest)console.log('jest-config-in-package')}catch{}" 2>/dev/null
ls pyproject.toml pytest.ini setup.cfg 2>/dev/null
ls go.mod 2>/dev/null
ls phpunit.xml phpunit.xml.dist 2>/dev/null
```

### 2. Run Vitest

```bash
npx vitest run $test_pattern --reporter=json --reporter=default --outputFile=test-results/vitest-results.json
```

With coverage:
```bash
npx vitest run $test_pattern --coverage --reporter=json --outputFile=test-results/vitest-results.json
```

With filter:
```bash
npx vitest run -t "$filter_pattern"
```

### 3. Run Jest

```bash
npx jest $test_pattern --json --outputFile=test-results/jest-results.json
```

With coverage:
```bash
npx jest $test_pattern --coverage --json --outputFile=test-results/jest-results.json
```

With filter:
```bash
npx jest $test_pattern -t "$filter_pattern"
```

### 4. Run pytest

```bash
python -m pytest $test_pattern -v --tb=short --json-report --json-report-file=test-results/pytest-results.json
```

With coverage:
```bash
python -m pytest $test_pattern --cov --cov-report=json:test-results/coverage.json -v
```

### 5. Run go test

```bash
go test ./... -v -json > test-results/go-test-results.json 2>&1
```

With coverage:
```bash
go test ./... -v -coverprofile=test-results/coverage.out -json > test-results/go-test-results.json 2>&1
```

With filter:
```bash
go test ./... -v -run "$filter_pattern" -json
```

### 6. Run PHPUnit

```bash
php vendor/bin/phpunit $test_pattern --log-junit test-results/phpunit-results.xml
```

### 7. Display Results

Parse JSON output and display:

```
Unit Test Results (Vitest)
══════════════════════════════════════════════════════════════
  ✓ utils/format.test.ts
    ✓ formatDate › formats ISO date              2ms
    ✓ formatDate › handles null input             1ms
    ✓ formatCurrency › adds $ prefix              1ms
  ✗ utils/validate.test.ts
    ✓ validateEmail › accepts valid email          1ms
    ✗ validateEmail › rejects invalid email        3ms
      Expected: false
      Received: true
      at validate.test.ts:24:10
──────────────────────────────────────────────────────────────
Tests:   4 passed, 1 failed, 5 total
Suites:  1 passed, 1 failed, 2 total
Time:    0.8s
Coverage: 78.5% statements, 65.2% branches
══════════════════════════════════════════════════════════════
```

### 8. Post-Run

- Show pass/fail summary with counts
- If `--coverage`, show coverage summary (statements, branches, functions, lines)
- If failures, show error details with file:line
- Suggest: "Use `--watch` for continuous testing during development"

## Error Recovery

- If no test framework detected: "No test framework found. Install one: `npm install -D vitest` or `npm install -D jest`. Or use `/scaffold-test unit`."
- If `vitest` not found: "Run `npm install -D vitest`"
- If `jest` not found: "Run `npm install -D jest @types/jest ts-jest`"
- If `pytest` not found: "Run `pip install pytest pytest-json-report`"
- If `go` not found: "Install Go from https://go.dev/dl/"
- If snapshot mismatch: suggest `--update-snapshots` flag
- If import errors: suggest checking `tsconfig.json` or module resolution

## Related Skills

- Create unit test templates: `/scaffold-test unit`
- View detailed report: `/test-report --last`
- Run web E2E tests: `/run-test`
- Run API tests: `/api-test`
- Check coverage: use `--coverage` flag
