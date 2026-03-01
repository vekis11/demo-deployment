#!/bin/bash
# Bootstrap script: Install Apache and serve "Welcome to WellSpan."
set -e

dnf update -y
dnf install -y httpd

cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WellSpan</title>
  <style>
    body {
      font-family: system-ui, -apple-system, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
      color: #eee;
    }
    h1 {
      font-size: 2.5rem;
      text-align: center;
    }
  </style>
</head>
<body>
  <h1>Welcome to WellSpan.</h1>
</body>
</html>
EOF

systemctl start httpd
systemctl enable httpd
