#!/bin/bash

password=$1

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

if [[ $password = "" ]]; then
	log "Please provide the user password"
	exit 0
fi

log "APT UPDATE"

wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"| tee /etc/apt/sources.list.d/brave-browser-release.list

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
echo "deb [arch=amd64] https://download.docker.com/linux/debian bullseye stable" | tee  /etc/apt/sources.list.d/docker.list

apt update

apt install -y dbus-x11 sshpass google-chrome-stable sublime-text dirmngr gnupg xfce4-terminal snapd tldr flameshot bloodhound keepass2 brave-browser golang xfce4-genmon-plugin gimp vlc audacity bat docker-ce docker-ce-cli docker-compose containerd.io bettercap hostapd mdk4 asleap isc-dhcp-server hostapd-wpe hcxdumptool hcxtools beef-xss lighttpd openvpn-systemd-resolved libreoffice seclists


user=$(ls /home)

log "Detected user: $user"

usermod -aG docker $user
newgrp docker << TEST
echo "new group docker created"
TEST

cd "/home/$user/Pictures"

if [ ! -e "wallpaper.jpg" ]; then
	log "Downloading wallpaper..."
	sudo -u "$user" wget "https://raw.githubusercontent.com/migue27au/auto_kali_configuration/main/wallpaper.jpg"
fi

log "enabling ssh service"
systemctl start ssh

log "Setting wallpaper..."
sudo -u "$user" sshpass -p "$password" ssh "$user@localhost" -o StrictHostKeyChecking=no -x "xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s /home/$user/Pictures/wallpaper.jpg"
sshpass -p "$password" ssh "$user@localhost" -o StrictHostKeyChecking=no -x "xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s /home/$user/Pictures/wallpaper.jpg"

log "disabling ssh service"
sudo systemctl stop ssh

log "Downloading oh-my-zsh"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

cd /tmp
wget https://raw.githubusercontent.com/migue27au/auto_kali_configuration/main/root-theme.zsh-theme
cd /tmp
wget https://raw.githubusercontent.com/migue27au/auto_kali_configuration/main/user-theme.zsh-theme

ln=$(grep "^ZSH_THEME" /root/.zshrc -n | cut -d ':' -f1)
sed -i "${ln}c ZSH_THEME=\"my-custom-theme\"" /root/.zshrc

cp -r /root/.oh-my-zsh "/home/$user/"
cp -r /root/.zshrc "/home/$user/"

mv "/tmp/root-theme.zsh-theme" "/root/.oh-my-zsh/custom/themes/my-custom-theme.zsh-theme"
mv "/tmp/user-theme.zsh-theme" "/home/$user/.oh-my-zsh/custom/themes/my-custom-theme.zsh-theme"

chown -R "$user:$user" "/home/$user/.zshrc"
chown -R "$user:$user" "/home/$user/.oh-my-zsh"

log "Changing keyboard layout to es"
setxkbmap es

log "Configuring shortcuts"
sudo -u "$user" xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Primary><Alt>t' -t string -s '/usr/bin/xfce4-terminal'
sudo -u "$user" xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Shift><Super>s' -t string -s '/usr/bin/flameshot gui' --create

log "downloading tools"

pip install frida frida-tools objection uploadserver

mkdir /opt/tools
cd /opt/tools

wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1l_vCY5w-r1vHleUpqPCN0pXVZNBDpA5X' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1l_vCY5w-r1vHleUpqPCN0pXVZNBDpA5X" -O AD_Tools.7z && rm -rf /tmp/cookies.txt

7z x AD_Tools.7z -pAD_Tools

git clone https://github.com/migue27au/nmap-info
git clone https://github.com/migue27au/ping-sweep
git clone https://github.com/v1s1t0r1sh3r3/airgeddon
git clone https://github.com/migue27au/toolbar_tools

chmod +x /opt/tools/nmap-info/nmap-info.py
chmod +x /opt/tools/ping-sweep/ping-sweep

ln -s /opt/tools/nmap-info/nmap-info.py /usr/bin/nmap-info
ln -s /opt/tools/ping-sweep/ping-sweep /usr/bin/ping-sweep
ln -s /opt/tools/toolbar_tools/target.sh /usr/bin/target

cd /opt/tools

sudo apt-get install -y --no-install-recommends git ca-certificates build-essential pkg-config libreadline-dev gcc-arm-none-eabi libnewlib-dev qtbase5-dev libbz2-dev liblz4-dev libbluetooth-dev libpython3-dev libssl-dev

git clone https://github.com/RfidResearchGroup/proxmark3
cd proxmark3

make accessrights
make clean && make -j
make install

cd /opt/tools
mkdir kerbrute
cd kerbrute
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64
mv kerbrute_linux_amd64 kerbrute
ln -s /opt/tools/kerbrute/kerbrute_linux_amd64 /usr/bin/kerbrute

chown -R "$user:$user" /opt/tools
apt upgrade -y 
