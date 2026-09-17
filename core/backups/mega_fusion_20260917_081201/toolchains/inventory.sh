#!/usr/bin/env bash
set -u

echo "=== SCHAGLK TOOLCHAIN INVENTORY ==="

check() {
    local name="$1"
    local cmd="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "[AVAILABLE] $name -> $(command -v "$cmd")"
    else
        echo "[MISSING] $name"
    fi
}

check "Java" java
check "Javac" javac
check "Python" python
check "Node" node
check "Clang" clang
check "CMake" cmake
check "Make" make
check "Git" git
check "Gradle" gradle
check "ADB" adb

if [ -d "${ANDROID_HOME:-$HOME/android-sdk}" ]; then
    echo "[AVAILABLE] Android SDK -> ${ANDROID_HOME:-$HOME/android-sdk}"
else
    echo "[MISSING] Android SDK"
fi

echo
echo "TARGETS"
echo "[READY] Web"
echo "[READY] Python"
echo "[READY] Native C/C++"
echo "[INTEGRATION] Android"
echo "[INTEGRATION] Game 2D"
echo "[INTEGRATION] Game 3D"
echo "[INTEGRATION] PC"
