#!/usr/bin/env bash
# Deploy index.html to the exe.dev VM and (re)configure nginx to serve it on port 8000,
# which exe.dev proxies to https://weather-now.exe.xyz.
set -euo pipefail
HOST="${1:-weather-now.exe.xyz}"
ROOT="/var/www/weather-now"
cd "$(dirname "$0")"

ssh "$HOST" "sudo mkdir -p $ROOT && sudo chown \$USER $ROOT"
scp -q index.html widget.html manifest.webmanifest sw.js "$HOST:$ROOT/"
ssh "$HOST" "mkdir -p $ROOT/icons"
scp -q icons/*.png icons/icon.svg "$HOST:$ROOT/icons/"
ssh "$HOST" "mkdir -p $ROOT/grove"
scp -q grove/*.md "$HOST:$ROOT/grove/"

ssh "$HOST" 'sudo tee /etc/nginx/sites-available/weather-now >/dev/null <<EOF
server {
    listen 8000;
    server_name _;
    root /var/www/weather-now;
    index index.html;
    add_header Cache-Control "no-cache";
    location = /sw.js { add_header Cache-Control "no-cache"; add_header Service-Worker-Allowed "/"; }
    location = /manifest.webmanifest { default_type application/manifest+json; add_header Cache-Control "no-cache"; }
    location ~ ^/(apod\.json|starlink\.tle)$ { add_header Access-Control-Allow-Origin "*"; add_header Cache-Control "no-cache"; }
    gzip_types text/plain application/json application/javascript text/css image/svg+xml application/manifest+json;
    add_header X-Content-Type-Options nosniff;
    location / { try_files \$uri \$uri/ /index.html; }
}
EOF
sudo ln -sf /etc/nginx/sites-available/weather-now /etc/nginx/sites-enabled/weather-now
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && (sudo systemctl reload nginx || sudo systemctl start nginx)
sudo systemctl enable nginx >/dev/null 2>&1 || true
curl -s -o /dev/null -w "local check: %{http_code}\n" http://127.0.0.1:8000/'
# Hourly cache of NASA's Astronomy Picture of the Day (keeps viewers off the API rate limit).
ssh "$HOST" 'sudo tee /usr/local/bin/apod-fetch.sh >/dev/null <<"EOF"
#!/usr/bin/env bash
set -u
OUT=/var/www/weather-now/apod.json
TMP=$(mktemp)
if curl -fsS -m 30 "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&thumbs=true" -o "$TMP" && python3 -c "import json,sys; j=json.load(open(sys.argv[1])); assert j.get(\"url\") or j.get(\"thumbnail_url\")" "$TMP"; then
  mv "$TMP" "$OUT"; chmod 644 "$OUT"
else
  rm -f "$TMP"
fi
EOF
sudo chmod +x /usr/local/bin/apod-fetch.sh
( crontab -l 2>/dev/null | grep -v apod-fetch; echo "17 * * * * /usr/local/bin/apod-fetch.sh" ) | crontab -
[ -s /var/www/weather-now/apod.json ] || /usr/local/bin/apod-fetch.sh'
# Starlink constellation elements from CelesTrak, every 6 hours (1.8 MB; keeps every viewer off CelesTrak's rate limit).
ssh "$HOST" 'sudo tee /usr/local/bin/starlink-fetch.sh >/dev/null <<"EOF"
#!/usr/bin/env bash
set -u
OUT=/var/www/weather-now/starlink.tle
TMP=$(mktemp)
if curl -fsS -m 120 "https://celestrak.org/NORAD/elements/gp.php?GROUP=starlink&FORMAT=TLE" -o "$TMP" && [ "$(grep -c "^1 " "$TMP")" -gt 1000 ]; then
  mv "$TMP" "$OUT"; chmod 644 "$OUT"
else
  rm -f "$TMP"
fi
EOF
sudo chmod +x /usr/local/bin/starlink-fetch.sh
( crontab -l 2>/dev/null | grep -v starlink-fetch; echo "23 */6 * * * /usr/local/bin/starlink-fetch.sh" ) | crontab -
[ -s /var/www/weather-now/starlink.tle ] || /usr/local/bin/starlink-fetch.sh'
echo "deployed to https://${HOST}"
