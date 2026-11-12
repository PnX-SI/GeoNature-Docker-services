# FAQ

## Comment ouvrir à l'accès à la base de données ?

Activer le fichier d’override `expose-postgres` :

```env
COMPOSE_FILE=${COMPOSE_FILE}:override_gallery/docker-compose.expose-postgres.yml
POSTGRES_EXPOSED_PORT=5439
```

puis relancer `docker compose up -d`

La base de données sera alors accessible localement sur le port 5439.
Si vous omettez `POSTGRES_EXPOSED_PORT`, la base de données sera exposé sur le port par défaut de PostgreSQL, le port 5432.
Se méfier de ne pas avoir déjà une base de données localement en écoute sur ce port.

## Comment déployer GeoNature et UsersHub sur des domaines séparés ?

Modifier le fichier `.env` comme ceci (on suppose que `HOST="mon-domaine.org"`) :

```shell
USERSHUB_HOST="usershub.${HOST}"
USERSHUB_HOSTPORT="usershub.${HOSTPORT}"
USERSHUB_PREFIX="/"

GEONATURE_BACKEND_HOST="geonature.${HOST}"
GEONATURE_BACKEND_HOSTPORT="geonature.${HOSTPORT}"
GEONATURE_BACKEND_PREFIX="/api"

GEONATURE_FRONTEND_HOST="geonature.${HOST}"
GEONATURE_FRONTEND_HOSTPORT="geonature.${HOSTPORT}"
GEONATURE_FRONTEND_PREFIX="/"
```

Puis relancer `docker compose up -d`

Vous pourrez alors accéder, par exemple, à GeoNature à l’adresse <https://geonature.mon-domaine.org> et UsersHub à l'adresse <https://usershub.mon-domaine.org>.

## Comment importer le MNT / DEM ?

GeoNature a besoin d'un modèle numérique de terrain (MNT ou DEM) dans sa base de données pour calculer automatiquement les altitudes des objets localisés sur les cartes.

Par défaut un MNT de France métropolitaine avec un pas de 250m fourni par l'IGN est proposé et peut être intégré dans la base de données. Il est possible (et recommandé) de le remplacer par un MNT plus précis limité à votre territoire.

- Télécharger la version de la BD ALTI IGN (24MB) proposée par défaut : `wget https://geonature.fr/data/ign/BDALTIV2_2-0_250M_ASC_LAMB93-IGN69_FRANCE_2017-06-21.zip`
- Désarchiver : `unzip BDALTIV2_2-0_250M_ASC_LAMB93-IGN69_FRANCE_2017-06-21.zip`
- Installer `raster2pgsql` dans le conteneur Docker contenant PostgreSQL et la BDD de GeoNature : `docker compose exec postgres /bin/sh -c "apt-get update && apt-get install -y postgis"`
- Copier le MNT dans ce conteneur : `docker compose cp BDALTIV2_250M_FXX_0098_7150_MNT_LAMB93_IGN69.asc postgres:/`
- Lancer l’import (préciser votre SRID) : `docker compose exec postgres raster2pgsql -s {local_srid} -c -C -I -M -d BDALTIV2_250M_FXX_0098_7150_MNT_LAMB93_IGN69.asc ref_geo.dem | docker compose exec -T postgres psql -U geonatadmin -d geonature2db`

À noter : si le conteneur `postgres` est recréé, l’installation de `raster2pgsql` et la copie du MNT dans le conteneur seront perdus.  
Mais ces données ne sont normalement plus nécessaires une fois le MNT importé dans la base de données (qui elle est permanente).

## Comment rediriger `/` vers `/geonature/` ?

Créer un fichier `docker-compose.override.yml` avec ces lignes, pour ajouter au service `traefik` les labels suivants :

```yaml
services:
  traefik:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.root.rule=Host(`${HOST}`) && Path(`/`)"
      - "traefik.http.routers.root.entrypoints=websecure"
      - "traefik.http.routers.root.tls.certResolver=acme-resolver"
      - "traefik.http.routers.root.middlewares=gnprefix"
      - "traefik.http.middlewares.gnprefix.redirectregex.regex=(.)*"
      - "traefik.http.middlewares.gnprefix.redirectregex.replacement=${GEONATURE_FRONTEND_PREFIX}/"
```

## Comment connaître la version de GeoNature contenue dans l’image Docker ?

```shell
docker image inspect ghcr.io/pnx-si/geonature-backend-extra --format '{{index .Config.Labels "org.opencontainers.image.version"}}'
```

ou, pour plus d’informations :

```shell
docker image inspect ghcr.io/pnx-si/geonature-backend-extra --format '{{json .Config.Labels}}'
```
