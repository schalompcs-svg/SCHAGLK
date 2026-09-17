#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"

mkdir -p "$WORK"

case "${1:-status}" in

    status)
        echo "GITHUB ENGINE"

        if git -C "$WORK" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo "GIT_REPOSITORY=YES"
            echo "BRANCH=$(git -C "$WORK" branch --show-current)"
            echo "REMOTE:"
            git -C "$WORK" remote -v || true
        else
            echo "GIT_REPOSITORY=NO"
            echo "ACTION=INITIALIZATION_REQUIRED"
        fi

        echo "AUTHENTICATION=EXTERNAL"
        echo "PUSH_REQUIRES_AUTH=YES"
        ;;

    init)
        if [ ! -d "$WORK/.git" ]; then
            git -C "$WORK" init
            git -C "$WORK" config user.name "SCHAGLK"
            git -C "$WORK" config user.email "schaglk@localhost"
        fi
        echo "GITHUB_READY=YES"
        ;;

    remote)
        git -C "$WORK" remote -v
        ;;

    branch)
        git -C "$WORK" branch
        ;;

    log)
        git -C "$WORK" log --oneline -10 2>/dev/null || true
        ;;

    *)
        echo "Usage:"
        echo "  github-engine.sh status"
        echo "  github-engine.sh init"
        echo "  github-engine.sh remote"
        echo "  github-engine.sh branch"
        echo "  github-engine.sh log"
        exit 1
        ;;
esac
