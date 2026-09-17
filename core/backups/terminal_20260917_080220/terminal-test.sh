#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(pwd)}"
export SCHAGLK_ROOT="$ROOT"

TEST="$ROOT/workspace/__TERMINAL_TEST__"

rm -rf "$TEST"
mkdir -p "$TEST"

PASS=0
FAIL=0

pass(){
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

fail(){
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}

"$ROOT/core/terminal/runner.sh" \
    "mkdir -p workspace/__TERMINAL_TEST__/nested" \
    >/dev/null 2>&1 && pass "mkdir" || fail "mkdir"

"$ROOT/core/terminal/runner.sh" \
    "printf 'SCHAGLK TERMINAL OK\n' > workspace/__TERMINAL_TEST__/test.txt" \
    >/dev/null 2>&1 && pass "process execution" || fail "process execution"

if grep -q "SCHAGLK TERMINAL OK" \
   "$TEST/test.txt"; then
    pass "file output"
else
    fail "file output"
fi

"$ROOT/core/terminal/runner.sh" \
    "python -c 'print(12345)'" \
    >/dev/null 2>&1 && pass "python execution" || fail "python execution"

if "$ROOT/core/terminal/runner.sh" \
   "pwd" >/dev/null 2>&1; then
    pass "pwd"
else
    fail "pwd"
fi

if "$ROOT/core/terminal/runner.sh" \
   "ls workspace/__TERMINAL_TEST__" >/dev/null 2>&1; then
    pass "ls"
else
    fail "ls"
fi

rm -rf "$TEST"

echo
echo "TERMINAL TESTS: PASS=$PASS FAIL=$FAIL"

[ "$FAIL" -eq 0 ]
