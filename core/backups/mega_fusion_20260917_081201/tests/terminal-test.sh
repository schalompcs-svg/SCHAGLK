#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"
RUNNER="$ROOT/core/terminal/runner.sh"
TEST="$WORK/__TERMINAL_TEST__"

PASS=0
FAIL=0

ok() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

bad() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}

rm -rf "$TEST"
mkdir -p "$TEST"

echo "=== SCHAGLK TERMINAL TESTS ==="

if "$RUNNER" "mkdir -p __TERMINAL_TEST__/nested"; then
    [ -d "$TEST/nested" ] && ok "mkdir" || bad "mkdir output"
else
    bad "mkdir execution"
fi

if "$RUNNER" "printf 'SCHAGLK TERMINAL OK\n' > __TERMINAL_TEST__/test.txt"; then
    if grep -q "SCHAGLK TERMINAL OK" "$TEST/test.txt"; then
        ok "file output"
    else
        bad "file content"
    fi
else
    bad "file command"
fi

if "$RUNNER" "printf 'ABC' > __TERMINAL_TEST__/nested/data.txt"; then
    if [ "$(cat "$TEST/nested/data.txt")" = "ABC" ]; then
        ok "nested file"
    else
        bad "nested file content"
    fi
else
    bad "nested file"
fi

if "$RUNNER" "python -c 'print(\"PYTHON_OK\")'" | grep -q "PYTHON_OK"; then
    ok "python"
else
    bad "python"
fi

if "$RUNNER" "node -e 'console.log(\"NODE_OK\")'" | grep -q "NODE_OK"; then
    ok "node"
else
    bad "node"
fi

if "$RUNNER" "pwd" | grep -q "$WORK"; then
    ok "pwd"
else
    bad "pwd"
fi

if "$RUNNER" "ls __TERMINAL_TEST__" | grep -q "test.txt"; then
    ok "ls"
else
    bad "ls"
fi

if "$RUNNER" "cd /tmp" >/dev/null 2>&1; then
    ok "cd command"
else
    bad "cd command"
fi

if "$RUNNER" "printf 'SECURITY_TEST'" >/dev/null 2>&1; then
    ok "workspace execution"
else
    bad "workspace execution"
fi

if bash -n "$ROOT/core/runtime/process-engine.sh" &&
   bash -n "$ROOT/core/terminal/runner.sh" &&
   bash -n "$ROOT/core/terminal/terminal-engine.sh"; then
    ok "bash syntax"
else
    bad "bash syntax"
fi

rm -rf "$TEST"

echo
echo "TERMINAL TESTS: PASS=$PASS FAIL=$FAIL"

if [ "$FAIL" -eq 0 ]; then
    echo "SCHAGLK TERMINAL CORE: PASS"
    exit 0
else
    echo "SCHAGLK TERMINAL CORE: FAIL"
    exit 1
fi
