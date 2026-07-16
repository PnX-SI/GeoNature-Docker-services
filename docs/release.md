## Release

Pour publier une nouvelle version de **GeoNature-docker-services**, il faut :

- Vérifier que le changelog reprend l'ensemble des contributions. Vous pouvez comparer votre branche avec la dernière version (exemple : https://github.com/PnX-SI/GeoNature-Docker-services/compare/2.17.1.2...main)
- Vérifier que la version de l'image de GeoNature dans `.github/workflows/docker.yml` correspond à la dernière version de GeoNature.
- Vérifier que les sous-modules pointent bien vers les tags des dernières versions de GeoNature et des modules monitoring, dashboard et export.
- Modifier la version des images `geonature-backend-extra` et `geonature-frontend-extra` dans le fichier `docker-compose.essential.yml`.
- Faire un merge de la branche `develop` dans `main`.
- Vérifier que l'ensemble des tests automatisés sont passés.
- Faire la release (https://github.com/PnX-SI/GeoNature-Docker-services/releases) en la taguant X.Y.Z (sans v devant) et en copiant le contenu du changelog
