#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(pwd)}"

if [ "$#" -eq 0 ]; then
    exec "$ROOT/core/terminal/terminal-engine.sh"
fi

"$ROOT/core/runtime/process-engine.sh" run "$*"
