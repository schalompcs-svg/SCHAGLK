#!/data/data/com.termux/files/usr/bin/bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FAIL=0

check() {
    if [ -e "$1" ]; then
        echo "[OK] $2"
    else
        echo "[FAIL] $2"
        FAIL=1
    fi
}

check "$ROOT/app/src/main/java/com/schaglk/studio/MainActivity.java" "Application source"
check "$ROOT/app/src/main/AndroidManifest.xml" "Manifest"
check "$ROOT/app/build.gradle" "Android build"
check "$ROOT/core/terminal/commands.sh" "Terminal"
check "$ROOT/core/ai" "AI module"
check "$ROOT/core/build" "Build system"
check "$ROOT/core/git" "Git module"
check "$ROOT/core/toolchains" "Toolchains"
check "$ROOT/core/tests" "Tests"

if [ "$FAIL" -eq 0 ]; then
    echo "SCHAGLK CORE TESTS: PASS"
else
    echo "SCHAGLK CORE TESTS: FAIL"
    exit 1
fi
