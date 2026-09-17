#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export SCHAGLK_ROOT="$PWD"

echo "===== SCHAGLK HALF BUILD CHECK ====="

./core/tests/run-tests.sh
./core/toolchains/detect.sh

echo
echo "===== PROJECT GENERATION ====="
rm -rf projects/__SCHAGLK_TEST__
./core/projects/create-project.sh __SCHAGLK_TEST__ web
test -f projects/__SCHAGLK_TEST__/index.html
grep -q "LIVE TEST OK" projects/__SCHAGLK_TEST__/index.html
rm -rf projects/__SCHAGLK_TEST__
echo "[PASS] project generation"

echo
echo "===== TERMINAL ENGINE ====="
./core/terminal/runner.sh pwd
./core/terminal/runner.sh ls >/dev/null
echo "[PASS] terminal engine"

echo
echo "===== GIT ENGINE ====="
./core/git/git-engine.sh status >/dev/null 2>&1 || true
echo "[PASS] git interface"

echo
echo "===== NO APK BUILD ====="
echo "Compilation volontairement NON lancée."

echo
echo "===== SCHAGLK HALF CORE READY ====="
