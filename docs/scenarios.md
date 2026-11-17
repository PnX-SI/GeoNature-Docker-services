# Différents scénarios d'installation

Il est possible de déployer la stack GeoNature de plusieurs manières différentes. La configuration par défaut est pensée
pour
être autosuffisante, toutefois, dans le cas où vous voulez connecter cette stack à des outils déjà existant dans votre
SI, plusieurs scénarios sont possibles.

Si vous êtes dans un cas basique, referez vous à [la section démarrage rapide](./home.md?id=démarrage-rapide) .

### Reverse Proxy externe

Si vous voulez utiliser votre propre Reverse Proxy (Apache, Nginx, ...), rendez vous sur [la section Reverse Proxy externe](./proxy.md).

- Utiliser Traefik en HTTP, par exemple sur le port 8080:
    - `COMPOSE_FILE` ne doit pas contenir `docker-compose.traefik-https.yml`
    - Définissez `TRAEFIK_HTTP_PORT=8080`
    - Définissez `BASE_PROTOCOL=https` (ou `http` si votre reverse proxy ne gère pas l’HTTPS) et `BASE_PORT=` (vide,
      sauf si port exotique différent de 80 en http ou 443 en https)
    - Assurez vous que `GEONATURE_BACKEND_PREFIX`, `GEONATURE_FRONTEND_PREFIX` et `USERSHUB_PREFIX` vous convienne
    - Votre Reverse Proxy doit transmettre le trafic de votre domaine vers `http://127.0.0.1:8080`.
    - TODO: Traefik doit truster le Reverse Proxy pour présenter la bonne IP de l’utilisateur

### Base de données déportée

Si vous préférez stocker les données dans un SGBD externe, vous devez enlevez `docker-compose.postgres.yml` de la
variable `COMPOSE_FILE`.
Il faudra ensuite renseigner les informations de connexion à votre base de données à travers les variables suivantes :
`POSTGRES_HOST`, `POSTGRES_PORT` (si différent de 5432), `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.

### Service UsersHub déjà existant

Si pour d'autres besoins, vous disposez déjà d'un service UsersHub, vous devrez enlever le profil `usershub` de la
variable `COMPOSE_PROFILES`.

### Plusieurs instances de GDS sur le même serveur

Il existe de multiples façons de lancer plusieurs instances (stack) de GDS sur le même serveur. Dans tous les cas,
assurez-vous de définir dans votre `.env` la variable `COMPOSE_PROJECT_NAME` à des valeurs distincts pour chaque
instance.

- Pour des instances de développement, vous pouvez lancer Traefik sur des ports distincts en utilisant différentes
  valeurs pour la variable `TRAEFIK_HTTP_PORT`.
- Pour la production, vous ne pouvez nécessairement avoir qu’un seul serveur web en écoute sur les ports 80 et 443. Dans
  ce cas, il est conseillé d'utiliser un Reverse Proxy externe. Lancer vos deux stacks avec Traefik en HTTP sur deux
  ports distincts, et utilisez un Reverse Proxy pour rediriger le trafic sur l’une ou l’autre stack. Pour plus de détails
  rendez vous sur [la section Reverse Proxy externe](./proxy.md).

