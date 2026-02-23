#!/bin/bash
set -e
for i in {1..12}; do
  if curl -sf http://localhost:3000/health >/dev/null 2>&1; then
    echo "Validation passed - service is responding."
    exit 0
  fi
  sleep 5
done
echo "Validation failed - service did not respond in time."
exit 1
