# Quick setup

This docker orchestration repo is meant to be used with edwd, see below.
However, if you do not wish to go into that or you don't want a bash & co environment,
you can use this repo without edwd.

For quick development setup, you will need docker (for Windows and Mac make sure you share the drive the sources are on with docker VM)

* Make sure deploy/secret.env exists and has sane values (see deploy/secret.env.sample)
* Make sure docker-compose.override.yml exists and has sane values (see sample companion)
* run `docker-compose run --rm solr solr-create -c ecolex -d conf` then exit
* run `docker-compose run --rm web init`
* run `docker-compose up -d`

You should be able to connect to http://localhost:8000

To connect to other solr than the one bootstrapped by this docker suite change `EDW_RUN_SOLR_URI` in `deploy/web/docker.env`


# Deploy architecture

This deployment structure is based on bash scripts and ssh
Is is meant to be orchestrated with a tool like edwd from wrapdocker https://github.com/danbaragan/wrapdocker
See README in that project for details.
edwd will export env vars found in `.env` file of this repo (overridable) into his own running environment. This
environment is set at each invocation and expires afterwards.

This repo contains build/deploy instructions specific to ecolex project
The edwd command will use this repo and any other source repos to perfom builds.
`build/<proj_name>/src.url` contains the url to such source repos
Environment var `EDW_BUILD_<proj_name>_SRC` can overwrite the src repo url with a local srource dir.
Use it to determine build to use local dirs for specific projescts rather than git repos. For development purposes.

There are three entities at play here:
1. Your Own machine.
2. The Host machine.
3. The docker container(s)

## Own machine

### General

This is the machine from where the deploy commands are passed to the Host machine.
This machine should hold:
1. deploy scripts 
2. own-to-host deploy environment variables
3. host-to-docker environment and secrets to be copied down to the host machine

This machine should be any machine that can run bash, git and ssh/scp, thus a Windos 10 machine should also work,
besides linux and Mac. Unless you plan to build the to be deployed docker images, no docker is required on Own machine.

One could simply ssh into the Host machine, copy docker-compose.yml & co files, copy secrets, copy the deploy scripts and run the deployment from
there. The target however is that such thing will not be required.

### Own machine requirements

* edwd
* git, and access to deploy/soruce repos
* bash/sh
* ssh-client with public/private keys for the user that will be authorized to log on the Host machine


## Host machine

### General

The Host machine runs the docker daemon and containers.
TODO: On docker swarm addition this will be the swarm host.
I shall assume that this machine is a linux machine. (actually a debian linux machine)
The Host machine should hold:
1. docker and docker-able user used for deployments
2. docker-compose.yml & co, environment files, secret files.
3. web server/apache
4. sshd; accept connections from Own machine into the docker-able user
5. firewall

### Host machine requirements

* sshd
* docker daemon/client (>1.10), docker-compose (>1.6)
* git
* apache
* iptables

### Host machine setup

#### sshd & deploy user

Create the deploy user, I shall call it deploy from now on

```bash
useradd --user-group --create-home --shell /bin/bash deploy
usermod -aG docker deploy
```
Add your the public key from the user you shall use on your Own machine to the `authorized_keys` of the deploy user of
Host machine. For RSA keys, copy `id_rsa.pub` from your user on the Own machine over to `/home/deploy/.ssh/authorized_keys`

Install openssh-server if missing and set AllowUsers to accept deploy if needed.


#### docker

wget a docker-engine deb file from https://apt.dockerproject.org/repo/pool/main/d/docker-engine/

It has to be greater than 1.10.
```bash
apt-get install libapparmor1
dpkg -i <docker.deb>
```
Or use any other method to setup docker

For docker-compose the easyest way is to install pip
```bash
apt-get install python-pip python-dev build-essentials
pip install docker-compose
```

#### git
Get git
`apt-get install git`

#### apache
TODO

#### iptables
TODO


## Docker environment

The docker environment is configured by:
* the environment used at build time on the Own machine. (eg: docker build args, src dir overrides)
* the environment used at deploy time on the Own machine. (eg: docker image tag to be pulled)
* the environment files copied at deploy time over from Own machine (this repo) to Host machine


# Deploying

## Some considerations

The files holding environment variables Own-to-Host are in `.env` files. This files are ignored by git.
TODO: This files currently hold both Own-to-Host env vars and Host-to-Docker vars.

The files holding Host-to-Docker vars are in `deploy/envs/`. With the exception of secret.env the rest of the files are
versioned in git. This means that these enviroment vars are not prone to change often and do not differ between
environments.
*Keep your secret.env file safe*
TODO: Make a clear separation between files that differ from one deployment to another and files that do not (and are in
git therefore). Also make a clear separation between environment vars that are Own-to-Host and the one Host-to-Docker

*When executing deploy or Own machine scripts (r-<some-name>.sh) one should populate his own environment with the proper
vars*
It is not recomended to do this in a persistend way like exporting env vars.
Rather this method is recomended:
```bash
env `xargs < .env` deploy/web/own-scripts/r-init.sh
```
Where .env is a file containing Own-to-Host env vars, but possibly some Host-to-Docker vars too
and the script to be run can be a script in `deploy/` or a `r-<some-script>.sh`
Usually this 'r' scripts are initializing live data and need to be hot instructed where exactly to pull data from
and what to initialize. This kind of information is not set in stone in the source code and thus is not in the repo
files holding env vars.

## Build

Befoare deploying one needs to build and push the required images to docker.hub
