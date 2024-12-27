[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](README.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](README.md)

## Sprint 2

### Overview

The final activity of Sprint 2 focuses on the deployment and automation of Nginx monitoring. In parallel, the configuration of Linux in a Windows environment through WSL was studied.

My implementation of the activity focused on creating robust and modular scripts to configure and monitor, both internally and externally, the Nginx instance.

For automating the execution of the scripts, I used both cron and the systemd timer.

### Scripts and Documentation

- Deployment and configuration of Nginx, with redirection and a `/health` endpoint for subsequent monitoring:
  - **Script:** **[deploy_nginx.sh](../../scripts/sprint2/deploy_nginx.sh)**
  - **Documentation:** [deploy_nginx.en.md](deploy_nginx.md)


- Storing structured logs based on the Nginx service status:
  - **Script:** **[check_nginx_system_status.sh](../../scripts/sprint2/check_nginx_system_status.sh)**
  - **Documentation:** **[check_nginx_system_status.en.md](check_nginx_system_status.md)**


- Storing structured logs based on the response from the `/health` endpoint configured in Nginx:
  - **Script:** **[check_nginx_health_endpoint.sh](../../scripts/sprint2/check_nginx_health_endpoint.sh)**
  - **Documentation:** **[check_nginx_health_endpoint.en.md](check_nginx_health_endpoint.md)**


- Scheduling the verification of the Nginx health endpoint using cron:
  - **Script:** **[schedule_nginx_health_endpoint_cron.sh](../../scripts/sprint2/schedule_nginx_health_endpoint_cron.sh)**
  - **Documentation:** **[schedule_nginx_health_endpoint_cron.en.md](schedule_nginx_health_endpoint_cron.md)**


- Scheduling the verification of the Nginx system status every 5 minutes using systemd:
  - **Script:** **[schedule_nginx_systemd_timer.sh](../../scripts/sprint2/schedule_nginx_systemd_timer.sh)**
  - **Documentation:** **[schedule_nginx_systemd_timer.en.md](schedule_nginx_systemd_timer.md)**


- Documentation on installing the Windows Subsystem for Linux (WSL): **[wsl_installation.md](../../docs/sprint2/wsl_installation.md)**


- Documentation comparing cron jobs and systemd timers: **[cron_vs_systemd_timers.md](../../docs/general/cron_vs_systemd_timers.md)**
