[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](schedule_nginx_systemd_timer.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](schedule_nginx_systemd_timer.md)

## Overview

The `schedule_nginx_systemd_timer.sh` script automates the scheduling of the `check_nginx_system_status.sh` script using a systemd timer. This ensures that the Nginx system status is checked every 5 minutes without manual intervention.

## Script Purpose

- **Automation:** Schedules the `check_nginx_system_status.sh` script to run periodically using systemd timers.
- **Reliability:** Utilizes systemd's robust scheduling capabilities to ensure consistent execution.
- **Logging:** Maintains logs of the timer and service status for monitoring and troubleshooting.

You can read about `check_nginx_system_status.sh` [here](../check_nginx_system_status/check_nginx_system_status.md).

## Script in Action

https://github.com/user-attachments/assets/02116a6c-8f41-4530-97d4-61538c909a85

## How to Run

You can quickly download and execute the `schedule_nginx_systemd_timer.sh` script using either `wget` or `curl`. This eliminates the need to manually download the script and make it executable.

#### Using wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/schedule_nginx_systemd_timer.sh \
  | sudo bash -s --
```

#### Using curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/schedule_nginx_systemd_timer.sh \
  | sudo bash -s --
```

#### Explanation of the Command

- ```wget -qO-``` or ```curl -sL```:
    - These commands fetch the script from the specified URL without saving it to a file.
    - The `-qO-` flag in `wget` and `-sL` in `curl` ensure the output is sent directly to the terminal.

- ```| sudo bash -s --```:
    - This pipes the script output into `bash`, allowing the script to run with `sudo` privileges.
    - The `\` character at the end of the first line is used to break the command into multiple lines for better readability. It tells the shell that the command continues on the next line.

### Prerequisites

- **Supported Package Managers:** The script supports `apt` (for Debian-based) and `dnf` (for Red Hat-based) package managers. Ensure that one of these is available on your system.
- **Dependencies:** The script relies on `jq`, `curl`, and `systemd`. The script will attempt to install them if they are not already present.
- **Sudo Privileges:** The script requires `sudo` privileges to create systemd service and timer files, install dependencies, and manage systemd units.

## Options

- `-h, --help`: Display help message.

### Example with Help Option

```bash
  sudo ./schedule_nginx_systemd_timer.sh --help
```

## Verifying the Timer

To confirm that the systemd timer is running every 5 minutes:

1. **Check Timer Status:**

```bash
  systemctl list-timers --all | grep nginx_status_check.timer
```

   You should see an entry indicating that the timer is active and the next trigger time.

2. **Review Service Status:**

```bash
  systemctl status nginx_status_check.service
```

   This command shows the status of the service triggered by the timer, including recent execution logs.

3. **Check Logs with jq:**

```bash
  cat /var/log/nginx_status/online.log | jq .
  cat /var/log/nginx_status/offline.log | jq .
```

   These commands display the structured logs in a readable JSON format.

## Dependencies and Required Paths

- **Script Location:** The monitoring script is downloaded to `/usr/local/bin/check_nginx_system_status.sh`.
- **Service and Timer Files:**
    - Service File: `/etc/systemd/system/nginx_status_check.service`
    - Timer File: `/etc/systemd/system/nginx_status_check.timer`
- **Log Directory:** `/var/log/nginx_status/`

Ensure that these paths are accessible and have the appropriate permissions.

## Troubleshooting

- **Timer Not Running:**
    - Ensure that systemd is active and running on your system.
    - Verify that the timer and service files exist in `/etc/systemd/system/`.

- **Logs Not Updating:**
    - Check the permissions of the log directory and files.
    - Ensure that the `check_nginx_system_status.sh` script is executable.

- **Script Execution Failures:**
    - Review the service logs using `journalctl -u nginx_status_check.service`.
    - Confirm that all dependencies are installed correctly.

## Integration

This script sets up a systemd timer to automate the execution of the `check_nginx_system_status.sh` script every 5 minutes. It replaces the need for manual cron job setup, leveraging systemd's advanced features for more reliable scheduling.

## References

- [Nginx Official Documentation](https://nginx.org/en/docs/)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [Systemd Timer Documentation](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
- [Cron vs Systemd Timers](../../general/cron_vs_systemd_timers/cron_vs_systemd_timers.md)

---
