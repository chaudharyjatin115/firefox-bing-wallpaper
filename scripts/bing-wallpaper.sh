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

# grabbing  wallpaper urls
mapfile -t ARR < <(
  curl -s "$API" |
  grep -o '"url":"[^"]*"' |
  cut -d'"' -f4
)

COUNT=${#ARR[@]}
[ "$COUNT" -eq 0 ] && exit 1

LAST_URL=$(<"$LAST")

# pick wallpaperon rotation base
if [ "$LIMIT" -eq 1 ]; then
  URL="${ARR[0]}"   # latest only
else
  INDEX_FILE="$DIR/index.txt"

  # create if missing
  [ -f "$INDEX_FILE" ] || echo 0 > "$INDEX_FILE"

  CURRENT_INDEX=$(<"$INDEX_FILE")

  NEXT_INDEX=$(( (CURRENT_INDEX + 1) % COUNT ))

  URL="${ARR[$NEXT_INDEX]}"

  echo "$NEXT_INDEX" > "$INDEX_FILE"
fi
echo "$URL" > "$LAST"

curl -f -s "https://www.bing.com$URL" -o "$IMG" || exit 1
echo "$URL" > "$LAST"

# Download directly 
curl -f -s "https://www.bing.com$URL" -o "$IMG" || exit 1

echo "Wallpaper updated"