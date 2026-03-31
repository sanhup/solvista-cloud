# Deploy Templates

Canonical deploy scripts for all Solvista projects. Copy these into a project's `deploy/` directory — the only file you need to edit is `deploy.conf`.

## Setup for a new project

```bash
# 1. Copy all templates into your project's deploy dir
cp sv-cloud/deploy/templates/* my-project/deploy/
chmod +x my-project/deploy/*.sh

# 2. Edit deploy.conf — fill in APP_NAME, REPO, BUILD_TYPE, VITE_ vars
# 3. Edit docker-compose.run.yaml — set correct image names and host port
# 4. Edit .env.example — add app-specific env vars
# 5. Add your caddy.snippet blocks to sv-cloud/caddy/solvista-{app,api}-caddyfile
```

## First-time server setup

```bash
# SSH in, clone repo, run setup
ssh -i ../../.ssh/solvista_id_rsa root@157.90.154.103
git clone git@github.com:sanhup/my-app.git /opt/build/my-app
/opt/build/my-app/deploy/setup.sh
exit

# Push .env (backend projects only)
scp -i ../../.ssh/solvista_id_rsa deploy/.env.example root@157.90.154.103:/opt/apps/my-app/.env
# Then SSH in and edit .env with real values
```

## Build & deploy

```bash
ssh -i ../../.ssh/solvista_id_rsa root@157.90.154.103

/opt/build/my-app/deploy/build.sh        # pull code, build image(s)
/opt/build/my-app/deploy/deploy.sh       # copy files, restart services

# Optionally pass a branch:
/opt/build/my-app/deploy/build.sh develop
```

## BUILD_TYPE behaviour

| `BUILD_TYPE` | `build.sh` | `deploy.sh` |
|---|---|---|
| `backend` | builds backend image | starts compose services |
| `frontend` | builds frontend image | extracts static files to `frontend/` |
| `both` | builds both | does both |

## Backup & restore (backend projects only)

```bash
/opt/apps/my-app/backup-db.sh

/opt/apps/my-app/restore-db.sh /opt/apps/my-app/backups/postgres_YYYY-MM-DD.sql.gz
```

## SSH key

All commands use `../../.ssh/solvista_id_rsa` — relative to the project's `deploy/` directory, pointing to the shared `.ssh/` at the solvista-project root.
