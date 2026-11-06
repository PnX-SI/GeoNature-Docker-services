# Mettre à jour GeoNature et ses modules

1. Éditez le tag des variables `GEONATURE_BACKEND_IMAGE`, `GEONATURE_FRONTEND_IMAGE` et `USERSHUB_IMAGE`. Si vous n’avez pas définie ces variables, ou si vous utilisez le tag `latest` (par défaut), vous devez explicitement demander à docker de mettre à jour les images : `docker compose pull`
2. Relancer les services : `docker compose up -d`
