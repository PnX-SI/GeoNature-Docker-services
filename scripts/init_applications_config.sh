#!/bin/bash

# GN config required SECRET_KEY
if [ ! -f data/apps/geonature/config/geonature_config.toml ]; then
    echo "SECRET_KEY = 'fiezbhefzbihrzfbfziboazj2222'" > data/apps/geonature/config/geonature_config.toml
fi

touch data/apps/taxhub/config/config.py
touch data/apps/usershub/config/config.py
