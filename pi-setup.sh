#!/bin/bash
SETUP_COMPLETE_FILE=/var/.pisetup
if [[ -f "$FILE" ]]; then
    echo "Setup has run, skipping"
    exit 0
fi

# Setup Rapsi-Config
/usr/lib/raspi-config/init_resize.sh

source /boot/montior.env

sudo aspi-config nonint do_hostname "$HOSTNAME"
sudo raspi-config nonint do_ssh 1
sudo raspi-config nonint do_wifi_country "US"
sudo raspi-config nonint do_wifi_passphrase "$WIFISSID" "$WIFIPSK"

# Update and upgrade
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

# Install mosquito
# get repo key
wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key

#add repo
sudo apt-key add mosquitto-repo.gpg.key

#download appropriate lists file
cd /etc/apt/sources.list.d/
sudo wget http://repo.mosquitto.org/debian/mosquitto-buster.list

#update caches and install
sudo apt-cache search mosquitto
sudo apt-get update
sudo apt-get install -f libmosquitto-dev mosquitto mosquitto-clients libmosquitto1

# Install package
sudo apt-get install -y vim git pi-bluetooth

# Install monitor
cd ~
git clone https://github.com/constructorfleet/monitor.git
git clone https://github.com/constructprfleet/monitor-setup-script.git
for template in ~/monitor-setup-script/*.template; do
    templatename=$(basename -- "$i")
    outputname=${filename%.*}
    cat $template | envsubst "$(env | cut -d= -f1 | sed -e 's/^/$/')" > ~/monitor/$outputname
cd monitor/
sudo touch SETUP_COMPLETE_FILE
sudo bash monitor.sh
