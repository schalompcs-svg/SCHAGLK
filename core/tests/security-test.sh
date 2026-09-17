#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
export SCHAGLK_ROOT="$ROOT"

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

WORK="$ROOT/workspace"
OUTSIDE="$ROOT/../SCHAGLK_SECURITY_OUTSIDE"

mkdir -p "$WORK"

if "$ROOT/core/runtime/process-engine.sh" inside "$WORK" >/dev/null 2>&1; then
    pass "workspace accepted"
else
    fail "workspace accepted"
fi

if "$ROOT/core/runtime/process-engine.sh" inside "$WORK/test" >/dev/null 2>&1; then
    pass "workspace child accepted"
else
    fail "workspace child accepted"
fi

if "$ROOT/core/runtime/process-engine.sh" inside "$OUTSIDE" >/dev/null 2>&1; then
    fail "outside rejected"
else
    pass "outside rejected"
fi

if "$ROOT/core/runtime/process-engine.sh" inside "/" >/dev/null 2>&1; then
    fail "root rejected"
else
    pass "root rejected"
fi

echo
echo "SECURITY TESTS: PASS=$PASS FAIL=$FAIL"

[ "$FAIL" -eq 0 ]
