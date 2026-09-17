#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"
LOGDIR="$ROOT/core/terminal/logs"
HISTORY="$LOGDIR/history.log"
PROCESS="$ROOT/core/runtime/process-engine.sh"

mkdir -p "$WORK" "$LOGDIR"

touch "$HISTORY"

CURRENT="$WORK"

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log_command() {
    printf '[%s] %s\n' "$(timestamp)" "$*" >> "$HISTORY"
}

inside_workspace() {
    local target="$1"
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

resolve_path() {
    local p="${1:-}"

    if [ -z "$p" ]; then
        printf '%s\n' "$CURRENT"
        return
    fi

    case "$p" in
        /*)
            realpath -m "$p"
            ;;
        *)
            realpath -m "$CURRENT/$p"
            ;;
    esac
}

safe_path() {
    local p
    p="$(resolve_path "$1")"
    inside_workspace "$p"
}

show_prompt() {
    local display

    display="${CURRENT#$WORK}"

    [ "$display" = "$CURRENT" ] && display="/"

    [ -z "$display" ] && display="/"

    printf 'SCHAGLK:%s> ' "$display"
}

cmd_help() {
    cat <<HELP
============================================================
SCHAGLK TERMINAL
============================================================

NAVIGATION
  pwd
  ls [path]
  cd <path>
  tree [path]
  find <motif>

FILES
  mkdir <dir>
  touch <file>
  cat <file>
  write <file> <texte>
  cp <source> <destination>
  mv <source> <destination>
  rm <path>

SYSTEME
  env
  which <commande>
  history
  clear
  date

EXECUTION
  run <commande>
  python <commande>
  node <commande>
  clang <commande>
  clang++ <commande>

SCHAGLK
  projects
  diagnostics
  toolchains
  build
  test
  ai
  devices
  logs

CONTROL
  help
  exit
  quit

SECURITE
  Le terminal travaille par défaut dans workspace.
  rm demande une confirmation.
============================================================
HELP
}

cmd_pwd() {
    printf '%s\n' "$CURRENT"
}

cmd_ls() {
    local target="${1:-$CURRENT}"
    local p

    p="$(resolve_path "$target")"

    if ! inside_workspace "$p"; then
        echo "[SECURITY] chemin hors workspace refusé"
        return 1
    fi

    ls -la "$p"
}

cmd_cd() {
    local p
    p="$(resolve_path "${1:-$WORK}")"

    if ! inside_workspace "$p"; then
        echo "[SECURITY] cd hors workspace refusé"
        return 1
    fi

    if [ ! -d "$p" ]; then
        echo "[ERROR] dossier introuvable"
        return 1
    fi

    CURRENT="$p"
}

cmd_tree() {
    local p="${1:-$CURRENT}"

    p="$(resolve_path "$p")"

    if ! inside_workspace "$p"; then
        echo "[SECURITY] chemin hors workspace refusé"
        return 1
    fi

    find "$p" -maxdepth 6 -print | sort
}

cmd_find() {
    local pattern="${1:-}"

    [ -n "$pattern" ] || {
        echo "Usage: find <motif>"
        return 1
    }

    find "$CURRENT" -iname "*$pattern*" -print
}

cmd_mkdir() {
    local p
    p="$(resolve_path "${1:-}")"

    [ -n "${1:-}" ] || {
        echo "Usage: mkdir <dossier>"
        return 1
    }

    if ! inside_workspace "$p"; then
        echo "[SECURITY] mkdir hors workspace refusé"
        return 1
    fi

    mkdir -p "$p"
}

cmd_touch() {
    local p
    p="$(resolve_path "${1:-}")"

    [ -n "${1:-}" ] || {
        echo "Usage: touch <fichier>"
        return 1
    }

    if ! inside_workspace "$p"; then
        echo "[SECURITY] touch hors workspace refusé"
        return 1
    fi

    mkdir -p "$(dirname "$p")"
    touch "$p"
}

cmd_cat() {
    local p
    p="$(resolve_path "${1:-}")"

    [ -n "${1:-}" ] || {
        echo "Usage: cat <fichier>"
        return 1
    }

    if ! inside_workspace "$p"; then
        echo "[SECURITY] cat hors workspace refusé"
        return 1
    fi

    cat "$p"
}

cmd_write() {
    local file="${1:-}"
    shift || true

    [ -n "$file" ] || {
        echo "Usage: write <fichier> <texte>"
        return 1
    }

    local p
    p="$(resolve_path "$file")"

    if ! inside_workspace "$p"; then
        echo "[SECURITY] write hors workspace refusé"
        return 1
    fi

    mkdir -p "$(dirname "$p")"
    printf '%s\n' "$*" > "$p"
}

cmd_cp() {
    local src="${1:-}"
    local dst="${2:-}"

    [ -n "$src" ] && [ -n "$dst" ] || {
        echo "Usage: cp <source> <destination>"
        return 1
    }

    local s d
    s="$(resolve_path "$src")"
    d="$(resolve_path "$dst")"

    if ! inside_workspace "$s" || ! inside_workspace "$d"; then
        echo "[SECURITY] cp hors workspace refusé"
        return 1
    fi

    mkdir -p "$(dirname "$d")"
    cp -r "$s" "$d"
}

cmd_mv() {
    local src="${1:-}"
    local dst="${2:-}"

    [ -n "$src" ] && [ -n "$dst" ] || {
        echo "Usage: mv <source> <destination>"
        return 1
    }

    local s d
    s="$(resolve_path "$src")"
    d="$(resolve_path "$dst")"

    if ! inside_workspace "$s" || ! inside_workspace "$d"; then
        echo "[SECURITY] mv hors workspace refusé"
        return 1
    fi

    mkdir -p "$(dirname "$d")"
    mv "$s" "$d"
}

cmd_rm() {
    local p
    p="$(resolve_path "${1:-}")"

    [ -n "${1:-}" ] || {
        echo "Usage: rm <path>"
        return 1
    }

    if ! inside_workspace "$p"; then
        echo "[SECURITY] rm hors workspace refusé"
        return 1
    fi

    [ "$p" != "$WORK" ] || {
        echo "[SECURITY] suppression du workspace racine interdite"
        return 1
    }

    printf "Supprimer %s ? [y/N] " "$p"
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            rm -rf -- "$p"
            ;;
        *)
            echo "[CANCELLED]"
            ;;
    esac
}

cmd_history() {
    tail -n 100 "$HISTORY"
}

cmd_env() {
    env | sort
}

cmd_which() {
    command -v "${1:-}" || true
}

cmd_run() {
    shift || true

    [ "$#" -gt 0 ] || {
        echo "Usage: run <commande>"
        return 1
    }

    "$PROCESS" run "$@"
}

cmd_python() {
    shift || true
    command -v python >/dev/null 2>&1 || {
        echo "[ERROR] python indisponible"
        return 1
    }

    "$PROCESS" run python "$@"
}

cmd_node() {
    shift || true
    command -v node >/dev/null 2>&1 || {
        echo "[ERROR] node indisponible"
        return 1
    }

    "$PROCESS" run node "$@"
}

cmd_clang() {
    shift || true
    command -v clang >/dev/null 2>&1 || {
        echo "[ERROR] clang indisponible"
        return 1
    }

    "$PROCESS" run clang "$@"
}

cmd_clangpp() {
    shift || true
    command -v clang++ >/dev/null 2>&1 || {
        echo "[ERROR] clang++ indisponible"
        return 1
    }

    "$PROCESS" run clang++ "$@"
}

cmd_projects() {
    find "$ROOT/projects" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf '%f\n' 2>/dev/null | sort
}

cmd_diagnostics() {
    "$ROOT/core/diagnostics/run.sh"
}

cmd_toolchains() {
    "$ROOT/core/toolchains/detect.sh"
}

cmd_build() {
    echo "[INFO] BUILD ROUTER"
    echo "[INFO] APK compilation désactivée à cette étape."
    "$ROOT/core/build/build-router.sh" "${1:-}" 2>/dev/null || true
}

cmd_test() {
    "$ROOT/core/tests/run-tests.sh"
}

cmd_ai() {
    "$ROOT/core/ai/ai-tools.sh" status
}

cmd_devices() {
    "$ROOT/core/devices/device-manager.sh" status
}

cmd_logs() {
    echo "=== PROCESS ==="
    "$PROCESS" log 2>/dev/null || true

    echo
    echo "=== HISTORY ==="
    tail -n 100 "$HISTORY" 2>/dev/null || true
}

echo
echo "============================================================"
echo " SCHAGLK TERMINAL ENGINE"
echo " ROOT      : $ROOT"
echo " WORKSPACE : $WORK"
echo "============================================================"
echo "Tape 'help' pour afficher les commandes."
echo

while true; do

    show_prompt

    if ! IFS= read -r command_line; then
        echo
        break
    fi

    [ -n "$command_line" ] || continue

    log_command "$command_line"

    case "$command_line" in

        help)
            cmd_help
            ;;

        pwd)
            cmd_pwd
            ;;

        ls)
            cmd_ls
            ;;

        ls\ *)
            cmd_ls "${command_line#ls }"
            ;;

        cd)
            cmd_cd "$WORK"
            ;;

        cd\ *)
            cmd_cd "${command_line#cd }"
            ;;

        tree)
            cmd_tree
            ;;

        tree\ *)
            cmd_tree "${command_line#tree }"
            ;;

        find\ *)
            cmd_find "${command_line#find }"
            ;;

        mkdir\ *)
            cmd_mkdir "${command_line#mkdir }"
            ;;

        touch\ *)
            cmd_touch "${command_line#touch }"
            ;;

        cat\ *)
            cmd_cat "${command_line#cat }"
            ;;

        write\ *)
            args="${command_line#write }"
            file="${args%% *}"
            text="${args#"$file"}"
            text="${text# }"
            cmd_write "$file" "$text"
            ;;

        cp\ *)
            rest="${command_line#cp }"
            src="${rest%% *}"
            dst="${rest#"$src"}"
            dst="${dst# }"
            cmd_cp "$src" "$dst"
            ;;

        mv\ *)
            rest="${command_line#mv }"
            src="${rest%% *}"
            dst="${rest#"$src"}"
            dst="${dst# }"
            cmd_mv "$src" "$dst"
            ;;

        rm\ *)
            cmd_rm "${command_line#rm }"
            ;;

        history)
            cmd_history
            ;;

        env)
            cmd_env
            ;;

        which\ *)
            cmd_which "${command_line#which }"
            ;;

        run\ *)
            set -- ${command_line#run }
            cmd_run "$@"
            ;;

        python\ *)
            set -- ${command_line#python }
            cmd_python "$@"
            ;;

        node\ *)
            set -- ${command_line#node }
            cmd_node "$@"
            ;;

        clang\ *)
            set -- ${command_line#clang }
            cmd_clang "$@"
            ;;

        clang++\ *)
            set -- ${command_line#clang++ }
            cmd_clangpp "$@"
            ;;

        projects)
            cmd_projects
            ;;

        diagnostics)
            cmd_diagnostics
            ;;

        toolchains)
            cmd_toolchains
            ;;

        build)
            cmd_build
            ;;

        build\ *)
            cmd_build "${command_line#build }"
            ;;

        test)
            cmd_test
            ;;

        ai)
            cmd_ai
            ;;

        devices)
            cmd_devices
            ;;

        logs)
            cmd_logs
            ;;

        clear)
            clear
            ;;

        date)
            date
            ;;

        exit|quit)
            echo "SCHAGLK Terminal arrêté."
            break
            ;;

        *)
            "$PROCESS" run "$command_line"
            ;;
    esac

done
