#!/usr/bin/env bash
# check-env.sh - Verify test automation prerequisites
# Usage: bash scripts/check-env.sh
# Output: Status of each tool with color-coded results

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_tool() {
    local name="$1"
    local cmd="$2"
    local required="${3:-optional}"

    local version=""
    # Use a subshell to safely capture output; avoid eval on untrusted input
    if version=$(bash -c "$cmd" 2>/dev/null | head -1); then
        if [ -n "$version" ]; then
            echo -e "  ${GREEN}✓${NC} ${name}: ${version}"
            PASS=$((PASS + 1))
        else
            # Command succeeded but no output — treat as found
            echo -e "  ${GREEN}✓${NC} ${name}: (installed)"
            PASS=$((PASS + 1))
        fi
    else
        if [ "$required" = "required" ]; then
            echo -e "  ${RED}✗${NC} ${name}: not found"
            FAIL=$((FAIL + 1))
        else
            echo -e "  ${YELLOW}○${NC} ${name}: not found (optional)"
            WARN=$((WARN + 1))
        fi
    fi
}

echo ""
echo "═══════════════════════════════════════════"
echo "  Test Automation Environment Check"
echo "═══════════════════════════════════════════"
echo ""

echo "Core Tools:"
check_tool "Node.js" "node --version" "required"
check_tool "npm" "npm --version" "required"
check_tool "Java" "java --version 2>&1 | head -1" "required"

echo ""
echo "Android Tools:"
check_tool "ADB" "adb version | head -1" "required"
if [ -n "${ANDROID_HOME:-}" ]; then
    echo -e "  ${GREEN}✓${NC} ANDROID_HOME: ${ANDROID_HOME}"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗${NC} ANDROID_HOME: not set"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "Test Frameworks:"
check_tool "Appium" "appium --version" "required"
check_tool "Appium Drivers" "appium driver list --installed 2>/dev/null | grep -c 'installed'" "required"
check_tool "Playwright" "npx playwright --version 2>/dev/null" "required"
check_tool "k6" "k6 version" "optional"

echo ""
echo "iOS Tools (macOS only):"
if [[ "${OSTYPE:-unknown}" == "darwin"* ]]; then
    check_tool "Xcode" "xcodebuild -version | head -1" "optional"
    check_tool "ios-deploy" "ios-deploy --version" "optional"
    check_tool "idevice_id" "idevice_id --version 2>&1 | head -1" "optional"
else
    echo -e "  ${YELLOW}○${NC} Skipped (not macOS)"
fi

echo ""
echo "═══════════════════════════════════════════"
echo -e "  Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}, ${YELLOW}${WARN} optional${NC}"

if [ "$FAIL" -eq 0 ]; then
    echo -e "  ${GREEN}Environment is ready!${NC}"
else
    echo -e "  ${RED}${FAIL} required tool(s) missing.${NC}"
    echo ""
    echo "Install missing tools:"
    echo "  Appium:     npm install -g appium"
    echo "  Drivers:    appium driver install uiautomator2"
    echo "  Playwright: npm install -D @playwright/test && npx playwright install"
    echo "  k6:         https://k6.io/docs/get-started/installation/"
fi
echo "═══════════════════════════════════════════"
echo ""

exit "$FAIL"
