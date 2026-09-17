#!/data/data/com.termux/files/usr/bin/bash
set -u
case "${1:-help}" in
status) git status;;
remote) git remote -v;;
clone) git clone "$2" "${3:-}";;
pull) git pull;;
push) git push;;
branches) git branch -a;;
log) git log --oneline -20;;
init) git init;;
add) git add "${2:-.}";;
commit) git commit -m "${2:-SCHAGLK commit}";;
*) echo "status remote clone pull push branches log init add commit";;
esac
