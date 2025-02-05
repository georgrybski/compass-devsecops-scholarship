[![Read in Portuguese](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%B7%20Portugu%C3%AAs-gray.svg)](troubleshooting.pt-BR.md)
[![Read in English](https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-F0FFFF.svg)](troubleshooting.md)

---

# Troubleshooting

Below are some common issues you might encounter along with suggested solutions.

## Common Issues

### Docker Service Fails to Start
- **Problem:** Docker is not running.
- **Solution:**
    - Check system logs (`journalctl -u docker` or `/var/log/messages`).
    - Ensure the `user_data.sh` script executed correctly.
    - Manually start Docker with `sudo systemctl start docker`.

### EFS Mount Issues
- **Problem:** The directory `/mnt/efs` is empty or inaccessible.
- **Solution:**
    - Verify that the `nfs-utils` package is installed.
    - Confirm that the security group for EFS permits NFS (port 2049) from EC2.
    - Test mounting manually:
```bash
  sudo mount -t nfs4 -o nfsvers=4.1 <EFS_DNS_NAME>:/ /mnt/efs
```

### WordPress Container Not Running
- **Problem:** The container fails to launch or crashes.
- **Solution:**
    - Check container logs with `docker logs <container_id>`.
    - Ensure environment variables (database host, user, password, etc.) are correctly set.
    - Verify connectivity from EC2 to the RDS instance.

### Load Balancer Health Check Failures
- **Problem:** Instances are marked unhealthy.
- **Solution:**
    - Validate the health check path and protocol.
    - Ensure security groups permit communication between the LB and instances.
    - Confirm that the WordPress container is serving on the expected port.
