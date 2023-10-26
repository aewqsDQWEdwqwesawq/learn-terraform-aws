#!/bin/sh



wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.1-arm64.deb
sudo dpkg -i influxdb2-2.7.1-arm64.deb
sudo apt update
sudo apt install influxdb -y
sudo systemctl start influxdb
sudo apt install influxdb-client -y
sudo systemctl restart influxdb-client
sudo systemctl enable influxdb
sudo systmectl enable influxdb-client

sudo echo 'Port 22' >> /etc/ssh/sshd_config
sudo systemctl restart sshd