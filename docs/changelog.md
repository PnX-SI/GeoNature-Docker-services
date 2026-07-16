# CHANGELOG

## 2.17.4

### 🚀 Nouveautés

- Ajout d'un dossier `/override_gallery` contenant des exemples d'intégration de plugins. Ici, nous proposons un exemple d'intégration de [flower](https://flower.readthedocs.io/en/latest/) (#117 par @christophe-ramet)
- Ajout d'un docker-compose d'exemple dans le dossier `/override_gallery` permettant de faire du multi-instances sur un serveur (#118 par @christophe-ramet)
- Ajout d'une section "Principes et objectifs" dans le README.md (#115 par @camillemonchicourt)
- Les dépendances de GeoNature sont maintenant compilées et installées à l'initialisation du mode dev (#83 par @christophe-ramet)
- Ajout d'un fichier CONTRIBUTING.md (#116 par @christophe-ramet)
- Amélioration de la création des images Docker (#120 par @christophe-ramet)

### 🖥️ Développement

- Ajout de la commande `make install_monitoring_module` pour installer un sous-module Monitoring (#84 par @christophe-ramet)

### 🐛 Corrections

- Correction d'un bug dans la création du fichier .env (#119 par @christophe-ramet)
- Correction de la target cypress dans le Makefile (#95 par @VincentCauchois)

**🏷️ Versions**

- GeoNature 2.17.4
- UsersHub 2.4.8
- GeoNature-dashboard 1.6.1
- GeoNature-export 1.8.2
- GeoNature-monitoring 1.3.1

## 2.17.1.2

### ⏩ En bref

Cette version apporte une restructuration majeure de la stack Docker avec la séparation du fichier `docker-compose.yml`. Cette refonte permet une bien meilleure flexibilité, en offrant la possibilité de lancer GDS selon différents scénarios : sans Traefik, avec une base de données externe, ou sans UsersHub.

Pour explorer différentes possibilités de configurations, des exemples de `.env` sont mis à disposition dans le dossier `env_examples`.

### 🚀 Nouveautés

- Changement important sur le fichier `docker-compose.yml` (#18 par @christophe-ramet et @jacquesfize):
  - Séparation du contenu du fichier en deux parties : `docker-compose.essential.yml` et `docker-compose.traefik.yml` (le fichier `docker-compose.yml` existe toujours)
  - Il est possible de lancer GDS selon différents scénarions :
    - Sans Traefik
    - Sans base de données. Par conséquent, il vous est possible d'utiliser GDS sur une de vos bases de données existantes.
    - Sans UsersHub. Par conséquent, il vous est possible d'utiliser GDS sur votre UsersHub.
    - Plusieurs fichiers d'exemple sont disponibles dans le dossier `env_examples/`
  - Ajout d'une CI `compose.yml` qui effectue les tests des différents scénarios de lancement de GDS.
- Ajout d'un CLI pour générer un fichier `.env` (Statut expérimental). Pour l'utiliser, lancer la commande `python generate_env.py`
- Modification de Traefik
  - Mise à jour de Traefik de la version 2.10.4 vers la 3.6.4 (#87 par @christophe-ramet)
  - Ajout du Dashboard traefik. L'identifiant et le mot de passe d'accès au dashboard est paramétrable avec les variables `TRAEFIK_USER` et `TRAEFIK_PASSWORD`.
  - Ajout d'un paramètre permettant d'activer les logs de Traefik `TRAEFIK_ACTIVATE_ACCESS_LOG`
- Ajout de la possibilité d'ajouter un Makefile.local pour surcoucher son makefile. Cela permet d'ajouter ses propres commande make sans rentrer en conflit avec le makefile de base.

#### Développement

- Installation automatique des modules ajoutés par l'utilisateur (#72 par @christophe-ramet)
- Ajout de la possibilité de déployer une base de données GeoNature pré-peuplée (https://github.com/PnX-SI/geonature_db)
- Ajout des commandes dans le Makefile: `lint_frontend`, `lint_backend`,`test`

### 🐛 Corrections

- Ajout de politiques de démarrages manquantes sur certains services (#105 par @andriacap)

**⚠️ Notes de version**

Cette nouvelle version de GDS apporte des modifications profondes dans le fichier de configuration `.env` ! Il est nécessaire de reconstruire le fichier `.env` en s'appuyant de la dernière version du modèle contenue dans `env.sample`.

```shell
cp .env .env_backup
cp .env.sample .env
# modifier le contenu de .env en vous appuyant certaines
# des valeurs de la sauvegarde .env_backup
```

## 2.17.1

**🏷️ Versions**

- GeoNature 2.17.1
- TaxHub 2.3.1
- UsersHub 2.4.8
- GeoNature-dashboard 1.6.1
- GeoNature-export 1.8.2
- GeoNature-monitoring 1.3.0

## 2.17.0

**🏷️ Versions**

- GeoNature 2.17.0
- TaxHub 2.3.1
- UsersHub 2.4.8
- GeoNature-dashboard 1.6.1
- GeoNature-export 1.8.1
- GeoNature-monitoring 1.3.0

## 2.16.4.2

**🏷️ Versions**

- GeoNature 2.16.4
- TaxHub 2.2.3
- UsersHub 2.4.7
- GeoNature-dashboard 1.6.0
- GeoNature-export 1.8.1
- GeoNature-monitoring 1.2.6

## 2.16.4.1

**🏷️ Versions**

- GeoNature 2.16.4
- TaxHub 2.2.3
- UsersHub 2.4.7
- GeoNature-dashboard 1.6.0
- GeoNature-export 1.8.1
- GeoNature-monitoring 1.2.3

## 2.16.4

**🏷️ Versions**

- GeoNature 2.16.4
- TaxHub 2.2.3
- UsersHub 2.4.7
- GeoNature-dashboard 1.6.0
- GeoNature-export 1.8.0
- GeoNature-monitoring 1.2.2

## 2.16.3

**🏷️ Versions**

- GeoNature 2.16.3
- TaxHub 2.2.3
- UsersHub 2.4.7
- GeoNature-dashboard 1.6.0
- GeoNature-export 1.8.0
- GeoNature-monitoring 1.2.2

## 2.16.2

**🏷️ Versions**

- GeoNature 2.16.2
- TaxHub 2.2.2
- UsersHub 2.4.7
- GeoNature-dashboard 1.6.0
- GeoNature-export 1.8.0
- GeoNature-monitoring 1.1.0

## 2.16.1

**🏷️ Versions**

- GeoNature 2.16.1
- TaxHub 2.2.2
- UsersHub 2.4.7
- GeoNature-dashboard 1.6.0
- GeoNature-export 1.8.0
- GeoNature-monitoring 1.0.3

## 2.16.0

**🏷️ Versions**

- GeoNature 2.16.0
- TaxHub 2.2.2
- UsersHub 2.4.7
- GeoNature-dashboard 1.6.0
- GeoNature-export 1.8.0
- GeoNature-monitoring 1.0.3

## 2.15.4

**🏷️ Versions**

- GeoNature 2.15.4
- TaxHub 2.1.2
- UsersHub 2.4.4
- GeoNature-dashboard 1.5.0
- GeoNature-export 1.7.2
- GeoNature-monitoring 1.0.1

**🚀 Nouveautés**

- [Développement] Ajout d'un docker-compose dédié au développement de GeoNature (#47 par @Christophe-Ramet)

**⚠️ Notes de version**

- Pour mettre à jour GDS, il est maintenant nécessaire de spécifier la version GeoNature et UsersHub dans les variables `GEONATURE_BACKEND_EXTRA_IMAGE`, `GEONATURE_FRONTEND_EXTRA_IMAGE` et `USERSHUB_IMAGE` du fichier `.env`. Les versions seront indiquées dans chaque note de version.

## 2.15.3

**🏷️ Versions**

- GeoNature 2.15.3
- TaxHub 2.1.2
- UsersHub 2.4.4
- GeoNature-dashboard 1.5.0
- GeoNature-export 1.7.2
- GeoNature-monitoring 1.0.1

## 2.15.2

**🏷️ Versions**

- GeoNature 2.15.2
- TaxHub 2.1.1
- UsersHub 2.4.4
- GeoNature-dashboard 1.5.0
- GeoNature-export 1.7.2
- GeoNature-monitoring 1.0.0

## 2.15.0

**🏷️ Versions**

- GeoNature 2.15.0
- TaxHub 2.1.0
- UsersHub 2.4.4
- GeoNature-dashboard 1.5.0
- GeoNature-export 1.7.2
- GeoNature-monitoring 1.0.0

**🚀 Nouveautés**

- TaxHub est désormais intégré à GeoNature
- Ajout d'une politique de redémarrage automatique des services Docker (#26; par @lpofredc)

**⚠️ Notes de version**

- Avant d'effectuer la mise à jour de GeoNature, installer l'extension `ltree` dans le container `postgres` :
  `docker compose exec postgres psql -U [user_postgres] -d [nom_db_geonature] -f /docker-entrypoint-initdb.d/add-extensions.sql`
- Avec cette nouvelle version, les médias de TaxHub se trouvent dans le dossier `media` de GeoNature. Si vous mettez à jour votre GeoNature, déplacer les médias de TaxHub de l'ancien dossier (`GeoNature-Docker-services/data/taxhub/medias`) vers le nouveau (`GeoNature-Docker-services/data/geonature/media/taxhub`) :
  `cp -r data/taxhub/medias/* data/geonature/media/taxhub`
- La suppression du container TaxHub implique une modification du docker-compose, n'oubliez pas de récupérer les modifications de ce dernier ([Voir documentation](https://github.com/PnX-SI/GeoNature-Docker-services?tab=readme-ov-file#mettre-%C3%A0-jour-geonature-et-ses-modules))

## 2.14.2 (2024-06-03)

- GeoNature 2.14.2
- TaxHub 1.14.1
- UsersHub 2.4.3
- GeoNature-dashboard 1.5.0
- GeoNature-export 1.7.0
- GeoNature-import 2.3.0
- GeoNature-monitoring 0.7.3

## 2.14.1 (2024-05-03)

**🏷️ Versions**

- GeoNature 2.14.1
- TaxHub 1.14.0
- UsersHub 2.4.2
- GeoNature-dashboard 1.5.0
- GeoNature-export 1.7.0
- GeoNature-import 2.3.0
- GeoNature-monitoring 0.7.3

## 2.14.0 (2024-02-29)

**🏷️ Versions**

- GeoNature 2.14.0
- TaxHub 1.13.3
- UsersHub 2.4.0
- GeoNature-dashboard 1.5.0
- GeoNature-export 1.7.0
- GeoNature-import 2.3.0
- GeoNature-monitoring 0.7.2

## 2.13.4 (2023-12-15)

**🏷️ Versions**

- GeoNature 2.13.4
- TaxHub 1.12.1
- UsersHub 2.3.4
- GeoNature-dashboard 1.4.0
- GeoNature-export 1.6.0
- GeoNature-import 2.2.3
- GeoNature-monitoring 0.7.0

**✨ Améliorations**

- Le GID et le UID sont modifiables dans le fichier `.env` (#23 par @jacquesfize).

## 2.13.3 (2023-10-18)

**🏷️ Versions**

- GeoNature 2.13.3
- TaxHub 1.12.1
- UsersHub 2.3.4
- GeoNature-dashboard 1.4.0
- GeoNature-export 1.6.0
- GeoNature-import 2.2.3
- GeoNature-monitoring 0.7.0

**🐛 Corrections**

- Correction de la prise en compte de la configuration de TaxHub (#20)

**⚠️ Notes de version**

- Comme indiqué dans la procédure classique de mise à jour, vous devez télécharger la nouvelle version du dépôt (notamment pour mettre à jour le fichier `docker-compose.yml` qui a évolué dans cette version)
- Si vous l'aviez modifié localement, reportez les évolutions du fichier `docker-compose.yml` (#20), en y ajoutant les paramètres de TaxHub

## 2.13.2 (2023-09-28)

**🏷️ Versions**

- GeoNature 2.13.2
- TaxHub 1.12.1
- UsersHub 2.3.4
- GeoNature-dashboard 1.4.0
- GeoNature-export 1.6.0
- GeoNature-import 2.2.3
- GeoNature-monitoring 0.7.0

**✨ Améliorations**

- Mise à jour de Python en version 3.11 dans l'image Docker de GeoNature (#17)

**🐛 Corrections**

- Correction du chargement de la customisation (au niveau de GeoNature)

## 0.2.0 (2023-09-19)

**🏷️ Versions**

- GeoNature 2.13.1
- TaxHub 1.12.1
- UsersHub 2.3.4
- GeoNature-dashboard 1.4.0
- GeoNature-export 1.6.0
- GeoNature-import 2.2.2
- GeoNature-monitoring 0.7.0

**✨ Améliorations**

- Compléments de la documentation (Redirections, version, rebuild des images)
- Ajout de variables dans le `.env` pour pouvoir intégrer ou non les données initiales (référentiel de sensibilité, BDC statuts, zonages administratifs, mailles et données d'exemple)

**🐛 Corrections**

- Déclaration d’une variable d’environnement manquante à UsersHub pour créer des utilisateurs
- Spécification du fichier de schedule pour Celery Beat

**⚠️ Notes de version**

Les modifications suivantes ont été apportées au fichier `docker-compose.yml` :

- Ajout de la variable d’environnement `USERSHUB_FILL_MD5_PASS` au service UsersHub :
  ```
  services:
    usershub:
      environment:
        USERSHUB_FILL_MD5_PASS: ${USERSHUB_FILL_MD5_PASS:-false}
  ```
- Ajout du paramètre `--schedule-filename` à la commande de Celery Beat :

  ```
  services:
    geonature-worker:
      command: celery -A geonature.celery_app:app worker --beat --schedule-filename=/dist/media/celerybeat-schedule.db
  ```

## 0.1.0 (2023-09-15)

Première version fonctionnelle de GeoNature-Docker-services, permettant de déployer, avec un seul fichier `docker-compose`, GeoNature et ses 4 modules externes principaux, TaxHub, UsersHub et traefik (comme reverse proxy et pour gérer les certificats SSL, générés automatiquement pour que les applications soient accessibles en HTTPS lors de leur installation).

**🏷️ Versions**

- GeoNature 2.12.3
- TaxHub 1.12.1
- UsersHub 2.3.4
- GeoNature-dashboard 1.4.0
- GeoNature-export 1.6.0
- GeoNature-import 2.2.1
- GeoNature-monitoring 0.7.0
