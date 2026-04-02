# Firefox Bing Wallpaper

Minimal tool to set Bing daily wallpapers as Firefox homepage background.

## Features
- Random Bing wallpapers (last 7)
- custom interval timings 
- Uses systemd timer (no cron)
-  works on default homescreen no need to use firefox extensions 
- updates in background

- <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/b4ee6a53-615d-4a67-b63b-93413e50913d" />





## Dependencies

Required:
- curl
- grep (GNU grep)
- coreutils
- systemd
Optional:

- libnotify (for notifications)
- dos2unix (for line ending fixes)

On Arch Linux:
sudo pacman -S curl libnotify dos2unix

## Install

```bash
git clone https://github.com/chaudharyjatin115/firefox-bing-wallpaper.git
cd firefox-bing-wallpaper
chmod +x install.sh
./install.sh
