#!/bin/bash

MAX_ATTEMPTS=$1
SLEEP_TIME=$2
URL_FRONTEND=$3
URL_BACKEND=$4

for i in $(seq 1 $MAX_ATTEMPTS); do
    echo "Attempt $i/$MAX_ATTEMPTS - Testing GeoNature availability..."
    if curl --insecure --fail --silent "$URL_FRONTEND" && \
       curl --insecure --fail --silent "$URL_BACKEND"; then
        echo "✅ GeoNature is ready!"
        exit 0
    fi
    echo "❌ Services not ready yet, waiting ${SLEEP_TIME}s..."
    sleep $SLEEP_TIME
done

echo "🚨 GeoNature failed to become available after $MAX_ATTEMPTS attempts"
docker compose logs
exit 1