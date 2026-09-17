#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"
RUNNER="$ROOT/core/terminal/runner.sh"

mkdir -p "$WORK" "$ROOT/core/terminal/history" "$ROOT/core/terminal/logs"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" \
        >> "$ROOT/core/terminal/logs/terminal.log"
}

safe_path() {
    local p="$1"
    local r
    r="$(realpath -m "$WORK/$p" 2>/dev/null || true)"
    case "$r" in
        "$WORK"|"$WORK"/*) printf '%s\n' "$r"; return 0 ;;
        *) return 1 ;;
    esac
}

execute() {
    local command="$1"
    log "$command"
    "$RUNNER" "$command"
}

case "${1:-help}" in
    help)
        cat <<HELP
SCHAGLK TERMINAL ENGINE

pwd       affiche le workspace
ls        liste les fichiers
mkdir     crée un dossier
touch     crée un fichier
cat       lit un fichier
find      recherche
python    Python
node      Node.js
git       Git
clear     efface l'écran
HELP
        ;;
    run)
        shift
        execute "$*"
        ;;
    status)
        echo "ROOT=$ROOT"
        echo "WORK=$WORK"
        echo "RUNNER=$RUNNER"
        echo "STATUS=READY"
        ;;
    *)
        execute "$*"
        ;;
esac
