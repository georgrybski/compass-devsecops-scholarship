[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](lb_autoscaling.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](lb_autoscaling.md)

---

# Configuração do Load Balancer & Auto Scaling

Este documento cobre como configurar um Load Balancer e um Auto Scaling Group (ASG) para que sua implantação permaneça altamente disponível e escalável em duas Zonas de Disponibilidade.

## Configuração do Load Balancer

### Visão Geral
- **Tipo:** Utilize um Application Load Balancer (ALB) ou um Classic Load Balancer (se necessário).
- **Listeners:** Configure HTTP na porta 80.
- **Sub-redes:** Anexe o LB a pelo menos duas sub-redes públicas (uma por Zona de Disponibilidade).
- **Grupo de Segurança:** Permita HTTP (porta 80) de entrada da internet.

### Passos
1. **Crie o Load Balancer:**
    - No Console AWS, navegue até “Load Balancers.”
    - Crie um novo ALB (ou Classic LB) com o nome e as configurações desejadas.
    - Anexe-o às suas sub-redes públicas.

2. **Configure os Target Groups:**
    - Crie um target group para suas instâncias EC2 (protocolo HTTP, porta 80).
    - Defina os parâmetros do health check (por exemplo, um caminho de verificação como `/` ou `/wp-admin/install.php`).

3. **Registre os Targets:**
    - Inicialmente, registre uma instância EC2 para teste.
    - Posteriormente, ao utilizar Auto Scaling, as instâncias serão registradas automaticamente.

## Configuração do Auto Scaling Group (ASG)

### Visão Geral
- **Objetivo:** Garantir que duas instâncias EC2 (uma por Zona de Disponibilidade) estejam sempre em execução.
- **Launch Template:** Utilize um Launch Template que incorpore seu script `user_data.sh`.
- **Política de Escalonamento:** Opcionalmente, defina políticas baseadas em CPU ou métricas de rede.

### Passos
1. **Crie um Launch Template:**
    - Defina a AMI, o tipo de instância (ex.: `t2.micro`), o par de chaves e o grupo de segurança.
    - Incorpore o script `user_data.sh` (conforme detalhado em [Instalação do Docker](../docker_setup/docker_setup.pt-BR.md)).
    - Salve o Launch Template.
2. **Crie o Auto Scaling Group:**
    - Defina a capacidade desejada como 2 (garantindo uma instância por Zona de Disponibilidade).
    - Selecione a VPC e as sub-redes privadas onde as instâncias serão executadas.
    - Anexe o Launch Template criado anteriormente.
    - Anexe o target group do Load Balancer.
    - Habilite os health checks tanto para EC2 quanto para o ELB.
3. **Verificação:**
    - Confirme que duas instâncias foram lançadas.
    - Verifique que ambas as instâncias estão registradas no Load Balancer.
    - Teste o acesso à aplicação WordPress via DNS do LB.

> **Observação:** Monitore seu ASG e LB com o CloudWatch para desempenho ideal.
