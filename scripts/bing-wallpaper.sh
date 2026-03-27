# #!/bin/bash

# DIR="$HOME/.local/share/bing-home"
# IMG="$DIR/wallpaper.jpg"
# LAST="$DIR/last.txt"

# mkdir -p "$DIR"

# JSON=$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=7")

# mapfile -t URLS < <(echo "$JSON" | grep -oP '"url":"\K[^"]+')

# # fallback safety
# if [ ${#URLS[@]} -eq 0 ]; then
#     echo "Failed to fetch URLs"
#     exit 1
# fi

# # Pick a random image
# while true; do
#     INDEX=$((RANDOM % ${#URLS[@]}))
#     URL="${URLS[$INDEX]}"
#     if [ ! -f "$LAST" ] || [ "$URL" != "$(cat "$LAST")" ]; then
#         echo "$URL" > "$LAST"
#         break
#     fi
# done

# FULL_URL="https://www.bing.com$URL&$(date +%s)"

# curl -s "$FULL_URL" -o "$IMG"

# echo "Wallpaper updated at $(date)"

# # Notification
# if command -v notify-send >/dev/null 2>&1; then
#     notify-send "Bing Wallpaper" "Wallpaper updated"
# fi
#!/bin/bash

DIR="$HOME/.local/share/bing-home"
IMG="$DIR/wallpaper.jpg"
LAST="$DIR/last.txt"

mkdir -p "$DIR"

# Fetch only needed lines (less memory)
URLS=$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=7" \
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