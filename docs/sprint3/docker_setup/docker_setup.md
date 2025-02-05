[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](docker_setup.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](docker_setup.md)

---

# Docker Installation and Configuration

This guide explains how Docker (and Docker Compose) is installed and configured on the EC2 hosts via an automated startup script.

## Overview
The EC2 instances are pre‑configured to run a `user_data.sh` script that:
- Updates OS packages.
- Installs Docker and Docker Compose.
- Starts and enables the Docker service.
- Adds the default user (e.g., `ec2-user`) to the Docker group.
- Installs NFS utilities and creates the EFS mount point (`/mnt/efs`).

## Sample `user_data.sh`
Here is a sample script used during instance launch:

```bash
    #!/bin/bash
    # Update the system
    sudo yum update -y
    
    # Install Docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add the ec2-user to the Docker group
    sudo usermod -aG docker ec2-user
    
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Install NFS utilities and create the EFS mount point
    sudo yum install -y nfs-utils
    sudo mkdir -p /mnt/efs
    sudo chmod 777 /mnt/efs
    
    # (Optional) Mount EFS manually (replace <EFS_DNS_NAME> with your EFS endpoint)
    # sudo mount -t nfs4 -o nfsvers=4.1 <EFS_DNS_NAME>:/ /mnt/efs
```

## Verification
After boot-up, verify that:
- Docker is running: `docker ps`
- Docker Compose is installed: `docker-compose --version`
- The EFS directory exists: `ls /mnt/efs`

> **Note:** Adjust commands if you’re using Ubuntu or another distribution.

---
