#!/bin/bash

DIR="$HOME/.local/share/bing-home"
IMG="$DIR/wallpaper.jpg"
LAST="$DIR/last.txt"

mkdir -p "$DIR"

# Fetch only needed lines (less memory)
URLS=$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-IN"\
  | grep -o '"url":"[^"]*"' \
  | cut -d'"' -f4)

# Convert to array safely
readarray -t ARR <<< "$URLS"

COUNT=${#ARR[@]}
[ "$COUNT" -eq 0 ] && exit 1

# Pick different image
while true; do
    INDEX=$((RANDOM % COUNT))
    URL="${ARR[$INDEX]}"
    [ ! -f "$LAST" ] || [ "$URL" != "$(cat "$LAST")" ] && break
done

echo "$URL" > "$LAST"

# Download (no extra memory usage)
curl -s "https://www.bing.com$URL" -o "$IMG"

echo "Wallpaper updated"