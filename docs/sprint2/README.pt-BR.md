[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](README.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](README.md)

## Sprint 2

### Visão Geral

A Sprint 2 foca na automação do monitoramento do Nginx através de scripts e no agendamento de sua execução utilizando cron jobs e systemd timers. Esta sprint inclui o desenvolvimento de scripts para verificar endpoints de saúde do Nginx, status do sistema e seus respectivos mecanismos de agendamento.

### Scripts e Documentação

- **[`deploy_nginx.sh`](../../scripts/sprint2/deploy_nginx.sh)**: Script para implantar o Nginx e configurar um redirecionamento e um endpoint de saúde.
    - **Documentação:** [deploy_nginx.pt-BR.md](deploy_nginx.pt-BR.md)

- **[`check_nginx_health_endpoint.sh`](../../scripts/sprint2/check_nginx_health_endpoint.sh)**: Script para verificar o endpoint de saúde do Nginx.

    - **Documentação:** [check_nginx_health_endpoint.pt-BR.md](check_nginx_health_endpoint.pt-BR.md)

- **[`check_nginx_system_status.sh`](../../scripts/sprint2/check_nginx_system_status.sh)**: Script para verificar o status do sistema do Nginx.

    - **Documentação:** [check_nginx_system_status.pt-BR.md](check_nginx_system_status.pt-BR.md)

- **[`schedule_nginx_health_endpoint_cron.sh`](../../scripts/sprint2/schedule_nginx_health_endpoint_cron.sh)**: Script para agendar a verificação do endpoint de saúde do Nginx usando cron.

    - **Documentação:** [schedule_nginx_health_endpoint_cron.pt-BR.md](schedule_nginx_health_endpoint_cron.pt-BR.md)

- **[`schedule_nginx_systemd_timer.sh`](../../scripts/sprint2/schedule_nginx_systemd_timer.sh)**: Script para agendar a verificação do status do sistema do Nginx usando systemd timer.

    - **Documentação:** [schedule_nginx_systemd_timer.pt-BR.md](schedule_nginx_systemd_timer.pt-BR.md)

- **[`wsl_installation.md`](../../docs/sprint2/wsl_installation.pt-BR.md)**: Documentação sobre a instalação do Windows Subsystem for Linux (WSL).

- **[`cron_vs_systemd_timers.md`](../../docs/general/cron_vs_systemd_timers.pt-BR.md)**: Documentação comparando cron jobs e systemd timers.

---