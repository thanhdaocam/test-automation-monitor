---
name: docker-test
version: 2.0.0
description: Quản lý môi trường kiểm thử Docker. Khởi động/dừng container (cơ sở dữ liệu, dịch vụ), chạy kiểm thử trong môi trường Docker cô lập. Dùng cho microservices và kiểm thử tích hợp.
allowed-tools: Bash(docker *), Bash(docker-compose *), Bash(cat *), Bash(ls *), Bash(node *), Bash(curl *), Read, Grep, Glob
user-invocable: true
argument-hint: <up|down|status|run> [--file docker-compose.test.yml] [--service name] [--build]
---

# Môi trường kiểm thử Docker

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

**Đợi dịch vụ sẵn sàng (tương thích đa nền tảng):**

**Trên macOS/Linux:**
```bash
timeout $timeout bash -c 'until docker compose -f $compose_file exec db pg_isready; do sleep 1; done'
timeout $timeout bash -c 'until curl -sf http://localhost:3000/health; do sleep 1; done'
```

**Trên Windows (dùng Node.js):**
```bash
node -e "const {execSync}=require('child_process');const start=Date.now();const timeout=$timeout*1000;while(Date.now()-start<timeout){try{execSync('docker compose -f $compose_file exec db pg_isready',{timeout:5000});process.exit(0)}catch{}}console.error('Hết thời gian đợi');process.exit(1)"
```

> **Lưu ý:** Lệnh `timeout` trên Windows CMD có cú pháp khác (`timeout /t` chỉ để tạm dừng). Dùng Node.js hoặc Git Bash cho logic đợi phức tạp.

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

## Security Best Practices

> **⚠ CRITICAL: Never hardcode passwords or secrets in docker-compose files.**

- **Use environment variables with defaults** for all credentials in `docker-compose.test.yml`:
  - `${POSTGRES_PASSWORD:-testpass}` — defaults are only for local development convenience
  - Create a `.env` file (from `templates/.env.example`) for environment-specific overrides
- **Never commit `.env` files** — they are gitignored by default. Only `.env.example` templates should be in version control.
- **Use separate credentials** for test vs. production environments — never reuse production database passwords in test configs.
- **For CI/CD pipelines**: inject credentials via pipeline secrets (GitHub Secrets, GitLab CI Variables), not via committed `.env` files.
- **Rotate database passwords** regularly, especially for shared test environments.
- **Limit port exposure** — only expose ports that tests actually need. Avoid exposing database ports in production-like environments.
- **Clean up volumes** containing test data after use: `docker compose down -v` removes data volumes to prevent credential/data leakage.
- **Scan Docker images** for vulnerabilities: `docker scout cve <image>` or use Trivy/Snyk.

## Related Skills

- Run tests after env is up: `/unit-test`, `/api-test`, `/run-test`
- Database testing: `/db-test`
- Generate CI with Docker: `/ci-gen`
- Full status: `/monitor`
