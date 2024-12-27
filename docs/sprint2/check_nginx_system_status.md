## Overview

The `check_nginx_system_status.sh` script monitors the system status of the Nginx service on Red Hat-based and Debian-based distributions. It logs the service status as either **online** or **offline** with a timestamp and a custom message.

## Script Purpose

- **Service Monitoring:** Checks if the Nginx service is active and running using `systemctl` or `service` commands.
- **Logging:** Records the status to `online.log` or `offline.log` based on the service state.
- **Customization:** Includes timestamps, service names, statuses, and personalized messages.
- **Dependency Management:** Ensures required dependencies (`jq` and `ec2-metadata`) are installed.

## How to Run

You can quickly download and execute the `check_nginx_system_status.sh` script using either `wget` or `curl`. This eliminates the need to manually download the script and make it executable.

#### Using wget:

```bash
wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_system_status.sh \
 | sudo bash -s --
```

#### Using curl:

```bash
curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_system_status.sh \
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

### Prerequisites

- **Execution Permissions:** Ensure the script is executable.

```bash
  chmod +x check_nginx_system_status.sh
```

- **Dependencies:** The script relies on `jq` and `ec2-metadata`. The script will attempt to install them if they are not already present.
- **Supported Package Managers For Dependency Resolution:** The script supports `apt` (for Debian-based) and `dnf` (for Red Hat-based) package managers. Ensure that one of these is available on your system or that the dependencies are fulfilled.
- **Sudo Privileges:** The script requires `sudo` privileges to check the status of the Nginx service and to install dependencies.

### Execution

Run the script manually:

```bash
  sudo ./check_nginx_system_status.sh
```

### Options

- `-v, --verbose`: Enable verbose logging.
- `-h, --help`: Display help message.

#### Example with Verbose Output

```bash
  sudo ./check_nginx_system_status.sh --verbose
```

## Log Files

Logs are stored in `/var/log/nginx_status/` with two separate files:

- **Online Logs:** `/var/log/nginx_status/online.log`
- **Offline Logs:** `/var/log/nginx_status/offline.log`

### Log Entry Structure

Each log entry is a **structured log** in JSON format and includes the following fields:

- `timestamp`: ISO 8601 formatted date and time.
- `service`: Name of the service (`nginx`).
- `status`: `online` or `offline`.
- `message`: Custom message indicating the status.
- `instance_id`: AWS EC2 instance ID (if applicable).
- `region`: AWS region (if applicable).

For more information on the benefits of structured logging, refer to the [Benefits of Structured Logging](#benefits-of-structured-logging) section.

#### Example Log Entry

```json
{
  "timestamp": "2024-04-27T12:34:56Z",
  "service": "nginx",
  "status": "online",
  "message": "Nginx is running.",
  "instance_id": "i-0123456789abcdef0",
  "region": "us-west-2"
}
```

## Troubleshooting

- **Script Fails to Execute:**
  - Ensure you have `sudo` privileges.
  - Verify that `jq` and `ec2-metadata` are installed or allow the script to install them.

- **Logs Not Being Created:**
  - Check if the log directory exists: `/var/log/nginx_status/`.
  - Ensure the script has write permissions to the log directory.

- **Incorrect Status Detection:**
  - Verify the Nginx service status using:

```bash
  sudo systemctl status nginx
```

## Integration

This script is intended to be used with scheduling scripts (`schedule_nginx_systemd_timer.sh`) to automate periodic checks.

## References

- [Nginx Official Documentation](https://nginx.org/en/docs/)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [AWS EC2 Metadata](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)

---