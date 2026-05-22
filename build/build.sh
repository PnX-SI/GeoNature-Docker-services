#!/bin/bash

set -x
set -o nounset

# It is necessary to build base-* images before building final images, and compose does not support build
# dependencies yet (solved with additional_contexts in compose 2.36.2 - not in Debian 13).

# docker-compose-build must come first, as dev file (if present in COMPOSE_FILE) override build sections
export COMPOSE_FILE=docker-compose-build.yml:$(docker compose config --environment | grep COMPOSE_FILE || echo "docker-compose.yml")

docker compose build base-backend
docker compose build geonature-install-db # requires base-backend

docker compose build base-frontend-source
docker compose build base-frontend-nginx
docker compose build geonature-frontend  # requires base-frontend-source and base-frontend-nginx

docker compose build usershub
