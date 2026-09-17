#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PASS=0
FAIL=0
TMP="$ROOT/core/tests/.terminal-test-tmp"

pass(){ echo "[PASS] $1"; PASS=$((PASS+1)); }
fail(){ echo "[FAIL] $1"; FAIL=$((FAIL+1)); }

rm -rf "$TMP"
mkdir -p "$TMP"

echo "=== SCHAGLK TERMINAL TEST ==="

if [ -f "$ROOT/core/terminal/terminal-engine.sh" ]; then
    pass "terminal-engine"
else
    fail "terminal-engine"
fi

if [ -f "$ROOT/core/terminal/runner.sh" ]; then
    pass "runner"
else
    fail "runner"
fi

if bash -n "$ROOT/core/terminal/terminal-engine.sh" 2>/dev/null; then
    pass "terminal-engine syntax"
else
    fail "terminal-engine syntax"
fi

if bash -n "$ROOT/core/terminal/runner.sh" 2>/dev/null; then
    pass "runner syntax"
else
    fail "runner syntax"
fi

if printf 'echo SCHAGLK_TERMINAL_OK\n' | bash "$ROOT/core/terminal/terminal-engine.sh" >/dev/null 2>&1; then
    pass "terminal execution"
else
    fail "terminal execution"
fi

if bash "$ROOT/core/terminal/terminal-engine.sh" pwd >/dev/null 2>&1; then
    pass "terminal pwd"
else
    fail "terminal pwd"
fi

if bash "$ROOT/core/terminal/terminal-engine.sh" ls >/dev/null 2>&1; then
    pass "terminal ls"
else
    fail "terminal ls"
fi

if bash "$ROOT/core/terminal/terminal-engine.sh" 'mkdir -p .terminal-test-tmp/testdir' >/dev/null 2>&1; then
    pass "terminal mkdir"
else
    fail "terminal mkdir"
fi

if bash "$ROOT/core/terminal/terminal-engine.sh" 'echo TEST > .terminal-test-tmp/testdir/test.txt' >/dev/null 2>&1; then
    pass "terminal file write"
else
    fail "terminal file write"
fi

if find "$ROOT" -type f -path "*/.terminal-test-tmp/testdir/test.txt" -print -quit 2>/dev/null | grep -q .; then
    pass "terminal filesystem"
else
    fail "terminal filesystem"
fi

if bash "$ROOT/core/terminal/terminal-engine.sh" 'python -c "print(123)"' >/dev/null 2>&1; then
    pass "terminal python"
else
    fail "terminal python"
fi

if bash "$ROOT/core/terminal/terminal-engine.sh" 'node -e "console.log(123)"' >/dev/null 2>&1; then
    pass "terminal node"
else
    fail "terminal node"
fi

rm -rf "$TMP"

echo
echo "TERMINAL TESTS: PASS=$PASS FAIL=$FAIL"

if [ "$FAIL" -eq 0 ]; then
    echo "SCHAGLK TERMINAL CORE: PASS"
    exit 0
else
    echo "SCHAGLK TERMINAL CORE: FAIL"
    exit 1
fi
