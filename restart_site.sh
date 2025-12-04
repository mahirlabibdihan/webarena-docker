#!/bin/bash
# Usage:
# ./reset_site.sh <site_key>
source 00_vars.sh

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <site_key>"
    exit 1
fi

WORKING_DIR=$(pwd)

SITE_KEY=$1
CONFIG_FILE="sites.yml"  # hardcoded path

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "❌ yq is required. Install it first: https://github.com/mikefarah/yq"
    exit 1
fi

# check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required. Install it first: https://stedolan.github.io/jq/"
    exit 1
fi

# Load environment variables
source 00_vars.sh

# Extract values from YAML
# Use second command-line argument if provided; otherwise read from YAML
CONTAINER_NAME=${3:-$(yq -r ".${SITE_KEY}.container_name" "$CONFIG_FILE")}
SERVICE_URL=$(yq -r ".${SITE_KEY}.service_url" "$CONFIG_FILE")
SERVICE_SCRIPT=$(yq -r ".${SITE_KEY}.service_script" "$CONFIG_FILE")

# If container exists → remove it
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "🗑 Removing existing container '$CONTAINER_NAME'..."
    max_retries=3
    count=0
    until docker stop "$CONTAINER_NAME"; do
        count=$((count+1))
        if [ $count -ge $max_retries ]; then
            echo "❌ Failed to stop container '$CONTAINER_NAME' after $max_retries attempts."
            break
        fi
        echo "⚠️ Retry $count/$max_retries: failed to stop, waiting..."
        sleep 2
    done
    docker rm -f "$CONTAINER_NAME"
fi

# Deploy fresh container (service scripts are in services/ directory)
echo "🚀 Deploying fresh container '$CONTAINER_NAME' using $SERVICE_SCRIPT..."
bash "$SERVICE_SCRIPT" "$CONTAINER_NAME"

# Wait for service to come up
bash spinner.sh "$CONTAINER_NAME" "$SERVICE_URL"
update_status "Running"