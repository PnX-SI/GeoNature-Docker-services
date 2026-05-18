# Comment contribuer

Merci à tous les contributeurs de GeoNature Docker services (GDS).

Pour rappel, GDS est à la fois un environnement Docker pour déployer une stack GeoNature,
et un repo construisant des images Docker incluant des modules externes supportés.

---

## Philosophie du projet

Avant de contribuer, il est important de comprendre les principes essentiels de GDS et de vérifier que sa 
contribution ne rentre pas en conflit avec ces principes.


**1. GeoNature clé en main**
   
   Un fichier de configuration et une commande suffisent à déployer et mettre à jour facilement un environnement GeoNature dockerisé, fonctionnel et complet (GeoNature et ses principaux modules)
        
>   🢂 Votre contribution ne doit pas empecher le déploiement avec une seule commande et un seul fichier de configuration

**2. Modulaire et adaptable**
   
   Doit permettre à chacun d'adapter le projet pour ses besoins spécifiques et son infrastructure

>   🢂 Votre feature ne doit pas empecher le bon fonctionnement de GDS dans un autre contexte que le votre
   
**3. Limiter la complexité globale**

   Le projet ne doit pas inclure de fonctionnalités trop spécifiques à un contexte. L'ajout de fonctionnalités (paramètres, makefile...) ne doit pas se substituer à une maitrise de Docker, GeoNature ou d'administration système

>   🢂 Il faut limiter l'ajout de paramètre et de regle Makefile à celles qui seront utiles à une majorité d'utilisateurs
 


> ⚠️ Si une contribution ne s'inscrit pas totalement dans ces principes, vous pouvez ouvrir une issue pour en discuter.

---

## Signaler un bug

1. Vérifier que le bug n'a pas déjà été signalé dans les [issues](../../issues)
2. Ouvrir une nouvelle issue en précisant :
   - La version de GDS et de GeoNature
   - Le comportement observé vs attendu
   - Les logs pertinents
---

## Proposer une fonctionnalité

Avant toute chose,
- Vérifier que votre contribution ne rentre pas en conflit avec les principes de GDS
- Vérifier que votre contribution n'est pas lié à un contexte spécifique
- Vérifier que votre contribution est lié à GDS et pas à GeoNature ou un de ses sous-modules

Par ailleurs, nous vous demandons d'**ouvrir une issue avant de coder**
