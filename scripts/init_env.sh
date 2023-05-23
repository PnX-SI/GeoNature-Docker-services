#!/bin/bash

GN_VERSION=current
GN_IMAGE_NAME=ghcr.io/pnx-si/gds-geonature
GN_4_MODULES_IMAGE_NAME=${GN_IMAGE_NAME}-4-modules

# destiné à l'action docker.yml

GN_FRONTEND_TAG=$(echo "${GN_IMAGE_NAME}-frontend:${GN_VERSION}" | tr '[:upper:]' '[:lower:]')
GN_FRONTEND_4M_TAG=$(echo "${GN_4_MODULES_IMAGE_NAME}-frontend:${GN_VERSION}" | tr '[:upper:]' '[:lower:]')

GN_BACKEND_TAG=$(echo "${GN_IMAGE_NAME}-backend:${GN_VERSION}" | tr '[:upper:]' '[:lower:]')
GN_BACKEND_4M_TAG=$(echo "${GN_4_MODULES_IMAGE_NAME}-backend:${GN_VERSION}" | tr '[:upper:]' '[:lower:]')

GN_VERSION=$(cat ./GeoNature/VERSION)
GN_MODULE_MONITORING_VERSION=$(cat gn_module_monitoring/VERSION)
GN_MODULE_EXPORT_VERSION=$(cat gn_module_export/VERSION)
GN_MODULE_IMPORT_VERSION=$(cat gn_module_import/VERSION)
GN_MODULE_DASHBOARD_VERSION=$(cat gn_module_dashboard/VERSION)

GN_4M_DESCRIPTION="GeoNature ${GN_VERSION}, MONITORING ${GN_MODULE_MONITORING_VERSION}, IMPORT ${GN_MODULE_IMPORT_VERSION}, EXPORT ${GN_MODULE_EXPORT_VERSION}, DASHBOARD ${GN_MODULE_DASHBOARD_VERSION}"

BUILD_DATE=$(date -Iseconds)

GN_LABELS="org.opencontainers.image.url=https://github.com/PnX-SI/GeoNature-Docker-services
org.opencontainers.image.created=${BUILD_DATE}
org.opencontainers.image.source=https://github.com/PnX-SI/GeoNature
org.opencontainers.image.version=${GN_VERSION}
org.opencontainers.image.vendor=https://github.com/PnX-SI
"


echo "GN_FRONTEND_TAG=$GN_FRONTEND_TAG"
echo "GN_FRONTEND_4M_TAG=$GN_FRONTEND_4M_TAG"
echo "GN_BACKEND_TAG=$GN_BACKEND_TAG"
echo "GN_BACKEND_4M_TAG=$GN_BACKEND_4M_TAG"
echo "GN_4M_DESCRIPTION=$GN_4M_DESCRIPTION"
echo "GN_LABELS=$GN_LABELS"
echo "BUILD_DATE=$BUILD_DATE"