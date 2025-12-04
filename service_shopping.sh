#!/bin/bash
source 00_vars.sh

docker create --name shopping -p $SHOPPING_PORT:80 shopping_final_0712
# docker create --name shopping -p http://127.0.0.1:80 shopping_final_0712
docker start shopping

# Countdown timer for service startup
bash countdown.sh 100

# remove the requirement to reset password
docker exec shopping /var/www/magento2/bin/magento setup:store-config:set --base-url="http://$PUBLIC_HOSTNAME:$SHOPPING_PORT" # no trailing /
docker exec shopping mysql -u magentouser -pMyPassword magentodb -e  "UPDATE core_config_data SET value='http://$PUBLIC_HOSTNAME:$SHOPPING_PORT/' WHERE path = 'web/secure/base_url';"
docker exec shopping /var/www/magento2/bin/magento cache:flush
bash countdown.sh 100
