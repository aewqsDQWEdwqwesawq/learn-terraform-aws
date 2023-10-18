#!/bin/bash
sudo apt install adduser libfontconfig1 musl -y
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_10.1.5_amd64.deb
sudo dpkg -i grafana-enterprise_10.1.5_amd64.deb

sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl restart grafana-server
