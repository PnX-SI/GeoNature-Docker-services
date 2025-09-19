#!/bin/bash

MAX_RETRIES=$1
RETRY_INTERVAL=$2
EXPECTED_SERVICES=$3

echo "Expected services: $EXPECTED_SERVICES"

check_service() {
    local service=$1
    for i in $(seq 1 $MAX_RETRIES); do
        if docker compose ps $service | grep -q "Up"; then
            echo "$service is running"
            return 0
        fi
        echo "Waiting for $service to be running (attempt $i/$MAX_RETRIES)..."
        sleep $RETRY_INTERVAL
    done
    echo "Error: $service failed to start after $MAX_RETRIES attempts"
    docker compose logs $service
    return 1
}

# Vérifier que tous les services attendus sont actifs
for service in $EXPECTED_SERVICES; do
    if ! check_service $service; then
        exit 1
    fi
done

# Vérifier qu'aucun service inattendu n'est actif
echo "Checking for unexpected running services..."
RUNNING_SERVICES=$(docker compose ps --services --filter "status=running")

for running_service in $RUNNING_SERVICES; do
    if [ "$running_service" = "geonature-install-db" ]; then
        echo "ℹ️  Ignoring optional service: $running_service"
        continue
    fi

    if ! echo "$EXPECTED_SERVICES" | grep -q "\b$running_service\b"; then
        echo "❌ Error: Unexpected service '$running_service' is running!"
        echo "Expected services: $EXPECTED_SERVICES"
        echo "Running services: $RUNNING_SERVICES"
        exit 1
    fi
done

echo "✅ All expected services are running and no unexpected services detected!"
echo "Running services: $RUNNING_SERVICES"