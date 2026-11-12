# Configuration

Voir la documentation des différentes applications pour renseigner les fichiers de configuration :

- GeoNature : `./config/geonature/geonature_config.toml` ([fichier d’exemple](https://github.com/PnX-SI/GeoNature/tree/master/config/geonature_config.toml.sample))
- UsersHub : `./config/usershub/config.py` ([fichier d’exemple](https://github.com/PnX-SI/UsersHub/tree/master/config/config.py.sample))

Ces fichiers doivent contenir _a minima_ le paramètre `SECRET_KEY` (sauf à la fournir par variable d’environnement).
Vous pouvez générer automatiquement des fichiers vierges contenant des clés secrètes aléatoires avec le script `./init-config.sh`.

Si vous modifiez les fichiers de configuration de GeoNature ou d'un de ses modules, GeoNature va automatiquement redémarrer.
Vous pouvez toutefois forcer le redémarrage d’un service avec la commande `docker compose restart <service>` (ou de l’ensemble des services avec `docker compose restart`).
UsersHub ne bénéficie pas d’un mécanisme de redémarrage automatique et doit donc nécessairement être relancé manuellement.

À noter que certains paramètres de configuration sont fournis en tant que variables d'environnement (voir les fichiers [`.env`](https://github.com/PnX-SI/GeoNature-Docker-services/blob/main/.env.sample) et [`docker-compose.yml`](https://github.com/PnX-SI/GeoNature-Docker-services/blob/main/docker-compose.yml)), comme par exemple :

- `URL_APPLICATION`
- `SQLALCHEMY_DATABASE_URI`
- ...

Vous pouvez personnaliser la [politique de redémarrage automatique des services](https://github.com/compose-spec/compose-spec/blob/master/spec.md#restart) en paramétrant la variable `RESTART_POLICY` du fichier `.env` (valeur par défaut: `unless-stopped`)

Il est aussi possible de personnaliser son installation en créant un fichier d'override de docker compose. Pour le détail
de fonctionnement, voir la section [Surcharger son installation](override.md).

## Dossiers de configuration et de customisation

- Les fichiers de configuration de GeoNature, de ses modules et de UsersHub sont donc dans le dossier `GeoNature-Docker-services/config/`
- Les fichiers de customisation de GeoNature sont stockés dans le dossier `GeoNature-Docker-services/data/geonature/custom/`
- Les fichiers des médias de GeoNature (photos, application mobile...) sont stockés dans le dossier `GeoNature-Docker-services/data/geonature/media/`

## Configuration par variable d’environnement

Les applications peuvent être configurées par des variables d’environnement préfixées respectivement par `GEONATURE_` et `USERSHUB_` (voir [from_prefix_env](https://flask.palletsprojects.com/en/2.2.x/api/#flask.Config.from_prefixed_env)).
Si vous souhaitez définir de nouvelles variables d’environnement, il est recommandé de les définir dans un fichier `docker-compose.override.yml` (voir [Surcharger son installation](override.md)).
