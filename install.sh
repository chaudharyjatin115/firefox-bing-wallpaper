
#!/bin/bash

set -e

echo ""
echo "Setting up Bing wallpaper for Firefox"
echo ""

# todo:  auto-detect this later 
read -rp "Firefox directory (~/.mozilla/firefox): " FIREFOX_DIR

# expand ~ (bash sometimes doesn’t here)
FIREFOX_DIR="${FIREFOX_DIR/#\~/$HOME}"

if [ ! -d "$FIREFOX_DIR" ]; then
  echo "Path not found, exiting..."
  exit 1
fi

echo ""
echo "Profiles:"
ls "$FIREFOX_DIR"
echo ""

# NOTE: keeping manual selection to avoid picking wrong profile
read -rp "Profile folder (xxxx.default-release): " PROFILE_NAME

PROFILE_PATH="$FIREFOX_DIR/$PROFILE_NAME"

if [ ! -d "$PROFILE_PATH" ]; then
  echo "Invalid profile."
  exit 1
fi

echo ""
echo "Using: $PROFILE_PATH"
echo ""

# using realpath because username mismatch was breaking earlier
HOME_DIR="$(realpath ~)"


# echo "DEBUG: home = $HOME_DIR"

echo "Home: $HOME_DIR"
echo ""

# timer selection
echo "Update interval:"
echo "1) 1h"
echo "2) 6h"
echo "3) 12h"
echo "4) 24h"
echo ""

read -rp "Choice: " CHOICE

case "$CHOICE" in
  1) INTERVAL="1h" ;;
  2) INTERVAL="6h" ;;
  3) INTERVAL="12h" ;;
  4) INTERVAL="24h" ;;
  *)
    echo "Invalid, defaulting to 6h"
    INTERVAL="6h"
    ;;
esac

echo ""
echo "Interval set to $INTERVAL"
echo ""

# dirs should exist but eh
mkdir -p "$HOME_DIR/.local/bin"
mkdir -p "$HOME_DIR/.local/share/bing-home"
mkdir -p "$PROFILE_PATH/chrome"

# installer script
echo "Copying script..."
cp scripts/bing-wallpaper.sh "$HOME/.local/bin/bing-wallpaper.sh"

# fix possible windows line endings (prevents systemd exec errors)
sed -i 's/\r$//' "$HOME/.local/bin/bing-wallpaper.sh"

chmod +x "$HOME/.local/bin/bing-wallpaper.sh"

# CSS injection 
echo "Writing CSS..."

cat > "$PROFILE_PATH/chrome/userContent.css" << EOF
/* quick hack, works fine */
@-moz-document url("about:home"), url("about:newtab") {
  body {
    background-image: url("file://$HOME_DIR/.local/share/bing-home/wallpaper.jpg") !important;
    background-size: cover !important;
    background-position: center !important;
    background-repeat: no-repeat !important;
  }
}
EOF

# systemd config
echo ""
echo "Setting up timer..."

mkdir -p "$HOME_DIR/.config/systemd/user"

cat > "$HOME_DIR/.config/systemd/user/bing-wallpaper.service" << EOF
[Unit]
Description=Bing wallpaper updater

[Service]
Type=oneshot
ExecStart=$HOME_DIR/.local/bin/bing-wallpaper.sh
EOF
cat > "$HOME_DIR/.config/systemd/user/bing-wallpaper.timer" << EOF
[Unit]
Description=Bing wallpaper timer

[Timer]
OnBootSec=2min
OnUnitActiveSec=$INTERVAL
Persistent=true

[Install]
WantedBy=timers.target
EOF


# reload systemd 
systemctl --user daemon-reload

systemctl --user enable --now bing-wallpaper.timer

# fix for arch user servics
loginctl enable-linger "$USER" >/dev/null 2>&1 || true

# run once so user notices changes immediately
echo ""
echo "Fetching first wallpaper..."
"$HOME_DIR/.local/bin/bing-wallpaper.sh"

echo ""
echo "Done."
echo ""

echo "Important:"
echo "about:config -> toolkit.legacyUserProfileCustomizations.stylesheets = true"
echo "restart firefox after that"
echo ""

# todo:
# - maybe add uninstall script improvements
# - maybe support multiple profiles