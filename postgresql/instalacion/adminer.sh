#!/bin/bash

docker image pull adminer:latest
docker container create --name adminer -p 8080:8080 adminer
docker container start adminer

#docker run --name adminer -p 8080:8080 -d adminer:latest

sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload


    