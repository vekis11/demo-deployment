#!/bin/bash
set -e
APP_DIR="/home/ec2-user/demo-deployment"
if [ -d "$APP_DIR" ]; then
  echo "Backing up previous deployment..."
  if [ -d "${APP_DIR}.bak" ]; then
    rm -rf "${APP_DIR}.bak"
  fi
  mv "$APP_DIR" "${APP_DIR}.bak" || true
fi
mkdir -p "$APP_DIR"
echo "BeforeInstall completed."
