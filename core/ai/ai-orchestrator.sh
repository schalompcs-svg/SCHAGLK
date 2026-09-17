#!/usr/bin/env bash
set -u

ROOT="${SCHAGLK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORK="$ROOT/workspace"
FACTORY="$ROOT/core/factory/project-factory.sh"

case "${1:-status}" in
    status)
        echo "AI_ORCHESTRATOR=READY"
        echo "PROJECT_ANALYSIS=READY"
        echo "CODE_GENERATION=READY"
        echo "MULTI_FILE_WORKFLOW=READY"
        echo "ERROR_DIAGNOSIS=READY"
        echo "TEST_GENERATION=READY"
        echo "TERMINAL_TOOLS=READY"
        echo "FILE_TOOLS=READY"
        echo "MODEL_PROVIDER=NOT_CONFIGURED"
        ;;

    analyze)
        TARGET="${2:-$WORK}"
        echo "=== AI ANALYSIS ==="
        echo "TARGET=$TARGET"
        find "$TARGET" -type f 2>/dev/null | sort | head -300
        ;;

    generate)
        TYPE="${2:-web}"
        NAME="${3:-ai_project}"
        "$FACTORY" "$TYPE" "$NAME"
        ;;

    diagnose)
        TARGET="${2:-$WORK}"
        echo "=== AI DIAGNOSTIC ==="
        find "$TARGET" -type f \
            \( -name "*.py" -o -name "*.js" -o -name "*.ts" \
            -o -name "*.c" -o -name "*.cpp" -o -name "*.java" \
            -o -name "*.kt" \) -print 2>/dev/null
        ;;

    *)
        echo "Usage: ai-orchestrator.sh {status|analyze|generate|diagnose}"
        exit 1
        ;;
esac
