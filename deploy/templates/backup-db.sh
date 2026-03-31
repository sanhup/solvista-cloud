#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/deploy.conf"

APP_DIR="/opt/apps/$APP_NAME"
BACKUP_DIR="$APP_DIR/backups"
DATE="$(date +%F)"
FILE="$BACKUP_DIR/postgres_$DATE.sql.gz"

set -a
source "$APP_DIR/.env"
set +a

mkdir -p "$BACKUP_DIR"

podman exec \
  -e PGPASSWORD="$POSTGRES_PASSWORD" \
  "$POSTGRES_CONTAINER" \
  pg_dumpall -U postgres \
  | gzip > "$FILE"

# Fail if backup is empty
test -s "$FILE"

# Remove backups older than 14 days
find "$BACKUP_DIR" -type f -mtime +14 -delete

echo "Backup saved to $FILE"
