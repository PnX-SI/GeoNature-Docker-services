
# <a name="dev-faq"></a> FAQ de développement

## Mon docker compose de dev ne lance pas le build des images et essaye de les chercher sur un repo à la place.

Assurez-vous de ne pas avoir activé la feature Bake de docker `COMPOSE_BAKE=true`

## Comment installer un module dans une instance de dev

Il vous faut commencer par cloner le module dans le dossier `sources`. Assurez vous que le nom du dossier commence par  
gn_module et que dans la racine de ce dossier se trouvent bien les dossiers `backend` et `frontend` 
(si un frontend existe pour ce module).

```bash
cd sources
git clone https://github.com/PnX-SI/mtd_sync.git gn_module_mtd_sync
```

Une fois que c'est fait, si votre module dispose d'un frontend, il faut créer un lien symbolique
entre le dossier `frontend` de ce module et le dossier `frontend/external_modules`. Attention à bien utiliser 
le même nom de dossier que le `module_path` de votre module.  

```bash
cd sources/gn_module_calcutrice_monitoring/ # /!\ vous devez faire le lien symbolique depuis le dossier du module
ln -s ../../sources/gn_module_calcutrice_monitoring/frontend/ ../../frontend/external_modules/calculatrice
```

Une fois que c'est fait, vous pouvez simplement relancer vos dockers : 
```bash
docker compose down
docker compose up
```

## Quand je lance mes tests une erreur 404 apparait alors que les tests marchent sur une installation classique ou dans la CI
Le mode d'installation via Traefik fait qu'on doit set la variable `GEONATURE_API_ENDPOINT` en fonction de l'url
servis par Traefik. Lors des tests, qui sont executés dans le container, on ne passe plus par Traefik donc cette variable
a une valeur qui entraine des erreurs. Il faut donc lancer les tests en changeant cette variable. 
```bash
GEONATURE_API_ENDPOINT='https://localhost'  pytest .
```


## Je ne trouve pas la branche que je cherche dans Geonature et mes sous modules 
Pour gagner de l'espace, nous faisons un copy shallow de nos sous module (récupération seulement du dernier commit).
Pour avoir accès au reste de l'historique, vous pouvez vous déplacer dans le module en question `cd sources/GeoNature` puis
executer les commandes :
```
git fetch --unshallow
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch origin 
```

## J'ai une question, à qui puis-je la poser ?

Selon la nature de votre problème, vous pouvez créer une issue sur notre GitHub ou nous contacter [sur Element](https://matrix.to/#/#geonature:matrix.org)

