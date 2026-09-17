#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(pwd)}"
WORK="$ROOT/workspace"
LOG="$ROOT/core/terminal/logs/process.log"

mkdir -p "$WORK" "$(dirname "$LOG")"

timestamp(){
    date '+%Y-%m-%d %H:%M:%S'
}

log(){
    printf '[%s] %s\n' "$(timestamp)" "$*" >> "$LOG"
}

inside_workspace(){
    local target="$1"
    local base
    local real

    base="$(realpath -m "$WORK")"
    real="$(realpath -m "$target")"

    case "$real" in
        "$base"|"$base"/*) return 0 ;;
        *) return 1 ;;
    esac
}

run(){
    local command="$*"

    test -n "$command" || {
        echo "[ERROR] commande vide"
        return 1
    }

    log "EXEC: $command"

    (
        cd "$WORK" || exit 1
        bash -c "$command"
    )

    local code=$?

    log "EXIT: $code"

    return "$code"
}

case "${1:-help}" in

run)
    shift
    run "$@"
    ;;

log)
    tail -n 100 "$LOG"
    ;;

clear-log)
    : > "$LOG"
    echo "[OK] process log cleared"
    ;;

workspace)
    echo "$WORK"
    ;;

inside)
    inside_workspace "${2:-}" &&
        echo "[YES]" ||
        echo "[NO]"
    ;;

*)
    echo "run <command>"
    echo "log"
    echo "clear-log"
    echo "workspace"
    echo "inside <path>"
    ;;
esac
