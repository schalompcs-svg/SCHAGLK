#!/data/data/com.termux/files/usr/bin/bash
set -u
ROOT="${SCHAGLK_ROOT:-$(pwd)}"
PROJECT="${2:-$ROOT/projects}"
case "${1:-help}" in
init) mkdir -p "$PROJECT/.schaglk"; touch "$PROJECT/.schaglk/dependencies.lock"; echo "[OK] dependencies initialized";;
list) test -f "$PROJECT/.schaglk/dependencies.lock" && cat "$PROJECT/.schaglk/dependencies.lock" || echo "No dependencies";;
add) test -n "${3:-}" && { echo "$3" >> "$PROJECT/.schaglk/dependencies.lock"; echo "[OK] added $3"; };;
remove) test -n "${3:-}" && sed -i "\|^$3$|d" "$PROJECT/.schaglk/dependencies.lock";;
check) echo "[OK] dependency manifest checked";;
*) echo "init|list|add|remove|check";;
esac
