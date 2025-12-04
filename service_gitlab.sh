#!/bin/bash
source 00_vars.sh

docker create --name gitlab -p $GITLAB_PORT:8023 gitlab-populated-final-port8023 /opt/gitlab/embedded/bin/runsvdir-start
docker start gitlab

bash countdown.sh 60

docker exec gitlab sed -i "s|^external_url.*|external_url 'http://$PUBLIC_HOSTNAME:$GITLAB_PORT'|" /etc/gitlab/gitlab.rb
docker exec gitlab bash -c "printf '\n\npuma[\"worker_processes\"] = 4' >> /etc/gitlab/gitlab.rb"  # bugfix https://github.com/ServiceNow/BrowserGym/issues/285
docker exec gitlab gitlab-ctl reconfigure
