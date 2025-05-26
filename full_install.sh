#/!bin/bash

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (sudo)."
    exit 1
fi

CWD=$(pwd)

# Reading data of new user to panel
read -p "Введите имя пользователя: " USER_NAME
read -p "Введите пароль пользователя: " USER_PASSWD

adduser --disabled-password --gecos '' $USER_NAME

echo "$USER_NAME:$USER_PASSWD" | chpasswd

usermod -aG sudo $USER_NAME

cd /home/$USER_NAME

apt update
apt install -y curl

bash <(curl -sSL https://get.docker.com)

git clone https://github.com/MHSanaei/3x-ui.git
cd 3x-ui

mkdir grafana/ prometheus/

cat <<EOF> grafana/prometheus.yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: http://$PROMETHEUS_URL
EOF

cat <<EOF> prometheus/prometheus.yml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: "proxy"
    static_configs:
      - targets: ['x-ui-exporter:9080']
EOF

cp $CWD/docker-compose.yml .

docker compose up -d

usermod -aG docker $USER_NAME

IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo -e "\033[32mPanel is installed, check\033[0;39m $IP_ADDRESS:2053 \033[32min browser\033[0;39m"
