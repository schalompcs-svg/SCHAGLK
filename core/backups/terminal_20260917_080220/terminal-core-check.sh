#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export SCHAGLK_ROOT="$ROOT"

FAIL=0

echo "=========================================="
echo " SCHAGLK TERMINAL CORE CHECK"
echo " APK BUILD: DISABLED"
echo "=========================================="

for f in \
 core/runtime/process-engine.sh \
 core/terminal/terminal-engine.sh \
 core/terminal/runner.sh \
 core/tests/terminal-test.sh
do
    if test -x "$ROOT/$f"; then
        echo "[PASS] $f"
    else
        echo "[FAIL] $f"
        FAIL=1
    fi
done

echo
echo "=== SHELL SYNTAX ==="

for f in \
 core/runtime/process-engine.sh \
 core/terminal/terminal-engine.sh \
 core/terminal/runner.sh \
 core/tests/terminal-test.sh
do
    if bash -n "$ROOT/$f"; then
        echo "[PASS] syntax $f"
    else
        echo "[FAIL] syntax $f"
        FAIL=1
    fi
done

echo
echo "=== TERMINAL FUNCTIONAL TEST ==="

if "$ROOT/core/tests/terminal-test.sh"; then
    echo "[PASS] terminal functional tests"
else
    echo "[FAIL] terminal functional tests"
    FAIL=1
fi

echo
echo "=== SECURITY TEST ==="

OUT="$("$ROOT/core/runtime/process-engine.sh" inside "$ROOT/workspace/test.txt")"

if [ "$OUT" = "[YES]" ]; then
    echo "[PASS] workspace path"
else
    echo "[FAIL] workspace path"
    FAIL=1
fi

OUT="$("$ROOT/core/runtime/process-engine.sh" inside "$HOME/test.txt")"

if [ "$OUT" = "[NO]" ]; then
    echo "[PASS] outside workspace blocked"
else
    echo "[FAIL] outside workspace blocked"
    FAIL=1
fi

echo
echo "=== APK ==="
echo "Compilation skipped."

echo

if [ "$FAIL" -eq 0 ]; then
    echo "=========================================="
    echo " SCHAGLK TERMINAL CORE: ALL CHECKS PASS"
    echo "=========================================="
else
    echo "=========================================="
    echo " SCHAGLK TERMINAL CORE: FAILURES"
    echo "=========================================="
    exit 1
fi
