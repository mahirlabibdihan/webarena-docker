WAIT_TIME=$1
printf "⏳ Starting services... "
for ((i=$WAIT_TIME; i>=1; i--)); do
    printf "%3d seconds remaining\r⏳ Starting services... " $i
    sleep 1
done
printf "✓ Services startup completed!                    \n"