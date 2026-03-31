#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/deploy.conf"

APP_DIR="/opt/apps/$APP_NAME"

echo "Setting up $APP_NAME..."

if [[ "$BUILD_TYPE" == "backend" || "$BUILD_TYPE" == "both" ]]; then
  mkdir -p "$APP_DIR/postgres" "$APP_DIR/secrets" "$APP_DIR/backups" "$APP_DIR/frontend"
else
  mkdir -p "$APP_DIR"
fi

if [[ "$BUILD_TYPE" == "backend" || "$BUILD_TYPE" == "both" ]]; then
  if [ ! -f "$APP_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env.example" "$APP_DIR/.env"
    echo ""
    echo "*** Edit $APP_DIR/.env with production values, then run deploy/build.sh and deploy/deploy.sh ***"
  else
    echo ".env already exists, skipping."
  fi
fi

echo "Setup complete."
