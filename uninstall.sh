#!/bin/bash

echo "Removing Bing wallpaper setup"
echo ""

# Stop timer first
systemctl --user disable --now bing-wallpaper.timer 2>/dev/null || true

# Remove systemd files
rm -f ~/.config/systemd/user/bing-wallpaper.service
rm -f ~/.config/systemd/user/bing-wallpaper.timer

# Remove installed script
rm -f ~/.local/bin/bing-wallpaper.sh

# Optional: remove downloaded wallpapers
read -rp "Remove downloaded wallpapers too? (y/N): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    rm -rf ~/.local/share/bing-home
    echo "Wallpaper cache removed"
fi

# Reload systemd
systemctl --user daemon-reload

echo ""
echo "Removed successfully"