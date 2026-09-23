# Weather Now

Single-page weather dashboard built on the US National Weather Service API
(`https://api.weather.gov`). It shows current conditions, the next 12 hours and
a 10-day outlook,
with switchable views for temperature, rain, clouds and sky, wind, storms and
lightning, snow and ice, fire weather, active alerts, and a raw data table.

Live: https://weather-now.exe.xyz

## What it shows

| View | Data |
|---|---|
| Overview | Hourly strip with NWS icons, temperature and rain charts, tonight's sky summary and the sky sub-tabs |
| Map | Leaflet map with NOAA nowCOAST layers: radar loop, lightning density, GOES infrared clouds, forecast temperature, feels-like, rain chance, rain amount, snow, cloud cover, wind speed, gusts, wind barbs, humidity, and NWS alert polygons; time slider and play button; click for the value at a point or to load that point's forecast |
| 10-day | Day cards with NWS text, icons, highs and lows for seven days and Open-Meteo model guidance for days 8 to 10; highs/lows, precipitation and wind charts across all ten days |
| Health & comfort | Xweather-style 1–5 indices for migraine, arthritis, sinus, allergy (pollen), asthma & air quality, cold & flu, UV and outdoor discomfort, all on the same higher-is-worse scale, with the reasons behind each score; current pressure trend, AQI, humidity, UV; a 96-hour barometric pressure chart; a 7-day outlook table |
| Overview (sky block) | Live map of the ISS, Tiangong, Hubble, NOAA-20, Terra, Landsat 9 and GOES-19 from CelesTrak orbital elements (satellite.js SGP4), with ground track, horizon footprint and day/night terminator; naked-eye pass predictions over the location for 10 days; tonight's sky and a 10-day calendar of sun/moon times, moon phase, visible planets, moon phases, equinoxes, meteor-shower peaks, eclipses and conjunctions |
| NESDIS imagery (sky sub-tab) | Live GOES-East/West imagery from NOAA NESDIS STAR: local sector, CONUS or full disk; GeoColor, clean IR, visible, water vapor, shortwave IR, air mass, sandwich, fire temperature, dust; still or animated loop |
| Astronomy picture of the day | NASA APOD at the bottom of every view, with explanation and full-resolution link |
| Daily learning & Hebrew calendar | Below the picture on every view: Hebrew date (after-sunset aware), parasha, next candle lighting and havdalah for the location, today's holiday, the Sefaria learning cycles Tiby follows (Daf Yomi first; 929, Daily Rambam, Daf a Week, Arukh HaShulchan Yomi and Yerushalmi Yomi are hidden) linked to the text, and a two-week list of holidays and Shabbat times |
| Temperature | Air, feels-like and dew point lines; heat index / wind chill; NWS HeatRisk; heat and cold alerts |
| Rain | Probability of precipitation, liquid amount per hour, precipitation type and coverage, flood alerts |
| Clouds & sky | Sky cover, relative humidity, visibility and ceiling where published, sunrise and sunset |
| Wind | Sustained and gust lines with per-hour direction arrows, Beaufort descriptions, 20-ft and transport wind |
| Storms & lightning | Probability of thunder, Lightning Activity Level, storm hours, gridded hazards, radar loop, storm alerts |
| Snow & ice | Snowfall and ice accretion per hour, snow level, wind chill, winter hazards and alerts |
| Fire weather | Derived status, minimum humidity, peak wind, red flag / grassland / Haines indices, smoke dispersion, fire alerts |
| Alerts | Every active alert containing the point, most severe first, plus gridded hazard flags |
| Data table | One row per hour with every value; CSV download |

## How it works

`index.html` is the whole application: no build step, plain HTML, CSS and
JavaScript with inline SVG charts. The Map view loads Leaflet 1.9.4 from cdnjs
on first use and draws NOAA nowCOAST WMS layers over OpenStreetMap tiles; time
steps come from each layer's WMS capabilities document.

1. `GET /points/{lat},{lon}` resolves the forecast office, grid cell, time zone,
   hourly forecast URL, observation stations and radar station.
2. In parallel: `GET /gridpoints/{wfo}/{x},{y}` (the raw forecast grid),
   `/forecast/hourly` (icons and short text), `/stations` and
   `/alerts/active?point=`.
3. The latest observation is fetched from the nearest station that reports a
   temperature.
4. Every grid layer is sampled at the top of each of the next 13 hours. Grid
   values carry ISO 8601 `start/duration` validity periods, so a 3-hour
   temperature value covers three hourly samples. Six-hour accumulation layers
   (precipitation, snow, ice) are spread evenly across their hours and labelled
   as such.
5. Sunrise and sunset are computed locally (NOAA solar position formulas) to
   shade night hours on the charts.

The default location is ZIP 07304 (Jersey City, NJ). A `?lat=&lon=&name=` query
string overrides it, and so does a location chosen with the search box (place
names are resolved with Nominatim; `lat,lon` pairs are used directly) or the
📍 button, which is remembered in `localStorage`.
The NWS only covers the United States and its territories. Outside the United
States (Canada, Mexico, Brazil and anywhere else) the page falls back to
Open-Meteo for current conditions, the hourly rows, the 10-day outlook and the
health indices; the Map view switches to RainViewer global radar (plus
Environment Canada GeoMet radar in Canada), nowCOAST lightning and global
satellite; official warnings are linked to Environment Canada, CONAGUA or INMET
rather than read, and NESDIS imagery offers CONUS or full disk where no sector
exists. The search box accepts places in the US, Canada, Mexico and Brazil.

Not every forecast office publishes every layer. Views say so explicitly when a
layer (for example Lightning Activity Level or the fire danger indices) is
absent for the selected point rather than showing zeros.

## GraphXR grovebook

`grove/weather-console.md` is the same console as a Kineviz GraphXR grovebook
(also served at https://weather-now.exe.xyz/grove/weather-console.md). Open it
in Kineviz Desktop by uploading the file through the Grove panel's file
explorer, or drop it into a project's Grove folder.

What it does, cell by cell:

1. **Location** input (ZIP, city or `lat,lon`; default 07304) → `loc`.
2. **`wx`** fetches the NWS forecast grid, hourly forecast, 7-day forecast,
   alerts, nearest observation and Open-Meteo days 8–10, and samples 13 hours.
3. **Charts**: current conditions, next 12 hours, 10-day highs and lows,
   tonight's sky, naked-eye passes, 10-day sky calendar, NESDIS imagery and
   the NASA picture of the day.
4. **Build weather graph**: `Location` → `Hour` nodes chained by `NEXT`,
   `Day` nodes for the outlook, `Alert` nodes with `AFFECTS` edges.
5. **Build sky graph**: `Satellite` nodes with live lat/lon, `Pass` nodes
   (`Satellite -PASSES-> Pass -OVER-> Location`), `Planet` and `SkyEvent`
   nodes.
6. **Show globe**: `gxr.createGlobe()` puts a day/night Earth on the canvas
   and pins every node with lat/lon to it; neighbours fan outward.
7. **Live satellite tracking**: every 3 s the Satellite nodes are re-merged
   with fresh SGP4 positions and re-projected on the globe.
8. **Layouts**: timeline (`gxr.parametric` with hour index × temperature),
   force, fit, clear. Selecting a node on the canvas shows its properties in
   the notebook.

Orbital propagation uses satellite.js loaded with Grove's `require`; every
other computation is the same code as `index.html`.

## On a phone

The site is an installable web app (`manifest.webmanifest`, `sw.js`, icons in
`icons/`). On Android Chrome open https://weather-now.exe.xyz, choose
*Add to Home screen* / *Install app*, and a 1×1 TARDIS icon opens the console
full-screen. `widget.html` is a live 1:1 tile (temperature, condition, high/low,
rain chance or NWS alert count, today's Daf Yomi) that scales to any square;
point an Android web-widget app (for example a KWGT web tile) at
https://weather-now.exe.xyz/widget.html for a true home-screen widget. It
reads the same saved location as the main page and accepts `?lat=&lon=&name=`.

## Styling

The look is a Doctor Who fan tribute: TARDIS-blue console panels, amber
instrument light, a time-vortex backdrop, roundel-shaped tabs, a CSS-drawn
police box in the header, and the Audiowide / Exo 2 typefaces from Google
Fonts. The vortex (dark) theme is the default; the ◐ button switches to a
daylight theme. No BBC assets are used and the page is not affiliated with
the BBC.

## Run locally

Any static file server works:

```bash
python3 -m http.server 8765
```

Then open `http://localhost:8765/?lat=37.7749&lon=-122.4194`.

## Deploy

`deploy.sh` copies `index.html` to the exe.dev VM, where nginx serves it on
the VM's proxy port. See the script for the one-time nginx setup.

## Data notes

- Daily learning comes from the Sefaria calendars API (Diaspora or Israel
  schedule by location); Hebrew date, parasha, candle lighting, havdalah and
  holidays come from Hebcal, computed for the location's coordinates and time
  zone with the default 18-minute candle-lighting offset.

- Health indices are computed in the page from Open-Meteo hourly data (two
  days back, seven ahead: sea-level pressure, humidity, temperature, UV, wind,
  precipitation, weather code, CAPE) and the Open-Meteo air-quality feed (US
  AQI, PM2.5, PM10, ozone, dust, CAMS pollen where available). The scale mirrors
  Xweather's indices endpoint, which needs a paid client id and secret; if you
  have one, the same block can be fed from it via a small server-side proxy.
  US pollen is an estimate from season and weather because no free count feed
  exists; it is marked with an asterisk and capped at High.

- APOD is read from `apod.json`, which `deploy.sh` keeps fresh on the VM with an
  hourly cron job using NASA's public DEMO_KEY (so viewers never hit the API
  rate limit); the page falls back to calling the API directly.
- GOES imagery comes straight from `cdn.star.nesdis.noaa.gov`; the local sector
  is picked from the location's latitude and longitude.

- Satellite positions come from CelesTrak two-line elements (cached six hours)
  propagated in the browser with satellite.js. A pass counts as naked-eye when
  the observer's sun is below -6° and the satellite is outside Earth's shadow,
  with a visible peak of at least 10°.
- Sun, moon and planet positions are computed in the page from low-precision
  J2000 formulas (suncalc-style sun/moon, JPL approximate Keplerian elements for
  the planets), accurate to a fraction of a degree. Meteor shower and eclipse
  dates are static tables.

- The NWS API publishes seven days of forecast. The 10-day view uses it for
  days 1 to 7 and Open-Meteo (`api.open-meteo.com`, no key) for days 8 to 10
  and for the numeric series in its charts. Each card names its source.

- Temperatures arrive in °C, wind in km/h, precipitation in mm, heights in m.
  The unit toggle converts on display; nothing is rounded before conversion.
- Wind direction from the NWS is the direction the wind blows *from*. Arrows on
  the charts point where the wind is blowing *to*.
- The fire weather status is a heuristic layered on top of NWS products: alerts
  and gridded `FW` hazards win, then the published indices, then a humidity and
  wind check (RH ≤ 15 % with wind ≥ 25 mph). Official red flag criteria vary by
  office.
