# Infrastructre du projet 

L'idée de ce repository est de mettre à disposition une infrastructure du projet GeoNature. Il met en place un service 
de base de données (POSTGIS) ainsi qu'un reverse proxy (Traefik). Pour utiliser ce repository, il vous suffit de le 
cloner et de suivre les étapes décrites ci-après.

Le projet nécessite la mise en place de volumes et de networks docker. Pour les initialiser:
```bash
docker network create databases
docker network create web
docker volume create raw-data
```

## Base de données

Le service de base de données mis en place repose sur l'image [postgis](https://registry.hub.docker.com/r/postgis/postgis/) 
reposant elle-même sur l'image officielle postgres.
Pour lancer la base de données en local:
```bash
cd database
docker-compose --env-file .env.local -p database -f docker-compose.local.yml up --build
```
Pour lancer la base de données en production:
```bash
cd database
docker-compose --env-file .env -p database -f docker-compose.yml up --build
```
Le fichier .env devra entre autres contqenir le nom de la base de données, l'utilisateur ainsi que son mot de passe. 
## Reverse proxy 
Le projet vient avec un traefik permettant de rediriger les requêtes vers les containers appropriés, notamment pour les
services usershub et taxhub.

Pour lancer le reverse proxy en local:
```bash
cd gateway
docker-compose -p gateway -f docker-compose.local.yml up --build
```


Pour lancer le reverse proxy en production:
```bash
cd gateway
docker-compose -p gateway -f docker-compose.local.yml up --build
```

