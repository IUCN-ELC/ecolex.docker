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

1. Choose the appropriate `docker-compose.yml` file from the `config` directory
   and copy it to the project directory:

        cp config/solr-zk/docker-compose.yml .

   The agreed setup contains 4 servers:

    * one that keeps the web application, a Solr node, and a ZooKeeper node
    * three that correspond to the data sources and run Solr nodes; 2 out of these 3
      servers will also host a ZooKeeper node

    In conclusion, there will be 3 categories of Docker Compose config files:
    * Web + Solr + ZK
    * Solr + ZK
    * ZK

1. Modify `docker-compose.yml` according to your needs:

    * ZK component:

            environment:
                - MYID=[id of current server in hostnames list]
                - HOSTNAMES=[server1;server2;server3]

    where **HOSTNAMES** is a list of the public IPs of all servers that act as ZooKeeper nodes,
    separated by `;`. For the current machine, use `0.0.0.0` instead of the public IP.
    **MYID** is the index of the current server in this list, starting with 1.

    Example:

        environment:
            - MYID=2
            - HOSTNAMES=75.75.75.75;0.0.0.0;75.75.75.76

    * Solr component:

            command:
                /opt/solr/bin/solr start -f -z [zk_server]:2181 -h [public_ip] -p 8983

    Replace `[zk_server]` with the public IP of one of the ZooKeeper nodes (if docker-compose
    also contains a `zk` component, this component will be linked to it, and `[zk_server]`
    will be replaced by `zk`) and `[public_ip]` with the current server's public IP.

1. Run docker container:

        docker-compose up

1. Make sure the public IP is visible from inside the docker container:


        docker exec -i -t ecolexdocker_solr1_1
        curl [public_ip]:8983

    If the answer is "No route to host", add the following iptables rule

        sudo iptables -I INPUT -s 0.0.0.0/0 -d 0.0.0.0/0 -i docker0 -m addrtype --dst-type LOCAL -j ACCEPT


Deployment
----------

1. Update project repository (on the machine where `web` component is running):

    cd ecolex-prototype
    git pull --rebase

1. Update configuration files in ZooKeeper:

    cp ecolex-prototype/configs/schema.xml solrconfigs/ecolex/conf/schema.xml
    docker exec -it ecolexdocker_solr_1 bash
    ./server/scripts/cloud-scripts/zkcli.sh -zkhost [ZK_HOST]:[ZK_PORT] -cmd upconfig --confname ecolex --confdir /ecolex_configs/ecolex/conf/

1. Reload schema:

    curl "http://[SOLR_HOST]:[SOLR_PORT]/solr/admin/collections?action=RELOAD&name=ecolex&indent=true"

_*Replace `[ZK_HOST]`, `[ZK_PORT]`, `[SOLR_HOST]`, `[SOLR_PORT]` with actual values._


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

* Alex Eftimie (alex.eftimie at eaudeweb.ro)
* Iulia Chiriac (iulia.chiriac at eaudeweb.ro)
