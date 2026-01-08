# syntax=docker/dockerfile:1.2

ARG ATLAS_IMAGE="geonature-docker-service/geonature-atlas-local:latest"

FROM ${ATLAS_IMAGE}-app as base_env

ARG DOCKER_UID
ARG DOCKER_GID
ARG HOST_USER

USER root
# Add the group (if not existing) then add the user to the group
RUN id --name --group ${DOCKER_GID} || \
    addgroup --gid ${DOCKER_GID} ${HOST_USER} && \
    id --name --user ${DOCKER_UID} || \
    adduser --gecos GECOS --disabled-password --uid ${DOCKER_UID} --gid ${DOCKER_GID} ${HOST_USER}

COPY ./sources/GeoNature-atlas/requirements.txt .
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements.txt

COPY --chown=${DOCKER_UID}:${DOCKER_GUID} ./sources/GeoNature-atlas ./GeoNature-atlas

RUN --mount=type=cache,target=/root/.cache \
    pip install -e ./GeoNature-atlas

COPY --chmod=755 ./sources/GeoNature-atlas/docker_startup.sh .
COPY --chmod=755 ./sources/GeoNature-atlas/docker_install_atlas_schema.sh .
COPY ./sources/GeoNature-atlas/data ./data

ENV FLASK_APP=app.app:create_app
ENV ATLAS_SETTINGS=/dist/config/config.py
ENV ATLAS_STATIC_FOLDER=/dist/static
ENV ATLAS_TEMPLATE_FOLDER=/dist/
ENV ATLAS_BABEL_TRANSLATION_DIRECTORIES=/dist/translations

EXPOSE 8080

CMD ["./docker_startup.sh"]

# Nettoyage final
RUN rm -f *.whl