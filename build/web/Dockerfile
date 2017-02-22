FROM python:3.4-slim

# roles:
#   front - publishes ports to the world; this depends on run/docker-compose though...
#   cron - runs cron daemon
LABEL maintainer="daniel.baragan@eaudeweb.ro" \
      roles="front,cron"

RUN apt-get -y update &&\
    apt-get -y --no-install-recommends install \
    vim \
    sudo \
    netcat-traditional \
    git \
    libmariadb-client-lgpl-dev \
    gcc \
    libc-dev-bin \
    libc6-dev \
    libstdc++-4.9-dev \
    make \
    patch \
    cron \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV GNUPGHOME=/tmp/gnupghome \
    GOSU_VERSION=1.10

RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" && \
    mkdir $GNUPGHOME && \
    chmod og-rwx $GNUPGHOME && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

RUN ln -s /usr/bin/mariadb_config /usr/bin/mysql_config

RUN adduser --disabled-password --gecos '' --shell /bin/false web &&\
    adduser web sudo &&\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# need to consume this anyway
ARG EDW_BUILD_web_SRC
ENV ECOLEX_HOME=/home/web \
    PATH=/home/web/bin:$PATH \
    EDW_RUN_WEB_PORT=8000 \
    EDW_BUILD_web_SRC=$EDW_BUILD_web_SRC \
    USER=web

RUN mkdir -p $ECOLEX_HOME/ecolex &&\
    mkdir -p $ECOLEX_HOME/www_static &&\
    mkdir -p $ECOLEX_HOME/bin

# Add as few files of possible, we want to cache pip install step for good
ADD build/web/container-scripts/entrypoint.sh \
    build/web/container-scripts/root-entrypoint.sh \
    build/web/container-scripts/import_updater.sh \
    build/web/container-scripts/reprocess_from_db.sh \
    $ECOLEX_HOME/bin/

ADD build/web/ecolex.crontab \
    $ECOLEX_HOME/

ARG EDW_BUILD_SRC_DIR
# Every time you change the value of this variable the cache will be skipped from the next RUN step further
#ARG EDW_ECOLEX_VER
#RUN echo $EDW_ECOLEX_VER
ADD ./${EDW_BUILD_SRC_DIR}/requirements.txt \
    ./${EDW_BUILD_SRC_DIR}/requirements-dep.txt \
    $ECOLEX_HOME/ecolex/

WORKDIR $ECOLEX_HOME/ecolex
RUN pip install -r requirements-dep.txt

ADD ./$EDW_BUILD_SRC_DIR $ECOLEX_HOME/ecolex/
RUN chown -R web:web $ECOLEX_HOME

# no changes to volume are persistent after declaring it
VOLUME ["/home/web/www_static"]

EXPOSE $EDW_RUN_WEB_PORT

# USER web # use gosu in the entrypoint
ENTRYPOINT ["root-entrypoint.sh"]
CMD ["run"]
