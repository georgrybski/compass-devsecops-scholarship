[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](wordpress_deployment.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](wordpress_deployment.md)

# WordPress Container Deployment

This section describes how to deploy the WordPress container using Docker Compose. The container connects to an RDS MySQL instance and uses EFS for persistent storage.

## Deployment Overview
- **WordPress Container:** Uses the official WordPress image.
- **Database Connection:** Environment variables configure the connection to RDS.
- **Persistent Storage:** The container maps `/var/www/html` (or just `wp-content`) to the EFS mount at `/mnt/efs/wordpress`.
- **Ports:** The container listens on port 80 (or 8080 as an alternative).

## Sample Docker Compose File
Create a file named `docker-compose.yml` with the following content:

```yaml
version: '3.3'
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: <RDS_ENDPOINT>   # e.g., yourdb.abcdefg.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: <DB_USERNAME>      # e.g., admin
      WORDPRESS_DB_PASSWORD: <DB_PASSWORD>
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - /mnt/efs/wordpress:/var/www/html
    restart: always
```

## Deployment Steps
1. **Environment Preparation:**
    - Ensure Docker and Docker Compose are installed (see [Docker Setup](docker_setup.md)).
    - Verify that `/mnt/efs` is mounted and writable.

2. **Configure the Compose File:**
    - Replace `<RDS_ENDPOINT>`, `<DB_USERNAME>`, and `<DB_PASSWORD>` with your RDS details.
    - Save the file on your EC2 instance.

3. **Deploy:**
    - Navigate to the directory containing the file.
    - Run:
      ```bash
      docker-compose up -d
      ```
    - Confirm the container is running with:
      ```bash
      docker ps
      ```

4. **Access WordPress:**
    - Open a browser and navigate to your instance’s (or Load Balancer’s) DNS name to complete the WordPress setup.

> **Tip:** For enhanced security and efficiency, you might consider using a multi‑stage Dockerfile or a distroless image where appropriate.
