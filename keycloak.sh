#!/bin/bash

ver=21.1.2

sudo apt update
sudo apt install openjdk-11-jdk -y
wget https://github.com/keycloak/keycloak/releases/download/$ver/keycloak-$ver.tar.gz
tar -zxvf keycloak-$ver.tar.gz
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=password
sudo -E $PWD/keycloak-$ver/bin/kc.sh start-dev