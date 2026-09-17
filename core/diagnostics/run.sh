#!/data/data/com.termux/files/usr/bin/bash
set -u
ROOT="${SCHAGLK_ROOT:-$(pwd)}"
echo "=== SCHAGLK DIAGNOSTICS ==="
echo "[INFO] ROOT=$ROOT"
echo "[INFO] JAVA=$(command -v java || true)"
echo "[INFO] PYTHON=$(command -v python || true)"
echo "[INFO] NODE=$(command -v node || true)"
echo "[INFO] CLANG=$(command -v clang || true)"
echo "[INFO] GIT=$(command -v git || true)"
echo "[INFO] GRADLE=$(command -v gradle || true)"
echo "[INFO] ADB=$(command -v adb || true)"
echo "[INFO] ANDROID_HOME=${ANDROID_HOME:-unset}"
echo "[INFO] SDK platforms:"
find "${ANDROID_HOME:-$HOME/android-sdk}/platforms" -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true
echo "[INFO] SDK build-tools:"
find "${ANDROID_HOME:-$HOME/android-sdk}/build-tools" -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true
