#!/data/data/com.termux/files/usr/bin/bash
set -u

P="${1:-}"

test -d "$P" || {
    echo "[ERROR] project not found"
    exit 1
}

echo "=== PROJECT DIAGNOSTICS ==="
echo "PATH: $P"

echo
echo "--- FILES ---"
find "$P" -maxdepth 5 -type f | sort

echo
echo "--- LANGUAGES ---"

find "$P" -type f \
  \( -name '*.java' \
  -o -name '*.kt' \
  -o -name '*.kts' \
  -o -name '*.py' \
  -o -name '*.js' \
  -o -name '*.jsx' \
  -o -name '*.ts' \
  -o -name '*.tsx' \
  -o -name '*.html' \
  -o -name '*.css' \
  -o -name '*.scss' \
  -o -name '*.c' \
  -o -name '*.h' \
  -o -name '*.cpp' \
  -o -name '*.hpp' \
  -o -name '*.rs' \
  -o -name '*.go' \
  -o -name '*.php' \
  -o -name '*.rb' \
  -o -name '*.swift' \
  -o -name '*.xml' \
  -o -name '*.json' \
  -o -name '*.sh' \) \
  -printf '%f\n' 2>/dev/null | sort

echo
echo "--- BUILD FILES ---"

find "$P" -type f \
  \( -name 'build.gradle' \
  -o -name 'build.gradle.kts' \
  -o -name 'settings.gradle' \
  -o -name 'settings.gradle.kts' \
  -o -name 'CMakeLists.txt' \
  -o -name 'package.json' \
  -o -name 'requirements.txt' \
  -o -name 'Cargo.toml' \
  -o -name 'go.mod' \
  -o -name 'pom.xml' \) \
  -print 2>/dev/null

echo
echo "[DONE]"
