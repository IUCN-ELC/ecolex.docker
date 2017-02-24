FROM solr:5.5

LABEL maintainer="daniel.baragan@eaudeweb.ro"

USER root
RUN apt-get update && apt-get -y --no-install-recommends install \
    vim \
    patch \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER solr

RUN cp -r ./server/solr/configsets/data_driven_schema_configs/conf conf
ADD ./build/solr/schema.xml \
    ./build/solr/solrconfig.xml.patch \
    conf/

ADD ./build/solr/container-scripts/config-diff.sh \
    ./build/solr/container-scripts/entrypoint.sh \
    /opt/docker-solr/scripts/

RUN cd conf/ && patch -p1 < solrconfig.xml.patch

ENTRYPOINT ["entrypoint.sh"]
CMD ["solr-foreground"]
