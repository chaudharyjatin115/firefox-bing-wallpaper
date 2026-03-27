#!/bin/bash

INTERVAL=21600  # 6 hours
LOCKFILE="$HOME/.cache/bing-daemon.lock"
LOGFILE="$HOME/.cache/bing-daemon.log"

mkdir -p "$(dirname "$LOCKFILE")"

# Prevent multiple instances
if [ -f "$LOCKFILE" ]; then
  if kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
    echo "Daemon already running"
    exit 1
  else
    rm -f "$LOCKFILE"
  fi
fi

echo $$ > "$LOCKFILE"

echo "Starting Bing wallpaper daemon..." >> "$LOGFILE"

# Clean up on exit
trap "rm -f '$LOCKFILE'" EXIT

while true; do
  echo "Updating wallpaper at $(date)" >> "$LOGFILE"
  "$HOME/.local/bin/bing-home.sh" >> "$LOGFILE" 2>&1
  sleep $INTERVAL
done