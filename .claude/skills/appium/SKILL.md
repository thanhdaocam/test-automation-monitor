---
name: appium
description: Start, stop, or check the status of the Appium 2.0 server for mobile testing. Subcommands - start, stop, status, install-drivers. Use before running mobile tests.
allowed-tools: Bash(appium *), Bash(curl *), Bash(lsof *), Bash(netstat *), Bash(tasklist *), Bash(taskkill *), Bash(kill *), Bash(npm *), Bash(npx *)
user-invocable: true
argument-hint: [start|stop|status|install-drivers] [--port 4723]
disable-model-invocation: true
---

# Appium Server Management

Control the Appium 2.0 server for mobile automation testing.

## Parse Arguments

- `$0` = subcommand: `start`, `stop`, `status`, or `install-drivers`. Default to `status` if not provided.
- `--port <number>` = port to use. Default: `4723`.

## Subcommands

### `status` (default)

Check if Appium server is running:

**On Windows:**
```bash
netstat -ano | grep :<port> 2>/dev/null || echo "NOT_RUNNING"
```

**On macOS/Linux:**
```bash
lsof -i :<port> 2>/dev/null || echo "NOT_RUNNING"
```

**Health check:**
```bash
curl -s http://localhost:<port>/status 2>/dev/null
```

Display result:
- If running: "Appium server is **running** on port <port>" + show version from health check response
- If not running: "Appium server is **not running**. Use `/appium start` to start it."

Also check installed drivers:
```bash
appium driver list --installed 2>/dev/null
```

### `start`

1. First check if already running (same as `status` check). If yes, report "Already running on port <port>" and stop.

2. Check Appium is installed:
   ```bash
   appium --version
   ```
   If not found: "Appium not installed. Run `/appium install-drivers` or `npm install -g appium`."

3. Start Appium server in the background:

   **On Windows:**
   ```bash
   appium server --port <port> --allow-cors > /tmp/appium.log 2>&1 &
   ```

   **On macOS/Linux:**
   ```bash
   nohup appium server --port <port> --allow-cors > /tmp/appium.log 2>&1 &
   ```

4. Wait 3 seconds, then verify it started:
   ```bash
   sleep 3 && curl -s http://localhost:<port>/status
   ```

5. Report:
   - Success: "Appium server started on port <port>. Logs: /tmp/appium.log"
   - Failed: Show last 20 lines of /tmp/appium.log for debugging

### `stop`

1. Find the Appium process:

   **On Windows:**
   ```bash
   netstat -ano | grep :<port>
   ```
   Extract PID, then:
   ```bash
   taskkill /PID <pid> /F
   ```

   **On macOS/Linux:**
   ```bash
   lsof -t -i :<port>
   ```
   Then:
   ```bash
   kill -9 $(lsof -t -i :<port>)
   ```

2. Verify it stopped:
   ```bash
   curl -s http://localhost:<port>/status 2>/dev/null
   ```

3. Report: "Appium server stopped." or "No Appium server was running on port <port>."

### `install-drivers`

1. Check Appium is installed:
   ```bash
   appium --version
   ```
   If not: install it first with `npm install -g appium`.

2. List current drivers:
   ```bash
   appium driver list --installed
   ```

3. Install missing drivers:
   ```bash
   appium driver install uiautomator2 2>/dev/null || echo "uiautomator2 already installed"
   appium driver install xcuitest 2>/dev/null || echo "xcuitest already installed or not on macOS"
   ```

4. Verify:
   ```bash
   appium driver list --installed
   ```

5. Report installed drivers with versions.
