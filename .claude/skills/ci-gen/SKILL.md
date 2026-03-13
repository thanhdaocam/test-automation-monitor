---
name: ci-gen
version: 2.0.0
description: Tạo cấu hình pipeline CI/CD cho bộ kiểm thử. Hỗ trợ GitHub Actions, GitLab CI, Jenkins và Azure Pipelines. Tự phát hiện loại dự án và tạo cấu hình pipeline phù hợp.
allowed-tools: Bash(cat *), Bash(ls *), Bash(node *), Bash(mkdir *), Read, Write, Grep, Glob
user-invocable: true
argument-hint: <github|gitlab|jenkins|azure> [--test-type web|mobile|api|unit|performance|all]
disable-model-invocation: true
---

# Trình tạo pipeline CI/CD

Generate CI/CD pipeline configuration files for automated test execution.

## Current Project Context

Existing CI/CD configs:
!`ls .github/workflows/*.yml .github/workflows/*.yaml .gitlab-ci.yml Jenkinsfile azure-pipelines.yml bitbucket-pipelines.yml 2>/dev/null || echo "No CI/CD config found"`

Project type:
!`node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};const types=[];if(d['@playwright/test'])types.push('playwright');if(d.webdriverio||d['@wdio/cli'])types.push('wdio');if(d.vitest||d.jest)types.push('unit');if(d.cypress)types.push('cypress');console.log(types.length?'Test types: '+types.join(', '):'No test frameworks detected')}catch{console.log('No package.json')}" 2>/dev/null`

## Parse Arguments

- `$0` = CI platform: `github`, `gitlab`, `jenkins`, `azure` (required)
- `--test-type <type>` = test types to include: `web`, `mobile`, `api`, `unit`, `performance`, `all` (default: auto-detect)
- `--node-version <v>` = Node.js version (default: 20)
- `--schedule <cron>` = add scheduled trigger (cron expression)

## Steps

### 1. Detect CI Platform

Map argument to output file:
- `github` → `.github/workflows/tests.yml`
- `gitlab` → `.gitlab-ci.yml`
- `jenkins` → `Jenkinsfile`
- `azure` → `azure-pipelines.yml`

### 2. Detect Test Types

If `--test-type` not specified, auto-detect from project:
- Check `package.json` dependencies for test frameworks
- Check for test file patterns (*.spec.ts, *.k6.js, *.mobile.ts, *.api.ts)
- Check for config files (playwright.config.ts, wdio.conf.ts, cypress.config.ts)

### 3. Generate Pipeline Config

Based on the CI platform and test types detected, use the Write tool to create the appropriate config file from `templates/ci/` directory.

**For GitHub Actions**, create `.github/workflows/tests.yml` with:
- Trigger: push to main, pull requests
- Jobs for each test type (unit, web E2E, API, performance)
- Proper caching (node_modules, Playwright browsers)
- Artifact upload (test results, screenshots, videos)
- Matrix strategy for cross-browser (if web tests)

**For GitLab CI**, create `.gitlab-ci.yml` with:
- Stages: test, report
- Jobs for each test type
- Caching and artifacts
- Pages for HTML reports

**For Jenkins**, create `Jenkinsfile` with:
- Declarative pipeline
- Stages for each test type
- Post-build actions (publish reports)
- Parallel execution

**For Azure**, create `azure-pipelines.yml` with:
- Trigger and PR policies
- Jobs for each test type
- Test result publishing
- Artifact publishing

### 4. Read the appropriate template from `templates/ci/` and adapt it based on detected test types. Use the Write tool to create the config file.

### 5. Post-Generation

- Show the generated file path
- Explain what the pipeline does
- Suggest: "Commit this file and push to trigger the pipeline"
- Note any secrets/variables that need to be configured in CI settings

## Error Recovery

- If platform not specified: ask user to choose from github/gitlab/jenkins/azure
- If existing CI config found: warn user and ask before overwriting
- If no test frameworks detected: generate a basic pipeline with npm test
- For mobile tests in CI: note that mobile tests require device/emulator setup

## Related Skills

- Check environment: `/setup-test-env`
- Run tests locally first: `/run-test` or `/unit-test`
- Send notifications: `/notify`
- Status overview: `/monitor`
