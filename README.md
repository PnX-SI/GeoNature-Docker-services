# Infrastructre du projet 

L'idée de ce repository est de mettre à disposition une infrastructure du projet GeoNature. Il met en place un service 
de base de données (POSTGIS) ainsi qu'un reverse proxy (Traefik). Pour utiliser ce repository, il vous suffit de le 
cloner `git clone http://outils-patrinat.mnhn.fr/gitlab/geonature/infra-as-code.git` et de suivre les étapes 
décrites ci-après.

Le projet nécessite la mise en place de volumes et de networks docker. Pour les initialiser:
```bash
docker network create databases
docker network create web
docker volume create raw-data
```

## Base de données

Le service de base de données mis en place repose sur l'image [mdillon](https://hub.docker.com/r/mdillon/postgis/) 
reposant elle-même sur l'image officielle postgres.
Pour lancer la base de données:
```bash
cd infra-as-code/database
docker-compose -p database -f docker-compose.yml up --build
```


## Reverse proxy 
Le projet vient avec un traefik permettant de rediriger les requêtes vers les containers appropriés, notamment pour les
services usershub et taxhub.

```bash
cd infra-as-code/gateway
docker-compose -p gateway -f docker-compose.yml up --build
```
