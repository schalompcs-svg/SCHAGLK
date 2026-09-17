#!/data/data/com.termux/files/usr/bin/bash
case "$1" in
 help) echo "help ls pwd cd mkdir touch cat rm cp mv clear build test git ai preview";;
 pwd) pwd;;
 ls) ls -la;;
 clear) clear;;
 mkdir) mkdir -p "$2";;
 touch) touch "$2";;
 cat) cat "$2";;
 rm) rm -rf "$2";;
 cp) cp -r "$2" "$3";;
 mv) mv "$2" "$3";;
 *) echo "SCHAGLK: commande inconnue: $1";;
esac
