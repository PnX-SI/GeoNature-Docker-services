#!/bin/bash

if [ ! -f config/geonature/geonature_config.toml ]; then
    echo SECRET_KEY = \"$(openssl rand -hex 16)\" > config/geonature/geonature_config.toml
fi
if [ ! -f config/usershub/config.py ]; then
    echo SECRET_KEY = \"$(openssl rand -hex 16)\" > config/usershub/config.py
fi
if [ ! -f config/taxhub/config.py ]; then
    echo SECRET_KEY = \"$(openssl rand -hex 16)\" > config/taxhub/config.py
fi
