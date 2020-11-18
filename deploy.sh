#!/bin/bash

#SET PASSWORD
read -s -p "Set DB root password: " rootpasswd

read -s -p "Set DB user password: " npmpasswd

#SECURITY AND UPDATE
apt update && apt install gnupg2 software-properties-common -y && apt upgrade -y && apt install unattended-upgrades -y

#BASIC DEPENDENCIES
apt install git curl apt-transport-https ca-certificates libffi-dev libssl-dev python3 python3-pip -y
apt-get remove python-configparser

#DOCKER
curl -sSL https://get.docker.com | sh
pip3 install docker-compose

#SETUP
cp docker-compose.yaml.orig docker-compose.yaml
sed -i "s/rootpass/$rootpasswd/g" docker-compose.yaml
sed -i "s/passwd/$npmpasswd/g" docker-compose.yaml

#DEPLOY
docker-compose up -d

#CLEAN
#rm -f docker-compose.yaml

echo "Your instance is deployed on http://YOUR_IP_ADRESS:81"
echo "default login are : admin@example.com / changeme"
