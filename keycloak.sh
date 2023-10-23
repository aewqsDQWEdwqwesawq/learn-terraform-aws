#!/bin/bash
sudo apt update
sudo apt install openjdk-11-jdk
wget https://github.com/keycloak/keycloak/releases/download/21.1.2/keycloak-21.1.2.tar.gz
tar -zxvf keycloak-22.0.4.tar.gz
cd keycloak-17.0.0/
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=password
sudo -E $PWD/keycloak-17.0.0/bin/kc.sh start-dev