#!/bin/bash
sudo apt install -y git
sudo apt install -y docker.io
sudo add-apt-repository ppa:longsleep/golang-backports -y
sudo apt update
sudo apt install -y golang
sudo apt install make

mkdir -p ~/.postgresql && \
wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
     --output-document ~/.postgresql/root.crt && \
chmod 0600 ~/.postgresql/root.crt