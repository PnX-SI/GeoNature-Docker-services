# GeoNature Docker Services

Dockerisation de geonature et d'application associées

## Applications

- backend
    - https://github.com/PnX-SI/GeoNature/blob/master/backend/Dockerfile

- frontend
    - https://github.com/PnX-SI/GeoNature/blob/master/frontend/Dockerfile

- publication
    - https://github.com/PnX-SI/GeoNature/blob/master/.github/workflows/docker.yml

#### UsersHub

- application:
    https://github.com/PnX-SI/UsersHub/blob/master/Dockerfile

- publication:
    https://github.com/PnX-SI/UsersHub/blob/master/.github/workflows/docker.yml


#### TaxHub

- application:
    https://github.com/PnX-SI/TaxHub/blob/master/Dockerfile
- publication:
    https://github.com/PnX-SI/TaxHub/blob/master/.github/workflows/docker.yml


## Configuration

- .env.prod
    - utilise les images docker des application taggées en `:latest`
        - `ghcr.io/pnx-si/geonature-backend:latest`
        - `ghcr.io/pnx-si/usershub-backend:latest`
        - `ghcr.io/pnx-si/taxhub-backend:latest`
    - protocole `HTTPS`
    - ports `80/443`

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


## Package et versionnement

Une actions permet la publication d'image dockers sur les packages du dépôt.

- **gds-geonature-4-modules-frontend:<VERSION>**
- **gds-geonature-4-modules-backend:<VERSION>**
- **gds-geonature-backend:<VERSION>**
- **gds-geonature-backend:<VERSION>**

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

On suppose ici qu'une version ne va comporter que des états versionnées de GéoNature et de ses modules.
## Schema des services

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

https://excalidraw.com/#json=RWMZ1Hu6RXqGOqjmGlSJX,FqzNr6BRZkkwqD0mll07ig
