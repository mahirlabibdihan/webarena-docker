SERVICE_NAME=$1
SERVICE_URL=$2

echo "Checking $SERVICE_NAME responsiveness..."

spinstr='|/-\'
delay=0.1

while true; do
    # Try the request
    if curl -s --max-time 3 "$SERVICE_URL" > /dev/null 2>&1; then
        response_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$SERVICE_URL")
        if [ "$response_code" = "200" ] || [ "$response_code" = "302" ]; then
            break
        fi
    fi

    # Spinner animation
    for (( i=0; i<${#spinstr}; i++ )); do
        printf " [%c] Waiting for %s to become responsive..." "${spinstr:$i:1}" "$SERVICE_NAME"
        sleep $delay
        printf "\r"
    done
done

printf "    \r"
echo "✅ $SERVICE_NAME is ready and responsive at $SERVICE_URL"
