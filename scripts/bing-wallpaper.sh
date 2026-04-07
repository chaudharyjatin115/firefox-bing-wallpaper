#!/bin/bash

# load config
[ -f "$HOME/.config/bing-wallpaper.conf" ] && source "$HOME/.config/bing-wallpaper.conf"

DIR="$HOME/.local/share/bing-home"
IMG="$DIR/wallpaper.jpg"
LAST="$DIR/last.txt"

mkdir -p "$DIR"
touch "$LAST"

API="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=$LIMIT&mkt=${MARKET:-en-IN}"

# decide wallpapers based on interval
INTERVAL="${INTERVAL:-6h}"

case "$INTERVAL" in
  1h) LIMIT=7 ;;
  6h) LIMIT=4 ;;
  12h) LIMIT=2 ;;
  24h) LIMIT=1 ;;
  *) LIMIT=4 ;;
esac

API="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=$LIMIT&mkt=${MARKET:-en-IN}"

# grab wallpaper urls
mapfile -t ARR < <(
  curl -s "$API" |
  grep -o '"url":"[^"]*"' |
  cut -d'"' -f4
)

COUNT=${#ARR[@]}
[ "$COUNT" -eq 0 ] && exit 1

LAST_URL=$(<"$LAST")

# pick wallpaper
if [ "$LIMIT" -eq 1 ]; then
  URL="${ARR[0]}"   # latest only
else
  INDEX=$((RANDOM % COUNT))
  URL="${ARR[$INDEX]}"

  # avoid repeating same one
  if [ "$URL" = "$LAST_URL" ] && [ "$COUNT" -gt 1 ]; then
    INDEX=$(((INDEX + 1) % COUNT))
    URL="${ARR[$INDEX]}"
  fi
fi

echo "$URL" > "$LAST"

# Download directly (overwrite, no rm needed)
curl -f -s "https://www.bing.com$URL" -o "$IMG" || exit 1

echo "Wallpaper updated"