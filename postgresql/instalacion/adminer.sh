#!/bin/bash

docker image pull docker.io/library/adminer:latest
docker container create --name adminer -p 8080:8080 adminer
docker container start adminer

sudo firewall-cmd --permanent --add-port=1234/tcp
sudo firewall-cmd --reload
