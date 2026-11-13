# Configurer un reverse proxy externe

Cette section a pour but de vous aider à configurer un reverse proxy externe pour votre installation de GeoNature. Cela
arrive sur les serveurs web ou plusieurs services cohabitent (GeoNature et une autre application), ou ceux où plusieurs
instances de GeoNatures sont présentes.

## Configuration commune

Pour la suite nous allons partir de la supposition que vous avez trois applications à servir.

- `app` une de vos application qui n'a rien à voir avec GeoNature qui doit être servie sur `app.example.com`
- `gds1` une stack GeoNature, qui doit être servie sur `gds1.example.com`
- `gds2` une seconde stack de GeoNature, qui doit être servie sur `gds2.example.com`

Si vous avez plusieurs autres applications, ou une seule instance de GeoNature, vous pouvez utiliser la même logique et
l'adapter à votre cas.

Sur chaque stack GeoNature:

- Utiliser Traefik en HTTP sur un port custom (on prendra pour la suite gds1 sur 8080 et gds2 sur 8081) en modifiant
  dans chaque stack la variable `TRAEFIK_HTTP_PORT`
- `COMPOSE_FILE` ne doit pas contenir `docker-compose.traefik-https.yml`
- Changer les variables `GEONATURE_BACKEND_PORT` et `GEONATURE_FRONTEND_PORT` vers 443 (dans notre exemple 80 en http)
- Définissez `BASE_PROTOCOL=https` (ou `http` si votre reverse proxy ne gère pas l’HTTPS) et `BASE_PORT=` (vide,
  sauf si port exotique différent de 80 en http ou 443 en https)
- Assurez vous que `GEONATURE_BACKEND_PREFIX`, `GEONATURE_FRONTEND_PREFIX` et `USERSHUB_PREFIX` vous convienne
- Modfier votre host : `BASE_HOST="gds1.example.org"`
- Si vous avez plusieurs stacks GeoNature, faire les mêmes modifications sur la deuxième stack

Pour la suite, nous rentrons dans le detail de quelques proxies connus. La version proposé est en http mais facilement
transposable pour du https

## Nginx

Dans votre fichier de configuration ajouter les lignes suivantes (à adapter à votre contexte):

```
upstream gds1 { server host.docker.internal:8081; }
upstream gds2 { server host.docker.internal:8080; }

# VOS CONFIGURATIONS
# ----

server {
    listen 80;
    server_name gds1.example.org;
    location / { proxy_pass http://gds1; }
}

server {
    listen 80;
    server_name gds2.example.org;
    location / { proxy_pass http://gds2; }
}
```
Vous pourrez ensuite accéder à vos instances de GeoNature sur `gds1.example.org` et `gds2.example.org`.


## Apache

Dans votre fichier de configuration ajouter les lignes suivantes (à adapter à votre contexte):

```
# VOS CONFIGURATIONS
# ----
<VirtualHost *:80>
    ServerName gds1.example.org
    ProxyPass        / http://host.docker.internal:8091/
    ProxyPassReverse / http://host.docker.internal:8091/
</VirtualHost>

<VirtualHost *:80>
    ServerName gds2.example.org
    ProxyPass        / http://host.docker.internal:8090/
    ProxyPassReverse / http://host.docker.internal:8090/
</VirtualHost>
```

Vous pourrez ensuite accéder à vos instances de GeoNature sur `gds1.example.org` et `gds2.example.org`.

