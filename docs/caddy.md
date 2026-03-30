# Caddy — Multi-service setup

Caddy acts as the reverse proxy on the solvista cloud server. It handles TLS (automatic HTTPS via Let's Encrypt) and routes incoming requests to the correct backend service based on subdomain and path.

This file contains the instructions how to set it up, but also how to deploy (copy) the caddyfile to the server.

## Initial server setup

### Install Caddy

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
chmod o+r /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

### Configure the main Caddyfile

```bash
sudo mkdir -p /etc/caddy/sites
echo 'import /etc/caddy/sites/*' | sudo tee /etc/caddy/Caddyfile
```

## Adding a new service on the server

1. Add a `handle_path` block to `caddy/solvista-api-caddyfile`:

```caddy
handle_path /myservice/* {
    reverse_proxy localhost:<port>
}
```

2. Deploy Caddyfile to the server:

```bash
scp -i ./ssh/solvista_id_rsa caddy/solvista-api-caddyfile root@157.90.154.103:/etc/caddy/sites/
scp -i ./ssh/solvista_id_rsa caddy/solvista-app-caddyfile root@157.90.154.103:/etc/caddy/sites/
ssh -i ./ssh/solvista_id_rsa root@157.90.154.103
sudo systemctl reload caddy
```

## Structure

All Caddyfiles live in the `solvista-cloud` repo under `caddy/`:

```
solvista-cloud/
└── caddy/
    ├── solvista-api-caddyfile    ← api.solvista.nl routes
    ├── solvista-app-caddyfile    ← app.solvista.nl routes
    ├── solvista-wiki-caddyfile   ← wiki.solvista.nl
    └── domogo-apps-caddyfile     ← domogo.solvista.nl
```

On the server they are placed in `/etc/caddy/sites/`, which is imported by the main Caddyfile:

```
/etc/caddy/Caddyfile          → import /etc/caddy/sites/*
/etc/caddy/sites/
    solvista-api-caddyfile
    solvista-app-caddyfile
    solvista-wiki-caddyfile
    domogo-apps-caddyfile
```

## How routing works

Each service gets a path under a subdomain. A single subdomain block handles multiple services:

```caddy
api.solvista.nl {

    handle_path /postcode-nl/* {
        reverse_proxy localhost:8002
    }

    handle_path /iam/* {
        reverse_proxy localhost:8001
    }

    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        Referrer-Policy strict-origin-when-cross-origin
    }
}
```

| URL | Forwards to |
|-----|-------------|
| `api.solvista.nl/postcode-nl/*` | `localhost:8002` (postcode-nl service) |
| `api.solvista.nl/iam/*` | `localhost:8001` (solvista-iam backend) |
| `api.solvista.nl/slack/*` | `localhost:8003` (domogo-slack backend) |

`handle_path` strips the matched prefix before forwarding. So `api.solvista.nl/iam/users` arrives at the backend as `/users`.

## App-owned Caddyfiles

Apps that need their own subdomain get a dedicated Caddyfile in `solvista-cloud/caddy/`. This is the single source of truth for all Caddy config — useful when rebuilding the server. App repos may include a `.example` copy for reference.

Example (`solvista-wiki-caddyfile`):

```caddy
wiki.solvista.nl {
    reverse_proxy 127.0.0.1:9001

    header {
        X-Content-Type-Options nosniff
        Referrer-Policy strict-origin-when-cross-origin
    }
}
```
