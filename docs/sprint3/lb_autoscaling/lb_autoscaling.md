[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](lb_autoscaling.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](lb_autoscaling.md)

---
# Load Balancer & Auto Scaling Configuration

This document covers how to configure a Load Balancer and an Auto Scaling Group (ASG) so that your deployment remains highly available and scalable across two Availability Zones.

## Load Balancer Configuration

### Overview
- **Type:** Use an Application Load Balancer (ALB) or Classic Load Balancer (if required).
- **Listeners:** Configure HTTP on port 80.
- **Subnets:** Attach the LB to at least two public subnets (one per AZ).
- **Security Group:** Allow incoming HTTP (port 80) from the internet.

### Steps
1. **Create the Load Balancer:**
    - In the AWS Console, navigate to “Load Balancers.”
    - Create a new ALB (or Classic LB) with the desired name and settings.
    - Attach it to your public subnets.

2. **Configure Target Groups:**
    - Create a target group for your EC2 instances (protocol HTTP, port 80).
    - Define health check parameters (for example, a ping path like `/` or `/wp-admin/install.php`).

3. **Register Targets:**
    - Initially register one EC2 instance to test.
    - Later, when using Auto Scaling, the instances will be registered automatically.

## Auto Scaling Group (ASG) Configuration

### Overview
- **Objective:** Ensure that two EC2 instances (one per AZ) are always running.
- **Launch Template:** Use a Launch Template that embeds your `user_data.sh` script.
- **Scaling Policy:** Optionally, set policies based on CPU or network metrics.

### Steps
1. **Create a Launch Template:**
    - Define the AMI, instance type (e.g., `t2.micro`), key pair, and security group.
      - Embed your `user_data.sh` script (as detailed in [Docker Setup](../docker_setup/docker_setup.md)).
    - Save the Launch Template.
2. **Create the Auto Scaling Group:**
    - Specify the desired capacity as 2 (ensuring one instance per AZ).
    - Select the VPC and private subnets where the instances will run.
    - Attach the previously created Launch Template.
    - Attach the target group from the Load Balancer.
    - Enable both EC2 and ELB health checks.
3. **Verification:**
    - Confirm that two instances launch.
    - Verify that both instances are registered with the Load Balancer.
    - Test access to the WordPress application via the LB DNS name.

> **Note:** Monitor your ASG and LB with CloudWatch for optimal performance.

---