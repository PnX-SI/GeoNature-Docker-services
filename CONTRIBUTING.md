# Comment contribuer

Merci à tous les contributeurs de GeoNature Docker services (GDS).

Pour rappel, GDS est à la fois un environnement Docker pour déployer une stack GeoNature,
et un repo construisant des images Docker incluant des modules externes supportés.

---

## Philosophie du projet

Avant de contribuer, il est important de comprendre les principes essentiels de GDS et de vérifier que sa
contribution ne rentre pas en conflit avec ces principes.

**1. GeoNature clé en main**

> 🢂 Votre contribution ne doit pas empecher le déploiement avec une seule commande et un seul fichier de configuration

**2. Modulaire et adaptable**

> 🢂 Votre feature ne doit pas empecher le bon fonctionnement de GDS dans un autre contexte que le votre

**3. Limiter la complexité globale**

> 🢂 Il faut limiter l'ajout de paramètre et de regle Makefile à celles qui seront utiles à une majorité d'utilisateurs

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

Chaque développement doit être précédé obligatoirement de l'ouverture d'une issue.

## Justifications

Cette section liste un certain nombre de choix techniques et les justifications associées.

- **`TRAEFIK_HTTPS_PORT` doit être définie mais vide si utilisation du port 443 :** Sa définition permet de définir automatiquement `BASE_PROTOCOL=https`, sans pour autant rajouter `:443` dans les URLs.
- **Traefik bind en interne le port exposé :** Il aurait été possible de bind le port 443, tout en exposant le port `${TRAEFIK_HTTPS_PORT}`, mais cela peut amener à des redirections incorrectes HTTP vers HTTPS par la règle `entrypoints.web.http.redirections.entrypoint.to=websecure`.
- **Utilisation de variable d’environnement pour configurer Traefik :** La section `command` (liste) se trouve entièrement remplacé lorsque overridé dans un autre fichier. À l’inverse, `environment` (mapping) est fusionnée, permettant de rajouter d’autres paramètres de configuration.
