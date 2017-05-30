This project contains the .yml and .env files required to run docker-compose for Ecolex project.

Installation guide
------------------

1.Install `Docker Compose <https://docs.docker.com/compose/>`_ .

2.Move to the directory that contains .yml files

    cd ecx

Production
----------

3.Make sure *mysql.env* and *web.env* have the right settings.

4.Create and start the containers:

    docker-compose up

Development
-----------

3.Create *docker-compose.override.yml* from the sample file
    
    cp docker-compose.override.yml.sample docker-compose.override.yml

4.Set volume in web service in *docker-compose.override.yml*. It should be the absolute path to the ecolex project.

5.Set *mysql.dev.env* and *web.dev.env* files.

* If you want to run with **DEBUG=False**, remove the **EDW_RUN_WEB_DEBUG** variable from *web.dev.env* . 

* Change the **EDW_RUN_SOLR_URI** if you don't want to use a local solr.

6.Use a local *schema.xml* for solr **(optional)**

Uncomment the following line from *docker-compose.yml* file and make sure the path points to the file:

    #- ./schema.xml:/opt/solr/server/solr/ecolex/conf/schema.xml


7.Create and start the containers:

    docker-compose up
    
8.Use local solr **(optional)**

8.1. Make sure **EDW_RUN_SOLR_URI=http://solr:8983/solr/ecolex** in *web.dev.env*
    
8.2. Enter in the solr container:
        
    docker exec -it ecx_solr bash
    
8.3. Copy *schema.xml* and *solrconfig.xml*:
        
    cp -r ecolex-initial_conf/ /opt/solr/server/solr/ecolex
    
    chown -R solr.solr /opt/solr/server/solr/ecolex
    
8.4. Create a new core:
        
    solr create_core -c ecolex
