# Surcharger son installation

En fonction de l'environnement dans lequel vous déployez, il est possible que vous soyez amené à vouloir modifier le
fichier `docker-compose.yml` afin de personnaliser le comportement de GDS. Afin de pouvoir mettre à jour votre repo, il
est fortement conseillé de passer par un fichier d'override
(voir [documentation docker compose sur les overrides](https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/)).
Pour cela, vous pouvez créer un fichier `docker-compose.override.yml` qui contient les modifications que vous souhaitez
apporter à la stack et l'ajouter à votre variable d'environnement
`COMPOSE_FILE`
(voir [documentation docker](https://docs.docker.com/compose/how-tos/environment-variables/envvars/#compose_file))

Vous pouvez vérifier après modification de votre `.env` ou de votre fichier `docker-compose.override.yml` la
configuration effective de docker compose avec la commande `docker compose config`.

Plusieurs exemples de surcharge sont disponibles dans le dossier `override_gallery`. Ce dossier contient des fichiers
`compose.yml` testés
pour une version précise de GDS et permettant de modifier la configuration de GDS ou de déployer des services
supplémentaires.
