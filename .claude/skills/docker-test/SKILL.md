---
name: docker-test
description: Manage Docker-based test environments. Start/stop test containers (databases, services), run tests in isolated Docker environments. Use for microservices and integration testing with real dependencies.
allowed-tools: Bash(docker *), Bash(docker-compose *), Bash(cat *), Bash(ls *), Bash(node *), Bash(curl *), Read, Grep, Glob
user-invocable: true
argument-hint: <up|down|status|run> [--file docker-compose.test.yml] [--service name] [--build]
---

# Docker Test Environment

Manage Docker containers for isolated test environments.

## Current Project Context

Docker files:
!`ls docker-compose.test.yml docker-compose.testing.yml docker-compose.yml Dockerfile Dockerfile.test 2>/dev/null || echo "No Docker files found"`

Docker status:
!`docker info --format '{{.ServerVersion}}' 2>/dev/null || echo "Docker not running or not installed"`

Running containers:
!`docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | head -10 || echo "Cannot list containers"`

## Parse Arguments

- `$0` = action: `up`, `down`, `status`, `run` (required)
- `--file <path>` = docker-compose file (default: `docker-compose.test.yml`)
- `--service <name>` = specific service to manage
- `--build` = rebuild images before starting
- `--detach` = run in background (default for `up`)
- `--timeout <s>` = wait timeout for services to be ready (default: 60s)

## Steps

### 1. Action: `up` — Start Test Environment

```bash
docker compose -f $compose_file up -d --wait
```

With build:
```bash
docker compose -f $compose_file up -d --build --wait
```

Specific service:
```bash
docker compose -f $compose_file up -d $service_name
```

**Wait for services to be healthy:**
```bash
# Wait for database
timeout $timeout bash -c 'until docker compose -f $compose_file exec db pg_isready; do sleep 1; done'

# Wait for HTTP service
timeout $timeout bash -c 'until curl -sf http://localhost:3000/health; do sleep 1; done'
```

### 2. Action: `down` — Stop Test Environment

```bash
docker compose -f $compose_file down
```

With volume cleanup (full reset):
```bash
docker compose -f $compose_file down -v --remove-orphans
```

### 3. Action: `status` — Check Environment

```bash
docker compose -f $compose_file ps
```

Show logs for unhealthy services:
```bash
docker compose -f $compose_file ps --filter "status=unhealthy" --format json
docker compose -f $compose_file logs --tail 20 $unhealthy_service
```

### 4. Action: `run` — Run Tests in Docker

Run test command inside container:
```bash
docker compose -f $compose_file run --rm test-runner npx vitest run
```

Or run in existing service:
```bash
docker compose -f $compose_file exec app npx vitest run
```

### 5. Display Results

```
Docker Test Environment
══════════════════════════════════════════════════════════════
Compose file: docker-compose.test.yml

SERVICES
  Name          Status      Ports              Health
  ─────────────────────────────────────────────────────
  postgres      running     5432:5432          healthy
  redis         running     6379:6379          healthy
  api           running     3000:3000          healthy
  test-runner   exited(0)   -                  -

VOLUMES
  test_postgres_data    120MB
  test_redis_data       2MB

──────────────────────────────────────────────────────────────
Status: All services healthy | Uptime: 2m 30s
══════════════════════════════════════════════════════════════
```

## Error Recovery

- If Docker not installed: provide install instructions for user's OS
- If Docker daemon not running: "Start Docker Desktop or run `sudo systemctl start docker`"
- If port conflict: show which process uses the port, suggest changing in compose file
- If build fails: show build logs and suggest `--no-cache` rebuild
- If service unhealthy: show last 20 lines of logs for that service
- If out of disk space: suggest `docker system prune` to clean up

## Related Skills

- Run tests after env is up: `/unit-test`, `/api-test`, `/run-test`
- Database testing: `/db-test`
- Generate CI with Docker: `/ci-gen`
- Full status: `/monitor`
