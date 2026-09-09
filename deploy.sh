#!/usr/bin/env bash
# Deploy index.html to the exe.dev VM and (re)configure nginx to serve it on port 8000,
# which exe.dev proxies to https://weather-now.exe.xyz.
set -euo pipefail
HOST="${1:-weather-now.exe.xyz}"
ROOT="/var/www/weather-now"
cd "$(dirname "$0")"

ssh "$HOST" "sudo mkdir -p $ROOT && sudo chown \$USER $ROOT"
scp -q index.html "$HOST:$ROOT/index.html"

ssh "$HOST" 'sudo tee /etc/nginx/sites-available/weather-now >/dev/null <<EOF
server {
    listen 8000;
    server_name _;
    root /var/www/weather-now;
    index index.html;
    add_header Cache-Control "no-cache";
    add_header X-Content-Type-Options nosniff;
    location / { try_files \$uri \$uri/ /index.html; }
}
EOF
sudo ln -sf /etc/nginx/sites-available/weather-now /etc/nginx/sites-enabled/weather-now
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && (sudo systemctl reload nginx || sudo systemctl start nginx)
sudo systemctl enable nginx >/dev/null 2>&1 || true
curl -s -o /dev/null -w "local check: %{http_code}\n" http://127.0.0.1:8000/'
echo "deployed to https://${HOST}"
