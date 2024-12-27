# WSL Environment Setup

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
  - [1. Enable WSL](#1-enable-wsl)
  - [2. Install Ubuntu LTS](#2-install-ubuntu-lts)
  - [3. Initialize the Distribution](#3-initialize-the-distribution)
  - [4. Update Package Lists](#4-update-package-lists)
  - [5. Set Up Your Linux User](#5-set-up-your-linux-user)
  - [6. Verify Installation](#6-verify-installation)
- [Advanced Configuration](#advanced-configuration)
  - [Change Default WSL Version](#change-default-wsl-version)
  - [Set Default Distribution](#set-default-distribution)
  - [Upgrade WSL Version](#upgrade-wsl-version)
  - [Run Multiple Distributions](#run-multiple-distributions)
- [Troubleshooting](#troubleshooting)
- [References](#references)

## Prerequisites

- **Operating System:** Windows 10 (version 2004 and higher / Build 19041 and higher) or Windows 11.
- **Administrative Privileges:** Required to install WSL and configure system settings.
- **Internet Connection:** Necessary for downloading packages and updates.

## Installation Steps

https://github.com/georgrybski/compass-devsecops-scholarship/blob/6de39b8cbe92550594ac1fdb633c5f165fb9cb6a/docs/assets/wsl_ubuntu_setup_tag_along.mp4

### 1. Enable WSL

Open **PowerShell** with **Administrator** privileges and run the following command:

```powershell
  wsl --install
```

This command enables the necessary features for WSL and installs the default Ubuntu distribution. If you prefer a different distribution, see [Install Ubuntu LTS](#2-install-ubuntu-lts).

**Note:** If WSL is already installed, running `wsl --install` will display the help text. To install a specific distribution, use the `-d` flag as shown below.

### 2. Install Ubuntu LTS

To install the latest Ubuntu LTS distribution, execute:

```powershell
  wsl --install -d Ubuntu
```

Alternatively, to see a list of available distributions, run:

```powershell
  wsl --list --online
```

Then install your preferred distribution by replacing `<DistroName>` with the desired name:

```powershell
  wsl --install -d <DistroName>
```

### 3. Initialize the Distribution

After installation, launch the Ubuntu distribution from the Start menu. A console window will open, decompressing and setting up the file system. This process may take a few minutes.

### 4. Update Package Lists

Once inside the Linux environment, update the package lists to ensure all packages are up to date:

```bash
  sudo apt update && sudo apt upgrade -y
```

### 5. Set Up Your Linux User

During the first launch, you will be prompted to create a new user account and set a password. Follow the on-screen instructions to complete this setup.

### 6. Verify Installation

To verify that WSL and Ubuntu are installed correctly, run:

```bash
  wsl -l -v
```

You should see Ubuntu listed with its version number. Additionally, you can check the Linux kernel version:

```bash
  uname -r
```

## Advanced Configuration

### Change Default WSL Version

By default, WSL 2 is installed. To set WSL 1 as the default version for new distributions, use:

```powershell
  wsl --set-default-version 1
```

To revert to WSL 2:

```powershell
  wsl --set-default-version 2
```

### Set Default Distribution

To set a specific distribution as the default, use:

```powershell
  wsl -s <DistributionName>
```

**Example:**

```powershell
  wsl -s Ubuntu
```

### Upgrade WSL Version

To upgrade an existing distribution from WSL 1 to WSL 2, run:

```powershell
  wsl --set-version <DistroName> 2
```

**Example:**

```powershell
  wsl --set-version Ubuntu 2
```

### Run Multiple Distributions

WSL supports running multiple Linux distributions simultaneously. Install additional distributions using:

```powershell
  wsl --install -d <AnotherDistroName>
```

**Example:**

```powershell
  wsl --install -d Debian
```

You can manage and switch between distributions using the `wsl -l -v` and `wsl -s` commands.

## Troubleshooting

<details>
  <summary>Expand Troubleshooting Steps</summary>

### WSL Installation Issues

- **Ensure Virtualization is Enabled:**
  - Restart your computer and enter BIOS/UEFI settings.
  - Enable virtualization technology (Intel VT-x or AMD-V).

- **Check Windows Version:**
  - Run `winver` in the Run dialog (`Win + R`) to verify your Windows version.
  - Ensure it is Windows 10 version 2004 or higher, or Windows 11.

- **Verify WSL Installation:**
  - Run `wsl --version` to check the installed WSL version.

### Initialization Problems

- **Distribution Fails to Initialize:**
  - Unregister and reinstall the distribution:
    ```powershell
      wsl --unregister <DistroName>
      wsl --install -d <DistroName>
    ```

### Network Connectivity Issues

- **No Internet Access in WSL:**
  - Restart the WSL network:
    ```bash
      sudo service networking restart
    ```

- **Firewall Blocking Ports:**
  - Ensure that Windows Firewall allows WSL traffic.

### General Issues

- **Update WSL:**
  - Run the following command to update WSL to the latest version:
    ```powershell
      wsl --update
    ```

</details>

## References

- [Official WSL Documentation](https://learn.microsoft.com/windows/wsl/)
- [Ubuntu on WSL](https://documentation.ubuntu.com/wsl/en/latest/)
- [WSL GitHub Repository](https://github.com/microsoft/WSL)
- [Best Practices for Setting Up a WSL Development Environment](https://learn.microsoft.com/windows/wsl/setup/environment)
