#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

export SCHAGLK_ROOT="$ROOT"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

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

echo
echo "============================================================"
echo "          SCHAGLK PRE-BUILD COMPLETE CHECK"
echo "          APK BUILD : STRICTLY DISABLED"
echo "============================================================"

echo
echo "=== REQUIRED FILES ==="

FILES=(
    core/runtime/process-engine.sh
    core/terminal/terminal-engine.sh
    core/terminal/runner.sh
    core/terminal/terminal-config.json
    core/tests/terminal-test.sh
    core/tests/security-test.sh
    core/diagnostics/project-scan.sh
    core/toolchains/detect.sh
    core/ai/engine-spec.json
    core/ai/tool-contract.json
    core/ai/config.json
    core/live/live-engine.js
    core/github/github-engine.sh
    core/plugins/plugin-manager.sh
    core/projects/project-manager.sh
    core/build/build-router.sh
    core/devices/device-manager.sh
)

for f in "${FILES[@]}"; do
    if [ -f "$ROOT/$f" ]; then
        pass "$f"
    else
        fail "$f"
    fi
done

echo
echo "=== BASH SYNTAX ==="

while IFS= read -r -d '' f; do
    if bash -n "$f" >/dev/null 2>&1; then
        pass "syntax $f"
    else
        fail "syntax $f"
    fi
done < <(find "$ROOT/core" "$ROOT/scripts" -type f -name '*.sh' -print0)

echo
echo "=== JSON VALIDATION ==="

if command -v python >/dev/null 2>&1; then

    while IFS= read -r -d '' f; do

        if python - "$f" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    json.load(fh)
PY
        then
            pass "json $f"
        else
            fail "json $f"
        fi

    done < <(find "$ROOT/core" -type f -name '*.json' -print0)

else
    echo "[INFO] Python unavailable"
fi

echo
echo "=== TERMINAL TEST ==="

if "$ROOT/core/tests/terminal-test.sh"; then
    pass "terminal functional tests"
else
    fail "terminal functional tests"
fi

echo
echo "=== SECURITY TEST ==="

if "$ROOT/core/tests/security-test.sh"; then
    pass "security tests"
else
    fail "security tests"
fi

echo
echo "=== PROJECT ENGINE ==="

for type in web python cpp; do

    NAME="__PREBUILD_${type}_TEST__"

    rm -rf "$ROOT/projects/$NAME"

    if "$ROOT/core/projects/create-project.sh" "$NAME" "$type" >/dev/null 2>&1; then
        pass "project $type creation"
    else
        fail "project $type creation"
    fi

    rm -rf "$ROOT/projects/$NAME"

done

echo
echo "=== AI CONTRACT ==="

if python - "$ROOT/core/ai/engine-spec.json" <<'PY'
import json
import sys

p=json.load(open(sys.argv[1],encoding="utf-8"))

required=[
    "project-analysis",
    "multi-file-editing",
    "code-generation",
    "code-explanation",
    "error-diagnosis"
]

caps=p.get("capabilities",[])

missing=[x for x in required if x not in caps]

sys.exit(1 if missing else 0)
PY
then
    pass "AI specification"
else
    fail "AI specification"
fi

echo
echo "=== LIVE ENGINE ==="

if node - <<'NODE'
const e=require("./core/live/live-engine.js");
const x=e.executeHTML("<button>TEST</button>");
if(!x || x.type!=="html" || !x.interactive) process.exit(1);
console.log("[PASS] LIVE engine execution");
NODE
then
    pass "LIVE engine"
else
    fail "LIVE engine"
fi

echo
echo "=== GIT/GITHUB ==="

if git --version >/dev/null 2>&1; then
    pass "git available"
else
    fail "git available"
fi

if [ -x "$ROOT/core/github/github-engine.sh" ]; then
    pass "github engine present"
else
    fail "github engine present"
fi

echo
echo "=== DEVICES ==="

if adb version >/dev/null 2>&1; then
    pass "adb available"
else
    fail "adb available"
fi

echo
echo "=== TOOLCHAINS ==="

if "$ROOT/core/toolchains/detect.sh" >/dev/null 2>&1; then
    pass "toolchain detector"
else
    fail "toolchain detector"
fi

echo
echo "=== APK BUILD GUARD ==="

if grep -Rqs \
    'Compilation volontairement NON lancée\|APK compilation désactivée\|APK_BUILD.*false\|apkCompilation.*false' \
    "$ROOT/core" "$ROOT/scripts" 2>/dev/null; then
    pass "APK build remains disabled"
else
    echo "[INFO] APK guard marker not found everywhere"
fi

echo
echo "=== PROJECT TREE ==="

find "$ROOT/core" -maxdepth 2 -type d | sort

echo
echo "============================================================"
echo "RESULT"
echo "PASS=$PASS"
echo "FAIL=$FAIL"
echo "============================================================"

if [ "$FAIL" -eq 0 ]; then
    echo
    echo "SCHAGLK PRE-BUILD CORE CHECK : PASS"
    echo
    echo "IMPORTANT:"
    echo "AUCUN APK N'A ÉTÉ COMPILÉ."
    echo "AUCUN BUILD GRADLE N'A ÉTÉ LANCÉ."
    echo "La prochaine phase reste le développement des fonctions."
    exit 0
else
    echo
    echo "SCHAGLK PRE-BUILD CORE CHECK : FAIL"
    echo "Corriger les erreurs avant de poursuivre."
    exit 1
fi
