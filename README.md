# Pull Images
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
wget http://metis.lti.cs.cmu.edu/webarena-images/wikipedia_en_all_maxi_2022-05.zim
mkdir wikipedia
mv ./wikipedia_en_all_maxi_2022-05.zim wikipedia/
```

<!-- ## Map
### Frontend
```bash
wget https://zenodo.org/records/12636845/files/openstreetmap-website-db.tar.gz
docker load --input openstreetmap-website-db.tar.gz
wget https://zenodo.org/records/12636845/files/openstreetmap-website-web.tar.gz
docker load --input openstreetmap-website-web.tar.gz
wget https://zenodo.org/records/12636845/files/openstreetmap-website.tar.gz
tar -xzf ./openstreetmap-website.tar.gz
```
### Backend
#### Nominatim
#### OSRM
#### Tile Server -->


# Run Containers
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
### Wikipedia
```bash
bash restart_site.sh wikipedia
```