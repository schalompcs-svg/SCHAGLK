#!/data/data/com.termux/files/usr/bin/bash
set -e
case "$1" in
 init) git init;;
 status) git status;;
 add) git add "${2:-.}";;
 commit) git commit -m "${2:-SCHAGLK commit}";;
 pull) git pull;;
 push) git push;;
 clone) git clone "$2" "$3";;
 *) echo "git init|status|add|commit|pull|push|clone";;
esac
