#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(pwd)}"
REG="$ROOT/core/plugins/registry.json"

case "${1:-list}" in

 list)
   cat "$REG"
   ;;

 install)
   NAME="${2:-}"
   TYPE="${3:-generic}"
   test -n "$NAME" || exit 1

   DIR="$ROOT/core/plugins/$NAME"
   mkdir -p "$DIR"

   cat > "$DIR/plugin.json" <<JSON
{
  "name":"$NAME",
  "type":"$TYPE",
  "enabled":true
}
JSON

   echo "[OK] plugin registered: $NAME"
   ;;

 enable)
   echo "[INFO] plugin enable: ${2:-}"
   ;;

 disable)
   echo "[INFO] plugin disable: ${2:-}"
   ;;

 *)
   echo "list|install|enable|disable"
   ;;
esac
