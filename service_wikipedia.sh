#!/bin/bash
source 00_vars.sh
WORKING_DIR=$(pwd)

docker create --name "$CONTAINER_NAME" --volume=${WORKING_DIR}/wikipedia/:/data -p $WIKIPEDIA_PORT:80 ghcr.io/kiwix/kiwix-serve:3.3.0 wikipedia_en_all_maxi_2022-05.zim
docker start "$CONTAINER_NAME"