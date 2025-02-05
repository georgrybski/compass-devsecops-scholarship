[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](README.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](README.md)

---

# Sprint 3: AWS Docker – Deploying WordPress on AWS

This Sprint demonstrates a complete DevSecOps workflow to deploy a scalable WordPress application on AWS using Docker. The activity covers:

- **Docker Installation:** Automatically set up on EC2 (via a `user_data.sh` script).
- **WordPress Deployment:** Containerized WordPress connected to an RDS MySQL database.
- **Persistent Storage:** Use of AWS EFS for WordPress static content.
- **High Availability:** A Load Balancer and an Auto Scaling Group spanning two Availability Zones.

For further background on WordPress in containerized environments, see the [General WordPress Documentation](../general/wordpress/wordpress.md).

## Table of Contents
1. [AWS Infrastructure Setup](aws_infrastructure/aws_infrastructure.md)
2. [Docker Installation and Configuration](docker_setup/docker_setup.md)
3. [WordPress Container Deployment](wordpress_deployment/wordpress_deployment.md)
4. [Load Balancer & Auto Scaling Configuration](lb_autoscaling/lb_autoscaling.md)
5. [Troubleshooting](troubleshooting/troubleshooting.md)
6. [References](references/references.md)

---