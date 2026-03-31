#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/deploy.conf"

PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BRANCH="${1:-main}"

echo "=== Build: $APP_NAME (branch: $BRANCH) ==="

echo "Pulling latest code..."
cd "$PROJECT_DIR"
git pull origin "$BRANCH"

# Fetch shared libs (cloned into apps/backend/shared_libs/ for the backend build context)
if [ -n "${SHARED_REPOS:-}" ]; then
  SHARED_LIBS_DIR="$PROJECT_DIR/apps/backend/shared_libs"
  mkdir -p "$SHARED_LIBS_DIR"
  for REPO_URL in $SHARED_REPOS; do
    REPO_NAME=$(basename "$REPO_URL" .git)
    echo "Fetching $REPO_NAME..."
    rm -rf "$SHARED_LIBS_DIR/$REPO_NAME"
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$SHARED_LIBS_DIR/$REPO_NAME"
  done
fi

# Build backend image
if [[ "$BUILD_TYPE" == "backend" || "$BUILD_TYPE" == "both" ]]; then
  echo "Building backend image..."
  podman build \
    -t "${APP_NAME}-backend:latest" \
    "$PROJECT_DIR/apps/backend"
fi

# Build frontend image (VITE_ vars from deploy.conf are passed as build args)
if [[ "$BUILD_TYPE" == "frontend" || "$BUILD_TYPE" == "both" ]]; then
  echo "Building frontend image..."
  VITE_ARGS=()
  while IFS= read -r var; do
    VITE_ARGS+=(--build-arg "$var=${!var}")
  done < <(compgen -v | grep "^VITE_" || true)

  podman build \
    "${VITE_ARGS[@]}" \
    -t "${APP_NAME}-frontend:latest" \
    "$PROJECT_DIR/apps/frontend"
fi

# Clean shared libs from build context
if [ -n "${SHARED_REPOS:-}" ]; then
  rm -rf "$PROJECT_DIR/apps/backend/shared_libs"
fi

echo "=== Build complete ==="
