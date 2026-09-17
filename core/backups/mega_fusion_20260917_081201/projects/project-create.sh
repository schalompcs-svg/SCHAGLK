#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
NAME="${1:-ProjetSCHAGLK}"
TYPE="${2:-web}"
DIR="$ROOT/projects/$NAME"
mkdir -p "$DIR"

case "$TYPE" in
 web)
 cat > "$DIR/index.html" <<HTML
<!doctype html>
<html>
<head><meta name="viewport" content="width=device-width"><title>$NAME</title></head>
<body><h1>$NAME</h1><button onclick="document.body.dataset.test='OK'">TEST</button></body>
</html>
HTML
 ;;
 python)
 echo 'print("SCHAGLK PROJECT OK")' > "$DIR/main.py"
 ;;
 cpp)
 printf '#include <iostream>\nint main(){std::cout<<"SCHAGLK PROJECT OK\\\\n";}\n' > "$DIR/main.cpp"
 ;;
 android)
 mkdir -p "$DIR"
 echo "Android project placeholder - Android toolchain required" > "$DIR/README.txt"
 ;;
 *)
 echo "Type: web|python|cpp|android"
 exit 2
 ;;
esac
echo "$DIR"
