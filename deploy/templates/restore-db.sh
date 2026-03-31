#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/deploy.conf"

APP_DIR="/opt/apps/$APP_NAME"

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <backup-file.sql.gz>"
  echo "Backups are in $APP_DIR/backups/"
  exit 1
fi

FILE="$1"
if [ ! -f "$FILE" ]; then
  echo "File not found: $FILE"
  exit 1
fi

set -a
source "$APP_DIR/.env"
set +a

echo "Stopping app..."
cd "$APP_DIR"
podman-compose stop "$BACKEND_CONTAINER" "$INIT_CONTAINER"

echo "Restoring from $FILE..."
gunzip -c "$FILE" | podman exec -i \
  -e PGPASSWORD="$POSTGRES_PASSWORD" \
  "$POSTGRES_CONTAINER" \
  psql -U postgres

echo "Starting app..."
podman-compose up -d

echo "Restore complete."
