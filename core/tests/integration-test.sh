#!/data/data/com.termux/files/usr/bin/bash

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
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

echo "============================================================"
echo " SCHAGLK — MEGA FUSION #3 INTEGRATION TEST"
echo "============================================================"

check_file() {
  if [ -f "$ROOT/$1" ]; then
    pass "$2"
  else
    fail "$2"
  fi
}

check_file "core/integration/integration-engine.sh" "integration engine"
check_file "core/integration/integration-contract.json" "integration contract"

if bash "$ROOT/core/integration/integration-engine.sh" status >/dev/null 2>&1; then
  pass "integration runtime"
else
  fail "integration runtime"
fi

if bash "$ROOT/core/terminal/terminal-test.sh" >/dev/null 2>&1; then
  pass "terminal"
else
  fail "terminal"
fi

if bash "$ROOT/core/tests/git-test.sh" >/dev/null 2>&1; then
  pass "git/github"
else
  fail "git/github"
fi

if bash "$ROOT/core/diagnostics/run.sh" >/dev/null 2>&1; then
  pass "diagnostics"
else
  fail "diagnostics"
fi

if bash "$ROOT/core/ai/ai-orchestrator.sh" status >/dev/null 2>&1; then
  pass "AI"
else
  fail "AI"
fi

if [ -f "$ROOT/core/live/live-engine.js" ]; then
  pass "LIVE"
else
  fail "LIVE"
fi

if bash "$ROOT/core/build/build-router.sh" web >/dev/null 2>&1; then
  pass "build router"
else
  fail "build router"
fi

check_file "core/factory/project-factory.sh" "project factory"
check_file "core/projects/project-manager.sh" "project manager"
check_file "core/devices/device-manager.sh" "device manager"
check_file "core/plugins/plugin-manager.sh" "plugin manager"

if bash -n "$ROOT/core/integration/integration-engine.sh"; then
  pass "integration syntax"
else
  fail "integration syntax"
fi

echo
echo "INTEGRATION TEST: PASS=$PASS FAIL=$FAIL"

if [ "$FAIL" -eq 0 ]; then
  echo "SCHAGLK MEGA-FUSION #3: PASS"
  exit 0
else
  echo "SCHAGLK MEGA-FUSION #3: FAIL"
  exit 1
fi
