[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](deploy_nginx.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](deploy_nginx.md)

## Overview

The `deploy_nginx.sh` script automates the installation and configuration of the Nginx web server on a WSL Ubuntu environment. It sets up a redirect for the `/portfolio` endpoint to an external GitHub Pages URL, ensuring that the web server serves content correctly and efficiently.

## Script Purpose

- **Automated Deployment:** Installs Nginx and sets it up without manual intervention.
- **Configuration Management:** Configures Nginx to redirect `/portfolio` to a specified external URL.
- **Service Management:** Ensures that Nginx is enabled and started to apply the configurations.
- **Flexibility:** Supports both `apt` and `dnf` package managers for installation.

## Script in Action

https://github.com/user-attachments/assets/7e9c4dbb-f49f-44aa-ac87-759b41956ffb

## How to Run

You can quickly download and execute the `deploy_nginx.sh` script using either `wget` or `curl`. This eliminates the need to manually download the script and make it executable.

#### Using wget:

```bash
  wget -qO- https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/deploy_nginx.sh | sudo bash
```

#### Using curl:

```bash
  curl -sL https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/deploy_nginx.sh | sudo bash
```

#### Explanation of the Command

- ```wget -qO-``` or ```curl -sL```:
    - These commands fetch the script from the specified URL without saving it to a file.
    - The `-qO-` flag in `wget` and `-sL` in `curl` ensure the output is sent directly to the terminal.

- ```| sudo bash```:
    - This pipes the script output into `bash`, allowing the script to run with `sudo` privileges.

- No additional arguments are required for basic execution. Use the `-h` or `--help` flag for more options.

### Prerequisites

- **Execution Permissions:** Ensure the script is executable.

```bash
  chmod +x deploy_nginx.sh
```

- **Dependencies:** The script relies on `nginx`. It will handle the installation if not already present.
- **Supported Package Managers:** The script supports `apt` (for Debian-based) and `dnf` (for Red Hat-based) package managers. Ensure that one of these is available on your system.
- **Sudo Privileges:** The script requires `sudo` privileges to install packages and configure Nginx.

### Execution

Run the script manually:

```bash
  sudo ./deploy_nginx.sh
```

### Options

- `-v, --verbose`: Enable verbose logging.
- `-h, --help`: Display help message.

#### Example with Verbose Output

```bash
  sudo ./deploy_nginx.sh --verbose
```

## Configuration Details

The script creates a configuration file at `/etc/nginx/conf.d/redirect.conf` with the following content:

```nginx
server {
    location /portfolio {
        return 301 https://georgrybski.github.io/uninter/portfolio;
    }

    location /health {
        access_log off;
        return 200 "OK";
    }
}
```

This configuration ensures that any request to `/portfolio` is redirected to the specified GitHub Pages URL. Additionally, it sets up a `/health` endpoint for monitoring purposes.

## Troubleshooting

- **Script Fails to Execute:**
    - Ensure you have `sudo` privileges.
    - Verify that the script has execution permissions: `chmod +x deploy_nginx.sh`.

- **Nginx Not Starting:**
    - Check the Nginx status: `sudo systemctl status nginx`.
    - Review Nginx configuration for errors: `sudo nginx -t`.

- **Redirect Not Working:**
    - Ensure the configuration file `/etc/nginx/conf.d/redirect.conf` exists and contains the correct redirect.
    - Reload Nginx to apply changes: `sudo systemctl reload nginx`.

## Integration

This script is intended to be used as part of the deployment pipeline to ensure that Nginx is consistently installed and configured across environments. It can be integrated with automation tools like Ansible, Terraform, or CI/CD pipelines.

## References

- [Nginx Official Documentation](https://nginx.org/en/docs/)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/bash.html)
