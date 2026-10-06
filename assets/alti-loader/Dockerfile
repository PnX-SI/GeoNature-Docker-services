# ./assets/alti-loader/Dockerfile
ARG POSTGIS_IMAGE=postgis/postgis:15-3.4
FROM ${POSTGIS_IMAGE}

# Ajout des dépendances nécessaires
RUN apt-get update -qq && \
    apt-get install -y -qq curl unzip postgis && \
    rm -rf /var/lib/apt/lists/*

# Copie du script d'import
COPY alti-loader.sh /usr/local/bin/alti-loader.sh
RUN chmod +x /usr/local/bin/alti-loader.sh

ENTRYPOINT ["bash", "/usr/local/bin/alti-loader.sh"]
