#!/bin/bash
source 00_vars.sh

docker create --name reddit -p $REDDIT_PORT:80 postmill-populated-exposed-withimg
docker start reddit

bash countdown.sh 60

# reddit - make server more responsive
docker exec reddit sed -i \
  -e 's/^pm.max_children = .*/pm.max_children = 32/' \
  -e 's/^pm.start_servers = .*/pm.start_servers = 10/' \
  -e 's/^pm.min_spare_servers = .*/pm.min_spare_servers = 5/' \
  -e 's/^pm.max_spare_servers = .*/pm.max_spare_servers = 20/' \
  -e 's/^;pm.max_requests = .*/pm.max_requests = 500/' \
  /usr/local/etc/php-fpm.d/www.conf 
docker exec reddit supervisorctl restart php-fpm