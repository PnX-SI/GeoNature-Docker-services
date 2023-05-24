#!/bin/bash

# test
# si GeoNature-Docker-Service est une release
# on souhaite vérifier que toutes les source sont aussi des releases

ALL_SOURCE_IS_TAG=[ ${GN_IS_TAG} = true ] \
    && [ ${GN_MODULE_MONITORING_IS_TAG} = true ] \
    && [ ${GN_MODULE_IMPORT_IS_TAG} = true ] \
    && [ ${GN_MODULE_DASHBOARD_IS_TAG} = true ] \
    && [ ${GN_MODULE_EXPORT_IS_TAG} = true ]

# si GDS est sur un tag mais pas tous les autres -> erreur
if [[ ${GDS_IS_TAG} = true && ! ( ${ALL_SOURCE_IS_TAG} ) ]]; then
    exit 1
else
    exit 0
fi