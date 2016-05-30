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

1. Make sure its host owner matches the container's solr user:

        sudo chown 999:999 docker-volumes/solr

1. Copy the `solr` directory from a temporary container to the volume:

        docker run -it --rm -v /var/local/ecolex/ecolex.docker/docker-volumes/solr:/target solr cp -r server/solr/ /target/

    or copy from host machine to solr container

        sudo chown 999:999 solrconfigs/ecolex
        docker cp solrconfigs/ecolex ecolexdocker_solr_1:/opt/solr/server/solr/ecolex/

1. Run docker container:

        docker-compose up -d

1. Create the solr core:

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


Development Setup
-----------------

To setup a local development, one must follow the next steps:

1. Copy docker-compose.yml from config/dev/

        cp config/dev/docker-compose.yml .

2. Download a Solr core and unzip it inside solrconfig/ecolex/data

        cd config/dev/solr/ecolex
        wget http://ecolex-frontend.edw.lan/data.tgz
        tar xvf data.tgz

3. Start the 3 instances (zk, solr, web):

        docker-compose up

4. Link solr with zk (Run this inside the running solr container):

        docker exec -it ecolexdocker_solr_1 bash
        cd server/
        scripts/cloud-scripts/zkcli.sh -cmd upconfig -zkhost zk:2181 -d solr/ecolex/conf/ -n ecolex_conf
        scripts/cloud-scripts/zkcli.sh -cmd linkconfig -zkhost zk:2181 -collection ecolex_collection -confname ecolex_conf -solrhome solr
        scripts/cloud-scripts/zkcli.sh -cmd bootstrap -zkhost zk:2181 -solrhome solr

5. Restart containers

        docker-compose stop
        docker-compose up

Contacts
========

People involved in this project:

* Iulia Chiriac (iulia.chiriac at eaudeweb.ro)
* Andrei Meliș (andrei.melis at eaudeweb.ro)
* Taygun Agiali (taygun.agiali at eaudeweb.ro)
