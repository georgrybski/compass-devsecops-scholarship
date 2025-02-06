[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](docker_setup.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](docker_setup.md)

---

# Instalação e Configuração do Docker

Este guia explica como o Docker (e o Docker Compose) é instalado e configurado nas instâncias EC2 por meio de um script de inicialização automatizado.

## Visão Geral
As instâncias EC2 são pré-configuradas para executar um script `user_data.sh` que:
- Atualiza os pacotes do sistema operacional.
- Instala as dependências necessárias, incluindo Docker, Docker Compose e amazon-efs-utils.
- Monta um sistema de arquivos EFS em `/mnt/efs`.
- Configura o Docker, adicionando o usuário padrão (por exemplo, `ec2-user`) ao grupo Docker, e habilitando e iniciando o serviço Docker.
- Instala o Docker Compose.
- Cria um arquivo Docker Compose para implantar o WordPress.
- Realiza o deploy do container do WordPress utilizando o Docker Compose.

## Exemplo de `user_data.sh`
Segue um exemplo de script utilizado durante o lançamento da instância:

```bash
#!/bin/bash
set -e

DATABASE_HOST="your-db-host.yourdomain.region.rds.amazonaws.com"
DATABASE_USER="your-db-user"
DATABASE_PASSWORD="your-db-password"
DATABASE_NAME="your-db-name"
EFS_DNS="your-efs-id.efs.your-region.amazonaws.com"

atualizar_sistema() {
    sudo yum update -y
    sudo yum upgrade -y
}

instalar_dependencias() {
    sudo yum install -y amazon-efs-utils docker
}

montar_efs() {
    mkdir -p /mnt/efs
    sudo mount -t efs -o tls "${EFS_DNS}":/ /mnt/efs
}

configurar_docker() {
    sudo usermod -a -G docker ec2-user
    newgrp docker
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
}

instalar_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

criar_arquivo_docker_compose() {
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

implantar_wordpress() {
    cd /home/ec2-user
    docker-compose up -d
}

principal() {
    atualizar_sistema
    instalar_dependencias
    montar_efs
    configurar_docker
    instalar_docker_compose
    criar_arquivo_docker_compose
    implantar_wordpress
}

principal
```

## Verificação
Após a inicialização, verifique que:
- O Docker está rodando: `docker ps`
- O Docker Compose está instalado: `docker-compose --version`
- O diretório EFS existe: `ls /mnt/efs`

> **Observação:** Ajuste os comandos se estiver utilizando Ubuntu ou outra distribuição.
