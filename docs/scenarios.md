# Différents scénarios d'installation

Il est possible de déployer la stack GeoNature de plusieurs manières différentes. La configuration par défaut est pensée
pour
être autosuffisante, toutefois, dans le cas où vous voulez connecter cette stack à des outils déjà existant dans votre
SI, plusieurs scénarios sont possibles.

### Reverse Proxy externe

Si vous voulez utiliser votre propre Reverse Proxy (Apache, Nginx, ...), vous pouvez au choix :

- Utiliser Traefik en HTTP sur le port par exemple 8080 :
    - `COMPOSE_FILE` doit contenir `docker-compose.traefik.yml` mais pas `docker-compose.traefik-https.yml`
    - Définissez `TRAEFIK_HTTP_PORT=8080`
    - Définissez `BASE_PROTOCOL=https` (ou `http` si votre reverse proxy ne gère pas l’HTTPS) et `BASE_PORT=` (vide,
      sauf si port exotique différent de 80 en http ou 443 en https)
    - Assurez vous que `GEONATURE_BACKEND_PREFIX`, `GEONATURE_FRONTEND_PREFIX` et `USERSHUB_PREFIX` vous convienne
    - Votre Reverse Proxy doit transmettre le trafic de votre domaine vers `http://127.0.0.1:8080`.
    - TODO: Traefik doit truster le Reverse Proxy pour présenter la bonne IP de l’utilisateur

- Désactiver complétement Traefik :
    - `COMPOSE_FILE` ne doit contenir ni `docker-compose.traefik.yml`, ni `docker-compose.traefik-https.yml`, et les
      variables correspondantes doivent être commentées.
    - Votre Reverse Proxy doit alors transmettre :
        - `/api` vers `http://127.0.0.1:8000/api` (configurable via `GEONATURE_BACKEND_PREFIX` et
          `GEONATURE_BACKEND_PORT`)
        - `/usershub` vers `http://127.0.0.1:5001/usershub` (configurable via `USERSHUB_PREFIX` et `USERSHUB_PORT`)
        - `/` vers `http://127.0.0.1:4200` (configurable via `GEONATURE_FRONTEND_PREFIX` et `GEONATURE_FRONTEND_PORT`)

### Base de données déportée

Si vous préférez stocker les données dans un SGBD externe, vous devez enlevez `docker-compose.postgres.yml` de la
variable `COMPOSE_FILE`.
Il faudra ensuite renseigner les informations de connexion à votre base de données à travers les variables suivantes :
`POSTGRES_HOST`, `POSTGRES_PORT` (si différent de 5432), `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.

### Service UsersHub déjà existant

Si pour d'autres besoins, vous disposez déjà d'un service UsersHub, vous devrez enlever le profil `usershub` de la
variable `COMPOSE_PROFILES`.

## Plusieurs instances de GDS sur le même serveur

Il existe de multiples façons de lancer plusieurs instances (stack) de GDS sur le même serveur. Dans tous les cas,
assurez-vous de définir dans votre `.env` la variable `COMPOSE_PROJECT_NAME` à des valeurs distincts pour chaque
instance.

- Pour des instances de développement, vous pouvez lancer Traefik sur des ports distincts en utilisant différentes
  valeurs pour la variable `TRAEFIK_HTTP_PORT`.
- Pour la production, vous ne pouvez nécessairement avoir qu’un seul serveur web en écoute sur les ports 80 et 443. Dans
  ce cas, vous pouvez :
    - Utilisez un Reverse Proxy externe. Lancer vos deux stacks avec Traefik en HTTP sur deux ports distincts, et
      utilisez votre Reverse Proxy pour rediriger le trafic sur l’une ou l’autre stack.
    - Activer Traefik uniquement sur votre première stack. Pour l’ensemble des stacks, utilisez le fichier
      `override_gallery/docker-compose.additional_stack.yml`. Celui permet d’éviter les conflits de label entre les
      différentes stacks. Par ailleur, pour la première stack qui fait tourner Traefik, celui-ci supprime le filtre le
      limitant à sa propre stack afin qu’il serve également les services des autres stacks.
