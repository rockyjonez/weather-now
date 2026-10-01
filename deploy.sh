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
# Hourly cache of NASA's Astronomy Picture of the Day.
# NASA retired apod.nasa.gov and api.nasa.gov/planetary/apod on 2026-10-01; the picture now comes from
# science.nasa.gov's own endpoint. We normalise it into the shape the page has always read.
ssh "$HOST" 'sudo tee /usr/local/bin/apod-fetch.sh >/dev/null <<"SHAPOD"
#!/usr/bin/env bash
set -u
OUT=/var/www/weather-now/apod.json
TMP=$(mktemp)
if curl -fsS -m 45 "https://science.nasa.gov/wp-json/wp/v2/apod-basic?per_page=1" -o "$TMP.raw"; then
  python3 - "$TMP.raw" "$TMP" <<"PYAPOD"
import html, json, re, sys
raw, out = sys.argv[1], sys.argv[2]
j = json.load(open(raw))
d = j[0] if isinstance(j, list) else j
strip = lambda s: re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", "", s or ""))).strip()
def sized(u, w):
    if not u:
        return u
    return re.sub(r"([?&])w=\d+", r"\g<1>w=%d" % w, u) if "assets.science.nasa.gov" in u else u
img = d.get("hdurl") or d.get("url")
rec = {"date": d["date"], "title": strip(d.get("title")),
       "explanation": re.sub(r"^Explanation:\s*", "", strip(d.get("explanation")), flags=re.I),
       "url": sized(img, 1200), "hdurl": sized(img, 2400),
       "media_type": d.get("media_type"), "copyright": strip(d.get("copyright") or d.get("credit")),
       "permalink": d.get("permalink") or d.get("url"), "alt": strip(d.get("alt"))}
assert rec["url"], "no image url"
json.dump(rec, open(out, "w"))
PYAPOD
  if [ -s "$TMP" ]; then mv "$TMP" "$OUT"; chmod 644 "$OUT"; fi
fi
rm -f "$TMP" "$TMP.raw"
SHAPOD
sudo chmod +x /usr/local/bin/apod-fetch.sh
( crontab -l 2>/dev/null | grep -v apod-fetch; echo "17 * * * * /usr/local/bin/apod-fetch.sh" ) | crontab -
/usr/local/bin/apod-fetch.sh'
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
