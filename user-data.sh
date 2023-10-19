#!/bin/bash

sudo apt update
sudo apt install nginx -y
sudo systemctl restart nginx


wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list

sudo apt update && sudo apt install -y telegraf
sudo bash -c "cat << EOF >> /etc/telegraf/telegraf.conf
[[outputs.influxdb]]
  urls = [\"http://${dbip}:8086\"]
  database = \"telegraf\"
  username = \"telegraf\"
  password = \"password\"
EOF"
sudo systemctl restart telegraf
