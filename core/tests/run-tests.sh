#!/data/data/com.termux/files/usr/bin/bash
set -u
ROOT="${SCHAGLK_ROOT:-$(pwd)}"
PASS=0
FAIL=0

test_file(){
  if [ -e "$1" ]; then
    echo "[PASS] $2"
    PASS=$((PASS+1))
  else
    echo "[FAIL] $2"
    FAIL=$((FAIL+1))
  fi
}

test_exec(){
  if "$@" >/dev/null 2>&1; then
    echo "[PASS] $*"
    PASS=$((PASS+1))
  else
    echo "[FAIL] $*"
    FAIL=$((FAIL+1))
  fi
}

test_file "$ROOT/app/src/main/AndroidManifest.xml" "Android manifest"
test_file "$ROOT/app/src/main/java/com/schaglk/studio/MainActivity.java" "MainActivity"
test_file "$ROOT/core/terminal/runner.sh" "Terminal engine"
test_file "$ROOT/core/projects/create-project.sh" "Project engine"
test_file "$ROOT/core/files/FileEngine.java" "File engine"
test_file "$ROOT/core/live/live-engine.js" "LIVE engine"
test_file "$ROOT/core/git/git-engine.sh" "Git engine"
test_file "$ROOT/core/toolchains/detect.sh" "Toolchain detector"

test_exec bash -n "$ROOT/core/terminal/runner.sh"
test_exec bash -n "$ROOT/core/projects/create-project.sh"
test_exec bash -n "$ROOT/core/git/git-engine.sh"
test_exec bash -n "$ROOT/core/toolchains/detect.sh"

echo
echo "SCHAGLK TESTS: PASS=$PASS FAIL=$FAIL"

[ "$FAIL" -eq 0 ]
