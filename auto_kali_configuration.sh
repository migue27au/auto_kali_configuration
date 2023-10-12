#!/bin/bash

function log {
    text=$1
    BOLDRED="\e[1;31m" # Rojo en negrita
    END="\e[0m" # Resetear los estilos y colores

    echo -e "${BOLDRED}${text}${END}"
}

whoami=$(whoami)

if [[ $whoami != "root" ]]; then
	log "Run this with sudo"
	exit 0
fi

log "APT UPDATE"

apt update

sudo apt install -y dbus-x11 xwallpaper

user=$(ls /home)

log "Detected user: $user"

cd "/home/$user/Pictures"
pwd 


if [ ! -e "wallpaper.jpg" ]; then
	log "Downloading wallpaper..."
	sudo -u $user wget "https://raw.githubusercontent.com/migue27au/auto_kali_configuration/main/wallpaper.jpg"
fi

log "Setting wallpaper..."

sudo -u $user xwallpaper --zoom "/home/$user/Pictures/wallpaper.jpg"

log "Changing keyboard layout to es"
sudo -u $user setxkbmap es

