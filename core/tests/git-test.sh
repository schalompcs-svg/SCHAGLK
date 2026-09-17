#!/data/data/com.termux/files/usr/bin/bash
set -u

echo "=== SCHAGLK GIT/GITHUB TESTS ==="

BASE="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$BASE/core/tests/.git-test-tmp"

PASS=0
FAIL=0

rm -rf "$TMP"
mkdir -p "$TMP"

pass() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}

cd "$TMP" || exit 1

# Git identity locale du dépôt de test
git init -q
git config user.name "SCHAGLK"
git config user.email "schaglk@localhost"

if [ -d .git ]; then
    pass "git init"
else
    fail "git init"
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    pass "repository detected"
else
    fail "repository detected"
fi

echo "SCHAGLK GIT TEST" > test.txt

if git add test.txt >/dev/null 2>&1; then
    pass "git add"
else
    fail "git add"
fi

if git commit -m "SCHAGLK test commit" >/dev/null 2>&1; then
    pass "git commit"
else
    echo "    commit diagnostic:"
    git commit -m "SCHAGLK test commit" 2>&1 || true
    fail "git commit"
fi

if git status >/dev/null 2>&1; then
    pass "git status"
else
    fail "git status"
fi

if git branch >/dev/null 2>&1; then
    pass "git branch"
else
    fail "git branch"
fi

if git log -1 >/dev/null 2>&1; then
    pass "git log"
else
    fail "git log"
fi

cd "$BASE"

# Interface GitHub SCHAGLK
if [ -x "$BASE/core/github/github-engine.sh" ]; then
    pass "github repository integration"
    pass "github branch interface"
    pass "github log interface"
else
    fail "github repository integration"
    fail "github branch interface"
    fail "github log interface"
fi

rm -rf "$TMP"

echo
echo "GIT/GITHUB TESTS: PASS=$PASS FAIL=$FAIL"

if [ "$FAIL" -eq 0 ]; then
    echo "SCHAGLK GIT/GITHUB CORE: PASS"
    exit 0
else
    echo "SCHAGLK GIT/GITHUB CORE: FAIL"
    exit 1
fi
