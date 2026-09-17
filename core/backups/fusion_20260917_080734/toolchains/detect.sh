#!/data/data/com.termux/files/usr/bin/bash
set -u

echo "=== SCHAGLK TOOLCHAINS ==="

check() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "[AVAILABLE] $1 -> $(command -v "$1")"
    else
        echo "[MISSING]   $1"
    fi
}

for x in \
    java javac gradle \
    python node npm \
    clang clang++ gcc g++ \
    cmake make \
    git adb \
    curl wget \
    zip unzip tar
do
    check "$x"
done

echo
echo "=== ANDROID SDK ==="

SDK="${ANDROID_HOME:-$HOME/android-sdk}"

if [ -d "$SDK" ]; then
    echo "[SDK] $SDK"

    echo "--- platforms ---"
    find "$SDK/platforms" \
        -maxdepth 1 \
        -mindepth 1 \
        -type d \
        -printf '%f\n' 2>/dev/null | sort

    echo "--- build-tools ---"
    find "$SDK/build-tools" \
        -maxdepth 1 \
        -mindepth 1 \
        -type d \
        -printf '%f\n' 2>/dev/null | sort

    if [ -x "$SDK/build-tools/34.0.0/aapt2" ]; then
        echo "[AVAILABLE] aapt2"
    else
        echo "[MISSING] aapt2"
    fi

    if [ -x "$SDK/build-tools/34.0.0/apksigner" ]; then
        echo "[AVAILABLE] apksigner"
    else
        echo "[MISSING] apksigner"
    fi

else
    echo "[MISSING] Android SDK"
fi
