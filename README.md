# GeoNature Docker Services

Ce dépôt permet de déployer automatiquement et facilement GeoNature, UsersHub dans un environnement dockerisé et accessible en HTTPS. De plus, celui-ci fournit une image Docker de GeoNature contenant, outre les modules du cœur (Occtax, Occhab, Validation, Import), les modules suivants :

- [Export](https://github.com/PnX-SI/gn_module_exports)
- [Dashboard](https://github.com/PnX-SI/gn_module_dashboard)
- [Monitorings](https://github.com/PnX-SI/gn_module_monitorings)

## Démarrage rapide

- Installer Docker : [voir la documentation](https://docs.docker.com/engine/install/)
- Ajouter votre utilisateur courant au groupe `docker` : `sudo usermod -aG docker $USER` puis réouvrir sa session Linux ([voir la documentation](https://docs.docker.com/engine/install/linux-postinstall))
- Installer `git` (`sudo apt-get install git`)
- Clôner le dépôt : `git clone https://github.com/PnX-SI/GeoNature-Docker-services` ou extraire une [archive](https://github.com/PnX-SI/GeoNature-Docker-services/releases)
- Se placer dans le répertoire du dépôt : `cd GeoNature-Docker-services`
- Créer le fichier `.env` à partir du fichier d’exemple : `cp .env.sample .env`. Compléter les paramètres importants (`HOST`, `ACME_EMAIL`, `GEONATURE_LOCAL_SRID`, `POSTGRES_PASSWORD`, `GID`, `UID`).
- Lancer la commande `./init-config.sh` afin de créer les fichiers de configuration suivants, avec des clés secrètes générées aléatoirement :
  - `config/geonature/geonature_config.toml`
  - `config/usershub/config.py`
- Lancer les conteneurs : `docker compose up -d`

Les logs de tous les services sont accessibles avec la commande `docker compose logs -f`.
Pour n'afficher que les 100 dernières lignes, on utilise l'option `--tail 100` et donc la commande `docker compose logs -f --tail 100`.
Pour n'afficher les logs que d'un service en particulier, on utilise la commande `docker compose logs -f <nom du service>`.

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

### Dossiers de configuration et de customisation

- Les fichiers de configuration de GeoNature, de ses modules et de UsersHub sont donc dans le dossier `GeoNature-Docker-services/config/`
- Les fichiers de customisation de GeoNature sont stockés dans le dossier `GeoNature-Docker-services/data/geonature/custom/`
- Les fichiers des médias de GeoNature (photos, application mobile...) sont stockés dans le dossier `GeoNature-Docker-services/data/geonature/media/`

### Configuration par variable d’environnement

Les applications peuvent être configurées par des variables d’environnement préfixées respectivement par `GEONATURE_` et `USERSHUB_` (voir [from_prefix_env](https://flask.palletsprojects.com/en/2.2.x/api/#flask.Config.from_prefixed_env)).  
Ces variables d’environnement doivent être renseignées directement dans le fichier `docker-compose.yml`, bien que certaines variables sont définies à partir d’une variable du même nom en provenance du fichier `.env`.

## Mettre à jour GeoNature et ses modules

- Vérifiez si la [dernière version disponible](https://github.com/PnX-SI/GeoNature-Docker-services/releases) correspond aux versions des applications que vous souhaitez mettre à jour
- Placez vous dans le dossier `GeoNature-Docker-services` de votre serveur
- Mettez à jour le contenu du dossier dans sa dernière version : `git pull`
- Changez la version de GeoNature dans les variables `GEONATURE_BACKEND_EXTRA_IMAGE`, `GEONATURE_FRONTEND_EXTRA_IMAGE`, et de UsersHub dans `USERSHUB_IMAGE` dans votre fichier `.env`. Par exemple, pour passer de la version 2.15.2 à 2.15.3, effectuez les modifications suivantes :

  ```env

  USERSHUB_IMAGE="ghcr.io/pnx-si/usershub:2.4.4"
  [...]
  GEONATURE_BACKEND_EXTRA_IMAGE="ghcr.io/pnx-si/geonature-backend-extra:2.15.3"
  [...]
  GEONATURE_FRONTEND_EXTRA_IMAGE="ghcr.io/pnx-si/geonature-frontend-extra:2.15.3"
  ```

  Pour connaître la version de UsersHub, consultez la note de version.

- Lancez la commande qui va télécharger les dernières versions des différentes applications et les relancer : `docker compose pull && docker compose up -d --remove-orphans`

## FAQ

Pour des informations spécifique sur le mode développement, voir la section [Lancer une instance de développement](#dev) et sa propre [FAQ de développement](#dev-faq). 

Pour en savoir plus (lancer des commandes `geonature`, accéder à la BDD, intégrer le MNT, modifier votre domaine,...), consultez la [FAQ GeoNature](https://github.com/PnX-SI/GeoNature-Docker-services/blob/main/docs/faq.md).

## Images Docker publiées

Une action permet la publication automatique d'images Docker frontend et backend de GeoNature sur [les packages du dépôt](https://github.com/orgs/PnX-SI/packages?repo_name=GeoNature-Docker-services) :

- `ghcr.io/pnx-si/geonature-frontend-extra`
- `ghcr.io/pnx-si/geonature-backend-extra`

Ces images sont le pendant de [celles publiées sur le dépôt de GeoNature](https://github.com/orgs/PnX-SI/packages?repo_name=GeoNature) mais contiennent en supplément les modules externes pré-cités en introduction.

## <a name="dev"></a> Lancer une instance de développement

Commencez par vous assurer d'avoir installé make, jq et git-lfs `sudo apt install make jq git-lfs openssl`.

Il faut ensuite, dans votre fichier .env décommenter les lignes de l'environnement de dev.
Une fois le fichier .env rempli correctement, il faut créer les fichiers de configuration avec `./init-config.sh`.

Une fois cela fait, il ne vous reste plus qu'à lancer `make submodule_init` suivit de `make dev`.
Il est déconseillé de lancer avec la commande `docker compose up -d` car si vous mettez à jour le projet GeoNature,
cela ne fonctionnera pas sans relancer `make dev_init`.
Le premier lancement peut mettre quelques dizaines de minutes.

Vous pouvez visiter votre GeoNature à l'adresse https://localhost/geonature et le proxy traefik http://localhost:8080/.

### Executer les test Cypress

Vous devez avoir installé Cypress au préalable et lancé la stack.
La commande `make cypress` vous permet ensuite de lancer les tests cypress.

Si vous voulez que vos tests s'exécutent comme dans la CI Github, il faut, une base sans données saisie au préalable. 
Puis, vous devez passer les migrations "samples" : 
`          
          geonature db upgrade occtax-samples-test@head
          geonature db upgrade occhab-samples@head
          geonature db upgrade import-samples@head
`

Il est aussi possible de lancer Cypress en version headed ou avec des paramètres plus complexe en se calquant sur ce 
qui est fait dans le Makefile, par exemple pour lancer cypress en headed et en spécifiant les tests liées aux forms d'occtax : 

`source .env; cd sources/GeoNature/frontend; API_ENDPOINT="https://$${HOST}$${GEONATURE_BACKEND_PREFIX}/" URL_APPLICATION="https:$${HOST}$${GEONATURE_FRONTEND_PREFIX}/" cypress run --headed --spec cypress/e2e/occtax-form-spec.js`


## <a name="dev-faq"></a> FAQ de développement

* Mon docker compose de dev ne lance pas le build des images et essaye de les chercher sur un repo à la place.

Assurez-vous de ne pas avoir activé la feature Bake de docker `COMPOSE_BAKE=true`

* J'ai une question, à qui puis-je la poser ? 

Selon la nature de votre problème, vous pouvez créer une issue sur notre GitHub ou nous contacter [sur Element](https://matrix.to/#/#geonature:matrix.org)

## Liens utiles
### GeoNature

- [Dépôt](https://github.com/PnX-SI/GeoNature)
- [`Dockerfile` backend](https://github.com/PnX-SI/GeoNature/blob/master/backend/Dockerfile)
- [`Dockerfile` frontend](https://github.com/PnX-SI/GeoNature/blob/master/frontend/Dockerfile)
- [`Dockerfile` backend-extra](./build/Dockerfile-geonature-backend)
- [`Dockerfile` frontend-extra](./build/Dockerfile-geonature-frontend)

### UsersHub

- [Dépôt](https://github.com/PnX-SI/UsersHub)
- [`Dockerfile`](https://github.com/PnX-SI/UsersHub/blob/master/Dockerfile)
