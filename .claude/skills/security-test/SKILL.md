---
name: security-test
version: 2.0.0
description: Quét bảo mật dự án. Kiểm tra lỗ hổng phụ thuộc (npm audit, Snyk), vấn đề OWASP, và cấu hình bảo mật sai phổ biến. Dùng cho mọi dự án cần tuân thủ bảo mật.
allowed-tools: Bash(npm *), Bash(npx *), Bash(node *), Bash(pip *), Bash(cat *), Bash(ls *), Bash(grep *), Read, Grep, Glob
user-invocable: true
argument-hint: [--deps] [--code] [--owasp] [--fix] [--severity critical|high|medium|low]
---

# Kiểm thử bảo mật

Quét dự án để tìm lỗ hổng bảo mật: kiểm tra phụ thuộc, phân tích mã tĩnh và kiểm tra OWASP.

## Current Project Context

Package managers detected:
!`ls package-lock.json yarn.lock pnpm-lock.yaml requirements.txt Pipfile.lock go.sum Gemfile.lock composer.lock 2>/dev/null || echo "No lock files found"`

## Parse Arguments

- `--deps` = scan dependencies only (npm audit / pip audit)
- `--code` = static code analysis only
- `--owasp` = OWASP Top 10 check (web projects)
- `--fix` = auto-fix vulnerabilities where possible
- `--severity <level>` = minimum severity to report (critical, high, medium, low)
- No flags = run all scans

## Steps

### 1. Dependency Vulnerability Scan

**Node.js projects:**
```bash
npm audit --json 2>/dev/null || echo "{}"
```

With auto-fix:
```bash
npm audit fix
```

**Check for known critical packages:**
```bash
npx is-website-vulnerable 2>/dev/null || true
```

**Python projects:**
```bash
pip audit --format json 2>/dev/null || pip-audit --format json 2>/dev/null
```

**If Snyk is available:**
```bash
npx snyk test --json 2>/dev/null
```

### 2. Static Code Analysis

**Kiểm tra secrets được mã hóa cứng (tương thích đa nền tảng — dùng Grep tool hoặc Node.js):**

> **Lưu ý:** Các lệnh `grep -rn --include` bên dưới hoạt động trên macOS/Linux/Git Bash. Trên Windows thuần, sử dụng công cụ Grep tích hợp của Claude Code hoặc `findstr /s /n /r` thay thế.

```bash
# Tìm kiếm secrets tiềm ẩn trong mã nguồn (macOS/Linux/Git Bash)
grep -rn --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" --include="*.py" --include="*.java" --include="*.go" -E "(password|secret|api_key|token|private_key)\s*[:=]\s*['\"][^'\"]+['\"]" src/ app/ lib/ 2>/dev/null | head -20
```

**Thay thế Windows (PowerShell):**
```powershell
Get-ChildItem -Recurse -Include *.ts,*.js,*.tsx,*.jsx,*.py -Path src/,app/,lib/ -ErrorAction SilentlyContinue | Select-String -Pattern "(password|secret|api_key|token|private_key)\s*[:=]\s*['\`"][^'\`"]+['\`"]" | Select-Object -First 20
```

**Kiểm tra mẫu bảo mật phổ biến:**
```bash
# SQL injection patterns (macOS/Linux/Git Bash)
grep -rn --include="*.ts" --include="*.js" --include="*.py" -E "(\bexec\b.*\+|query\(.*\+|raw\(.*\$)" src/ 2>/dev/null | head -10

# XSS patterns (dangerouslySetInnerHTML, innerHTML)
grep -rn --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" -E "(dangerouslySetInnerHTML|\.innerHTML\s*=)" src/ 2>/dev/null | head -10

# Eval usage
grep -rn --include="*.ts" --include="*.js" -E "\beval\s*\(" src/ 2>/dev/null | head -10
```

> **Gợi ý:** Trên Windows, sử dụng công cụ Grep tích hợp của Claude Code cho các tìm kiếm trên — nó hoạt động trên mọi nền tảng.

### 3. OWASP Top 10 Check (Web Projects)

For each category, check relevant patterns:

1. **A01 Broken Access Control** - Check auth middleware, route protection
2. **A02 Cryptographic Failures** - Check for weak hashing, plaintext passwords
3. **A03 Injection** - Check for SQL/NoSQL/Command injection
4. **A04 Insecure Design** - Check for missing rate limiting
5. **A05 Security Misconfiguration** - Check CORS, headers, debug mode
6. **A06 Vulnerable Components** - npm audit results
7. **A07 Auth Failures** - Check password policies, session management
8. **A08 Data Integrity** - Check for unsigned data, CSRF protection
9. **A09 Logging Failures** - Check if security events are logged
10. **A10 SSRF** - Check for user-controlled URLs in server requests

### 4. Display Results

```
Security Scan Results
══════════════════════════════════════════════════════════════
DEPENDENCY VULNERABILITIES
  Critical:  2
  High:      5
  Medium:    12
  Low:       8

  ✗ lodash@4.17.15 ── Prototype Pollution (Critical)
    Fix: npm install lodash@4.17.21
  ✗ express@4.17.1 ── Open Redirect (High)
    Fix: npm install express@4.18.2

CODE ANALYSIS
  ✗ src/api/users.ts:45 ── Potential SQL injection
  ✗ src/utils/auth.ts:12 ── Hardcoded API key detected
  ✓ No eval() usage found
  ✓ No dangerouslySetInnerHTML found

OWASP TOP 10
  ✓ A01 Access Control ── Auth middleware found
  ✗ A03 Injection ── 1 potential issue
  ✓ A05 Configuration ── CORS configured
  ✗ A06 Vulnerable Components ── 7 issues
──────────────────────────────────────────────────────────────
Risk Level: HIGH (2 critical vulnerabilities)
Recommendation: Run with --fix to auto-patch dependencies
══════════════════════════════════════════════════════════════
```

## Error Recovery

- If `npm audit` fails: check if package-lock.json exists, run `npm install` first
- If Snyk not available: fall back to `npm audit` (built-in, no install needed)
- If no package manager detected: report that dependency scanning is not applicable
- For false positives in code scan: note that manual review is recommended

## Related Skills

- Fix vulnerabilities: use `--fix` flag
- Check environment: `/setup-test-env`
- Full project status: `/monitor`
- Run web tests after fixing: `/run-test`
