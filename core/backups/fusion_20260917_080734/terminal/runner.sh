#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
export SCHAGLK_ROOT="$ROOT"

if [ "$#" -eq 0 ]; then
    exec "$ROOT/core/terminal/terminal-engine.sh"
fi

"$ROOT/core/runtime/process-engine.sh" run "$@"
