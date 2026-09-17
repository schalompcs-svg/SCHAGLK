#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"
LOGDIR="$ROOT/core/terminal/logs"
LOG="$LOGDIR/process.log"

mkdir -p "$WORK" "$LOGDIR"

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log() {
    printf '[%s] %s\n' "$(timestamp)" "$*" >> "$LOG"
}

inside_workspace() {
    local target="${1:-}"
    [ -n "$target" ] || return 1

    local base
    local real

    base="$(realpath -m "$WORK")"
    real="$(realpath -m "$target")"

    case "$real" in
        "$base"|"$base"/*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

run() {
    [ "$#" -gt 0 ] || {
        echo "[ERROR] commande vide"
        return 1
    }

    local command="$*"

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
        tail -n 200 "$LOG" 2>/dev/null || true
        ;;

    clear-log)
        : > "$LOG"
        echo "[OK] process log cleared"
        ;;

    workspace)
        printf '%s\n' "$WORK"
        ;;

    inside)
        if inside_workspace "${2:-}"; then
            echo "[YES]"
            exit 0
        else
            echo "[NO]"
            exit 1
        fi
        ;;

    *)
        echo "run <command>"
        echo "log"
        echo "clear-log"
        echo "workspace"
        echo "inside <path>"
        ;;
esac
