#!/bin/bash

sudo docker -v
# Verificandoo se já tem docker instalado na máquina
if [ $? -eq 0 ]; then
    echo "Docker já instalado"
else
    echo "Instalando Docker..."

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
fi

# Instalar arquivo docker-compose.yml
# Só deve instalar se arquivo não existir na máquina
if [ -f docker-compose.yml ]; then
    echo "arquivo docker compose já instalado"
else
    echo "Baixando arquivo docker compose..."
    wget -O docker-compose.yml https://raw.githubusercontent.com/CenterWatch/setup/Setup-Lucas/docker-compose.yml
fi

# Sobe os containers, executa sempre que executar o script
echo "Iniciando containers"
sudo docker compose up