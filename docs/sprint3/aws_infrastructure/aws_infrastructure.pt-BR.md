[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](aws_infrastructure.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](aws_infrastructure.md)

---

# Configuração da Infraestrutura AWS

Este documento detalha os componentes e os passos de configuração na AWS necessários para suportar a implantação do WordPress.

## Visão Geral da Arquitetura
A solução utiliza diversos serviços da AWS:
- **VPC & Sub-redes:** Uma VPC dedicada (ex.: CIDR `10.0.0.0/16`) com pelo menos duas sub-redes públicas (para o Load Balancer) e duas sub-redes privadas (para EC2, RDS e EFS).
- **Grupos de Segurança:** Regras personalizadas para EC2, RDS, EFS e o Load Balancer para regular o tráfego.
- **Instâncias EC2:** Hosts Docker rodando em duas Zonas de Disponibilidade diferentes, gerenciadas por um Auto Scaling Group.
- **RDS MySQL:** Uma instância MySQL gerenciada com credenciais seguras e acesso restrito.
- **EFS:** Um sistema de arquivos compartilhado montado nas instâncias EC2 para armazenamento persistente do WordPress.
- **Load Balancer:** Distribui o tráfego HTTP para as instâncias EC2, garantindo que o WordPress não seja exposto via IP público.

## Passos Detalhados

### 1. VPC e Sub-redes
- **VPC:** Crie uma VPC (ex.: CIDR `10.0.0.0/16`).
- **Sub-redes:** Provisione duas sub-redes públicas (para o Load Balancer) e duas sub-redes privadas (para EC2, RDS e EFS).

### 2. Grupos de Segurança
- **SG da EC2:** Permitir SSH (porta 22) a partir do seu IP, HTTP (porta 80) do LB e NFS (porta 2049) do EFS.
- **SG do RDS:** Permitir tráfego MySQL (porta 3306) somente a partir do SG da EC2.
- **SG do EFS:** Permitir NFS (porta 2049) a partir do SG da EC2.
- **SG do LB:** Abrir HTTP (porta 80) para a internet.

### 3. Instâncias EC2
- Lance instâncias (por exemplo, Amazon Linux 2 ou Ubuntu) em duas Zonas de Disponibilidade diferentes.
- Utilize um script `user_data.sh` para instalar Docker, Docker Compose e montar o EFS (veja [Instalação do Docker](../docker_setup/docker_setup.pt-BR.md)).
- Certifique-se de que as instâncias estão registradas no Auto Scaling Group.

### 4. RDS MySQL
- Crie uma instância RDS utilizando MySQL (por exemplo, `db.t3.micro`).
- Defina um nome de banco de dados (ex.: `wordpress`), um usuário principal e uma senha.
- Implemente o RDS em sub-redes privadas com o SG do RDS anexado.

### 5. EFS
- Crie um sistema de arquivos EFS em sua VPC.
- Configure os targets de montagem nas sub-redes privadas.
- Atualize as instâncias EC2 (ou o arquivo `fstab`) para que `/mnt/efs` seja montado na inicialização.

### 6. Load Balancer & Auto Scaling
- Consulte [Configuração do Load Balancer & Auto Scaling](../lb_autoscaling/lb_autoscaling.pt-BR.md) para detalhes completos.

> **Dica:** Verifique duas vezes as configurações de rede (sub-redes, grupos de segurança) no Console AWS para evitar problemas de conectividade.

---
