![Banner Compass UOL](https://vetores.org/d/compass-uol.svg)

---
[![Leia em Português](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-F0FFFF.svg)](README.pt-BR.md)
[![Leia em Inglês](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-gray.svg)](README.md)

## Programa Bolsas DevSecOps Compass UOL

Este repositório contém as atividades concluídas por [mim](https://github.com/georgrybski) no programa de bolas DevSecOps/AWS da [Compass UOL](https://compass.uol/en/home/) em parceria com o [Centro Universitário UNINTER](https://www.uninter.com/centro-universitario/).

---

### Índice
- [Status do Projeto](#status-do-projeto)
- [Projetos da Sprint, Scripts e Documentação](#projetos-da-sprint-scripts-e-documentação)
- [Visão Geral da Estrutura do Repositório](#visão-geral-da-estrutura-do-repositório)
    - [Sprint 2](#sprint-2)
- [Licença](#licença)

---

### Status do Projeto

Utilizei os [projetos](https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects) e [issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues) do GitHub para acompanhar as tarefas, detalhando as especificações de cada atribuição.

Além disso, cada Pull Request (PR) está associada a uma issue respectiva e revisada pelo [Qodo Merge](https://qodo-merge-docs.qodo.ai/), anteriormente conhecido como PR-Agent.

Você pode ver o progresso das tarefas deste projeto [aqui](https://github.com/users/georgrybski/projects/3).

---

### Projetos da Sprint, Scripts e Documentação
- #### [Sprint 2](docs/sprint2/README.pt-BR.md)

---

### Visão Geral da Estrutura do Repositório

```
repository-root/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   └── user_story.pt-BR.md
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   ├── general/
│   │   ├── cron_vs_systemd_timers.pt-BR.md
│   │   └── virtualizing_windows_on_kvm.pt-BR.md (TODO)
│   └── sprint2/
│       ├── README.pt-BR.md
│       ├── check_nginx_health_endpoint.pt-BR.md
│       ├── check_nginx_system_status.pt-BR.md
│       ├── schedule_nginx_health_endpoint_cron.pt-BR.md
│       ├── schedule_nginx_systemd_timer.pt-BR.md
│       └── wsl_installation.pt-BR.md
├── scripts/
│   └── sprint2/
│       ├── check_nginx_health_endpoint.sh
│       ├── check_nginx_system_status.sh
│       ├── deploy_nginx.sh
│       ├── schedule_nginx_health_endpoint_cron.sh
│       └── schedule_nginx_systemd_timer.sh
├── .gitignore
└── README.md
```
---

### Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).

---
