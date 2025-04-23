#!/bin/bash

if [ ! -f config/geonature/geonature_config.toml ]; then
    echo SECRET_KEY = \"$(openssl rand -hex 16)\" > config/geonature/geonature_config.toml
fi
if [ ! -f config/usershub/config.py ]; then
    echo SECRET_KEY = \"$(openssl rand -hex 16)\" > config/usershub/config.py
fi
touch config/geonature/dashboard_config.toml
touch config/geonature/exports_config.toml
touch config/geonature/monitorings_config.toml
touch config/geonature/import_config.toml
