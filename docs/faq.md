# FAQ

## Comment accéder à la base de données ?

Créer un fichier `docker-compose.override.yml` contenant :

```
services:
  postgres:
    ports:
      - 5432:5432
```

puis re-lancer `docker compose up -d`

Il se peut que vous ayez déjà une base de données localement.
Dans ce cas, vous pouvez utiliser un autre port : ` -5433:5432`
La base de données sera alors accessible localement sur le port 5433.
Attention, le deuxième port est celui d’écoute dans le conteneur et doit rester à 5432.


## Comment déployer GeoNature, TaxHub et UsersHub sur des domaines séparés ?

Éditer le fichier `.env` comme ceci (on suppose que ``HOST="mon-domaine.org") :

```
USERSHUB_HOST="usershub.${HOST}"
USERSHUB_HOSTPORT="usershub.${HOSTPORT}"
USERSHUB_PREFIX="/"

TAXHUB_HOST="taxhub.${HOST}"
TAXHUB_HOSTPORT="taxhub.${HOSTPORT}"
TAXHUB_PREFIX="/"
TAXHUB_API_PREFIX="${TAXHUB_PREFIX}api"

GEONATURE_BACKEND_HOST="geonature.${HOST}"
GEONATURE_BACKEND_HOSTPORT="geonature.${HOSTPORT}"
GEONATURE_BACKEND_PREFIX="/api"

GEONATURE_FRONTEND_HOST="geonature.${HOST}"
GEONATURE_FRONTEND_HOSTPORT="geonature.${HOSTPORT}"
GEONATURE_FRONTEND_PREFIX="/"
```

puis relancer `docker compose up -d`

Vous pourrez alors accéder, par exemple, à GeoNature à l’adresse https://geonature.mon-domaine.org


## Comment peupler le MNT / DEM ?

- Télécharger la dernière version de la BD ALTI (24MB): `wget https://geonature.fr/data/ign/BDALTIV2_2-0_250M_ASC_LAMB93-IGN69_FRANCE_2017-06-21.zip`
- Désarchiver : `unzip BDALTIV2_2-0_250M_ASC_LAMB93-IGN69_FRANCE_2017-06-21.zip`
- Installer `raster2pgsql` : `docker compose exec postgres /bin/sh -c "apt-get update && apt-get install -y postgis"`
- Copier le MNT dans le conteneur : `docker compose cp BDALTIV2_250M_FXX_0098_7150_MNT_LAMB93_IGN69.asc postgres:/`
- Lancer l’import (préciser votre SRID) : `docker compose exec postgres raster2pgsql -s {local_srid} -c -C -I -M -d BDALTIV2_250M_FXX_0098_7150_MNT_LAMB93_IGN69.asc ref_geo.dem | docker compose exec -T postgres psql -U geonatadmin -d geonature2db`

À noter : si le conteneur `postgres` est re-créé, l’installation de `raster2pgsql` et la copie du MNT dans le conteneur seront perdu.
Mais ces données ne sont normalement plus nécessaire une fois le MNT importé en base (qui elle est permanante).