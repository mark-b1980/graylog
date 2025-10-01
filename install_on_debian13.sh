#!/bin/bash

################################################################################################
# Check if running as root
################################################################################################
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

################################################################################################
# Change directory to script location
################################################################################################
script_dir=$(dirname "$0")
cd "$script_dir"

################################################################################################
# Install needed tools
################################################################################################
apt update
apt install -y openssh-server docker.io ufw
systemctl enable sshd
systemctl start sshd

################################################################################################
# Configure firewall
################################################################################################
ufw allow 22/tcp
ufw allow 9000/tcp
ufw allow 5140/tcp
ufw allow 5140/udp
ufw allow 5141/tcp
ufw allow 5141/udp
ufw enable 
ufw status

################################################################################################
# Chreate docker-compose and config file
################################################################################################
cp docker_compose_template.yml docker-compose.yml
cp config/graylog/graylog_conf_template.conf config/graylog/graylog.conf

# Generate random password and pepper
PASSWORD=$(openssl rand -base64 12)
PEPPER=$(openssl rand -base64 12)
PASSWORDHASH=$(echo -n "$PASSWORD" | sha256sum | awk '{print $1}')

# Prompt user for timezone and IP address
read -p "Enter the server TIMEZONE address: " TIMEZONE 
TIMEZONE="Europe/Berlin"
echo "SETTING TZ: $TIMEZONE"
read -p "Enter the server IP address: " ID 
IP="192.168.2.15"
echo "SETTING IP: $IP"

# Replace placeholders in docker-compose.yml
sed -i "s/%PASSWORD%/$PASSWORD/g" docker-compose.yml > docker-compose.yml
sed -i "s/%PEPPER%/$PEPPER/g" docker-compose.yml > docker-compose.yml
sed -i "s/%PASSWORDHASH%/$PASSWORDHASH/g" docker-compose.yml > docker-compose.yml
sed -i "s/%TIMEZONE%/$TIMEZONE/g" docker-compose.yml > docker-compose.yml
sed -i "s/%IP%/$IP/g" docker-compose.yml > docker-compose.yml

# Replace placeholders in graylog.conf
sed -i "s/%TIMEZONE%/$TIMEZONE/g" config/graylog/graylog.conf > config/graylog/graylog.conf

# Save credentials to a file
echo "Graylog admin password: $PASSWORD" > credentials.txt

################################################################################################
# Start Graylog stack
################################################################################################
#docker compose up -d

