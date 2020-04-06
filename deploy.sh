#!/bin/bash

#SET PASSWORD
read -e -i "$rootpasswd" -s -p "Set DB root password: " input
rootpasswd="${input:-$rootpasswd}"

read -e -i "$npmpasswd" -s -p "Set DB user password: " input
npmpasswd="${input:-$npmpasswd}"

#SECURITY AND UPDATE
apt update
apt install gnupg2 software-properties-common
apt upgrade -y
apt install unattended-upgrades -y

#BASIC DEPENDENCIES
apt install git curl apt-transport-https ca-certificates libffi-dev libssl-dev python3 python3-pip -y
apt-get remove python-configparser

#DOCKER
curl -sSL https://get.docker.com | sh
usermod -aG docker pi
pip3 install docker-compose

#SETUP
cp config.json.orig config.json
cp docker-compose.yaml.orig docker-compose.yaml
sed -i "s/psswd/$npmpasswd/g" config.json
sed -i "s/rootpass/$rootpasswd/g" docker-compose.yaml
sed -i "s/psswd/$npmpasswd/g" docker-compose.yaml

#DEPLOY
docker-compose up -d

#CLEAN
rm -f docker-compose.yaml

echo "Your instance is deployed on http://IP:81"
echo "default login are : admin@example.com / changeme"
