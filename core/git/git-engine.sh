#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"

mkdir -p "$WORK"

git_cmd() {
    git -C "$WORK" "$@"
}

init_repo() {
    if [ ! -d "$WORK/.git" ]; then
        git_cmd init
        git_cmd config user.name "SCHAGLK"
        git_cmd config user.email "schaglk@localhost"
    fi
}

case "${1:-status}" in
    init)
        init_repo
        echo "GIT_REPOSITORY=INITIALIZED"
        git_cmd status --short
        ;;

    status)
        if [ ! -d "$WORK/.git" ]; then
            echo "GIT_REPOSITORY=NOT_INITIALIZED"
            echo "Use: git-engine.sh init"
            exit 0
        fi
        echo "GIT_REPOSITORY=YES"
        git_cmd status --short
        ;;

    add)
        init_repo
        shift
        git_cmd add "${@:-.}"
        ;;

    commit)
        init_repo
        shift
        message="${*:-SCHAGLK commit}"
        git_cmd add .
        git_cmd commit -m "$message"
        ;;

    branch)
        init_repo
        git_cmd branch
        ;;

    checkout)
        init_repo
        shift
        git_cmd checkout "$@"
        ;;

    log)
        init_repo
        git_cmd log --oneline -10
        ;;

    remote)
        init_repo
        git_cmd remote -v
        ;;

    *)
        echo "Usage:"
        echo "  git-engine.sh init"
        echo "  git-engine.sh status"
        echo "  git-engine.sh add [files]"
        echo "  git-engine.sh commit [message]"
        echo "  git-engine.sh branch"
        echo "  git-engine.sh checkout <branch>"
        echo "  git-engine.sh log"
        echo "  git-engine.sh remote"
        exit 1
        ;;
esac
