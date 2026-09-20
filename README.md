# GeoNature Docker services

Ce dépôt permet de déployer automatiquement et facilement GeoNature, UsersHub dans un environnement dockerisé et accessible en HTTPS.

## Principes et objectifs

**1. GeoNature clé en main**

Un fichier de configuration et une commande suffisent à déployer et mettre à jour facilement un environnement GeoNature dockerisé, fonctionnel et complet (GeoNature et ses principaux modules)

**2. Modulaire et adaptable**

Doit permettre à chacun d'adapter le projet pour ses besoins spécifiques et son infrastructure.

**3. Limiter la complexité globale**

Le projet ne doit pas inclure de fonctionnalités trop spécifiques à un contexte. L'ajout de fonctionnalités (paramètres, makefile...) ne doit pas se substituer à une maitrise de Docker, GeoNature ou d'administration système.

## Démarrage rapide

1. **Installation de Docker** ([Voir la documentation](https://docs.docker.com/engine/install/))
2. **Ajout de votre utilisateur courant au groupe `docker`**
   - Ajouter votre utilisateur courant dans le groupe docker : `sudo usermod -aG docker USER`
   - Réouvrir sa session Linux pour appliquer les changements
   - Plus d'infos sur la [documentation officielle](https://docs.docker.com/engine/install/linux-postinstall)

3. **Installation de `git`**
   - `sudo apt-get install git`

4. **Clonage du dépôt de GeoNature-Docker-services** : `git clone https://github.com/PnX-SI/GeoNature-Docker-services` ou extraire une [archive](https://github.com/PnX-SI/GeoNature-Docker-services/releases)

5. **Déplacement dans le répertoire du dépôt** : `cd GeoNature-Docker-services`

6. **Création du fichier `.env` à partir du fichier d’exemple** : `cp .env.sample .env`.

7. **Changement des variables de configurations obligatoires dans le fichier `.env`**. Les variables obligatoires sont les suivantes :
   - `GEONATURE_DB_LOCAL_SRID` : Code des projections des géométries stockées dans GeoNature (par défaut 2154)
   - `POSTGRES_PASSWORD` : Mot de passe de la base de données [PostgreSQL](https://www.postgresql.org/)
   - `UID` et `GID` : Indique l'utilisateur utilisé par les conteneurs. Utiliser la commande `id -u` pour récupérer la valeur pour `UID` et `id -g` pour récupérer la valeur pour `GID`
   - `COMPOSE_FILE` : Indique les fichiers compose que vous souhaitez utiliser.
    - `docker-compose.postgres.yml` : À désactiver pour utiliser une base de données externe (voir section dédiée).
    - `docker-compose.traefik.yml` : À activer pour utiliser traefik et servir GeoNature et UsersHub derrière un même port. Dans ce cas, vous devez renseigner également `TRAEFIK_HTTP_PORT` (laisser vide pour utiliser le port 80, mais la variable doit être impérativement définie), `GEONATURE_BACKEND_PREFIX`, `GEONATURE_FRONTEND_PREFIX` et `USERSHUB_PREFIX`.
    - `docker-compose.traefik-https.yml` : À activer pour que traefik écoute également en HTTPS. Dans ce cas vous devez également renseigner `TRAEFIK_HTTPS_PORT` (laisser vide pour utiliser le port  443, mais la variable doit impérativement être définie). Vous devez également définir `ACME_EMAIL` pour que soit générer des certificats SSL valides par [Let's Encrypt](https://letsencrypt.org/fr/).
    - `docker-compose.dev.yml`: À activer pour le développement (voir section dédiée).

- Pour éviter les mise à jour inattendues, il est recommandé de décommenter les variables `GEONATURE_BACKEND_IMAGE`, `GEONATURE_FRONTEND_IMAGE` et `USERSHUB_IMAGE` et de remplacer `latest` par le numéro de version à utiliser.

  Vous pouvez à tout moment vérifier la configuration finale avec `docker compose config`.

1. **Initialisation des fichiers de configurations.** Lancer la commande `./init-config.sh` afin de créer les dossiers et les fichiers de configuration requis. Le script `init-config.sh` génère aléatoirement aussi les clés secrètes pour GeoNature et UsersHub respectivement dans les fichiers suivants :
   - `config/geonature/geonature_config.toml`
   - `config/usershub/config.py`

2. **Lancer la création des conteneurs Docker** : `docker compose up -d`

## Accéder aux logs

Les logs de tous les services sont accessibles avec la commande `docker compose logs -f`.

Pour n'afficher que les 100 dernières lignes, on utilise l'option `--tail 100` et donc la commande `docker compose logs -f --tail 100`.

Pour n'afficher les logs que d'un service en particulier, on utilise la commande `docker compose logs -f <nom du service>`.

## Exécuter la commande `geonature`

Utilisez `docker compose exec -it geonature-backend /entrypoint.sh geonature --help`

Pour faciliter l’accès à la commande `geonature`, vous pouvez utiliser [`direnv`](https://direnv.net/). Une fois installé, lancé `direnv allow` dans le dossier GeoNature-Docker-services. Le dossier `bin` sera alors automatiquement ajouter à votre `PATH` lorsque vous rentrez dans le dossier, et vous pourrez alors exécuter la commande `geonature` directement.

## Les services

- `postgres` : la base de données
- `usershub` : la gestion des utilisateurs
- `geonature-backend` : l’API de GeoNature
- `geonature-frontend` : l’interface web de GeoNature
- `geonature-worker` : exécution de certaines tâches de GeoNature en arrière-plan (import, export, mail, etc...)
- `redis` : service de communication entre le worker et le backend
- `traefik` : serveur web redirigeant les requêtes vers le bon service

```
SERVICE              PORTS
geonature-backend    8000/tcp
geonature-frontend   80/tcp
geonature-worker     8000/tcp
postgres             0.0.0.0:5435->5432/tcp, :::5435->5432/tcp
redis                6379/tcp
traefik              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, [::]:80->80/tcp, [::]:443->443/tcp
usershub             5001/tcp
```

![Schéma des services](docs/schema_services_0.1.png)

## Différents scénarios d'installation

Il est possible de déployer la stack GeoNature de plusieurs manières différentes. La configuration par défaut est pensée pour
être autosuffisante, toutefois, dans le cas où vous voulez connecter cette stack à des outils déjà existant dans votre
SI, plusieurs scénarios sont possibles.

#### Reverse Proxy externe

Si vous voulez utiliser votre propre Reverse Proxy (Apache, Nginx, ...), vous pouvez au choix :

- Utiliser Traefik en HTTP sur le port par exemple 8080 :
  - `COMPOSE_FILE` doit contenir `docker-compose.traefik.yml` mais pas `docker-compose.traefik-https.yml`
  - Définisez `TRAEFIK_HTTP_PORT=8080` (et assurez-vous que `TRAEFIK_HTTPS_PORT` soit commenté)
  - Assurez vous que `GEONATURE_BACKEND_PREFIX`, `GEONATURE_FRONTEND_PREFIX` et `USERSHUB_PREFIX` vous convienne
  - Votre Reverse Proxy doit transmettre le trafic de votre domaine vers `http://127.0.0.1:8080`.
  - TODO: Traefik doit truster le Reverse Proxy pour présenter la bonne IP de l’utilisateur

- Désactiver complétement Traefik :
  - `COMPOSE_FILE` ne doit contenir ni `docker-compose.traefik.yml`, ni `docker-compose.traefik-https.yml`, et les variables correspondantes doivent être commentées.
  - Votre Reverse Proxy doit alors transmettre :
    - `/api` vers `http://127.0.0.1:8000/api` (configurable via `GEONATURE_BACKEND_PREFIX` et `GEONATURE_BACKEND_PORT`)
    - `/usershub` vers `http://127.0.0.1:5001/usershub` (configurable via `USERSHUB_PREFIX` et `USERSHUB_PORT`)
    - `/` vers `http://127.0.0.1:4200` (configurable via `GEONATURE_FRONTEND_PREFIX` et `GEONATURE_FRONTEND_PORT`)

#### Base de données déportée

Si vous préférez stocker les données dans un SGBD externe, vous devez enlevez `docker-compose.postgres.yml` de la variable `COMPOSE_FILE`.
Il faudra ensuite renseigner les informations de connexion à votre base de données à travers les variables suivantes : `POSTGRES_HOST`, `POSTGRES_PORT` (si différent de 5432), `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.

#### Service UsersHub déjà existant

Si pour d'autres besoins, vous disposez déjà d'un service UsersHub, vous devrez enlever le profil `usershub` de la variable `COMPOSE_PROFILES`.

## Configuration

Voir la documentation des différentes applications pour renseigner les fichiers de configuration :

- GeoNature : `./config/geonature/geonature_config.toml` ([fichier d’exemple](https://github.com/PnX-SI/GeoNature/tree/master/config/geonature_config.toml.sample))
- UsersHub : `./config/usershub/config.py` ([fichier d’exemple](https://github.com/PnX-SI/UsersHub/tree/master/config/config.py.sample))

Ces fichiers doivent contenir _a minima_ le paramètre `SECRET_KEY`.  
Vous pouvez générer automatiquement des fichiers vierges contenant des clés secrètes aléatoires avec le script `./init-config.sh`.

Si vous modifiez les fichiers de configuration de GeoNature, d'un de ses modules, de UsersHub, vous devez relancer les conteneurs Docker avec la commande `docker compose restart` (ou idéalement seulement le conteneur concerné, par exemple `docker compose restart usershub`).

À noter que certaines variables seront fournies en tant que variables d'environnement (voir les fichiers [`.env`](./.env.sample) et [`docker-compose.yml`](./docker-compose.yml)), comme par exemple :

- `URL_APPLICATION`
- `SQLALCHEMY_DATABASE_URI`
- ...

Vous pouvez personnaliser la [politique de redémarrage automatique des services](https://github.com/compose-spec/compose-spec/blob/master/spec.md#restart) en paramétrant la variable `RESTART_POLICY` du fichier `.env` (valeur par défaut: `unless-stopped`)

Il est aussi possible de personnaliser son installation en créant un fichier d'override de docker compose. Pour le détail
de fonctionnement, voir la section [Surcharger son installation](#override).

### Dossiers de configuration et de customisation

- Les fichiers de configuration de GeoNature, de ses modules et de UsersHub sont donc dans le dossier `GeoNature-Docker-services/config/`
- Les fichiers de customisation de GeoNature sont stockés dans le dossier `GeoNature-Docker-services/data/geonature/custom/`
- Les fichiers des médias de GeoNature (photos, application mobile...) sont stockés dans le dossier `GeoNature-Docker-services/data/geonature/media/`

### Configuration par variable d’environnement

Les applications peuvent être configurées par des variables d’environnement préfixées respectivement par `GEONATURE_` et `USERSHUB_` (voir [from_prefix_env](https://flask.palletsprojects.com/en/2.2.x/api/#flask.Config.from_prefixed_env)).
Si vous souhaitez définir de nouvelles variables d’environnement, il est recommandé de les définir dans un fichier `docker-compose.override.yml` (voir [Surcharger son installation](#override)).

## Mettre à jour GeoNature et ses modules

1. Éditez le tag des variables `GEONATURE_BACKEND_IMAGE`, `GEONATURE_FRONTEND_IMAGE` et `USERSHUB_IMAGE`. Si vous n’avez pas définie ces variables, ou si vous utilisez le tag `latest` (par défaut), vous devez explicitement demander à docker de mettre à jour les images : `docker compose pull`
2. Relancer les services : `docker compose up -d`

## Monitoring

### Installer un sous-module

1. Déposer le dossier contenant la configuration du protocole dans `data/geonature/media/monitorings/`. Par exemple, lorsque vous avez récupéré le dépôt [protocoles_suivi](https://github.com/PnX-SI/protocoles_suivi/) :

   ```sh
   cp -r protocoles_suivi/chiro data/geonature/media/monitorings/chiro
   ```

2. Lancer l'installation du sous-module avec la commande :

   ```sh
   docker compose exec geonature-backend geonature monitorings install <nom_sous_module>
   ```

### Modifier ou mettre à jour le sous-module

Si vous souhaitez modifier le sous-module, faites le directement dans les fichiers du dossier du sous-module dans `data/geonature/media/monitorings/`.

### Exécuter une commande Monitoring

Pour des actions plus avancées, vous pouvez vous attacher au Docker avec la commande `docker compose exec geonature-backend bash` et
suivre la [documentation du module Monitoring](https://github.com/PnX-SI/gn_module_monitoring/blob/main/docs/commandes.md)

## <a name="override"></a> Surcharger son installation

En fonction de l'environnement dans lequel vous déployez, il est possible que vous soyez amené à vouloir modifier le
fichier `docker-compose.yml` afin de personnaliser le comportement de GDS. Afin de pouvoir mettre à jour votre repo, il
est fortement conseillé de passer par un fichier d'override (voir [documentation docker compose sur les overrides](https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/)).
Pour cela, vous pouvez créer un fichier `docker-compose.override.yml` qui contient les modifications que vous souhaitez apporter à la stack et l'ajouter à votre variable d'environnement
`COMPOSE_FILE` (voir [documentation docker](https://docs.docker.com/compose/how-tos/environment-variables/envvars/#compose_file))

Vous pouvez vérifier après modification de votre `.env` ou de votre fichier `docker-compose.override.yml` la configuration effective de docker compose avec la commande `docker compose config`.

Plusieurs exemples de surcharge sont disponibles dans le dossier `override_gallery`. Ce dossier contient des fichiers `compose.yml` testés
pour une version précise de GDS et permettant de modifier la configuration de GDS ou de déployer des services supplémentaires.

## Lancer plusieurs instances de GDS sur le même serveur

Il existe de multiples façons de lancer plusieurs instances (stack) de GDS sur le même serveur. Dans tous les cas, assurez-vous de définir dans votre `.env` la variable `COMPOSE_PROJECT_NAME` à des valeurs distincts pour chaque instance.

- Pour des instances de développement, vous pouvez lancer Traefik sur des ports distincts en utilisant différentes valeurs pour la variable `TRAEFIK_HTTP_PORT`.
- Pour la production, vous ne pouvez nécessairement avoir qu’un seul serveur web en écoute sur les ports 80 et 443. Dans ce cas, vous pouvez :
  - Utilisez un Reverse Proxy externe. Lancer vos deux stacks avec Traefik en HTTP sur deux ports distincts, et utilisez votre Reverse Proxy pour rediriger le trafic sur l’une ou l’autre stack.
  - Activer Traefik uniquement sur votre première stack. Pour l’ensemble des stacks, utilisez le fichier `override_gallery/docker-compose.additional_stack.yml`. Celui permet d’éviter les conflits de label entre les différentes stacks. Par ailleur, pour la première stack qui fait tourner Traefik, celui-ci supprime le filtre le limitant à sa propre stack afin qu’il serve également les services des autres stacks.

## FAQ

Pour en savoir plus (lancer des commandes `geonature`, accéder à la BDD, intégrer le MNT, modifier votre domaine,...), consultez la [FAQ GeoNature-Docker-services](/docs/faq.md).

Pour des informations spécifiques sur le mode développement, voir la section [Lancer une instance de développement](#dev) et sa propre [FAQ de développement](docs/dev-faq.md).

## <a name="dev"></a> Lancer une instance de développement

1. Commencez par vous assurer d'avoir installé make, jq et git-lfs : `sudo apt install make jq git-lfs openssl`.

1. Initialisez le sous-module `GeoNature-images` :

    ```
   git submodule update --init --recursive --depth 1 --remote
   ```

1. Vous pouvez à présent entrer dans le dossier `GeoNature-images` et consulter son README afin de suivre la procédure de création des images. En théorie, celle-ci se résume à lancer `make docker-dev`. Vous pouvez visualiser le nom des images produites avec la commande `make docker-list-images`.
1. Dans votre fichier `.env`, ajouter `docker-compose.dev.yml` à `COMPOSE_FILE`.
1. Vérifiez le nom des images et leur tag dans les variables `GEONATURE_BACKEND_IMAGE` et `GEONATURE_FRONTEND_IMAGE`. Attention, les tags se verrons automatiquement rajouté le suffix `-dev`.
1. Relancer votre stack avec `docker compose up -d`

Vous devez rebuild vos images de dev et relancer la stack lorsque vous modifiez notamment les dépendances Python ou node.

### Exécuter les test Cypress

Vous devez avoir installé Cypress au préalable et lancé la stack.
La commande `make cypress` vous permet ensuite de lancer les tests cypress.

Si vous voulez que vos tests s'exécutent comme dans la CI Github, il faut, une base sans données saisie au préalable.
Puis, vous devez passer les migrations "samples" :

```shell
   geonature db upgrade occtax-samples-test@head
   geonature db upgrade occhab-samples@head
   geonature db upgrade import-samples@head`
```

Il est aussi possible de lancer Cypress en version headed ou avec des paramètres plus complexe en se calquant sur ce
qui est fait dans le Makefile, par exemple pour lancer cypress en headed et en spécifiant les tests liés aux forms d'occtax :

`source .env; cd sources/GeoNature/frontend; API_ENDPOINT="https://$${HOST}$${GEONATURE_BACKEND_PREFIX}/" URL_APPLICATION="https:$${HOST}$${GEONATURE_FRONTEND_PREFIX}/" cypress run --headed --spec cypress/e2e/occtax-form-spec.js`

## Liens utiles

### GeoNature

- [Dépôt](https://github.com/PnX-SI/GeoNature)
- [`Dockerfile` backend](https://github.com/PnX-SI/GeoNature/blob/master/backend/Dockerfile)
- [`Dockerfile` frontend](https://github.com/PnX-SI/GeoNature/blob/master/frontend/Dockerfile)
- [`Dockerfile` backend-extra](ttps://github.com/PnX-SI/GeoNature-images/blob/main/Dockerfile-backend)
- [`Dockerfile` frontend-extra](ttps://github.com/PnX-SI/GeoNature/blob/main/Dockerfile-frontend)

### UsersHub

- [Dépôt](https://github.com/PnX-SI/UsersHub)
- [`Dockerfile`](https://github.com/PnX-SI/UsersHub/blob/master/Dockerfile)
