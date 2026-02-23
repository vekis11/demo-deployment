#!/bin/bash
set -e
APP_DIR="/home/ec2-user/demo-deployment"
if [ -f "$APP_DIR/package.json" ]; then
  cd "$APP_DIR"
  if [ -f .pid ]; then
    kill $(cat .pid) 2>/dev/null || true
    rm -f .pid
  fi
  pkill -f "node server.js" 2>/dev/null || true
fi
echo "Application stopped."
