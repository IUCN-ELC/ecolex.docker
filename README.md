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

Create a docker group and add ecolex to it:

    sudo groupadd docker
    sudo usermod -aG docker ecolex
    sudo service docker restart


Install dependencies
--------------------
The following commands will be run as an unprivileged user in the product
directory:

    su ecolex
    cd

1. Clone the repository:

        git clone https://github.com/eaudeweb/ecolex.docker.git --recursive
        cd ecolex.docker

1. Create a directory on the host machine to store the `server/solr` directory:

        mkdir -p docker-volumes/solr


1. Copy the `solr` directory from a temporary container to the volume:

        docker run --user=root -it --rm -v /var/local/ecolex/ecolex.docker/docker-volumes/solr:/tmp/solr solr cp -r /opt/solr/server/solr/ /tmp/solr

1. Copy the ecolex solr core into the shared volume from host:

        cp -R solrconfigs/ecolex docker-volumes/solr/solr/

1. Make sure its host owner matches the container's solr user:

        sudo chown -R 999:999 docker-volumes/solr

1. Run docker container:

        docker-compose up -d

1. Create the solr core (on development env):

        docker exec -it ecolexdocker_solr_1 bin/solr create -c ecolex -d /ecolexconfigs/ecolex/conf

1. Make sure the public IP is visible from inside the docker container:

        docker exec -i -t ecolexdocker_solr1_1
        curl [public_ip]:8983

    If the answer is "No route to host", add the following iptables rule

        sudo iptables -I INPUT -s 0.0.0.0/0 -d 0.0.0.0/0 -i docker0 -m addrtype --dst-type LOCAL -j ACCEPT


Deployment
----------

1. Update project repository:

        cd ecolex-prototype
        git pull --rebase


Contacts
========

People involved in this project:

* Iulia Chiriac (iulia.chiriac at eaudeweb.ro)
* Andrei Meliș (andrei.melis at eaudeweb.ro)
* Taygun Agiali (taygun.agiali at eaudeweb.ro)
