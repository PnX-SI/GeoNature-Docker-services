# script docker GN all
set -x 
source .env

# A Définir au préalable
# GEONATURE_BACKEND_CURRENT_IMAGE="gn_backend_cur"
# GEONATURE_FRONTEND_CURRENT_IMAGE="gn_frontend_cur"
# GEONATURE_FRONTEND_CURRENT_4_MODULES_IMAGE="gn_frontend_4_cur"
# GEONATURE_BACKEND_CURRENT_4_MODULES_IMAGE="gn_backend_4_cur"

# GN FRONTEND SOURCE
docker build -f sources/GeoNature/frontend/Dockerfile -t ${GEONATURE_FRONTEND_CURRENT_IMAGE}-source --target=source sources/GeoNature/

# GN FRONTEND NGINX
docker build -f sources/GeoNature/frontend/Dockerfile -t ${GEONATURE_FRONTEND_CURRENT_IMAGE}-nginx --target=prod-base sources/GeoNature/


# GN BACKEND WHEELS
docker build -f sources/GeoNature/backend/Dockerfile -t ${GEONATURE_BACKEND_CURRENT_IMAGE}-wheels --target=wheels sources/GeoNature/

# GN FRONTEND
docker build -f sources/GeoNature/frontend/Dockerfile -t ${GEONATURE_BACKEND_CURRENT_IMAGE} sources/GeoNature/

# GN BACKEND
docker build -f sources/GeoNature/backend/Dockerfile -t ${GEONATURE_FRONTEND_CURRENT_IMAGE} sources/GeoNature/

# GN FRONTEND 4 MODULE
docker build \
    --build-arg GEONATURE_FRONTEND_IMAGE=$GEONATURE_FRONTEND_CURRENT_IMAGE \
    -f ./build/Dockerfile-geonature-frontend \
    -t ${GEONATURE_FRONTEND_CURRENT_4_MODULES_IMAGE} .

# GN BACKEND 4 MODULES
docker build \
    --build-arg GEONATURE_BACKEND_IMAGE=$GEONATURE_BACKEND_CURRENT_IMAGE \
    -f ./build/Dockerfile-geonature-backend \
    -t ${GEONATURE_BACKEND_CURRENT_4_MODULES_IMAGE} .