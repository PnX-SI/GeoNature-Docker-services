#!/bin/bash

set -a && source .env && set +a

if [ ! -d "$GEONATURE_CONFIG_DIR" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR"
fi

if [ ! -d "$GEONATURE_DATA_DIR" ]; then
    mkdir -p "$GEONATURE_DATA_DIR"
    mkdir -p "$GEONATURE_DATA_DIR/custom"
    mkdir -p "$GEONATURE_DATA_DIR/media"
fi

if [ ! -f "$GEONATURE_CONFIG_DIR/geonature/geonature_config.toml" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR/geonature"
    echo "SECRET_KEY = \"$(openssl rand -hex 16)\"" > "$GEONATURE_CONFIG_DIR/geonature/geonature_config.toml"
fi

if [ ! -f "$GEONATURE_CONFIG_DIR/usershub/config.py" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR/usershub"
    echo "SECRET_KEY = \"$(openssl rand -hex 16)\"" > "$GEONATURE_CONFIG_DIR/usershub/config.py"
fi

if [ ! -f "$GEONATURE_CONFIG_DIR/atlas/config.py" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR/atlas"
    echo "SECRET_KEY = \"$(openssl rand -hex 16)\"" > "$GEONATURE_CONFIG_DIR/atlas/config.py"
fi

if [ ! -d "$GEONATURE_CONFIG_DIR/traefik" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR/traefik/certs"
fi

touch "$GEONATURE_CONFIG_DIR/geonature/dashboard_config.toml"
touch "$GEONATURE_CONFIG_DIR/geonature/exports_config.toml"
touch "$GEONATURE_CONFIG_DIR/geonature/monitorings_config.toml"
touch "$GEONATURE_CONFIG_DIR/geonature/import_config.toml"
