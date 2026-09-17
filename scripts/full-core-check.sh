#!/data/data/com.termux/files/usr/bin/bash
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export SCHAGLK_ROOT="$ROOT"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
FAIL=0

echo "=========================================="
echo "       SCHAGLK FULL CORE CHECK"
echo "       NO APK COMPILATION"
echo "=========================================="

run(){
  echo
  echo ">>> $*"
  if "$@"; then
    echo "[PASS]"
  else
    echo "[FAIL]"
    FAIL=1
  fi
}

run "$ROOT/core/tests/run-tests.sh"
run "$ROOT/core/tests/project-test.sh"
run "$ROOT/core/diagnostics/run.sh"

echo
echo "=== SHELL SYNTAX ==="
bash -n "$ROOT/core/terminal/shell-engine.sh" && echo "[PASS] shell"

echo
echo "=== PROJECT TYPES ==="
for t in web python cpp; do
  n="__CHECK_${t}__"
  rm -rf "$ROOT/projects/$n"
  if "$ROOT/core/projects/create-project.sh" "$n" "$t" >/dev/null 2>&1; then
    echo "[PASS] $t"
  else
    echo "[FAIL] $t"
    FAIL=1
  fi
  rm -rf "$ROOT/projects/$n"
done

echo
echo "=== DEPENDENCY ENGINE ==="
rm -rf "$ROOT/projects/__DEP_CHECK__"
mkdir -p "$ROOT/projects/__DEP_CHECK__"
"$ROOT/core/dependencies/manager.sh" init "$ROOT/projects/__DEP_CHECK__"
"$ROOT/core/dependencies/manager.sh" add "$ROOT/projects/__DEP_CHECK__" "example-package"
"$ROOT/core/dependencies/manager.sh" list "$ROOT/projects/__DEP_CHECK__"
rm -rf "$ROOT/projects/__DEP_CHECK__"

echo
echo "=== BUILDERS PRESENT ==="
for f in \
 core/build/android-build.sh \
 core/build/web-build.sh \
 core/build/native-build.sh \
 core/build/python-test.sh; do
  test -x "$ROOT/$f" && echo "[PASS] $f" || { echo "[FAIL] $f"; FAIL=1; }
done

echo
echo "=== AI CONTRACT ==="
test -s "$ROOT/core/ai/tool-contract.json" && echo "[PASS] AI tools contract" || { echo "[FAIL] AI contract"; FAIL=1; }

echo
echo "=== GITHUB ENGINE ==="
test -x "$ROOT/core/github/github-engine.sh" && echo "[PASS] GitHub engine" || { echo "[FAIL] GitHub engine"; FAIL=1; }

echo
echo "=== COMPILATION ==="
echo "SKIPPED — conformément au plan."
echo

if [ "$FAIL" -eq 0 ]; then
  echo "=========================================="
  echo " SCHAGLK CORE EXPANSION: ALL CHECKS PASS "
  echo "=========================================="
else
  echo "=========================================="
  echo " SCHAGLK CORE EXPANSION: FAILURES FOUND "
  echo "=========================================="
  exit 1
fi
