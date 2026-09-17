#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
ENGINE="$ROOT/core/runtime/process-engine.sh"

if [ "$#" -eq 0 ]; then
    echo "SCHAGLK TERMINAL"
    echo "Workspace: $ROOT/workspace"
    echo "Tape 'help' pour commencer."
    while IFS= read -r -p "schaglk> " cmd; do
        [ -n "$cmd" ] || continue
        case "$cmd" in
            exit|quit) break ;;
            help)
                printf '%s\n' \
                    "pwd" "ls" "cd" "mkdir" "touch" "cat" \
                    "find" "python" "node" "git" "clear" "exit"
                ;;
            clear) clear ;;
            *) "$ENGINE" "$cmd" ;;
        esac
    done
    exit 0
fi

"$ENGINE" "$*"
