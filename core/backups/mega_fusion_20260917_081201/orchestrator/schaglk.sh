#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(pwd)}"
export SCHAGLK_ROOT="$ROOT"

die(){ echo "[ERROR] $*" >&2; exit 1; }
ok(){ echo "[OK] $*"; }

case "${1:-help}" in

  help)
    cat <<HELP
SCHAGLK ORCHESTRATOR

project create <name> <type>
project list
project info <name>

build web <project>
build cpp <project>
build python <project>

test <project>
diagnostics
toolchains
plugins
devices

terminal
HELP
    ;;

  project)
    case "${2:-}" in
      create)
        "$ROOT/core/projects/create-project.sh" "${3:-SCHAGLK_PROJECT}" "${4:-web}"
        ;;
      list)
        find "$ROOT/projects" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort
        ;;
      info)
        P="$ROOT/projects/${3:-}"
        test -d "$P" || die "Projet introuvable"
        echo "PROJECT=$P"
        find "$P" -maxdepth 2 -type f | sort
        ;;
      *)
        die "project create|list|info"
        ;;
    esac
    ;;

  build)
    TYPE="${2:-}"
    NAME="${3:-}"
    P="$ROOT/projects/$NAME"

    test -d "$P" || die "Projet introuvable: $NAME"

    case "$TYPE" in
      web)
        "$ROOT/core/build/web-build.sh" "$P"
        ;;
      cpp)
        "$ROOT/core/build/native-build.sh" "$P"
        ;;
      python)
        "$ROOT/core/build/python-test.sh" "$P"
        ;;
      *)
        die "Builders disponibles: web|cpp|python"
        ;;
    esac
    ;;

  test)
    NAME="${2:-}"
    P="$ROOT/projects/$NAME"
    test -d "$P" || die "Projet introuvable"

    if test -f "$P/main.py"; then
      "$ROOT/core/build/python-test.sh" "$P"
    elif test -f "$P/main.cpp" || test -f "$P/main.c"; then
      "$ROOT/core/build/native-build.sh" "$P" >/dev/null
      "$P/app"
    elif test -f "$P/index.html"; then
      grep -q '<html' "$P/index.html" && ok "HTML structure"
      grep -q 'LIVE TEST OK' "$P/index.html" && ok "LIVE marker"
    else
      die "Type de projet non détecté"
    fi
    ;;

  diagnostics)
    "$ROOT/core/diagnostics/run.sh"
    ;;

  toolchains)
    "$ROOT/core/toolchains/detect.sh"
    ;;

  plugins)
    find "$ROOT/core/plugins" -maxdepth 2 -type f -print | sort
    ;;

  devices)
    echo "=== ADB DEVICES ==="
    adb devices
    ;;

  terminal)
    exec "$ROOT/core/terminal/shell-engine.sh"
    ;;

  *)
    die "Commande inconnue. Tape: schaglk help"
    ;;
esac
