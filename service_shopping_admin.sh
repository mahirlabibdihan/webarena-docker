#!/bin/bash
source 00_vars.sh

CONTAINER_NAME=$1

# docker create --name shopping_admin -p 7780:80 shopping_admin_final_0719
docker create --name $CONTAINER_NAME -p $SHOPPING_ADMIN_PORT:80 shopping_admin_final_0719
# docker start shopping_admin
docker start $CONTAINER_NAME

bash countdown.sh 60

# docker exec shopping_admin php /var/www/magento2/bin/magento config:set admin/security/password_is_forced 0
docker exec $CONTAINER_NAME php /var/www/magento2/bin/magento config:set admin/security/password_is_forced 0
# docker exec shopping_admin php /var/www/magento2/bin/magento config:set admin/security/password_lifetime 0
docker exec $CONTAINER_NAME php /var/www/magento2/bin/magento config:set admin/security/password_lifetime 0

# docker exec shopping_admin /var/www/magento2/bin/magento setup:store-config:set --base-url="http://127.0.0.1:7780"
docker exec $CONTAINER_NAME /var/www/magento2/bin/magento setup:store-config:set --base-url="http://$PUBLIC_HOSTNAME:$SHOPPING_ADMIN_PORT"
# docker exec shopping_admin mysql -u magentouser -pMyPassword magentodb -e  "UPDATE core_config_data SET value='http://127.0.0.1:7780/' WHERE path = 'web/secure/base_url';"

docker exec $CONTAINER_NAME mysql -u magentouser -pMyPassword magentodb -e  "UPDATE core_config_data SET value='http://$PUBLIC_HOSTNAME:$SHOPPING_ADMIN_PORT/' WHERE path = 'web/secure/base_url';"

docker exec $CONTAINER_NAME /var/www/magento2/bin/magento cache:flush

# 1.09GB / 851MB
