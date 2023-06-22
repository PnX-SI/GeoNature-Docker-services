# script docker GN all
set -xeof pipefail
source .env

current_dir="$(pwd)"
# A Définir au préalable
# GEONATURE_BACKEND_IMAGE="gn_backend_cur"
# GEONATURE_FRONTEND_IMAGE="gn_frontend_cur"
# GEONATURE_FRONTEND_4_MODULES_IMAGE="gn_frontend_4_cur"
# GEONATURE_BACKEND_4_MODULES_IMAGE="gn_backend_4_cur"


# BUILD des applications

# - ATLAS

docker build -f sources/GeoNature-atlas/Dockerfile -t ${GDS_ATLAS_IMAGE}  sources/GeoNature-atlas/


# - USERSHUB

# chargement des sous modules git
cd sources/UsersHub
git submodule init
git submodule update
cd ${current_dir}

docker build -f sources/UsersHub/Dockerfile -t ${GDS_USERSHUB_IMAGE}  sources/UsersHub/


# - TAXHUB

# chargement des sous modules git
cd sources/TaxHub
git submodule init
git submodule update
cd ${current_dir}

docker build -f sources/TaxHub/Dockerfile -t ${GDS_TAXHUB_IMAGE}  sources/TaxHub/


# - GEONATURE

# chargement des sous modules git
cd sources/GeoNature
git submodule init
git submodule update
cd ${current_dir}

#   - FRONTEND

#     - SOURCES

docker build -f sources/GeoNature/frontend/Dockerfile -t ${GDS_GEONATURE_FRONTEND_IMAGE}-source --target=source sources/GeoNature/

#     - NGINX

docker build -f sources/GeoNature/frontend/Dockerfile -t ${GDS_GEONATURE_FRONTEND_IMAGE}-nginx --target=prod-base sources/GeoNature/

#     - APP + 4 MODULES

docker build \
    --build-arg GEONATURE_FRONTEND_IMAGE=${GDS_GEONATURE_FRONTEND_IMAGE} \
    -f ./build/Dockerfile-geonature-frontend \
    -t ${GDS_GEONATURE_FRONTEND_IMAGE} .


#  - BACKEND

#    - WHEELS

docker build -f sources/GeoNature/backend/Dockerfile -t ${GDS_GEONATURE_BACKEND_IMAGE}-wheels --target=wheels sources/GeoNature/

#    - APP

docker build \
    --build-arg GEONATURE_BACKEND_IMAGE=${GDS_GEONATURE_BACKEND_IMAGE} \
    -f ./build/Dockerfile-geonature-backend \
    -t ${GDS_GEONATURE_BACKEND_IMAGE} .