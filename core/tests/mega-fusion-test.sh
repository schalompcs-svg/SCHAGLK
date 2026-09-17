#!/usr/bin/env bash

SCHAGLK_TEST_TMP="${SCHAGLK_TEST_TMP:-$PWD/core/tests/.tmp}"
mkdir -p "$SCHAGLK_TEST_TMP"

set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
export SCHAGLK_ROOT="$ROOT"

PASS=0
FAIL=0

ok(){ echo "[PASS] $1"; PASS=$((PASS+1)); }
bad(){ echo "[FAIL] $1"; FAIL=$((FAIL+1)); }

run(){
    NAME="$1"
    shift
    if "$@"; then ok "$NAME"; else bad "$NAME"; fi
}

echo "============================================================"
echo "        SCHAGLK — MEGA FUSION FUNCTIONAL TEST"
echo "============================================================"

# ------------------------------------------------------------
# FACTORY
# ------------------------------------------------------------

rm -rf "$ROOT/projects/generated/mega_test"

for TYPE in web api python android game2d game3d pc native; do
    if "$ROOT/core/factory/project-factory.sh" "$TYPE" "mega_test_$TYPE" >/dev/null 2>&1; then
        [ -f "$ROOT/projects/generated/mega_test_$TYPE/schaglk-project.json" ] \
            && ok "factory $TYPE" \
            || bad "factory $TYPE files"
    else
        bad "factory $TYPE"
    fi
done

# ------------------------------------------------------------
# WEB
# ------------------------------------------------------------

WEB="$ROOT/projects/generated/mega_test_web"

if [ -f "$WEB/index.html" ] &&
   grep -q "SCHAGLK WEB" "$WEB/index.html"; then
    ok "web generation"
else
    bad "web generation"
fi

# ------------------------------------------------------------
# API
# ------------------------------------------------------------

API="$ROOT/projects/generated/mega_test_api"

if mkdir -p "$SCHAGLK_TEST_TMP"
python "$API/server.py" >"$SCHAGLK_TEST_TMP/api.log" 2>&1 &
then
    API_PID=$!
    sleep 1

    if python - <<'PY'
import urllib.request,json
r=urllib.request.urlopen("http://127.0.0.1:8765",timeout=3)
data=json.loads(r.read())
assert data["status"]=="ok"
print("API_OK")
PY
    then
        ok "API runtime"
    else
        bad "API runtime"
    fi

    kill "$API_PID" 2>/dev/null || true
    wait "$API_PID" 2>/dev/null || true
else
    bad "API launch"
fi

# ------------------------------------------------------------
# PYTHON
# ------------------------------------------------------------

if python "$ROOT/projects/generated/mega_test_python/main.py" |
   grep -q "PYTHON PROJECT READY"; then
    ok "python runtime"
else
    bad "python runtime"
fi

# ------------------------------------------------------------
# NATIVE C
# ------------------------------------------------------------

NATIVE="$ROOT/projects/generated/mega_test_native"
if clang "$NATIVE/src/main.c" -o "$NATIVE/native_test" >/dev/null 2>&1 &&
   "$NATIVE/native_test" | grep -q "NATIVE PROJECT READY"; then
    ok "native C compile/runtime"
else
    bad "native C compile/runtime"
fi

# ------------------------------------------------------------
# PC C++
# ------------------------------------------------------------

PC="$ROOT/projects/generated/mega_test_pc"
if cmake -S "$PC" -B "$PC/build" >/dev/null 2>&1 &&
   cmake --build "$PC/build" >/dev/null 2>&1 &&
   "$PC/build/schaglk_pc" | grep -q "PC PROJECT READY"; then
    ok "PC C++ compile/runtime"
else
    bad "PC C++ compile/runtime"
fi

# ------------------------------------------------------------
# GAME 2D
# ------------------------------------------------------------

if node "$ROOT/projects/generated/mega_test_game2d/src/main.js" |
   grep -q "GAME 2D READY"; then
    ok "game 2D runtime"
else
    bad "game 2D runtime"
fi

# ------------------------------------------------------------
# GAME 3D
# ------------------------------------------------------------

if node "$ROOT/projects/generated/mega_test_game3d/src/main.js" |
   grep -q "GAME 3D SCENE READY"; then
    ok "game 3D runtime"
else
    bad "game 3D runtime"
fi

# ------------------------------------------------------------
# ANDROID — STRUCTURE ONLY
# ------------------------------------------------------------

ANDROID="$ROOT/projects/generated/mega_test_android"

if [ -f "$ANDROID/settings.gradle" ] &&
   [ -f "$ANDROID/app/build.gradle" ] &&
   [ -f "$ANDROID/app/src/main/AndroidManifest.xml" ] &&
   [ -f "$ANDROID/app/src/main/java/com/schaglk/generated/MainActivity.java" ]; then
    ok "Android project generation"
else
    bad "Android project generation"
fi

# ------------------------------------------------------------
# LIVE
# ------------------------------------------------------------

if node "$ROOT/core/live/live-engine.js" "$WEB/index.html" |
   grep -q '"interactive": true'; then
    ok "LIVE inspection"
else
    bad "LIVE inspection"
fi

# ------------------------------------------------------------
# AI
# ------------------------------------------------------------

if "$ROOT/core/ai/ai-orchestrator.sh" status |
   grep -q "AI_ORCHESTRATOR=READY"; then
    ok "AI orchestrator"
else
    bad "AI orchestrator"
fi

if "$ROOT/core/ai/ai-orchestrator.sh" analyze "$WEB" |
   grep -q "index.html"; then
    ok "AI project analysis"
else
    bad "AI project analysis"
fi

# ------------------------------------------------------------
# BUILD ROUTER
# ------------------------------------------------------------

for TYPE in web python native android game2d game3d pc; do
    if "$ROOT/core/build/build-router.sh" "$TYPE" >/dev/null 2>&1; then
        ok "build router $TYPE"
    else
        bad "build router $TYPE"
    fi
done

# ------------------------------------------------------------
# CI
# ------------------------------------------------------------

if "$ROOT/core/ci/local-ci.sh" >"$SCHAGLK_TEST_TMP/ci.log" 2>&1; then
    ok "local CI"
else
    bad "local CI"
    tail -50 "$SCHAGLK_TEST_TMP/ci.log"
fi

rm -rf \
"$ROOT/projects/generated/mega_test_web" \
"$ROOT/projects/generated/mega_test_api" \
"$ROOT/projects/generated/mega_test_python" \
"$ROOT/projects/generated/mega_test_android" \
"$ROOT/projects/generated/mega_test_game2d" \
"$ROOT/projects/generated/mega_test_game3d" \
"$ROOT/projects/generated/mega_test_pc" \
"$ROOT/projects/generated/mega_test_native"

echo
echo "============================================================"
echo "MEGA FUSION TEST RESULT"
echo "PASS=$PASS"
echo "FAIL=$FAIL"
echo "============================================================"

[ "$FAIL" -eq 0 ]
