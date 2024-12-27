[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](schedule_nginx_health_endpoint_cron.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](schedule_nginx_health_endpoint_cron.md)

## Overview

The `schedule_nginx_health_endpoint_cron.sh` script automates the scheduling of the `check_nginx_health_endpoint.sh` script using a cron job. This ensures that the Nginx health endpoint is checked every 5 minutes without manual intervention.

## Script Purpose

- **Automation:** Schedules the `check_nginx_health_endpoint.sh` script to run periodically using cron jobs.
- **Reliability:** Utilizes cron's scheduling capabilities to ensure consistent execution.
- **Logging:** Maintains logs of the cron job executions for monitoring and troubleshooting.

You can read about `check_nginx_health_endpoint.sh` [here](check_nginx_health_endpoint.md).

## Script in Action

https://github.com/user-attachments/assets/ef4148bf-5bcb-4120-a45d-66ddba51aa58

## How to Run

You can quickly download and execute the `schedule_nginx_health_endpoint_cron.sh` script using either `wget` or `curl`. This eliminates the need to manually download the script and make it executable.

#### Using wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/schedule_nginx_health_endpoint_cron.sh \
  | sudo bash -s --address http://localhost --user user
```

#### Using curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/schedule_nginx_health_endpoint_cron.sh \
  | sudo bash -s --address http://localhost --user user
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
- **Dependencies:** The script relies on `jq`, `curl`, and `cronie` (or `cron`). The script will attempt to install them if they are not already present.
- **Sudo Privileges:** The script requires `sudo` privileges to create cron jobs, install dependencies, and manage log directories.

## Options

- `--address <ADDRESS>`: Base URL to check (default: `http://127.0.0.1`)
- `-h, --help`: Display help message

### Example with Help Option

```bash
  sudo ./schedule_nginx_health_endpoint_cron.sh --help
```

## Verifying the Cron Job

To confirm that the cron job is running every 5 minutes:

1. **List Cron Jobs for the User:**

```bash
   sudo crontab -u ec2-user -l
```

   You should see an entry similar to:

```
   */5 * * * * sudo /usr/local/bin/check_nginx_health_endpoint.sh -v http://localhost >> /var/log/nginx_health_cron/health_check.log 2>&1
```

2. **Check Cron Logs with jq:**

   ```bash
   sudo cat /var/log/nginx_health_cron/health_check.log | jq .
   ```

   These commands display the structured logs in a readable JSON format.

3. **Verify Log Directory:**

   Ensure that the log directory `/var/log/nginx_health_cron/` exists and contains the `health_check.log` file with recent entries.

## Dependencies and Required Paths

- **Script Location:** The monitoring script is downloaded to `/usr/local/bin/check_nginx_health_endpoint.sh`.
- **Log Directory:** `/var/log/nginx_health_cron/`
- **Log File:** `/var/log/nginx_health_cron/health_check.log`

Ensure that these paths are accessible and have the appropriate permissions.

## Troubleshooting

- **Cron Job Not Running:**
    - Ensure that the cron service is active and running.
    - Verify that the cron job entry exists using `crontab -u ec2-user -l`.

- **Logs Not Updating:**
    - Check the permissions of the log directory and files.
    - Ensure that the `check_nginx_health_endpoint.sh` script is executable.

- **Script Execution Failures:**
    - Review the log file at `/var/log/nginx_health_cron/health_check.log` for error messages.
    - Confirm that all dependencies are installed correctly.

## Integration

This script sets up a cron job to automate the execution of the `check_nginx_health_endpoint.sh` script every 5 minutes. It leverages cron's scheduling capabilities to ensure regular health checks without manual intervention.

## References

- [Nginx Official Documentation](https://nginx.org/en/docs/)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [Curl Documentation](https://curl.se/docs/manpage.html)
- [Cron Documentation](https://man7.org/linux/man-pages/man5/crontab.5.html)
- [Cron vs Systemd Timers](../general/cron_vs_systemd_timers.md)

---
