#!/bin/bash

# TODO: Let GeoNature & UsersHub make required directories and generate a secret key automatically on first run

set -a && source .env && set +a

### CONFIG_DIR
if [ -z "$CONFIG_DIR" ]; then
  CONFIG_DIR="./config"
fi

# geonature
mkdir -p "$CONFIG_DIR/geonature"
if [ ! -f "${CONFIG_DIR}/geonature/geonature_config.toml" ]; then
  mkdir -p "$CONFIG_DIR/geonature"
  echo SECRET_KEY = \"$(openssl rand -hex 16)\" >"${CONFIG_DIR}/geonature/geonature_config.toml"
fi

# usershub
mkdir -p "$CONFIG_DIR/usershub"
if [ ! -f "${CONFIG_DIR}/usershub/config.py" ]; then
  echo SECRET_KEY = \"$(openssl rand -hex 16)\" >"${CONFIG_DIR}/usershub/config.py"
fi

# traefik
mkdir -p "$CONFIG_DIR/traefik/certs"

### DATA_DIR
if [ -z "$DATA_DIR" ]; then
  DATA_DIR="./data"
fi

mkdir -p "$DATA_DIR/geonature/custom"
mkdir -p "$DATA_DIR/geonature/media"
mkdir -p "$DATA_DIR/geonature/cache"
