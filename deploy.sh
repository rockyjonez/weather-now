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
    location ~ ^/(apod\.json|launches\.json|starlink\.tle)$ { add_header Access-Control-Allow-Origin "*"; add_header Cache-Control "no-cache"; }
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
# Launch schedule from The Space Devs Launch Library, hourly.
# Unauthenticated callers are rate limited (about 15 requests an hour), so the VM holds one copy
# for every viewer and the page only calls the API directly if this file is unreachable.
ssh "$HOST" 'sudo tee /usr/local/bin/launch-fetch.sh >/dev/null <<"SHLAUNCH"
#!/usr/bin/env bash
set -u
OUT=/var/www/weather-now/launches.json
TMP=$(mktemp)
if curl -fsS -m 60 "https://ll.thespacedevs.com/2.3.0/launches/upcoming/?limit=12&mode=detailed" -o "$TMP.raw"; then
  python3 - "$TMP.raw" "$TMP" <<"PYLAUNCH"
import json, sys
raw, out = sys.argv[1], sys.argv[2]
j = json.load(open(raw))
def g(d, *path):
    c = d
    for k in path:
        c = c.get(k) if isinstance(c, dict) else None
    return c
rows = []
for d in j.get("results", []):
    vids = sorted(d.get("vid_urls") or [], key=lambda v: 0 if v.get("priority") else 1)
    watch = next((v for v in vids if any(s in (v.get("url") or "").lower() for s in ("youtube", "nasa", "spacex", "twitch"))), vids[0] if vids else None)
    info = (d.get("info_urls") or [{}])[0].get("url")
    lat, lon = g(d, "pad", "latitude"), g(d, "pad", "longitude")
    rows.append({
        "id": d.get("id"), "name": d.get("name"), "net": d.get("net"),
        "precision": g(d, "net_precision", "name") or "Day",
        "statusAbbrev": g(d, "status", "abbrev"), "statusName": g(d, "status", "name"),
        "statusNote": g(d, "status", "description"),
        "provider": g(d, "launch_service_provider", "name"),
        "rocket": g(d, "rocket", "configuration", "full_name") or g(d, "rocket", "configuration", "name"),
        "mission": g(d, "mission", "name"), "missionType": g(d, "mission", "type"),
        "orbit": g(d, "mission", "orbit", "name"), "about": g(d, "mission", "description"),
        "pad": g(d, "pad", "name"), "place": g(d, "pad", "location", "name"),
        "lat": float(lat) if lat not in (None, "") else None,
        "lon": float(lon) if lon not in (None, "") else None,
        "image": g(d, "image", "image_url"), "probability": d.get("probability"),
        "weather": d.get("weather_concerns"), "info": info,
        "watch": watch.get("url") if watch else None,
        "watchWho": watch.get("publisher") if watch else None,
        "live": d.get("webcast_live"),
    })
assert rows, "no launches"
json.dump(rows, open(out, "w"))
PYLAUNCH
  if [ -s "$TMP" ]; then mv "$TMP" "$OUT"; chmod 644 "$OUT"; fi
fi
rm -f "$TMP" "$TMP.raw"
SHLAUNCH
sudo chmod +x /usr/local/bin/launch-fetch.sh
( crontab -l 2>/dev/null | grep -v launch-fetch; echo "41 * * * * /usr/local/bin/launch-fetch.sh" ) | crontab -
/usr/local/bin/launch-fetch.sh'
echo "deployed to https://${HOST}"
