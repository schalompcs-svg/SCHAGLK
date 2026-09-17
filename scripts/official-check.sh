#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "======================================"
echo "       SCHAGLK OFFICIAL CHECK"
echo "======================================"

./core/tests/test-core.sh
./core/toolchains/detect.sh

echo
echo "=== GRADLE ==="
gradle --version | head -12

echo
echo "=== ANDROID SDK ==="
echo "$ANDROID_HOME"

echo
echo "=== BUILD OFFICIEL ==="
./core/build/android-build.sh

APK=$(find app/build/outputs/apk/debug -type f -name '*.apk' | head -1)

echo
echo "=== APK ==="
ls -lh "$APK"

echo
echo "=== APK BADGING ==="
"$ANDROID_HOME/build-tools/34.0.0/aapt2" dump badging "$APK" | head -15

echo
echo "======================================"
echo " SCHAGLK OFFICIAL BUILD CHECK PASSED "
echo "======================================"
