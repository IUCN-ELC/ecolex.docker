FROM python:3.4-slim
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
    ;

#RUN rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/mariadb_config /usr/bin/mysql_config

RUN adduser --disabled-password --gecos '' --shell /bin/false web &&\
    adduser web sudo &&\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV THIS_HOME=/home/web \
    PATH=/home/web/bin:$PATH \
    EDW_WEB_PORT=8000

RUN mkdir -p $THIS_HOME/ecolex &&\
    mkdir -p $THIS_HOME/bin

# Add as few files of possible, we want to cache pip install step for good
ADD build/web/container-scripts/entrypoint.sh \
    build/web/container-scripts/import_updater.sh \
    $THIS_HOME/bin/

ARG EDW_SRC_DIR
# Every time you change the value of this variable the cache will be skipped from the next RUN step further
#ARG EDW_ECOLEX_VER
#RUN echo $EDW_ECOLEX_VER
ADD ./${EDW_SRC_DIR}/requirements.txt \
    ./${EDW_SRC_DIR}/requirements-dep.txt \
    $THIS_HOME/ecolex/

WORKDIR $THIS_HOME/ecolex
RUN pip install -r requirements-dep.txt

ADD ./$EDW_SRC_DIR $THIS_HOME/ecolex/
RUN chown -R web:web $THIS_HOME

EXPOSE $EDW_WEB_PORT

USER web
ENTRYPOINT ["entrypoint.sh"]
CMD ["run"]
