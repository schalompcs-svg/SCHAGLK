#!/data/data/com.termux/files/usr/bin/bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

case "${1:-status}" in
  status)
    echo "SCHAGLK INTEGRATION READY"
    ;;
  terminal)
    bash "$ROOT/core/terminal/terminal-engine.sh" "${@:2}"
    ;;
  factory)
    bash "$ROOT/core/factory/project-factory.sh" "${@:2}"
    ;;
  project)
    bash "$ROOT/core/projects/project-manager.sh" "${@:2}"
    ;;
  ai)
    bash "$ROOT/core/ai/ai-orchestrator.sh" "${@:2}"
    ;;
  diagnostics)
    bash "$ROOT/core/diagnostics/run.sh" "${@:2}"
    ;;
  git)
    bash "$ROOT/core/git/git-engine.sh" "${@:2}"
    ;;
  github)
    bash "$ROOT/core/github/github-engine.sh" "${@:2}"
    ;;
  devices)
    bash "$ROOT/core/devices/device-manager.sh" "${@:2}"
    ;;
  build)
    bash "$ROOT/core/build/build-router.sh" "${@:2}"
    ;;
  *)
    echo "Usage: status terminal factory project ai diagnostics git github devices build"
    exit 1
    ;;
esac
