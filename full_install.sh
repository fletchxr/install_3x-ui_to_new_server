#/!bin/bash

read -p "Введите имя пользователя: " USER_NAME
read -p "Введите пароль пользователя: " USER_PASSWD

adduser --disabled-password --gecos '' $USER_NAME

echo "$USER_NAME:$USER_PASSWD" | chpasswd

usermod -aG sudo $USER_NAME

cd /home/$USER_NAME

sudo apt update
sudo apt install -y curl

bash <(curl -sSL https://get.docker.com)

git clone https://github.com/MHSanaei/3x-ui.git
cd 3x-ui

docker compose up -d

IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "Panel is installed, check $IP_ADDRESS:2053 in browser"