#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
export SCHAGLK_ROOT="$ROOT"

PASS=0
FAIL=0

run(){
    local name="$1"
    shift
    echo
    echo ">>> CI: $name"
    if "$@"; then
        echo "[PASS] $name"
        PASS=$((PASS+1))
    else
        echo "[FAIL] $name"
        FAIL=$((FAIL+1))
    fi
}

run "Terminal" "$ROOT/core/tests/terminal-test.sh"
run "Git/GitHub" "$ROOT/core/tests/git-test.sh"
run "Diagnostics" "$ROOT/core/diagnostics/fusion-check.sh"

echo
echo "CI RESULT: PASS=$PASS FAIL=$FAIL"

[ "$FAIL" -eq 0 ]
