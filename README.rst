
This project contains the .yml and .env files required to run docker-compose for Ecolex project.

Installation guide
------------------

1.Install `Docker Compose <https://docs.docker.com/compose/>`_ .

2.Move to the directory that contains .yml files

    cd ecx

Production
----------

3.Make sure mysql.env and web.env have the right settings.

4.Create and start the containers:

    docker-compose up

Development
-----------

3.Create docker-compose.override.yml from the sample file
    
    cp docker-compose.override.yml.sample docker-compose.override.yml

4.Set volume in web service in docker-compose.override.yml. It should be the absolute path to the ecolex project.

5.Set mysql.dev.env and web.dev.env files.

6.Create and start the containers:

    docker-compose up