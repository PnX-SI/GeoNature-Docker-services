# Lancer une instance de développement

1. Commencez par vous assurer d'avoir installé make, jq et git-lfs : `sudo apt install make jq git-lfs openssl`.

1. Initialisez le sous-module `GeoNature-images` :

    ```
   git submodule update --init --remote
   git -C GeoNature-images submodule update --init --depth=1 --remote
   git -C GeoNature-images/GeoNature submodule update --init --depth=1
   ```

1. Vous pouvez à présent entrer dans le dossier `GeoNature-images` et consulter son README afin de suivre la procédure de création des images. En théorie, celle-ci se résume à lancer `make docker-dev`. Vous pouvez visualiser le nom des images produites avec la commande `make docker-list-images`.
1. Dans votre fichier `.env`, ajouter `docker-compose.dev.yml` à `COMPOSE_FILE`.
1. Vérifiez le nom des images et leur tag dans les variables `GEONATURE_BACKEND_IMAGE` et `GEONATURE_FRONTEND_IMAGE`. Attention, les tags se verrons automatiquement rajouté le suffix `-dev`.
1. Relancer votre stack avec `docker compose up -d`

Vous devez rebuild vos images de dev et relancer la stack lorsque vous modifiez notamment les dépendances Python ou node.

## Exécuter les test Cypress

Vous devez avoir installé Cypress au préalable et lancé la stack.
La commande `make cypress` vous permet ensuite de lancer les tests cypress.

Si vous voulez que vos tests s'exécutent comme dans la CI Github, il faut, une base sans données saisie au préalable.
Puis, vous devez passer les migrations "samples" :

```shell
   geonature db upgrade occtax-samples-test@head
   geonature db upgrade occhab-samples@head
   geonature db upgrade import-samples@head`
```

Il est aussi possible de lancer Cypress en version headed ou avec des paramètres plus complexe en se calquant sur ce
qui est fait dans le Makefile, par exemple pour lancer cypress en headed et en spécifiant les tests liés aux forms d'occtax :

`source .env; cd sources/GeoNature/frontend; API_ENDPOINT="https://$${HOST}$${GEONATURE_BACKEND_PREFIX}/" URL_APPLICATION="https:$${HOST}$${GEONATURE_FRONTEND_PREFIX}/" cypress run --headed --spec cypress/e2e/occtax-form-spec.js`
