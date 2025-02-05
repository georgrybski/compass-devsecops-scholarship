[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](aws_infrastructure.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](aws_infrastructure.md)

---

# AWS Infrastructure Setup

This document details the AWS components and configuration steps needed to support the WordPress deployment.

## Architecture Overview
The solution leverages several AWS services:
- **VPC & Subnets:** A dedicated VPC (e.g., CIDR `10.0.0.0/16`) with at least two public subnets (for the Load Balancer) and two private subnets (for EC2, RDS, and EFS).
- **Security Groups:** Custom rules for EC2, RDS, EFS, and the Load Balancer to regulate traffic.
- **EC2 Instances:** Docker hosts running in two different Availability Zones (AZs) and managed by an Auto Scaling Group.
- **RDS MySQL:** A managed MySQL instance with secure credentials and restricted access.
- **EFS:** A shared file system mounted on the EC2 instances for persistent WordPress storage.
- **Load Balancer:** Routes HTTP traffic to EC2 instances, ensuring that WordPress is not exposed via a public IP.

## Detailed Steps

### 1. VPC and Subnets
- **VPC:** Create a VPC (CIDR e.g., `10.0.0.0/16`).
- **Subnets:** Provision two public subnets (for the Load Balancer) and two private subnets (for EC2, RDS, and EFS).

### 2. Security Groups
- **EC2 SG:** Allow SSH (port 22) from your IP, HTTP (port 80) from the LB, and NFS (port 2049) from the EFS.
- **RDS SG:** Permit MySQL traffic (port 3306) only from the EC2 SG.
- **EFS SG:** Allow NFS (port 2049) from the EC2 SG.
- **LB SG:** Open HTTP (port 80) to the internet.

### 3. EC2 Instances
- Launch instances (e.g., Amazon Linux 2 or Ubuntu) in two different AZs.
- Use a `user_data.sh` script to install Docker, Docker Compose, and mount the EFS (see [Docker Setup](../docker_setup/docker_setup.md)).
- Ensure instances are registered with the Auto Scaling Group.

### 4. RDS MySQL
- Create an RDS instance using MySQL (e.g., `db.t3.micro`).
- Set a database name (e.g., `wordpress`), a master username, and password.
- Deploy the RDS in private subnets with the RDS SG attached.

### 5. EFS
- Create an EFS file system in your VPC.
- Configure mount targets in the private subnets.
- Update the EC2 instances (or `fstab`) so that `/mnt/efs` is mounted at boot.

### 6. Load Balancer & Auto Scaling
- See [Load Balancer & Auto Scaling Configuration](../lb_autoscaling/lb_autoscaling.md) for full details.

> **Tip:** Double‑check your network configurations (subnets, security groups) in the AWS Console to prevent connectivity issues.

---
