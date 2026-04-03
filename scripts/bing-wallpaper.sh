#!/bin/bash

DIR="$HOME/.local/share/bing-home"
IMG="$DIR/wallpaper.jpg"
LAST="$DIR/last.txt"

mkdir -p "$DIR"

API="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mkt=${MARKET:-en-IN}"

# Extract URLs directly (no big variables)
mapfile -t ARR < <(
  curl -s "$API" |
  grep -o '"url":"[^"]*"' |
  cut -d'"' -f4
)

COUNT=${#ARR[@]}
[ "$COUNT" -eq 0 ] && exit 1

# Read last once (no repeated cat)
[ -f "$LAST" ] || echo "" > "$LAST"
LAST_URL=$(<"$LAST")

# Pick random safely (no infinite loop)
INDEX=$((RANDOM % COUNT))
URL="${ARR[$INDEX]}"

# If same, just shift index (O(1), no loop)
if [ "$URL" = "$LAST_URL" ] && [ "$COUNT" -gt 1 ]; then
    INDEX=$(((INDEX + 1) % COUNT))
    URL="${ARR[$INDEX]}"
fi

echo "$URL" > "$LAST"

# Download directly (overwrite, no rm needed)
curl -f -s "https://www.bing.com$URL" -o "$IMG" || exit 1

echo "Wallpaper updated"