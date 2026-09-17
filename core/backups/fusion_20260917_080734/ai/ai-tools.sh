#!/data/data/com.termux/files/usr/bin/bash
set -u

ROOT="${SCHAGLK_ROOT:-$(pwd)}"

case "${1:-help}" in

 status)
   cat "$ROOT/core/ai/config.json"
   ;;

 files)
   find "$ROOT/workspace" -maxdepth 5 -type f 2>/dev/null | sort
   ;;

 project)
   "$ROOT/core/projects/project-manager.sh" list
   ;;

 diagnostics)
   "$ROOT/core/diagnostics/run.sh"
   ;;

 terminal)
   shift
   "$ROOT/core/terminal/runner.sh" "$*"
   ;;

 tests)
   "$ROOT/core/tests/run-tests.sh"
   ;;

 build)
   echo "AI BUILD TOOL"
   echo "Use orchestrator after project/type detection."
   ;;

 *)
   echo "status|files|project|diagnostics|terminal|tests|build"
   ;;
esac
