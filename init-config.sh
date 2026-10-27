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

# TODO: enrober dans un "if [usershub dans COMPOSE_PROFILES]"
if [ ! -f "$GEONATURE_CONFIG_DIR/usershub/config.py" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR/usershub"
    echo "SECRET_KEY = \"$(openssl rand -hex 16)\"" > "$GEONATURE_CONFIG_DIR/usershub/config.py"
fi

# TODO: enrober dans un "if [atlas dans COMPOSE_PROFILES]"
if [ ! -f "$GEONATURE_CONFIG_DIR/atlas/configuration/config.py" ] || [ ! -f "$GEONATURE_CONFIG_DIR/atlas/configuration/settings.ini" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR/atlas/configuration/"
    atlas_container_id=$(docker create "$ATLAS_IMAGE")
    if [ ! -f "$GEONATURE_CONFIG_DIR/atlas/configuration/config.py" ]; then
        ATLAS_LOCAL_CONFIG_FILE="$GEONATURE_CONFIG_DIR/atlas/configuration/config.py"
        docker cp "$atlas_container_id:/dist/atlas/configuration/config.py.sample" "$ATLAS_LOCAL_CONFIG_FILE"
        sed -i 's/SQLALCHEMY_DATABASE_URI = "postgresql:\/\/geonatatlas:monpassachanger@localhost:5432\/geonatureatlas"/SQLALCHEMY_DATABASE_URI = "postgresql:\/\/'$PG_ATLAS_USER_NAME':'$PG_ATLAS_USER_PASS'@postgres:5432\/'$PG_ATLAS_DB_NAME'"/g' $ATLAS_LOCAL_CONFIG_FILE
        # Voir pour utiliser la variable GEONATURE_API_ENDPOINT ci-après, mais demande de bien gérer l'ajout de '\' devant les caractères '/'
        sed -i 's/REMOTE_MEDIAS_URL = "https:\/\/<URL_GEONATURE>\/api\/media\/taxhub\/"/REMOTE_MEDIAS_URL = "'$GEONATURE_BACKEND_PROTOCOL':\/\/'$GEONATURE_BACKEND_HOSTPORT'\/geonature\/api\/media\/taxhub\/"/g' $ATLAS_LOCAL_CONFIG_FILE
        # Voir pour utiliser la variable GEONATURE_API_ENDPOINT ci-après, mais demande de bien gérer l'ajout de '\' devant les caractères '/'
        sed -i 's/# Si vous utilisez GeoNature : REMOTE_MEDIAS_URL = "'$GEONATURE_BACKEND_PROTOCOL':\/\/'$GEONATURE_BACKEND_HOSTPORT'\/geonature\/api\/media\/taxhub\/"/# Si vous utilisez GeoNature : REMOTE_MEDIAS_URL = "https:\/\/<URL_GEONATURE>\/api\/media\/taxhub\/"/g' $ATLAS_LOCAL_CONFIG_FILE
        # Voir pour utiliser la variable GEONATURE_API_ENDPOINT ci-après, mais demande de bien gérer l'ajout de '\' devant les caractères '/'
        sed -i 's/TAXHUB_URL = "https:\/\/<URL_GEONATURE>\/api\/taxhub"/TAXHUB_URL = "'$GEONATURE_BACKEND_PROTOCOL':\/\/'$GEONATURE_BACKEND_HOSTPORT'\/geonature\/api\/taxhub"/g' $ATLAS_LOCAL_CONFIG_FILE
        # Voir pour utiliser la variable GEONATURE_API_ENDPOINT ci-après, mais demande de bien gérer l'ajout de '\' devant les caractères '/'
        sed -i 's/# Si vous utilisez GeoNature : TAXHUB_URL = "'$GEONATURE_BACKEND_PROTOCOL':\/\/'$GEONATURE_BACKEND_HOSTPORT'\/geonature\/api\/taxhub"/# Si vous utilisez GeoNature : TAXHUB_URL = "https:\/\/<URL_GEONATURE>\/api\/taxhub"/g' $ATLAS_LOCAL_CONFIG_FILE
        sed -i 's/SECRET_KEY = '"'INSERT_A_RANDOM_SECRET_KEY'"'/SECRET_KEY = '"'$(openssl rand -hex 16)'"'/g' $ATLAS_LOCAL_CONFIG_FILE
    fi
    if [ ! -f "$GEONATURE_CONFIG_DIR/atlas/configuration/settings.ini" ]; then
        ATLAS_LOCAL_SETTINGS_FILE="$GEONATURE_CONFIG_DIR/atlas/configuration/settings.ini"
        docker cp "$atlas_container_id:/dist/atlas/configuration/settings.ini.sample" "$ATLAS_LOCAL_SETTINGS_FILE"
        sed -i 's/db_host=localhost/db_host=postgres/g' $ATLAS_LOCAL_SETTINGS_FILE
        sed -i 's/db_name=geonatureatlas/db_name='$PG_ATLAS_DB_NAME'/g' $ATLAS_LOCAL_SETTINGS_FILE
        sed -i 's/user_pg=geonatatlas/user_pg='$PG_ATLAS_USER_NAME'/g' $ATLAS_LOCAL_SETTINGS_FILE
        sed -i 's/user_pg_pass=monpassachanger/user_pg_pass='$PG_ATLAS_USER_PASS'/g' $ATLAS_LOCAL_SETTINGS_FILE
        sed -i 's/owner_atlas=geonatadmin/owner_atlas='$PG_ATLAS_OWNER_NAME'/g' $ATLAS_LOCAL_SETTINGS_FILE
        sed -i 's/owner_atlas_pass=monpassachanger/owner_atlas_pass='$PG_ATLAS_OWNER_PASS'/g' $ATLAS_LOCAL_SETTINGS_FILE
        sed -i 's/atlas_source_user=geonatatlas/atlas_source_user='$PG_ATLAS_SOURCE_USER'/g' $ATLAS_LOCAL_SETTINGS_FILE
        sed -i 's/atlas_source_pass=monpassachanger/atlas_source_pass='$PG_ATLAS_SOURCE_USER_PASS'/g' $ATLAS_LOCAL_SETTINGS_FILE
    fi
    docker rm "$atlas_container_id"
fi

# TODO: enrober dans un "if [atlas dans COMPOSE_PROFILES]"
if [ ! -f "$GEONATURE_CONFIG_DIR/atlas/configuration/settings.ini" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR/atlas/configuration/"
    touch "$GEONATURE_CONFIG_DIR/atlas/configuration/settings.ini"
    wget https://raw.githubusercontent.com/PnX-SI/GeoNature-atlas/refs/heads/master/atlas/configuration/settings.ini.sample -O "$GEONATURE_CONFIG_DIR/atlas/configuration/settings.ini"
fi

# TODO: enrober dans un "if [atlas dans COMPOSE_PROFILES]"
if [ ! -d "$GEONATURE_DATA_DIR/atlas/static/custom" ]; then
    mkdir -p "$GEONATURE_DATA_DIR/atlas/static/custom"
fi

if [ ! -d "$GEONATURE_CONFIG_DIR/traefik" ]; then
    mkdir -p "$GEONATURE_CONFIG_DIR/traefik/certs"
fi

touch "$GEONATURE_CONFIG_DIR/geonature/dashboard_config.toml"
touch "$GEONATURE_CONFIG_DIR/geonature/exports_config.toml"
touch "$GEONATURE_CONFIG_DIR/geonature/monitorings_config.toml"
touch "$GEONATURE_CONFIG_DIR/geonature/import_config.toml"
