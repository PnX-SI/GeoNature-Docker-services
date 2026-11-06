# Accéder aux logs

Les logs de tous les services sont accessibles avec la commande `docker compose logs -f`.

Pour n'afficher que les 100 dernières lignes, on utilise l'option `--tail 100` et donc la commande `docker compose logs -f --tail 100`.

Pour n'afficher les logs que d'un service en particulier, on utilise la commande `docker compose logs -f <nom du service>`.
