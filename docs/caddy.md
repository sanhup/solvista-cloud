# Caddy

In order to have multiple machines, we need to install caddy to the server.

```bash
cd .
ssh -i ./ssh/solvista_id_rsa root@157.90.154.103
```

# Install Caddy
```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
chmod o+r /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

```

# Prepare your sites folder
```bash                             
sudo mkdir -p /etc/caddy/sites 
```
# Adjust main Caddyfile    
```bash                             
echo 'import /etc/caddy/sites/*' | sudo tee /etc/caddy/Caddyfile
```
# Per Repo Caddyfile
Every Repository will have it's own caddyfile
```bash                             
sudo cp deploy/AppCaddyFile /etc/caddy/sites/
```

# Reload after each new site
```bash                             
sudo systemctl reload caddy
```