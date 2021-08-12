#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install nginx -y
sudo gsutil cp gs://backend-storage-44/default /etc/nginx/sites-available/default;
export IP_ADDRESS=10.1.0.99
sudo service nginx restart
sudo curl -L https://toolbelt.treasuredata.com/sh/install-debian-buster-td-agent4.sh  | sh
sudo usermod -aG adm td-agent
sudo /usr/sbin/td-agent-gem install fluent-plugin-bigquery
sudo gsutil cp gs://backend-storage-44/td-agent.conf /etc/td-agent/td-agent.conf
sudo systemctl restart td-agent
