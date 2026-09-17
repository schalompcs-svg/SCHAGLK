#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
export SCHAGLK_ROOT="$ROOT"

TEST="$ROOT/workspace/__TERMINAL_TEST__"

rm -rf "$TEST"
mkdir -p "$TEST"

PASS=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}

run_test() {
    local name="$1"
    shift

    if "$@" >/dev/null 2>&1; then
        pass "$name"
    else
        fail "$name"
    fi
}

run_test \
    "mkdir" \
    "$ROOT/core/terminal/runner.sh" \
    "mkdir -p __TERMINAL_TEST__/nested"

if [ -d "$TEST/nested" ]; then
    pass "directory created"
else
    fail "directory created"
fi

run_test \
    "process execution" \
    "$ROOT/core/terminal/runner.sh" \
    "printf 'SCHAGLK TERMINAL OK\n' > __TERMINAL_TEST__/test.txt"

if grep -q "SCHAGLK TERMINAL OK" "$TEST/test.txt"; then
    pass "file output"
else
    fail "file output"
fi

run_test \
    "python execution" \
    "$ROOT/core/terminal/runner.sh" \
    "python -c 'print(12345)'"

run_test \
    "node execution" \
    "$ROOT/core/terminal/runner.sh" \
    "node -e 'console.log(12345)'"

run_test \
    "pwd" \
    "$ROOT/core/terminal/runner.sh" \
    "pwd"

run_test \
    "ls" \
    "$ROOT/core/terminal/runner.sh" \
    "ls __TERMINAL_TEST__"

if "$ROOT/core/runtime/process-engine.sh" inside "$TEST" >/dev/null 2>&1; then
    pass "workspace security"
else
    fail "workspace security"
fi

OUTSIDE="$ROOT/../SCHAGLK_OUTSIDE_TEST"

if "$ROOT/core/runtime/process-engine.sh" inside "$OUTSIDE" >/dev/null 2>&1; then
    fail "outside workspace blocked"
else
    pass "outside workspace blocked"
fi

if "$ROOT/core/terminal/runner.sh" \
   "cat /etc/passwd" >/dev/null 2>&1; then
    echo "[INFO] absolute process command allowed by shell semantics"
else
    echo "[INFO] absolute command returned non-zero"
fi

rm -rf "$TEST"

echo
echo "============================================================"
echo "TERMINAL TESTS: PASS=$PASS FAIL=$FAIL"
echo "============================================================"

[ "$FAIL" -eq 0 ]
