# Quick setup

This docker orchestration repo is meant to be used with edwd, see below.
However, if you do not wish to go into that or you don't want a bash & co environment,
you can use this repo without edwd, usually for development purposes.



- Have docker, docker-compose, git on own machine;
(for Windows and Mac make sure you share the drive the sources are on with docker VM)
- Have docker orchestration repo  - this repo
- Have the subprojects src repos
- Setup docker-compose.override.yml (see .sample) 
- Make sure docker-compose.override.yml exists and has sane values Use volume to shadow the src files inside the image.
(see sample companion)
- Make sure deploy/secret.env exists and has sane values (see deploy/secret.env.sample)
- Make sure you mentioned any `EDW_RUN_*` vars overrides in `environment` clause of docker-compose.override.yml
- run `docker-compose run --rm solr solr-create -c ecolex -d conf` then exit
- run `docker-compose run --rm web init`
- run `docker-compose up -d`

You should be able to connect to http://localhost:8000

You should probably override the following `EDW_RUN_*` vars in docker-compose.override.yml:
- solr service:
  - EDW_RUN_SOLR_HEAP_MB=200 (avoid the huge production default on own machine)
  - EDW_RUN_SOLR_LOG_MB=10
- web service:
  - EDW_RUN_SOLR_URI=some_populated_solr_service If you do not wish tp populate your own solr.


# Deploy architecture

This deployment structure is based on bash scripts and ssh
Is is meant to be orchestrated with a tool like edwd from wrapdocker https://github.com/danbaragan/wrapdocker
See README in that project for details.
edwd will export env vars found in `.env` file of this repo into his own running environment. This
environment is set at each invocation and expires afterwards.

This repo contains build/deploy instructions specific to ecolex project
The edwd command will use this repo and any other source repos to perfom builds.
`EDW_BUILD_subproject_SRC` env var contains the url to such source repos; Its contents may also
contain a specific branch or tag like so: `githubUrl,branch_or_tag=name`

There are three entities at play here:
1. Your Own machine.
2. The Host machine.
3. The docker container(s)

## Own machine

The machine you use edwd on. You build docker images on this machine, you deploy from it to Host machine
and interact with orchestration suite  deployed on Host machine.

Generally one needs these installed on own machine:
- edwd
- git, and access to deploy/soruce repos
- bash/sh
- ssh-client with public/private keys for the user that will be authorized to log on the Host machine

One could simply ssh into the Host machine, copy docker-compose.yml, env files (used by `env_file`),
including files holding secrets, the `.env` file properly populated and start the docker suite from there

For details see:
https://github.com/danbaragan/wrapdocker/blob/master/README.md


## Host machine

The Host machine runs the docker daemon and containers.
I shall assume that this machine is a linux machine. (actually a debian linux machine)
The Host machine should hold:
1. docker and docker-able user used for deployments
2. docker-compose.yml & co, environment files, secret files, .env file
3. web server/apache
4. sshd; accept connections from Own machine into the docker-able user
5. firewall

### Host machine requirements

- sshd
- docker daemon/client (>1.10), docker-compose (>1.6)
- git
- apache
- iptables

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
- the environment used at build time on the Own machine, the `.env` file (eg: docker build args)
- the environment used at deploy time on the Own machine. the env used on own machine gets copied to Host machine in `.env`
- the environment files copied at deploy time over from Own machine (from this repo) to Host machine


# Deploying

## Some considerations

The files holding environment variables Own-to-Host are in `.env` files. This files are ignored by git.
These vars are named
- `EDW_BUILD_*` vars used at build time on own machine. Note however that docker-compose uses those too for suite start up
- `EDW_DEPLOY_*` vars used to connect from Own machine to Host machine.
These are used by the deploy procedure and all other commands sent from Own machine to docker suite
- `EDW_RUN_*` vars that docker-compose may mention in yml to override vars in files used in `env_file` clause.
The use of these vars in `.env` is intended mainly for development deploys.
Change the respective vars in files read by `env_file` clause instead! (named the same)

The files holding Host-to-Docker vars are in `deploy/` and specific subprojects.
With the exception of secret.env the rest of the files are versioned in git.
This means that these enviroment vars are not prone to change often and do not differ between
environments.

*Keep your secret.env file safe*

*When executing deploy or Own machine scripts (r-<some-name>.sh) one should populate his own environment with the proper
vars*

At least wit `EDW_DEPLOY_*` vars for the r-script to be able to connect to Host machine.
The `.env` file found on the Host machine, in the deployment dir will be used by docker-compose. 
(this file is placed there by the deploy procedure)

It is not recomended to do this in a persistend way like exporting env vars.
Rather this method is recomended:
```bash
env `xargs < .env` deploy/web/own-scripts/r-init.sh
```
Where .env is a file containing `EDW_DEPLOY_*` vars.
Usually this 'r' scripts are initializing a bare deployment or extract some current, live data from the running suite
One example would be the `deploy/solr/own-scripts/r-config-diff.sh` used to output a pach of the current solr config.
This patch is what is stored on git and perhaps needs to changed and updated from time to time.

*Please note that due to this expansion directly into the command line, .env files must not contain comments*


## Build
See https://github.com/danbaragan/wrapdocker/blob/master/README.md for details on edwd build and other commands.

- make sure `.env` vars are properly setup, at this phase the `EDW_BUILD_*` ones
- docker login
- `edwd build`  Inspect the displayed info, make sure is what you want and confirm with 'y'


## Deploy

- make sure `.env` vars are properly setup, at this phase both `EDW_BUILD_*` and `EDW_DEPLOY_*` ones
If you altered yml files and mention `EDW_RUN_*` overrides *expecting values from the docker-compose running environment*,
make sure those are vars are also present in `.env` file. Check files read by `env_file` yml clause 
to see what run vars can be altered.
- `edwd deploy -s`  Inspect the presentend info, make sure it is what you want and confirm.
If you want to let edwd automatically restart your suite afterwards don't give the `-s` option.
Usually, only for initial bare deploy one should refrain from restart.
The schema changes and collectstatic are performed on every regular start.

## Other operations

You can do some interaction with Host machine docker suite there without the need to login into a shel there.
Current edwd interactions from Own machine are:
- `edwd up` with optional `edwd up f` to see logs in foreground
- `edwd stop`
- `edwd lockdown some reason`  Doing so will place a lock on the Host machine so that future `edwd deploy`
will be refused with that reason. `edwd deploy -f` ignores this behaviour and deletes the lock

You may also run any r-sacript from deploy/subproj/own-scripts dir. Make sure you have at least `EDW_DEPLOY_*` vars
into its running environment, usually with ```env `xargs < .env` deploy/subproj/own-scripts/r-script.sh```

# Containers

## solr

Solr has its config on a named volume.
One could run a bash into the container (default solr user) and make changes to `/opt/solr/server/solr/ecolex/conf/`
One could also go as root on Host machine, go to the volume dir:
`docker volume inspect -f "{{ .Mountpoint }}" ecolexprototype_ecolex_solr` and interact with the same files.
Make sure you keep the `8983:8983` user and group needed by solr container though.