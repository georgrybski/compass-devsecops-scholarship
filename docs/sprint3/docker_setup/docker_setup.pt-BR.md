[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](docker_setup.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](docker_setup.md)

---

# Instalação e Configuração do Docker

Este guia explica como o Docker (e o Docker Compose) é instalado e configurado nas instâncias EC2 por meio de um script de inicialização automatizado.

## Visão Geral
As instâncias EC2 são pré-configuradas para executar um script `user_data.sh` que:
- Atualiza os pacotes do sistema operacional.
- Instala o Docker e o Docker Compose.
- Inicia e habilita o serviço Docker.
- Adiciona o usuário padrão (ex.: `ec2-user`) ao grupo Docker.
- Instala utilitários NFS e cria o ponto de montagem do EFS (`/mnt/efs`).

## Exemplo de `user_data.sh`
Segue um script de exemplo utilizado durante o lançamento da instância:

```bash
    #!/bin/bash
    # Atualiza o sistema
    sudo yum update -y
    
    # Instala o Docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Adiciona o ec2-user ao grupo Docker
    sudo usermod -aG docker ec2-user
    
    # Instala o Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Instala utilitários NFS e cria o ponto de montagem do EFS
    sudo yum install -y nfs-utils
    sudo mkdir -p /mnt/efs
    sudo chmod 777 /mnt/efs
    
    # (Opcional) Monte o EFS manualmente (substitua <EFS_DNS_NAME> pelo endpoint do seu EFS)
    # sudo mount -t nfs4 -o nfsvers=4.1 <EFS_DNS_NAME>:/ /mnt/efs
```

## Verificação
Após a inicialização, verifique que:
- O Docker está rodando: `docker ps`
- O Docker Compose está instalado: `docker-compose --version`
- O diretório do EFS existe: `ls /mnt/efs`

> **Observação:** Ajuste os comandos se estiver utilizando Ubuntu ou outra distribuição.

---
