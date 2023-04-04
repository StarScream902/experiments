#!/usr/bin/env bash

yum update -y
# yum install -y httpd
# systemctl start httpd
# systemctl enable httpd
# echo "Host $(hostname -f)" > /var/www/html/index.html

yum install -y docker python3-pip git
rm -rf /usr/lib/python3.9/site-packages/requests*
pip3 install docker-compose

systemctl start docker.service
systemctl enable docker.service

cd /opt/

git clone https://github.com/StarScream902/experiments.git

cd experiments/Python/cpu-load-app

docker-compose up -d
