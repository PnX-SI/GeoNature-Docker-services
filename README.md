# GeoNature Docker Services

Ce dépôt permet de déployer GeoNature, UsersHub et TaxHub dans un environnement dockerisé.
De plus, celui-ci fournit une image Docker de GeoNature contenant, outre les modules du cœur (OccTax, OccHab, Validation), les modules suivants :

- [Import](https://github.com/PnX-SI/gn_module_import)
- [Export](https://github.com/PnX-SI/gn_module_exports)
- [Dashboard](https://github.com/PnX-SI/gn_module_dashboard)
- [Monitorings](https://github.com/PnX-SI/gn_module_monitorings)


## Démarrage rapide

- Installer Docker : [voir la documentation](https://docs.docker.com/engine/install/)
- Ajouter votre utilisateur courant au groupe `docker` : `sudo usermod -aG docker $USER` puis réouvrir sa session Linux ([voir la documentation](https://docs.docker.com/engine/install/linux-postinstall))
- Clôner le dépôt : `git clone https://github.com/PnX-SI/GeoNature-Docker-services` ou extraire une [archive](https://github.com/PnX-SI/GeoNature-Docker-services/releases)
- Se placer dans le répertoire du dépôt : `cd GeoNature-Docker-services`
- Créer le fichier `.env` à partir du fichier d’exemple : `cp .env.sample .env`. Compléter les paramètres importants.
- Lancer la commande `./init-config.sh` afin de créer les ficiers de configuration suivant, avec des clés secrètes générées aléatoirement :
  - `config/geonature/geonature_config.toml`
  - `config/usershub/config.py`
  - `config/taxhub/config.py`
- Lancer les conteneurs : `docker compose up -d`

Les logs sont accessibles avec la commande `docker compose logs -f` ou `docker compose -f <nom du service>`.


## Les services

 - `postgres` : la base de données
 - `usershub` : la gestion des utilisateurs
 - `taxhub` : la gestion du référentiel taxonomique
 - `geonature-backend` : l’API de GeoNature
 - `geonature-frontend` : l’interface web de GeoNature
 - `geonature-worker`: exécution de certaines tâches de geonature en arrière plan (import, export, mail, etc...)
 - `redis` : service de communication entre le worker et le backend
 - `traefik` : serveur web redirigant les requêtes vers le bon service

```
SERVICE              PORTS
geonature-backend    8000/tcp
geonature-frontend   80/tcp
geonature-worker     8000/tcp
postgres             0.0.0.0:5435->5432/tcp, :::5435->5432/tcp
redis                6379/tcp
taxhub               5000/tcp
traefik              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, [::]:80->80/tcp, [::]:443->443/tcp
usershub             5001/tcp
```

![Schéma des services](docs/schema_services_0.1.png)


## Configuration

Voir la documentation des différentes applications pour renseigner les fichiers de configuration :

- GeoNature : `./config/geonature/geonature_config.toml` ([fichier d’exemple](https://github.com/PnX-SI/GeoNature/tree/master/config/geonature_config.toml.sample))
- UsersHub : `./config/usershub/config.py` ([fichier d’exemple](https://github.com/PnX-SI/UsersHub/tree/master/config/config.py.sample))
- TaxHub : `./config/taxhub/config.py` ([fichier d’exemple](https://github.com/PnX-SI/TaxHub/apptax/config.py.sample))

Ces fichiers doivent contenir *a minima* le paramètre `SECRET_KEY`.
Vous pouvez générer des fichiers vierges contenant des clés secrètes aléatoire avec le script `./init-config.sh`.

À noter que certaines variables seront fournies en tant que variables d'environnement (voir les fichiers [`.env`](./.env.sample) et [`docker-compose.yml`](./docker-compose.yml)), comme par exemple:
  - `URL_APPLICATION`
  - `SQLALCHEMY_DATABASE_URI`
  - ...


### Configuration par variable d’environnement

Les applications peuvent être configurées par des variables d’environnement préfixée respectivement par `GEONATURE_`, `TAXHUB_` et `USERSHUB_` (voir [from_prefix_env](https://flask.palletsprojects.com/en/2.2.x/api/#flask.Config.from_prefixed_env)).
Ces variables d’environnement doivent être renseigné directement dans le fichier `docker-compose.yml`, bien que certaines variables sont définies à partir d’une variable du même nom en provenance du fichier `.env`.

## Images publiées

Une actions permet la publication d'image frontend et backend dockers sur [les packages du dépôt](https://github.com/orgs/PnX-SI/packages?repo_name=GeoNature-Docker-services] :

- `ghcr.io/pnx-si/geonature-frontend-extra`
- `ghcr.io/pnx-si/geonature-backend-extra`

Ces images sont le pendant de [celles publiées sur le dépôt de GeoNature](https://github.com/orgs/PnX-SI/packages?repo_name=GeoNature) mais contiennent en supplément les modules externes pré-cités en introduction.


## Liens utiles

### Geonature

- [Dépôt](https://github.com/PnX-SI/GeoNature)
- [`Dockerfile` backend](https://github.com/PnX-SI/GeoNature/blob/master/backend/Dockerfile)
- [`Dockerfile` frontend](https://github.com/PnX-SI/GeoNature/blob/master/frontend/Dockerfile)
- [`Dockerfile` backend-extra](./build/Dockerfile-geonature-backend)
- [`Dockerfile` frontend-extra](./build/Dockerfile-geonature-frontend)


### UsersHub

- [Dépôt](https://github.com/PnX-SI/UsersHub)
- [`Dockerfile`](https://github.com/PnX-SI/UsersHub/blob/master/Dockerfile)


### TaxHub

- [Dépôt](https://github.com/PnX-SI/Taxhub)
- [`Dockerfile`](https://github.com/PnX-SI/TaxHub/blob/master/Dockerfile)


