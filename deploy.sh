#!/bin/bash

function init ()
{
  #SET DATABASE PASSWORD
  read -s -p "Please, provide a root password for database: " dbrootpasswd
  read -s -p "Please, provide a password for user of npm database: " dbnpmpasswd

  #SET CONTAINER VOLUMES INSTALLATION PATH
  read -p "Please, provide an installation path for npm application volumes (must be an absolute path !!)" installpath

  #CHECK IF VOLUME PATH EXIST
  if [ -d $volpath ];then
    echo "directory "$volpath" already exist"
  else
    echo "creating "$volpath" directory"
    mkdir -p $volpath/npm-reverse-proxy
  fi
}

function update ()
{
  #SECURITY AND UPDATE
  apt update && apt install gnupg2 software-properties-common -y && apt upgrade -y && apt install unattended-upgrades -y

  #BASIC DEPENDENCIES
  apt install git curl apt-transport-https ca-certificates libffi-dev libssl-dev python3 python3-pip -y
  apt-get remove python-configparser
}

function docker ()
{
  # DOCKER-CE AND DOCKER-COMPOSE INSTALLATION
  curl -sSL https://get.docker.com | sh
  pip3 install docker-compose
}

function deploy()
{
  #SETUP
  cp docker-compose.yaml.orig docker-compose.yaml
  sed -i "s/PATH/$volpath/g" docker-compose.yaml
  sed -i "s/rootpass/$dbrootpasswd/g" docker-compose.yaml
  sed -i "s/passwd/$dbnpmpasswd/g" docker-compose.yaml

  #DEPLOY CONTAINER
  docker-compose up -d

  #CLEAN DOCKER-COMPOSE FROM REPO AND MOVE IT TO INSTALLATION PATH
  mv docker-compose.yaml $volpath/npm-reverse-proxy/docker-compose.yaml

  echo "Your instance is deployed on http://YOUR_IP_ADRESS:81"
  echo "default login are : admin@example.com / changeme"
}

#INIT SCRIPT WITH USER PARAMETERS
#init

#UPDATE PACKAGES
while true
do
  read -r -p "Do you want to update and upgrade packages ? [Yes/No]" input
  case $input in [yY][eE][sS]|[yY])
    update
    break
    ;;
  [nN][oO]|[nN])
    break
    ;;
  *)
    echo "Please answer yes or no.."
    ;;
  esac
done

#CHECK DOCKER INSTALLATION
dcis=$(pip3 list | grep docker-compose | tail -n1 | awk {print'$1'})
echo "dcis = "$dcis
if [[ $dcis = "docker-compose" ]];then
  echo "docker-compose is installed"
else
  echo "docker-compose is not installed"
  #docker
fi
#DEPLOY NPM
#deploy
