#!/bin/bash
set -e

DATABASE_HOST="your-db-host.yourdomain.region.rds.amazonaws.com"
DATABASE_USER="your-db-user"
DATABASE_PASSWORD="your-db-password"
DATABASE_NAME="your-db-name"
EFS_DNS="your-efs-id.efs.your-region.amazonaws.com"

update_system() {
    sudo yum update -y
    sudo yum upgrade -y
}

install_dependencies() {
    sudo yum install -y amazon-efs-utils docker
}

mount_efs() {
    mkdir -p /mnt/efs
    sudo mount -t efs -o tls "${EFS_DNS}":/ /mnt/efs
}

setup_docker() {
    sudo usermod -a -G docker ec2-user
    newgrp docker
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
}

install_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

create_docker_compose_file() {
    cat <<EOF | sudo tee /home/ec2-user/docker-compose.yml > /dev/null
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: "${DATABASE_HOST}"
      WORDPRESS_DB_USER: "${DATABASE_USER}"
      WORDPRESS_DB_PASSWORD: "${DATABASE_PASSWORD}"
      WORDPRESS_DB_NAME: "${DATABASE_NAME}"
    volumes:
      - /mnt/efs/wp-content:/var/www/html/wp-content
    restart: always
EOF
}

deploy_wordpress() {
    cd /home/ec2-user
    docker-compose up -d
}

main() {
    update_system
    install_dependencies
    mount_efs
    setup_docker
    install_docker_compose
    create_docker_compose_file
    deploy_wordpress
}

main