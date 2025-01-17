ARG ATLAS_IMAGE

FROM ${ATLAS_IMAGE}

ARG UID
ARG GID
ARG HOST_USER

USER root
# Add the group (if not existing) then add the user to the group
RUN id --name --group ${GID} || \
    addgroup --gid ${GID} ${HOST_USER} && \
    id --name --user ${UID} || \
    adduser --gecos GECOS --disabled-password --uid ${UID} --gid ${GID} ${HOST_USER}

#Fix
RUN sed -i "s/:type_territoire/:\'type_territoire\'/g" /dist/data/gn2/atlas_ref_geo.sql && \
    sed -i "s/:type_maille/:\'type_maille\'/g" /dist/data/atlas/12.atlas.t_mailles_territoire.sql