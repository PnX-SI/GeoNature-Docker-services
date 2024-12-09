#!/bin/bash

set -x 
set -o nounset

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

source .env

# GN BACKEND WHEELS
# docker build -f sources/GeoNature/backend/Dockerfile -t ${GEONATURE_BACKEND_IMAGE}-wheels --target=wheels sources/GeoNature/

# GN BACKEND EXTRA
docker build \
    --build-arg GEONATURE_BACKEND_IMAGE=${GEONATURE_BACKEND_IMAGE} \
    -f ./build/Dockerfile-geonature-backend \
    -t ${GEONATURE_BACKEND_EXTRA_IMAGE} .

# GN FRONTEND SOURCE
# docker build -f sources/GeoNature/frontend/Dockerfile -t ${GEONATURE_FRONTEND_IMAGE}-source --target=source sources/GeoNature/

# # GN FRONTEND NGINX
# docker build -f sources/GeoNature/frontend/Dockerfile -t ${GEONATURE_FRONTEND_IMAGE}-nginx --target=prod-base sources/GeoNature/

# # GN FRONTEND EXTRA
# docker build \
#     --build-arg GEONATURE_FRONTEND_IMAGE=${GEONATURE_FRONTEND_IMAGE} \
#     -f ./build/Dockerfile-geonature-frontend \
#     -t ${GEONATURE_FRONTEND_EXTRA_IMAGE} .


# # UsersHub
# docker build -f sources/UsersHub/Dockerfile -t ${USERSHUB_IMAGE} --target=prod sources/UsersHub/
