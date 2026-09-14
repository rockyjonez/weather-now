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
| Overview | Hourly strip with NWS icons, at-a-glance tiles, temperature and rain charts |
| Map | Leaflet map with NOAA nowCOAST layers: radar loop, lightning density, GOES infrared clouds, forecast temperature, feels-like, rain chance, rain amount, snow, cloud cover, wind speed, gusts, wind barbs, humidity, and NWS alert polygons; time slider and play button; click for the value at a point or to load that point's forecast |
| 10-day | Day cards with NWS text, icons, highs and lows for seven days and Open-Meteo model guidance for days 8 to 10; highs/lows, precipitation and wind charts across all ten days |
| Sky & satellites | Live map of the ISS, Tiangong, Hubble, NOAA-20, Terra, Landsat 9 and GOES-19 from CelesTrak orbital elements (satellite.js SGP4), with ground track, horizon footprint and day/night terminator; naked-eye pass predictions over the location for 10 days; tonight's sky and a 10-day calendar of sun/moon times, moon phase, visible planets, moon phases, equinoxes, meteor-shower peaks, eclipses and conjunctions |
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
The NWS only covers the United States and its territories.

Not every forecast office publishes every layer. Views say so explicitly when a
layer (for example Lightning Activity Level or the fire danger indices) is
absent for the selected point rather than showing zeros.

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
