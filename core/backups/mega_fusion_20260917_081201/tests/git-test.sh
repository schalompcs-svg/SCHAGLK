#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"
GIT_ENGINE="$ROOT/core/git/git-engine.sh"
GITHUB_ENGINE="$ROOT/core/github/github-engine.sh"

PASS=0
FAIL=0

ok() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

bad() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}

echo "=== SCHAGLK GIT/GITHUB TESTS ==="

if "$GIT_ENGINE" init >/dev/null 2>&1; then
    ok "git init"
else
    bad "git init"
fi

if git -C "$WORK" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    ok "repository detected"
else
    bad "repository detection"
fi

printf 'SCHAGLK_GIT_TEST\n' > "$WORK/__git_test__.txt"

if "$GIT_ENGINE" add . >/dev/null 2>&1; then
    ok "git add"
else
    bad "git add"
fi

if "$GIT_ENGINE" commit "SCHAGLK automated test" >/dev/null 2>&1; then
    ok "git commit"
else
    bad "git commit"
fi

if "$GIT_ENGINE" status >/dev/null 2>&1; then
    ok "git status"
else
    bad "git status"
fi

if "$GIT_ENGINE" branch >/dev/null 2>&1; then
    ok "git branch"
else
    bad "git branch"
fi

if "$GIT_ENGINE" log | grep -q "SCHAGLK automated test"; then
    ok "git log"
else
    bad "git log"
fi

if "$GITHUB_ENGINE" status | grep -q "GIT_REPOSITORY=YES"; then
    ok "github repository integration"
else
    bad "github repository integration"
fi

if "$GITHUB_ENGINE" branch >/dev/null 2>&1; then
    ok "github branch interface"
else
    bad "github branch interface"
fi

if "$GITHUB_ENGINE" log >/dev/null 2>&1; then
    ok "github log interface"
else
    bad "github log interface"
fi

rm -f "$WORK/__git_test__.txt"

echo
echo "GIT/GITHUB TESTS: PASS=$PASS FAIL=$FAIL"

if [ "$FAIL" -eq 0 ]; then
    echo "SCHAGLK GIT/GITHUB CORE: PASS"
    exit 0
else
    echo "SCHAGLK GIT/GITHUB CORE: FAIL"
    exit 1
fi
