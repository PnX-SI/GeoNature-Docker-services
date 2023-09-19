CHANGELOG
=========

0.2.0 (2023-09-19)
------------------

**🏷️ Versions**

- GeoNature 2.12.3
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

0.1.0 (2023-09-15)
------------------

Première version fonctionnelle de GeoNature-Docker-services, permettant de déployer, avec un seul fichier `docker-compose`, GeoNature et ses 4 modules externes principaux, TaxHub, UsersHub et traefik (comme reverse proxy et pour gérer les certificats SSL, générés automatiquement pour que les applications soient accessibles en HTTPS lors de leur installation).

**🏷️ Versions**

- GeoNature 2.12.3
- TaxHub 1.12.1
- UsersHub 2.3.4
- GeoNature-dashboard 1.4.0
- GeoNature-export 1.6.0
- GeoNature-import 2.2.1
- GeoNature-monitoring 0.7.0
