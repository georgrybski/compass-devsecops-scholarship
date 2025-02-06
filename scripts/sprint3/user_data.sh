#!/bin/bash
set -euo pipefail

EFS_VOLUME="/mnt/efs"
WORDPRESS_VOLUME="/var/www/html"

DATABASE_HOST="database_host"
DATABASE_USER="database_user"
DATABASE_PASSWORD="database_password"
DATABASE_NAME="database_name"

EFS_DNS="efs_dns"

DOCKER_COMPOSE_PATH="/bin/docker-compose"
COMPOSE_FILE="/home/ec2-user/docker-compose.yaml"
DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"

NFS_OPTIONS="nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=1000,retrans=2,noresvport"


prepare_volume_dir() {
  echo "Creating mount directory: $EFS_VOLUME..." &&
  sudo mkdir -p "$EFS_VOLUME" ||
    { echo "Error: Failed to create directory $EFS_VOLUME"; return 1; }
}

is_volume_mounted() {
  mountpoint -q "$EFS_VOLUME"
}

do_mount() {
  echo "Mounting EFS volume..." &&
  sudo mount -t nfs4 -o "$NFS_OPTIONS" "${EFS_DNS}:/ " "$EFS_VOLUME" ||
    { echo "Error: Failed to mount EFS volume"; return 1; }
}

set_volume_permissions() {
  echo "Setting permissions for EFS volume..." &&
  sudo chown -R 33:33 "$EFS_VOLUME" &&
  sudo chmod -R 775 "$EFS_VOLUME" ||
    { echo "Error: Failed to set permissions on $EFS_VOLUME"; return 1; }
}

mount_efs() {
  echo "Setting up EFS volume..." &&
  prepare_volume_dir &&
  ( is_volume_mounted && echo "EFS volume already mounted." || do_mount ) &&
  set_volume_permissions
}

update_system() {
  echo "Updating system and installing dependencies..." &&
  sudo yum update -y &&
  sudo yum install -y docker amazon-efs-utils
}

configure_docker() {
  echo "Configuring Docker..." &&
  sudo usermod -aG docker "$(whoami)" &&
  sudo systemctl start docker &&
  sudo systemctl enable docker
}

install_docker_compose() {
  echo "Installing Docker Compose..." &&
  curl -L "$DOCKER_COMPOSE_URL" -o "$DOCKER_COMPOSE_PATH" &&
  sudo chmod +x "$DOCKER_COMPOSE_PATH"
}

create_docker_compose_file() {
  echo "Creating Docker Compose file at $COMPOSE_FILE..." &&
  cat <<EOL | sudo tee "$COMPOSE_FILE" > /dev/null
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - ${EFS_VOLUME}${WORDPRESS_VOLUME}:/${WORDPRESS_VOLUME}
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: ${DATABASE_HOST}
      WORDPRESS_DB_USER: ${DATABASE_USER}
      WORDPRESS_DB_PASSWORD: ${DATABASE_PASSWORD}
      WORDPRESS_DB_NAME: ${DATABASE_NAME}
EOL
}

run_docker_compose() {
  echo "Starting Docker Compose services..." &&
  sudo docker-compose -f "$COMPOSE_FILE" up -d
}

main() {
  update_system &&
  configure_docker &&
  mount_efs &&
  install_docker_compose &&
  create_docker_compose_file &&
  run_docker_compose
}

main