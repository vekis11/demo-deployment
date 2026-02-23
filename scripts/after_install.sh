#!/bin/bash
set -e
APP_DIR="/home/ec2-user/demo-deployment"
cd "$APP_DIR"
export NODE_ENV=production
if command -v node &>/dev/null; then
  npm ci --omit=dev 2>/dev/null || npm install --omit=dev
else
  echo "Node.js not found. Installing via nvm or system..."
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npm ci --omit=dev 2>/dev/null || npm install --omit=dev
fi
chown -R ec2-user:ec2-user "$APP_DIR"
echo "AfterInstall completed."
