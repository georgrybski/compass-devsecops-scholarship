![Banner Compass UOL](https://vetores.org/d/compass-uol.svg)

---
[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](README.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](README.md)

## Programa Bolsas DevSecOps Compass UOL

Este repositório contém as atividades concluídas por [mim](https://github.com/georgrybski) no programa de bolsas DevSecOps/AWS da [Compass UOL](https://compass.uol/pt/home/) em parceria com o [Centro Universitário UNINTER](https://www.uninter.com/centro-universitario/).

---

### Índice
- [Status do Projeto](#status-do-projeto)
- [Projetos da Sprint, Scripts e Documentação](#projetos-da-sprint-scripts-e-documentação)
  - [Linux - Sprint 2](#linux---sprint-2)
  - [Docker - Sprint 3](#docker---sprint-3)
  - [Docker - Sprint 3](#migração---sprint-4)
- [Visão Geral da Estrutura do Repositório](#visão-geral-da-estrutura-do-repositório)
- [Licença](#licença)

---

### Status do Projeto

Utilizei os [projetos](https://docs.github.com/pt/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects) e [issues](https://docs.github.com/pt/issues/tracking-your-work-with-issues/about-issues) do GitHub para acompanhar as tarefas, detalhando os requisitos e especificações de cada task.

Além disso, cada Pull Request (PR) está associada a uma respectiva issue e revisada pelo [Qodo Merge](https://qodo-merge-docs.qodo.ai/) (anteriormente conhecido como PR-Agent).

Você pode ver o progresso das tasks deste projeto [aqui](https://github.com/users/georgrybski/projects/3).

---

### Projetos da Sprint, Scripts e Documentação
- #### [Linux - Sprint 2](docs/sprint2/README.pt-BR.md)
- #### [Docker - Sprint 3](docs/sprint3/README.pt-BR.md)
- #### [Migração - Sprint 4](docs/sprint4/README.pt-BR.md)
---

### Visão Geral da Estrutura do Repositório

```
repository-root/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   └── user_story.md
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   ├── general/
│   │   ├── cron_vs_systemd_timers/
│   │   │   ├── cron_vs_systemd_timers.md
│   │   │   └── cron_vs_systemd_timers.pt-BR.md
│   │   ├── structured_logging/
│   │   │   ├── structured_logging.md
│   │   │   └── structured_logging.pt-BR.md
│   │   └── wordpress/
│   │       ├── wordpress.md
│   │       └── wordpress.pt-BR.md
│   ├── sprint2/
│   │   ├── README.md
│   │   ├── README.pt-BR.md
│   │   ├── check_nginx_health_endpoint/
│   │   │   ├── check_nginx_health_endpoint.md
│   │   │   └── check_nginx_health_endpoint.pt-BR.md
│   │   ├── check_nginx_system_status/
│   │   │   ├── check_nginx_system_status.md
│   │   │   └── check_nginx_system_status.pt-BR.md
│   │   ├── schedule_nginx_health_endpoint_cron/
│   │   │   ├── schedule_nginx_health_endpoint_cron.md
│   │   │   └── schedule_nginx_health_endpoint_cron.pt-BR.md
│   │   ├── schedule_nginx_systemd_timer/
│   │   │   ├── schedule_nginx_systemd_timer.md
│   │   │   └── schedule_nginx_systemd_timer.pt-BR.md
│   │   └── wsl_installation/
│   │       ├── wsl_installation.md
│   │       └── wsl_installation.pt-BR.md
│   ├── sprint3/
│   │   ├── aws_infrastructure/
│   │   │   ├── aws_infrastructure.md
│   │   │   └── aws_infrastructure.pt-BR.md
│   │   ├── docker_setup/
│   │   │   ├── docker_setup.md
│   │   │   └── docker_setup.pt-BR.md
│   │   ├── lb_autoscaling/
│   │   │   ├── lb_autoscaling.md
│   │   │   └── lb_autoscaling.pt-BR.md
│   │   ├── references/
│   │   │   ├── references.md
│   │   │   └── references.pt-BR.md
│   │   ├── troubleshooting/
│   │   │   ├── troubleshooting.md
│   │   │   └── troubleshooting.pt-BR.md
│   │   ├── wordpress_deployment/
│   │   │   ├── wordpress_deployment.md
│   │   │   └── wordpress_deployment.pt-BR.md
│   │   ├── README.md
│   │   └── README.pt-BR.md
│   └── sprint4/
│       ├── final_project_budget/
│       │   ├── final_project_budget.md
│       │   └── final_project_budget.pt-BR.md
│       ├── README.md
│       └── README.pt-BR.md
├── scripts/
│   └── sprint2/
│       ├── check_nginx_health_endpoint.sh
│       ├── check_nginx_system_status.sh
│       ├── deploy_nginx.sh
│       ├── schedule_nginx_health_endpoint_cron.sh
│       └── schedule_nginx_systemd_timer.sh
├── .gitignore
├── README.pt-BR.md
└── README.md
```
---

### Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).

---
