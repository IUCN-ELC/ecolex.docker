ECOLEX
======


Project Name
------------
The Project Name is `ECOLEX` (The gateway to environmental law).


Prerequisites - System packages
-------------------------------

These packages should be installed as superuser (root).

### Debian based systems ###

    apt-get install docker pip git
    pip install docker-compose

### RHEL based systems ###

    yum install docker git epel-release
    yum install python-pip
    pip install docker-compose

Prerequisites - System services
-------------------------------

These services should be running:

    sudo service docker start


Product directory
-----------------

Create a new user:

    useradd ecolex -d /var/local/ecolex

Give root access to the user (TODO: make it work without this step):

    visudo



Install dependencies
--------------------
The following commands will be run as an unprivileged user in the product
directory:

    su ecolex
    cd

1. Clone the repository:

    git clone https://github.com/eaudeweb/ecolex.docker.git --recursive
    cd ecolex.docker

2. Modify `docker-compose.yml` according to your needs:

    ports:
        - 8984:_public_port_
    command:
        /opt/solr/bin/solr start -f -z zk:2181 -h _public_ip_ -p _public_port_


3. Run docker container:

    sudo docker-compose up

Contacts
========

People involved in this project:

* Alex Eftimie (alex.eftimie at eaudeweb.ro)
* Iulia Chiriac (iulia.chiriac at eaudeweb.ro)


Copyright and license
=====================

This project is free software; you can redistribute it and/or modify it under
the terms of the EUPL v1.1.

More details under `LICENSE.txt`_.

.. _`LICENSE.txt`: https://github.com/eea/art17-consultation/blob/master/LICENSE.txt
