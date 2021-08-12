#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install tomcat9 -y


sudo gsutil cp gs://backend-storage-44/sample.war /var/lib/tomcat9/webapps/sample.war

sudo systemctl tomcat9 restart
