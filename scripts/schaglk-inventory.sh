#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export SCHAGLK_ROOT="$ROOT"

echo "============================================================"
echo "             SCHAGLK — INVENTAIRE RÉEL"
echo "============================================================"

check(){
    local label="$1"
    local result="$2"

    if [ "$result" = "1" ]; then
        printf "[READY]       %-30s\n" "$label"
    elif [ "$result" = "2" ]; then
        printf "[PARTIAL]     %-30s\n" "$label"
    else
        printf "[NOT READY]   %-30s\n" "$label"
    fi
}

[ -x "$ROOT/core/terminal/runner.sh" ] && check "Terminal" 1 || check "Terminal" 0
[ -x "$ROOT/core/ai/ai-orchestrator.sh" ] && check "AI orchestrator" 2 || check "AI orchestrator" 0
[ -f "$ROOT/core/ai/engine-contract.json" ] && check "AI contract" 1 || check "AI contract" 0
[ -x "$ROOT/core/factory/project-factory.sh" ] && check "Project factory" 1 || check "Project factory" 0
[ -x "$ROOT/core/live/live-engine.js" ] && check "LIVE engine" 1 || check "LIVE engine" 0
[ -x "$ROOT/core/toolchains/inventory.sh" ] && check "Toolchain detection" 1 || check "Toolchain detection" 0
[ -x "$ROOT/core/git/git-engine.sh" ] && check "Git" 1 || check "Git" 0
[ -x "$ROOT/core/github/github-engine.sh" ] && check "GitHub interface" 2 || check "GitHub interface" 0
[ -x "$ROOT/core/ci/local-ci.sh" ] && check "Local CI" 1 || check "Local CI" 0
[ -x "$ROOT/core/tests/mega-fusion-test.sh" ] && check "Mega tests" 1 || check "Mega tests" 0

[ -d "$ANDROID_HOME/platforms/android-34" ] && check "Android SDK" 1 || check "Android SDK" 0
[ -d "$ANDROID_HOME/build-tools/34.0.0" ] && check "Android Build Tools" 1 || check "Android Build Tools" 0
command -v adb >/dev/null 2>&1 && check "ADB" 1 || check "ADB" 0
command -v clang >/dev/null 2>&1 && check "C/C++" 1 || check "C/C++" 0
command -v cmake >/dev/null 2>&1 && check "CMake" 1 || check "CMake" 0
command -v python >/dev/null 2>&1 && check "Python" 1 || check "Python" 0
command -v node >/dev/null 2>&1 && check "Node.js" 1 || check "Node.js" 0
command -v java >/dev/null 2>&1 && check "Java" 1 || check "Java" 0
command -v gradle >/dev/null 2>&1 && check "Gradle" 2 || check "Gradle" 0

echo
echo "TARGETS"
echo "  Web/API             -> project factory + runtime test"
echo "  Python              -> generation + runtime test"
echo "  C/C++               -> compiler/runtime test"
echo "  Android             -> generation + SDK detection (BUILD BLOCKED)"
echo "  Game 2D             -> prototype generation/runtime"
echo "  Game 3D             -> prototype generation/runtime"
echo "  PC                  -> CMake generation/build/runtime"
echo "  LIVE                -> HTML inspection"
echo "  IA                  -> orchestrator + project analysis"
echo "  Git/GitHub          -> repository interface"
echo "  CI                  -> local automated validation"

echo
echo "============================================================"
echo "IMPORTANT"
echo "============================================================"
echo "A READY label means the implemented/tested layer works."
echo "A PARTIAL label means integration exists but is not a full AI provider,"
echo "production engine, or remote GitHub service."
echo "APK_BUILD=SKIPPED"
echo "SAMSUNG_REAL_DEVICE_TEST=NOT_RUN"
