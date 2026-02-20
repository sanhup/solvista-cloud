
# Install podman and enable it

```bash
apt-get update
apt-get install -y podman podman-compose
sudo systemctl enable podman
sudo systemctl enable podman-restart
```

View used space

```bash
podman system df
```

```bash
podman image prune
```