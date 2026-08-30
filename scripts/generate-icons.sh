#!/usr/bin/env bash
# One-time setup: resize the OpenMoji dog-face (U+1F436) into the macOS AppIcon
# set. Uses only curl + sips. The menu bar uses an SF Symbol, not this bitmap.
#
# Usage:
#   scripts/generate-icons.sh [color-png]
#
# If the PNG is missing, it is downloaded from the OpenMoji GitHub repo
# (https://github.com/hfg-gmuend/openmoji — color/618x618).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$ROOT/Assets/OpenMoji"
COLOR_URL="https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/color/618x618/1F436.png"

COLOR_SRC="${1:-$SOURCE_DIR/1F436-color.png}"
APPICON_DIR="$ROOT/Zoomie/Assets.xcassets/AppIcon.appiconset"

mkdir -p "$SOURCE_DIR" "$APPICON_DIR"

if [[ ! -f "$COLOR_SRC" ]]; then
    echo "Downloading $(basename "$COLOR_SRC")…"
    curl -fsSL "$COLOR_URL" -o "$COLOR_SRC"
fi

if [[ ! -f "$COLOR_SRC" ]]; then
    echo "Missing color source PNG: $COLOR_SRC" >&2
    exit 1
fi

resize() {
    local src="$1"
    local px="$2"
    local dest="$3"
    sips -s format png -z "$px" "$px" "$src" --out "$dest" >/dev/null
}

echo "Generating AppIcon.appiconset from $(basename "$COLOR_SRC")…"
resize "$COLOR_SRC" 16   "$APPICON_DIR/icon_16x16.png"
resize "$COLOR_SRC" 32   "$APPICON_DIR/icon_16x16@2x.png"
resize "$COLOR_SRC" 32   "$APPICON_DIR/icon_32x32.png"
resize "$COLOR_SRC" 64   "$APPICON_DIR/icon_32x32@2x.png"
resize "$COLOR_SRC" 128  "$APPICON_DIR/icon_128x128.png"
resize "$COLOR_SRC" 256  "$APPICON_DIR/icon_128x128@2x.png"
resize "$COLOR_SRC" 256  "$APPICON_DIR/icon_256x256.png"
resize "$COLOR_SRC" 512  "$APPICON_DIR/icon_256x256@2x.png"
resize "$COLOR_SRC" 512  "$APPICON_DIR/icon_512x512.png"
resize "$COLOR_SRC" 1024 "$APPICON_DIR/icon_512x512@2x.png"

cat > "$APPICON_DIR/Contents.json" <<'EOF'
{
  "images" : [
    { "filename" : "icon_16x16.png", "idiom" : "mac", "scale" : "1x", "size" : "16x16" },
    { "filename" : "icon_16x16@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "16x16" },
    { "filename" : "icon_32x32.png", "idiom" : "mac", "scale" : "1x", "size" : "32x32" },
    { "filename" : "icon_32x32@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "32x32" },
    { "filename" : "icon_128x128.png", "idiom" : "mac", "scale" : "1x", "size" : "128x128" },
    { "filename" : "icon_128x128@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "128x128" },
    { "filename" : "icon_256x256.png", "idiom" : "mac", "scale" : "1x", "size" : "256x256" },
    { "filename" : "icon_256x256@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "256x256" },
    { "filename" : "icon_512x512.png", "idiom" : "mac", "scale" : "1x", "size" : "512x512" },
    { "filename" : "icon_512x512@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "512x512" }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "Done."
echo "  App icon:     $APPICON_DIR"
echo "  Color source: $COLOR_SRC"
