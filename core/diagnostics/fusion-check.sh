#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

PASS=0
FAIL=0

check_file() {
    if [ -f "$1" ]; then
        echo "[PASS] $2"
        PASS=$((PASS+1))
    else
        echo "[FAIL] $2"
        FAIL=$((FAIL+1))
    fi
}

FILES=(
"$ROOT/core/runtime/process-engine.sh"
"$ROOT/core/terminal/runner.sh"
"$ROOT/core/terminal/terminal-engine.sh"
"$ROOT/core/tests/terminal-test.sh"
"$ROOT/core/tests/git-test.sh"
"$ROOT/core/ai/engine-contract.json"
"$ROOT/core/ai/ai-engine.sh"
"$ROOT/core/toolchains/inventory.sh"
"$ROOT/core/git/git-engine.sh"
"$ROOT/core/github/github-engine.sh"
)

for f in "${FILES[@]}"; do
    check_file "$f" "$(basename "$f")"
done

for f in \
    "$ROOT/core/runtime/process-engine.sh" \
    "$ROOT/core/terminal/runner.sh" \
    "$ROOT/core/terminal/terminal-engine.sh" \
    "$ROOT/core/tests/terminal-test.sh" \
    "$ROOT/core/tests/git-test.sh" \
    "$ROOT/core/ai/ai-engine.sh" \
    "$ROOT/core/toolchains/inventory.sh" \
    "$ROOT/core/git/git-engine.sh" \
    "$ROOT/core/github/github-engine.sh"
do
    if bash -n "$f"; then
        echo "[PASS] syntax $(basename "$f")"
        PASS=$((PASS+1))
    else
        echo "[FAIL] syntax $(basename "$f")"
        FAIL=$((FAIL+1))
    fi
done

if python - "$ROOT/core/ai/engine-contract.json" <<'PY'
import json,sys
with open(sys.argv[1],encoding="utf-8") as f:
    json.load(f)
print("JSON_OK")
PY
then
    echo "[PASS] AI JSON"
    PASS=$((PASS+1))
else
    echo "[FAIL] AI JSON"
    FAIL=$((FAIL+1))
fi

echo
echo "FUSION STRUCTURE: PASS=$PASS FAIL=$FAIL"

[ "$FAIL" -eq 0 ]
