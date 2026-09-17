#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export SCHAGLK_ROOT="$ROOT"

FAIL=0

pass(){ echo "[PASS] $*"; }
fail(){ echo "[FAIL] $*"; FAIL=1; }

echo "=========================================="
echo " SCHAGLK NEXT CORE CHECK"
echo " APK BUILD: DISABLED"
echo "=========================================="

for f in \
 core/orchestrator/schaglk.sh \
 core/projects/project-manager.sh \
 core/plugins/plugin-manager.sh \
 core/ai/ai-tools.sh \
 core/build/build-router.sh \
 core/diagnostics/project-scan.sh \
 core/devices/device-manager.sh
do
  if test -x "$ROOT/$f"; then
    pass "$f"
  else
    fail "$f"
  fi
done

echo
echo "=== SHELL SYNTAX ==="

for f in \
 core/orchestrator/schaglk.sh \
 core/projects/project-manager.sh \
 core/plugins/plugin-manager.sh \
 core/ai/ai-tools.sh \
 core/build/build-router.sh \
 core/diagnostics/project-scan.sh \
 core/devices/device-manager.sh
do
  if bash -n "$ROOT/$f"; then
    pass "syntax $f"
  else
    fail "syntax $f"
  fi
done

echo
echo "=== PROJECT MANAGER ==="

rm -rf "$ROOT/projects/__NEXT_CHECK__"

if "$ROOT/core/projects/project-manager.sh" create __NEXT_CHECK__ web >/dev/null 2>&1; then
  pass "create project"
else
  fail "create project"
fi

if "$ROOT/core/projects/project-manager.sh" files __NEXT_CHECK__ >/dev/null 2>&1; then
  pass "project files"
else
  fail "project files"
fi

echo
echo "=== BUILD ROUTER ==="

if "$ROOT/core/build/build-router.sh" "$ROOT/projects/__NEXT_CHECK__" >/dev/null 2>&1; then
  pass "web build router"
else
  fail "web build router"
fi

echo
echo "=== DIAGNOSTICS ==="

if "$ROOT/core/diagnostics/project-scan.sh" \
   "$ROOT/projects/__NEXT_CHECK__" >/dev/null 2>&1; then
  pass "project diagnostics"
else
  fail "project diagnostics"
fi

echo
echo "=== PLUGIN SYSTEM ==="

rm -rf "$ROOT/core/plugins/__TEST_PLUGIN__"

if "$ROOT/core/plugins/plugin-manager.sh" install \
   __TEST_PLUGIN__ formatter >/dev/null 2>&1 &&
   test -f "$ROOT/core/plugins/__TEST_PLUGIN__/plugin.json"
then
  pass "plugin registration"
else
  fail "plugin registration"
fi

rm -rf "$ROOT/core/plugins/__TEST_PLUGIN__"
rm -rf "$ROOT/projects/__NEXT_CHECK__"

echo
echo "=== AI TOOL CONTRACT ==="

if "$ROOT/core/ai/ai-tools.sh" status >/dev/null 2>&1; then
  pass "AI tools"
else
  fail "AI tools"
fi

echo
echo "=== ANDROID ==="
echo "Compilation intentionally skipped."

echo

if [ "$FAIL" -eq 0 ]; then
  echo "=========================================="
  echo " SCHAGLK NEXT CORE: ALL CHECKS PASS"
  echo "=========================================="
else
  echo "=========================================="
  echo " SCHAGLK NEXT CORE: FAILURES"
  echo "=========================================="
  exit 1
fi
