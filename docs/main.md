## Documentation

This helps you setup your cloud environment. Order matters.

## SSH
Look at ssh.md how to setup your ssh keys. This is required for Open Tofu and deployment later.

## Open Tofu
Look at opentofu.md on how to install andcreate your VM

## Podman
Install podman and enable it so containers restart on reboot:

```bash
apt-get update
apt-get install -y podman podman-compose
sudo systemctl enable podman
sudo systemctl enable podman-restart
```

For ongoing maintenance (disk usage, cleanup) see housekeeping.md.

## Caddy
Look at caddy.md on how to install caddy. This is needed to run make your applications to be used online.

## Setup Git
Look at github.md on how to setup github.