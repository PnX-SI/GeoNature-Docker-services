# syntax=docker/dockerfile:1.2

ARG ATLAS_IMAGE="ghcr.io/pnx-si/geonature-atlas-local:latest"

FROM python:3.9-bullseye AS build

ENV PIP_ROOT_USER_ACTION=ignore

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip setuptools wheel

FROM build AS build-atlas

ARG DOCKER_UID
ARG DOCKER_GID

COPY --chown=${DOCKER_UID}:${DOCKER_GUID} /sources/GeoNature-atlas /sources/GeoNature-atlas

WORKDIR /build/
COPY /sources/GeoNature-atlas/setup.py .
COPY /sources/GeoNature-atlas/requirements.in .
COPY /sources/GeoNature-atlas/VERSION .
COPY /sources/GeoNature-atlas/MANIFEST.in .
COPY /sources/GeoNature-atlas/README.rst .
COPY /sources/GeoNature-atlas/LICENSE.txt .
COPY /sources/GeoNature-atlas/atlas ./atlas
COPY /sources/GeoNature-atlas/atlas/configuration/config.py.sample config.py
RUN python setup.py bdist_wheel

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

COPY /sources/GeoNature-atlas/requirements.txt .
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements.txt

COPY --from=build-atlas /build/dist/*.whl .

RUN --mount=type=cache,target=/root/.cache \
    pip install *.whl

COPY --chown=${DOCKER_UID}:${DOCKER_GUID} /sources/GeoNature-atlas /sources/GeoNature-atlas

RUN --mount=type=cache,target=/root/.cache \
    pip install -e /sources/GeoNature-atlas

COPY --chmod=755 /sources/GeoNature-atlas/docker_startup.sh .
COPY --chmod=755 /sources/GeoNature-atlas/docker_install_atlas_schema.sh .
COPY /sources/GeoNature-atlas/data ./data

#Fix
RUN sed -i "s/:type_territoire/:\'type_territoire\'/g" /dist/data/gn2/atlas_ref_geo.sql && \
    sed -i "s/:type_maille/:\'type_maille\'/g" /dist/data/atlas/12.atlas.vm_mailles_territoire.sql

ENV FLASK_APP=app.app:create_app
ENV ATLAS_SETTINGS=/dist/config/config.py
ENV ATLAS_STATIC_FOLDER=/dist/static
ENV ATLAS_TEMPLATE_FOLDER=/dist/
ENV ATLAS_BABEL_TRANSLATION_DIRECTORIES=/dist/translations

EXPOSE 8080

CMD ["./docker_startup.sh"]

# Nettoyage final
RUN rm -f *.whl