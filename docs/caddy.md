# Caddy — Multi-service setup

Caddy acts as the reverse proxy on the solvista cloud server. It handles TLS (automatic HTTPS via Let's Encrypt) and routes incoming requests to the correct backend service based on subdomain and path.

## Structure

All Caddyfiles live in the `solvista-cloud` repo under `caddy/`:

```
solvista-cloud/
└── caddy/
    └── solvista-api-caddyfile    ← api.solvista.nl routes
```

On the server they are placed in `/etc/caddy/sites/`, which is imported by the main Caddyfile:

```
/etc/caddy/Caddyfile          → import /etc/caddy/sites/*
/etc/caddy/sites/
    solvista-api-caddyfile
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

`handle_path` strips the matched prefix before forwarding. So `api.solvista.nl/iam/users` arrives at the backend as `/users`.

## App-owned Caddyfiles

If a service needs its own subdomain or more complex routing, it can ship its own Caddyfile. Place it in the repo under `caddy/` and deploy it alongside the others:

```bash
sudo cp caddy/myservice-caddyfile /etc/caddy/sites/
sudo systemctl reload caddy
```

For example, a frontend app that needs its own domain:

```caddy
myservice.solvista.nl {
    root * /var/www/myservice
    file_server
}
```

Both approaches coexist — the main `/etc/caddy/sites/` directory imports all files regardless of which repo they came from.

---

## Adding a new service

1. Add a `handle_path` block to `caddy/solvista-api-caddyfile`:

```caddy
handle_path /myservice/* {
    reverse_proxy localhost:<port>
}
```

2. Deploy the updated file and reload:

```bash
sudo cp caddy/solvista-api-caddyfile /etc/caddy/sites/
sudo systemctl reload caddy
```

---

## Initial server setup

```bash
# Connect to the server
ssh -i ./ssh/solvista_id_rsa root@157.90.154.103
```

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

### Deploy and reload

```bash
sudo cp caddy/solvista-api-caddyfile /etc/caddy/sites/
sudo systemctl reload caddy
```
