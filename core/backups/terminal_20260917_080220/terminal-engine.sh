#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(pwd)}"
WORK="$ROOT/workspace"
HISTORY="$ROOT/core/terminal/history/commands.log"
PROCESS="$ROOT/core/runtime/process-engine.sh"

mkdir -p "$WORK" "$(dirname "$HISTORY")"

touch "$HISTORY"

CURRENT="$WORK"

prompt(){
    local rel
    rel="${CURRENT#$WORK}"
    [ "$rel" = "$CURRENT" ] && rel="/"
    [ -z "$rel" ] && rel="/"

    printf '\nSCHAGLK:%s> ' "$rel"
}

record(){
    printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$HISTORY"
}

safe_path(){
    local p="$1"
    local base real

    base="$(realpath -m "$WORK")"
    real="$(realpath -m "$p")"

    case "$real" in
        "$base"|"$base"/*) return 0 ;;
        *) return 1 ;;
    esac
}

resolve(){
    realpath -m "$CURRENT/$1"
}

cmd_help(){
    cat <<HELP

================ SCHAGLK TERMINAL ================

Navigation:
  pwd
  ls
  cd <dir>
  tree
  find <name>

Files:
  touch <file>
  mkdir <dir>
  cat <file>
  write <file> <text>
  cp <src> <dst>
  mv <src> <dst>
  rm <file>

Execution:
  run <command>
  python <file>
  node <file>
  clang <file>
  clang++ <file>
  java <file>

System:
  env
  which <command>
  history
  clear

SCHAGLK:
  projects
  diagnostics
  build <project>
  test <project>
  ai
  devices
  logs

  help
  exit

====================================================
HELP
}

while true; do

    prompt
    IFS= read -r line || break

    [ -z "$line" ] && continue

    record "$line"

    case "$line" in

        exit|quit)
            echo "SCHAGLK terminal stopped."
            break
            ;;

        help)
            cmd_help
            ;;

        pwd)
            pwd
            ;;

        ls)
            ls -la "$CURRENT"
            ;;

        "ls "*)
            target="$(resolve "${line#ls }")"

            if safe_path "$target"; then
                ls -la "$target"
            else
                echo "[SECURITY] accès hors workspace refusé"
            fi
            ;;

        "cd "*)
            target="$(resolve "${line#cd }")"

            if safe_path "$target" && [ -d "$target" ]; then
                CURRENT="$(realpath "$target")"
            else
                echo "[ERROR] dossier inaccessible"
            fi
            ;;

        tree)
            find "$CURRENT" -maxdepth 5 -print | sort
            ;;

        "find "*)
            pattern="${line#find }"
            find "$CURRENT" -iname "*$pattern*" 2>/dev/null
            ;;

        "mkdir "*)
            target="$(resolve "${line#mkdir }")"

            if safe_path "$target"; then
                mkdir -p "$target"
                echo "[OK] directory created"
            else
                echo "[SECURITY] chemin refusé"
            fi
            ;;

        "touch "*)
            target="$(resolve "${line#touch }")"

            if safe_path "$target"; then
                mkdir -p "$(dirname "$target")"
                touch "$target"
                echo "[OK] file created"
            else
                echo "[SECURITY] chemin refusé"
            fi
            ;;

        "cat "*)
            target="$(resolve "${line#cat }")"

            if safe_path "$target" && [ -f "$target" ]; then
                cat "$target"
            else
                echo "[ERROR] fichier inaccessible"
            fi
            ;;

        "write "*)
            rest="${line#write }"
            file="${rest%% *}"
            text="${rest#* }"

            target="$(resolve "$file")"

            if safe_path "$target"; then
                mkdir -p "$(dirname "$target")"
                printf '%s\n' "$text" > "$target"
                echo "[OK] written"
            else
                echo "[SECURITY] chemin refusé"
            fi
            ;;

        "cp "*)
            set -- ${line#cp }
            [ "$#" -ge 2 ] || {
                echo "Usage: cp source destination"
                continue
            }

            src="$(resolve "$1")"
            dst="$(resolve "$2")"

            if safe_path "$src" && safe_path "$dst"; then
                cp -r "$src" "$dst"
            else
                echo "[SECURITY] chemin refusé"
            fi
            ;;

        "mv "*)
            set -- ${line#mv }
            [ "$#" -ge 2 ] || {
                echo "Usage: mv source destination"
                continue
            }

            src="$(resolve "$1")"
            dst="$(resolve "$2")"

            if safe_path "$src" && safe_path "$dst"; then
                mv "$src" "$dst"
            else
                echo "[SECURITY] chemin refusé"
            fi
            ;;

        "rm "*)
            target="$(resolve "${line#rm }")"

            if safe_path "$target" && [ "$target" != "$WORK" ]; then
                echo "[CONFIRMATION] suppression de: $target"
                printf "Confirmer (oui/non): "
                read -r answer

                if [ "$answer" = "oui" ]; then
                    rm -rf "$target"
                    echo "[OK] removed"
                else
                    echo "[CANCEL]"
                fi
            else
                echo "[SECURITY] suppression refusée"
            fi
            ;;

        "run "*)
            "$PROCESS" run "${line#run }"
            ;;

        "python "*)
            target="$(resolve "${line#python }")"

            if safe_path "$target" && [ -f "$target" ]; then
                "$PROCESS" run python "$target"
            else
                echo "[ERROR] Python file inaccessible"
            fi
            ;;

        "node "*)
            target="$(resolve "${line#node }")"

            if safe_path "$target" && [ -f "$target" ]; then
                "$PROCESS" run node "$target"
            else
                echo "[ERROR] Node file inaccessible"
            fi
            ;;

        "clang "*)
            target="$(resolve "${line#clang }")"

            if safe_path "$target" && [ -f "$target" ]; then
                "$PROCESS" run clang "$target" -o "$CURRENT/app"
            else
                echo "[ERROR] C file inaccessible"
            fi
            ;;

        "clang++ "*)
            target="$(resolve "${line#clang++ }")"

            if safe_path "$target" && [ -f "$target" ]; then
                "$PROCESS" run clang++ "$target" -o "$CURRENT/app"
            else
                echo "[ERROR] C++ file inaccessible"
            fi
            ;;

        "env")
            env | sort
            ;;

        "which "*)
            command -v "${line#which }" || echo "not found"
            ;;

        history)
            tail -n 100 "$HISTORY"
            ;;

        clear)
            clear
            ;;

        projects)
            "$ROOT/core/projects/project-manager.sh" list
            ;;

        "diagnostics")
            "$ROOT/core/diagnostics/run.sh"
            ;;

        "build "*)
            NAME="${line#build }"
            "$ROOT/core/build/build-router.sh" "$ROOT/projects/$NAME"
            ;;

        "test "*)
            NAME="${line#test }"
            "$ROOT/core/orchestrator/schaglk.sh" test "$NAME"
            ;;

        ai)
            "$ROOT/core/ai/ai-tools.sh" status
            ;;

        devices)
            "$ROOT/core/devices/device-manager.sh" status
            ;;

        logs)
            "$PROCESS" log
            ;;

        *)
            echo "[SCHAGLK] commande système:"
            "$PROCESS" run "$line"
            ;;

    esac
done
