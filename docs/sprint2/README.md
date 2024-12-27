
## Sprint 2

### Overview

Sprint 2 focuses on automating Nginx monitoring through scripts and scheduling their execution using cron jobs and systemd timers. This sprint includes the development of scripts to check Nginx health endpoints, system status, and their respective scheduling mechanisms.

### Scripts and Documentation

- **[`deploy_nginx.sh`](../../scripts/sprint2/deploy_nginx.sh)**: Script to deploy Nginx and configure a redirect and a health endpoint.
    - **Documentation:** [deploy_nginx.md](deploy_nginx.md)

- **[`check_nginx_health_endpoint.sh`](../../scripts/sprint2/check_nginx_health_endpoint.sh)**: Script to check the health endpoint of Nginx.

    - **Documentation:** [check_nginx_health_endpoint.md](check_nginx_health_endpoint.md)

- **[`check_nginx_system_status.sh`](../../scripts/sprint2/check_nginx_system_status.sh)**: Script to check the system status of Nginx.

    - **Documentation:** [check_nginx_system_status.md](check_nginx_system_status.md)

- **[`schedule_nginx_health_endpoint_cron.sh`](../../scripts/sprint2/schedule_nginx_health_endpoint_cron.sh)**: Script to schedule the Nginx health endpoint check using cron.

    - **Documentation:** [schedule_nginx_health_endpoint_cron.md](schedule_nginx_health_endpoint_cron.md)

- **[`schedule_nginx_systemd_timer.sh`](../../scripts/sprint2/schedule_nginx_systemd_timer.sh)**: Script to schedule the Nginx system status check using systemd timer.

    - **Documentation:** [schedule_nginx_systemd_timer.md](schedule_nginx_systemd_timer.md)

- **[`wsl_installation.md`](../../docs/sprints/sprint2/wsl_installation.md)**: Documentation on installing Windows Subsystem for Linux (WSL).

- **[`cron_vs_systemd_timers.md`](../../docs/general/cron_vs_systemd_timers.md)**: Documentation comparing cron jobs and systemd timers.

- **[`structured_logging.md`](../../docs/general/structured_logging.md)**: Documentation describing structured logs and their benefits.


---