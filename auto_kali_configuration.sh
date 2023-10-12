#!/bin/bash
whoami=$(whoami)

if [[ $whoami -ne "root" ]]; then
	echo "Run this with sudo"
	exit 0
fi

echo ""

echo "Detected user: $whoami"

echo "Downloading wallpaper..."

cd /home/$whoami/Pictures
wget https://raw.githubusercontent.com/migue27au/auto_kali_configuration/main/wallpaper.png

echo "Setting wallpaper..."
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s /home/$whoami/Pictures/wallpaper.png

echo "Changing keyboard layout to es"
setxkbmap es