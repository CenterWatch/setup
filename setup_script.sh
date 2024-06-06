#!/bin/bash

# Vai ser um setup diferente para cada integrante do grupo?
# echo "Desinstalando possíveis dependências e aplicações que possam causar conflito"
# sudo for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Adicionando chave GPG oficial Docker 
echo "Adicionando chave GPG oficial Docker"
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Adicionando repositório no apt source
echo "Adicionando repositório no apt source"
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

echo "Instalando pacotes Docker"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Instalar arquivo docker-compose.yml

wget -O docker-compose.yml https://raw.githubusercontent.com/Lucas-Oristanio/jar_client/main/docker-compose.yml

sudo docker compose up