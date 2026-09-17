#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"
mkdir -p "$WORK"

die() {
    echo "[ERROR] $*" >&2
    return 1
}

inside_workspace() {
    local target
    target="$(realpath -m "$1" 2>/dev/null || true)"
    case "$target" in
        "$WORK"|"$WORK"/*) return 0 ;;
        *) return 1 ;;
    esac
}

run_command() {
    local command="${1:-}"
    [ -n "$command" ] || die "commande vide"

    if ! inside_workspace "$WORK"; then
        die "workspace invalide"
        return 1
    fi

    (
        cd "$WORK" || exit 1
        export SCHAGLK_ROOT="$ROOT"
        export SCHAGLK_WORKSPACE="$WORK"
        export SCHAGLK_TERMINAL=1
        bash -c "$command"
    )
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    run_command "${1:-}"
fi
