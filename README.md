# GeoNature Docker Services

Dockerisation de geonature et d'application associées

## Les services

 - `postgres`
 - `usershub`
 - `taxhub`
 - `geonature-backend`
 - `geonature-frontend`
 - `geonature-worker`: `worker` qui peut reprendre certaine tâches de geonature (import, export, mail, etc...)
 - `redis`

- `traefik`

```
SERVICE              PORTS
geonature-backend    8000/tcp
geonature-frontend   80/tcp
geonature-worker     8000/tcp
postgres             0.0.0.0:5435->5432/tcp, :::5435->5432/tcp
redis                6379/tcp
taxhub               5000/tcp
traefik              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:8889->8080/tcp, :::80->80/tcp, :::443->443/tcp, :::8889->8080/tcp
usershub             5001/tcp
```


![Schéma des services](docs/schema_services_0.1.png)


## Utilisation

- rapatrier le dépôt
- se placer dans le répertoire du dépôt
- créer un fichier   `.env` (copier ou s'inspirer des fichiers `.env` exemples)
- créer les fichiers de configuration (vous pouver copier les fichiers de config *vide* d'un seul coup avec la commande `./scrits/init_applications_config.sh`)
- lancer les dockers avec la commande `docker compose up -d`
- les logs sont accessibles avec la commande `docker compose logs -f` ou `docker compose -f <nom du service>`

## Configuration

Il y a deux moyen pour configurer les applications: les fichiers de configuration et les variables d'environnement.

### Dossiers et fichiers

Par défaut, la structure des fichiers est la suivante

```
    -
        - db/
            - postgres (volume (ou point de montage ??) pour la bdd ())
        - apps/
            - taxhub/
                - config/
                    - config.py
                - static/
            - geonature/
                - config/
                    - geonature_config.toml
                - media/
            - usershub/
                - config/
                    - config.py
            - atlas/
                - config/
                    - config.py
                - custom/

```

Voir la documentation des différentes applications pour renseigner les fichiers de configuration

- [fichier exemple pour GeoNature](./sources/GeoNature/config/geonature_config.toml.sample)
  - Il faut au moins renseigner la variable `SECRET_KEY`.
- [fichier exemple pour UsersHub](./sources/UsersHub/config/config.py.sample)
- [fichier exemple pour TaxHub](./sources/TaxHub/apptax/config.py.sample)
<<<<<<< HEAD
- [fichier exemple pour GeoNature-atlas](./sources/GeoNature-atlas/atlas/configuration/config.py.sample)
=======
- [fichier exemple pour Geonature-atlas](./sources/GeoNature-atlas/atlas/configuration/config.py.sample )
>>>>>>> geonature atlas wip

à noter que certaines variables seront fournies en tant que variables d'environnement (voir les fichiers [docker-compose](./docker-compose.yml))

comme par exemple:
  - `URL_APPLICATION`
  - `SQLALCHEMY_DATABASE_URI`
  - ...
### Variables d'environnement

Ces variable peuvent être définie dans un fichier `.env`.

#### Configuration des applications

Il est possible de passer par les variables d'environnemnt pour configurer les applications.

Par exemple toutes les variables préfixée par `GEONATURE_` seront traduite par un configuration de l'application GéoNature (`USERSHUB_` pour usershub, et `TAXHUB_` pour taxhub) (voir https://flask.palletsprojects.com/en/2.2.x/api/#flask.Config.from_prefixed_env).

Par exemple:
- `GEONATURE_SQLALCHEMY_DATABASE_URI` pour `app.config['SQLALCHEMY_DATABASE_URI']`
- `GEONATURE_CELERY__broker_url` pour `app.config['GEONATURE_CELERY']['broker_url]`

#### Configuration des services

Les variable d'environnement qui servent au fichier docker-compose seront préfixées `GDS_` (comme GeoNature-Docker-Services)

`GDS_<nom_de_lavariable>` (`<valeur par defaut`)

##### Les images docker des applications
- `GDS_USERSHUB_IMAGE` (`ghcr.io/pnx-si/usershub:latest`)
- `GDS_TAXHUB_IMAGE` (`ghcr.io/pnx-si/taxhub:latest`)
- `GDS_GEONATURE_FRONTEND_IMAGE` (`ghcr.io/pnx-si/taxhub:latest`)
- `GDS_GEONATURE_BACKEND_IMAGE` (`ghcr.io/pnx-si/geonature-backend:latest`)
- `GDS_GEONATURE_FRONTEND_IMAGE` (`ghcr.io/pnx-si/geonature-frontend:latest`)

##### L'emplacement des volumes

`GDS_<nom_de_lavariable>` (`<valeur par defaut`) : `<point de montage dans le docker>`


##### Dossiers de Configuration

- `GDS_GEONATURE_CONFIG_DIRECTORY` (`./data/apps/geonature/config`) : `/dist/config`
- `GDS_USERSHUB_CONFIG_DIRECTORY` (`./data/apps/usershub/config`) : `/dist/config`
- `GDS_TAXHUB_CONFIG_DIRECTORY` (`./data/apps/taxhub/config`) : `/dist/config`

##### Dossiers persistants

- `GDS_GEONATURE_MEDIA_DIRECTORY` (`./data/apps/geonature/media`) : `/dist/media`
- `GDS_TAXHUB_STATIC_DIRECTORY` (`./data/apps/taxhub/static`) : `/dist/static`
- `GDS_POSTGRES_DIRECTORY` (`./data/db/postgres`): `/var/lib/postgresql/data`

##### Réseaux

- `GDS_HTTP_PORT` (`80`)
- `GDS_HTTPS_PORT`(`403`)

- `GDS_USERSHUB_HOST`
- `GDS_USERSHUB_PROTOCOL`
- `GDS_USERSHUB_DOMAIN`
- `GDS_USERSHUB_PREFIX` (`/usershub`)

- `GDS_TAXHUB_HOST`
- `GDS_TAXHUB_PROTOCOL`
- `GDS_TAXHUB_DOMAIN`
- `GDS_TAXHUB_PREFIX` (`/taxhub`)

- `GDS_GEONATURE_DOMAIN`

- `GDS_GEONATURE_BACKEND_HOST`
- `GDS_GEONATURE_BACKEND_PROTOCOL`
- `GDS_GEONATURE_BACKEND_PREFIX` (`/geonature/api`)

- `GDS_GEONATURE_FRONTEND_HOST`
- `GDS_GEONATURE_FRONTEND_PROTOCOL`
- `GDS_GEONATURE_FRONTEND_PREFIX` (`/geonature/api`)


#### Exemples de configurations

`GDS_<nom_de_lavariable>` (`<valeur par defaut`)

- env.dev
    - utilise les images docker des application taggées en `:develop`
    - protocole `HTPP`
    - url des applications suffixées par `:<PORT>` (par exemple `localhost:8000` pour le service `geonature-backend`)
    - ports `8081/8183`

- env.current
    - similaire à env.dev
    - on build les images pour GeoNature (`FRONTEND` et `BACKEND`) (voir [build_geonature_all.sh](./build/build_geonature_all.sh)
      - à partir du code des sous-modules github
      - pour GeoNature seul
      - pour GeoNature avec les 4 modules principaux (`IMPORT`, `EXPORT`, `DASHBOARD`, `MONITORING`)
    - pour `UH` et `TH` on utilise (`:latest`)
      - TODO builder les applis à partir du code des sous-modules github
    - permet de pouvoir builder des images aux versions souhaitées (pour GeoNature et les modules) sans dépendre des versions releasées.
##### `env.prod`
- utilise les images docker des application taggées en `:latest`
    - `ghcr.io/pnx-si/geonature-backend:latest`
    - `ghcr.io/pnx-si/usershub:latest`
    - `ghcr.io/pnx-si/taxhub-backend:latest`
- protocole `HTTPS`
- ports `80/443`

##### `env.dev`
- utilise les images docker des application taggées en `:develop`
- protocole `HTPP`
- url des applications suffixées par `:<PORT>` (par exemple `localhost:8000` pour le service `geonature-backend`)
- ports `8081/8183`

##### `env.current`
- similaire à env.dev
- on peut construire en local les images pour GeoNature (`FRONTEND` et `BACKEND`) (voir [build_geonature_all.sh](./build/build_geonature_all.sh)
    - à partir du code des sous-modules github
    - pour GeoNature seul
    - pour GeoNature avec les 4 modules principaux (`IMPORT`, `EXPORT`, `DASHBOARD`, `MONITORING`)
- pour `UH` et `TH` on utilise (`:latest`)
- permet de pouvoir builder des images aux versions souhaitées (pour GeoNature et les modules) sans dépendre des versions releasées.
- **TODO** construite aussi les images des autres applications (UsersHub, TaxHub)

##### `env.lattest-versions`

Permet de référencer les version de tags des dernières applications (équivalent à lattest mais avec des numéro de version codées en *dur*)

À titre informatif, il y a aussi les version des applicaitons et des modules utilisés.

Ces version sont aussi renseignées dans [le fichier changelog du dépôt)[./docs/changelog.md]

### Liens utiles
## Geonature

https://github.com/PnX-SI/GeoNature

- [`Dockerfile` backend](https://github.com/PnX-SI/GeoNature/blob/master/backend/Dockerfile)
- [`Dockerfile` frontend](https://github.com/PnX-SI/GeoNature/blob/master/frontend/Dockerfile)

- [`Dockerfile` backend + 4 modules](./build/Dockerfile-geonature-backend)
- [`Dockerfile` frontend + 4 modules](./build/Dockerfile-geonature-frontend)


## UsersHub

https://github.com/PnX-SI/UsersHub

- [`Dockerfile`](https://github.com/PnX-SI/UsersHub/blob/master/Dockerfile)


#### TaxHub

https://github.com/PnX-SI/Taxhub

- [`Dockerfile`](https://github.com/PnX-SI/TaxHub/blob/master/Dockerfile)


## Package et versionnement

Une actions permet la publication d'image dockers sur les packages du dépôt.

- `gds-geonature-4-modules-frontend:<VERSION>`
- `gds-geonature-4-modules-backend:<VERSION>`
- `gds-geonature-backend:<VERSION>`
- `gds-geonature-frontend:<VERSION>`

La valeur de `VERSION` est calculée comme ceci:

Si le build a été fait:
- depuis une branche on lui donne le nom de la branche (du dépôt courrant), on aura alors
   - `develop`: version en cours de développement
   - `main`: correspond en gros à la dernière release

- depuis un tag ou une release, on aura alors:
  - `<VERSION du dépôt courrant>__<VERSION de GeoNature>`
  - par exemple 
    - `0.0.1__2.12.3`
    - `0.0.2__2.12.3`
    - `0.0.3__2.13.1`

    - et `latest` qui correspond à la dernière release buildée

On suppose ici qu'une version ne va comporter que des états versionnées de GéoNature et de ses modules.
