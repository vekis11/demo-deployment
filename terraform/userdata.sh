#!/bin/bash
# Bootstrap script: Install Apache and serve Cordea-WellSpan welcome page
set -e

dnf update -y
dnf install -y httpd

cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cordea-WellSpan Cloud 101</title>
  <style>
    * { box-sizing: border-box; }
    body {
      font-family: system-ui, -apple-system, sans-serif;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      padding: 2rem;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
      color: #eee;
      overflow-x: hidden;
    }
    .ribbons {
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      pointer-events: none;
      overflow: hidden;
    }
    .ribbon {
      position: absolute;
      width: 120px;
      height: 24px;
      background: linear-gradient(90deg, #e91e63, #ff4081);
      transform: rotate(-45deg);
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      opacity: 0.9;
    }
    .ribbon::after {
      content: '';
      position: absolute;
      right: -8px;
      top: 50%;
      border: 12px solid transparent;
      border-left: 12px solid #c2185b;
      transform: translateY(-50%);
    }
    .ribbon:nth-child(1) { top: 10%; left: 5%; }
    .ribbon:nth-child(2) { top: 25%; right: 8%; left: auto; transform: rotate(45deg); background: linear-gradient(90deg, #2196f3, #03a9f4); }
    .ribbon:nth-child(2)::after { border-left-color: #1565c0; }
    .ribbon:nth-child(3) { top: 50%; left: 2%; transform: rotate(-30deg); background: linear-gradient(90deg, #4caf50, #8bc34a); }
    .ribbon:nth-child(3)::after { border-left-color: #2e7d32; }
    .ribbon:nth-child(4) { bottom: 30%; right: 5%; left: auto; transform: rotate(30deg); background: linear-gradient(90deg, #ff9800, #ffc107); }
    .ribbon:nth-child(4)::after { border-left-color: #e65100; }
    .ribbon:nth-child(5) { bottom: 10%; left: 15%; transform: rotate(-50deg); background: linear-gradient(90deg, #9c27b0, #e040fb); }
    .ribbon:nth-child(5)::after { border-left-color: #6a1b9a; }
    .ribbon:nth-child(6) { top: 15%; right: 20%; transform: rotate(60deg); background: linear-gradient(90deg, #00bcd4, #4dd0e1); }
    .ribbon:nth-child(6)::after { border-left-color: #00838f; }
    .ribbon:nth-child(7) { bottom: 40%; left: 8%; transform: rotate(-15deg); background: linear-gradient(90deg, #f44336, #ff5722); }
    .ribbon:nth-child(7)::after { border-left-color: #c62828; }
    .ribbon:nth-child(8) { top: 60%; right: 10%; left: auto; transform: rotate(20deg); background: linear-gradient(90deg, #673ab7, #9575cd); }
    .ribbon:nth-child(8)::after { border-left-color: #4527a0; }
    .ribbon:nth-child(9) { top: 5%; left: 25%; transform: rotate(-60deg); background: linear-gradient(90deg, #009688, #26a69a); }
    .ribbon:nth-child(9)::after { border-left-color: #00695c; }
    .ribbon:nth-child(10) { bottom: 15%; right: 25%; left: auto; transform: rotate(45deg); background: linear-gradient(90deg, #ff5722, #ff8a65); }
    .ribbon:nth-child(10)::after { border-left-color: #d84315; }
    .content {
      position: relative;
      z-index: 1;
      text-align: center;
      max-width: 800px;
    }
    h1 {
      font-size: clamp(1.5rem, 4vw, 2.5rem);
      line-height: 1.4;
      text-shadow: 0 2px 20px rgba(0,0,0,0.3);
    }
    .ribbon-emoji { font-size: 2rem; margin: 0 0.2em; }
  </style>
</head>
<body>
  <div class="ribbons">
    <div class="ribbon"></div>
    <div class="ribbon"></div>
    <div class="ribbon"></div>
    <div class="ribbon"></div>
    <div class="ribbon"></div>
    <div class="ribbon"></div>
    <div class="ribbon"></div>
    <div class="ribbon"></div>
    <div class="ribbon"></div>
    <div class="ribbon"></div>
  </div>
  <div class="content">
    <h1><span class="ribbon-emoji">🎀</span> Welcome to Cordea-WellSpan Cloud 101 Mentorship Program led by Vekis Tem and Collins Nwanze <span class="ribbon-emoji">🎀</span></h1>
  </div>
</body>
</html>
EOF

systemctl start httpd
systemctl enable httpd
