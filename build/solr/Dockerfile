FROM solr:5.5

LABEL maintainer="daniel.baragan@eaudeweb.ro"

USER root
RUN apt-get update && apt-get -y install patch

ARG EDW_solr_HEAP_MB=4096
ARG EDW_solr_LOG_MB=200

USER solr
RUN sed -i -e"s/^SOLR_HEAP=.*\$/SOLR_HEAP=\"${EDW_solr_HEAP_MB}m\"/" /opt/solr/bin/solr.in.sh \
    && sed -i -e"s/^log4j.appender.file.MaxFileSize=.*/log4j.appender.file.MaxFileSize=${EDW_solr_LOG_MB}MB/" /opt/solr/server/resources/log4j.properties

RUN cp -r ./server/solr/configsets/data_driven_schema_configs/conf conf
ADD ./build/solr/schema.xml \
    ./build/solr/solrconfig.xml.patch \
    conf/
ADD ./build/solr/container-scripts/config-diff.sh /opt/docker-solr/scripts/
RUN cd conf/ && patch -p1 < solrconfig.xml.patch
