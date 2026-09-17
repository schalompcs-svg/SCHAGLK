#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT="${SCHAGLK_ROOT:-$(pwd)}"
NAME="${1:-SCHAGLK_PROJECT}"
TYPE="${2:-web}"
DIR="$ROOT/projects/$NAME"
mkdir -p "$DIR"

case "$TYPE" in
web)
cat > "$DIR/index.html" <<HTML
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width">
<title>$NAME</title>
<style>
body{font-family:sans-serif;margin:20px}
button{padding:12px;border-radius:10px}
</style>
</head>
<body>
<h1>$NAME</h1>
<button onclick="document.getElementById('result').textContent='LIVE TEST OK'">Tester</button>
<p id="result"></p>
</body>
</html>
HTML
;;
python)
printf 'print("SCHAGLK TEST OK")\n' > "$DIR/main.py"
;;
cpp)
printf '#include <iostream>\nint main(){std::cout<<"SCHAGLK TEST OK\\\\n";return 0;}\n' > "$DIR/main.cpp"
;;
*)
printf '{\n  "name":"%s",\n  "type":"%s"\n}\n' "$NAME" "$TYPE" > "$DIR/project.json"
;;
esac
echo "$DIR"
