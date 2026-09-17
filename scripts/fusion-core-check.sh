#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export SCHAGLK_ROOT="$ROOT"

PASS=0
FAIL=0

run_test() {
    local name="$1"
    shift

    echo
    echo ">>> $name"

    if "$@"; then
        echo "[PASS] $name"
        PASS=$((PASS+1))
    else
        echo "[FAIL] $name"
        FAIL=$((FAIL+1))
    fi
}

run_test "Fusion structure" \
    "$ROOT/core/diagnostics/fusion-check.sh"

run_test "Terminal core" \
    "$ROOT/core/tests/terminal-test.sh"

run_test "Git/GitHub core" \
    "$ROOT/core/tests/git-test.sh"

run_test "AI status" \
    "$ROOT/core/ai/ai-engine.sh" status

run_test "Toolchain inventory" \
    "$ROOT/core/toolchains/inventory.sh"

echo
echo "============================================================"
echo "SCHAGLK FUSION CORE RESULT"
echo "PASS=$PASS"
echo "FAIL=$FAIL"
echo "APK_BUILD=SKIPPED"
echo "============================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "FUSION CORE: PASS"
    exit 0
else
    echo "FUSION CORE: FAIL"
    exit 1
fi
