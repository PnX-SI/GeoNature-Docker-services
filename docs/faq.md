# FAQ

## Comment lancer des commandes `geonature` ?

Pour exécuter une commande `geonature`, lancer la commande :

```
docker compose exec -it geonature-backend geonature nom_de_la_commande
```

Exemples :

```
docker compose exec -it geonature-backend geonature --help
docker compose exec -it geonature-backend geonature dashboard refresh-vm
```

## Comment ouvrir à l'accès à la base de données ?

Créer un fichier `docker-compose.override.yml` contenant :

```
services:
  postgres:
    ports:
      - 5432:5432
```

puis relancer `docker compose up -d`

Il se peut que vous ayez déjà une base de données localement.  
Dans ce cas, vous pouvez utiliser un autre port : `-5433:5432`.  
La base de données sera alors accessible localement sur le port 5433.  
Attention, le deuxième port est celui d’écoute dans le conteneur et doit rester à 5432.

## Comment déployer GeoNature et UsersHub sur des domaines séparés ?

Modifier le fichier `.env` comme ceci (on suppose que `HOST="mon-domaine.org"`) :

```
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

Vous pourrez alors accéder, par exemple, à GeoNature à l’adresse https://geonature.mon-domaine.org et UsersHub à l'adresse https://usershub.mon-domaine.org.

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

```
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

```
docker image inspect ghcr.io/pnx-si/geonature-backend-extra --format '{{index .Config.Labels "org.opencontainers.image.version"}}'
```

ou, pour plus d’informations :

```
docker image inspect ghcr.io/pnx-si/geonature-backend-extra --format '{{json .Config.Labels}}'
```

## Comment rebuilder localement les images Docker ?

- Initialiser et cloner les sous-modules git :
  ```bash
  git submodule init
  git submodule update
  ```
- Faire de même pour les sous-modules de GeoNature et UsersHub, exemple pour GeoNature :
  ```bash
  cd sources/GeoNature
  git submodule init
  git submodule update
  cd ../..
  ```
- Apporter vos éventuelles modifications au code source.
- Il est conseillé de renommer les images dans le fichier `.env` afin de ne pas rentrer en conflit avec les images officielles, par exemple en leur rajoutant un suffix `-local` :
  ```env
  USERSHUB_IMAGE="ghcr.io/pnx-si/usershub-local:latest"
  GEONATURE_BACKEND_IMAGE="ghcr.io/pnx-si/geonature-backend-local:latest"
  GEONATURE_BACKEND_EXTRA_IMAGE="ghcr.io/pnx-si/geonature-backend-extra-local:latest"
  GEONATURE_FRONTEND_IMAGE="ghcr.io/pnx-si/geonature-frontend-local:latest"
  GEONATURE_FRONTEND_EXTRA_IMAGE="ghcr.io/pnx-si/geonature-frontend-extra-local:latest"
  ```
- Lancer le script `build/build.sh` depuis la racine du dépôt.
- Relancer `docker compose up -d` afin de recréer les conteneurs avec vos propres images Docker.
