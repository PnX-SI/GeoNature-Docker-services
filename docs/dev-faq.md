
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
entre le dossier `frontend` de ce module et le dossier `frontend/external_modules`. 

```bash
ln -s ../../sources/gn_module_mtd_sync/frontend frontend/external_modules/mtd_sync
```

Une fois que c'est fait, vous pouvez simplement relancer vos dockers : 
```bash
docker compose down
docker compose up
```


## J'ai une question, à qui puis-je la poser ?

Selon la nature de votre problème, vous pouvez créer une issue sur notre GitHub ou nous contacter [sur Element](https://matrix.to/#/#geonature:matrix.org)

