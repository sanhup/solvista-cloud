#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/deploy.conf"

APP_DIR="/opt/apps/$APP_NAME"

echo "=== Deploy: $APP_NAME ==="

if [[ "$BUILD_TYPE" == "backend" || "$BUILD_TYPE" == "both" ]]; then
  echo "Deploying backend..."
  cp "$SCRIPT_DIR/docker-compose.run.yaml" "$APP_DIR/docker-compose.yaml"
  cp "$SCRIPT_DIR/deploy.conf" "$APP_DIR/deploy.conf"

  if [ -f "$SCRIPT_DIR/../postgres/init.sh" ]; then
    cp "$SCRIPT_DIR/../postgres/init.sh" "$APP_DIR/postgres/init.sh"
  fi

  if [ -f "$SCRIPT_DIR/backup-db.sh" ]; then
    cp "$SCRIPT_DIR/backup-db.sh" "$APP_DIR/backup-db.sh"
    cp "$SCRIPT_DIR/restore-db.sh" "$APP_DIR/restore-db.sh"
    chmod +x "$APP_DIR/backup-db.sh" "$APP_DIR/restore-db.sh"
  fi

  cd "$APP_DIR"
  podman-compose up -d
fi

if [[ "$BUILD_TYPE" == "frontend" || "$BUILD_TYPE" == "both" ]]; then
  echo "Deploying frontend..."
  mkdir -p "$APP_DIR/frontend"
  podman run --rm -v "$APP_DIR/frontend:/output" "${APP_NAME}-frontend:latest"
fi

echo "=== Deploy complete ==="
