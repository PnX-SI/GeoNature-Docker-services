#!/bin/bash

# destiné à l'action docker.yml


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPOSITORY_DIR=$(dirname "${SCRIPT_DIR}")

# récupération des infos git
. $SCRIPT_DIR/get_git_version.sh . GDS
. $SCRIPT_DIR/get_git_version.sh ./sources/GeoNature GN
. $SCRIPT_DIR/get_git_version.sh ./sources/gn_module_monitoring GN_MODULE_MONITORING
. $SCRIPT_DIR/get_git_version.sh ./sources/gn_module_export GN_MODULE_EXPORT
. $SCRIPT_DIR/get_git_version.sh ./sources/gn_module_import GN_MODULE_IMPORT
. $SCRIPT_DIR/get_git_version.sh ./sources/gn_module_dashboard GN_MODULE_DASHBOARD


cd $REPOSITORY_DIR/

GN_IMAGE_NAME=ghcr.io/pnx-si/gds-geonature
GN_4_MODULES_IMAGE_NAME=${GN_IMAGE_NAME}-4-modules

[ ${GDS_IS_TAG} = true ] && IMAGE_VERSION="${GDS_GIT_VERSION}__${GN_GIT_VERSION}" || IMAGE_VERSION="${GDS_GIT_VERSION}"
[ ${GDS_IS_TAG} = true ] && LATEST_TAG=", latest" || LATEST_TAG=""

GN_FRONTEND_IMAGE=$(echo "${GN_IMAGE_NAME}-frontend:${GDS_GIT_VERSION}" | tr '[:upper:]' '[:lower:]')
GN_FRONTEND_TAGS="${GN_FRONTEND_IMAGE}${LATEST_TAG}"
GN_FRONTEND_4M_TAGS=$(echo "${GN_4_MODULES_IMAGE_NAME}-frontend:${GDS_GIT_VERSION}" | tr '[:upper:]' '[:lower:]')${LATEST_TAG}

GN_BACKEND_IMAGE=$(echo "${GN_IMAGE_NAME}-backend:${GDS_GIT_VERSION}" | tr '[:upper:]' '[:lower:]')
GN_BACKEND_TAGS="${GN_BACKEND_IMAGE}${LATEST_TAG}"
GN_BACKEND_4M_TAGS=$(echo "${GN_4_MODULES_IMAGE_NAME}-backend:${GDS_GIT_VERSION}" | tr '[:upper:]' '[:lower:]')${LATEST_TAG}

GN_4M_DESCRIPTION="GDS ${GDS_GIT_VERSION} GeoNature ${GN_GIT_VERSION}, MONITORING ${GN_MODULE_MONITORING_GIT_VERSION}, IMPORT ${GN_MODULE_IMPORT_VERSION}, EXPORT ${GN_MODULE_EXPORT_GIT_VERSION}, DASHBOARD ${GN_MODULE_DASHBOARD_GIT_VERSION}"

BUILD_DATE=$(date -Iseconds)

GN_LABELS="org.opencontainers.image.url=https://github.com/PnX-SI/GeoNature-Docker-services
org.opencontainers.image.created=${BUILD_DATE}
org.opencontainers.image.source=https://github.com/PnX-SI/GeoNature
org.opencontainers.image.version=${GN_GIT_VERSION}
org.opencontainers.image.vendor=https://github.com/PnX-SI
"

echo "GDS_IS_TAG=$GDS_IS_TAG"
echo "GN_IS_TAG=$GN_IS_TAG"
echo "GN_MODULE_MONITORING_IS_TAG=$GN_MODULE_MONITORING_IS_TAG"
echo "GN_MODULE_EXPORT_IS_TAG=$GN_MODULE_EXPORT_IS_TAG"
echo "GN_MODULE_IMPORT_IS_TAG=$GN_MODULE_IMPORT_IS_TAG"
echo "GN_MODULE_DASHBOARD_IS_TAG=$GN_MODULE_DASHBOARD_IS_TAG"

echo "GN_FRONTEND_IMAGE=$GN_FRONTEND_IMAGE"
echo "GN_FRONTEND_TAGS=$GN_FRONTEND_TAGS"
echo "GN_FRONTEND_4M_TAGS=$GN_FRONTEND_4M_TAGS"

echo "GN_BACKEND_IMAGE=$GN_BACKEND_IMAGE"
echo "GN_BACKEND_TAGS=$GN_BACKEND_TAGS"
echo "GN_BACKEND_4M_TAGS=$GN_BACKEND_4M_TAGS"

echo "GN_4M_DESCRIPTION=$GN_4M_DESCRIPTION"
echo "GN_LABELS=$GN_LABELS"
echo "BUILD_DATE=$BUILD_DATE"

exit $SCRIPT_DIR/check_env.sh