# Weather Now

A single-page weather and sky console. One HTML file, no build step, no API keys,
no accounts. It covers any address in the United States, Canada, Mexico or Brazil.

**Live:** https://weather-now.exe.xyz
**Where the data comes from:** https://weather-now.exe.xyz/docs/data-sources.html

Weather forecasts come from the National Weather Service inside the United
States and from Open-Meteo everywhere else. On top of that it carries health
indices, a live satellite tracker, rocket launch countdowns, NASA's picture of
the day and the Hebrew calendar.

---

## What it shows

Twelve tabs across the top. The Overview holds the sky material in its own set
of sub-tabs, so the space section sits inside one page rather than scattered.

| Tab | What it holds |
|---|---|
| **Overview** | Hourly strip, temperature and rain charts, health scores, tonight's sky, and the sky sub-tabs below |
| **Map** | Fourteen switchable layers with a time slider: radar (NOAA and RainViewer with nowcast), lightning, four GOES satellite channels, NOAA air-quality forecasts, snow depth, flash flood guidance, worldwide fire detections, alert polygons |
| **10-day** | Day cards with NWS text for seven days and Open-Meteo for days 8 to 10, plus charts |
| **Temperature / Rain / Clouds & sky / Wind / Storms & lightning / Snow & ice / Fire weather** | One subject each, charted hour by hour, with the alerts that apply |
| **Alerts** | Every active warning covering the point, most severe first |
| **Data table** | Every value, one row per hour, with CSV download |

### Inside the Overview

| Block | What it holds |
|---|---|
| **Health & comfort** | Migraine, arthritis, sinus, allergy, asthma, cold and flu, UV and outdoor discomfort, each scored 1 to 5 with the reasons behind it; pressure trend, air quality, humidity, UV; a 96-hour pressure chart and a 7-day outlook |
| **Launches** | Live countdown to the next rocket anywhere in the world, then the nine after it |
| **Satellites over Earth** | ISS, Tiangong, Hubble, NOAA-20, Terra, Landsat 9, GOES-19 and the whole Starlink constellation, with ground tracks and the day/night terminator |
| **Passes** | Naked-eye satellite passes over your location for ten days |
| **Satellite imagery** | GOES imagery in nine products, still or animated |
| **Moon & Sun / Planets / Events / Full calendar** | Rise and set times, moon phase, visible planets, meteor showers, eclipses, conjunctions |
| **Astronomy picture of the day** | NASA's daily photograph with its explanation |
| **Daf Yomi & more** | The day's page in each Sefaria learning cycle, Hebrew date, candle lighting and havdalah for your coordinates, and two weeks of holidays |

Every section heading is a button. Click it to fold that section away; what you
close is remembered in the browser.

---

## Location

The default is ZIP 07304, Jersey City. The search box takes:

- a US ZIP code
- a Brazilian CEP, eight digits with or without the dash, such as `01310-100`
- a Canadian or Mexican postcode
- a city name
- a `lat,lon` pair

A `?lat=&lon=&name=` query string overrides it, and the 📍 button uses the
browser's own location. Whatever you choose is remembered.

### Outside the United States

The National Weather Service only covers the US and its territories. Elsewhere
the page rebuilds the same views from Open-Meteo, and:

- **Brazil** gets real INMET storm warnings, matched to your point by polygon,
  with INMET's own risk text and safety instructions.
- **Canada and Mexico** link out to Environment Canada and the Servicio
  Meteorológico Nacional, because neither publishes warnings in a form open to us.
- **Fire detections** come from NASA satellites and work worldwide, so the fire
  section has real data where the American red-flag indices do not exist.
- **NOAA air-quality layers** are hidden outside North America rather than drawn
  blank.

A tab with no data for your location says so, rather than showing zeros.

---

## On a phone

The site installs as a web app. On Android Chrome open the live URL and choose
*Add to Home screen*; a 1×1 TARDIS icon opens the console full screen.

`widget.html` is a separate square tile that scales to any size: temperature,
condition, high and low, rain chance or alert count, and today's Daf Yomi.
Point an Android web-widget app at `https://weather-now.exe.xyz/widget.html`
for a live home-screen widget. It follows the location you last chose and also
accepts `?lat=&lon=&name=`.

---

## How it works

`index.html` is the whole application. Plain HTML, CSS and JavaScript, with
charts drawn as inline SVG. Two libraries load from a CDN only when needed:
Leaflet for maps and satellite.js for orbit propagation.

1. `GET /points/{lat},{lon}` resolves the forecast office, grid cell, time zone,
   hourly forecast URL, observation stations and radar station.
2. In parallel: the forecast grid, the hourly forecast, the station list, active
   alerts, and Open-Meteo for the longer range and the health indices.
3. The latest observation comes from the nearest station reporting a temperature.
4. Every grid layer is sampled at the top of each of the next 13 hours. Six-hour
   accumulation layers are spread evenly across their hours and labelled as such.
5. Sun, moon, planet and eclipse positions are calculated in the page, not
   fetched. Orbits are propagated locally from published elements.

Four feeds are cached hourly on the server because their providers rate-limit or
reject anonymous callers: NASA's picture of the day, the launch schedule, the
Starlink elements and the INMET warnings. Viewers read one shared copy.

---

## GraphXR grovebook

`grove/weather-console.md` is the same console as a Kineviz GraphXR grovebook,
also served at https://weather-now.exe.xyz/grove/weather-console.md. Open it in
Kineviz Desktop through the Grove panel's file explorer, or drop it into a
project's Grove folder.

It builds a graph from the same data: `Location` → `Hour` nodes chained by
`NEXT`, `Day` nodes for the outlook, `Alert` nodes with `AFFECTS` edges, then
`Satellite`, `Pass`, `Planet` and `SkyEvent` nodes. `gxr.createGlobe()` puts a
day/night Earth on the canvas and pins every node with coordinates to it;
satellites re-project every three seconds as they move.

---

## Styling

A Doctor Who fan tribute: TARDIS-blue console panels, amber instrument light, a
time-vortex backdrop, roundel tabs, a CSS-drawn police box in the header, and the
Audiowide and Exo 2 typefaces. The vortex theme is the default; the ◐ button
switches to daylight. No BBC assets are used and the page is not affiliated with
the BBC.

---

## Run it

Any static file server works:

```bash
python3 -m http.server 8765
```

Then open `http://localhost:8765/?lat=37.7749&lon=-122.4194`.

## Deploy

`deploy.sh` copies the site to an exe.dev VM, writes the nginx config, and
installs the four caching cron jobs:

```bash
./deploy.sh
```

---

## Data notes

- **No API keys anywhere.** Every provider is a free public service. The full
  list, with links, is at [docs/data-sources.html](docs/data-sources.html).
- **Health indices** are computed in the page from Open-Meteo hourly pressure,
  humidity, temperature, UV, wind, rain and storm energy, plus the Open-Meteo
  air-quality feed. The 1-to-5 scale mirrors Xweather's indices endpoint, which
  needs a paid key. US pollen is an estimate from season and weather, marked with
  an asterisk, because no free US pollen-count feed exists.
- **Satellite passes** count as naked-eye when the observer's sun is below -6°,
  the satellite is outside Earth's shadow, and the peak is at least 10° up.
- **Astronomy** uses low-precision J2000 formulas, accurate to a fraction of a
  degree. Meteor shower and eclipse dates are static tables.
- **Launch times slip.** A launch with no clock time has not been set to the
  minute yet, and the page says so rather than inventing one.
- **Fire detections are hot pixels**, which can be wildfire, agricultural burning
  or industry. They are not confirmed fires.
- **Units**: everything arrives metric and converts on display. Wind direction
  from the NWS is where the wind blows *from*; arrows point where it blows *to*.

### Things that broke, and why

Upstream services move. Both of these were found and fixed the same day:

- **September 2026** — NOAA retired every NDFD forecast workspace from nowCOAST,
  dropping it from 144 layers to 64. Ten map layers had been returning 404
  silently. Replaced with live sources, including NOAA's air-quality forecasts.
- **October 2026** — NASA retired `apod.nasa.gov` and its old picture-of-the-day
  API. Moved to `science.nasa.gov`, whose fields need HTML stripping.

INMET is a useful gotcha: it resets the connection for unfamiliar user agents,
so it looks unreachable until you send a browser one.

## Licence

MIT. See [LICENSE](LICENSE).
