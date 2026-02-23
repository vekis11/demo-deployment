#!/bin/bash
set -e
APP_DIR="/home/ec2-user/demo-deployment"
cd "$APP_DIR"
export NODE_ENV=production
export PORT=3000
if command -v node &>/dev/null; then
  nohup node server.js > /var/log/demo-deployment.log 2>&1 &
  echo $! > .pid
else
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nohup node server.js > /var/log/demo-deployment.log 2>&1 &
  echo $! > .pid
fi
echo "Application started."
