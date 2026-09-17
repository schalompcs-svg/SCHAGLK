#!/data/data/com.termux/files/usr/bin/bash
set -u
case "${1:-help}" in
init) git init;;
status) git status;;
add) git add "${2:-.}";;
commit) git commit -m "${2:-SCHAGLK commit}";;
branch) git branch;;
checkout) git checkout "$2";;
pull) git pull;;
push) git push;;
clone) git clone "$2" "${3:-}";;
remote) git remote -v;;
*) echo "init status add commit branch checkout pull push clone remote";;
esac
