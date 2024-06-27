#!/bin/bash
sudo apt install -y git
sudo apt install -y openjdk-21-jre
sudo apt-get install -y jq

mkdir -p ~/.postgresql && \
wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
     --output-document ~/.postgresql/root.crt && \
chmod 0600 ~/.postgresql/root.crt