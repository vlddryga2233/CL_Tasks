#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install tomcat9 -y


sudo gsutil cp gs://backend-storage-44/sample.war /var/lib/tomcat9/webapps/sample.war

sudo systemctl tomcat9 restart
