[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](README.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](README.md)

## Sprint 2

### Visão Geral

A atividade final da Sprint 2 foca no deployment e automação do monitoramento do Nginx. Em paralelo foi estudada a configuração do Linux em ambiente Windows através do WSL.

Minha implementação da atividade focou na criação de scripts robustos e modulares, para configurar, e monitorar, de forma interna e externa, instância do Nginx.

Para a automatização da execução dos scripts, utilizei tanto cron e o timer do systemd.


### Scripts e Documentação

- Deployment e configuração do Nginx, com redirecionamento e um endpoint de `/health` para posterior monitoramento:
  - **Script:** **[deploy_nginx.sh](../../scripts/sprint2/deploy_nginx.sh)**
  - **Documentação:** **[deploy_nginx.pt-BR.md](deploy_nginx/deploy_nginx.pt-BR.md)**


- Armazenar logs estruturardos com base no status do serviço do Nginx:
  - **Script:** **[check_nginx_system_status.sh](../../scripts/sprint2/check_nginx_system_status.sh)** 
  - **Documentação:** **[check_nginx_system_status.pt-BR.md](check_nginx_system_status/check_nginx_system_status.pt-BR.md)**


- Armazenar logs estruturardos com base na resposta do endpoint `/health` configurado no Nginx:
  - **Script:** **[check_nginx_health_endpoint.sh](../../scripts/sprint2/check_nginx_health_endpoint.sh)**
  - **Documentação:** **[check_nginx_health_endpoint.pt-BR.md](check_nginx_health_endpoint/check_nginx_health_endpoint.pt-BR.md)**


- Agendar a verificação do endpoint de saúde do Nginx usando cron:
  - **Script:** **[schedule_nginx_health_endpoint_cron.sh](../../scripts/sprint2/schedule_nginx_health_endpoint_cron.sh)**
  - **Documentação:** **[schedule_nginx_health_endpoint_cron.pt-BR.md](schedule_nginx_health_endpoint_cron/schedule_nginx_health_endpoint_cron.pt-BR.md)**


- Agendar a verificação do status do sistema do Nginx a cada 5 minutos usando systemd:
    - **Script:** **[schedule_nginx_systemd_timer.sh](../../scripts/sprint2/schedule_nginx_systemd_timer.sh)**
    - **Documentação:** **[schedule_nginx_systemd_timer.pt-BR.md](schedule_nginx_systemd_timer/schedule_nginx_systemd_timer.pt-BR.md)**


- Documentação sobre a instalação do Windows Subsystem for Linux (WSL): **[wsl_installation.md](wsl_installation/wsl_installation.pt-BR.md)**


- Documentação comparando cron jobs e systemd timers: **[cron_vs_systemd_timers.md](../general/cron_vs_systemd_timers/cron_vs_systemd_timers.pt-BR.md)** 

---
