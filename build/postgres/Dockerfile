ARG POSTGRES_IMAGE

FROM ${POSTGRES_IMAGE:-postgis/postgis:15-3.4}
# See: https://hub.docker.com/r/postgis/postgis
# TODO: build image to add specific optimized config, pg activity utility, vim, bash alias...

ARG TZ

# Change default Postgresql locale
RUN localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8

ENV LANG fr_FR.utf8
ENV TZ ${TZ}

# Install utils
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --quiet --no-install-recommends \
        vim htop sudo pg-activity \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Add /etc/vim/vimrc.local
RUN echo "runtime! defaults.vim" > /etc/vim/vimrc.local \
    && echo "let g:skip_defaults_vim = 1" >> /etc/vim/vimrc.local  \
    && echo "set mouse=" >> /etc/vim/vimrc.local

# Uncomment alias from /root/.bashrc
RUN sed -i -r 's/^# (alias|export|eval)/\1/' /root/.bashrc

# Add Pg Activity alias
RUN	grep -qxF "alias pga='pg_activity -U ${POSTGRES_USER} -d ${POSTGRES_DB}'" /root/.bashrc \
    || echo "alias pga='pg_activity -U ${POSTGRES_USER} -d ${POSTGRES_DB}'" >> /root/.bashrc