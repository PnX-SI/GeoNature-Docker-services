# Monitoring

## Installer un sous-module

1. Déposer le dossier contenant la configuration du protocole dans `data/geonature/media/monitorings/`. Par exemple,
   lorsque vous avez récupéré le dépôt [protocoles_suivi](https://github.com/PnX-SI/protocoles_suivi/) :

   ```sh
   cp -r protocoles_suivi/chiro data/geonature/media/monitorings/chiro
   ```

2. Lancer l'installation du sous-module avec la commande :

   ```sh
   docker compose exec geonature-backend geonature monitorings install <nom_sous_module>
   ```

## Modifier ou mettre à jour le sous-module

Si vous souhaitez modifier le sous-module, faites le directement dans les fichiers du dossier du sous-module dans
`data/geonature/media/monitorings/`.

## Exécuter une commande Monitoring

Pour des actions plus avancées, vous pouvez vous attacher au Docker avec la commande
`docker compose exec geonature-backend bash` et
suivre
la [documentation du module Monitoring](https://github.com/PnX-SI/gn_module_monitoring/blob/main/docs/commandes.md)
