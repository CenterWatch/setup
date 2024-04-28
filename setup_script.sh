#!/bin/bash

echo "Fazendo update"
sudo apt update -y

java -version

if [ $? = 0 ]
    then echo "Java encontrado"
    java -version
    echo cut -b -2 $?
else
    echo "Instalando Java"
    sudo apt install openjdk-17-jre -y
fi

mysql -V

if [ $? = 0 ]
    then echo "MySql Server encontrado."
else
    echo "Instalando MySql Server"
    sudo apt install mysql-server -y

    echo "Iniciando servico MySql Server"
    sudo systemctl start mysql.service

    echo "Configurando MySql Server"
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'"
fi

unzip -v

if [ $? = 0 ]
    then echo "Unzip instalado."
else
    echo "Instalando Unzip."
    sudo apt install unzip -y
fi

ls CWatching/cwatching.jar

if [ $? = 0 ]
    then echo "Aplicação já instalada."
else
    echo "Baixando release da aplicação."
    wget https://github.com/CenterWatch/cwatching/releases/download/v0.1/cwatching+db.zip

    echo "Instalando aplicação"
    mkdir CWatching
    unzip cwatching+db.zip -d CWatching/
    rm cwatching+db.zip
fi

sudo mysql -u root -proot < CWatching/script.sql

echo "Iniciando aplicação"
clear
java -jar CWatching/cwatching.jar