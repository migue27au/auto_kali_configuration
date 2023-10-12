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

log "Detected user: $whoami"

log "Downloading wallpaper..."

cd /home/$whoami/Pictures
wget https://raw.githubusercontent.com/migue27au/auto_kali_configuration/main/wallpaper.png

log "Setting wallpaper..."
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s /home/$whoami/Pictures/wallpaper.png

log "Changing keyboard layout to es"
setxkbmap es