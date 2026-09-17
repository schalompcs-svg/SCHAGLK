#!/data/data/com.termux/files/usr/bin/bash
set -u
ROOT="${SCHAGLK_ROOT:-$(pwd)}"
WORK="$ROOT/workspace"
mkdir -p "$WORK"

echo "SCHAGLK SHELL ENGINE"
echo "Tape 'help' pour les commandes."

while IFS= read -r -p "schaglk> " c; do
  case "$c" in
    "") continue ;;
    exit|quit) break ;;
    help) echo "pwd ls cd tree mkdir touch cat cp mv rm find clear env build test git ai projects exit" ;;
    pwd) pwd ;;
    ls) ls -la ;;
    tree) find "$WORK" -maxdepth 5 -print | sort ;;
    clear) clear ;;
    env) env | grep '^SCHAGLK' || true ;;
    projects) find "$ROOT/projects" -maxdepth 2 -type f | sort ;;
    build) echo "Builder sélectionné selon projet." ;;
    test) "$ROOT/core/tests/run-tests.sh" ;;
    git) shiftcmd="${c#git }"; "$ROOT/core/github/github-engine.sh" $shiftcmd ;;
    ai) echo "SCHAGLK AI tool contract: $ROOT/core/ai/tool-contract.json" ;;
    cd\ *) cd "$WORK/${c#cd }" 2>/dev/null || echo "Dossier introuvable" ;;
    mkdir\ *) mkdir -p "$WORK/${c#mkdir }" ;;
    touch\ *) touch "$WORK/${c#touch }" ;;
    cat\ *) cat "$WORK/${c#cat }" ;;
    find\ *) find "$WORK" -iname "*${c#find }*" ;;
    *) echo "Commande inconnue: $c" ;;
  esac
done
