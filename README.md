# Download Data

### Wikipedia Data
```bash
curl -O -C - http://metis.lti.cs.cmu.edu/webarena-images/wikipedia_en_all_maxi_2022-05.zim
mkdir wikipedia
mv ./wikipedia_en_all_maxi_2022-05.zim wikipedia/
```

### OSM Dump
```bash
curl -O -C - https://webarena-map-server-data.s3.amazonaws.com/osm_dump.tar
tar -xvf osm_dump.tar
rm -f osm_dump.tar
```

### Nominatim Volumes
```bash
curl -O -C - https://webarena-map-server-data.s3.amazonaws.com/nominatim_volumes.tar
tar -C /var/lib/docker/volumes --strip-components=5 -xf ./nominatim_volumes.tar
```

### OSRM Data
```bash
curl -O -C - https://webarena-map-server-data.s3.amazonaws.com/osrm_routing.tar
tar -xvf osrm_routing.tar
rm -f osrm_routing.tar
```

### Tile Volumes
```bash
curl -O -C - https://webarena-map-server-data.s3.amazonaws.com/osm_tile_server.tar
tar -C /var/lib/docker/volumes --strip-components=5 -xf ./osm_tile_server.tar
```

### Map Frontend
```bash
curl -O -C -  https://zenodo.org/records/12636845/files/openstreetmap-website-db.tar.gz
curl -O -C -  https://zenodo.org/records/12636845/files/openstreetmap-website-web.tar.gz
curl -O -C -  https://zenodo.org/records/12636845/files/openstreetmap-website.tar.gz
tar -xzf ./openstreetmap-website.tar.gz
rm -f openstreetmap-website.tar.gz
```

### Tile Server
```bash
curl -O -C - https://webarena-map-server-data.s3.amazonaws.com/osm_tile_server.tar
tar -xvfC /var/lib/docker/volumes --strip-components=5 -xf ./osm_tile_server.tar
rm -f osm_tile_server.tar
```

# Setup Images

### Gitlab
```bash
docker pull webarenaimages/gitlab-populated-final
docker tag webarenaimages/gitlab-populated-final gitlab-populated-final-port8023
```

### Shopping
```bash
docker pull webarenaimages/shopping_final_0712
docker tag webarenaimages/shopping_final_0712 shopping_final_0712
```

### Reddit
```bash
docker pull webarenaimages/postmill-populated-exposed-withimg
docker tag webarenaimages/postmill-populated-exposed-withimg postmill-populated-exposed-withimg
```

### Shopping Admin
```bash
docker pull webarenaimages/shopping_admin_final_0719
docker tag webarenaimages/shopping_admin_final_0719 shopping_admin_final_0719
```

### Wikipedia
```bash
docker pull ghcr.io/kiwix/kiwix-serve:3.3.0
```

## Map Frontend
```bash
docker load --input openstreetmap-website-db.tar.gz
docker load --input openstreetmap-website-web.tar.gz
rm -f openstreetmap-website-db.tar.gz openstreetmap-website-web.tar.gz
```
## Map Backend

- **Nominatim**
    ```bash
    docker pull mediagis/nominatim:4.2
    ```

- **OSRM**
    ```bash
    docker pull ghcr.io/project-osrm/osrm-backend:v5.27.1
    ```

- **Tile Server**
    ```bash
    docker pull overv/openstreetmap-tile-server
    ```

# Run Containers
### Gitlab
```bash
bash start_site.sh gitlab
```
### Shopping
```bash
bash start_site.sh shopping
```

### Reddit
```bash
bash start_site.sh reddit
```

### Shopping Admin
```bash
bash start_site.sh shopping_admin
```

### Wikipedia
```bash
bash start_site.sh wikipedia
```

### Nominatim

```bash
docker run --name nominatim --restart unless-stopped \
        --memory=4g --memory-swap=8g \
        --env=IMPORT_STYLE=extratags \
        --env=PBF_PATH=/nominatim/data/us-northeast-latest.osm.pbf \
        --env=IMPORT_WIKIPEDIA=/nominatim/data/wikimedia-importance.sql.gz \
        --volume=./osm_dump:/nominatim/data \
        --volume=nominatim-data:/var/lib/postgresql/14/main \
        --volume=nominatim-flatnode:/nominatim/flatnode \
        -p 8085:8080 -d mediagis/nominatim:4.2 /app/start.sh
```

### OSRM

- Start OSRM car routing
    ```bash
    docker run --name osrm-car --restart unless-stopped \
            --memory=4g --memory-swap=8g \
            --volume=./osrm/car:/data -p 5000:5000 -d \
            ghcr.io/project-osrm/osrm-backend:v5.27.1 osrm-routed --algorithm mld /data/us-northeast-latest.osrm
    ```

- Start OSRM bike routing
    ```bash
    docker run --name osrm-bike --restart unless-stopped \
            --memory=4g --memory-swap=8g \
            --volume=./osrm/bike:/data -p 5001:5000 -d \
            ghcr.io/project-osrm/osrm-backend:v5.27.1 osrm-routed --algorithm mld /data/us-northeast-latest.osrm
    ```

- Start OSRM car routing
    ```bash
    docker run --name osrm-foot --restart unless-stopped \
            --memory=4g --memory-swap=8g \
            --volume=./osrm/foot:/data -p 5002:5000 -d \
            ghcr.io/project-osrm/osrm-backend:v5.27.1 osrm-routed --algorithm mld /data/us-northeast-latest.osrm
    ```

### Tile Server

```bash
docker run --name tile --restart unless-stopped \
        --memory=2g --memory-swap=4g \
        --volume=osm-data:/data/database/ --volume=osm-tiles:/data/tiles/ \
        -p 8880:80 -d overv/openstreetmap-tile-server run
```

### Map Frontend
```bash
bash restart_osm.sh
```

```bash
sudo apt install osmosis
osmosis --read-pbf ./osm_dump/us-northeast-latest.osm.pbf   --write-apidb host="localhost:54321" database="openstreetmap"   user="openstreetmap" password=" " validateSchemaVersion="no"
```

# Restart Containers
*Need to restart 4 websites after each full experiment, as write tasks changes the website state.*

### Gitlab
```bash
bash restart_site.sh gitlab
```

### Shopping
```bash
bash restart_site.sh shopping
```

### Reddit
```bash
bash restart_site.sh reddit
```

### Shopping Admin
```bash
bash restart_site.sh shopping_admin
```
