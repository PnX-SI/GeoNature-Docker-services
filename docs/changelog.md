# CHANGELOG

## 2.14.2 (2024-06-03)

- Geonature 2.14.2
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

  2.13.2 (2023-09-28)

---

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

  0.2.0 (2023-09-19)

---

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

  0.1.0 (2023-09-15)

---

Première version fonctionnelle de GeoNature-Docker-services, permettant de déployer, avec un seul fichier `docker-compose`, GeoNature et ses 4 modules externes principaux, TaxHub, UsersHub et traefik (comme reverse proxy et pour gérer les certificats SSL, générés automatiquement pour que les applications soient accessibles en HTTPS lors de leur installation).

**🏷️ Versions**

- GeoNature 2.12.3
- TaxHub 1.12.1
- UsersHub 2.3.4
- GeoNature-dashboard 1.4.0
- GeoNature-export 1.6.0
- GeoNature-import 2.2.1
- GeoNature-monitoring 0.7.0
