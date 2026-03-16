# Housekeeping

## Disk Usage

```bash
# Overall disk usage
df -h

# Podman storage usage (images, containers, volumes)
podman system df
```

## Cleanup

```bash
# Remove unused images
podman image prune

# Remove all unused images, containers, networks and volumes
podman system prune -a

# Remove unused volumes only
podman volume prune
```

## Containers

```bash
# List running containers
podman ps

# List all containers (including stopped)
podman ps -a

# View logs of a container
podman logs <container-name>

# Restart a container
podman restart <container-name>
```
