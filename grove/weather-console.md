<!--{"pinCode":false,"dname":"wc-styles","codeMode":"js","hide":true}-->
```js
{
  const id = "wc-console-styles";
  if (!document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id;
    s.textContent = `
      .wc{font-family:"Exo 2",-apple-system,system-ui,sans-serif;color:#eaf2ff;font-size:14px;line-height:1.5}
      .wc-card{position:relative;background:#0b1c3a;border:1px solid #22437c;border-radius:12px;padding:16px 18px;margin:0 0 12px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,.35)}
      .wc-card::before{content:"";position:absolute;left:0;right:0;top:0;height:2px;background:linear-gradient(90deg,transparent,#f5b83d 30%,#f5b83d 70%,transparent);opacity:.7}
      .wc-eyebrow{font-size:11px;letter-spacing:.3em;text-transform:uppercase;color:#7f95bf;margin-bottom:4px}
      .wc-h{font-family:"Audiowide","Exo 2",sans-serif;font-weight:400;letter-spacing:.08em;text-transform:uppercase;color:#ffd27a;font-size:15px;margin:0 0 8px}
      .wc-hero{background:radial-gradient(ellipse 90% 80% at 50% -10%,#123a7a 0%,#0b1c3a 60%);border:1px solid #22437c;border-radius:12px;padding:22px 24px;margin-bottom:12px}
      .wc-hero h1{font-family:"Audiowide","Exo 2",sans-serif;font-weight:400;font-size:26px;letter-spacing:.06em;text-transform:uppercase;color:#ffd27a;margin:2px 0 6px;text-shadow:0 0 14px rgba(245,184,61,.45)}
      .wc-hero p{color:#b9c9e6;margin:0;max-width:760px}
      .wc-tiles{display:grid;grid-template-columns:repeat(auto-fill,minmax(130px,1fr));gap:8px}
      .wc-tile{background:#112748;border:1px solid #22437c;border-radius:10px;padding:10px 12px}
      .wc-tile .k{font-size:10px;letter-spacing:.14em;text-transform:uppercase;color:#7f95bf}
      .wc-tile .v{font-family:"Audiowide","Exo 2",sans-serif;font-size:20px;color:#eaf2ff;margin-top:2px}
      .wc-tile .s{font-size:12px;color:#b9c9e6}
      .wc-big{font-family:"Audiowide","Exo 2",sans-serif;font-size:48px;color:#ffd27a;line-height:1;text-shadow:0 0 14px rgba(245,184,61,.45)}
      .wc-muted{color:#7f95bf;font-size:12px}
      .wc-table{width:100%;border-collapse:collapse;font-size:12.5px}
      .wc-table th{text-align:left;color:#7f95bf;font-weight:600;font-size:11px;letter-spacing:.1em;text-transform:uppercase;padding:6px 8px;border-bottom:1px solid #22437c}
      .wc-table td{padding:6px 8px;border-bottom:1px solid rgba(255,255,255,.05);color:#b9c9e6;vertical-align:top}
      .wc-table td.on{color:#ffd27a;font-weight:600}
      .wc-row{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin:6px 0}
      .wc button, .wc-row button{background:#0b1c3a;color:#eaf2ff;border:1px solid #22437c;border-radius:999px;padding:6px 14px;font:inherit;cursor:pointer}
      .wc button:hover, .wc-row button:hover{border-color:#f5b83d;color:#f5b83d}
      .wc-words{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:6px;font-size:12.5px}
      .wc-words>div{background:#112748;border:1px solid #22437c;border-radius:8px;padding:6px 9px}
      .wc-words b{display:block;font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:#7f95bf}
      .wc img.wc-img{width:100%;max-width:820px;border-radius:10px;border:1px solid #22437c;display:block;background:#000}
    `;
    document.head.appendChild(s);
  }
  if (!document.getElementById("wc-fonts")) {
    const l = document.createElement("link");
    l.id = "wc-fonts"; l.rel = "stylesheet";
    l.href = "https://fonts.googleapis.com/css2?family=Audiowide&family=Exo+2:wght@400;600;700&display=swap";
    document.head.appendChild(l);
  }
  return html`<span style="display:none"></span>`;
}
```

<!--{"pinCode":false,"dname":"wc-hero","codeMode":"js","hide":false}-->
```js
html`<div class="wc"><div class="wc-hero">
  <div class="wc-eyebrow">Weather console · GraphXR edition</div>
  <h1>Weather Now</h1>
  <p>The same live sources as the web page, but every hour, alert, satellite, pass and sky event becomes a node on the canvas.
  Pick a location, build the graph, then put the Earth on the canvas and watch the satellites move.</p>
</div></div>`
```

<!--{"pinCode":false,"dname":"wc-loc-input","codeMode":"js","hide":false}-->
```js
viewof locQuery = Inputs.text({label: "Location", value: "07304", placeholder: "ZIP, city, or lat,lon (US only)", submit: "Go"})
```

<!--{"pinCode":false,"dname":"wc-loc","codeMode":"js","hide":true}-->
```js
loc = {
  const q = (locQuery || "07304").trim();
  const m = /^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$/.exec(q);
  if (m) return { lat: +m[1], lon: +m[2], label: `${(+m[1]).toFixed(3)}, ${(+m[2]).toFixed(3)}` };
  if (q === "07304") return { lat: 40.7141, lon: -74.0744, label: "Jersey City, NJ 07304" };
  const isZip = /^\d{5}$/.test(q);
  const url = isZip
    ? `https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&country=us&postalcode=${q}`
    : `https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&countrycodes=us,pr,vi,gu,as,mp&q=${encodeURIComponent(q)}`;
  const r = await fetch(url, { headers: { Accept: "application/json" } });
  const j = await r.json();
  if (!j.length) throw new Error(`No US place found for "${q}"`);
  const name = isZip ? `${j[0].display_name.split(",").slice(1, 3).map(s => s.trim()).join(", ")} ${q}` : j[0].display_name.split(",").slice(0, 2).map(s => s.trim()).join(", ");
  return { lat: +j[0].lat, lon: +j[0].lon, label: name };
}
```

<!--{"pinCode":false,"dname":"wc-astro","codeMode":"js","hide":true}-->
```js
astro = {
  const rad = Math.PI / 180, DEG = 180 / Math.PI, dayMs = 864e5, HOUR = 36e5;
  const J2000ms = Date.UTC(2000, 0, 1, 12), OBL = rad * 23.4397;
  const jd = t => (t - J2000ms) / dayMs;
  const sunCoords = d => { const M = rad * (357.5291 + 0.98560028 * d), L = M + rad * (1.9148 * Math.sin(M) + 0.02 * Math.sin(2 * M) + 0.0003 * Math.sin(3 * M)) + rad * 102.9372 + Math.PI; return { dec: Math.asin(Math.sin(OBL) * Math.sin(L)), ra: Math.atan2(Math.sin(L) * Math.cos(OBL), Math.cos(L)) }; };
  const moonCoords = d => { const L = rad * (218.316 + 13.176396 * d), M = rad * (134.963 + 13.064993 * d), F = rad * (93.272 + 13.229350 * d); const l = L + rad * 6.289 * Math.sin(M), b = rad * 5.128 * Math.sin(F), dist = 385001 - 20905 * Math.cos(M); return { ra: Math.atan2(Math.sin(l) * Math.cos(OBL) - Math.tan(b) * Math.sin(OBL), Math.cos(l)), dec: Math.asin(Math.sin(b) * Math.cos(OBL) + Math.cos(b) * Math.sin(OBL) * Math.sin(l)), dist }; };
  const sidereal = (d, lw) => rad * (280.16 + 360.9856235 * d) - lw;
  const altAz = (ra, dec, d, lat, lon) => { const lw = -rad * lon, phi = rad * lat, H = sidereal(d, lw) - ra; const alt = Math.asin(Math.sin(phi) * Math.sin(dec) + Math.cos(phi) * Math.cos(dec) * Math.cos(H)); const az = Math.atan2(Math.sin(H), Math.cos(H) * Math.sin(phi) - Math.tan(dec) * Math.cos(phi)) + Math.PI; return { alt, az: (az + 2 * Math.PI) % (2 * Math.PI) }; };
  const sunAlt = (t, lat, lon) => { const d = jd(t), s = sunCoords(d); return altAz(s.ra, s.dec, d, lat, lon).alt; };
  const sunTimes = (t, lat, lng) => {
    const J1970 = 2440588, J2000 = 2451545, toDays = ms => ms / dayMs - 0.5 + J1970 - J2000, fromJ = j => (j + 0.5 - J1970) * dayMs;
    const lw = rad * -lng, phi = rad * lat, d = toDays(t), n = Math.round(d - 0.0009 - lw / (2 * Math.PI));
    const ds = 0.0009 + lw / (2 * Math.PI) + n, M = rad * (357.5291 + 0.98560028 * ds);
    const L = M + rad * (1.9148 * Math.sin(M) + 0.02 * Math.sin(2 * M) + 0.0003 * Math.sin(3 * M)) + rad * 102.9372 + Math.PI;
    const dec = Math.asin(Math.sin(OBL) * Math.sin(L)), Jnoon = J2000 + ds + 0.0053 * Math.sin(M) - 0.0069 * Math.sin(2 * L);
    const w = Math.acos((Math.sin(-0.833 * rad) - Math.sin(phi) * Math.sin(dec)) / (Math.cos(phi) * Math.cos(dec)));
    if (isNaN(w)) return null;
    const Jset = J2000 + (0.0009 + (w + lw) / (2 * Math.PI) + n) + 0.0053 * Math.sin(M) - 0.0069 * Math.sin(2 * L);
    return { sunrise: fromJ(Jnoon - (Jset - Jnoon)), sunset: fromJ(Jset) };
  };
  const moonIllum = t => { const d = jd(t), s = sunCoords(d), m = moonCoords(d), sdist = 149598000; const phi = Math.acos(Math.sin(s.dec) * Math.sin(m.dec) + Math.cos(s.dec) * Math.cos(m.dec) * Math.cos(s.ra - m.ra)); const inc = Math.atan2(sdist * Math.sin(phi), m.dist - sdist * Math.cos(phi)); const angle = Math.atan2(Math.cos(s.dec) * Math.sin(s.ra - m.ra), Math.sin(s.dec) * Math.cos(m.dec) - Math.cos(s.dec) * Math.sin(m.dec) * Math.cos(s.ra - m.ra)); return { fraction: (1 + Math.cos(inc)) / 2, phase: 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Math.PI }; };
  const moonAlt = (t, lat, lon) => { const d = jd(t), m = moonCoords(d); const a = altAz(m.ra, m.dec, d, lat, lon).alt; return a - Math.atan(6371 / m.dist) * Math.cos(a); };
  const moonTimes = (t0, lat, lon) => {
    const hc = 0.133 * rad; let h0 = moonAlt(t0, lat, lon) - hc, rise, set, ye = 0;
    for (let i = 1; i <= 24; i += 2) {
      const h1 = moonAlt(t0 + i * HOUR, lat, lon) - hc, h2 = moonAlt(t0 + (i + 1) * HOUR, lat, lon) - hc;
      const a = (h0 + h2) / 2 - h1, b = (h2 - h0) / 2, xe = -b / (2 * a); ye = (a * xe + b) * xe + h1;
      const dd = b * b - 4 * a * h1; let roots = 0, x1 = 0, x2 = 0;
      if (dd >= 0) { const dx = Math.sqrt(dd) / (Math.abs(a) * 2); x1 = xe - dx; x2 = xe + dx; if (Math.abs(x1) <= 1) roots++; if (Math.abs(x2) <= 1) roots++; if (x1 < -1) x1 = x2; }
      if (roots === 1) { if (h0 < 0) rise = i + x1; else set = i + x1; } else if (roots === 2) { rise = i + (ye < 0 ? x2 : x1); set = i + (ye < 0 ? x1 : x2); }
      if (rise != null && set != null) break; h0 = h2;
    }
    const r = {}; if (rise != null) r.rise = t0 + rise * HOUR; if (set != null) r.set = t0 + set * HOUR; return r;
  };
  const PL = [["Mercury", 0.38709927, 0.20563593, 7.00497902, 252.25032350, 77.45779628, 48.33076593, 0.00000037, 0.00001906, -0.00594749, 149472.67411175, 0.16047689, -0.12534081], ["Venus", 0.72333566, 0.00677672, 3.39467605, 181.97909950, 131.60246718, 76.67984255, 0.00000390, -0.00004107, -0.00078890, 58517.81538729, 0.00268329, -0.27769418], ["Earth", 1.00000261, 0.01671123, -0.00001531, 100.46457166, 102.93768193, 0.0, 0.00000562, -0.00004392, -0.01294668, 35999.37244981, 0.32327364, 0.0], ["Mars", 1.52371034, 0.09339410, 1.84969142, -4.55343205, -23.94362959, 49.55953891, 0.00001847, 0.00007882, -0.00813131, 19140.30268499, 0.44441088, -0.29257343], ["Jupiter", 5.20288700, 0.04838624, 1.30439695, 34.39644051, 14.72847983, 100.47390909, -0.00011607, -0.00013253, -0.00183714, 3034.74612775, 0.21252668, 0.20469106], ["Saturn", 9.53667594, 0.05386179, 2.48599187, 49.95424423, 92.59887831, 113.66242448, -0.00125060, -0.00050991, 0.00193609, 1222.49362201, -0.41897216, -0.28867794]];
  const helio = (p, T) => { const a = p[1] + p[7] * T, e = p[2] + p[8] * T, I = rad * (p[3] + p[9] * T), L = p[4] + p[10] * T, wb = p[5] + p[11] * T, Od = p[6] + p[12] * T, O = rad * Od, w = rad * (wb - Od); const M = rad * ((((L - wb) % 360) + 540) % 360 - 180); let E = M + e * Math.sin(M); for (let i = 0; i < 12; i++) { const dE = (M - (E - e * Math.sin(E))) / (1 - e * Math.cos(E)); E += dE; if (Math.abs(dE) < 1e-9) break; } const xp = a * (Math.cos(E) - e), yp = a * Math.sqrt(1 - e * e) * Math.sin(E), cw = Math.cos(w), sw = Math.sin(w), cO = Math.cos(O), sO = Math.sin(O), cI = Math.cos(I), sI = Math.sin(I); return { x: (cw * cO - sw * sO * cI) * xp + (-sw * cO - cw * sO * cI) * yp, y: (cw * sO + sw * cO * cI) * xp + (-sw * sO + cw * cO * cI) * yp, z: sw * sI * xp + cw * sI * yp }; };
  const planetRaDec = (name, t) => { const T = jd(t) / 36525, E = helio(PL[2], T), P = helio(PL.find(p => p[0] === name), T); const x = P.x - E.x, y = P.y - E.y, z = P.z - E.z; const ye = y * Math.cos(OBL) - z * Math.sin(OBL), ze = y * Math.sin(OBL) + z * Math.cos(OBL); return { ra: Math.atan2(ye, x), dec: Math.atan2(ze, Math.hypot(x, ye)) }; };
  const angSep = (a, b) => Math.acos(Math.min(1, Math.sin(a.dec) * Math.sin(b.dec) + Math.cos(a.dec) * Math.cos(b.dec) * Math.cos(a.ra - b.ra)));
  const NAMES = ["Mercury", "Venus", "Mars", "Jupiter", "Saturn"];
  const compass8 = az => ["N", "NE", "E", "SE", "S", "SW", "W", "NW"][Math.round(((az * DEG) % 360) / 45) % 8];
  const planetsUp = (t, lat, lon, minAlt = 8) => { const d = jd(t), s = sunCoords(d), out = []; NAMES.forEach(n => { const p = planetRaDec(n, t), aa = altAz(p.ra, p.dec, d, lat, lon), el = angSep(p, s) * DEG; if (aa.alt * DEG >= minAlt && el > 12) out.push({ name: n, alt: aa.alt * DEG, az: aa.az * DEG, dir: compass8(aa.az) }); }); return out.sort((a, b) => b.alt - a.alt); };
  const PHASES = [[0.0625, "New moon", "🌑"], [0.1875, "Waxing crescent", "🌒"], [0.3125, "First quarter", "🌓"], [0.4375, "Waxing gibbous", "🌔"], [0.5625, "Full moon", "🌕"], [0.6875, "Waning gibbous", "🌖"], [0.8125, "Last quarter", "🌗"], [0.9375, "Waning crescent", "🌘"], [1.01, "New moon", "🌑"]];
  const phaseName = ph => PHASES.find(x => ph < x[0]);
  const phaseEvents = (from, to) => { const ev = [], targets = [[0, "New moon", "🌑"], [0.25, "First quarter", "🌓"], [0.5, "Full moon", "🌕"], [0.75, "Last quarter", "🌗"]]; let prev = moonIllum(from).phase; for (let t = from + HOUR; t <= to; t += HOUR) { const ph = moonIllum(t).phase; targets.forEach(([tg, name, emoji]) => { const cross = tg === 0 ? (prev > 0.9 && ph < 0.1) : (prev - tg < 0 && ph - tg >= 0); if (cross) ev.push({ t: t - HOUR / 2, name, emoji, kind: "moon" }); }); prev = ph; } return ev; };
  const seasonEvents = (from, to) => { const out = [], y0 = new Date(from).getUTCFullYear(); for (const y of [y0, y0 + 1]) { const Y = (y - 2000) / 1000; [[2451623.80984 + 365242.37404 * Y + 0.05169 * Y * Y - 0.00411 * Y ** 3 - 0.00057 * Y ** 4, "March equinox", "🌍"], [2451716.56767 + 365241.62603 * Y + 0.00325 * Y * Y + 0.00888 * Y ** 3 - 0.00030 * Y ** 4, "June solstice", "☀️"], [2451810.21715 + 365242.01767 * Y - 0.11575 * Y * Y + 0.00337 * Y ** 3 + 0.00078 * Y ** 4, "September equinox", "🍂"], [2451900.05952 + 365242.74049 * Y - 0.06223 * Y * Y - 0.00823 * Y ** 3 + 0.00032 * Y ** 4, "December solstice", "❄️"]].forEach(([jde, name, emoji]) => { const t = (jde - 2440587.5) * dayMs; if (t >= from && t <= to) out.push({ t, name, emoji, kind: "season" }); }); } return out; };
  const SHOWERS = [["Quadrantids", "01-03", 110], ["Lyrids", "04-22", 18], ["Eta Aquariids", "05-06", 50], ["Southern Delta Aquariids", "07-30", 25], ["Perseids", "08-12", 100], ["Draconids", "10-08", 10], ["Orionids", "10-21", 20], ["Southern Taurids", "11-05", 5], ["Northern Taurids", "11-12", 5], ["Leonids", "11-17", 15], ["Geminids", "12-14", 150], ["Ursids", "12-22", 10]];
  const ECLIPSES = [["2026-08-28", "Partial lunar eclipse"], ["2027-02-06", "Annular solar eclipse"], ["2027-02-20", "Penumbral lunar eclipse"], ["2027-07-18", "Penumbral lunar eclipse"], ["2027-08-02", "Total solar eclipse"], ["2027-08-17", "Penumbral lunar eclipse"], ["2028-01-12", "Partial lunar eclipse"], ["2028-01-26", "Annular solar eclipse"], ["2028-07-06", "Partial lunar eclipse"], ["2028-07-22", "Total solar eclipse"]];
  const tzOffsetMs = (t, tz) => { const p = {}; new Intl.DateTimeFormat("en-US", { timeZone: tz, hourCycle: "h23", year: "numeric", month: "numeric", day: "numeric", hour: "numeric", minute: "numeric", second: "numeric" }).formatToParts(new Date(t)).forEach(x => p[x.type] = x.value); return Date.UTC(+p.year, p.month - 1, +p.day, +p.hour, +p.minute, +p.second) - Math.floor(t / 1000) * 1000; };
  const localMidnight = (dateStr, tz) => { const [y, m, d] = dateStr.split("-").map(Number); return Date.UTC(y, m - 1, d) - tzOffsetMs(Date.UTC(y, m - 1, d, 12), tz); };
  const fmtTime = (t, tz) => new Intl.DateTimeFormat("en-US", { hour: "numeric", minute: "2-digit", timeZone: tz }).format(new Date(t));
  const fmtDT = (t, tz) => new Intl.DateTimeFormat("en-US", { weekday: "short", hour: "numeric", minute: "2-digit", timeZone: tz }).format(new Date(t));
  const calendar = (lat, lon, tz, days = 10) => {
    const today = new Date().toLocaleDateString("en-CA", { timeZone: tz }), out = [];
    for (let i = 0; i < days; i++) {
      const t0 = localMidnight(today, tz) + i * dayMs, date = new Date(t0 + 12 * HOUR).toLocaleDateString("en-CA", { timeZone: tz });
      const sun = sunTimes(t0 + 12 * HOUR, lat, lon), moon = moonTimes(t0, lat, lon), ill = moonIllum(t0 + 12 * HOUR);
      const evening = sun ? sun.sunset + 75 * 60e3 : null, morning = sun ? sun.sunrise - 75 * 60e3 : null;
      const events = [], mmdd = date.slice(5);
      SHOWERS.forEach(([n, peak, zhr]) => { if (mmdd === peak) events.push({ kind: "shower", name: `${n} peak`, note: `up to ${zhr}/h`, emoji: "☄️" }); });
      ECLIPSES.forEach(([d, n]) => { if (d === date) events.push({ kind: "eclipse", name: n, note: "", emoji: "🌘" }); });
      [[t0 + 21 * HOUR, "evening"], [t0 + 5 * HOUR, "before dawn"]].forEach(([tt, when]) => {
        const d = jd(tt), m = moonCoords(d), pl = NAMES.map(n => ({ n, c: planetRaDec(n, tt) }));
        pl.forEach(p => { const sep = angSep(m, p.c) * DEG; if (sep < 5 && altAz(p.c.ra, p.c.dec, d, lat, lon).alt > 0) events.push({ kind: "conj", name: `Moon near ${p.n}`, note: `${sep.toFixed(1)}° apart, ${when}`, emoji: "🌙" }); });
        for (let a = 0; a < pl.length; a++) for (let b = a + 1; b < pl.length; b++) { const sep = angSep(pl[a].c, pl[b].c) * DEG; if (sep < 2.5 && altAz(pl[a].c.ra, pl[a].c.dec, d, lat, lon).alt > 0) events.push({ kind: "conj", name: `${pl[a].n} near ${pl[b].n}`, note: `${sep.toFixed(1)}° apart, ${when}`, emoji: "✨" }); }
      });
      out.push({ i, date, t0, sun, moon, ill, phase: phaseName(ill.phase), evening, morning, eveningPlanets: evening ? planetsUp(evening, lat, lon) : [], morningPlanets: morning ? planetsUp(morning, lat, lon) : [], events });
    }
    const from = out[0].t0, to = out[days - 1].t0 + dayMs;
    [...phaseEvents(from, to), ...seasonEvents(from, to)].forEach(e => { const dt = new Date(e.t).toLocaleDateString("en-CA", { timeZone: tz }); const dy = out.find(x => x.date === dt); if (dy) dy.events.unshift({ ...e, note: fmtTime(e.t, tz) }); });
    out.forEach(dy => { const seen = new Set(); dy.events = dy.events.filter(e => { const k = e.kind + e.name; if (seen.has(k)) return false; seen.add(k); return true; }); });
    return out;
  };
  return { rad, DEG, dayMs, HOUR, jd, sunCoords, altAz, sunAlt, sunTimes, moonIllum, moonTimes, planetsUp, compass8, calendar, fmtTime, fmtDT, phaseName };
}
```

<!--{"pinCode":false,"dname":"wc-wx","codeMode":"js","hide":true}-->
```js
wx = {
  const API = "https://api.weather.gov", HOUR = 36e5;
  const nws = async url => { const r = await fetch(url, { headers: { Accept: "application/geo+json" } }); if (!r.ok) throw new Error(`NWS ${r.status} for ${url}`); return r.json(); };
  const pts = (await nws(`${API}/points/${loc.lat.toFixed(4)},${loc.lon.toFixed(4)}`)).properties;
  const [grid, hourly, stations, alerts, daily, om] = await Promise.all([
    nws(pts.forecastGridData), nws(pts.forecastHourly).catch(() => null), nws(pts.observationStations).catch(() => null),
    nws(`${API}/alerts/active?point=${loc.lat.toFixed(4)},${loc.lon.toFixed(4)}`).catch(() => ({ features: [] })), nws(pts.forecast).catch(() => null),
    fetch(`https://api.open-meteo.com/v1/forecast?latitude=${loc.lat.toFixed(4)}&longitude=${loc.lon.toFixed(4)}&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max&forecast_days=10&timezone=${encodeURIComponent(pts.timeZone || "auto")}`).then(r => r.ok ? r.json() : null).catch(() => null)
  ]);
  let obs = null;
  if (stations) for (const f of stations.features.slice(0, 4)) { try { const o = await nws(`${API}/stations/${f.properties.stationIdentifier}/observations/latest`); if (o.properties.temperature.value != null) { obs = o.properties; obs.stationName = f.properties.name; break; } } catch (e) { } }
  const parseValid = vt => { const [s, d] = vt.split("/"); const start = Date.parse(s); const m = /P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?)?/.exec(d || "PT1H"); const hrs = (+(m[1] || 0)) * 24 + (+(m[2] || 0)) + (+(m[3] || 0)) / 60; return { start, end: start + Math.max(hrs, 1) * HOUR, hours: Math.max(hrs, 1) }; };
  const layer = name => { const L = grid.properties[name]; if (!L || !L.values || !L.values.length) return null; const segs = L.values.map(v => ({ ...parseValid(v.validTime), value: v.value })); return t => segs.find(s => t >= s.start && t < s.end) || null; };
  const NUM = ["temperature", "apparentTemperature", "dewpoint", "relativeHumidity", "skyCover", "windDirection", "windSpeed", "windGust", "probabilityOfPrecipitation", "probabilityOfThunder", "snowfallAmount", "quantitativePrecipitation"];
  const L = {}; NUM.forEach(n => L[n] = layer(n)); L.hazards = layer("hazards"); L.weather = layer("weather");
  const periods = {}; if (hourly) hourly.properties.periods.forEach(p => periods[Date.parse(p.startTime)] = p);
  const h0 = Math.floor(Date.now() / HOUR) * HOUR, tz = pts.timeZone;
  const toF = c => c == null ? null : Math.round(c * 9 / 5 + 32), mph = k => k == null ? null : Math.round(k / 1.609344), inch = mm => mm == null ? null : Math.round(mm / 25.4 * 100) / 100;
  const rows = Array.from({ length: 13 }, (_, i) => {
    const t = h0 + i * HOUR, g = n => { const s = L[n] && L[n](t); return s ? s.value : null; };
    const acc = n => { const s = L[n] && L[n](t); return s && s.value != null ? s.value / s.hours : null; };
    const per = periods[t];
    const r = { hourIndex: i, time: new Date(t).toISOString(), label: i === 0 ? "Now" : astro.fmtTime(t, tz), tempF: toF(g("temperature")) ?? (per ? per.temperature : null), feelsF: toF(g("apparentTemperature")), dewF: toF(g("dewpoint")), humidity: g("relativeHumidity"), skyCover: g("skyCover"), windDir: g("windDirection"), windMph: mph(g("windSpeed")), gustMph: mph(g("windGust")), rainChance: g("probabilityOfPrecipitation") ?? (per && per.probabilityOfPrecipitation ? per.probabilityOfPrecipitation.value : null), thunderChance: g("probabilityOfThunder"), precipIn: inch(acc("quantitativePrecipitation")), snowIn: inch(acc("snowfallAmount")), condition: per ? per.shortForecast : "", icon: per ? per.icon : null, night: astro.sunAlt(t + HOUR / 2, loc.lat, loc.lon) < 0 };
    const hz = L.hazards && L.hazards(t); r.hazards = hz && hz.value ? hz.value.filter(Boolean).map(h => `${h.phenomenon}.${h.significance}`).join(" ") : "";
    return r;
  });
  const days = new Map();
  if (om && om.daily) om.daily.time.forEach((date, i) => { const g = k => om.daily[k] ? om.daily[k][i] : null; days.set(date, { date, hiF: toF(g("temperature_2m_max")), loF: toF(g("temperature_2m_min")), rainChance: g("precipitation_probability_max"), precipIn: inch(g("precipitation_sum")), windMph: mph(g("wind_speed_10m_max")), gustMph: mph(g("wind_gusts_10m_max")), code: g("weather_code"), source: "Open-Meteo" }); });
  if (daily) daily.properties.periods.forEach(p => { const k = p.startTime.slice(0, 10); if (!days.has(k)) days.set(k, { date: k }); const d = days.get(k); d.source = "NWS"; const tF = p.temperatureUnit === "F" ? p.temperature : Math.round(p.temperature * 9 / 5 + 32); if (p.isDaytime) { d.hiF = tF; d.condition = p.shortForecast; d.detail = p.detailedForecast; d.icon = p.icon; } else { d.loF = tF; d.nightCondition = p.shortForecast; d.nightDetail = p.detailedForecast; if (!d.condition) { d.condition = p.shortForecast; d.icon = p.icon; } } });
  const today = new Date().toLocaleDateString("en-CA", { timeZone: tz });
  const dailyRows = [...days.values()].filter(d => d.date >= today).sort((a, b) => a.date.localeCompare(b.date)).slice(0, 10).map((d, i) => ({ dayIndex: i, ...d }));
  const alertRows = (alerts.features || []).map(f => f.properties).map(a => ({ id: a.id, event: a.event, severity: a.severity, urgency: a.urgency, headline: a.headline, sender: a.senderName, ends: a.ends || a.expires, areas: a.areaDesc, description: a.description }));
  return { tz, pts, rows, dailyRows, alerts: alertRows, obs, office: pts.gridId, grid: `${pts.gridX},${pts.gridY}`, radar: pts.radarStation, updated: new Date().toISOString() };
}
```

<!--{"pinCode":false,"dname":"wc-now","codeMode":"js","hide":false}-->
```js
{
  const o = wx.obs, r0 = wx.rows[0], tz = wx.tz;
  const v = (x, u = "") => x == null ? "–" : `${x}${u}`;
  const temp = o ? Math.round(o.temperature.value * 9 / 5 + 32) : r0.tempF;
  const wind = o && o.windSpeed && o.windSpeed.value != null ? Math.round(o.windSpeed.value / 1.609344) : r0.windMph;
  const dir = d => d == null ? "" : ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"][Math.round(d / 22.5) % 16];
  const wdir = o && o.windDirection && o.windDirection.value != null ? o.windDirection.value : r0.windDir;
  const tile = (k, val, s) => `<div class="wc-tile"><div class="k">${k}</div><div class="v">${val}</div>${s ? `<div class="s">${s}</div>` : ""}</div>`;
  return html`<div class="wc"><div class="wc-card">
    <div class="wc-eyebrow">${wx.pts.relativeLocation ? wx.pts.relativeLocation.properties.city + ", " + wx.pts.relativeLocation.properties.state : loc.label} · NWS ${wx.office} grid ${wx.grid}</div>
    <div style="display:flex;gap:16px;align-items:center;flex-wrap:wrap;margin-bottom:10px">
      ${r0.icon ? `<img src="${r0.icon.replace(/size=\w+/, "size=medium")}" style="width:64px;height:64px;border-radius:10px">` : ""}
      <div><div class="wc-big">${v(temp, "°")}</div><div style="color:#b9c9e6">${(o && o.textDescription) || r0.condition}</div>
      <div class="wc-muted">${o ? `Observed ${astro.fmtTime(Date.parse(o.timestamp), tz)} at ${o.stationName}` : "Forecast for this hour"}</div></div>
    </div>
    <div class="wc-tiles">
      ${tile("Wind", `${dir(wdir)} ${v(wind, " mph")}`, r0.gustMph != null ? `gusts ${r0.gustMph} mph` : "")}
      ${tile("Humidity", v(r0.humidity, "%"), `dew point ${v(r0.dewF, "°")}`)}
      ${tile("Cloud cover", v(r0.skyCover, "%"))}
      ${tile("Rain chance", v(r0.rainChance, "%"), "this hour")}
      ${tile("Thunder", v(r0.thunderChance, "%"))}
      ${tile("Alerts", String(wx.alerts.length), wx.alerts[0] ? wx.alerts[0].event : "none active")}
    </div></div></div>`;
}
```

<!--{"pinCode":false,"dname":"wc-hourly-chart","codeMode":"js","hide":false}-->
```js
{
  const R = wx.rows;
  const vals = R.flatMap(r => [r.tempF, r.feelsF]).filter(v => v != null), lo = Math.floor(Math.min(...vals) - 3), hi = Math.ceil(Math.max(...vals) + 3);
  const p1 = Plot.plot({ width, height: 220, marginLeft: 44, style: { background: "transparent", color: "#b9c9e6", fontFamily: "Exo 2, system-ui, sans-serif" },
    x: { domain: R.map(r => r.label), label: null }, y: { grid: true, label: "°F", domain: [lo, hi] },
    marks: [
      Plot.rectY(R.filter(r => r.night), { x: "label", y1: () => lo, y2: () => hi, fill: "#000", fillOpacity: .28, insetLeft: -6, insetRight: -6 }),
      Plot.lineY(R, { x: "label", y: "tempF", stroke: "#e8722f", strokeWidth: 2 }), Plot.dot(R, { x: "label", y: "tempF", fill: "#e8722f", r: 3.5, title: d => `${d.label}: ${d.tempF}°F, feels ${d.feelsF}°F\n${d.condition}` }),
      Plot.lineY(R, { x: "label", y: "feelsF", stroke: "#dd6a97", strokeWidth: 2, strokeDasharray: "6 4" })
    ] });
  const p2 = Plot.plot({ width, height: 160, marginLeft: 44, style: { background: "transparent", color: "#b9c9e6", fontFamily: "Exo 2, system-ui, sans-serif" },
    x: { domain: R.map(r => r.label), label: null }, y: { domain: [0, 100], grid: true, label: "Rain %" },
    marks: [Plot.barY(R, { x: "label", y: "rainChance", fill: "#4d9cf0", rx: 3, title: d => `${d.label}: ${d.rainChance}% rain, ${d.thunderChance ?? 0}% thunder` })] });
  return html`<div class="wc"><div class="wc-card"><div class="wc-h">Next 12 hours</div><div class="wc-muted" style="margin-bottom:6px">Temperature (orange), feels-like (dashed) and chance of rain. Night hours shaded.</div>${p1}${p2}</div></div>`;
}
```

<!--{"pinCode":false,"dname":"wc-daily-chart","codeMode":"js","hide":false}-->
```js
{
  const D = wx.dailyRows, lab = d => new Intl.DateTimeFormat("en-US", { weekday: "short", timeZone: "UTC" }).format(new Date(d.date + "T12:00:00Z"));
  const p = Plot.plot({ width, height: 220, marginLeft: 44, style: { background: "transparent", color: "#b9c9e6", fontFamily: "Exo 2, system-ui, sans-serif" },
    x: { domain: D.map(lab), label: null }, y: { grid: true, label: "°F", nice: true },
    marks: [
      Plot.areaY(D, { x: lab, y1: "loF", y2: "hiF", fill: "#e8722f", fillOpacity: .12, curve: "monotone-x" }),
      Plot.lineY(D, { x: lab, y: "hiF", stroke: "#e8722f", strokeWidth: 2, curve: "monotone-x" }), Plot.dot(D, { x: lab, y: "hiF", fill: "#e8722f", r: 3.5, title: d => `${d.date}: high ${d.hiF}°F, low ${d.loF}°F\n${d.condition || ""} (${d.source})` }),
      Plot.lineY(D, { x: lab, y: "loF", stroke: "#4d9cf0", strokeWidth: 2, curve: "monotone-x" }), Plot.dot(D, { x: lab, y: "loF", fill: "#4d9cf0", r: 3.5 })
    ] });
  return html`<div class="wc"><div class="wc-card"><div class="wc-h">10-day outlook</div><div class="wc-muted" style="margin-bottom:6px">Highs and lows. Days 1–7 from the NWS, days 8–10 from Open-Meteo model guidance.</div>${p}</div></div>`;
}
```

<!--{"pinCode":false,"dname":"wc-satlib","codeMode":"js","hide":true}-->
```js
satlib = require("satellite.js@5.0.0/dist/satellite.min.js")
```

<!--{"pinCode":false,"dname":"wc-sats","codeMode":"js","hide":true}-->
```js
sats = {
  const SATS = [{ id: 25544, name: "ISS", emoji: "🛰️", pass: true, about: "International Space Station" }, { id: 48274, name: "Tiangong", emoji: "🛰️", pass: true, about: "Chinese space station" }, { id: 20580, name: "Hubble", emoji: "🔭", pass: true, about: "Hubble Space Telescope" }, { id: 43013, name: "NOAA-20", emoji: "🌐", about: "Polar-orbiting weather satellite" }, { id: 25994, name: "Terra", emoji: "🌍", about: "NASA Earth-observing satellite" }, { id: 49260, name: "Landsat 9", emoji: "📷", about: "Land-imaging satellite" }, { id: 60133, name: "GOES-19", emoji: "🌀", about: "Geostationary weather satellite (GOES-East)" }];
  const out = [];
  await Promise.all(SATS.map(async s => {
    try {
      const r = await fetch(`https://celestrak.org/NORAD/elements/gp.php?CATNR=${s.id}&FORMAT=TLE`);
      const L = (await r.text()).trim().split("\n").map(x => x.trim());
      if (L.length >= 3 && L[1].startsWith("1 ")) out.push({ ...s, l1: L[1], l2: L[2], satrec: satlib.twoline2satrec(L[1], L[2]) });
    } catch (e) { }
  }));
  if (!out.some(s => s.id === 25544)) { try { const j = await (await fetch("https://api.wheretheiss.at/v1/satellites/25544/tles")).json(); out.push({ ...SATS[0], l1: j.line1, l2: j.line2, satrec: satlib.twoline2satrec(j.line1, j.line2) }); } catch (e) { } }
  return out.sort((a, b) => SATS.findIndex(x => x.id === a.id) - SATS.findIndex(x => x.id === b.id));
}
```

<!--{"pinCode":false,"dname":"wc-satmath","codeMode":"js","hide":true}-->
```js
satmath = {
  const DEG = 180 / Math.PI, rad = Math.PI / 180;
  const geo = (satrec, t) => { const date = new Date(t), pv = satlib.propagate(satrec, date); if (!pv || !pv.position) return null; const gmst = satlib.gstime(date), g = satlib.eciToGeodetic(pv.position, gmst), v = pv.velocity; return { lat: g.latitude * DEG, lon: ((g.longitude * DEG + 540) % 360) - 180, altKm: g.height, speedKms: v ? Math.hypot(v.x, v.y, v.z) : null }; };
  const look = (satrec, lat, lon, t) => { const date = new Date(t), pv = satlib.propagate(satrec, date); if (!pv || !pv.position) return null; const gmst = satlib.gstime(date), obs = { longitude: rad * lon, latitude: rad * lat, height: 0.05 }; const la = satlib.ecfToLookAngles(obs, satlib.eciToEcf(pv.position, gmst)); const d = astro.jd(t), s = astro.sunCoords(d), su = [Math.cos(s.dec) * Math.cos(s.ra), Math.cos(s.dec) * Math.sin(s.ra), Math.sin(s.dec)], p = pv.position; const dot = p.x * su[0] + p.y * su[1] + p.z * su[2], perp = Math.sqrt(Math.max(0, p.x * p.x + p.y * p.y + p.z * p.z - dot * dot)); return { el: la.elevation, az: la.azimuth, sunlit: !(dot < 0 && perp < 6371), sunAlt: astro.altAz(s.ra, s.dec, d, lat, lon).alt }; };
  const passes = (satrec, lat, lon, from, to, step = 30e3) => {
    const out = []; let cur = null;
    const finish = c => { if (c.max.el < rad * 10) return; const vis = c.pts.filter(([, p]) => p.sunlit && p.sunAlt < -6 * rad); c.visible = vis.length > 0; if (c.visible) { c.visStart = vis[0][0]; c.visEnd = vis[vis.length - 1][0]; c.visMax = vis.reduce((a, x) => x[1].el > a[1].el ? x : a, vis[0]); if (c.visMax[1].el < rad * 10 || c.visEnd - c.visStart < 60e3) c.visible = false; } c.pts = null; out.push(c); };
    for (let t = from; t <= to; t += step) { const p = look(satrec, lat, lon, t); if (!p) continue; if (p.el > 0) { if (!cur) cur = { start: t, startAz: p.az, max: p, maxT: t, pts: [] }; if (p.el > cur.max.el) { cur.max = p; cur.maxT = t; } cur.pts.push([t, p]); } else if (cur) { cur.end = t; cur.endAz = p.az; finish(cur); cur = null; } }
    return out;
  };
  return { geo, look, passes, DEG };
}
```

<!--{"pinCode":false,"dname":"wc-sky","codeMode":"js","hide":true}-->
```js
sky = {
  const cal = astro.calendar(loc.lat, loc.lon, wx.tz, 10);
  const from = Date.now(), to = from + 10 * 864e5, passes = [];
  sats.filter(s => s.pass).forEach(s => satmath.passes(s.satrec, loc.lat, loc.lon, from, to).forEach(p => passes.push({ ...p, sat: s })));
  passes.sort((a, b) => a.start - b.start);
  return { cal, passes, visible: passes.filter(p => p.visible) };
}
```

<!--{"pinCode":false,"dname":"wc-tonight","codeMode":"js","hide":false}-->
```js
{
  const t = sky.cal[0], tz = wx.tz, np = sky.visible[0];
  const tile = (k, v, s) => `<div class="wc-tile"><div class="k">${k}</div><div class="v" style="font-size:17px">${v}</div>${s ? `<div class="s">${s}</div>` : ""}</div>`;
  const pl = list => list.length ? list.map(p => `${p.name} (${p.dir}, ${Math.round(p.alt)}° up)`).join(" · ") : "none above the horizon";
  return html`<div class="wc"><div class="wc-card"><div class="wc-h">Tonight’s sky</div>
    <div class="wc-tiles">
      ${tile("Moon", `${t.phase[2]} ${Math.round(t.ill.fraction * 100)}%`, t.phase[1])}
      ${tile("Sunset", t.sun ? astro.fmtTime(t.sun.sunset, tz) : "–", t.sun ? `sunrise ${astro.fmtTime(t.sun.sunrise, tz)}` : "")}
      ${tile("Moonrise", t.moon.rise ? astro.fmtTime(t.moon.rise, tz) : "–", t.moon.set ? `sets ${astro.fmtTime(t.moon.set, tz)}` : "")}
      ${tile("Next visible pass", np ? `${np.sat.emoji} ${np.sat.name} ${astro.fmtDT(np.visStart, tz)}` : "none in 10 days", np ? `${astro.compass8(np.startAz)} → ${astro.compass8(np.endAz)}, up to ${Math.round(np.visMax[1].el * satmath.DEG)}°` : "ISS, Tiangong, Hubble")}
    </div>
    <div class="wc-words" style="margin-top:8px">
      <div><b>Evening planets</b>${pl(t.eveningPlanets)}</div>
      <div><b>Morning planets</b>${pl(t.morningPlanets)}</div>
      <div><b>Events today</b>${t.events.length ? t.events.map(e => `${e.emoji} ${e.name} <span class="wc-muted">${e.note}</span>`).join("<br>") : "nothing notable"}</div>
    </div></div></div>`;
}
```

<!--{"pinCode":false,"dname":"wc-build-header","codeMode":"js","hide":false}-->
```js
html`<div class="wc"><div class="wc-eyebrow" style="margin:14px 2px 6px">Canvas · build the graph</div>
<div class="wc-muted">Location → 13 Hour nodes chained by NEXT · Day nodes for the outlook · Alert nodes · Satellite, Pass, Planet and SkyEvent nodes. Re-running merges, so it is safe to click again after changing the location.</div></div>`
```

<!--{"pinCode":false,"dname":"wc-build-weather","codeMode":"js","hide":false}-->
```js
{
  return Button("1 · Build weather graph", async () => {
    const L = { key: loc.label, name: loc.label, lat: loc.lat, lon: loc.lon, office: wx.office, grid: wx.grid, tz: wx.tz };
    await gxr.mergeNodes({ category: "Location", keys: ["key"], data: [L] });
    const hours = wx.rows.map(r => ({ key: `${loc.label}#h${r.hourIndex}`, location: loc.label, ...r }));
    await gxr.mergeNodes({ category: "Hour", keys: ["key"], data: hours });
    await gxr.mergeRelationships({ source: { category: "Location", keys: ["key"] }, edge: { relationship: "NOW", keys: ["k"] }, target: { category: "Hour", keys: ["key"] }, data: [{ source: { key: loc.label }, edge: { k: `${loc.label}-now` }, target: { key: hours[0].key } }] });
    await gxr.mergeRelationships({ source: { category: "Hour", keys: ["key"] }, edge: { relationship: "NEXT", keys: ["k"] }, target: { category: "Hour", keys: ["key"] }, data: hours.slice(1).map((h, i) => ({ source: { key: hours[i].key }, edge: { k: `${hours[i].key}>${h.key}` }, target: { key: h.key } })) });
    const days = wx.dailyRows.map(d => ({ key: `${loc.label}#d${d.date}`, location: loc.label, label: new Intl.DateTimeFormat("en-US", { weekday: "short", month: "short", day: "numeric", timeZone: "UTC" }).format(new Date(d.date + "T12:00:00Z")), ...d }));
    await gxr.mergeNodes({ category: "Day", keys: ["key"], data: days });
    await gxr.mergeRelationships({ source: { category: "Location", keys: ["key"] }, edge: { relationship: "OUTLOOK", keys: ["k"] }, target: { category: "Day", keys: ["key"] }, data: [{ source: { key: loc.label }, edge: { k: `${loc.label}-outlook` }, target: { key: days[0].key } }] });
    await gxr.mergeRelationships({ source: { category: "Day", keys: ["key"] }, edge: { relationship: "NEXT", keys: ["k"] }, target: { category: "Day", keys: ["key"] }, data: days.slice(1).map((d, i) => ({ source: { key: days[i].key }, edge: { k: `${days[i].key}>${d.key}` }, target: { key: d.key } })) });
    if (wx.alerts.length) {
      await gxr.mergeNodes({ category: "Alert", keys: ["id"], data: wx.alerts.map(a => ({ ...a, name: a.event })) });
      await gxr.mergeRelationships({ source: { category: "Alert", keys: ["id"] }, edge: { relationship: "AFFECTS", keys: ["k"] }, target: { category: "Location", keys: ["key"] }, data: wx.alerts.map(a => ({ source: { id: a.id }, edge: { k: `${a.id}>${loc.label}` }, target: { key: loc.label } })) });
    }
    gxr.setCategoryColor("Location", "#f5b83d"); gxr.setCategoryColor("Hour", "#4d9cf0"); gxr.setCategoryColor("Day", "#1d5fa8"); gxr.setCategoryColor("Alert", "#ef6f6f");
    gxr.setCategoryIconByName("Location", "map-marker"); gxr.setCategoryIconByName("Alert", "warning");
    await gxr.captionNodesByProperties({ category: "Hour", properties: ["label", "tempF"] });
    await gxr.captionNodesByProperties({ category: "Day", properties: ["label", "hiF"] });
    await gxr.captionNodesByProperties({ category: "Alert", properties: ["event"] });
    await gxr.captionNodesByProperties({ category: "Location", properties: ["name"] });
    gxr.forceLayout(); await gxr.sleep(1500); await gxr.flyToCenter();
    gxr.toast().success(`Weather graph: ${hours.length} hours, ${days.length} days, ${wx.alerts.length} alerts for ${loc.label}`);
  });
}
```

<!--{"pinCode":false,"dname":"wc-build-sky","codeMode":"js","hide":false}-->
```js
{
  return Button("2 · Build sky graph", async () => {
    const now = Date.now(), tz = wx.tz;
    const satRows = sats.map(s => { const g = satmath.geo(s.satrec, now) || {}; return { id: s.id, name: s.name, emoji: s.emoji, about: s.about, lat: g.lat, lon: g.lon, altKm: g.altKm == null ? null : Math.round(g.altKm), speedKms: g.speedKms == null ? null : Math.round(g.speedKms * 100) / 100 }; });
    await gxr.mergeNodes({ category: "Satellite", keys: ["id"], data: satRows });
    const passRows = sky.visible.slice(0, 40).map(p => ({ key: `${p.sat.id}@${p.visStart}`, satellite: p.sat.name, satId: p.sat.id, location: loc.label, label: `${p.sat.name} ${astro.fmtDT(p.visStart, tz)}`, start: new Date(p.visStart).toISOString(), startLocal: astro.fmtDT(p.visStart, tz), endLocal: astro.fmtTime(p.visEnd, tz), appears: astro.compass8(p.startAz), disappears: astro.compass8(p.endAz), maxElevation: Math.round(p.visMax[1].el * satmath.DEG), minutes: Math.round((p.visEnd - p.visStart) / 60e3) }));
    if (passRows.length) {
      await gxr.mergeNodes({ category: "Pass", keys: ["key"], data: passRows });
      await gxr.mergeRelationships({ source: { category: "Satellite", keys: ["id"] }, edge: { relationship: "PASSES", keys: ["k"] }, target: { category: "Pass", keys: ["key"] }, data: passRows.map(p => ({ source: { id: p.satId }, edge: { k: `s>${p.key}` }, target: { key: p.key } })) });
      await gxr.mergeRelationships({ source: { category: "Pass", keys: ["key"] }, edge: { relationship: "OVER", keys: ["k"] }, target: { category: "Location", keys: ["key"] }, data: passRows.map(p => ({ source: { key: p.key }, edge: { k: `${p.key}>loc` }, target: { key: loc.label } })) });
    }
    const t0 = sky.cal[0];
    const planets = [...t0.eveningPlanets.map(p => ({ ...p, when: "evening" })), ...t0.morningPlanets.map(p => ({ ...p, when: "morning" }))].map(p => ({ key: `${p.name}-${p.when}`, name: p.name, when: p.when, direction: p.dir, altitude: Math.round(p.alt), location: loc.label }));
    if (planets.length) {
      await gxr.mergeNodes({ category: "Planet", keys: ["key"], data: planets });
      await gxr.mergeRelationships({ source: { category: "Planet", keys: ["key"] }, edge: { relationship: "VISIBLE_FROM", keys: ["k"] }, target: { category: "Location", keys: ["key"] }, data: planets.map(p => ({ source: { key: p.key }, edge: { k: `${p.key}>loc` }, target: { key: loc.label } })) });
    }
    const events = sky.cal.flatMap(d => d.events.map(e => ({ key: `${d.date}-${e.name}`, date: d.date, name: `${e.emoji} ${e.name}`, note: e.note || "", kind: e.kind, location: loc.label })));
    if (events.length) {
      await gxr.mergeNodes({ category: "SkyEvent", keys: ["key"], data: events });
      await gxr.mergeRelationships({ source: { category: "SkyEvent", keys: ["key"] }, edge: { relationship: "SEEN_FROM", keys: ["k"] }, target: { category: "Location", keys: ["key"] }, data: events.map(e => ({ source: { key: e.key }, edge: { k: `${e.key}>loc` }, target: { key: loc.label } })) });
    }
    gxr.setCategoryColor("Satellite", "#ffd27a"); gxr.setCategoryColor("Pass", "#22b384"); gxr.setCategoryColor("Planet", "#a293f0"); gxr.setCategoryColor("SkyEvent", "#dd6a97");
    gxr.setCategoryIconByName("Satellite", "satellite"); gxr.setCategoryIconByName("Planet", "globe");
    await gxr.captionNodesByProperties({ category: "Satellite", properties: ["name"] });
    await gxr.captionNodesByProperties({ category: "Pass", properties: ["label", "maxElevation"] });
    await gxr.captionNodesByProperties({ category: "Planet", properties: ["name", "when"] });
    await gxr.captionNodesByProperties({ category: "SkyEvent", properties: ["name"] });
    gxr.forceLayout(); await gxr.sleep(1500); await gxr.flyToCenter();
    gxr.toast().success(`Sky graph: ${satRows.length} satellites, ${passRows.length} visible passes, ${planets.length} planets, ${events.length} events`);
  });
}
```

<!--{"pinCode":false,"dname":"wc-globe-header","codeMode":"js","hide":false}-->
```js
html`<div class="wc"><div class="wc-eyebrow" style="margin:14px 2px 6px">Canvas · the Earth</div>
<div class="wc-muted">Puts a day/night globe on the canvas and pins every node that carries a latitude and longitude onto it: the location and the satellites. Hours, days, passes and events fan out from their parent. Then switch on live tracking.</div></div>`
```

<!--{"pinCode":false,"dname":"wc-globe-buttons","codeMode":"js","hide":false}-->
```js
{
  const show = await Button("3 · Show globe", async () => {
    if (!window.__wcGlobe) window.__wcGlobe = await gxr.createGlobe({ radius: 1, distance: 0.08, showLabels: false, showBorder: true, borderOpacity: 0.35, dayNightTransition: 0.5, neighborOffset: 0.12, neighborDistance: 0.04 });
    else window.__wcGlobe.show();
    window.__wcGlobe.projectNodes();
    await gxr.sleep(300);
    await gxr.flyToCenter();
    gxr.toast().success("Globe on. Nodes with lat/lon are pinned to the surface.");
  });
  const hide = await Button("Hide globe", async () => { if (window.__wcGlobe) window.__wcGlobe.hide(); gxr.nodes().pinned(false); gxr.forceLayout(); });
  const day = Inputs.range([0, 1], { label: "Day ↔ night", value: 0.5, step: 0.05 });
  day.addEventListener("input", () => { if (window.__wcGlobe) window.__wcGlobe.setDayNightTransition(+day.value); });
  const wrap = html`<div class="wc"><div class="wc-row"></div></div>`;
  wrap.querySelector(".wc-row").append(show, hide, day);
  return wrap;
}
```

<!--{"pinCode":false,"dname":"wc-live-toggle","codeMode":"js","hide":false}-->
```js
viewof live = Inputs.toggle({label: "4 · Live satellite tracking", value: false})
```

<!--{"pinCode":false,"dname":"wc-live","codeMode":"js","hide":false}-->
```js
{
  const box = html`<div class="wc"><div class="wc-card"><div class="wc-h">Satellites over Earth</div><div class="wc-muted">Switch on live tracking to move the Satellite nodes every 3 seconds.</div></div></div>`;
  if (!live) return box;
  const card = box.querySelector(".wc-card");
  const tick = async () => {
    const now = Date.now();
    const rows = sats.map(s => { const g = satmath.geo(s.satrec, now) || {}; const lk = satmath.look(s.satrec, loc.lat, loc.lon, now); return { id: s.id, name: s.name, emoji: s.emoji, lat: g.lat, lon: g.lon, altKm: g.altKm == null ? null : Math.round(g.altKm), speedKms: g.speedKms == null ? null : Math.round(g.speedKms * 100) / 100, up: lk && lk.el > 0, elev: lk ? Math.round(lk.el * satmath.DEG) : null, dir: lk ? astro.compass8(lk.az) : "" }; });
    try {
      await gxr.mergeNodes({ category: "Satellite", keys: ["id"], data: rows.map(r => { const s = sats.find(x => x.id === r.id); return { id: r.id, name: r.name, emoji: r.emoji, about: s ? s.about : "", lat: r.lat, lon: r.lon, altKm: r.altKm, speedKms: r.speedKms, aboveHorizon: !!r.up, elevation: r.elev, direction: r.dir }; }) });
      if (window.__wcGlobe) window.__wcGlobe.projectNodes();
    } catch (e) { }
    card.innerHTML = `<div class="wc-h">Satellites over Earth · live</div><table class="wc-table"><thead><tr><th>Satellite</th><th>Over</th><th>Altitude</th><th>Speed</th><th>From ${loc.label}</th></tr></thead><tbody>${rows.map(r => `<tr><td>${r.emoji} ${r.name}</td><td>${r.lat == null ? "–" : `${Math.abs(r.lat).toFixed(1)}°${r.lat >= 0 ? "N" : "S"} ${Math.abs(r.lon).toFixed(1)}°${r.lon >= 0 ? "E" : "W"}`}</td><td>${r.altKm ?? "–"} km</td><td>${r.speedKms ?? "–"} km/s</td><td class="${r.up ? "on" : ""}">${r.up ? `Above horizon · ${r.elev}° ${r.dir}` : "Below horizon"}</td></tr>`).join("")}</tbody></table><div class="wc-muted" style="margin-top:6px">Updated ${new Date().toLocaleTimeString()} · orbital elements from CelesTrak</div>`;
  };
  tick();
  const id = setInterval(tick, 3000);
  invalidation.then(() => clearInterval(id));
  return box;
}
```

<!--{"pinCode":false,"dname":"wc-layout-buttons","codeMode":"js","hide":false}-->
```js
{
  const timeline = await Button("Timeline layout", async () => {
    const g = window.__wcGlobe; if (g) g.hide(); gxr.nodes().pinned(false);
    const place = (n, p) => gxr.nodes().filter(x => x.id === n.id).position(p);
    const hours = gxr.nodes({ category: "Hour" }), temps = hours.map(n => +n.properties.tempF).filter(v => !isNaN(v)), tm = temps.length ? temps.reduce((a, b) => a + b, 0) / temps.length : 0;
    hours.forEach(n => place(n, { x: (+n.properties.hourIndex - 6) * 0.45, y: 1.2 + ((+n.properties.tempF || tm) - tm) * 0.06, z: 0 }));
    const days = gxr.nodes({ category: "Day" }), his = days.map(n => +n.properties.hiF).filter(v => !isNaN(v)), hm = his.length ? his.reduce((a, b) => a + b, 0) / his.length : 0;
    days.forEach(n => place(n, { x: (+n.properties.dayIndex - 4.5) * 0.6, y: -1.4 + ((+n.properties.hiF || hm) - hm) * 0.06, z: 0 }));
    gxr.nodes({ category: "Location" }).forEach(n => place(n, { x: -3.6, y: 0, z: 0 }));
    ["Alert", "Planet", "SkyEvent", "Satellite", "Pass"].forEach((c, ci) => gxr.nodes({ category: c }).forEach((n, i) => place(n, { x: 3.4 + ci * 0.5, y: 2 - i * 0.28, z: 0 })));
    gxr.nodes().pinned(true); await gxr.sleep(600); await gxr.flyToCenter();
  });
  const force = await Button("Force layout", async () => { if (window.__wcGlobe) window.__wcGlobe.hide(); gxr.nodes().pinned(false); gxr.forceLayout(); await gxr.sleep(1200); await gxr.flyToCenter(); });
  const fit = await Button("Fit to view", async () => { await gxr.flyToCenter(); });
  const clear = await Button("Clear canvas", async () => { if (window.__wcGlobe) { window.__wcGlobe.hide(); } gxr.clear(); gxr.toast().success("Canvas cleared"); });
  const wrap = html`<div class="wc"><div class="wc-eyebrow" style="margin:14px 2px 6px">Canvas · layouts</div><div class="wc-row"></div></div>`;
  wrap.querySelector(".wc-row").append(timeline, force, fit, clear);
  return wrap;
}
```

<!--{"pinCode":false,"dname":"wc-selected","codeMode":"js","hide":false}-->
```js
{
  const ids = selectedNodes.ids();
  if (!ids.length) return html`<div class="wc"><div class="wc-card"><div class="wc-h">Selected on canvas</div><div class="wc-muted">Click a node on the canvas to read it here.</div></div></div>`;
  const cards = selectedNodes.slice(0, 4).map(n => {
    const p = n.properties, cat = n.category || (n.tags && n.tags[0]) || "";
    const skip = new Set(["key", "location", "icon", "id", "satId", "description"]);
    const rows = Object.entries(p).filter(([k, v]) => !skip.has(k) && v != null && v !== "").slice(0, 16).map(([k, v]) => `<tr><td style="color:#7f95bf">${k}</td><td>${typeof v === "number" ? v : String(v).slice(0, 140)}</td></tr>`).join("");
    return `<div class="wc-card"><div class="wc-eyebrow">${cat}</div><div class="wc-h">${p.name || p.label || p.event || p.key || n.id}</div>${p.icon ? `<img src="${p.icon}" style="width:56px;height:56px;border-radius:8px;float:right">` : ""}<table class="wc-table">${rows}</table>${p.description ? `<details style="margin-top:6px"><summary style="color:#f5b83d;cursor:pointer">Full text</summary><pre style="white-space:pre-wrap;font:inherit;color:#b9c9e6">${p.description}</pre></details>` : ""}</div>`;
  });
  return html`<div class="wc">${cards.join("")}</div>`;
}
```

<!--{"pinCode":false,"dname":"wc-passes-table","codeMode":"js","hide":false}-->
```js
{
  const tz = wx.tz, list = sky.visible.slice(0, 25);
  const rows = list.map(p => `<tr><td>${p.sat.emoji} ${p.sat.name}</td><td>${astro.fmtDT(p.visStart, tz)}</td><td>${astro.compass8(p.startAz)}</td><td>${astro.fmtTime(p.visMax[0], tz)} ${astro.compass8(p.visMax[1].az)}</td><td>${astro.fmtTime(p.visEnd, tz)} ${astro.compass8(p.endAz)}</td><td class="on">${Math.round(p.visMax[1].el * satmath.DEG)}°</td><td>${Math.round((p.visEnd - p.visStart) / 60e3)} min</td></tr>`).join("");
  return html`<div class="wc"><div class="wc-card"><div class="wc-h">Naked-eye passes over ${loc.label}, next 10 days</div>
    ${list.length ? `<table class="wc-table"><thead><tr><th>Satellite</th><th>Appears</th><th>From</th><th>Highest</th><th>Disappears</th><th>Max</th><th>Length</th></tr></thead><tbody>${rows}</tbody></table>` : `<div class="wc-muted">No naked-eye passes above 10° in the window.</div>`}
    <div class="wc-muted" style="margin-top:6px">Dark sky at the observer, satellite still sunlit. ${sky.passes.length} passes above 10° in total, ${sky.visible.length} visible.</div></div></div>`;
}
```

<!--{"pinCode":false,"dname":"wc-calendar","codeMode":"js","hide":false}-->
```js
{
  const tz = wx.tz, dn = (d, i) => i === 0 ? "Today" : i === 1 ? "Tomorrow" : new Intl.DateTimeFormat("en-US", { weekday: "long", timeZone: "UTC" }).format(new Date(d + "T12:00:00Z"));
  const rows = sky.cal.map(d => `<tr><td><b style="color:#eaf2ff">${dn(d.date, d.i)}</b><div class="wc-muted">${d.date.slice(5)}</div></td><td>${d.sun ? `${astro.fmtTime(d.sun.sunrise, tz)} / ${astro.fmtTime(d.sun.sunset, tz)}` : "–"}</td><td>${d.moon.rise ? astro.fmtTime(d.moon.rise, tz) : "–"} / ${d.moon.set ? astro.fmtTime(d.moon.set, tz) : "–"}</td><td>${d.phase[2]} ${Math.round(d.ill.fraction * 100)}%</td><td>${d.eveningPlanets.map(p => `${p.name} ${p.dir}`).join(", ") || "<span class='wc-muted'>none</span>"}</td><td>${d.morningPlanets.map(p => `${p.name} ${p.dir}`).join(", ") || "<span class='wc-muted'>none</span>"}</td><td>${d.events.map(e => `${e.emoji} ${e.name} <span class="wc-muted">${e.note}</span>`).join("<br>") || "–"}</td></tr>`).join("");
  return html`<div class="wc"><div class="wc-card"><div class="wc-h">Sky calendar, next 10 days</div><div style="overflow-x:auto"><table class="wc-table"><thead><tr><th>Day</th><th>Sunrise / sunset</th><th>Moonrise / set</th><th>Moon</th><th>Evening planets</th><th>Morning planets</th><th>Events</th></tr></thead><tbody>${rows}</tbody></table></div>
  <div class="wc-muted" style="margin-top:6px">Computed in the notebook from J2000 low-precision formulas; planets listed when at least 8° up about 75 minutes after sunset or before sunrise.</div></div></div>`;
}
```

<!--{"pinCode":false,"dname":"wc-nesdis-select","codeMode":"js","hide":false}-->
```js
viewof nesdisProduct = Inputs.select(new Map([["GeoColor", "GEOCOLOR"], ["Clean infrared", "13"], ["Visible", "02"], ["Water vapor", "08"], ["Shortwave IR", "07"], ["Air mass", "AirMass"], ["Sandwich", "Sandwich"], ["Fire temperature", "FireTemperature"], ["Dust", "Dust"]]), {label: "NESDIS product", value: "GEOCOLOR"})
```

<!--{"pinCode":false,"dname":"wc-nesdis","codeMode":"js","hide":false}-->
```js
{
  const lat = loc.lat, lon = loc.lon;
  const sec = lat < 23 && lon < -154 ? { sat: "GOES18", sec: "hi", name: "Hawaii" } : lat > 50 && lon < -130 ? { sat: "GOES18", sec: "cak", name: "Alaska" } : lat < 19.5 && lon > -68.5 && lon < -64 ? { sat: "GOES19", sec: "pr", name: "Puerto Rico" } : lon < -114 ? (lat >= 42 ? { sat: "GOES18", sec: "pnw", name: "Pacific Northwest" } : { sat: "GOES18", sec: "psw", name: "Pacific Southwest" }) : lon < -104 ? (lat >= 41 ? { sat: "GOES19", sec: "nr", name: "Northern Rockies" } : { sat: "GOES19", sec: "sr", name: "Southern Rockies" }) : lon < -93 ? (lat >= 40 ? { sat: "GOES19", sec: "umv", name: "Upper Mississippi Valley" } : { sat: "GOES19", sec: "sp", name: "Southern Plains" }) : lon < -83 ? (lat >= 38 ? { sat: "GOES19", sec: "cgl", name: "Central Great Lakes" } : { sat: "GOES19", sec: "smv", name: "Southern Mississippi Valley" }) : (lat >= 37 ? { sat: "GOES19", sec: "ne", name: "Northeast" } : { sat: "GOES19", sec: "se", name: "Southeast" });
  const bust = Math.floor(Date.now() / 3e5);
  const still = `https://cdn.star.nesdis.noaa.gov/${sec.sat}/ABI/SECTOR/${sec.sec}/${nesdisProduct}/1200x1200.jpg?t=${bust}`;
  const loop = `https://cdn.star.nesdis.noaa.gov/${sec.sat}/ABI/SECTOR/${sec.sec}/${nesdisProduct}/${sec.sat}-${sec.sec.toUpperCase()}-${nesdisProduct}-600x600.gif?t=${bust}`;
  return html`<div class="wc"><div class="wc-card"><div class="wc-h">NESDIS · ${sec.sat.replace("GOES", "GOES-")} ${sec.name} sector</div>
    <a href="${still}" target="_blank" rel="noopener"><img class="wc-img" src="${still}" alt="${sec.name} ${nesdisProduct}"></a>
    <div class="wc-muted" style="margin-top:6px">Live geostationary imagery from NOAA NESDIS STAR, new frame every 5–10 minutes. <a href="${loop}" target="_blank" style="color:#f5b83d">Open the animated loop</a> · <a href="https://www.star.nesdis.noaa.gov/GOES/sector.php?sat=G${sec.sat.slice(4)}&sector=${sec.sec}" target="_blank" style="color:#f5b83d">NESDIS page</a></div></div></div>`;
}
```

<!--{"pinCode":false,"dname":"wc-apod","codeMode":"js","hide":false}-->
```js
{
  let d = null;
  try { const r = await fetch("https://weather-now.exe.xyz/apod.json", { cache: "no-cache" }); if (r.ok) d = await r.json(); } catch (e) { }
  if (!d || !d.url) { try { const r = await fetch("https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&thumbs=true"); if (r.ok) d = await r.json(); } catch (e) { } }
  if (!d || !d.url) return html`<div class="wc"><div class="wc-card"><div class="wc-h">Astronomy picture of the day</div><div class="wc-muted">Not reachable right now. <a href="https://apod.nasa.gov/apod/astropix.html" target="_blank" style="color:#f5b83d">Open apod.nasa.gov</a></div></div></div>`;
  const img = d.media_type === "video" ? (d.thumbnail_url ? `<a href="${d.url}" target="_blank"><img class="wc-img" src="${d.thumbnail_url}"></a>` : `<a href="${d.url}" target="_blank" style="color:#f5b83d">Watch today's video</a>`) : `<a href="${d.hdurl || d.url}" target="_blank" rel="noopener"><img class="wc-img" src="${d.url}" alt="${d.title}"></a>`;
  return html`<div class="wc"><div class="wc-card"><div class="wc-h">Astronomy picture of the day</div><div style="margin-bottom:8px"><b style="color:#eaf2ff">${d.title}</b> <span class="wc-muted">· ${d.date}${d.copyright ? " · © " + d.copyright.trim() : ""}</span></div>${img}
    <details style="margin-top:8px"><summary style="color:#f5b83d;cursor:pointer">Explanation</summary><p style="color:#b9c9e6">${d.explanation || ""}</p></details>
    <div class="wc-muted" style="margin-top:6px">NASA APOD · <a href="https://apod.nasa.gov/apod/ap${d.date.slice(2).replace(/-/g, "")}.html" target="_blank" style="color:#f5b83d">apod.nasa.gov</a></div></div></div>`;
}
```

<!--{"pinCode":false,"dname":"wc-how","codeMode":"js","hide":false}-->
```js
html`<div class="wc"><div class="wc-card" style="margin-top:18px">
  <div class="wc-eyebrow">How this was built</div>
  <div class="wc-h">Live external data as a graph</div>
  <p style="color:#b9c9e6">Every cell in this grovebook fetches public data directly from the browser and the GraphXR API turns it into nodes and edges:</p>
  <ul style="color:#b9c9e6;margin:0 0 8px 18px">
    <li><b>National Weather Service</b> (api.weather.gov): the forecast grid is sampled at the top of each of the next 13 hours; the 7-day forecast, active alerts and the nearest station observation come from the same API. Days 8–10 come from Open-Meteo.</li>
    <li><b>CelesTrak</b> two-line elements are propagated in the notebook with satellite.js (SGP4). Naked-eye passes require a dark observer and a sunlit satellite; Satellite nodes carry live latitude and longitude.</li>
    <li><b>Sun, moon and planets</b> are computed from J2000 low-precision formulas (suncalc-style sun and moon, JPL approximate Keplerian elements for the planets).</li>
    <li><b>NOAA NESDIS</b> supplies the GOES imagery; <b>NASA APOD</b> the picture of the day.</li>
    <li><b>GraphXR</b>: <code>gxr.mergeNodes</code> / <code>mergeRelationships</code> upsert the graph, <code>createGlobe</code> pins geo-tagged nodes to a day/night Earth, <code>parametric</code> lays the hours out as a timeline, and <code>selectedNodes</code> drives the detail card.</li>
  </ul>
  <div class="wc-muted">Web version: <a href="https://weather-now.exe.xyz" target="_blank" style="color:#f5b83d">weather-now.exe.xyz</a> · source: <a href="https://github.com/rockyjonez/weather-now" target="_blank" style="color:#f5b83d">github.com/rockyjonez/weather-now</a>. Styling is a fan tribute to a certain blue box; not affiliated with the BBC.</div>
</div></div>`
```
