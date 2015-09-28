FROM makuk66/docker-solr:5.2.1

ADD "ecolex" "/opt/solr/server/solr/ecolex"
USER root
RUN chown -R $SOLR_USER:$SOLR_USER /opt/solr/server/solr/ecolex
USER $SOLR_USER
