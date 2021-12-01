This project contains the .yml and .env files required to run docker-compose for Ecolex project.

Installation guide
------------------

1. Install docker.io and `Docker Compose <https://docs.docker.com/compose/>`_ .

2. Clone this project:
    
    git clone git@github.com:IUCN-ELC/ecolex.docker.git
    
3. Move to the directory that contains .yml files

    cd ecolex.docker/ecx/

Production
----------

4. Install Solr 8 and MariaDB 10

5. Copy the contents of solr/ecolex_initial_conf to the solr.home/data/ecolex to create the core, or in the case of an upgrade/server move use the https://github.com/freedev/solr-import-export-json tool to export the current core and import it to the new server. Keep in mind that when importing all the <copyField ... /> entries in the schema.xml file will have to be commented out to avoid import errors (because the export already contains the values for these fields, they don't have to be copied again). After the import uncomment the fields in the schema and restart Solr.

6. Rename .env.example in .env, make sure it has the right settings.

7. Create and start the containers:

    docker-compose up -d

8. Setup nginx to serve static files and do redirects:

 * Add a proxy to the application port

    location / {
      include conf.d/snippets/proxy.conf;
      proxy_pass http://localhost:7270;
    }

 * Map the /static path to the www_ecolex_static directory (the same one that is mapped in docker-compose for the app service as /www_static 

    location /static/ {
        alias /www_ecolex_static/;
    }

 * Check the redirects.txt file for the mappings to be added to the nginx configuration (legacy paths support). 

Development
-----------

4. Create *docker-compose.override.yml* from the sample file

    cp docker-compose.override.yml.example docker-compose.override.yml

5. Add docker volume for service "app" in *docker-compose.override.yml*. It should be the absolute path to the ecolex source code.

    services:
      app:
        volumes:
        # path to root dir of ecolex source code
        - ../../ecolex:/home/web/ecolex

6. Rename .env.example in .env.

* If you want to run with **DEBUG=False**, edit the **EDW_RUN_WEB_DEBUG** variable from *.env* . 

* Change the **EDW_RUN_SOLR_URI** if you don't want to use a local solr.

7. mkdir -p ./solr/data && chown 8983:8983 ./solr/data/

8. Create and start the containers:

    docker-compose -f docker-compose.yml  -f docker-compose.override.yml up -d

**In development, the web service runs first with the init_dev command. This command makes migrations and installs some fixtures.**

**You have to change this command from docker-compose.ovveride.yml to debug after the first run if you don't want those to execute each time you run the containers**

    command: debug
    
    # command: init_dev

**An alternative:**

* You can start the server manually to have more control in development.

* In order to do this, you have to comment "debug" and "init_dev" commands and uncomment the lines from docker-compose.override.yml dedicated to this.

* After the containers are up and running, start the server manually:

    docker exec -it ecolex_prod_app bash

    ./manage.py runserver 0:8000


9.1. Make sure **EDW_RUN_SOLR_URI=http://solr:8983/solr/ecolex** in *.env*

9.2. Enter in the solr container:
        
    docker exec -it ecx_solr bash
    
9.3. Create a new core:
        
    solr create_core -c ecolex -d /core-template/ecolex_initial_conf


Updating schema.xml
-------------------

    cd ecx
    docker cp solr/ecolex_initial_conf/conf/schema.xml ecx_solr:/var/solr/data/ecolex/conf
    docker exec -it ecx_solr rm /var/solr/data/ecolex/conf/managed-schema
    curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=ecolex"


Restoring data
--------------
    cd ecx
    docker cp [backup_filename].sql ecx_maria:/
    docker exec -it ecx_maria mysql -u ecolex -p ecolex < [backup_filename].sql
    
    rm -rf ./solr/data/ecolex/data/index/*
    mv [snapshot_dir]/* ./solr/data/ecolex/data/index/

**[snapshot_dir]: The name of the backed up snapshot to be restored, created after http://localhost:8983/solr/[core_name]/replication?command=backup**

    docker-compose restart

