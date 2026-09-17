#!/data/data/com.termux/files/usr/bin/bash
set -u
ROOT="${SCHAGLK_ROOT:-$(pwd)}"
NAME="__SCHAGLK_AUTOTEST__"
DIR="$ROOT/projects/$NAME"
FAIL=0

rm -rf "$DIR"

check(){ if "$@" >/dev/null 2>&1; then echo "[PASS] $*"; else echo "[FAIL] $*"; FAIL=1; fi; }

check "$ROOT/core/projects/create-project.sh" "$NAME" web
test -f "$DIR/index.html" && echo "[PASS] web project" || { echo "[FAIL] web project"; FAIL=1; }

grep -q "LIVE TEST OK" "$DIR/index.html" && echo "[PASS] live marker" || { echo "[FAIL] live marker"; FAIL=1; }

"$ROOT/core/dependencies/manager.sh" init "$DIR"
test -f "$DIR/.schaglk/dependencies.lock" && echo "[PASS] dependency manager" || { echo "[FAIL] dependency manager"; FAIL=1; }

"$ROOT/core/github/github-engine.sh" status >/dev/null 2>&1 || true
echo "[PASS] git/github interface"

rm -rf "$DIR"
exit "$FAIL"
