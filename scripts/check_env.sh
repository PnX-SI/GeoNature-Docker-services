echo GN_IS_TAG $GN_IS_TAG
echo GN_MODULE_MONITORING_IS_TAG $GN_MODULE_MONITORING_IS_TAG
echo GN_MODULE_DASHBOARD_IS_TAG $GN_MODULE_DASHBOARD_IS_TAG
echo GN_MODULE_EXPORT_IS_TAG $GN_MODULE_EXPORT_IS_TAG
echo GN_MODULE_IMPORT_IS_TAG $GN_MODULE_IMPORT_IS_TAG

ALL_SOURCE_IS_TAG=[ [ ${GN_IS_TAG} = true ] \
    && [ ${GN_MODULE_MONITORING_IS_TAG} = true ] \
    && [ ${GN_MODULE_IMPORT_IS_TAG} = true ] \
    && [ ${GN_MODULE_DASHBOARD_IS_TAG} = true ] \
    && [ ${GN_MODULE_EXPORT_IS_TAG} = true ] ]

# si GDS est sur un tag mais pas tous les autres -> erreur
if [[ ${GDS_IS_TAG} = true && ! ( ${ALL_SOURCE_IS_TAG} ) ]]; then
    exit 1
else
    exit 0
fi