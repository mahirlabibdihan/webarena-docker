#!/bin/bash
source 00_vars.sh

# Frontend

docker stop openstreetmap-website-db-1 openstreetmap-website-web-1
docker rm openstreetmap-website-db-1 openstreetmap-website-web-1

# tile server URL (use default openstreetmap server)
OSM_TILE_SERVER_URL="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
# OSM_TILE_SERVER_URL="http://$PUBLIC_HOSTNAME:8880/{z}/{x}/{y}.png"
# geocoding server URL (use default openstreetmap server)
# OSM_GEOCODING_SERVER_URL="https://nominatim.openstreetmap.org/"
OSM_GEOCODING_SERVER_URL=http://$PUBLIC_HOSTNAME:8085/
# routing server URLs (use default openstreetmap server)
# OSM_ROUTING_SERVER_URL="https://routing.openstreetmap.de"
# OSM_CAR_SUFFIX="/routed-car"
# OSM_BIKE_SUFFIX="/routed-bike"
# OSM_FOOT_SUFFIX="/routed-foot"
# original WebArena config (CMU server with different ports for each vehicule type)
OSM_ROUTING_SERVER_URL="http://$PUBLIC_HOSTNAME"
OSM_CAR_SUFFIX=":5000"
OSM_BIKE_SUFFIX=":5001"
OSM_FOOT_SUFFIX=":5002"


cd openstreetmap-website/
cp ../openstreetmap-templates/docker-compose.yml ./docker-compose.yml
cp ../openstreetmap-templates/leaflet.osm.js ./vendor/assets/leaflet/leaflet.osm.js
cp ../openstreetmap-templates/fossgis_osrm.js ./app/assets/javascripts/index/directions/fossgis_osrm.js

# sed works differently on Mac (BSD) and Linux (GNU),
# so we need to check the version of sed to determine the correct syntax for in-place editing
if [[ -z "$OSTYPE" ]]; then
  echo "Error: OSTYPE is not set. Please run this script in a proper shell environment."
  exit 1
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE=(-i '')  # MacOS
else
  SED_INPLACE=(-i)  # Linux
fi
# set up web server port
sed "${SED_INPLACE[@]}" "s|MAP_PORT|${MAP_PORT}|g" docker-compose.yml
# set up tile server URL
sed "${SED_INPLACE[@]}" "s|url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'|url: '${OSM_TILE_SERVER_URL}'|g" ./vendor/assets/leaflet/leaflet.osm.js
# set up geocoding server URL
sed "${SED_INPLACE[@]}" "s|nominatim_url:.*|nominatim_url: \"$OSM_GEOCODING_SERVER_URL\"|g" ./config/settings.yml
# set up routing server URLs
sed "${SED_INPLACE[@]}" "s|fossgis_osrm_url:.*|fossgis_osrm_url: \"$OSM_ROUTING_SERVER_URL\"|g" ./config/settings.yml
sed "${SED_INPLACE[@]}" "s|__OSMCarSuffix__|${OSM_CAR_SUFFIX}|g" ./app/assets/javascripts/index/directions/fossgis_osrm.js
sed "${SED_INPLACE[@]}" "s|__OSMBikeSuffix__|${OSM_BIKE_SUFFIX}|g" ./app/assets/javascripts/index/directions/fossgis_osrm.js
sed "${SED_INPLACE[@]}" "s|__OSMFootSuffix__|${OSM_FOOT_SUFFIX}|g" ./app/assets/javascripts/index/directions/fossgis_osrm.js

echo "🛠️ Starting Docker Compose services..."
docker compose create
docker compose start

echo "⏳ Waiting for PostgreSQL to initialize..."
sleep 60  # 300 seconds is usually overkill unless the DB is very large

echo "🧩 Ensuring openstreetmap role exists..."
docker exec -i openstreetmap-website-db-1 psql -U postgres -c "
DO
\$\$
BEGIN
   IF NOT EXISTS (
       SELECT FROM pg_catalog.pg_roles WHERE rolname = 'openstreetmap'
   ) THEN
       CREATE ROLE openstreetmap WITH LOGIN PASSWORD 'openstreetmap';
       ALTER ROLE openstreetmap SUPERUSER;
   END IF;
END
\$\$;
"

echo "🗃️ Running Rails database migrations..."
docker exec openstreetmap-website-web-1 bin/rails db:migrate RAILS_ENV=development

echo "✅ Initialization complete!"