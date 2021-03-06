This project contains the .yml and .env files required to run docker-compose for Ecolex project.

Installation guide
------------------

1. Install `Docker Compose <https://docs.docker.com/compose/>`_ .

2. Clone this project:
    
    git clone git@gitlab.com:ecolex/ecolex.docker.git
    
3. Move to the directory that contains .yml files

    cd ecolex.docker/ecx/

Production
----------

4. Rename prod.env in .env, make sure it has the right settings.

5. Create and start the containers:

    docker-compose up -d

Development
-----------

4. Create *docker-compose.override.yml* from the sample file

    cp docker-compose.override.yml.sample docker-compose.override.yml

5. Add docker volume for service "app" in *docker-compose.override.yml*. It should be the absolute path to the ecolex source code.

    services:
      app:
        volumes:
        # path to root dir of ecolex source code
        - ../../ecolex:/home/web/ecolex


6. Rename dev.env in .env.

* If you want to run with **DEBUG=False**, remove the **EDW_RUN_WEB_DEBUG** variable from *.env* . 

* Change the **EDW_RUN_SOLR_URI** if you don't want to use a local solr.


7. Create and start the containers:

    docker-compose -f docker-compose.yml  -f docker-compose.override.yml up -d

**In development, the web service runs first with the init_dev command. This command makes migrations and installs some fixtures.**

**You have to change this command from docker-compose.ovveride.yml to debug after the first run if you don't want those to execute each time you run the containers**

    command: debug
    
    # command: init_dev

8. Use local solr **(optional)**

8.1. Make sure **EDW_RUN_SOLR_URI=http://solr:8983/solr/ecolex** in *.env*
    
8.2. Enter in the solr container:
        
    docker exec -it ecx_solr bash
    
8.3. Create a new core:
        
    solr create_core -c ecolex -d ecolex_initial_conf


Updating schema.xml
-------------------

    cd ecx
    docker cp solr/ecolex_initial_conf/conf/schema.xml ecx_solr:/opt/solr/server/solr/mycores/ecolex/conf
    docker exec -it ecx_solr rm /opt/solr/server/solr/mycores/ecolex/conf/managed-schema
    curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=ecolex"
