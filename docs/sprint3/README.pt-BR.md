[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](README.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](README.md)

---

# Sprint 3: AWS Docker – Implantando o WordPress na AWS

Esta Sprint demonstra um fluxo completo DevSecOps para implantar uma aplicação WordPress escalável na AWS utilizando Docker. A atividade abrange:

- **Instalação do Docker:** Configuração automática em instâncias EC2 (via script `user_data.sh`).
- **Deploy do WordPress:** Container do WordPress integrado a um banco de dados MySQL do RDS.
- **Armazenamento Persistente:** Uso do AWS EFS para conteúdos estáticos do WordPress.
- **Alta Disponibilidade:** Load Balancer e Auto Scaling Group distribuídos em duas Zonas de Disponibilidade.

Para mais informações sobre o WordPress em ambientes conteinerizados, veja a [Documentação Geral do WordPress](../general/wordpress/wordpress.pt-BR.md).

## Sumário
1. [Configuração da Infraestrutura AWS](aws_infrastructure/aws_infrastructure.md)
2. [Instalação e Configuração do Docker](docker_setup/docker_setup.md)
3. [Deploy do Container WordPress](wordpress_deployment/wordpress_deployment.pt-BR.md)
4. [Configuração do Load Balancer & Auto Scaling](lb_autoscaling/lb_autoscaling.pt-BR.md)
5. [Solução de Problemas](troubleshooting/troubleshooting.pt-BR.md)
6. [Referências](references/references.pt-BR.md)

---