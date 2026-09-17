#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(pwd)}"
PROJECTS="$ROOT/projects"

case "${1:-help}" in

 create)
   NAME="${2:-}"
   TYPE="${3:-web}"
   test -n "$NAME" || { echo "Nom requis"; exit 1; }
   "$ROOT/core/projects/create-project.sh" "$NAME" "$TYPE"
   ;;

 list)
   echo "=== PROJECTS ==="
   find "$PROJECTS" -mindepth 1 -maxdepth 1 -type d \
     -printf '%f\n' 2>/dev/null | sort
   ;;

 remove)
   NAME="${2:-}"
   test -n "$NAME" || exit 1
   P="$PROJECTS/$NAME"
   case "$P" in
     "$PROJECTS"/*)
       rm -rf "$P"
       echo "[OK] removed $NAME"
       ;;
     *)
       echo "[ERROR] invalid path"
       exit 1
       ;;
   esac
   ;;

 files)
   NAME="${2:-}"
   P="$PROJECTS/$NAME"
   test -d "$P" || exit 1
   find "$P" -type f | sort
   ;;

 *)
   echo "create|list|remove|files"
   ;;
esac
