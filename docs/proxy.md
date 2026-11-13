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

- Utiliser Traefik en HTTP sur un port custom (on prendra pour la suite gds1 sur 8080 et gds2 sur 8081) en modifiant
  dans chaque stack la variable `TRAEFIK_HTTP_PORT`
- `COMPOSE_FILE` ne doit pas contenir `docker-compose.traefik-https.yml`
- Changer les variables `GEONATURE_BACKEND_PORT` et `GEONATURE_FRONTEND_PORT` vers 443 (dans notre exemple 80 en http)
- Définissez `BASE_PROTOCOL=https` (ou `http` si votre reverse proxy ne gère pas l’HTTPS) et `BASE_PORT=` (vide,
  sauf si port exotique différent de 80 en http ou 443 en https)
- Assurez vous que `GEONATURE_BACKEND_PREFIX`, `GEONATURE_FRONTEND_PREFIX` et `USERSHUB_PREFIX` vous convienne
- Modfier votre host : `BASE_HOST="gds1.example.org"`

Si vous avez plusieurs stacks GeoNature:
- Faire les mêmes modifications sur toutes les stacks
- S'assurer que le nom du dossier où se trouve chaque stack est différent ou que `COMPOSE_PROJECT_NAME` est bien 
  différent pour chaque stack.

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

## Traefik

Ci dessous un exemple de configuration pour Traefik qui sert les traefiks des différentes stacks.

```
services:
  traefik:
    image: traefik:v3.6
    restart: unless-stopped
    command:
      - --log.level=DEBUG
      - --accesslog=true
      - --providers.file.filename=/etc/traefik/dynamic.yml
      - --entrypoints.web.address=:80
    ports:
      - "80:80"
    configs:
      - source: traefik_dynamic
        target: /etc/traefik/dynamic.yml
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      traefik_global:
        aliases:
          - gds1.example.org
          - gds2.example.org
          - app.example.com

configs:
  traefik_dynamic:
    content: |
      http:
        routers:
          gds1:
            rule: Host(`gds1.example.org`)
            service: gds1
          gds2:
            rule: Host(`gds2.example.org`)
            service: gds2
          app:
            rule: Host(`app.example.com`)
            service: app
        services:
          gds1:
            loadBalancer:
              servers:
                - url: http://gds1:8091/
          gds2:
            loadBalancer:
              servers:
                - url: http://gds2:8090/
          app:
            loadBalancer:
              servers:
                - url: http://app:8080/

networks:
  traefik_global:
    name: traefik_global
    driver: bridge
```

Il faut par ailleurs, dans chacune de vos stacks GeoNature, ajouter au .env
`COMPOSE_FILE=${COMPOSE_FILE}:override_gallery/docker-compose-multi-stack-traefik.yaml` et ajouter `TRAEFIK_ALIAS` pour
qu'il vaille `gds1` dans la stack `gds1` et `gds2` dans la stack `gds2`.