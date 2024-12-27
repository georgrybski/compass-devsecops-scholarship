## Overview

The `check_nginx_health_endpoint.sh` script checks the `/health` endpoint of the Nginx service to ensure it is responding correctly. It logs the HTTP response codes to determine the service's health status.

## Script Purpose

- **Endpoint Monitoring:** Verifies that the `/health` endpoint is accessible and returns a `200` status code.
- **Logging:** Records the status to `online.log` or `offline.log` based on the HTTP response.
- **Customization:** Includes timestamps, target URLs, HTTP codes, and personalized messages.
- **Dependency Management:** Ensures required dependencies (`jq` and `curl`) are installed.

## How to Run

You can quickly download and execute the `check_nginx_health_endpoint.sh` script using either `wget` or `curl`. This eliminates the need to manually download the script and make it executable.

#### Using wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_health_endpoint.sh \
  | sudo bash -s -- -v http://localhost
```

#### Using curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_health_endpoint.sh \
  | sudo bash -s -- -v http://localhost
```

#### Explanation of the Command

- ```wget -qO-``` or ```curl -sL```:
  - These commands fetch the script from the specified URL without saving it to a file.
  - The `-qO-` flag in `wget` and `-sL` in `curl` ensure the output is sent directly to the terminal.

- ```| sudo bash -s -- http://localhost```:
  - This pipes the script output into `bash`, allowing the script to run with `sudo` privileges.
  - The `--` signals the end of command options for bash. Any arguments following it will be passed to the script itself, rather than being interpreted as options for `bash`
  - `http://localhost` is the address that will be checked.

- `-v`:
  - This is a verbose flag passed to the script. When used, it enables detailed output, providing more information about what the script is doing.

- `\`:
  - This is used to break the command into multiple lines for better readability. It tells the shell that the command continues on the next line.

### Prerequisites

- **Execution Permissions:** Ensure the script is executable.

```bash
  chmod +x check_nginx_health_endpoint.sh
```

- **Dependencies:** The script relies on `jq` and `curl`. The script will attempt to install them if they are not already present.
- **Supported Package Managers For Dependency Resolution:** The script supports `apt` (for Debian-based) and `dnf` (for Red Hat-based) package managers. Ensure that one of these is available on your system or that the dependencies are fulfilled.
- **Sudo Privileges:** The script requires `sudo` privileges to create log directories and install dependencies.

### Execution

Run the script manually with the target URL:

```bash
  sudo ./check_nginx_health_endpoint.sh http://localhost
```

### Options

- `-v, --verbose`: Enable verbose logging.
- `-h, --help`: Display help message.

#### Example with Verbose Output

```bash
  sudo ./check_nginx_health_endpoint.sh --verbose http://localhost
```

## Log Files

Logs are stored in `/var/log/nginx_health_endpoint/` with two separate files:

- **Online Logs:** `/var/log/nginx_health_endpoint/online.log`
- **Offline Logs:** `/var/log/nginx_health_endpoint/offline.log`

### Log Entry Structure

Each log entry is a **structured log** in JSON format and includes the following fields:

- `timestamp`: ISO 8601 formatted date and time.
- `status`: `online` or `offline`.
- `message`: Custom message indicating the status.
- `http_code`: HTTP response code from the `/health` endpoint.
- `target_url`: The URL that was checked.
- `instance_id`: AWS EC2 instance ID (if applicable).
- `region`: AWS region (if applicable).

For more information on the benefits of structured logging, refer to the [Benefits of Structured Logging](#benefits-of-structured-logging) section.

#### Example Log Entry

```json
{
  "timestamp": "2024-04-27T12:34:56Z",
  "status": "online",
  "message": "Nginx health endpoint returned code 200.",
  "http_code": 200,
  "target_url": "http://localhost/health"
}
```

## Troubleshooting

- **Script Fails to Execute:**
  - Ensure you have `sudo` privileges.
  - Verify that `jq` and `curl` are installed or allow the script to install them.

- **Logs Not Being Created:**
  - Check if the log directory exists: `/var/log/nginx_health_endpoint/`.
  - Ensure the script has write permissions to the log directory.

- **Endpoint Not Responding:**
  - Verify that the `/health` endpoint is correctly configured in Nginx.
  - Check Nginx logs for any errors related to the health endpoint.

## Integration

This script is intended to be used with scheduling scripts (`schedule_nginx_health_endpoint_cron.sh`) to automate periodic health checks.

## References

- [Nginx Official Documentation](https://nginx.org/en/docs/)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [Curl Documentation](https://curl.se/docs/manpage.html)

---
