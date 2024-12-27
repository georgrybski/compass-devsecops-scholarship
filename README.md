![Banner Compass UOL](https://vetores.org/d/compass-uol.svg)

---

## Compass UOL DevSecOps Scholarship

This repository contains the activities completed by [me](https://github.com/georgrybski) under a DevSecOps/AWS scholarship provided by [Compass UOL](https://compass.uol/en/home/) in partnership with [UNINTER International University Center](https://www.uninter.com/centro-universitario/).

---

### Table of Contents
- [Project Status](#project-status)
- [Sprint Projects, Scripts, and Documentation](#sprint-projects-scripts-and-documentation)
- [Repository Structure Overview](#repository-structure-overview)
  - [Sprint 2](#sprint-2)
- [License](#license)

---

### Project Status

I utilized GitHub's [projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects) and [issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues) to track tasks by breaking down each assignment's specifications.

Additionally, each Pull Request (PR) is associated with a respective issue and reviewed by [Qodo Merge](https://qodo-merge-docs.qodo.ai/), formerly known as PR-Agent.

You can view the progress of this project's tasks [here](https://github.com/users/georgrybski/projects/3).

---

### Sprint Projects, Scripts, and Documentation
- #### [Sprint 2](docs/sprint2/README.md)

---

### Repository Structure Overview
```
repository-root/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   └── user_story.md
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   ├── general/
│   │   ├── cron_vs_systemd_timers.md
│   │   └── virtualizing_windows_on_kvm.md (TODO)
│   └── sprint2/
│       ├── README.md
│       ├── check_nginx_health_endpoint.md
│       ├── check_nginx_system_status.md
│       ├── schedule_nginx_health_endpoint_cron.md
│       ├── schedule_nginx_systemd_timer.md
│       └── wsl_installation.md
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

### License

This project is licensed under the [MIT License](LICENSE).

---
