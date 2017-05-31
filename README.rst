This project contains the .yml and .env files required to run docker-compose for Ecolex project.

Installation guide
------------------

1.Install `Docker Compose <https://docs.docker.com/compose/>`_ .

2.Clone this project:
    
    git clone git@gitlab.com:ecolex/ecolex.docker.git
    
3.Move to the directory that contains .yml files

    cd ecolex.docker/ecx/

Production
----------

4.Make sure *mysql.env* and *web.env* have the right settings.

5.Create and start the containers:

    docker-compose up

Development
-----------

4.Create *docker-compose.override.yml* from the sample file
    
    cp docker-compose.override.yml.sample docker-compose.override.yml

5.Set volume in web service in *docker-compose.override.yml*. It should be the absolute path to the ecolex project.

6.Set *mysql.dev.env* and *web.dev.env* files.

* If you want to run with **DEBUG=False**, remove the **EDW_RUN_WEB_DEBUG** variable from *web.dev.env* . 

* Change the **EDW_RUN_SOLR_URI** if you don't want to use a local solr.


7.Create and start the containers:

    docker-compose up

**In development, the web service runs first with the init_dev command. This command makes migrations and installs some fixtures.**

**You have to change this command from docker-compose.ovveride.yml to debug after the first run if you don't want those to execute each time you run the containers**

    command: debug
    
    # command: init_dev

8.Use local solr **(optional)**

8.1. Make sure **EDW_RUN_SOLR_URI=http://solr:8983/solr/ecolex** in *web.dev.env*
    
8.2. Enter in the solr container:
        
    docker exec -it ecx_solr bash
    
8.3. Create a new core:
        
    solr create_core -c ecolex -d ecolex_initial_conf
